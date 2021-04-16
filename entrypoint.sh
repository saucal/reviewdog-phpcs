#!/bin/bash
echo "PHPCS:"
phpcs --version
echo "Reviewdog:"
reviewdog --version
echo "Composer:"
composer --version

cd "${GITHUB_WORKSPACE}" || exit 1

# unshallow clone
git remote set-branches origin '*'
git fetch --depth 1 --quiet

git diff "origin/${GITHUB_BASE_REF}" "origin/${GITHUB_HEAD_REF}" > /worker/curr-diff.diff

export REVIEWDOG_GITHUB_API_TOKEN="$INPUT_GITHUB_TOKEN"
PHPCS_JSON=$(mktemp)
phpcs --extensions="php" --report-json="${PHPCS_JSON}" "${GITHUB_WORKSPACE}" || PHPCS_EXIT_CODE=$?

FIXABLE_ERRORS=$(cat "${PHPCS_JSON}" | php -f '/worker/count-fixable-php.php');
echo "::set-output name=fixables::${FIXABLE_ERRORS}"

if [ "${FIXABLE_ERRORS}" -eq "0" ]; then
    cat "$PHPCS_JSON" \
        | php -f "/worker/rdjson-conv.php" \
        | reviewdog \
            -name="${INPUT_TOOL_NAME:-PHPCS}" \
            -f="rdjsonl" \
            -reporter="${INPUT_REPORTER:-github-pr-review}" \
            -filter-mode="${INPUT_FILTER_MODE:-added}" \
            -fail-on-error="${INPUT_FAIL_ON_ERROR:-true}" \
            -level="${INPUT_LEVEL:-warning}" || REVIEWDOG_EXIT_CODE=$?

    exit "${REVIEWDOG_EXIT_CODE:-0}"
fi
