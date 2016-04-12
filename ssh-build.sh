#!/bin/bash
# openssh build script
# (C) 2016 shmilee, GPLv3
# Requires:
# Android NDK r8e x86_64 (http://developer.android.com/ndk/downloads/index.html)

helper()
{
    echo "Usage: $0 <ANDROID_NDK_ROOT> <_PATH_SSH_PROGRAM>"
    echo "  ANDROID_NDK_ROOT    default is $HOME/android/android-ndk-r8e"
    echo "  _PATH_SSH_PROGRAM   default is /system/busybox/ssh"
    exit 1
}

NCPU=$(grep -ci processor /proc/cpuinfo)
ANDROID_NDK_ROOT=${1:-"$HOME/android/android-ndk-r8e"}
_PATH_SSH_PROGRAM=${2:-"/system/busybox/ssh"}
export ANDROID_NDK_ROOT

if [ ! -d $ANDROID_NDK_ROOT ]; then
    echo "ANDROID_NDK_ROOT $ANDROID_NDK_ROOT not found."
    helper
    exit 1
fi

echo ">>> clean"
[ -d jni/external ] && rm -r jni/external/
[ -d libs ] && rm -r libs/
[ -d obj ] && rm -r obj/

echo ">>> download submodules ..."
git submodule update --init --remote

echo ">>> patch"
cd jni/external/
for p in $(ls ../../patches/*.patch); do
    patch -b -p0 < $p || exit 1
done
sed -i "s|\(^#define _PATH_SSH_PROGRAM \"\)/system/bin/ssh\"|\1${_PATH_SSH_PROGRAM}\"|g" openssh/config.h

echo ">>> build"
cd ../
$ANDROID_NDK_ROOT/ndk-build -j$NCPU || exit 1

echo ">>> copy"
cd ../
[ -d compiled ] && mv compiled compiled.bk
mkdir -p compiled/armeabi-v7a/{lib,bin}
cp -v libs/armeabi-v7a/{scp,sftp,sftp-server,sshd,ssh_exe,ssh-keygen} compiled/armeabi-v7a/bin/
cp -v libs/armeabi-v7a/libssh.so compiled/armeabi-v7a/lib/
