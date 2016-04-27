#! /bin/sh
# -*- mode: Shell-script; indent-tabs-mode: nil; -*-

BOILERMAKE_DIR=`dirname $0`
DOT_DIR=`readlink -e $BOILERMAKE_DIR/../.boilermake`
if [ -z "$TMP" ]
then
    TMP=/tmp
fi

usage () {
    cat <<EOF
USAGE: $0 [-help|-h] {current|setcurrent|supported}

Interact with the configuration database.

Subcommands:

current - Determine the current configuration.

setcurrent - Update the current configuration.

supported - Determine whether the current configuration is supported.

EOF
}

vet_supported_configurations () {
    if [ ! -f $DOT_DIR/supported_configurations ]
    then
        echo "Unable to find supported configurations" >&2
        exit 1
    fi
}

valid_variable_name () {
    vet_supported_configurations
    head -1 $DOT_DIR/supported_configurations | grep -E "[# ]$1([ ]*|$)" >/dev/null 2>&1
}

variable_names () {
    vet_supported_configurations
    head -1 $DOT_DIR/supported_configurations | sed -e 's/^#[ ]*//'
}

valid_variable_value () {
    grep -E "^[ ]*$2[ ]*$" $BOILERMAKE_DIR/$1 >/dev/null 2>&1
}

execute_current () {
    if [ -s $DOT_DIR/current_configuration ]
    then
        head -1 $DOT_DIR/current_configuration | awk '{print $1}'
    else
        PATTERN=""
        for VAR_NAME in `variable_names`
        do
            if [ "$VAR_NAME" = "NAME" ]
            then
                continue
            fi

            eval VAR_VALUE=\$$VAR_NAME
            if [ -z "$VAR_VALUE" ]
            then
                echo "Missing variable: $VAR_NAME" >&2
                exit 1
            fi

            if ! valid_variable_value $VAR_NAME "$VAR_VALUE"
            then
                echo "Invalid value for $VAR_NAME: $VAR_VALUE"
                exit 1
            fi

            PATTERN="${PATTERN}[ ][ ]*${VAR_VALUE}"
        done
        PATTERN="${PATTERN}\$"
        grep -E "$PATTERN" $DOT_DIR/supported_configurations | awk '{print $1}'
    fi
}

execute_setcurrent () {
    CURRENT=`execute_current`
    echo $CURRENT > $DOT_DIR/current_configuration
}

execute_supported () {
    CURRENT=`execute_current`
    if ! awk '{print $1}' $DOT_DIR/supported_configurations | grep -E "^${CURRENT}\$" >/dev/null 2>&1
    then
        echo "Unsupported platform: $CURRENT" >&2
        exit 1
    fi
}

SUBCOMMAND=
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
        if echo $1 | grep -F = >/dev/null 2>&1
        then
            VAR_NAME=`echo $1 | cut -d= -f1`
            if ! valid_variable_name $VAR_NAME
            then
                echo "Unrecognized variable: $VAR_NAME" >&2
                echo "" >&2
                usage
                exit 1
            else
                eval "$1"
            fi
        elif [ -n "$SUBCOMMAND" ]
        then
            echo "Subcommand already specified: $SUBCOMMAND" >&2
            echo "" >&2
            usage
            exit 1
        else
            if [ $1 != "current" -a $1 != "setcurrent" -a $1 != "supported" ]
            then
                echo "Unrecognized subcommand: $1" >&2
                echo "" >&2
                usage
                exit 1
            else
                SUBCOMMAND=$1
            fi
        fi
    fi
    shift
done

if [ -n "$SUBCOMMAND" ]
then
    execute_$SUBCOMMAND
fi
