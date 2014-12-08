#!/usr/bin/env bats

. test/helpers.sh

fn() { . $BOLT_DIR/types/git.sh $@; }

setup () {
  mkdir $BATS_TMPDIR/git
}

teardown () {
  rm -rf $BATS_TMPDIR/git
}

@test "git status: returns MISMATCH if target exists and is not a repo" {
  skip_travis
  cd $BATS_TMPDIR/git
  mkdir lolspeak
  run fn status git@github.com:/diffsky/lolspeak
  [ $status -eq $STATUS_MISMATCH ]
}

@test "git status: returns MISSING if repo is not present" {
  skip_travis
  run fn status $BATS_TMPDIR/git/foo
  [ $status -eq $STATUS_MISSING ]
}

@test "git status: returns OK if a repo exists and is up-to-date" {
  skip_travis
  cd $BATS_TMPDIR/git
  git clone git@github.com:/diffsky/lolspeak
  run fn status git@github.com:/diffsky/lolspeak
  [ "$status" -eq $STATUS_OK ]
  run ls -l $BATS_TMPDIR/git/lolspeak
  [ "$status" -eq 0 ]
}

@test "git status: returns OUTDATED if a repo is behind" {
  skip_travis
  cd $BATS_TMPDIR/git
  git clone git@github.com:/diffsky/lolspeak
  cd lolspeak
  git reset --hard f9e693548502eabf9c63d42d6b626238f23b581d
  cd ..
  run fn status git@github.com:/diffsky/lolspeak
  [ $status -eq $STATUS_OUTDATED ]
}

@test "git status: returns CONFLICT if a repo is dirty" {
  skip_travis
  cd $BATS_TMPDIR/git
  git clone git@github.com:/diffsky/lolspeak
  cd lolspeak
  echo "wat" > wat
  cd ..
  run fn status git@github.com:/diffsky/lolspeak
  [ $status -eq $STATUS_CONFLICT ]
}

@test "git status: returns CONFLICT if a repo is ahead" {
  skip_travis
  cd $BATS_TMPDIR/git
  git clone git@github.com:/diffsky/lolspeak
  cd lolspeak
  echo "wat" > wat
  git config user.email "you@example.com"
  git config user.name "Your Name"
  git add .
  git commit -m "add wat"
  cd ..
  run fn status git@github.com:/diffsky/lolspeak
  [ $status -eq $STATUS_CONFLICT ]
}

@test "git status: returns CONFLICT if repo exists and is on another branch" {
  skip_travis
  cd $BATS_TMPDIR/git
  git clone git@github.com:/diffsky/lolspeak
  cd lolspeak
  git checkout -b wat
  cd ..
  run fn status git@github.com:/diffsky/lolspeak
  [ $status -eq $STATUS_CONFLICT ]
}

@test "git install: creates a repo if it is not present" {
  skip_travis
  cd $BATS_TMPDIR/git
  run fn install git@github.com:/diffsky/lolspeak
  [ "$status" -eq $STATUS_OK ]
  run ls -l $BATS_TMPDIR/git/lolspeak
  [ "$status" -eq 0 ]
}

@test "git install: creates a repo if it is not present, respecting the --dir target" {
  skip_travis
  run fn install git@github.com:/diffsky/lolspeak --dir $BATS_TMPDIR/git/lolspeak2
  [ "$status" -eq $STATUS_OK ]
  run ls -l $BATS_TMPDIR/git/lolspeak2
  [ "$status" -eq 0 ]
}

@test "git install: updates a local repo from an outdated branch" {
  skip_travis
  cd $BATS_TMPDIR/git
  git clone git@github.com:/diffsky/lolspeak
  cd lolspeak
  git checkout -b wat
  cd ..
  run fn install git@github.com:/diffsky/lolspeak
  [ $status -eq $STATUS_OK ]
  cd lolspeak
  run git rev-parse --abbrev-ref HEAD
  [ $output == "master" ]
}
