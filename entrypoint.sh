#!/bin/bash
echo "PHP:"
php --version
echo "PHPCS:"
phpcs --version
echo "Reviewdog:"
reviewdog --version
echo "Composer:"
composer --version
echo "NodeJS:"
node -v

INPUT_LINTERS="${INPUT_LINTERS:-php}"
IFS=',' read -r -a INPUT_LINTERS <<< "${INPUT_LINTERS}"

cd "${GITHUB_WORKSPACE}" || exit 1

# unshallow clone
git remote set-branches origin '*'
git fetch --depth 1 --quiet

git diff "origin/${GITHUB_BASE_REF}" "origin/${GITHUB_HEAD_REF}" > /worker/curr-diff.diff

export REVIEWDOG_GITHUB_API_TOKEN="$INPUT_GITHUB_TOKEN"
export LINT_JSON
export LINT_RDJSONL
export LINT_EXIT_CODE
FIXABLE_ERRORS=0
FULL_RDJSONL=$(mktemp)

for INPUT_LINTER in "${INPUT_LINTERS[@]}"; do
    if [ ! -d "/worker/linter/${INPUT_LINTER}" ]; then
        continue;
    fi
    echo "* Running linter: ${INPUT_LINTER}"
    LINT_JSON=$(mktemp)
    LINT_RDJSONL=$(mktemp)
    . "/worker/linter/${INPUT_LINTER}/lint.sh"

    LINT_FIXABLE_ERRORS=$(cat "${LINT_JSON}" | php -f "/worker/linter/${INPUT_LINTER}/count-fixable.php");
    FIXABLE_ERRORS=$((FIXABLE_ERRORS + LINT_FIXABLE_ERRORS))
    ( cat "$LINT_JSON" | php -f "/worker/linter/${INPUT_LINTER}/rdjson-conv.php" ) > "${LINT_RDJSONL}"
    cat "${LINT_RDJSONL}" >> "${FULL_RDJSONL}"
done
echo "::set-output name=fixables::${FIXABLE_ERRORS}"

if [ "${FIXABLE_ERRORS}" -eq "0" ]; then
    cat "$FULL_RDJSONL" \
        | reviewdog \
            -name="${INPUT_TOOL_NAME:-Code Review}" \
            -f="rdjsonl" \
            -reporter="${INPUT_REPORTER:-github-pr-review}" \
            -filter-mode="${INPUT_FILTER_MODE:-added}" \
            -fail-on-error="${INPUT_FAIL_ON_ERROR:-true}" \
            -level="${INPUT_LEVEL:-warning}" || REVIEWDOG_EXIT_CODE=$?

    exit "${REVIEWDOG_EXIT_CODE:-0}"
fi
