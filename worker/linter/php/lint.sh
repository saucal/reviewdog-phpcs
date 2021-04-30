#!/bin/bash
phpcs --extensions="php" --ignore=*/node_modules/* --report-json="${LINT_JSON}" "${GITHUB_WORKSPACE}" || LINT_EXIT_CODE=$?

