#! /bin/sh
# -*- mode: Shell-script; indent-tabs-mode: nil; -*-

usage () {
    cat <<EOF
USAGE: $0 [-help|-h] <source>

Export a git project.

EOF
}

get_relative_path () {
    CANDIDATE_PATH=$1
    REFERENCE_DIRECTORY=$2
    if [ -n "$CANDIDATE_PATH" -a -n "$REFERENCE_DIRECTORY" ]
    then
        if [ $CANDIDATE_PATH = $REFERENCE_DIRECTORY ]
        then
            echo .
        elif echo $CANDIDATE_PATH | grep "^$REFERENCE_DIRECTORY" >/dev/null 2>&1
        then
            echo $CANDIDATE_PATH | sed -e "s?$REFERENCE_DIRECTORY/*??"
        else
            CANDIDATE_PREFIX=
            CANDIDATE_SUFFIX=$CANDIDATE_PATH
            REFERENCE_PREFIX=
            REFERENCE_SUFFIX=$REFERENCE_DIRECTORY
            while echo $REFERENCE_SUFFIX | fgrep / >/dev/null 2>&1
            do
                CANDIDATE_PREFIX=`echo $CANDIDATE_SUFFIX | cut -d/ -f1 2>/dev/null`
                REFERENCE_PREFIX=`echo $REFERENCE_SUFFIX | cut -d/ -f1 2>/dev/null`
                if [ "$CANDIDATE_PREFIX" != "$REFERENCE_PREFIX" ]
                then
                    break
                fi

                CANDIDATE_SUFFIX=`echo $CANDIDATE_SUFFIX | sed -e "s?^[^/]*/\(.*\)?\1?"`
                REFERENCE_SUFFIX=`echo $REFERENCE_SUFFIX | sed -e "s?^[^/]*/\(.*\)?\1?"`
            done

            RELATIVE_PREFIX=
            while [ -n "$REFERENCE_SUFFIX" ]
            do
                if [ -z "$RELATIVE_PREFIX" ]
                then
                    RELATIVE_PREFIX=".."
                else
                    RELATIVE_PREFIX="$RELATIVE_PREFIX/.."
                fi
                REFERENCE_SUFFIX=`echo $REFERENCE_SUFFIX | sed -e "s?^[^/]*\\$?? ; s?^[^/]*/\(.*\)?\1?"`
            done

            echo $RELATIVE_PREFIX/$CANDIDATE_SUFFIX
        fi
    else
        echo $CANDIDATE_PATH
    fi
}

ensure_link () {
    if [ "$1" != "$2" ]
    then
        if [ -e $2 ]
        then
            if [ ! -L $2 ]
            then
                rm -f $2
            fi
        fi

        PARENT_DIRECTORY=`dirname $2`
        cd $PARENT_DIRECTORY
        ln -s `get_relative_path $1 $PARENT_DIRECTORY` `basename $2`
    fi
}

SRC=
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
        if [ -z "$SRC" ]
        then
            SRC=$1
        else
            break
        fi
    fi
    shift
done

if [ -z "$SRC" ]
then
    echo "No source directory specified" >&2
    usage
    exit 1
fi
if [ ! -d $SRC ]
then
    echo "$SRC is not a directory" >&2
    exit 1
fi

DOT_GIT=`find $SRC -type d -name .git -print | head -1`
if [ -z "$DOT_GIT" ]
then
    echo "Not in a git project" >&2
    exit 1
fi
PROJECT_NAME=`grep -E '[ 	]*url[ 	]*=[ 	]*' $DOT_GIT/config | sed -e 's?.*/\([^/]*\)$?\1?' | cut -d. -f1`
ensure_link $SRC $SRC/$PROJECT_NAME
