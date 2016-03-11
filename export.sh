#! /bin/sh
# -*- mode: Shell-script; indent-tabs-mode: nil; -*-

usage () {
    cat <<EOF
USAGE: $0 [-help|-h] [-source] <source> [<destination>]

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
            if [ -L $2 ]
            then
                if [ $1 != `readlink -f $2` ]
                then
                    rm -f $2
                fi
            else
                rm -f $2
            fi
        fi
        if [ ! -e $2 ]
        then
            PARENT_DIRECTORY=`dirname $2`
            cd $PARENT_DIRECTORY
            ln -s `get_relative_path $1 $PARENT_DIRECTORY` `basename $2`
        fi
    fi
}

SRC=
DST=
MAJOR_VERSION=
MINOR_VERSION=
PATCH_VERSION=
SOURCE=0
while [ $# -gt 0 ]
do
    if [ "$1" = "-help" -o "$1" = "-h" ]
    then
        usage
        exit 0
    elif [ "$1" = "-source" ]
    then
        SOURCE=1
    elif [ -z "$1" ]
    then
        true # Discarding empty command-line argument
    else
        if [ -z "$SRC" ]
        then
            SRC=$1
        elif [ -z "$DST" ]
        then
            DST=$1
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

if [ -z "$DST" ]
then
    DST=$SRC
fi
if [ ! -d $DST ]
then
    echo "$DST is not a directory" >&2
    exit 1
fi
# Determine the project name.
DOT_GIT=`find $SRC -type d -name .git -print | head -1`
if [ -z "$DOT_GIT" ]
then
    echo "Not in a git project" >&2
    exit 1
fi
pushd $DOT_GIT
PROJECT_NAME=`git remote get-url --all origin | sed -e 's?.*/\([^/]*\)$?\1?' | cut -d. -f1`
popd

# Determine the current version numbers.
VERSION_HEADER=`find $SRC/* -type f -name version.h -print | egrep -v "exports/mgc_home|ao./${PROJECT_NAME}_" 2>/dev/null`
if [ -z "$VERSION_HEADER" ]
then
    echo "No version file" >&2
    exit 1
fi
MAJOR_VERSION=`grep -E -e '#define[ 	]+[A-Z]+_MAJOR_VERSION[ 	]+[0-9]+' $VERSION_HEADER | sed -e 's/^.*_MAJOR_VERSION[ 	][ 	]*\([0-9][0-9]*\).*/\1/'`
MINOR_VERSION=`grep -E -e '#define[ 	]+[A-Z]+_MINOR_VERSION[ 	]+[0-9]+' $VERSION_HEADER | sed -e 's/^.*_MINOR_VERSION[ 	][ 	]*\([0-9][0-9]*\).*/\1/'`
PATCH_VERSION=`grep -E -e '#define[ 	]+[A-Z]+_PATCH_VERSION[ 	]+[0-9]+' $VERSION_HEADER | sed -e 's/^.*_PATCH_VERSION[ 	][ 	]*\([0-9][0-9]*\).*/\1/'`

# Update the version numbers in the info files.
for SRC_INFO in `find $SRC/* -type f -name '*_info' -print | egrep -v "exports/mgc_home|ao./${PROJECT_NAME}_"`
do
    N=`grep -n '<dependenc' $SRC_INFO | cut -d: -f1`
    if [ -z "$N" ]
    then
        N=`wc -l $SRC_INFO | awk '{print $1}'`
    fi
    if [ 1 -lt $N ]
    then
        N=`expr $N - 1`
    fi
    sed -i -e "1,$N {s/<major>[^<]*/<major>$MAJOR_VERSION/} ; 1,$N {s/<minor>[^<]*/<minor>$MINOR_VERSION/} ; 1,$N {s/<patch>[^<]*/<patch>$PATCH_VERSION/}" $SRC_INFO
done

# Update the version numbers in the documentation.
for SRC_DOCUMENTATION in `find $SRC/* -type f -name '*.dox' -print | egrep -v "exports/mgc_home|ao./${PROJECT_NAME}_"`
do
    sed -i -e "s/\(\\mainpage.*[^ 	]\)[ 	][ 	]*v[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*/\1 v$MAJOR_VERSION.$MINOR_VERSION.$PATCH_VERSION/" $SRC_DOCUMENTATION
done

if [ "$DST" = "$SRC" ]
then
    COMMAND=ensure_link
    PRESENT_PARTICIPLE="Linking"
    DST_SPECIFIC=$DST
else
    COMMAND=cp
    PRESENT_PARTICIPLE="Copying"
    DST_SPECIFIC=$DST/${PROJECT_NAME}_${MAJOR_VERSION}_${MINOR_VERSION}_${PATCH_VERSION}.${VCO}
    if [ ! -d $DST_SPECIFIC ]
    then
        echo "Creating $DST_SPECIFIC"
        mkdir -p $DST_SPECIFIC
    else
        echo "Using $DST_SPECIFIC"
    fi
fi


# Update the version numbers in the glue files.
for SRC_VERSION in `find $SRC/* -type f -name 'version' -print | egrep -v "exports/mgc_home|ao./${PROJECT_NAME}_"`
do
    sed -i -e "s/\(#define [ ]*RLS_VER \"v\)[0-9][0-9]*\.[0-9][0-9]*\(_.*\)/\1${MAJOR_VERSION}.${MINOR_VERSION}\2/" $SRC_VERSION
done

echo "$PRESENT_PARTICIPLE header files..."
if [ ! -d $DST_SPECIFIC/include/$PROJECT_NAME ]
then
    mkdir -p $DST_SPECIFIC/include/$PROJECT_NAME
fi
for SRC_HEADER in `find $SRC/* -type f \( -name '*.h' -o -name '*.i' \) -print | egrep -v "exports/mgc_home|ao./${PROJECT_NAME}_"`
do
    if grep -E '\\ingroup[     ]+public_api' $SRC_HEADER >/dev/null 2>&1
    then
        if [ ! -d `dirname $SRC_HEADER`/.git ]
        then
            SUB=`dirname $SRC_HEADER`
            SUB=`basename $SUB`
            if [ ! -d $DST_SPECIFIC/include/$PROJECT_NAME/$SUB ]
            then
                mkdir -p $DST_SPECIFIC/include/$PROJECT_NAME/$SUB
            fi

            DST_HEADER=$DST_SPECIFIC/include/$PROJECT_NAME/$SUB/`basename $SRC_HEADER`
        else
            if [ ! -d $DST_SPECIFIC/include/$PROJECT_NAME ]
            then
                mkdir -p $DST_SPECIFIC/include/$PROJECT_NAME
            fi

            DST_HEADER=$DST_SPECIFIC/include/$PROJECT_NAME/`basename $SRC_HEADER`
        fi
        if [ -f $DST_HEADER ]
        then
            rm -f $DST_HEADER >/dev/null 2>&1
        fi

        $COMMAND $SRC_HEADER $DST_HEADER
        chmod 664 $DST_HEADER
    fi
done

if [ 0 -ne $SOURCE ]
then
    echo "$PRESENT_PARTICIPLE source files..."
    if [ ! -d $DST_SPECIFIC/source/$PROJECT_NAME ]
    then
        mkdir -p $DST_SPECIFIC/source/$PROJECT_NAME
    fi
    for DIR in `find $SRC/* -type d -prune -print`
    do
        for DIR in `find $DIR -type f \( -name '*.h' -o -name '*.i' -o -name '*.cxx' -o -name '*_info' -o -name '*.profile' -o -name '*.txt' -o -name '*.mk' \) -print | sed -e "s?^$SRC/\([^/]*\)/.*?\1?" | sort -u`
        do
            for SRC_SOURCE in `find $SRC/$DIR -type f \( -name '*.h' -o -name '*.i' -o -name '*.cxx' -o -name '*_info' -o -name '*.profile' -o -name '*.txt' -o -name '*.mk' \) -print`
            do
                if [ ! -d `dirname $SRC_HEADER`/.git ]
                then
                    SUB=`dirname $SRC_SOURCE`
                    SUB=`basename $SUB`
                    if [ ! -d $DST_SPECIFIC/source/$PROJECT_NAME/$SUB ]
                    then
                        mkdir -p $DST_SPECIFIC/source/$PROJECT_NAME/$SUB
                    fi

                    DST_SOURCE=$DST_SPECIFIC/source/$PROJECT_NAME/$SUB/`basename $SRC_SOURCE`
                else
                    if [ ! -d $DST_SPECIFIC/source/$PROJECT_NAME ]
                    then
                        mkdir -p $DST_SPECIFIC/source/$PROJECT_NAME
                    fi

                    DST_SOURCE=$DST_SPECIFIC/source/$PROJECT_NAME/`basename $SRC_SOURCE`
                fi
                if [ -f $DST_SOURCE ]
                then
                    rm -f $DST_SOURCE >/dev/null 2>&1
                fi

                $COMMAND $SRC_SOURCE $DST_SOURCE
                chmod 664 $DST_SOURCE
            done
        done
    done
fi

echo "$PRESENT_PARTICIPLE library files..."
if [ ! -d $DST_SPECIFIC/lib ]
then
    mkdir -p $DST_SPECIFIC/lib
fi
for SRC_LIBRARY in `find $SRC/* -type f -name '*.so' -print | egrep -v "exports/mgc_home|ao./${PROJECT_NAME}_"`
do
    if [ -s $SRC_LIBRARY ]
    then
        DST_LIBRARY=$DST_SPECIFIC/lib/`basename $SRC_LIBRARY`
        $COMMAND $SRC_LIBRARY $DST_LIBRARY
        chmod 664 $DST_LIBRARY
    fi
done

echo "$PRESENT_PARTICIPLE info files..."
if [ ! -d $DST_SPECIFIC/lib ]
then
    mkdir -p $DST_SPECIFIC/lib
fi
for SRC_INFO in `find $SRC/* -type f -name '*_info' -print | egrep -v "exports/mgc_home|ao./${PROJECT_NAME}_"`
do
    if [ -s $SRC_INFO ]
    then
        DST_INFO=$DST_SPECIFIC/lib/`basename $SRC_INFO`
        $COMMAND $SRC_INFO $DST_INFO
        chmod 664 $DST_INFO
    fi
done

echo "$PRESENT_PARTICIPLE executable files..."
if [ ! -d $DST_SPECIFIC/bin ]
then
    mkdir -p $DST_SPECIFIC/bin
fi
for SRC_EXECUTABLE in `find $SRC/* -type f -name '*.exe' -print | egrep -v "exports/mgc_home|ao./${PROJECT_NAME}_"`
do
    if [ -s $SRC_EXECUTABLE ]
    then
        DST_EXECUTABLE=$DST_SPECIFIC/bin/`basename $SRC_EXECUTABLE`
        $COMMAND $SRC_EXECUTABLE $DST_EXECUTABLE
        chmod 775 $DST_EXECUTABLE
    fi
done

echo "$PRESENT_PARTICIPLE script files..."
if [ ! -d $DST_SPECIFIC/bin ]
then
    mkdir -p $DST_SPECIFIC/bin
fi
for SRC_SCRIPT in `find $SRC/* -type f -name '*.sh' -print | egrep -v "exports/mgc_home|ao./${PROJECT_NAME}_"`
do
    if grep -E '\\ingroup[     ]+public_api' $SRC_SCRIPT >/dev/null 2>&1
    then
        DST_SCRIPT=$DST_SPECIFIC/bin/`basename $SRC_SCRIPT`
        $COMMAND $SRC_SCRIPT $DST_SCRIPT
        chmod 775 $DST_SCRIPT
    fi
done

echo "$PRESENT_PARTICIPLE configuration files..."
if [ ! -d $DST_SPECIFIC/config ]
then
    mkdir -p $DST_SPECIFIC/config
fi
for SRC_CONFIGURATION in `find $SRC/* -type f -name '*.profile' -print | egrep -v "exports/mgc_home|ao./${PROJECT_NAME}_"`
do
    if grep -E '\\ingroup[     ]+public_api' $SRC_CONFIGURATION >/dev/null 2>&1
    then
        DST_CONFIGURATION=$DST_SPECIFIC/config/`basename $SRC_CONFIGURATION`
        $COMMAND $SRC_CONFIGURATION $DST_CONFIGURATION
        chmod 664 $DST_CONFIGURATION
    fi
done

if [ "$DST" != "$SRC" ]
then
    echo "Copying documentation..."
    for README in `find $SRC/* -prune -type f -regex '^.*/[A-Z][A-Z0-9_]*' -print`
    do
        cp $README $DST_SPECIFIC
    done
    rsync -rLptgo --exclude='*.pages' --chmod=a+r,ug+w --delete-delay $SRC/doc $DST_SPECIFIC
fi

echo "Done."
