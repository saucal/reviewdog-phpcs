#!/bin/bash
echo "PHPCS:"
phpcs --version
echo "Reviewdog:"
reviewdog --version
echo "Composer:"
composer --version

INPUT_LINTER="${INPUT_LINTER:-php}"

cd "${GITHUB_WORKSPACE}" || exit 1

# unshallow clone
git remote set-branches origin '*'
git fetch --depth 1 --quiet

git diff "origin/${GITHUB_BASE_REF}" "origin/${GITHUB_HEAD_REF}" > /worker/curr-diff.diff

export REVIEWDOG_GITHUB_API_TOKEN="$INPUT_GITHUB_TOKEN"
export LINT_JSON
export LINT_RDJSONL
export LINT_EXIT_CODE
LINT_JSON=$(mktemp)
LINT_RDJSONL=$(mktemp)
. "/worker/linter/${INPUT_LINTER}/lint.sh"

FIXABLE_ERRORS=$(cat "${LINT_JSON}" | php -f "/worker/linter/${INPUT_LINTER}/count-fixable.php");
echo "::set-output name=fixables::${FIXABLE_ERRORS}"

( cat "$LINT_JSON" | php -f "/worker/linter/${INPUT_LINTER}/rdjson-conv.php" ) > "${LINT_RDJSONL}"

if [ "${FIXABLE_ERRORS}" -eq "0" ]; then
    cat "$LINT_RDJSONL" \
        | reviewdog \
            -name="${INPUT_TOOL_NAME:-PHPCS}" \
            -f="rdjsonl" \
            -reporter="${INPUT_REPORTER:-github-pr-review}" \
            -filter-mode="${INPUT_FILTER_MODE:-added}" \
            -fail-on-error="${INPUT_FAIL_ON_ERROR:-true}" \
            -level="${INPUT_LEVEL:-warning}" || REVIEWDOG_EXIT_CODE=$?

    exit "${REVIEWDOG_EXIT_CODE:-0}"
fi
