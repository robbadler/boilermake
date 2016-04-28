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
USAGE: $0 [-help|-h] {name|makeflags|select|supported}

Interact with the configuration database.

Subcommands:

name - Determine the name of the current configuration.

makeflags - Determine the make flags of the curent configuration.

select - Update the current configuration.

supported - Determine whether the current configuration is supported.

EOF
}

vet_all_configurations () {
    if [ ! -f $BOILERMAKE_DIR/all_configurations ]
    then
        echo "Unable to find all configurations" >&2
        exit 1
    fi
}

valid_variable_name () {
    vet_all_configurations
    head -1 $BOILERMAKE_DIR/all_configurations | grep -E "[# ]$1([ ]*|$)" >/dev/null 2>&1
}

variable_names () {
    vet_all_configurations
    head -1 $BOILERMAKE_DIR/all_configurations | sed -e 's/^#[ ]*//'
}

valid_variable_value () {
    if [ ! -f $BOILERMAKE_DIR/$1 ]
    then
        echo "Unable to find $1" >&2
        exit 1
    fi
    grep -E "^[ ]*$2[ ]*$" $BOILERMAKE_DIR/$1 >/dev/null 2>&1
}

vet_supported_configurations () {
    vet_all_configurations
    if [ ! -f $DOT_DIR/supported_configurations ]
    then
        echo "Unable to find supported configurations" >&2
        exit 1
    fi
    for NAME in `cat $DOT_DIR/supported_configurations`
    do
        if ! grep -E "^[ ]*$NAME[ ]" $BOILERMAKE_DIR/all_configurations >/dev/null 2>&1
        then
            echo "Unsupported configuration: $NAME" >&2
            exit 1
        fi
    done
}

supported_configuration () {
    vet_supported_configurations
    awk '{print $1}' $DOT_DIR/supported_configurations | grep -E "^$1\$" >/dev/null 2>&1
}

get_configuration_name () {
    if [ -s $DOT_DIR/current_configuration ]
    then
        head -1 $DOT_DIR/current_configuration | awk '{print $1}'
    else
        echo ""
    fi
}

initialize_variables () {
    vet_all_configurations

    CURRENT=`get_configuration_name`
    if [ -n "$CURRENT" ]
    then
        INDEX=0
        for VAR_NAME in `variable_names`
        do
            INDEX=`expr $INDEX + 1`
            if [ "$VAR_NAME" != "NAME" ]
            then
                if ! env | grep -E "^${VAR_NAME}=" >/dev/null 2>&1
                then
                    PATTERN="{print \$$INDEX}"
                    eval $VAR_NAME=`grep -E "^[ ]*${CURRENT}" $BOILERMAKE_DIR/all_configurations | awk "$PATTERN"`
                fi
            fi
        done
    fi
}

execute_name () {
    initialize_variables

    PATTERN=""
    for VAR_NAME in `variable_names`
    do
        if [ "$VAR_NAME" != "NAME" ]
        then
            eval VAR_VALUE=\$$VAR_NAME
            if [ -n "$VAR_VALUE" ]
            then
                if ! valid_variable_value $VAR_NAME "$VAR_VALUE"
                then
                    echo "Invalid value for $VAR_NAME: $VAR_VALUE"
                    exit 1
                fi

                PATTERN="${PATTERN}[ ][ ]*${VAR_VALUE}"
            else
                PATTERN="${PATTERN}[ ][ ]*[^ ][^ ]*"
            fi
        fi
    done
    PATTERN="${PATTERN}\$"
    for NAME in `grep -E "$PATTERN" $BOILERMAKE_DIR/all_configurations | awk '{print $1}'`
    do
        if grep -E "^[ ]*$NAME[ ]*$" $DOT_DIR/supported_configurations >/dev/null 2>&1
        then
            echo $NAME
            return
        fi
    done
}

execute_makeflags () {
    vet_all_configurations

    MAKEFLAGS=""
    CURRENT=`get_configuration_name`
    if [ -n "$CURRENT" ]
    then
        INDEX=0
        for VAR_NAME in `variable_names`
        do
            INDEX=`expr $INDEX + 1`
            if [ "$VAR_NAME" != "NAME" ]
            then
                PATTERN="{print \$$INDEX}"
                VAR_VALUE=`grep -E "^[ ]*${CURRENT}" $BOILERMAKE_DIR/all_configurations | awk "$PATTERN"`
                MAKEFLAGS="$MAKEFLAGS $VAR_NAME=$VAR_VALUE"
            else
                PATTERN="{print \$$INDEX}"
                VAR_VALUE=`grep -E "^[ ]*${CURRENT}" $BOILERMAKE_DIR/all_configurations | awk "$PATTERN"`
                MAKEFLAGS="$MAKEFLAGS CONFIGURATION_NAME=$VAR_VALUE"
            fi
        done
    fi
    echo $MAKEFLAGS
}

execute_select () {
    CURRENT=`execute_name`
    echo $CURRENT | tee $DOT_DIR/current_configuration
}

execute_supported () {
    CURRENT=`execute_name`
    if ! supported_configuration $CURRENT
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
                true
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
            if [ $1 != "name" -a $1 != "makeflags" -a $1 != "select" -a $1 != "supported" ]
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
