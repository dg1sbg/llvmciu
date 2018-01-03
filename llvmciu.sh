#!/bin/bash
# set -x

# =============================================================================
#  LLVM CLONE AND INSTALL UTILITY (LLVMCIU)
# =============================================================================
#  A MEMBER OF THE   G O E N N I N G E R   B & T  -  T O O L B O X
#
# Type:         shell script
#
# Purpose:      Clone and install LLVM, CLANG, LLD, COMPILER-RT,
#               OPENMP, LIBCXX, LIBXXABI, CLANG EXTRA TOOLS
#
# Arguments:    -n | --non-interactive -> Execute in batch mode
#               -c | --cleanup -> do cleanup on error
#               -s | --src-cleaning -> do rm -rf on source directories
#               -f | --force-cleanup -> do cleaning and cleanup
#    	        -b | --build -> execute Build step
#	        -i | --install -> execute Install step
#
#               Execution is also controlled by environment variables
#
# Author:       Frank Goenninger, Goenninger B&T UG, Germany
#
# Plattforms:   Bash on Mac OS X and Linux
#
# ----------------------------------------------------------------------------
# Modification History:
#
# 2017-12-28      Frank Goenninger   created.
#
# =============================================================================

# -----------------------------------------------------------------------------
#  C O N F I G    S E C T I O N
# -----------------------------------------------------------------------------

LLVM_CIU_DEBUG=${LLVM_CIU_DEBUG:-0}
LLVM_CIU_INTERACTIVE_MODE=${LLVM_CIU_INTERACTIVE_MODE:-1}

LLVM_CIU_ROOT=${LLVM_CIU_ROOT:-"/opt/langtools/llvm"}
LLVM_CIU_INSTROOT=${LLVM_CIU_INSTROOT:-"$LLVM_CIU_ROOT"}

LLVM_CIU_SRCROOT=${LLVM_CIU_SRCROOT:-"$LLVM_CIU_ROOT/src"}

LLVM_CIU_LLVM_SRCDIR=${LLVM_CIU_LLVM_SRCDIR:-"$LLVM_CIU_SRCROOT/llvm"}
LLVM_CIU_LLVM_TOOLSDIR=${LLVM_CIU_LLVM_TOOLSDIR:-"$LLVM_CIU_SRCROOT/llvm/tools"}
LLVM_CIU_LLVM_PROJECTSDIR=${LLVM_CIU_LLVM_PROJECTSDIR:-"$LLVM_CIU_SRCROOT/llvm/projects"}
LLVM_CIU_CLANG_TOOLSDIR=${LLVM_CIU_CLANG_TOOLSDIR:-"$LLVM_CIU_SRCROOT/llvm/tools/clang/tools"}
LLVM_CIU_BUILDDIR=${LLVM_CIU_BUILDDIR:-"$LLVM_CIU_SRCROOT/llvm/build"}

LLVM_CIU_LLVM_GIT_URL="https://git.llvm.org/git/llvm.git/"
LLVM_CIU_LLVM_DIR="$LLVM_CIU_LLVM_SRCDIR"

LLVM_CIU_CLANG_GIT_URL="https://git.llvm.org/git/clang.git/"
LLVM_CIU_CLANG_DIR="$LLVM_CIU_LLVM_TOOLSDIR/clang"

LLVM_CIU_LLD_GIT_URL="https://git.llvm.org/git/lld.git/"
LLVM_CIU_LLD_DIR="$LLVM_CIU_LLVM_TOOLSDIR/lld"

LLVM_CIU_COMPILERRT_GIT_URL="https://git.llvm.org/git/compiler-rt.git/"
LLVM_CIU_COMPILERRT_DIR="$LLVM_CIU_LLVM_PROJECTSDIR/compiler-rt"

LLVM_CIU_OPENMP_GIT_URL="https://git.llvm.org/git/openmp.git/"
LLVM_CIU_OPENMP_DIR="$LLVM_CIU_LLVM_PROJECTSDIR/openmp"

LLVM_CIU_LIBCXX_GIT_URL="https://git.llvm.org/git/libcxx.git/"
LLVM_CIU_LIBCXX_DIR="$LLVM_CIU_LLVM_PROJECTSDIR/libcxx"

