#!/usr/bin/env bats

. test/helpers.sh

@test "arg fn: should pick out required argument from the start of a string" {
  run arg "foo" "--foo hello --bar world"
  [ $output = "hello" ]
}

@test "arg fn: should pick out required argument from the middle of a string" {
  run arg "bar" "--foo hello --bar world --zzz done"
  [ $output = "world" ]
}

@test "arg fn: should pick out required argument from the end of a string" {
  run arg "zzz" "--foo hello --bar world --zzz done"
  [ $output = "done" ]
}

@test "match fn: should find a string match when there is one" {
  run match "foo" "foo"
  [ $status = $STATUS_OK ]
}

@test "match fn: should not find a string match when there isn't one" {
  run match "foo" "bar"
  [ $status = $STATUS_FAILED ]
}

@test "match fn: should find a string match for a matching regex" {
  run match "foobar" "^foo"
  [ $status = $STATUS_OK ]
}

@test "match fn: should not find a string match for a non-matching regex" {
  run match "notfoobar" "^foo"
  [ $status = $STATUS_FAILED ]
}
