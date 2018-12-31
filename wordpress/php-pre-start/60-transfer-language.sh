#!/bin/sh

if [ ! -f "${APP_ROOT}/src/wp-content/languages/.installed" ] ; then
    echo -n "Copying langauges ... "

    if [ ! -d ${APP_ROOT}/src/wp-content/languages ] ; then
        echo -n "creating languages directory ... "
        mkdir -p ${APP_ROOT}/src/wp-content/languages
    else
        echo -n "language directory exists ... "
    fi

    echo -n "copying ... "
    cp -a ${APP_ROOT}/languages/* ${APP_ROOT}/src/wp-content/languages

    echo -n "marking installed files ... "
    touch ${APP_ROOT}/src/wp-content/languages/.installed
    echo "done"
else
    echo "skipped"
fi