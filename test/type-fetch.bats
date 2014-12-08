#!/usr/bin/env bats

. test/helpers.sh

fn() { . $BOLT_DIR/types/fetch.sh $@; }

setup () {
  mkdir -p $BATS_TMPDIR/fetch
  echo "contents" > $BATS_TMPDIR/fetch/outdated
  curl -sf https://raw.githubusercontent.com/diffsky/bolt/master/VERSION > $BATS_TMPDIR/fetch/VERSION
}

teardown () {
  rm -rf $BATS_TMPDIR/fetch
}

@test "fetch status: returns FAILED when cannot curl source" {
  run fn status $BATS_TMPDIR/fetch/foo https://raw.githubusercontent.com/diffsky/bolt/master/missing
  [ $status -eq $STATUS_FAILED ]
}

@test "fetch status: returns FAILED_PRECONDITION when required owner is missing" {
  run fn status $BATS_TMPDIR/fetch/foo https://raw.githubusercontent.com/diffsky/bolt/master/VERSION --owner missing
  [ $status -eq $STATUS_FAILED_PRECONDITION ]
}

@test "fetch status: returns FAILED_PRECONDITION when required group is missing" {
  run fn status $BATS_TMPDIR/fetch/foo https://raw.githubusercontent.com/diffsky/bolt/master/VERSION --owner missing
  [ $status -eq $STATUS_FAILED_PRECONDITION ]
}

@test "fetch status: returns OUTDATED when target file contents differ from source" {
  run fn status $BATS_TMPDIR/fetch/outdated https://raw.githubusercontent.com/diffsky/bolt/master/VERSION
  [ $status -eq $STATUS_OUTDATED ]
}

@test "fetch status: returns OK when target file matches source" {
  run fn status $BATS_TMPDIR/fetch/VERSION https://raw.githubusercontent.com/diffsky/bolt/master/VERSION
  [ $status -eq $STATUS_OK ]
}

@test "fetch status: returns CONFLICT when target file perms differ from source" {
  run fn status $BATS_TMPDIR/fetch/VERSION https://raw.githubusercontent.com/diffsky/bolt/master/VERSION --perms 744
  [ $status -eq $STATUS_CONFLICT ]
}

@test "fetch status: returns CONFLICT when target file owner differs from source" {
  skip_root
  run fn status $BATS_TMPDIR/fetch/VERSION https://raw.githubusercontent.com/diffsky/bolt/master/VERSION --owner nobody
  [ $status -eq $STATUS_CONFLICT ]
}

@test "fetch install: creates target file with source contents" {
  run fn install $BATS_TMPDIR/fetch/missing https://raw.githubusercontent.com/diffsky/bolt/master/VERSION
  [ $status -eq $STATUS_OK ]
  run cat $BATS_TMPDIR/fetch/missing
  [ $output = $(cat $BATS_TMPDIR/fetch/VERSION) ]
}

@test "fetch install: creates target file and sets perms" {
  run fn install $BATS_TMPDIR/fetch/perms https://raw.githubusercontent.com/diffsky/bolt/master/VERSION --perms 664
  [ $status -eq $STATUS_OK ]
  perms=$(perms_cmd $BATS_TMPDIR/fetch/perms)
  [ $perms = "664" ]
}

@test "fetch install: creates target file and sets owner" {
  [ $EUID -ne 0 ] && skip "test must be run with root priveleges"
  run fn install $BATS_TMPDIR/fetch/owner https://raw.githubusercontent.com/diffsky/bolt/master/VERSION --owner nobody
  [ $status -eq $STATUS_OK ]
  owner=$(ls -l $BATS_TMPDIR/fetch/owner | awk '{print $3}')
  [ $owner = "nobody" ]
}

@test "fetch install: creates target file and sets group" {
  [ $EUID -ne 0 ] && skip "test must be run with root priveleges"
  run fn install $BATS_TMPDIR/fetch/group https://raw.githubusercontent.com/diffsky/bolt/master/VERSION --group nobody
  [ $status -eq $STATUS_OK ]
  group=$(ls -l $BATS_TMPDIR/fetch/group | awk '{print $4}')
  [ $group = "nobody" ]
}
