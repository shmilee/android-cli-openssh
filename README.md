Android Command Line OpenSSH
============================

Build openssh command line binaries for Android.

Upstreams:

* https://github.com/CyanogenMod/android_external_zlib.git -b cm-11.0
* https://github.com/CyanogenMod/android_external_openssl.git -b cm-11.0
* https://github.com/CyanogenMod/android_external_openssh.git -b cm-11.0


HOWTO build
===========

Requirements:

* Linux x86_64
* git
* [android-ndk-r8e-x86_64](https://dl.google.com/android/ndk/android-ndk-r8e-linux-x86_64.tar.bz2)

```
git clone https://github.com/shmilee/android-cli-openssh.git
cd android-cli-openssh
./ssh-build.sh <ANDROID_NDK_ROOT> <_PATH_SSH_PROGRAM> && find compiled/
```

__<_PATH_SSH_PROGRAM> is the ssh install path. default is /system/busybox/ssh__.
This affects ``scp`` and ``sftp``.

HOWTO use
=========

Requirements:

* ARM armeabi-v7a based Android device.
* Android 4.0 (API 14) or newer.
* An android terminal emulator, like https://github.com/jackpal/Android-Terminal-Emulator
* ~~root~~

Install
--------

```
device_path_for_ssh_bin=`dirname <_PATH_SSH_PROGRAM>`
export PATH=${device_path_for_ssh_bin}:$PATH
export LD_LIBRARY_PATH=<device_path_for_ssh_lib>:$LD_LIBRARY_PATH

bin/ssh_exe     -> <_PATH_SSH_PROGRAM>
bin/scp         -> ${device_path_for_ssh_bin}/scp
bin/sftp        -> ${device_path_for_ssh_bin}/sftp
bin/sftp-server -> ${device_path_for_ssh_bin}/sftp-server
bin/sshd        -> ${device_path_for_ssh_bin}/sshd
bin/ssh-keygen  -> ${device_path_for_ssh_bin}/ssh-keygen
lib/libssh.so   -> <device_path_for_ssh_lib>/libssh.so
```

Command info
------------

```
$ ssh 
usage: ssh [-1246AaCfgKkMNnqsTtVvXxYy] [-b bind_address] [-c cipher_spec]
           [-D [bind_address:]port] [-E log_file] [-e escape_char]
           [-F configfile] [-I pkcs11] [-i identity_file]
           [-L [bind_address:]port:host:hostport] [-Q protocol_feature]
           [-l login_name] [-m mac_spec] [-O ctl_cmd] [-o option] [-p port]
           [-R [bind_address:]port:host:hostport] [-S ctl_path]
           [-W host:port] [-w local_tun[:remote_tun]]
           [user@]hostname [command]
$ ssh -V
OpenSSH_6.4p1, OpenSSL 1.0.1e 11 Feb 2013
```

``sshd`` needs:

* root permission
* a host_rsa_key
* set ``AuthorizedKeysFile .ssh/authorized_keys`` in sshd_config
* add ssh client pub key in AuthorizedKeysFile

```
$ `which sshd` -h
option requires an argument -- h
OpenSSH_6.4p1, OpenSSL 1.0.1e 11 Feb 2013
usage: sshd [-46DdeiqTt] [-b bits] [-C connection_spec] [-c host_cert_file]
            [-E log_file] [-f config_file] [-g login_grace_time]
            [-h host_key_file] [-k key_gen_time] [-o option] [-p port]
            [-u len]

$ ssh-keygen -t rsa -f /sdcard/ssh_host_rsa_key #should be empty passphrase
Generating public/private rsa key pair.
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /sdcard/ssh_host_rsa_key.
Your public key has been saved in /sdcard/ssh_host_rsa_key.pub.
The key fingerprint is: xxxxxxxxxxxxxxxxxx
The key's randomart image is: xxxxxxxxxxxxxxxxx
$ netstat -tlp #run this to see if port 22 is already in use.
$ `which sshd` -d -f /sdcard/sshd_config -h /sdcard/ssh_host_rsa_key 
```

Strings
--------

They are defined in:

* jni/external/openssh/config.h
* jni/external/openssh/pathnames.h

So, change them, when you have a non-rooted android.

```
$ strings `which ssh`|egrep '\.ssh/|/ssh_'
.ssh/config
/data/ssh/ssh_config
/data/ssh/ssh_host_key
/data/ssh/ssh_host_dsa_key
/data/ssh/ssh_host_ecdsa_key
/data/ssh/ssh_host_rsa_key
.ssh/identity
.ssh/id_rsa
.ssh/id_dsa
.ssh/id_ecdsa
/data/ssh/ssh_known_hosts
/data/ssh/ssh_known_hosts2
/data/.ssh/known_hosts
/data/.ssh/known_hosts2

$ strings `which sshd`|egrep '\.ssh/|/ssh_'
/data/.ssh/known_hosts
/data/ssh/ssh_known_hosts
/data/ssh/ssh_host_key
/data/ssh/ssh_host_rsa_key
/data/ssh/ssh_host_dsa_key
/data/ssh/ssh_host_ecdsa_key
.ssh/authorized_keys
.ssh/authorized_keys2
%.200s/.ssh/environment
.ssh/rc
/data/.ssh/known_hosts2
/data/ssh/ssh_known_hosts2

$ strings `which scp`|grep '/system/'
/system/bin/linker
/system/busybox/ssh

$ strings `which sftp`|grep '/system/'
/system/bin/linker
/system/bin/sh
/system/busybox/ssh
```
