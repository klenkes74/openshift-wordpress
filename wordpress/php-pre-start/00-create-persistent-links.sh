#!/bin/sh

function create_directory() {
    DIRECTORY=$1

    if [ ! -d ${DIRECTORY} ] ; then
        echo -ne "creating ${DIRECTORY} ... "
        mkdir -p ${DIRECTORY}
    fi
}

pushd . &> /dev/null
echo -n "Creating persistent directories ... "
cd "${APP_ROOT}/data"

create_directory languages
create_directory plugin-languages
create_directory theme-languages
create_directory uploads
create_directory upgrade

popd &>/dev/null
echo "done"
