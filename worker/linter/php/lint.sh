#!/bin/bash
PHPFILES=$(find . -type d -name "node_modules" -prune -o -type f -print | grep -Ec '\.(php)$')

if [ "$PHPFILES" -eq 0 ]; then
	echo "nothing to lint here";
	return 0;
fi

phpcs --runtime-set ignore_warnings_on_exit 1 --runtime-set ignore_errors_on_exit 1 --extensions="php" --ignore=*/node_modules/* --report-json="${LINT_JSON}" "${GITHUB_WORKSPACE}" || LINT_EXIT_CODE=$?

