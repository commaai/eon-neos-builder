#!/usr/bin/env python

import subprocess
import requests
import os
import tempfile
import shutil

#BASE_URL = 'http://termux.net/'
BASE_URL = 'http://termux.comma.ai/'

# Create mirror using
# lftp -c "mirror --use-pget-n=10 --verbose http://termux.net"
# azcopy --source dists/ --destination https://termuxdist.blob.core.windows.net/dists --recursive --dest-key $(az storage account keys list --account-name termuxdist --output tsv --query "[0].value")


DEFAULT_PKG = ['apt', 'bash', 'busybox', 'ca-certificates', 'command-not-found', 'dash', 'dash', 'dpkg', 'gdbm', 'gpgv', 'libandroid-support', 'libbz2', 'libc++', 'libcrypt', 'libcurl', 'libffi', 'libgcrypt', 'libgpg-error', 'liblzma', 'libnghttp2', 'libsqlite', 'libutil', 'ncurses', 'ncurses-ui-libs', 'openssl', 'python', 'readline', 'termux-am', 'termux-exec', 'termux-tools']

# Python 3.8.2 is not available in binary form from the termux package repo,
# but it can be built from source from the termux-packages collection. It
# must be built locally in docker and copied to the path below.
#
# FIXME: still needs termux-elf stripping
# FIXME: should probably be using the Android API level options/legacy android-5 termux repo to start
# FIXME: explicitly test for the override package not being present and warn the user to look here
#
# Clone the termux repo and change the Python package build.sh and patch file
# back to its Python 3.8.2 state (from the current 3.8.3 or other future state)
#
# Then replace the configure.patch file with the below: removes lockf(), the
# preadv()/pwritev() family, and if_nameindex(), and undoes the termux patch
# removing link() which is usable on our ext4 filesystems.
#
#
#    diff -u -r ../cpython/configure ./configure
#    --- ../cpython/configure	2020-05-29 17:02:33.994795843 -0700
#    +++ ./configure	2020-05-29 17:44:19.524728185 -0700
#    @@ -11484,12 +11484,11 @@
#      getgrgid_r getgrnam_r \
#      getgrouplist getgroups getlogin getloadavg getpeername getpgid getpid \
#      getpriority getresuid getresgid getpwent getpwnam_r getpwuid_r getspnam getspent getsid getwd \
#    - if_nameindex \
#    - initgroups kill killpg lchown lockf linkat lstat lutimes mmap \
#    + initgroups kill killpg lchown linkat lstat lutimes mmap \
#      memrchr mbrtowc mkdirat mkfifo \
#      madvise mkfifoat mknod mknodat mktime mremap nice openat pathconf pause pipe2 plock poll \
#    - posix_fallocate posix_fadvise posix_spawn posix_spawnp pread preadv preadv2 \
#    - pthread_condattr_setclock pthread_init pthread_kill putenv pwrite pwritev pwritev2 \
#    + posix_fallocate posix_fadvise posix_spawn posix_spawnp pread \
#    + pthread_condattr_setclock pthread_init pthread_kill putenv pwrite \
#      readlink readlinkat readv realpath renameat \
#      sem_open sem_timedwait sem_getvalue sem_unlink sendfile setegid seteuid \
#      setgid sethostname \
#
# start docker: termux-packages/scripts/run-docker.sh
# build inside container: ./build-package.sh -a aarch64 python
# copy outside container: mkdir /tmp/termux-packages && docker cp termux-package-builder:/home/builder/termux-packages/debs/python_3.8.2_arm.deb /tmp/termux-packages

LOCAL_OVERRIDE_PKG = {'python': 'python_3.8.2_aarch64.deb'}

def load_packages():
    pkg_deps = {}
    pkg_filenames = {}

    r = requests.get(BASE_URL + 'dists/stable/main/binary-aarch64/Packages').text
    r += requests.get(BASE_URL + 'dists/stable/main/binary-all/Packages').text
    print(BASE_URL + 'dists/stable/main/binary-aarch64/Packages')

    for l in r.split('\n'):
        if l.startswith("Package:"):
            pkg_name = l.split(': ')[1]
            pkg_depends = []
        elif l.startswith('Depends: '):
            pkg_depends = l.split(': ')[1].split(',')
            pkg_depends = [p.replace(' ', '') for p in pkg_depends]

            # strip version (eg. gnupg (>= 2.2.9-1))
            pkg_depends = [p.split('(')[0] for p in pkg_depends]
        elif l.startswith('Filename: '):
            pkg_filename = l.split(': ')[1]
            pkg_deps[pkg_name] = pkg_depends
            pkg_filenames[pkg_name] = pkg_filename
    return pkg_deps, pkg_filenames


