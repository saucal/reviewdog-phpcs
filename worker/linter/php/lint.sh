#!/bin/bash
phpcs --runtime-set ignore_warnings_on_exit 1 --runtime-set ignore_errors_on_exit 1 --extensions="php" --ignore=*/node_modules/* --report-json="${LINT_JSON}" "${GITHUB_WORKSPACE}" || LINT_EXIT_CODE=$?

