#!/bin/bash

usage() {
    cat <<EOM
    Usage:
    $(basename $0) [-h] [-b] [-r] [-s] [-t]

    -h    Show this help text
    -b    Build dockers before run. Defaults to false.
    -r    Run the stack
    -s    Stop the stack
    -t    Start the test

EOM
    exit 0
}
[ $# -eq 0 ] && usage

while getopts ":hbrst" optname; do
    case "$optname" in
        "h") usage;;
        "b") build="true";;
        "r") start="true";;
        "s") teardown="true";;
        "t") test="true";;
        "?") echo "Unknown option $OPTARG" & exit 1;;
        ":") echo "No argument value for option $OPTARG" & exit 1;;
        *) echo "Unknown error while processing options" & exit 2;;
    esac
done

###
###  Functions
###
build-docker () {
    echo "-- Building docker image"
    CGO_ENABLED=0 GOOS=linux go build -a -ldflags '-extldflags "-static"' .
    if [[ "$?" != 0 ]]; then
        echo "Error building binary"
        exit 1
    fi
    docker build -t grace-test:local .
}

teardown-stack () { docker stack rm grace-test; }

run-stack () {
    echo "-- Starting stack"
    docker stack ls | grep -q grace-test
    if [[ "$?" -eq 0 ]]; then
        teardown-stack
        echo "...waiting for network removal"; sleep 20s
    fi
    docker stack deploy --compose-file docker-compose.yml grace-test
    echo "...waiting for stack initialisation"; sleep 10s
}

run-test() {
    echo "-- Starting update test"
    set -e
    docker service update grace-test_grace --force &>/dev/null &
    docker service logs grace-test_grace --follow
}

###
###  Script execution
###
if [ -n "$build" ]; then
    build-docker
fi
if [ -n "$start" ]; then
    run-stack
fi
if [ -n "$teardown" ]; then
    teardown-stack
fi
if [ -n "$test" ]; then
    run-test
fi
