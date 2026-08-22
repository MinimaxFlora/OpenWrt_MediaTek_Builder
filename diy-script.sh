#!/bin/bash

# 修改主机名称
sed -i 's/ImmortalWrt/ZeroWrt/g' package/base-files/files/bin/config_generate

# 修改默认IP
sed -i 's/192.168.1.1/10.0.0.1/g' package/base-files/files/bin/config_generate

# 修改默认密码
default_password=$(openssl passwd -5 password)
sed -i "s|^root:[^:]*:|root:${default_password}:|" package/base-files/files/etc/shadow

# 更改默认 Shell 为 zsh
# sed -i 's/\/bin\/ash/\/usr\/bin\/zsh/g' package/base-files/files/etc/passwd

# SSH 登录横幅
mkdir -p files/etc
cp -f $GITHUB_WORKSPACE/scripts/banner files/etc/banner

# profile
sed -i 's#\\u@\\h:\\w\\\$#\\[\\e[32;1m\\][\\u@\\h\\[\\e[0m\\] \\[\\033[01;34m\\]\\W\\[\\033[00m\\]\\[\\e[32;1m\\]]\\[\\e[0m\\]\\\$#g' package/base-files/files/etc/profile
sed -ri 's/(export PATH=")[^"]*/\1%PATH%:\/opt\/bin:\/opt\/sbin:\/opt\/usr\/bin:\/opt\/usr\/sbin/' package/base-files/files/etc/profile
sed -i '/ENV/i\export TERM=xterm-color' package/base-files/files/etc/profile

# bash
sed -i 's#ash#bash#g' package/base-files/files/etc/passwd
sed -i '\#export ENV=/etc/shinit#a export HISTCONTROL=ignoredups' package/base-files/files/etc/profile
mkdir -p files/root
cp -f $GITHUB_WORKSPACE/scripts/.bash_profile files/root/.bash_profile
cp -f $GITHUB_WORKSPACE/scripts/.bashrc files/root/.bashrc

# TTYD 免登录
sed -i 's|/bin/login|/bin/login -f root|g' feeds/packages/utils/ttyd/files/ttyd.config
sed -i 's/services/system/g' feeds/luci/applications/luci-app-ttyd/root/usr/share/luci/menu.d/luci-app-ttyd.json
sed -i '3 a\\t\t"order": 50,' feeds/luci/applications/luci-app-ttyd/root/usr/share/luci/menu.d/luci-app-ttyd.json
sed -i 's/procd_set_param stdout 1/procd_set_param stdout 0/g' feeds/packages/utils/ttyd/files/ttyd.init
sed -i 's/procd_set_param stderr 1/procd_set_param stderr 0/g' feeds/packages/utils/ttyd/files/ttyd.init

# WiFi 设置
sed -i 's/ImmortalWrt-/ZeroWrt-/g' package/mtk/applications/mtwifi-cfg-ucode/files/lib/wifi/mtwifi.uc
sed -i 's|        "encryption": "none"|        "encryption": "psk2",\n        "key": "1234567890"|' package/mtk/applications/mtwifi-cfg-ucode/files/lib/wifi/mtwifi.uc

# 版本设置
sed -i 's/VERSION_DIST:=$(if $(VERSION_DIST),$(VERSION_DIST),ImmortalWrt)/VERSION_DIST:=$(if $(VERSION_DIST),$(VERSION_DIST),ZeroWrt)/' include/version.mk
sed -i 's/VERSION_MANUFACTURER:=$(if $(VERSION_MANUFACTURER),$(VERSION_MANUFACTURER),ImmortalWrt)/VERSION_MANUFACTURER:=$(if $(VERSION_MANUFACTURER),$(VERSION_MANUFACTURER),ZeroWrt)/' include/version.mk
sed -i "s/DISTRIB_DESCRIPTION='[^']*'/DISTRIB_DESCRIPTION='ZeroWrt-$(date +%Y%m%d)'/g" package/base-files/files/etc/openwrt_release
sed -i "s/DISTRIB_REVISION='[^']*'/DISTRIB_REVISION=' By MinimaxFlora'/g" package/base-files/files/etc/openwrt_release
sed -i "s|^OPENWRT_RELEASE=\".*\"|OPENWRT_RELEASE=\"ZeroWrt 标准版 @R$(date +%Y%m%d) BY MinimaxFlora\"|" package/base-files/files/usr/lib/os-release