LLVM_CIU_LIBCXXABI_GIT_URL="https://git.llvm.org/git/libcxxabi.git/"
LLVM_CIU_LIBCXXABI_DIR="$LLVM_CIU_LLVM_PROJECTSDIR/libcxxabi"

LLVM_CIU_CLANGTOOLSEXTRA_GIT_URL="https://git.llvm.org/git/clang-tools-extra.git/ extra"
LLVM_CIU_CLANGTOOLSEXTRA_DIR="$LLVM_CIU_CLANG_TOOLSDIR/extra"


LLVM_CIU_CLONE_LLVM_SWITCH=${LLVM_CIU_CLONE_LLVM_SWITCH:-1}
LLVM_CIU_CLONE_CLANG_SWITCH=${LLVM_CIU_CLONE_CLANG_SWITCH:-1}
LLVM_CIU_CLONE_LLD_SWITCH=${LLVM_CIU_CLONE_LLD_SWITCH:-1}
LLVM_CIU_CLONE_COMPILERRT_SWITCH=${LLVM_CIU_CLONE_COMPILERRT_SWITCH:-1}
LLVM_CIU_CLONE_OPENMP_SWITCH=${LLVM_CIU_CLONE_OPENMP_SWITCH:-1}
LLVM_CIU_CLONE_LIBCXX_SWITCH=${LLVM_CIU_CLONE_LIBCXX_SWITCH:-1}
LLVM_CIU_CLONE_LIBCXXABI_SWITCH=${LLVM_CIU_CLONE_LIBCXXABI_SWITCH:-1}
LLVM_CIU_CLONE_CLANGTOOLSEXTRA_SWITCH=${LLVM_CIU_CLONE_CLANGTOOLSEXTRA_SWITCH:-1}

LLVM_CIU_BUILD_IT_SWITCH=${LLVM_CIU_BUILD_IT_SWITCH:-0}
LLVM_CIU_INSTALL_IT_SWITCH=${LLVM_CIU_INSTALL_IT_SWITCH:-0}
LLVM_CIU_DO_CLEANUP_SWITCH=0
LLVM_CIU_DO_SRC_CLEANING_SWITCH=0

CMAKE_BUILD_TYPE_VALUE=${CMAKE_BUILD_TYPE_VALUE:-"Release"}
CMAKE_INSTALL_PREFIX_VALUE=${CMAKE_INSTALL_PREFIX_VALUE:-$LLVM_CIU_INSTROOT}
BUILD_SHARED_LIBS_VALUE=${BUILD_SHARED_LIBS_VALUE:-"OFF"}
LLVM_BUILD_LLVM_DYLIB_VALUE=${LLVM_BUILD_LLVM_DYLIB_VALUE:-"false"}
LLVM_BUILD_LLVM_ENABLE_RTTI_VALUE=${LLVM_BUILD_LLVM_ENABLE_RTTI_VALUE:-"ON"}
LLVM_ENABLE_ASSERTIONS_VALUE=${LLVM_ENABLE_ASSERTIONS_VALUE:-"OFF"}

PJOBS=${PJOBS:-"4"}

CMAKE_OPTS_1="-DCMAKE_BUILD_TYPE:STRING=$CMAKE_BUILD_TYPE_VALUE"
CMAKE_OPTS_2="-DCMAKE_INSTALL_PREFIX:STRING=$CMAKE_INSTALL_PREFIX_VALUE"
CMAKE_OPTS_3="-DLLVM_BUILD_LLVM_DYLIB:BOOL=$LLVM_BUILD_LLVM_DYLIB_VALUE"
CMAKE_OPTS_4="-DLLVM_PARALLEL_COMPILE_JOBS:STRING=$PJOBS"
CMAKE_OPTS_5="-DLLVM_PARALLEL_LINK_JOBS:STRING=$PJOBS"
CMAKE_OPTS_6="-DLLVM_ENABLE_CXX17:BOOL=true"
CMAKE_OPTS_7="-DLLVM_ENABLE_EH:BOOL=ON"
CMAKE_OPTS_8="-DLLVM_ENABLE_RTTI:BOOL=ON"
CMAKE_OPTS_9="-DLLVM_ENABLE_ASSERTIONS:BOOL=OFF"

CMAKE_OPTS=${CMAKE_OPTS:-"$CMAKE_OPTS_1 $CMAKE_OPTS_2 $CMAKE_OPTS_3 $CMAKE_OPTS_4 $CMAKE_OPTS_5 $CMAKE_OPTS_6 $CMAKE_OPTS_7 $CMAKE_OPTS_8 $CMAKE_OPTS_9"}

