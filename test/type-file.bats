#!/usr/bin/env bats

. test/helpers.sh

fn() { . $BOLT_DIR/types/file.sh $@; }

setup () {
  mkdir -p $BATS_TMPDIR/file/{src,dst}
  echo "foo" > $BATS_TMPDIR/file/src/foo
  echo "bar" > $BATS_TMPDIR/file/dst/bar
  echo "match" > $BATS_TMPDIR/file/src/match
  echo "match" > $BATS_TMPDIR/file/dst/match
}

teardown () {
  rm -rf $BATS_TMPDIR/file
}

@test "file status: returns MISSING when target file is missing" {
  run fn status $BATS_TMPDIR/file/dst/missing $BATS_TMPDIR/file/src/foo
  [ $status -eq $STATUS_MISSING ]
}

@test "file status: returns FAILED_PRECONDITION when source file is missing" {
  run fn status $BATS_TMPDIR/file/dst/foo $BATS_TMPDIR/file/src/missing
  [ $status -eq $STATUS_FAILED_PRECONDITION ]
}

@test "file status: returns FAILED_PRECONDITION when required owner is missing" {
  run fn status $BATS_TMPDIR/file/dst/foo $BATS_TMPDIR/file/src/foo --owner missing
  [ $status -eq $STATUS_FAILED_PRECONDITION ]
}

@test "file status: returns FAILED_PRECONDITION when required group is missing" {
  run fn status $BATS_TMPDIR/file/dst/foo $BATS_TMPDIR/file/src/foo --group missing
  [ $status -eq $STATUS_FAILED_PRECONDITION ]
}

@test "file status: returns OUTDATED when target file contents difer from source" {
  run fn status $BATS_TMPDIR/file/dst/bar $BATS_TMPDIR/file/src/foo
  [ $status -eq $STATUS_OUTDATED ]
}

@test "file status: returns OK when target file matches source" {
  run fn status $BATS_TMPDIR/file/dst/match $BATS_TMPDIR/file/src/match
  [ $status -eq $STATUS_OK ]
}

@test "file status: returns CONFLICT when target file perms differ from source" {
  run fn status $BATS_TMPDIR/file/dst/match $BATS_TMPDIR/file/src/match --perms 744
  [ $status -eq $STATUS_CONFLICT ]
}

@test "file status: returns CONFLICT when target file owner differs from source" {
  skip_root
  run fn status $BATS_TMPDIR/file/dst/match $BATS_TMPDIR/file/src/match --owner nobody
  [ $status -eq $STATUS_CONFLICT ]
}

@test "file install: creates target file with source contents" {
  run fn install $BATS_TMPDIR/file/dst/sub/foo $BATS_TMPDIR/file/src/foo
  [ $status -eq $STATUS_OK ]
  run cat $BATS_TMPDIR/file/dst/sub/foo
  [ $output = "foo" ]
}

@test "file install: creates target file and sets perms" {
  run fn install $BATS_TMPDIR/file/dst/perms $BATS_TMPDIR/file/src/foo --perms 664
  [ $status -eq $STATUS_OK ]
  perms=$(perms_cmd $BATS_TMPDIR/file/dst/perms)
  [ $perms = "664" ]
}

@test "file install: creates target file and sets owner" {
  [ $EUID -ne 0 ] && skip "test must be run with root priveleges"
  run fn install $BATS_TMPDIR/file/dst/owner $BATS_TMPDIR/file/src/foo --owner nobody
  [ $status -eq $STATUS_OK ]
  owner=$(ls -l $BATS_TMPDIR/file/dst/owner | awk '{print $3}')
  [ $owner = "nobody" ]
}

@test "file install: creates target file and sets group" {
  [ $EUID -ne 0 ] && skip "test must be run with root priveleges"
  run fn install $BATS_TMPDIR/file/dst/owner $BATS_TMPDIR/file/src/foo --group nobody
  [ $status -eq $STATUS_OK ]
  group=$(ls -l $BATS_TMPDIR/file/dst/owner | awk '{print $4}')
  [ $group = "nobody" ]
}
