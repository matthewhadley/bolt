#!/usr/bin/env bash
set -e

shellcheck {lib/*.sh,types/*.sh,bin/bolt} --exclude=2148,2005,2116,2155,2034,1090,2164,2154,2012
echo "shellcheck OK"
bats --tap test
