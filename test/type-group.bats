#!/usr/bin/env bats

. test/helpers.sh

fn() { . $BOLT_DIR/types/group.sh $*; }

@test "group status: returns STATUS_UNPRIVILEGED if not run as root" {
  skip_user
  run fn status doesnotexist
  [ $status -eq $STATUS_UNPRIVILEGED ]
}

@test "group status: returns FAILED_PRECONDITION if groupadd cmd is not present" {
  platform "Linux" && skip "groupadd cmd avilable on Linux"
  skip_root
  run fn status wheel
  [ $status -eq $STATUS_FAILED_PRECONDITION ]
}

@test "group status: returns OK if group is present" {
  skip_root && skip_linux
  run fn status wheel
  [ $status -eq $STATUS_OK ]
}

@test "group status: returns MISSING if group is not present" {
  skip_root && skip_linux
  run fn status doesnotexist
  [ $status -eq $STATUS_MISSING ]
}

@test "group install: creates the group" {
  skip_root && skip_linux
  run fn install boltgrouptest
  [ $status -eq $STATUS_OK ]
  groupdel boltgrouptest
}
