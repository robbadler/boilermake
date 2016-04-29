#! /bin/sh
# -*- mode: Shell-script; indent-tabs-mode: nil; -*-

BIN_DIR=`dirname $0`

usage () {
    cat <<EOF
USAGE: $0 [-help|-h] [-configuration <name>] [-source] <source> [<destination>]

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
        if [ $TYPE = "det" ]
        then
            ln -s $1 `basename $2`
        else
            ln -s `get_relative_path $1 $PARENT_DIRECTORY` `basename $2`
        fi
    fi
}

ensure_directory () {
    if [ -f $1 -o -h $1 ]
    then
        rm -f $1
    fi
    if [ ! -d $1 ]
    then
        mkdir -p $1
    fi
}

TYPE=det
CONFIGURATION=
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
    elif [ "$1" = "-normal" ]
    then
        TYPE=normal
    elif [ "$1" = "-det" ]
    then
        TYPE=det
    elif [ "$1" = "-configuration" ]
    then
        shift
        CONFIGURATION=$1
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

if [ -z "$CONFIGURATION" ]
then
    CONFIGURATION=`$BIN_DIR/configuration.sh name`
fi

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

if [ -z "$VCO" ]
then
    VCO=`mgcvco`
fi
if [ -z "$VCO" ]
then
    echo "Unable to determine VCO" >&2
    exit 1
fi

# Determine the project name.
DOT_GIT=`find $SRC -type d -name .git -print | head -1`
if [ -z "$DOT_GIT" ]
then
    echo "Not in a git project" >&2
    exit 1
fi
if [ -z "$PROJECT_NAME" ]
then
    pushd $DOT_GIT > /dev/null
    PROJECT_NAME=`git remote get-url --all origin 2>/dev/null | sed -e 's?.*/\([^/]*\)$?\1?' | cut -d. -f1`
    popd > /dev/null
fi
if [ -z "$PROJECT_NAME" ]
then
    PROJECT_NAME=`grep "url[ 	]*=[ 	]*" $DOT_GIT/config | head -1 | sed -e 's?^.*/\([^/]*\)?\1? ; s?\.git$??'`
fi
if [ -z "$PROJECT_NAME" ]
then
    echo "Unable to determine project name" >&2
    exit 1
fi
echo "Using project name $PROJECT_NAME"

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

# Update the version numbers in the glue files.
for SRC_VERSION in `find $SRC/* -type f -name 'version' -print | egrep -v "exports/mgc_home|ao./${PROJECT_NAME}_"`
do
    sed -i -e "s/\(#define [ ]*RLS_VER \"v\)[0-9][0-9]*\.[0-9][0-9]*\(_.*\)/\1${MAJOR_VERSION}.${MINOR_VERSION}\2/" $SRC_VERSION
done

if [ "$DST" = "$SRC" ]
then
    COMMAND=ensure_link
    PRESENT_PARTICIPLE="Linking"
    DST_SPECIFIC=$DST

    # Remove any extant symbolic links, except under boilermake.
    find $SRC -type d -name boilermake -prune -o -type l -exec rm -f {} \;
