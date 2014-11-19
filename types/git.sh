# modified from original version at https://github.com/mattly/bork

action=$1
url=$2
shift 2

OWD=$PWD

dir=$(arg dir $@)
[ -z "$dir" ] && dir="$(basename $url .git)"
branch=$(arg branch $@)
[ -z "$branch" ] && branch="master"

case $action in
  desc)
    echo "assert presence and state of a git repo"
    echo "> git git@github.com:diffsky/bolt [arguments]"
    echo "--dir    target   destination dir"
    echo "--branch foo      git branch (defaults to master)"
    ;;

  status)
    exec "git" || return $STATUS_FAILED_PRECONDITION

    # if the directory is missing, then repo is missing
    [ ! -d $dir ] && return $STATUS_MISSING

    # if the .git directory is missing, then mismatched
    if [ ! -d $dir/.git ]; then
      echo "destination directory exists, but is not a git repo"
      return $STATUS_MISMATCH
    fi

    cd $dir

    # update remote refs
    git fetch 2>&1
    status=$?

    # If the directory isn't a git repo, conflict
    if [ $status -gt 0 ]; then
      echo "error checking repo state ($status)"
      cd $OWD
      return $STATUS_CONFLICT
    fi

    state=$(git status -uno -b --porcelain | head -n 1)

    # check on expected branch
    match "$state" "## $branch"
    if [ "$?" -ne 0 ]; then
      echo "local git repository on another branch"
      cd $OWD
      return $STATUS_CONFLICT
    fi

    # check local dirty state
    git_dirty=$(git status -s | wc -l)
    if [ $git_dirty -gt 0 ]; then
      echo "local git repository is dirty"
      cd $OWD
      return $STATUS_CONFLICT
    fi

    # check local divergence ahead
    match "$state" "\[ahead"
    if [ "$?" -eq 0 ]; then
      echo "local git repository ahead of remote"
      cd $OWD
      return $STATUS_CONFLICT
    fi

    # check local divergence behind
    match "$state" "\[behind"
    [ "$?" -eq 0 ] && cd $OWD && return $STATUS_OUTDATED

    cd $OWD
    return $STATUS_OK
    ;;

  install)
    mkdir -p $dir
    git clone $url $dir
    cd $dir
    git checkout $branch &>/dev/null
    cd $OWD
    ;;

  upgrade)
    cd $dir
    git reset --hard 1>/dev/null
    git pull 1>/dev/null
    git checkout $branch &>/dev/null
    git log --pretty=oneline --abbrev-commit HEAD@{2}..
    cd $OWD
    ;;

  *) return 1 ;;
esac

