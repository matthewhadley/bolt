#!/usr/bin/env bats

. test/helpers.sh

fn() { . $BOLT_DIR/types/brew.sh $*; }

@test "brew status: returns MISSING if package is not present" {
  skip_darwin && skip_exec brew
  run fn status doesnotexist
  [ $status -eq $STATUS_MISSING ]
}

@test "brew install: installs the package" {
  skip_darwin && skip_exec brew
  brew remove hr
  run fn install hr
  [ $status -eq $STATUS_OK ]
  which hr
  [ $status -eq $STATUS_OK ]
}

@test "brew status: returns OK if package is present" {
  skip_darwin && skip_exec brew
  run fn status hr
  [ $status -eq $STATUS_OK ]
}
