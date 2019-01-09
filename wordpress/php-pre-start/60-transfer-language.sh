#!/bin/sh

SOURCE_DIR=${APP_ROOT}/languages
TARGET_DIR=${APP_ROOT}/src/wp-content/languages

PLUGIN_SOURCE_DIR=${APP_ROOT}/plugin-languages
PLUGIN_DIR=${APP_ROOT}/src/wp-content/plugins

THEME_SOURCE_DIR=${APP_ROOT}/theme-languages
THEME_DIR=${APP_ROOT}/src/wp-content/themes

function create_directory() {
    DIRECTORY=$1

    if [ ! -d ${DIRECTORY} ] ; then
        echo -ne "creating ${DIRECTORY} ... "
        mkdir -p ${DIRECTORY}
    fi
}


echo -n "Copying languages to ${TARGET_DIR} ... "
create_directory ${APP_ROOT}/data/languages
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
        echo -n "copying '${PLUGIN}' ... "

        cp "${PLUGIN_SOURCE_DIR}/${PLUGIN}"/* "${PLUGIN}/languages"

        echo -n "marking plugin as installed ... "
        touch "${PLUGIN}/languages/.installed"
        echo "done"
    else
        echo "'${PLUGIN}' skipped ... "
    fi
done


echo -n "Removing old theme languages ... "
create_directory ${APP_ROOT}/data/theme-languages

cd "${APP_ROOT}/data/theme-languages"
for THEME in * ; do
    if [ ! -d "${THEME_DIR}/${THEME}" ] ; then
        echo "${THEME} ... "
        rm -rf "${THEME}"
    fi
done

echo -n "Copying theme languags ... "
cd ${THEME_DIR}

for THEME in * ; do
    if [ -d "${THEME}/languages" -a ! -f "${THEME}/languages/.installed" ] ; then
        echo -n "copying '${THEME}' ... "

        cp "${THEME_SOURCE_DIR}/${THEME}"/* "${THEME}/languages"

        echo -n "marking theme as installed ... "
        touch "${THEME}/languages/.installed"
        echo "done"
    else
        echo "'${THEME}' skipped ... "
    fi
done

popd &>/dev/null
echo "done"