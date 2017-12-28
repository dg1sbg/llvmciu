#!/bin/bash

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
# Arguments:    None
#               Execution is controlled by environment variables
#
# Author:        Frank Goenninger, Goenninger B&T UG, Germany
#
# Plattforms:    Bash on Mac OS X
#
# Usage: $ llvmcui.sh
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
LLVM_CIU_CLANG_GIT_URL="https://git.llvm.org/git/clang.git/"
LLVM_CIU_LLD_GIT_URL="https://git.llvm.org/git/lld.git/"
LLVM_CIU_COMPILERRT_GIT_URL="https://git.llvm.org/git/compiler-rt.git/"
LLVM_CIU_OPENMP_GIT_URL="https://git.llvm.org/git/openmp.git/"
LLVM_CIU_LIBCXX_GIT_URL="https://git.llvm.org/git/libcxx.git/"
LLVM_CIU_LIBCXXABI_GIT_URL="https://git.llvm.org/git/libcxxabi.git/"
LLVM_CIU_CLANGTOOLSEXTRA_GIT_URL="https://git.llvm.org/git/clang-tools-extra.git/ extra"

LLVM_CIU_CLONE_LLVM=${LLVM_CIU_CLONE_LLVM:-1}
LLVM_CIU_CLONE_CLANG=${LLVM_CIU_CLONE_CLANG:-1}
LLVM_CIU_CLONE_LLD=${LLVM_CIU_CLONE_LLD:-1}
LLVM_CIU_CLONE_COMPILERRT=${LLVM_CIU_CLONE_COMPILERRT:-1}
LLVM_CIU_CLONE_OPENMP=${LLVM_CIU_CLONE_OPENMP:-1}
LLVM_CIU_CLONE_LIBCXX=${LLVM_CIU_CLONE_LIBCXX:-1}
LLVM_CIU_CLONE_LIBCXXABI=${LLVM_CIU_CLONE_LIBCXXABI:-1}
LLVM_CIU_CLONE_CLANGTOOLSEXTRA=${LLVM_CIU_CLONE_CLANGTOOLSEXTRA:-1}

LLVM_CIU_BUILD_IT=${LLVM_CIU_BUILD_IT:-1}
LLVM_CIU_INSTALL_IT=${LLVM_CIU_INSTALL_IT:-1}

CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE:-"Release"}
CMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX:-$LLVM_CIU_INSTROOT}
BUILD_SHARED_LIBS=${BUILD_SHARED_LIBS:-"ON"}
LLVM_ENABLE_ASSERTIONS=${LLVM_ENABLE_ASSERTIONS:-"OFF"}

export CMAKE_BUILD_TYPE
export CMAKE_INSTALL_PREFIX
export BUILD_SHARED_LIBS
export LLVM_ENABLE_ASSERTION

# ***************************************************
# *** YOU SHOULD NOT HAVE TO EDIT BELOW THIS LONE ***
# ***************************************************

# -----------------------------------------------------------------------------
#  P L A T F O R M    S P E C I F I C    C O N F I G    S E C T I O N
# -----------------------------------------------------------------------------

MKDIR="mkdir -p"
PWD=pwd
CD=cd
GIT_CLONE="git clone"
RMRF="rm -rf"

MYSELF=`basename $0`
CURRPWD=`$PWD`

RED_COLOR=`tput setaf 1`
GREEN_COLOR=`tput setaf 2`
WHITEB_COLOR=`tput setab 7`
RESET_COLOR=`tput sgr0`

GLOBAL_RC=0

# -----------------------------------------------------------------------------
#  I M P L E M E N T A T I O N    S E C T I O N
# -----------------------------------------------------------------------------

## FUNCTIONS ##

MSG()
{
    if [ $LLVM_CIU_INTERACTIVE_MODE -ne 0 ]
    then
	echo $1
    fi
}

ERRMSG()
{
    if [ $LLVM_CIU_INTERACTIVE_MODE -ne 0 ]
    then
	echo "${RED_COLOR}$1${RESET_COLOR}"
    fi
}

