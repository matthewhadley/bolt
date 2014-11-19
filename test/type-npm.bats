#!/usr/bin/env bats

. test/helpers.sh

fn() { . $BOLT_DIR/types/npm.sh $@; }

@test "npm status: returns FAILED_PRECONDITION if not run as root" {
  skip_exec npm && skip_user
  run fn status doesnotexist
  [ $status -eq $STATUS_FAILED_PRECONDITION ]
}

@test "npm status: returns MISSING if package is not present" {
  skip_exec npm && skip_root
  run fn status doesnotexist
  [ $status -eq $STATUS_MISSING ]
}

@test "npm install: installs the package" {
  skip_exec npm && skip_root
  npm -g remove lolspeak
  run fn install lolspeak
  [ $status -eq $STATUS_OK ]
  run LOLSPEAK --version
  [ $status -eq $STATUS_OK ]
}

@test "npm status: returns OK if package is present" {
  skip_exec npm && skip_root
  run fn status lolspeak
  [ $status -eq $STATUS_OK ]
  npm -g remove lolspeak
}
