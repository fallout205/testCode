#!/bin/bash
set -e

echo "=========================================="
echo "  WebRTC 编译环境一键安装脚本"
echo "=========================================="

# 1. 更新系统源并安装基础编译依赖
echo "[1/6] 安装系统编译依赖..."
apt-get update -qq
apt-get install -y -qq --no-install-recommends \
    build-essential \
    gcc \
    g++ \
    make \
    cmake \
    ninja-build \
    pkg-config \
    bison \
    flex \
    gperf \
    libx11-dev \
    libxcomposite-dev \
    libxdamage-dev \
    libxext-dev \
    libxfixes-dev \
    libxrandr-dev \
    libxrender-dev \
    libxtst-dev \
    libglib2.0-dev \
    libgtk-3-dev \
    libnss3-dev \
    libasound2-dev \
    libpulse-dev \
    libudev-dev \
    libusb-1.0-0-dev \
    libssl-dev \
    libdbus-1-dev \
    libdrm-dev \
    libgbm-dev \
    libatspi2.0-dev \
    curl \
    wget \
    git \
    subversion \
    python3 \
    python3-pip \
    python3-setuptools \
    ccache \
    zip \
    unzip \
    locales \
    lsb-release

# 2. 设置 locale
echo "[2/6] 配置系统语言..."
locale-gen en_US.UTF-8
update-locale LANG=en_US.UTF-8

# 3. 安装 depot_tools
echo "[3/6] 安装 depot_tools..."
cd /home/vscode
if [ ! -d "depot_tools" ]; then
    git clone --depth 1 https://chromium.googlesource.com/chromium/tools/depot_tools.git
fi
echo 'export PATH="$HOME/depot_tools:$PATH"' >> /home/vscode/.bashrc
echo 'export DEPOT_TOOLS_UPDATE=0' >> /home/vscode/.bashrc
echo 'export GYP_DEFINES="target_arch=arm arm_version=7"' >> /home/vscode/.bashrc

# 4. 配置 pip 加速源
echo "[4/6] 配置 Python pip 镜像..."
su vscode -c "mkdir -p /home/vscode/.pip"
cat > /home/vscode/.pip/pip.conf << 'EOF'
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
trusted-host = pypi.tuna.tsinghua.edu.cn
EOF

# 5. 安装 ARM 交叉编译工具链
echo "[5/6] 安装 ARM 交叉编译工具链..."
apt-get install -y -qq --no-install-recommends \
    gcc-arm-linux-gnueabihf \
    g++-arm-linux-gnueabihf \
    binutils-arm-linux-gnueabihf

# 6. 配置 ccache 加速编译
echo "[6/6] 配置 ccache 编译缓存..."
mkdir -p /home/vscode/.ccache
chown -R vscode:vscode /home/vscode/.ccache /home/vscode/depot_tools /home/vscode/.pip /home/vscode/.bashrc

echo ""
echo "=========================================="
echo "  ✅ WebRTC 编译环境安装完成！"
echo "=========================================="
echo ""
echo "下一步操作："
echo "  1. 新建终端，执行: fetch --nohooks webrtc"
echo "  2. 进入 src 目录: cd src"
echo "  3. 安装依赖: ./build/install-build-deps.sh --arm"
echo "  4. 生成构建: gn gen out/arm7 --args='target_os=\"linux\" target_cpu=\"arm\" arm_version=7'"
echo "  5. 开始编译: ninja -C out/arm7 webrtc"
echo ""
echo "💡 提示：DEPOT_TOOLS_UPDATE 已设为0，避免depot_tools自动更新导致的网络问题"