CLEANUP()
{
    MSG "$MYSELF: Cleaning up ..."
    $CD $LLVM_CIU_SRCROOT

    if [ $LLVM_CIU_DEBUG -ne 0 ]
    then
	ERRMSG "*** NOT CLEANING UP - DEBUG enabled !"
	return 0
    fi

    if [ $? -eq 0 ]
    then
	$RMRF $LLVM_CIU_LLVM_SRCDIR 2>/dev/null
	$RMRF $LLVM_CIU_LLVM_SRCDIR 2>/dev/null
	$RMRF $LLVM_CIU_LLVM_TOOLSDIR 2>/dev/null
	$RMRF $LLVM_CIU_LLVM_PROJECTSDIR 2>/dev/null
	$RMRF $LLVM_CIU_CLANG_TOOLSDIR 2>/dev/null
	$RMRF $LLVM_CIU_BUILDDIR 2>/dev/null
    fi

    MSG "$MYSELF: Exiting now."
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

TITLE ()
{
    if [ $LLVM_CIU_INTERACTIVE_MODE -ne 0 ]
    then
	clear
	echo "${GREEN_COLOR}=============================================================================="
	echo " $MYSELF - LLVM and CLANG Clone and Install Utility"
	echo "==============================================================================${RESET_COLOR}"
	echo
    fi
}

BUILD_TOOLS_CHECK()
{
    NINJA_MISSING=`type ninja`
    CHECKRC_EXIT $NINJA_MISSNG "$MYSELF requires NINJA build tool - not found !"

    CMAKE_MISSING=`type cmake`
    CHECKRC_EXIT $CMAKE_MISSNG "$MYSELF requires CMAKE - not found !"
}

TRAP_HANDLER()
{
    TITLE
    SIGNAL=$1
    FN=$2
    ERRMSG "TRAP_HANDLER: Received signal $SIGNAL ..."
    ${FN}
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
BUILD_TOOLS_CHECK

if [ $LLVM_CIU_INTERACTIVE_MODE -ne 0 ]
then
    TITLE
    echo "Configuration (1/2): Paths and Module Selection"
    echo
    echo "LLVM_CIU_SRCROOT ............. = $LLVM_CIU_SRCROOT"
    echo "LLVM_CIU_INSTROOT ............ = $LLVM_CIU_INSTROOT"
    echo "LLVM_CIU_LLVM_SRCDIR ......... = $LLVM_CIU_LLVM_SRCDIR"
    echo "LLVM_CIU_LLVM_TOOLSDIR ....... = $LLVM_CIU_LLVM_TOOLSDIR"
    echo "LLVM_CIU_LLVM_PROJECTSDIR .... = $LLVM_CIU_LLVM_PROJECTSDIR"
    echo "LLVM_CIU_CLANG_TOOLSDIR ...... = $LLVM_CIU_CLANG_TOOLSDIR"
    echo "LLVM_CIU_BUILDDIR ............ = $LLVM_CIU_BUILDDIR"
    echo "LLVM_CIU_CLONE_LLVM .......... = $LLVM_CIU_CLONE_LLVM"
    echo "LLVM_CIU_CLONE_CLANG ......... = $LLVM_CIU_CLONE_CLANG"
    echo "LLVM_CIU_CLONE_LLD ........... = $LLVM_CIU_CLONE_LLD"
    echo "LLVM_CIU_CLONE_COMPILERRT .... = $LLVM_CIU_CLONE_COMPILERRT"
    echo "LLVM_CIU_CLONE_OPENMP ........ = $LLVM_CIU_CLONE_OPENMP"
    echo "LLVM_CIU_CLONE_LIBCXX ........ = $LLVM_CIU_CLONE_LIBCXX"
    echo "LLVM_CIU_CLONE_LIBCXXABI ..... = $LLVM_CIU_CLONE_LIBCXXABI"
    echo "LLVM_CIU_CLONE_CLANGTOOLSEXTRA = $LLVM_CIU_CLONE_CLANGTOOLSEXTRA"
    echo
    echo "PRESS [RETURN] TO CONTINUE OR CTRL-C TO ABORT ..."
    read
    TITLE
    echo "Configuration (2/2): Environment Variables for CMAKE and Build & Install"
    echo
    echo "CMAKE_BUILD_TYPE ..... = $CMAKE_BUILD_TYPE"
    echo "CMAKE_INSTALL_PREFIX . = $CMAKE_INSTALL_PREFIX"
    echo "BUILD_SHARED_LIBS .... = $BUILD_SHARED_LIBS"
    echo "LLVM_ENABLE_ASSERTIONS = $LLVM_ENABLE_ASSERTIONS"
    echo
    echo "LLVM_CIU_BUILD_IT .... = $LLVM_CIU_BUILD_IT"
    echo "LLVM_CIU_INSTALL_IT .. = $LLVM_CIU_INSTALL_IT"
    echo
    echo "PRESS [RETURN] TO CONTINUE OR CTRL-C TO ABORT ..."
    read
fi

# Clone LLVM

if [ ! -d $LLVM_CIU_SRCROOT ]
then
    $MKDIR $LLVM_CIU_SRCROOT 2>/dev/null
    CHECKRC_EXIT $? "Could not create directory $LLVM_CIU_SRCROOT"
fi

if [ $LLVM_CIU_CLONE_LLVM -eq 1 ]
then
    TITLE
    MSG " ... Cloning ... (This may take some time - please wait)"
    MSG

    $CD $LLVM_CIU_SRCROOT 2>/dev/null
    CHECKRC_EXIT $? "Directory $LLVM_CIU_SRCROOT not accessible !"

    $GIT_CLONE $LLVM_CIU_LLVM_GIT_URL
    CHECKRC_EXIT $? "Failed to clone LLVM from $LLVM_CIU_LLVM_GIT_URL !"
fi

# Clone CLANG

if [ $LLVM_CIU_CLONE_CLANG -ne 0 ]
then
    TITLE
    MSG " ... Cloning ... (This may take some time - please wait)"
    MSG

    $CD $LLVM_CIU_LLVM_TOOLSDIR 2>/dev/null
    CHECKRC_EXIT $? "Directory $LLVM_CIU_LLVM_TOOLSDIR not accessible !"

    $GIT_CLONE $LLVM_CIU_CLANG_GIT_URL
    CHECKRC_EXIT $? "Failed to clone CLANG from $LLVM_CIU_CLANG_GIT_URL !"
fi

# Clone LLD

if [ $LLVM_CIU_CLONE_LLD -ne 0 ]
then
    TITLE
    MSG " ... Cloning ... (This may take some time - please wait)"
    MSG

    $CD $LLVM_CIU_LLVM_TOOLSDIR 2>/dev/null
    CHECKRC_EXIT $? "Directory $LLVM_CIU_LLVM_TOOLSDIR not accessible !"

    $GIT_CLONE $LLVM_CIU_LLD_GIT_URL
    CHECKRC_EXIT $? "Failed to clone LLD from $LLVM_CIU_LLD_GIT_URL !"
fi

# Clone COMPILER-RT

if [ $LLVM_CIU_CLONE_COMPILERRT -ne 0 ]
then
    TITLE
    MSG " ... Cloning ... (This may take some time - please wait)"
    MSG

    $CD $LLVM_CIU_LLVM_PROJECTSDIR 2>/dev/null
    CHECKRC_EXIT $? "Directory $LLVM_CIU_LLVM_PROJECTSDIR not accessible !"

    $GIT_CLONE $LLVM_CIU_COMPILERRT_GIT_URL
    CHECKRC_EXIT $? "Failed to clone COMPILER-RT from $LLVM_CIU_COMPILERRT_GIT_URL !"
fi

# Clone OPENMP

if [ $LLVM_CIU_CLONE_OPENMP -ne 0 ]
then
    TITLE
    MSG " ... Cloning ... (This may take some time - please wait)"
    MSG

    $CD $LLVM_CIU_LLVM_PROJECTSDIR 2>/dev/null
    CHECKRC_EXIT $? "Directory $LLVM_CIU_LLVM_PROJECTSDIR not accessible !"

    $GIT_CLONE $LLVM_CIU_OPENMP_GIT_URL
    CHECKRC_EXIT $? "Failed to clone OPENMP from $LLVM_CIU_OPENMP_GIT_URL !"
fi

# Clone LIBCXX

if [ $LLVM_CIU_CLONE_LIBCXX -ne 0 ]
then
    TITLE
    MSG " ... Cloning ... (This may take some time - please wait)"
    MSG

    $CD $LLVM_CIU_LLVM_PROJECTSDIR 2>/dev/null
    CHECKRC_EXIT $? "Directory $LLVM_CIU_LLVM_PROJECTSDIR not accessible !"

    $GIT_CLONE $LLVM_CIU_LIBCXX_GIT_URL
    CHECKRC_EXIT $? "Failed to clone LIBCXX from $LLVM_CIU_LIBCXX_GIT_URL !"
fi

# Clone LIBCXXABI

if [ $LLVM_CIU_CLONE_LIBCXXABI -ne 0 ]
then
    TITLE
    MSG " ... Cloning ... (This may take some time - please wait)"
    MSG

    $CD $LLVM_CIU_LLVM_PROJECTSDIR 2>/dev/null
    CHECKRC_EXIT $? "Directory $LLVM_CIU_LLVM_PROJECTSDIR not accessible !"

    $GIT_CLONE $LLVM_CIU_LIBCXXABI_GIT_URL
    CHECKRC_EXIT $? "Failed to clone LIBCXXABI from $LLVM_CIU_LIBCXXABI_GIT_URL !"
fi

# Clone CLANG EXTRA TOOLS

if [ $LLVM_CIU_CLONE_CLANGTOOLSEXTRA -ne 0 ]
then
    TITLE
    MSG " ... Cloning ... (This may take some time - please wait)"
    MSG

    $CD $LLVM_CIU_CLANG_TOOLSDIR 2>/dev/null
    CHECKRC_EXIT $? "Directory $LLVM_CIU_CLANG_TOOLSDIR not accessible !"

    $GIT_CLONE $LLVM_CIU_CLANGTOOLSEXTRA_GIT_URL
    CHECKRC_EXIT $? "Failed to clone CLANG Extra Tools from $LLVM_CIU_CLANGTOOLSEXTRA_GIT_URL !"
fi

# Build stuff

if [ $LLVM_CIU_BUILD_IT -ne 0 ]
then
    TITLE

    MSG " ... Building ... (This may take some time - please wait)"
    MSG

    $MKDIR $LLVM_CIU_BUILDDIR 2>/dev/null
    CHECKRC_EXIT $? "Could not create directory $LLVM_CIU_BUILDDIR !"

    $CD $LLVM_CIU_BUILDDIR 2>/dev/null

    ccmake -G Ninja $LLVM_CIU_LLVM_SRCDIR
    RC=$?
    CHECKRC_EXIT $RC "Could not complete ccmake successfully (RC=$RC) !"

    ninja 2>/dev/null
    RC=$?
    CHECKRC_EXIT $RC "Could not build (RC=$RC) !"
fi

if [ $LLVM_CIU_INSTALL_IT -ne 0 ]
then
    TITLE

    MSG " ... Installing ... (This may take some time - please wait)"
    MSG
    if [ ! -d $LLVM_CIU_INSTDIR ]
    then
	$(MKDIR) $LLVM_CIU_INSTDIR
	CHECKRC_EXIT $? "Could not create directory $LLVM_CIU_INSTDIR !"
    fi
    $(CD) $LLVM_CIU_INSTDIR
    CHECKRC_EXIT $? "Could not change directory to $LLVM_CIU_INSTDIR !"
    $(RMRF) \*
    $(CD) $LLVM_CIU_BUILDDIR
    ninja install 2>/dev/null
    RC=$?
    CHECKRC_EXIT $RC "Could not install (RC=$RC) !"
fi

TITLE

MSG " ... Finished installing."
MSG
MSG "READY."
MSG
