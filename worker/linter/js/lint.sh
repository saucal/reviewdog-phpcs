#!/bin/bash
JSFILES=$(find . -type d -name "node_modules" -prune -o -type f -print | grep -Ec '\.(js|jsx|ts|tsx)$')

if [ "$JSFILES" -eq 0 ]; then
	echo "nothing to lint here";
	return 0;
fi

if [ ! -d ./node_modules ]; then
	echo 'installing'
	. /worker/linter/npm-install/run.sh
fi

./node_modules/.bin/wp-scripts lint-js --max-warnings 0 -f json . > "${LINT_JSON}"
LINT_EXIT_CODE=$?
if [ "${LINT_EXIT_CODE}" -eq "1" ]; then
	LINT_EXIT_CODE=0
fi