else
    COMMAND=cp
    PRESENT_PARTICIPLE="Copying"
    DST_SPECIFIC=$DST/$PROJECT_NAME/${MAJOR_VERSION}.${MINOR_VERSION}.${PATCH_VERSION}/$CONFIGURATION

    # Ensure that the destination specific directory exists.
    if [ ! -d $DST_SPECIFIC ]
    then
        echo "Creating $DST_SPECIFIC"
        mkdir -p $DST_SPECIFIC
    else
        echo "Using $DST_SPECIFIC"
    fi

    # Remove any extant symbolic links under the project directory.
    find $DST/$PROJECT_NAME/* -prune -type l -exec rm -fv {} \;
fi

# Determine the destination directories.
if [ $TYPE = "det" ]
then
    INCLUDE_DIR=$DST_SPECIFIC/mgc_home/shared/pkgs/${PROJECT_NAME}_inhouse.$VCO/include
    LIB_DIR=$DST_SPECIFIC/mgc_home/pkgs/${PROJECT_NAME}.$VCO/lib
    BIN_DIR=$DST_SPECIFIC/mgc_home/pkgs/${PROJECT_NAME}.$VCO/bin
    INHOUSE_BIN_DIR=$DST_SPECIFIC/mgc_home/shared/pkgs/${PROJECT_NAME}_inhouse.$VCO/bin
    CONFIG_DIR=$DST_SPECIFIC/mgc_home/pkgs/${PROJECT_NAME}.$VCO/config
    SRC_DIR=$DST_SPECIFIC/mgc_home/shared/pkgs/${PROJECT_NAME}_inhouse.$VCO/src
    DOC_DIR=$DST_SPECIFIC/mgc_home/shared/pkgs/${PROJECT_NAME}_inhouse.$VCO
else
    INCLUDE_DIR=$DST_SPECIFIC/include
    LIB_DIR=$DST_SPECIFIC/lib
    BIN_DIR=$DST_SPECIFIC/bin
    INHOUSE_BIN_DIR=$DST_SPECIFIC/bin
    CONFIG_DIR=$DST_SPECIFIC/config
    SRC_DIR=$DST_SPECIFIC/source
    DOC_DIR=$DST_SPECIFIC
fi

# Ensure the destination directories exist.
ensure_directory $INCLUDE_DIR
ensure_directory $LIB_DIR
ensure_directory $BIN_DIR
ensure_directory $INHOUSE_BIN_DIR
ensure_directory $CONFIG_DIR
if [ 0 -ne $SOURCE ]
then
    ensure_directory $SRC_DIR
fi
if [ "$DST" != "$SRC" ]
then
    ensure_directory $DOC_DIR
fi

# Export header files.
echo "$PRESENT_PARTICIPLE header files..."
for SRC_HEADER in `find $SRC/* -type f \( -name '*.h' -o -name '*.i' \) -print | egrep -v "exports/mgc_home|ao./${PROJECT_NAME}_"`
do
    if grep -E '\\ingroup[     ]+public_api' $SRC_HEADER >/dev/null 2>&1
    then
        if [ ! -d `dirname $SRC_HEADER`/.git ]
        then
            SUB=`dirname $SRC_HEADER`
            SUB=`basename $SUB`
            if [ ! -d $INCLUDE_DIR/$PROJECT_NAME/$SUB ]
            then
                mkdir -p $INCLUDE_DIR/$PROJECT_NAME/$SUB
            fi

            DST_HEADER=$INCLUDE_DIR/$PROJECT_NAME/$SUB/`basename $SRC_HEADER`
        else
            if [ ! -d $INCLUDE_DIR/$PROJECT_NAME ]
            then
                mkdir -p $INCLUDE_DIR/$PROJECT_NAME
            fi

            DST_HEADER=$INCLUDE_DIR/$PROJECT_NAME/`basename $SRC_HEADER`
        fi
        if [ -f $DST_HEADER ]
        then
            rm -f $DST_HEADER >/dev/null 2>&1
        fi

        $COMMAND $SRC_HEADER $DST_HEADER
        chmod 664 $DST_HEADER
    fi
done

# Export source files.
if [ 0 -ne $SOURCE ]
then
    echo "$PRESENT_PARTICIPLE source files..."
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
                    if [ ! -d $SRC_DIR/$PROJECT_NAME/$SUB ]
                    then
                        mkdir -p $SRC_DIR/$PROJECT_NAME/$SUB
                    fi

                    DST_SOURCE=$SRC_DIR/$PROJECT_NAME/$SUB/`basename $SRC_SOURCE`
                else
                    if [ ! -d $SRC_DIR/$PROJECT_NAME ]
                    then
                        mkdir -p $SRC_DIR/$PROJECT_NAME
                    fi

                    DST_SOURCE=$SRC_DIR/$PROJECT_NAME/`basename $SRC_SOURCE`
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

# Export library files.
echo "$PRESENT_PARTICIPLE library files..."
for SRC_LIBRARY in `find $SRC/* -type f -name '*.so' -print | egrep -v "exports/mgc_home|ao./${PROJECT_NAME}_"`
do
    if [ -s $SRC_LIBRARY ]
    then
        DST_LIBRARY=$LIB_DIR/`basename $SRC_LIBRARY`
        $COMMAND $SRC_LIBRARY $DST_LIBRARY
        chmod 664 $DST_LIBRARY
    fi
done

# Export info files.
echo "$PRESENT_PARTICIPLE info files..."
for SRC_INFO in `find $SRC/* -type f -name '*_info' -print | egrep -v "exports/mgc_home|ao./${PROJECT_NAME}_"`
do
    if [ -s $SRC_INFO ]
    then
        DST_INFO=$LIB_DIR/`basename $SRC_INFO`
        $COMMAND $SRC_INFO $DST_INFO
        chmod 664 $DST_INFO
    fi
done

# Export executable files.
echo "$PRESENT_PARTICIPLE executable files..."
for SRC_EXECUTABLE in `find $SRC/* -type f -name '*.exe' -print | egrep -v "exports/mgc_home|ao./${PROJECT_NAME}_"`
do
    if [ -s $SRC_EXECUTABLE ]
    then
        if echo $SRC_EXECUTABLE | grep -E '(_ut|_smoke)\.exe' >/dev/null 2>&1
        then
            DST_EXECUTABLE=$INHOUSE_BIN_DIR/`basename $SRC_EXECUTABLE`
        else
            DST_EXECUTABLE=$BIN_DIR/`basename $SRC_EXECUTABLE`
        fi
        $COMMAND $SRC_EXECUTABLE $DST_EXECUTABLE
        chmod 775 $DST_EXECUTABLE
    fi
done

# Export script files.
echo "$PRESENT_PARTICIPLE script files..."
for SRC_SCRIPT in `find $SRC/* -type f -name '*.sh' -print | egrep -v "exports/mgc_home|ao./${PROJECT_NAME}_"`
do
    if grep -E '\\ingroup[     ]+public_api' $SRC_SCRIPT >/dev/null 2>&1
    then
        if echo $SRC_SCRIPT | grep -E '(_ut|_smoke)\.sh' >/dev/null 2>&1
        then
            DST_SCRIPT=$INHOUSE_BIN_DIR/`basename $SRC_SCRIPT`
        else
            DST_SCRIPT=$BIN_DIR/`basename $SRC_SCRIPT`
        fi
        $COMMAND $SRC_SCRIPT $DST_SCRIPT
        chmod 775 $DST_SCRIPT
    fi
done

# Export configuration files.
echo "$PRESENT_PARTICIPLE configuration files..."
for SRC_CONFIGURATION in `find $SRC/* -type f -name '*.profile' -print | egrep -v "exports/mgc_home|ao./${PROJECT_NAME}_"`
do
    if grep -E '\\ingroup[     ]+public_api' $SRC_CONFIGURATION >/dev/null 2>&1
    then
        DST_CONFIGURATION=$CONFIG_DIR/`basename $SRC_CONFIGURATION`
        $COMMAND $SRC_CONFIGURATION $DST_CONFIGURATION
        chmod 664 $DST_CONFIGURATION
    fi
done

# Export documentation.
if [ "$DST" != "$SRC" ]
then
    echo "$PRESENT_PARTICIPLE documentation..."
    for README in `find $SRC/* -prune -type f -regex '^.*/[A-Z][A-Z0-9_]*' -print`
    do
        cp $README $DOC_DIR
    done
    rsync -rLptgo --exclude='*.pages' --chmod=a+r,ug+w --delete-delay $SRC/doc $DOC_DIR
fi

# Update the symbolic links.
if [ "$DST" != "$SRC" ]
then
    echo "Updating symbolic links..."
    cd $DST/$PROJECT_NAME

    PATTERN="[0-9]*"
    LINK_MAJOR=`find * -prune -type d -name "$PATTERN" -print | cut -d. -f1 | sort -u -n | tail -1`

    PATTERN="$LINK_MAJOR.[0-9]*"
    LINK_MINOR=`find * -prune -type d -name "$PATTERN" -print | cut -d. -f2 | sort -u -n | tail -1`

    PATTERN="$LINK_MAJOR.$LINK_MINOR.[0-9]*"
    LINK_PATCH=`find * -prune -type d -name "$PATTERN" -print | cut -d. -f3 | sort -u -n | tail -1`

    if [ -d ${LINK_MAJOR}.${LINK_MINOR}.${LINK_PATCH} ]
    then
        ln -s ${LINK_MAJOR}.${LINK_MINOR}.${LINK_PATCH} latest
    fi
fi

echo "Done."
