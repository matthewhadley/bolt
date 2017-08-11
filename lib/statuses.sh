# action outcomes
STATUS_OK=0
STATUS_FAILED=1

# action can proceed
## missing
STATUS_MISSING=2
## exists but is outdated
STATUS_OUTDATED=3
## in a correctable (conflicting) state
STATUS_CONFLICT=4

# action cannot proceed
## state cannot be corrected
STATUS_MISMATCH=5
## required precondition not met
STATUS_FAILED_PRECONDITION=6
## type not supported on current platform
STATUS_UNSUPPORTED=7
## must be root
STATUS_UNPRIVILEGED=8

# colors
DEF='\033[00m'
RED='\033[31m'
GRE='\033[32m'
YEL='\033[33m'

# show status
bolt_status () {
  case "$1" in
    $STATUS_OK) echo -e "${GRE}ok${DEF}" ;;
    $STATUS_FAILED) echo -e "${RED}failed${DEF}" ;;
    $STATUS_MISSING) echo -e "${YEL}missing${DEF}" ;;
    $STATUS_OUTDATED) echo -e "${YEL}outdated${DEF}" ;;
    $STATUS_CONFLICT) echo -e "${YEL}conflict${DEF}" ;;
    $STATUS_MISMATCH) echo -e "${RED}mismatch${DEF}" ;;
    $STATUS_FAILED_PRECONDITION) echo -e "${RED}error (failed precondition)${DEF}" ;;
    $STATUS_UNSUPPORTED) echo -e "${RED}error (unsupported platform)${DEF}" ;;
    $STATUS_UNPRIVILEGED) echo -e "${RED}error (must be root)${DEF}" ;;
    *) echo -e "${RED}unknown status: $1${DEF}" ;;
  esac
}