CCMAKE_OPTS="-Wno-dev $CMAKE_OPTS"

# ***************************************************
# *** YOU SHOULD NOT HAVE TO EDIT BELOW THIS LONE ***
# ***************************************************

# -----------------------------------------------------------------------------
#  P L A T F O R M    S P E C I F I C    C O N F I G    S E C T I O N
# -----------------------------------------------------------------------------

MKDIR="mkdir -p"
PWD="pwd"
CD="cd"
GIT_CLONE="git clone"
GIT_PULL="git pull"
RMRF="rm -rf"
NINJA="ninja"
CCMAKE="ccmake -G Ninja"
CMAKE="cmake -G Ninja"

MYSELF=`basename $0`
CURRPWD=`$PWD`

RED_COLOR=`tput setaf 1`
ORANGE_COLOR=`tput setaf 166`
GREEN_COLOR=`tput setaf 2`
BLUE_COLOR=`tput setaf 18`
WHITEB_COLOR=`tput setab 255`
RESET_COLOR=`tput sgr0`

GLOBAL_RC=0
ACTUALLY_DO_CLEANUP=0

# -----------------------------------------------------------------------------
#  I M P L E M E N T A T I O N    S E C T I O N
# -----------------------------------------------------------------------------

## FUNCTIONS ##

INTERACTIVE_MODE_P()
{
    if [ $LLVM_CIU_INTERACTIVE_MODE -ne 0 ]
    then
	return 1
    else
	return 0
    fi
}

MSG()
{
    if [ INTERACTIVE_MODE_P ]
    then
	echo $1
    fi
}

ERRMSG()
{
    if [ INTERACTIVE_MODE_P ]
    then
	echo "${RED_COLOR}$1${RESET_COLOR}"
    fi
}

WARNMSG()
{
    if [ INTERACTIVE_MODE_P ]
    then
	echo "${ORANGE_COLOR}$1${RESET_COLOR}"
    fi
}

CLEANUP()
{
    if [ $ACTUALLY_DO_CLEANUP -ne 0 ]
    then
	MSG "Cleaning up ..."
	$CD $LLVM_CIU_SRCROOT
	RC=$?

	if [ $LLVM_CIU_DEBUG -ne 0 ]
	then
	    ERRMSG "*** NOT CLEANING UP - DEBUG enabled !"
	    return 0
	fi

	if [ $RC -eq 0 ]
	then
	    if [ $LLVM_CIU_DO_CLEANUP_SWITCH -ne 0 ]
	    then
		$RMRF $LLVM_CIU_LLVM_SRCDIR 2>/dev/null
		$RMRF $LLVM_CIU_LLVM_TOOLSDIR 2>/dev/null
		$RMRF $LLVM_CIU_LLVM_PROJECTSDIR 2>/dev/null
		$RMRF $LLVM_CIU_CLANG_TOOLSDIR 2>/dev/null
	    else
		WARNMSG "*** NOT CLEANING UP SOURCE DIRECTORIES."
	    fi
	    $RMRF $LLVM_CIU_BUILDDIR 2>/dev/null
	fi

	MSG "Exiting now."
    else
	WARNMSG "*** NOT CLEANING UP SOURCE DIRECTORIES - INTERRUPTED BEFORE ACTION."
    fi
}

CLEANUP_AND_EXIT()
{
    CLEANUP
    exit $GLOBAL_RC
}

CHECKRC()
{
    if [ $1 -ne 0 ]
    then
	GLOBAL_RC=$1
	ERRMSG "$MYSELF *** ERROR: $2."
    fi
}

CHECKRC_EXIT()
{
    CHECKRC $1 "$2"
    if [ $1 -ne 0 ]
    then
	ERRMSG "$MYSELF - ABORTING !"
	CLEANUP
	exit $RC
    fi
}

WAIT_FOR_RETURN()
{
    echo "PRESS [${BLUE_COLOR}${WHITEB_COLOR}RETURN${RESET_COLOR}] TO CONTINUE OR CTRL-C TO ABORT ..."
    read
}


TITLE ()
{
    if [ INTERACTIVE_MODE_P ]
    then
	clear
	echo "${BLUE_COLOR}=============================================================================="
	echo " $MYSELF - LLVM and CLANG Clone and Install Utility"
	echo "==============================================================================${RESET_COLOR}"
	echo
    fi
}

