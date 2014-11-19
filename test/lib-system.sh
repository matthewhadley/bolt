#!/usr/bin/env bats

. test/helpers.sh

@test "md5_cmd fn: works" {
  run md5_cmd $BATS_TEST_FILENAME
  [ $status -eq $STATUS_OK ]
}

@test "perms_cmd fn: works" {
  run perms_cmd $BATS_TEST_FILENAME
  [ $status -eq $STATUS_OK ]
}

@test "exec fn: finds existing executable" {
  run exec ls
  [ $status -eq $STATUS_OK ]
}

@test "exec fn: errors when no existing executable found" {
  run exec doesnotexist
  [ $status -eq $STATUS_FAILED ]
}

@test "platform fn: reports non-Linux correctly" {
  run platform "Linux"
  [ $status -eq $STATUS_FAILED ]
}

@test "platform fn: eports Linux correctly" {
  skip_linux
  run platform "Linux"
  [ $status -eq $STATUS_OK ]
}