def get_dependencies(pkg_deps, pkg_name):
    r = [pkg_name]
    try:
        new_deps = pkg_deps[pkg_name]
        for dep in new_deps:
            r += get_dependencies(pkg_deps, dep)
    except KeyError:
        pass

    return r


def install_package(pkg_deps, pkg_filenames, pkg):
    if not os.path.exists('out'):
        os.mkdir('out')

    build_usr_dir = os.getcwd()
    tmp_dir = tempfile.mkdtemp()

    if pkg in LOCAL_OVERRIDE_PKG:
        deb_name = LOCAL_OVERRIDE_PKG[pkg]
        deb_path = os.path.join(os.path.join(build_usr_dir, "local_packages"), deb_name)
        print("Using local copy of package %s - %s - %s" % (pkg, tmp_dir, deb_name))
    elif pkg in pkg_filenames:
        url = BASE_URL + pkg_filenames[pkg]
        print("Downloading %s - %s - %s" % (pkg, tmp_dir, url))
        r = requests.get(url)
        deb_name = 'out.deb'
        deb_path = os.path.join(tmp_dir, deb_name)
        open(deb_path, 'wb').write(r.content)
    else:
        print("%s not found" % pkg)
        return ""

    subprocess.check_call(['ar', 'x', deb_path], cwd=tmp_dir)
    subprocess.check_call(['tar', '-C', './out', '-p', '-xf', os.path.join(tmp_dir, 'data.tar.xz')])
    if os.path.exists(os.path.join(tmp_dir, 'control.tar.gz')):
        subprocess.check_call(['tar', '-xf', os.path.join(tmp_dir, 'control.tar.gz')], cwd=tmp_dir)
    else:
        subprocess.check_call(['tar', '-xf', os.path.join(tmp_dir, 'control.tar.xz')], cwd=tmp_dir)

    control = open(os.path.join(tmp_dir, 'control')).read()
    control += 'Status: install ok installed\n'

    files = subprocess.check_output(['dpkg', '-c', deb_path], cwd=tmp_dir)

    file_list = ""
    for f in files.split('\n'):
        try:
            filename = f.split()[5][1:]
            if filename == '/':
                filename = '/.'  # this is what apt does
            file_list += filename + "\n"

        except IndexError:
            pass

    info_path = 'out/data/data/com.termux/files/usr/var/lib/dpkg/info'
    if not os.path.exists(info_path):
        os.makedirs(info_path)

    open(os.path.join(info_path, pkg + '.list'), 'w').write(file_list)

    copies = ['conffiles', 'postinst', 'prerm']

    for copy in copies:
        f = os.path.join(tmp_dir, copy)
        if os.path.exists(f):
            target = os.path.join(info_path, pkg + '.' + copy)
            shutil.copyfile(f, target)

    return control


if __name__ == "__main__":
    to_install = DEFAULT_PKG
    to_install += [
        'autoconf',
        'automake',
        'bison',
        'clang',
        'cmake',
        'coreutils',
        'curl',
        'ffmpeg',
        'ffmpeg-dev',
        'flex',
        'gdb',
        'git',
        'git-lfs',
        'htop',
        'jq',
        'libcurl-dev',
        'libffi-dev',
        'libjpeg-turbo',
        'libjpeg-turbo-dev',
        'liblz4',
        'liblz4-dev',
        'liblzo',
        'liblzo-dev',
        'libmpc',
        'libtool',
        'libuuid-dev',
        #'libzmq',
        'libpcap',
        'libpcap-dev',
        'make',
        'man',
        'nano',
        'ncurses-dev',
        'openssh',
        'openssl-dev',
        'openssl-tool',
        'patchelf',
        'pkg-config',
        # Included in main python package in recent termux
        #'python-dev',
        'rsync',
        'strace',
        'tar',
        'tmux',
        'vim',
        'wget',
        'xz-utils',
        'zlib-dev',
	'zsh',
    ]

    pkg_deps, pkg_filenames = load_packages()
    deps = []
    for pkg in to_install:
        deps += get_dependencies(pkg_deps, pkg)
    deps = set(deps)

    status = ""

    for pkg in deps:
        s = install_package(pkg_deps, pkg_filenames, pkg)
        status += s + "\n"
    print(deps)

    try:
        os.makedirs('out/data/data/com.termux/files/usr/var/lib/dpkg/')
    except OSError:
        pass

    status_file = 'out/data/data/com.termux/files/usr/var/lib/dpkg/status'
    open(status_file, 'w').write(status)
