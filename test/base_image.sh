#!/bin/bash
SCRIPT_PATH="$(cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P)"
. "$SCRIPT_PATH/shared.sh"

function test_assert() {
  TEST_PREFIX=$1
  TEST_URL=$2
  http_test "$TEST_PREFIX '/' redirect'" $TEST_URL "" '<h1>403 Forbidden</h1>'
}

function test_init() {
  TEST_PREFIX=$1
  TEST_DIR=$2
  OUTPUT_DIR=$3
  git_main $TEST_PREFIX $TEST_DIR $OUTPUT_DIR
}

test "$@"