# 移除要替换的包
rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/packages/lang/{golang,rust}
rm -rf feeds/packages/utils/{docker,dockerd,containerd,runc}
rm -rf feeds/packages/net/{adguardhome,open-app-filter,xray-core,v2ray-geodata,sing-box,chinadns-ng,dns2socks,hysteria,ipt2socks,mosdns,microsocks,naiveproxy,open-app-filter,shadowsocks-libev,shadowsocks-rust,shadowsocksr-libev,simple-obfs,tcping,trojan-plus,tuic-client,v2ray-plugin,xray-plugin,geoview,shadow-tls}
rm -rf feeds/luci/applications/{luci-app-adguardhome,luci-app-argon-config,luci-app-appfilter,luci-app-diskman,luci-app-dockerman,luci-app-homeproxy,luci-app-openclash,luci-app-openlist,luci-app-passwall,luci-app-ramfree}

# Go 1.26
git clone --depth=1 -b 26.x https://github.com/sbwml/packages_lang_golang feeds/packages/lang/golang

# Rust
git clone --depth=1 https://github.com/sbwml/packages_lang_rust feeds/packages/lang/rust

# 我的插件源
git clone --depth=1 https://github.com/MinimaxFlora/openwrt_package package/new/helloworld && rm -rf package/new/helloworld/autocore

# Docker
git clone --depth=1 -b openwrt-25.12 https://github.com/sbwml/luci-app-dockerman feeds/luci/applications/luci-app-dockerman
git clone --depth=1 https://github.com/sbwml/packages_utils_docker feeds/packages/utils/docker
git clone --depth=1 https://github.com/sbwml/packages_utils_dockerd feeds/packages/utils/dockerd
git clone --depth=1 https://github.com/sbwml/packages_utils_containerd feeds/packages/utils/containerd
git clone --depth=1 https://github.com/sbwml/packages_utils_runc feeds/packages/utils/runc

# 应用补丁
pushd feeds/luci
    curl -s https://raw.githubusercontent.com/MinimaxFlora/OpenWrt_MediaTek_Builder/refs/heads/master/scripts/0001-luci-mod-status-add-help-and-feedback-links.patch | patch -p1
    curl -s https://raw.githubusercontent.com/MinimaxFlora/OpenWrt_MediaTek_Builder/refs/heads/master/scripts/0002-luci-base-add-Chinese-translations-for-support-links.patch | patch -p1
    curl -s https://raw.githubusercontent.com/MinimaxFlora/OpenWrt_MediaTek_Builder/refs/heads/master/scripts/0003-luci-app-firewall-remove-flow-offloading-settings.patch | patch -p1
    curl -s https://raw.githubusercontent.com/MinimaxFlora/OpenWrt_MediaTek_Builder/refs/heads/master/scripts/0004-luci-mod-system-add-modal-overlay-dialog-to-reboot.patch | patch -p1
    curl -s https://raw.githubusercontent.com/MinimaxFlora/OpenWrt_MediaTek_Builder/refs/heads/master/scripts/0005-luci-mod-status-add-network-speed-monitor.patch | patch -p1
popd

# GCC 16
curl -s https://raw.githubusercontent.com/MinimaxFlora/OpenWrt_MediaTek_Builder/refs/heads/master/scripts/0006-toolchain-gcc-add-support-for-GCC-16.patch | patch -p1

# xl2tpd
sed -i '/ifneq (0,0)/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/net/xl2tpd/Makefile

# elfutils lto
curl -s https://raw.githubusercontent.com/MinimaxFlora/OpenWrt_MediaTek_Builder/refs/heads/master/scripts/900-fix-gcc16-null-dereference-with-lto.patch > package/libs/elfutils/patches/900-fix-gcc16-null-dereference-with-lto.patch

# libwebsockets
mkdir -p feeds/packages/libs/libwebsockets/patches
curl -s https://raw.githubusercontent.com/MinimaxFlora/OpenWrt_MediaTek_Builder/refs/heads/master/scripts/900-fix-build-for-gcc-16.patch > feeds/packages/libs/libwebsockets/patches/900-fix-build-for-gcc-16.patch

# bash
sed -i "/PKG_INSTALL:=/i\PKG_BUILD_FLAGS:=no-lto" feeds/packages/utils/bash/Makefile

./scripts/feeds update -a
./scripts/feeds install -a
