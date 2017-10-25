# 0.5.2

- fix perms check for directories

# 0.5.1

- shellcheck fixes

# 0.5.0

- allow lenient do/check usage
- re-instate extra lines removed from bolt

# 0.4.0

- extra lines removed from bolt logging output

# 0.3.0

- new unprivileged state, consistent error checking method

# 0.2.0
- add support for setting group, owner, perms for dir types
- disable spinner for npm installs

# 0.1.0
- add support for homebrew

# 0.0.9
- fix testing for existing groups in user type

# 0.0.8
- configure shellcheck to run in build

# 0.0.7
- apply shellcheck

# 0.0.6
- cross-system tmp file creation (used by fetch type)

# 0.0.5
- add fetch assertion type, which curls remote files
- redo exec check to not echo out found executable

# 0.0.4
- rename version to VERSION

# 0.0.3
- smarter autocomplete

# 0.0.2
- add CHANGELOG
- remove reporter output from `do` and `check` operations
- move version into own file to open way for version checking

# 0.0.1
- intial release
