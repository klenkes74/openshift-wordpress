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

    echo -n "marking installed files ... "
    touch "${TARGET_DIR}"/.installed
    echo "done"
else
    echo "skipped"
fi

pushd . &> /dev/null
echo -n "Removing old plugin languages ... "
create_directory ${PLUGIN_PERSISTENT_DIR}

cd "${PLUGIN_PERSISTENT_DIR}"
for PLUGIN in * ; do
    if [ ! -d "${PLUGIN_DIR}/${PLUGIN}" ] ; then
        echo "${PLUGIN} ... "
        rm -rf "${PLUGIN}"
    fi
done

echo -n "Copying plugin languags ... "
cd ${PLUGIN_DIR}

for PLUGIN in * ; do
    if [ -d "${PLUGIN_SOURCE_DIR}/${PLUGIN}/languages" ] ; then
        if [! -f "${PLUGIN}/languages/.installed" ] ; then
            create_directory "${PLUGIN_PERSISTENT_DIR}/${PLUGIN}"

            echo -n "copy '${PLUGIN}' ... "
            cp "${PLUGIN_SOURCE_DIR}/${PLUGIN}"/* "${PLUGIN}/languages"

            echo -n "marking plugin as installed ... "
            touch "${PLUGIN}"/languages/.installed
            echo "done"
        else
            echo "'${PLUGIN}' alread installed"
        fi
    else
        echo "'${PLUGIN}' has no language files"
    fi
done


echo -n "Removing old theme languages ... "
create_directory "${THEM_PERSISTENT_DIR}"

cd "${THEME_PERSISTENT_DIR}"
for THEME in * ; do
    if [ ! -d "${THEME_DIR}/${THEME}" ] ; then
        echo "${THEME} ... "
        rm -rf "${THEME}"
    fi
done

echo -n "Copying theme languags ... "
cd ${THEME_DIR}

for THEME in * ; do
    if [ -d "${THEME_SOURCE_DIR}/${THEME}/languages" ] ; then
        if [ ! -f "${THEME}/languages/.installed" ] ; then
            create_directory "${THEME_PERSISTENT_DIR}/${PLUGIN}"

            echo -n "copy '${THEME}' ... "
            cp "${THEME_SOURCE_DIR}/${THEME}"/* "${THEME}/languages"

            echo -n "marking theme as installed ... "
            touch "${THEME}"/languages/.installed
            echo "done"
        else
            echo "'${THEME}' alread installed"
        fi
    else
        echo "'${THEME}' has no language files"
    fi
done

popd &>/dev/null
echo "done"