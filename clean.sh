#! /bin/bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo -e "\033[32mCleaning VM..\033[0m"
export VAGRANT_CWD="${DIR}/vagrant"
vagrant destroy -f

echo -e "\033[32mDone."
