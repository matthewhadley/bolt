#!/usr/bin/env bash
set -e

shellcheck {lib/*.sh,types/*.sh,bin/bolt} --exclude=2148,2005,2116
echo "shellcheck OK"
bats --tap test
