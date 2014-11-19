#!/usr/bin/env bats

. test/helpers.sh

fn() { . $BOLT_DIR/types/dir.sh $@; }

setup () {
  mkdir $BATS_TMPDIR/dir
}
teardown () {
  rm -rf $BATS_TMPDIR/dir
}

@test "dir status: returns MISSING if directory is not present" {
  run fn status $BATS_TMPDIR/dir/foo
  [ $status -eq $STATUS_MISSING ]
}

@test "dir status: returns OK if directory is present" {
  mkdir $BATS_TMPDIR/dir/foo
  run fn status $BATS_TMPDIR/dir/foo
  [ $status -eq $STATUS_OK ]
}

@test "dir status: returns MISMATCH if target exists and is not a directory" {
  touch $BATS_TMPDIR/dir/bar
  run fn status $BATS_TMPDIR/dir/bar
  echo $status
  [ $status -eq $STATUS_MISMATCH ]
}

@test "dir install: creates a directory if it is not present" {
  run fn install $BATS_TMPDIR/dir/bar
  ls -l $BATS_TMPDIR/dir/bar
  [ "$status" -eq 0 ]
}
