#!/bin/bash
CSSFILES=$(find . -type d -name "node_modules" -prune -o -type f -print | grep -Ec '\.(css|scss)$')

if [ "$CSSFILES" -eq 0 ]; then
	echo "nothing to lint here";
	return 0;
fi

if [ ! -d ./node_modules ]; then
	echo 'installing'
	. /worker/linter/npm-install/run.sh
fi
export STYLELINT_UNFIXABLE_JSON
STYLELINT_UNFIXABLE_JSON=$(mktemp)
export STYLELINT_ALL_JSON
STYLELINT_ALL_JSON=$(mktemp)

./node_modules/.bin/wp-scripts lint-style --formatter=json --fix > "${STYLELINT_UNFIXABLE_JSON}"
git reset --hard HEAD --quiet
./node_modules/.bin/wp-scripts lint-style --formatter=json > "${STYLELINT_ALL_JSON}"
LINT_EXIT_CODE=$?
if [ "${LINT_EXIT_CODE}" -eq "2" ]; then
	LINT_EXIT_CODE=0
fi

php -f "/worker/linter/${INPUT_LINTER}/stylelint-fixables.php" > "${LINT_JSON}"
