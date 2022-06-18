#!/bin/bash
function syntax() {
  echo -e "Usage: $(basename $1) [OPTIONS]"
  echo
  echo -e "Tests the result of the Dockerfile"
  echo
  echo -e "Options:"
  echo -e "      --keep-alive  Keep the container running and show the exposed http port"
  echo -e "  -h, --help        Show this help"
}

function http_test() {
  TEST="$1"
  TEST_URL=$2
  FRAGMENT=$3
  EXPECTED_CONTENT="$4"

  if [ -z "$EXPECTED_CONTENT" ]; then
    if [ "$(curl -s -o /dev/null -w '%{http_code}\n' "$TEST_URL/$FRAGMENT")" == "200" ]; then
      echo "$TEST: PASSED"
    else
      >&2 echo "$TEST: FAILED"
      TEST_RESULT=false
    fi
  else
    if curl -s "$TEST_URL/$FRAGMENT" | grep -q "$EXPECTED_CONTENT" ; then
      echo "$TEST: PASSED"
    else
      >&2 echo "$TEST: FAILED"
      TEST_RESULT=false
    fi
  fi
}

function free_port() {
  while
    TEST_PORT=$(shuf -n 1 -i 49152-65535)
    netstat -atun | grep -q "$TEST_PORT"
  do
    continue
  done
  echo $TEST_PORT
}

function docker_rebuild() {
  TEST_IMAGE=$1
  TEST_CONTAINER=$2
  OUTPUT_DIR=$3
  echo
  echo "Docker build"
  docker kill $(docker ps -q -f "ancestor=$TEST_IMAGE") > /dev/null 2>&1
  docker rm $TEST_CONTAINER > /dev/null 2>&1
  docker rmi $TEST_IMAGE > /dev/null 2>&1
  docker build $OUTPUT_DIR -t $TEST_IMAGE

}

function docker_run() {
  TEST_IMAGE=$1
  TEST_CONTAINER=$2
  TEST_PORT=$3
  echo "Docker run"
  CONTAINER_ID=$(docker run -d -p $TEST_PORT:80 --name $TEST_CONTAINER $TEST_IMAGE)
  docker container logs $CONTAINER_ID
}

function docker_stop() {
  TEST_IMAGE=$1
  TEST_CONTAINER=$2
  TEST_URL=$3
  FLAG=$4
  if [ "$FLAG" == "--keep-alive" ]; then
      echo $TEST_IMAGE : $TEST_CONTAINER is available on $TEST_URL
  else
    docker kill $(docker ps -q -f "ancestor=$TEST_IMAGE") > /dev/null 2>&1
    docker rm $TEST_CONTAINER > /dev/null 2>&1
    docker rmi $TEST_IMAGE > /dev/null 2>&1
  fi
}

function git_main() {
  TEST_PREFIX=$1
  TEST_DIR=$2
  OUTPUT_DIR=$3
  cp -r $TEST_DIR/* $OUTPUT_DIR/
  git init .
  git checkout -q -b main
  git add .
  git commit -q --author="User <user@example.com>" -m 'first'
}

# Runs the tests
# It expects two functions to exist:
#   test_assert($TEST_PREFIX, $TEST_URL) - this one should check
#   test_init($TEST_PREFIX, $TEST_DIR, $OUTPUT_DIR)
function test() {
  if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    syntax $0
    exit 0
  fi

  BASE=$(basename -s .sh $0)
  TEST_IMAGE=test-antora-onbuild-$BASE
  TEST_CONTAINER=$TEST_IMAGE-1
  TEST_DIR=$SCRIPT_PATH/$BASE
  OUTPUT_DIR=$SCRIPT_PATH/../build/$BASE
  TEST_PORT=$(free_port)
  TEST_URL=http://localhost:$TEST_PORT
  TEST_PREFIX="[$BASE]"

  # Cleanup
  rm -rf $OUTPUT_DIR
  mkdir -p $OUTPUT_DIR
  cd $OUTPUT_DIR || exit

  echo "$TEST_PREFIX Initialize test"
  test_init $TEST_PREFIX $TEST_DIR $OUTPUT_DIR

  docker_rebuild $TEST_IMAGE $TEST_CONTAINER $OUTPUT_DIR
  docker_run $TEST_IMAGE $TEST_CONTAINER $TEST_PORT

  echo
  echo "$TEST_PREFIX Running tests against $TEST_IMAGE"
  TEST_RESULT=true
  test_assert $TEST_PREFIX $TEST_URL
  if [ "$TEST_RESULT" = true ]; then
    echo "$TEST_PREFIX ALL TESTS HAVE PASSED"
  else
    >&2 echo "$TEST_PREFIX THERE ARE TEST FAILURES"
  fi

  docker_stop $TEST_IMAGE $TEST_CONTAINER $TEST_URL $1

  if [ "$TEST_RESULT" = false ]; then
    exit 1
  fi

}