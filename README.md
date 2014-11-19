# [![Bolt](https://raw.githubusercontent.com/diffsky/bolt/master/assets/bolt-64.png)](https://github.com/diffsky/bolt) Bolt [![](https://travis-ci.org/diffsky/bolt.svg)](https://travis-ci.org/diffsky/bolt)

Bolt is a bash-based DSL for making assertions about the state of a system.

Bolt is a simpler version of [Bork](https://github.com/mattly/bork); less type functionality, fewer status values and no ability to convert configs into standalone scripts. Bolt was written as a means to manage my own systems.

Bolt is written against Bash 3.2 and common unix utilities such as sed, awk and grep. It is designed to work on any UNIX-based system, and be aware of platform differences between BSD and GPL versions of unix utilities.


## Bolt Configs

A Bolt config is a bash script that bolt runs. A basic config might look like:

```
ok npm gulp
ok github diffsky/scratch
ok yum nano
```

The declaration `ok` tells bolt that the following type (modified by any additional arguments) should be present. Bolt keeps no history of state - each bolt run is independent.


## Assertion Types

Bolt assertions are scripts that are run by bolt. They are invoked with an `action` and the arguments provided to `ok`. The assertion should be able to respond to `desc`, `status`, `install` and `upgrade` requests with various status codes.

You can run `bolt types` to get a list of the assertion types and basic info about their usage and options.

Currently supported types are:

```
* apt
assert package installed via apt-get on Debian or Ubuntu linux
> apt package

* dir
assert presence of a directory
> dir /tmp/foo

* file
assert presence, checksum, owner and permissions of a file
> file target source [arguments]
--perms 755       permissions for the file
--owner name      owner name of the file

* git
assert presence and state of a git repo
> git git@github.com:diffsky/bolt [arguments]
--dir    target   destination dir
--branch foo      git branch (defaults to master)

* github
interface for git type, using github user/repo combos
> github diffsky/bolt [arguments as per git type]

* group
assert presence of a unix group
> group admin

* npm
assert presence of an npm package installed globally
> npm package

* symlink
assert presence and target of a symlink
> symlink .bashrc ~/dotfiles/bashrc

* user
assert presence of a user on the system
> user admin
--shell /bin/bash
--groups admin,deploy

* yum
assert package installed via yum on CentOS or RedHat
> yum package
```