BUILD_TOOLS_CHECK()
{
    WTF=`type ninja` 2>&1 >/dev/null
    CHECKRC_EXIT $? "$MYSELF requires NINJA build tool - not found !"

    WTF=`type cmake` 2>&1 >/dev/null
    CHECKRC_EXIT $? "$MYSELF requires CMAKE - not found !"
}

TRAP_HANDLER()
{
    TITLE
    SIGNAL=$1
    FN=$2
    ERRMSG "TRAP_HANDLER: Received signal $SIGNAL ..."
    ${FN}
}

HANDLE_OPTIONS()
{
    POSITIONAL=()

    while [[ $# -gt 0 ]]
    do
	key="$1"

	case $key in
	    -n|--non-interactive)
		LLVM_CIU_INTERACTIVE_MODE=0
		shift # past argument
		;;
	    -c|--cleanup)
		LLVM_CIU_DO_CLEANUP_SWITCH=1
		shift # past argument
		;;
	    -s|--src-cleaning)
		LLVM_CIU_DO_SRC_CLEANING_SWITCH=1
		shift # past argument
		;;
	    -f|--force-cleanup)
		LLVM_CIU_DO_SRC_CLEANING_SWITCH=1
		LLVM_CIU_DO_CLEANUP_SWITCH=1
		shift # past argument
		;;
	    -b|--build)
		LLVM_CIU_BUILD_IT_SWITCH=1
		shift # past argument
		;;
	    -i|--install)
		LLVM_CIU_INSTALL_IT_SWITCH=1
		shift # past argument
		;;
	    *)    # unknown option
		POSITIONAL+=("$1") # save it in an array for later
		shift # past argument
		;;
	esac
    done
    set -- "${POSITIONAL[@]}" # restore positional parameters
}

CLONE_OR_PULL()
{
    DESIGNATOR=$1
    CLONING_REQUIRED=$2
    CLONE_SWITCH=$3
    CLONE_SRCDIR=$4
    PULL_SRCDIR=$5
    GIT_URL=$6

    # CHECK PARAMS

    if [ "$DESIGNATOR" = "" ]
    then
	CHECKRC_EXIT 1 "Function CLONE_OR_PULL: Param DESIGNTOR invalid!"
    fi
    if [ "$CLONE_SRCDIR" = "" ]
    then
	CHECKRC_EXIT 1 "Function CLONE_OR_PULL: $DESIGNATOR: Param CLONE_SRCDIR invalid!"
    fi
    if [ "$PULL_SRCDIR" = "" ]
    then
	CHECKRC_EXIT 1 "Function CLONE_OR_PULL: $DESIGNATOR: Param PULL_SRCDIR invalid!"
    fi
    if [ "$GIT_URL" = "" ]
    then
	CHECKRC_EXIT 1 "Function CLONE_OR_PULL: $DESIGNATOR: Param GIT_URL invalid!"
    fi

    # DO IT

    if [ $CLONING_REQUIRED -ne 0 ]
    then

	if [ $CLONE_SWITCH -ne 0 ]
	then
	    TITLE
	    MSG " ... Cloning §DESIGNATOR ... (This may take some time - please wait)"
	    MSG

	    $CD $CLONE_SRCDIR 2>/dev/null
	    CHECKRC_EXIT $? "Directory $CLONE_SRCDIR not accessible !"

	    $GIT_CLONE $GIT_URL
	    CHECKRC_EXIT $? "Failed to clone $DESIGNATOR from $GIT_URL !"
	fi

    else

	if [ $CLONE_SWITCH -ne 0 ]
	then
	    TITLE
	    MSG " ... Pulling $DESIGNATOR ... (This may take some time - please wait)"
	    MSG

	    $CD $PULL_SRCDIR 2>/dev/null
	    CHECKRC_EXIT $? "Directory $PULL_SRCDIR not accessible !"

	    $GIT_PULL
	    CHECKRC_EXIT $? "Failed to git pull in $PULL_SRCDIR !"
	fi

    fi

    sleep 2
}


## MAIN ##

