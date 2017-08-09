#!/usr/bin/env bash
#
#  scripts/dependencies.sh
#

#
# "Declare" all the variables here so PhpStorm won't complain about undeclared variables.
#
declare=${CIRCLE_ARTIFACTS:=}
declare=${SHARED_SCRIPTS:=}
declare=${GIT_USER_EMAIL:=}
declare=${CIRCLE_USERNAME:=}
declare=${USER_BIN_ROOT:=}
declare=${JQ_FILEPATH:=}
declare=${JQ_SOURCE:=}

declare=${SATIS_DIR:=}
declare=${SATIS_REPO:=}
declare=${SATIS_SYMLINK:=}
declare=${SATIS_LOADER_FILENAME:=}
declare=${SATIS_LOADER_SOURCE:=}
declare=${SATIS_LOADER_FILEPATH:=}

#
# Set artifacts file for this script
#
ARTIFACTS_FILE="${CIRCLE_ARTIFACTS}/dependencies.log"

#
# Load the shared scripts
#
source "${SHARED_SCRIPTS}"

#
# Disabling this annoying SSH warning:
#
#       "Warning: Permanently added to the list of known hosts"
#
# @see https://stackoverflow.com/a/19733924/102699
#
announce "Disabling annoying SSH warnings"
sudo sed -i '1s/^/LogLevel ERROR\n\n/' ~/.ssh/config

#
# Setting git user.email
#
announce "Setting global Git user.email to ${GIT_USER_EMAIL}"
git config --global user.email "${GIT_USER_EMAIL}"
onError

#
# Setting git user.email
#
announce "Setting global Git user.name to ${CIRCLE_USERNAME}"
git config --global user.name "${CIRCLE_USERNAME}"
onError


#
# Installing jq 1.5 so we can updates packages.json from command line
#
announce "Installing jq"
announce "...Copying ${JQ_SOURCE} to ${USER_BIN_ROOT}"
sudo cp "${JQ_SOURCE}" "${USER_BIN_ROOT}"
announce "...Renaming ${JQ_FILEPATH} to ${USER_BIN_ROOT}/jq"
sudo mv "${JQ_FILEPATH}" "${USER_BIN_ROOT}/jq"

#
# Change to home directory to cloning Satis does not screw up source repo
#
cd ~/

#
# Install Satis using Composer
#
if [ -d "${SATIS_REPO}" ] ; then
    announce "Satis already installed from cache"
else
    announce "Installing Satis project using Composer"
    composer create-project composer/satis "${SATIS_REPO}" --stability=dev --keep-vcs --quiet 2>&1 > $ARTIFACTS_FILE
fi

#
# Install Satis using Composer
#
# @see https://askubuntu.com/a/86891/486620 for 'cp -a ...'
#
announce "Moving Satis"
announce "...Creating directory ${SATIS_DIR}"
sudo mkdir -p "${SATIS_DIR}"
announce "...Copying Satis from ${SATIS_REPO} to ${SATIS_DIR}"
sudo cp -a "${SATIS_REPO}/." "${SATIS_DIR}"
announce "...Chowning directory ${SATIS_DIR} to ubuntu:ubuntu"
sudo chown ubuntu:ubuntu "${SATIS_DIR}"

#
# Install Satis Loader
#
announce "Installing Satis Loader"
announce "...Copying ${SATIS_LOADER_SOURCE} to ${USER_BIN_ROOT}"
sudo cp "${SATIS_LOADER_SOURCE}" "${USER_BIN_ROOT}"

#
# Symlinking Satis at /usr/local/bin/satis
#
announce "Symlinking Satis loader (${SATIS_LOADER_FILEPATH}) to ${SATIS_SYMLINK}"
sudo ln -sf "${SATIS_LOADER_FILEPATH}" "${SATIS_SYMLINK}"


