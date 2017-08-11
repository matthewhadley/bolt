#!/usr/bin/env bats

. test/helpers.sh

fn() { . $BOLT_DIR/types/yum.sh $*; }

@test "yum status: returns STATUS_UNPRIVILEGED if not run as root" {
  skip_exec yum && skip_user
  run fn status doesnotexist
  [ $status -eq $STATUS_UNPRIVILEGED ]
}

@test "yum status: returns MISSING if package is not present" {
  skip_exec yum && skip_root
  run fn status doesnotexist
  [ $status -eq $STATUS_MISSING ]
}

@test "yum install: installs the package" {
  skip_exec yum && skip_root
  run fn install nano
  [ $status -eq $STATUS_OK ]
  which nano
  [ $status -eq $STATUS_OK ]
}

@test "yum status: returns OK if package is present" {
  skip_exec yum && skip_root
  run fn status nano
  [ $status -eq $STATUS_OK ]
}
