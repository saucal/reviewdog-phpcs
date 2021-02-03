#!/bin/bash
phpcs --version
reviewdog --version

cd "${GITHUB_WORKSPACE}" || exit 1

export REVIEWDOG_GITHUB_API_TOKEN="$INPUT_GITHUB_TOKEN"
PHPCS_JSON=$(mktemp)
phpcs --extensions="php" --report-json="${PHPCS_JSON}" "${GITHUB_WORKSPACE}" || PHPCS_EXIT_CODE=$?

FIXABLE_ERRORS=$(cat "${PHPCS_JSON}" | php -f '/count-fixable.php');
echo "::set-output name=fixables::${FIXABLE_ERRORS}"

if [ "${FIXABLE_ERRORS}" -eq "0" ]; then
    cat "$PHPCS_JSON" \
        | php -f "/rdjson-conv.php" \
        | reviewdog \
            -name="${INPUT_TOOL_NAME:-PHPCS}" \
            -f="rdjsonl" \
            -reporter="${INPUT_REPORTER:-github-pr-review}" \
            -filter-mode="${INPUT_FILTER_MODE:-added}" \
            -fail-on-error="${INPUT_FAIL_ON_ERROR:-true}" \
            -level="${INPUT_LEVEL:-warning}" || REVIEWDOG_EXIT_CODE=$?

    exit "${REVIEWDOG_EXIT_CODE}"
fi
