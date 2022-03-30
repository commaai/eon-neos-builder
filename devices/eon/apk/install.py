#!/usr/bin/env python3
import subprocess
import requests
import os
import tempfile
import shutil

#BASE_URL = 'http://termux.net/'
BASE_URL = 'http://termux.comma.ai/'

DEFAULT_PKG = ['apt', 'bash', 'busybox', 'ca-certificates', 'command-not-found', 'dash', 'dpkg', 'gdbm', 'gpgv', 'libandroid-support',
               'libbz2', 'libc++', 'libcrypt', 'libcrypt-dev', 'libcurl', 'libffi', 'libgcrypt', 'libgpg-error', 'liblzma', 'libnghttp2',
               'libsqlite', 'libutil', 'ncurses', 'ncurses-ui-libs', 'openssl', 'readline', 'termux-am', 'termux-exec', 'termux-tools']

APK_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)))
TERMUX_PACKAGES_DIR = os.path.join(APK_DIR, "termux-packages")
LOCAL_PKG_BASE = os.path.join(TERMUX_PACKAGES_DIR, "debs")
LOCAL_OVERRIDE_PKG = {
  'python': 'python_3.8.5_aarch64.deb',
  'swig': 'swig_4.0.1-1_aarch64.deb',
  'libicu': 'libicu_65.1-1_aarch64.deb',
  'libusb': 'libusb_1.0.23-1_aarch64.deb',
  'gettext': 'gettext_0.20.1-3_aarch64.deb',
  'ripgrep': 'ripgrep_11.0.2-1_aarch64.deb',
  'qt5-base': 'qt5-base_5.12.8-28_aarch64.deb',
  'qt5-declarative': 'qt5-declarative_5.12.8-28_aarch64.deb',
  #'panda-gcc': 'qt5-declarative_5.12.8-28_aarch64.deb',
  'panda-binutils': 'panda-binutils:_2.33.1-1_aarch64.deb',
}

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
    deb_path = os.path.join(LOCAL_PKG_BASE, deb_name)
    if not os.path.isfile(deb_path):
      subprocess.check_call(['scripts/run-docker.sh', './build-package.sh', pkg], cwd=TERMUX_PACKAGES_DIR)
    print("Using local copy of package %s - %s - %s" % (pkg, tmp_dir, deb_name))
  elif pkg in pkg_filenames:
    url = BASE_URL + pkg_filenames[pkg]
    print("Downloading %s - %s - %s" % (pkg, tmp_dir, url))
    r = requests.get(url)
    deb_name = 'out.deb'
    deb_path = os.path.join(tmp_dir, deb_name)
    open(deb_path, 'wb').write(r.content)
  else:
    # TODO: handle dependencies better
    if pkg in ("openssh|dropbear", ):
      return ""
    raise Exception(f"'{pkg}' not found")

  subprocess.check_call(['ar', 'x', deb_path], cwd=tmp_dir)
  subprocess.check_call(['tar', '-C', './out', '-p', '-xf', os.path.join(tmp_dir, 'data.tar.xz')])
  if os.path.exists(os.path.join(tmp_dir, 'control.tar.gz')):
    subprocess.check_call(['tar', '-xf', os.path.join(tmp_dir, 'control.tar.gz')], cwd=tmp_dir)
  else:
    subprocess.check_call(['tar', '-xf', os.path.join(tmp_dir, 'control.tar.xz')], cwd=tmp_dir)

  control = open(os.path.join(tmp_dir, 'control')).read()
  control += 'Status: install ok installed\n'

  files = subprocess.check_output(['dpkg', '-c', deb_path], cwd=tmp_dir, encoding='utf-8')

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
  to_install += list(LOCAL_OVERRIDE_PKG.keys())
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
    'rsync',
    'strace',
    'tar',
    'tmux',
    'vim',
    'wget',
    'xz-utils',
    'zlib-dev',
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

  with open('out/data/data/com.termux/files/usr/var/lib/dpkg/status', 'w') as f:
    f.write(status)
