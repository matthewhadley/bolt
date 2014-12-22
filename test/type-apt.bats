#!/usr/bin/env bats

. test/helpers.sh

fn() { . $BOLT_DIR/types/yum.sh $*; }

@test "apt status: returns FAILED_PRECONDITION if not run as root" {
  skip_exec apt-get && skip_exec dpkg && skip_user
  run fn status doesnotexist
  [ $status -eq $STATUS_FAILED_PRECONDITION ]
}

@test "apt status: returns MISSING if package is not present" {
  skip_exec apt-get && skip_exec dpkg && skip_root
  run fn status doesnotexist
  [ $status -eq $STATUS_MISSING ]
}

@test "apt install: installs the package" {
  skip_exec apt-get && skip_exec dpkg && skip_root
  run fn install nano
  [ $status -eq $STATUS_OK ]
  which nano
  [ $status -eq $STATUS_OK ]
}

@test "apt status: returns OK if package is present" {
  skip_exec apt-get && skip_exec dpkg && skip_root
  run fn status nano
  [ $status -eq $STATUS_OK ]
}
