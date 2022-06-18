#!/bin/bash
SCRIPT_PATH="$(cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P)"
. "$SCRIPT_PATH/shared.sh"

function test_assert() {
  TEST_PREFIX=$1
  TEST_URL=$2

  http_test "$TEST_PREFIX '/' redirect'" $TEST_URL "" '<meta http-equiv="refresh" content="0; url=example/main/index.html">'
  http_test "$TEST_PREFIX main index page" $TEST_URL "/example/main/index.html" '<h1 class="page">Overview</h1>'
  http_test "$TEST_PREFIX 1.0.x index page" $TEST_URL "/example/v1.0.x/index.html" '<h1 class="page">Overview v1.0.x</h1>'
  http_test "$TEST_PREFIX Asset include" $TEST_URL "/example/main/_images/image1.png" ''
  http_test "$TEST_PREFIX Diagram support" $TEST_URL "/example/main/module1/_images/diag-9cba913b3b686b6f8abdaadb7c8a7727e9264ac7.svg" '<text fill="#000000" font-family="sans-serif" font-size="14" lengthAdjust="spacing" textLength="10" x="112.5" y="27.8467">B</text>'
  http_test "$TEST_PREFIX Search support" $TEST_URL "/example/main/index.html" '<input id="search-input" type="text" placeholder="Search the docs" autofocus>'
}

function test_init() {
  TEST_PREFIX=$1
  TEST_DIR=$2
  OUTPUT_DIR=$3
  git_main $TEST_PREFIX $TEST_DIR $OUTPUT_DIR
  git checkout -q -b v1.0.x
  sed -i 's/Overview/Overview v1.0.x/' $OUTPUT_DIR/docs/modules/ROOT/pages/index.adoc
  git add .
  git commit -q --author="User <user@example.com>" -m 'second'
  git checkout -q main
}

test "$@"
