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

    if pkg not in pkg_filenames:
        print("%s not found" % pkg)
        return ""

    url = BASE_URL + pkg_filenames[pkg]
    tmp_dir = tempfile.mkdtemp()

    print("Downloading %s - %s - %s" % (pkg, tmp_dir, url))
    r = requests.get(url)

    deb_path = os.path.join(tmp_dir, 'out.deb')
    open(deb_path, 'wb').write(r.content)
    subprocess.check_call(['ar', 'x', deb_path], cwd=tmp_dir)
    subprocess.check_call(['tar', '-C', './out', '-p', '-xf', os.path.join(tmp_dir, 'data.tar.xz')])
    if os.path.exists(os.path.join(tmp_dir, 'control.tar.gz')):
        subprocess.check_call(['tar', '-xf', os.path.join(tmp_dir, 'control.tar.gz')], cwd=tmp_dir)
    else:
        subprocess.check_call(['tar', '-xf', os.path.join(tmp_dir, 'control.tar.xz')], cwd=tmp_dir)

    control = open(os.path.join(tmp_dir, 'control')).read()
    control += 'Status: install ok installed\n'

    files = subprocess.check_output(['dpkg', '-c', 'out.deb'], cwd=tmp_dir)

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
        'clang',
        'cmake',
        'coreutils',
        'curl',
        'ffmpeg',
        'ffmpeg-dev',
        'gdb',
        'git',
        'git-lfs',
        'htop',
        'libcurl-dev',
        'libffi-dev',
        'liblz4',
        'liblz4-dev',
        'liblzo',
        'liblzo-dev',
        'libmpc',
        'libtool',
        'libuuid-dev',
        'libzmq',
        'make',
        'openssh',
        'openssl-dev',
        'openssl-tool',
        'patchelf',
        'pkg-config',
        'python2',
        'python2-dev',
        'rsync',
        'tar',
        'tmux',
        'vim',
        'wget',
        'xz-utils',
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
