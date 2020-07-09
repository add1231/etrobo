#!/usr/bin/env bash
# etrobo all-in-one package installer/updater
#   setup.sh 
# Author: jtFuruhata
# Copyright (c) 2020 ETロボコン実行委員会, Released under the MIT license
# See LICENSE
#

#
# ** CAUTION **:
#   This module will be duplicated.
#   installation process is already moved into `etrobopkg`.
#

if [ -z "$ETROBO_ROOT" ]; then
    echo "run startetrobo first."
    exit 1
elif [ ! "$ETROBO_ENV" = "available" ]; then
    if [ "$ETROBO_KERNEL" = "darwin" ] && [ -z "$BEERHALL" ]; then
        echo "run startetrobo_mac.command first."
        exit 1
    fi
    . "$ETROBO_ROOT/scripts/etroboenv.sh" silent
fi
cd "$ETROBO_ROOT"

if [ "$1" = "update" ]; then
    update="update"
    dist="$2"
    cd "$ETROBO_ROOT"
    echo "update etrobo package:"
    git pull --ff-only
    rm -f ~/startetrobo
    cp -f scripts/startetrobo ~/
    if [ "$ETROBO_OS" = "mac" ]; then
        rm -f "$BEERHALL/../startetrobo_mac.command"
        cp -f scripts/startetrobo_mac.command "$BEERHALL/../"
    fi
    scripts="$ETROBO_SCRIPTS"
    . "$scripts/etroboenv.sh" unset
    . "$scripts/etroboenv.sh" silent
fi

if [ "$dist" != "dist" ]; then
    echo
    echo "Build Athrill2 with the ETrobo official certified commit"
    "$ETROBO_SCRIPTS/build_athrill.sh" official
    rm -f "$ETROBO_ATHRILL_SDK/common/library/libcpp-ev3/libcpp-ev3-standalone.a"
fi

#
# distribute UnityETroboSim
cd "$ETROBO_ROOT/dist"
echo "Bundled Simulator: $ETROBO_SIM_VER"
if [ "$ETROBO_OS" = "chrome" ]; then
    os="linux"
else
    os="$ETROBO_OS"
fi
targetSrc="etrobosim${ETROBO_SIM_VER}_${os}"
tar xvf "${targetSrc}.tar.gz" > /dev/null 2>&1

if [ "$ETROBO_KERNEL" = "darwin" ]; then
    targetSrc="${targetSrc}${ETROBO_EXE_POSTFIX}"
    targetDist="/Applications/etrobosim"
else
    targetDist="$ETROBO_USERPROFILE/etrobosim"
fi

if [ -d "$targetDist" ]; then
    rm -rf "$targetDist/$targetSrc"
else
    mkdir "$targetDist"
fi
mv -f "$targetSrc" "$targetDist/"

if [ -n "$update" ]; then
    echo
    echo "Update: finish"
    echo
else
    echo
    echo "Install etrobo Environment: finish"
    echo
fi
