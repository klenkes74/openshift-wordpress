#!/bin/sh

SOURCE_DIR=${APP_ROOT}/languages
TARGET_DIR=${APP_ROOT}/src/wp-content/languages

function create_directory() {
    DIRECTORY=$1

    if [ ! -d ${DIRECTORY} ] ; then
        echo -ne "creating ${DIRECTORY} ... "
        mkdir -p ${DIRECTORY}
    fi
}


echo -n "Copying languages to ${TARGET_DIR} ... "

if [ ! -f "${TARGET_DIR}/.installed" ] ; then
    create_directory ${TARGET_DIR}

    echo -n "copying ... "
    cp -a ${SOURCE_DIR}/* ${TARGET_DIR}

    echo -n "marking installed files ... "
    touch ${TARGET_DIR}/.installed
    echo "done"
else
    echo "skipped"
fi