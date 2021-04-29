#!/bin/bash
JSFILES=$(find . | grep -Ec '\.(js|jsx|ts|tsx)$')

if [ "$JSFILES" -eq 0 ]; then
	echo "nothing to lint here";
	return 0;
fi

if [ ! -d ./node_modules ]; then
	echo 'installing'
	. /worker/linter/npm-install/run.sh
fi

./node_modules/.bin/wp-scripts lint-js -f json . > "${LINT_JSON}"