trap "TRAP_HANDLER 2 CLEANUP_AND_EXIT"   2
trap "TRAP_HANDLER 3 CLEANUP_AND_EXIT"   3
trap "TRAP_HANDLER 4 CLEANUP_AND_EXIT"   4
trap "TRAP_HANDLER 5 CLEANUP_AND_EXIT"   5
trap "TRAP_HANDLER 6 CLEANUP_AND_EXIT"   6
trap "TRAP_HANDLER 7 CLEANUP_AND_EXIT"   7
trap "TRAP_HANDLER 8 CLEANUP_AND_EXIT"   8

trap "TRAP_HANDLER 10 CLEANUP_AND_EXIT"  10
trap "TRAP_HANDLER 11 CLEANUP_AND_EXIT"  11
trap "TRAP_HANDLER 12 CLEANUP_AND_EXIT"  12
trap "TRAP_HANDLER 13 CLEANUP_AND_EXIT"  13
trap "TRAP_HANDLER 14 CLEANUP_AND_EXIT"  14
trap "TRAP_HANDLER 15 CLEANUP_AND_EXIT"  15

TITLE
HANDLE_OPTIONS $*

BUILD_TOOLS_CHECK

if [ $LLVM_CIU_DEBUG -ne 0 ]
then
    LLVM_CIU_DO_SRC_CLEANING_SWITCH=0
    LLVM_CIU_DO_CLEANUP_SWITCH=0
fi

if [ INTERACTIVE_MODE_P ]
then
    TITLE
    echo "Mode Information:"
    echo
    echo "Interactive Mode: $LLVM_CIU_INTERACTIVE_MODE"
    echo "Debug: $LLVM_CIU_DEBUG"
    echo
    echo "Execute Build Step: $LLVM_CIU_BUILD_IT_SWITCH"
    echo "Execute Install Step: $LLVM_CIU_INSTALL_IT_SWITCH"
    echo
    echo "Do Source Cleaning on Error: $LLVM_CIU_DO_SRC_CLEANING_SWITCH"
    echo "Do Cleanup on Error: $LLVM_CIU_DO_CLEANUP_SWITCH"
    echo
    WAIT_FOR_RETURN
    TITLE
    echo "Configuration (1/2): Paths and Module Selection"
    echo
    echo "LLVM_CIU_SRCROOT ........ = $LLVM_CIU_SRCROOT"
    echo "LLVM_CIU_INSTROOT ....... = $LLVM_CIU_INSTROOT"
    echo "LLVM_CIU_LLVM_SRCDIR .... = $LLVM_CIU_LLVM_SRCDIR"
    echo "LLVM_CIU_LLVM_TOOLSDIR .. = $LLVM_CIU_LLVM_TOOLSDIR"
    echo "LLVM_CIU_LLVM_PROJECTSDIR = $LLVM_CIU_LLVM_PROJECTSDIR"
    echo "LLVM_CIU_CLANG_TOOLSDIR . = $LLVM_CIU_CLANG_TOOLSDIR"
    echo "LLVM_CIU_BUILDDIR ....... = $LLVM_CIU_BUILDDIR"
    echo "LLVM_CIU_CLONE_LLVM_SWITCH .......... = $LLVM_CIU_CLONE_LLVM_SWITCH"
    echo "LLVM_CIU_CLONE_CLANG_SWITCH ......... = $LLVM_CIU_CLONE_CLANG_SWITCH"
    echo "LLVM_CIU_CLONE_LLD_SWITCH ........... = $LLVM_CIU_CLONE_LLD_SWITCH"
    echo "LLVM_CIU_CLONE_COMPILERRT_SWITCH .... = $LLVM_CIU_CLONE_COMPILERRT_SWITCH"
    echo "LLVM_CIU_CLONE_OPENMP_SWITCH ........ = $LLVM_CIU_CLONE_OPENMP_SWITCH"
    echo "LLVM_CIU_CLONE_LIBCXX_SWITCH ........ = $LLVM_CIU_CLONE_LIBCXX_SWITCH"
    echo "LLVM_CIU_CLONE_LIBCXXABI_SWITCH ..... = $LLVM_CIU_CLONE_LIBCXXABI_SWITCH"
    echo "LLVM_CIU_CLONE_CLANGTOOLSEXTRA_SWITCH = $LLVM_CIU_CLONE_CLANGTOOLSEXTRA_SWITCH"
    echo
    WAIT_FOR_RETURN
    TITLE
    echo "Configuration (2/2): CMAKE Options and Env Vars for Build & Install"
    echo
    echo "CMAKE_OPTS  = "
    echo $CMAKE_OPTS
    echo
    echo "CCMAKE_OPTS  = "
    echo $CCMAKE_OPTS
    echo
    WAIT_FOR_RETURN
