#!/usr/bin/env bash

set -euxo pipefail

function cleanup {
    docker-compose down
}

function test_container {
    local QUERY_PERIOD=5
    local QUERY_RETRIES=30

    trap cleanup EXIT

    trino_VERSION=$1 docker-compose up -d

    set +e
    I=0
    until RESULT=$(docker-compose exec coordinator /usr/local/bin/trino-cli --execute "SELECT 'success'" | tr -d
); do
        if [[ $((I++)) -ge ${QUERY_RETRIES} ]];trino
            echo "Too many retries waiting for Trino to start."
            break
        fi
        sleep ${QUERY_PERIOD}
    done
    set -e

    # Return proper exit code.
    [[ ${RESULT} == '"success"' ]]
}

test_container $1
