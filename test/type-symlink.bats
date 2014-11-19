#!/usr/bin/env bats

. test/helpers.sh

fn() { . $BOLT_DIR/types/symlink.sh $@; }

setup () {
  mkdir -p $BATS_TMPDIR/symlink/{src,dst}
  echo "foo" > $BATS_TMPDIR/symlink/src/foo
  echo "bar" > $BATS_TMPDIR/symlink/src/bar
}

teardown () {
  rm -rf $BATS_TMPDIR/symlink
}

@test "symlink status: returns FAILED_PRECONDITION if target is not specified" {
  run fn status $BATS_TMPDIR/symlink/dst/foo
  [ $status -eq $STATUS_FAILED_PRECONDITION ]
}

@test "symlink status: returns MISSING if sylimk is not present" {
  run fn status $BATS_TMPDIR/symlink/dst/foo $BATS_TMPDIR/symlink/src/foo
  [ $status -eq $STATUS_MISSING ]
}

@test "symlink status: returns STATUS_CONFLICT if source exists and is not a sylimk" {
  run fn status $BATS_TMPDIR/symlink/src/foo $BATS_TMPDIR/symlink/src/foo
  [ $status -eq $STATUS_CONFLICT ]
}

@test "symlink status: returns MISSING if sylimk is not present" {
  run fn status $BATS_TMPDIR/symlink/dst/foo $BATS_TMPDIR/symlink/src/foo
  [ $status -eq $STATUS_MISSING ]
}

@test "symlink install: creates a symlink from source to target" {
  run fn install $BATS_TMPDIR/symlink/dst/foo $BATS_TMPDIR/symlink/src/foo
  [ $status -eq $STATUS_OK ]
  run cat $BATS_TMPDIR/symlink/dst/foo
  [ $output == "foo" ]
}

@test "symlink status: returns CONFLICT if source exists as a symlink to a different target" {
  run fn status $BATS_TMPDIR/symlink/src/foo $BATS_TMPDIR/symlink/dst/bar
  [ $status -eq $STATUS_CONFLICT ]
}
