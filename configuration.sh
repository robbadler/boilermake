#! /bin/sh
# -*- mode: Shell-script; indent-tabs-mode: nil; -*-

if [ -z "$TMP" ]
then
    TMP=/tmp
fi

usage () {
    cat <<EOF
USAGE: $0 [-help|-h]

Interact with the configuration database.

EOF
}


DATABASE_FILE=`dirname $0`/configuration.db
while [ $# -gt 0 ]
do
    if [ "$1" = "-help" -o "$1" = "-h" ]
    then
        usage
        exit 0
    elif [ -z "$1" ]
    then
        true # Discarding empty command-line argument
    else
        usage
        exit 1
    fi
    shift
done
