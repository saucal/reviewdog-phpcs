#!/bin/bash
phpcs --extensions="php" --report-json="${LINT_JSON}" "${GITHUB_WORKSPACE}" || LINT_EXIT_CODE=$?

