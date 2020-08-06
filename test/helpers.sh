BOLT_DIR=$(dirname $BATS_TEST_DIRNAME)

for file in $BOLT_DIR/lib/*.sh; do
  . "$file"
done

# override BATS default TMPDIR for consistency when running tests as root
BATS_TMPDIR=$(mktemp -d -t bolt-dir.XXXXX)

skip_github() {
  [ "$GITHUB_REF" != "" ] && skip "requires non-github environment"
  return 0
}

skip_root() {
  [ $EUID -ne 0 ] && skip "requires root priveleges"
  return 0
}

skip_user() {
  [ $EUID -eq 0 ] && skip "requires normal user priveleges"
  return 0
}

skip_linux() {
  [ "$platform" != "Linux" ] && skip "requires Linux"
  return 0
}

skip_darwin() {
  [ "$platform" != "Darwin" ] && skip "requires OSX"
  return 0
}

skip_exec() {
  exec "$1"
  [ $? -ne 0 ] && skip "requires $1"
  return 0
}