fi

# Clone LLVM

LLVM_CIU_CLONING_REQUIRED=0
LLVM_CIU_SRC_CLEANING_REQUIRED=0

if [ ! -d $LLVM_CIU_SRCROOT ]
then
    $MKDIR $LLVM_CIU_SRCROOT 2>/dev/null
    CHECKRC_EXIT $? "Could not create directory $LLVM_CIU_SRCROOT"
    LLVM_CIU_CLONING_REQUIRED=1
    LLVM_CIU_SRC_CLEANING_REQUIRED=0
else
    $CD $LLVM_CIU_SRCROOT 2>/dev/null
    CHECKRC_EXIT $? "Directory $LLVM_CIU_SRCROOT not accessible !"

    if [ ! $LLVM_CIU_DO_SRC_CLEANING ]
    then
	if [  `\ls $LLVM_CIU_SRCROOT | wc -l` -eq  0 ]
	then
	    LLVM_CIU_CLONING_REQUIRED=1
	fi
    else
	LLVM_CIU_CLONING_REQUIRED=1
	LLVM_CIU_SRC_CLEANING_REQUIRED=1
    fi
fi

# if [ INTERACTIVE_MODE_P ]
# then
#     if [ $LLVM_CIU_SRC_CLEANING_REQUIRED -ne 0 ]
#     then
# 	MSG "*** Proceeding with SRC CLEANING."
#     fi
#     if [ $LLVM_CIU_CLONING_REQUIRED -ne 0 ]
#     then
# 	MSG "*** Proceeding with CLONING."
#     else
# 	MSG "*** Proceeding with PULLING."
#     fi

#     sleep 3
# fi

# Check if clone directory is empty

if [ -d $LLVM_CIU_SRCROOT ]
then
    $CD $LLVM_CIU_SRCROOT
    CHECKRC_EXIT $? "Directory $LLVM_CIU_SRCROOT exists but is not accessible ...- Please either delete this directory or make it accessable."

    if [ `\ls . | wcl -l` -gt 0 ]
    then
	if [ $LLVM_CIU_DO_CLEANUP_SWITCH ]
	then
	    if [ INTERACTIVE_MODE_P ]
	    then
		MSG "About to delete contents of directory `pwd` !"
		MSG
		WAIT_FOR_RETURN
	    fi
	    $RMRF \*
	fi
    fi
fi

ACTUALLY_DO_CLEANUP=1

###

# $1 = Designator / Name of Component
# $2 = General Clone Switch
# $3 = Specific Clone Switch
# $4 = Source Dir for Cloning
# $5 = Source Dir for Pulling
# $6 = GIT URL for Component

# Clone or Pull LLVM

CLONE_OR_PULL "LLVM" $LLVM_CIU_CLONING_REQUIRED $LLVM_CIU_CLONE_LLVM_SWITCH "$LLVM_CIU_SRCROOT" "$LLVM_CIU_LLVM_DIR" "$LLVM_CIU_LLVM_GIT_URL"

# Clone CLANG

CLONE_OR_PULL "CLANG" $LLVM_CIU_CLONING_REQUIRED $LLVM_CIU_CLONE_CLANG_SWITCH "$LLVM_CIU_LLVM_TOOLSDIR" "$LLVM_CIU_CLANG_DIR" "$LLVM_CIU_CLANG_GIT_URL"

# Clone LLD

CLONE_OR_PULL "LLD" $LLVM_CIU_CLONING_REQUIRED $LLVM_CIU_CLONE_LLD_SWITCH "$LLVM_CIU_LLVM_TOOLSDIR" "$LLVM_CIU_LLD_DIR" "$LLVM_CIU_LLD_GIT_URL"

# Clone COMPILER-RT

CLONE_OR_PULL "COMPILER-RT" $LLVM_CIU_CLONING_REQUIRED $LLVM_CIU_CLONE_COMPILERRT_SWITCH "$LLVM_CIU_LLVM_PROJECTSDIR" "$LLVM_CIU_COMPILERRT_DIR" "$LLVM_CIU_COMPILERRT_GIT_URL"

