#!/usr/bin/env bats

. test/helpers.sh

fn() { . $BOLT_DIR/types/dir.sh $*; }

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

@test "dir status: returns FAILED_PRECONDITION when required owner is missing" {
  run fn status $BATS_TMPDIR/dir/bar --owner missing
  [ $status -eq $STATUS_FAILED_PRECONDITION ]
}

@test "dir status: returns FAILED_PRECONDITION when required group is missing" {
  run fn status $BATS_TMPDIR/dir/bar --group missing
  [ $status -eq $STATUS_FAILED_PRECONDITION ]
}

@test "dir status: returns CONFLICT when target dir perms differ from source" {
  run fn status $BATS_TMPDIR/dir/bar $BATS_TMPDIR/dir/bar --perms 666
  [ $status -eq $STATUS_CONFLICT ]
}

@test "dir status: returns CONFLICT when target dir owner differs from source" {
  skip_root
  run fn status $BATS_TMPDIR/dir/bar --owner root
  [ $status -eq $STATUS_CONFLICT ]
}

@test "dir install: creates target directory and sets perms" {
  run fn install $BATS_TMPDIR/dir/bar --perms 555
  [ $status -eq $STATUS_OK ]
  perms=$(perms_cmd $BATS_TMPDIR/dir/bar)
  [ $perms = "555" ]
}

@test "dir install: creates target directory and sets owner" {
  [ $EUID -ne 0 ] && skip "test must be run with root priveleges"
  run fn install $BATS_TMPDIR/dir/bar --owner nobody
  [ $status -eq $STATUS_OK ]
  owner=$(ls -ld $BATS_TMPDIR/dir/bar | awk '{print $3}')
  [ $owner = "nobody" ]
}

@test "dir install: creates target directory and sets group" {
  [ $EUID -ne 0 ] && skip "test must be run with root priveleges"
  run fn install $BATS_TMPDIR/dir/bar --group nobody
  [ $status -eq $STATUS_OK ]
  owner=$(ls -ld $BATS_TMPDIR/dir/bar | awk '{print $4}')
  [ $owner = "nobody" ]
}
