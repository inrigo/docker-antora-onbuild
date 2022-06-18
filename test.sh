#!/bin/bash
SCRIPT_PATH="$(cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P)"
. "$SCRIPT_PATH/test/shared.sh"

if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
  syntax
  exit 0
fi

TEST_DIR=$SCRIPT_PATH/test

TEST_RESULT=true
for d in $TEST_DIR/* ; do
  if [ -d "$d" ]; then
    BASE=$(basename $d)
    if [ -f $d.sh ]; then
      $d.sh "$@"
      if [ $? -ne 0 ]; then
        TEST_RESULT=false
      fi
    else
      echo "[$BASE] Test script not found: $d.sh"
      TEST_RESULT=false
    fi
    echo
  fi
done

if [ "$TEST_RESULT" = true ]; then
  echo "ALL TESTS HAVE PASSED"
else
  >&2 echo "THERE ARE TEST FAILURES"
fi

if [ "$TEST_RESULT" = false ]; then
  exit 1
fi
