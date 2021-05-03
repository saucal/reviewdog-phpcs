#!/bin/bash
INPUT_LINTER="${1}"
if [ ! -d "/worker/linter/${INPUT_LINTER}" ]; then
	exit
fi
LINT_RDJSON="/worker/executions/${INPUT_LINTER}"
if [ -f "${LINT_RDJSON}" ]; then
	cat "${LINT_RDJSON}"
	exit
fi

FIXABLE_ERRORS_PREV=$(cat "${FIXABLE_ERRORS}")

echo "* Running linter: ${INPUT_LINTER}"
LINT_JSON=$(mktemp)
. "/worker/linter/${INPUT_LINTER}/lint.sh"

LINT_FIXABLE_ERRORS=$(cat "${LINT_JSON}" | php -f "/worker/linter/${INPUT_LINTER}/count-fixable.php");
FIXABLE_ERRORS_NEW=$((FIXABLE_ERRORS_PREV + LINT_FIXABLE_ERRORS))
echo -n "${FIXABLE_ERRORS_NEW}" > "${FIXABLE_ERRORS}"
( cat "$LINT_JSON" | php -f "/worker/linter/${INPUT_LINTER}/rdjson-conv.php" ) > "${LINT_RDJSON}"
cat "${LINT_RDJSON}"
