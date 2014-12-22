#!/usr/bin/env bats

. test/helpers.sh

fn() { . $BOLT_DIR/types/user.sh $*; }

@test "user status: returns MISSING if user is not present" {
  skip_root && skip_linux
  run fn status doesnotexist
  [ $status -eq $STATUS_MISSING ]
}

@test "user install: creates the user" {
  skip_root && skip_linux
  run fn install boltusertest
  [ $status -eq $STATUS_OK ]
  run id -u boltusertest
  [ $status -ne $STATUS_FAILED ]
  userdel -r boltusertest
}

@test "user install: creates the user in required groups" {
  skip_root && skip_linux
  run fn install boltusertest --groups wheel
  [ $status -eq $STATUS_OK ]
  run id -u boltusertest
  [ $status -ne $STATUS_FAILED ]
  run groups boltusertest | grep "boltusertest" | wc -l
  [ $output -gt 0 ]
  userdel -r boltusertest
}

@test "user install: creates the user in required groups and sets primary group automatically as required" {
  skip_root && skip_linux
  groupadd boltusertest
  run fn install boltusertest --groups wheel boltusertest
  [ $status -eq $STATUS_OK ]
  run id -u boltusertest
  [ $status -ne $STATUS_FAILED ]
  run groups boltusertest | grep "wheel" | wc -l
  [ $output -gt 0 ]
  userdel -r boltusertest
}

@test "user status: returns OK if user is present" {
  skip_root && skip_linux
  run fn status root
  [ $status -eq $STATUS_OK ]
}
