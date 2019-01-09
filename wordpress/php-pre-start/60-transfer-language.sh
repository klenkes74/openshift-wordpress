#!/bin/sh

SOURCE_DIR=${APP_ROOT}/languages
TARGET_DIR=${APP_ROOT}/src/wp-content/languages

PLUGIN_SOURCE_DIR=${APP_ROOT}/plugin-languages
PLUGIN_DIR=${APP_ROOT}/src/wp-content/plugins

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

pushd . &> /dev/null
echo -n "Removing old plugin languages ... "
create_directory ${APP_ROOT}/data/plugin-languages

cd "${APP_ROOT}/data/plugin-languages"
for PLUGIN in * ; do
    if [ ! -d "${PLUGIN_DIR}/${PLUGIN}" ] ; then
        echo "${PLUGIN} ... "
        rm -rf "${PLUGIN}"
    fi
done

echo -n "Copying plugin languags ... "
cd ${PLUGIN_DIR}

for PLUGIN in * ; do
    if [ -d "${PLUGIN}/languages" -a ! -f "${PLUGIN}/languages/.installed" ] ; then
        echo -n "copying ... "

        cp "${PLUGIN_SOURCE_DIR}/${PLUGIN}"/* "${PLUGIN}/languages"

        echo -n "marking plugin as installed ... "
        touch "${PLUGIN}/languages/.installed"
        echo "done"
    else
        echo "${PLUGIN} skipped ... "
    fi
done

popd &>/dev/null
echo "done"