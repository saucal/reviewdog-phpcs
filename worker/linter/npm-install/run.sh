#!/bin/bash
if [ -f "package-lock.json" ] && [ -f "package.json" ]; then
	echo "installing package-lock.json"
	npm ci --no-progress
elif [ -f "package.json" ]; then
	echo "installing package.json"
	npm install --no-progress
else
	echo "installing default @wordpress-scripts"
	cp /worker/linter/npm-install/package-lock.json ./package-lock.json
	cp /worker/linter/npm-install/package.json ./package.json
	npm ci --no-progress --quiet
fi