# Clone OPENMP

CLONE_OR_PULL "OpenMP" $LLVM_CIU_CLONING_REQUIRED $LLVM_CIU_CLONE_OPENMP_SWITCH "$LLVM_CIU_LLVM_PROJECTSDIR" "$LLVM_CIU_OPENMP_DIR" "$LLVM_CIU_OPENMP_GIT_URL"

# Clone LIBCXX

CLONE_OR_PULL "LIBCXX" $LLVM_CIU_CLONING_REQUIRED $LLVM_CIU_CLONE_LIBCXX_SWITCH "$LLVM_CIU_LLVM_PROJECTSDIR" "$LLVM_CIU_LIBCXX_DIR" "$LLVM_CIU_LIBCXX_GIT_URL"

# Clone LIBCXXABI

CLONE_OR_PULL "LIBCXXABI" $LLVM_CIU_CLONING_REQUIRED $LLVM_CIU_CLONE_LIBCXXABI_SWITCH "$LLVM_CIU_LLVM_PROJECTSDIR" "$LLVM_CIU_LIBCXXABI_DIR"  "$LLVM_CIU_LIBCXXABI_GIT_URL"

# Clone CLANG EXTRA TOOLS

CLONE_OR_PULL "CLANG-TOOLS-EXTRA" $LLVM_CIU_CLONING_REQUIRED $LLVM_CIU_CLONE_CLANGTOOLSEXTRA_SWITCH "$LLVM_CIU_CLANG_TOOLSDIR" "$LLVM_CIU_CLANGTOOLSEXTRA_DIR"  "$LLVM_CIU_CLANGTOOLSEXTRA_GIT_URL"

# Build stuff

if [ $LLVM_CIU_BUILD_IT_SWITCH -ne 0 ]
then
    TITLE

    MSG " ... Building ... (This may take some time - please wait)"
    MSG
    MSG " Build Directory: $LLVM_CIU_BUILDDIR"
    MSG
	  sleep 2

    if [ ! -d $LLVM_CIU_BUILDDIR ]
    then
	$MKDIR $LLVM_CIU_BUILDDIR 2>/dev/null
	CHECKRC_EXIT $? "Could not create directory $LLVM_CIU_BUILDDIR !"
    fi

    $CD $LLVM_CIU_BUILDDIR 2>/dev/null
    CHECKRC_EXIT $? "Could not change directory to $LLVM_CIU_BUILDDIR !"
    $RMRF \* 2>/dev/null
    sleep 2

    NR_ENTRIES=`\ls | wc -l`
    if [ $NR_ENTRIES -gt 0 ]
    then
        CHECKRC_EXIT 1 "Could not delete contents of build directory $LLVM_CIU_BUILDDIR"
    fi

    if [ INTERACTIVE_MODE_P ]
    then
	$CCMAKE $CCMAKE_OPTS $LLVM_CIU_LLVM_SRCDIR
	CHECKRC_EXIT $? "Could not complete ccmake successfully - RC = $RC !"
    else
	$CMAKE $CMAKE_OPTS
	CHECKRC_EXIT $? "Could not complete cmake successfully - RC = $RC !"    fi
    fi
    $NINJA 2>/dev/null
    RC=$?
    CHECKRC_EXIT $RC "Could not build - RC = $RC !"
    MSG " ... Finished building."
    MSG
    sleep 2
fi

if [ $LLVM_CIU_INSTALL_IT_SWITCH -ne 0 ]
then
    TITLE

    MSG " ... Installing ... (This may take some time - please wait)"
    MSG
    MSG
    MSG " Install Directory: $LLVM_CIU_INSTDIR"
    MSG
    if [ ! -d $LLVM_CIU_INSTDIR ]
    then
	$MKDIR $LLVM_CIU_INSTDIR
	CHECKRC_EXIT $? "Could not create directory $LLVM_CIU_INSTDIR !"
    fi
    $CD $LLVM_CIU_INSTDIR
    CHECKRC_EXIT $? "Could not change directory to $LLVM_CIU_INSTDIR !"
    $RMRF bin include lib libexec share
    $CD $LLVM_CIU_BUILDDIR
    $NINJA install 2>/dev/null
    RC=$?
    CHECKRC_EXIT $RC "Could not install (RC=$RC) !"
    MSG " ... Finished installing."
    MSG
fi

MSG "READY."
MSG
