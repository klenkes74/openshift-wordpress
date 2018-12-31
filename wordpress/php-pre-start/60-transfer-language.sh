#!/bin/sh

if [ ! -f "${DOCUMENT_ROOT}/wp-content/languages/.installed" ] ; then
    echo -n "Copying langauges ... "

    if [ ! -d ${DOCUMENT_ROOT}/wp-content/languages ] ; then
        echo -n "creating languages directory ... "
        mkdir -p ${DOCUMENT_ROOT}/wp-content/languages
    else
        echo -n "language directory exists ... "
    fi

    echo -n "copying ... "
    cp -a ${DOCUMENT_ROOT}/../languages/* ${DOCUMENT_ROOT}/wp-content/languages

    echo -n "marking installed files ... "
    touch ${DOCUMENT_ROOT}/wp-content/languages/.installed
    echo "done"
else
    echo "skipped"
fi