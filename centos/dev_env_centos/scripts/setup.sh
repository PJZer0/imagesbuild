#!/bin/bash

echo "Running kungfu builder setup script for CentOS 7.9.2009 using Aliyun centos-vault mirrors..."

minorver=7.9.2009

echo "[+]01 Backing up and modifying main CentOS repositories..."
cd /etc/yum.repos.d/
for repo in CentOS-*.repo; do
    cp -p "$repo" "${repo}.bak_$(date +%Y%m%d%H%M%S)"
    sed -i -e "s|^mirrorlist=|#mirrorlist=|g" \
           -e "s|^#baseurl=http://mirror.centos.org/centos/\\\$releasever|baseurl=https://mirrors.aliyun.com/centos-vault/$minorver|g" \
           "$repo"
done

echo "[+]02 Importing GPG key from Aliyun mirrors..."
rpm --import https://mirrors.aliyun.com/centos/RPM-GPG-KEY-CentOS-7

echo "[+]03 Main repository configuration after modification:"
cat /etc/yum.repos.d/CentOS-Base.repo

echo "Finished replacing yum repos, now installing dependencies..."
set -e

echo "[+]04 Installing dependencies..."

# PYTHON_VERSION="3.9.15"
PYTHON_VERSION="3.10.17"
PIP_INSTALL="pip3 install"
PIPX_INSTALL="pipx install"

INSTALL="yum -y install"
REINSTALL="yum -y reinstall"

echo "[+]05 Installing SCL and EPEL repositories..."
$INSTALL centos-release-scl epel-release

echo "[+]06 Backing up and modifying SCL repositories to use Aliyun centos-vault mirrors..."
for repo in /etc/yum.repos.d/CentOS-SCLo*.repo; do
    cp -p "$repo" "${repo}.bak_$(date +%Y%m%d%H%M%S)"
    sed -i -e "s|^mirrorlist=|#mirrorlist=|g" \
           -e "s|^#baseurl=http://mirror.centos.org/centos/7|baseurl=https://mirrors.aliyun.com/centos-vault/$minorver|g" \
           "$repo"
done

echo "[+]07 Showing modified SCL repositories:"
cat /etc/yum.repos.d/CentOS-SCLo*.repo
echo "[+]08 Showing EPEL repositories:"
cat /etc/yum.repos.d/epel*.repo

echo "[+]09 Configuring yum repositories..."
# 启用 centos-sclo-rh-testing 仓库，禁用 centos-sclo-sclo（部分 SCL 仓库在 centos-vault 中可能不存在）
yum-config-manager --enable centos-sclo-rh-testing
yum-config-manager --disable centos-sclo-sclo


echo "[+]10 Installing IUS release package..."
curl -sSL https://repo.ius.io/ius-release-el7.rpm -o /tmp/ius-release-el7.rpm
yum localinstall -y /tmp/ius-release-el7.rpm
rm -f /tmp/ius-release-el7.rpm

echo "[+]11 Installing additional software dependencies..."

$INSTALL awscli \
         bind-utils \
         ccache \
         cmake3 \
         devtoolset-11 \
         rh-git227 \
         kde-l10n-Chinese \
         make \
         rh-maven35-maven \
         patchelf \
         nmap \
         rpm-build \
         tcpdump \
         traceroute \
         xz \
         bzip2-devel \
         libffi-devel \
         openssl-devel \
         readline-devel \
         sqlite-devel \
         xz-devel \
         yum-utils \
         zlib-devel

echo "[+]12 Enabling devtoolset-11 and rh-git227..."
source /opt/rh/devtoolset-11/enable
source /opt/rh/rh-git227/enable

echo "[+]13 Reinstalling glibc-common and setting locale..."
$REINSTALL glibc-common
localedef -c -f GB18030 -i zh_CN zh_CN.GB18030
localedef -c -f UTF-8 -i zh_CN zh_CN.UTF-8

echo "[+]14 Building Python $PYTHON_VERSION from source..."
# mkdir /tmp/code
cd /tmp/code
# https://www.python.org/ftp/python/3.12.11/Python-3.12.11.tar.xz
# curl -sSLO https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tar.xz
tar -xf Python-$PYTHON_VERSION.tar.xz
cd Python-$PYTHON_VERSION
./configure --with-ensurepip=install --enable-optimizations --enable-shared LDFLAGS="-Wl,-rpath /usr/local/lib"
make install
cd /
rm -rf /tmp/code

echo "[+]15 Creating symbolic links for cmake and python..."
ln -s /usr/bin/cmake3 /usr/bin/cmake
ln -s /usr/local/bin/python3 /usr/local/bin/python

echo "[+]16 Upgrading pip and installing pipx..."
$PIP_INSTALL --upgrade pip setuptools

echo "[+]17 Coniguring pypip to use Tsinghua mirror..."
# 设置清华源
pip3 config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple

# 设置信任主机
pip3 config set global.trusted-host tuna.tsinghua.edu.cn

# 设置超时和重试
pip3 config set global.timeout 60
pip3 config set install.retries 5

echo "[+]18 Installing pipx packages..."
$PIP_INSTALL pipx

echo "[+]19 Ensuring pipx path..."
pipx ensurepath

echo "[+]20 Installing pipx packages..."
$PIPX_INSTALL black==22.3.0
$PIPX_INSTALL clang-format==15.0.7
$PIPX_INSTALL pipenv==2022.8.15
$PIPX_INSTALL poetry==1.2.2

echo "Setup script completed."
