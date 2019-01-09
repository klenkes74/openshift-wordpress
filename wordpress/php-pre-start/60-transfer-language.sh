#!/bin/sh

SOURCE_DIR=${APP_ROOT}/languages
TARGET_DIR=${APP_ROOT}/src/wp-content/languages
LANGUAGE_PERSISTENT_DIR=${APP_ROOT}/data/languages

PLUGIN_SOURCE_DIR=${APP_ROOT}/plugin-languages
PLUGIN_DIR=${APP_ROOT}/src/wp-content/plugins
PLUGIN_PERSISTENT_DIR=${APP_ROOT}/data/plugin-languages

THEME_SOURCE_DIR=${APP_ROOT}/theme-languages
THEME_DIR=${APP_ROOT}/src/wp-content/themes
THEME_PERSISTENT_DIR=${APP_ROOT}/data/theme-languages

function create_directory() {
    DIRECTORY=$1

    if [ ! -d ${DIRECTORY} ] ; then
        echo -ne "creating ${DIRECTORY} ... "
        mkdir -p ${DIRECTORY}
    fi
}


echo -n "Copying languages to ${TARGET_DIR} ... "
create_directory ${LANGUAGE_PERSISTENT_DIR}
if [ ! -f "${TARGET_DIR}/.installed" ] ; then
    create_directory ${TARGET_DIR}

    echo -n "copying ... "
    cp -a "${SOURCE_DIR}"/* "${TARGET_DIR}"

    touch "${TARGET_DIR}"/.installed
    echo "done"
else
    echo "skipped"
fi
echo "done"


pushd . &> /dev/null
echo -n "Removing old plugin languages ... "
create_directory ${PLUGIN_PERSISTENT_DIR}

cd "${PLUGIN_PERSISTENT_DIR}"
for PLUGIN in * ; do
    if [ ! -d "${PLUGIN_DIR}/${PLUGIN}" ] ; then
        echo -n "${PLUGIN} ... "
        rm -rf "${PLUGIN}"
    fi
done
echo "done"

echo -n "Copying plugin languags ... "
cd ${PLUGIN_DIR}

for PLUGIN in * ; do
    if [ -d "${PLUGIN_SOURCE_DIR}/${PLUGIN}" ] ; then
        if [ ! -f "${PLUGIN_PERSISTENT_DIR}/${PLUGIN}/.installed" ] ; then
            echo -n "${PLUGIN} ... "

            create_directory "${PLUGIN_PERSISTENT_DIR}/${PLUGIN}"

            cp "${PLUGIN_SOURCE_DIR}/${PLUGIN}"/* "${PLUGIN_PERSISTENT_DIR}/${PLUGIN}"

            touch "${PLUGIN_PERSISTENT_DIR}/${PLUGIN}"/.installed
        else
            echo -n "'${PLUGIN}' alread installed ... "
        fi
    else
        echo -n "'${PLUGIN}' has no language files ... "
    fi
done
echo "done"


echo -n "Removing old theme languages ... "
create_directory "${THEM_PERSISTENT_DIR}"

cd "${THEME_PERSISTENT_DIR}"
for THEME in * ; do
    if [ ! -d "${THEME_DIR}/${THEME}" ] ; then
        echo -n "${THEME} ... "
        rm -rf "${THEME}"
    fi
done
echo "done"

echo -n "Copying theme languags ... "
cd ${THEME_DIR}

for THEME in * ; do
    if [ -d "${THEME_SOURCE_DIR}/${THEME}" ] ; then
        if [ ! -f "${THEME_PERSISTENT_DIR}/${THEME}/.installed" ] ; then
            echo -n "${THEME} ... "

            create_directory "${THEME_PERSISTENT_DIR}/${THEME}"

            cp "${THEME_SOURCE_DIR}/${THEME}"/* "${THEME_PERSISTENT_DIR}/${THEME}"

            touch "${THEME_PERSISTENT_DIR}/${THEME}"/.installed
        else
            echo -n "'${THEME}' alread installed ... "
        fi
    else
        echo -n "'${THEME}' has no language files ... "
    fi
done
echo "done"

popd &>/dev/null
