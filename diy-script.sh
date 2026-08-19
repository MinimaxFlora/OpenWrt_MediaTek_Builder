#!/bin/bash

# 修改默认IP
sed -i 's/192.168.6.1/10.0.0.1/g' package/base-files/files/bin/config_generate
sed -i 's/192.168.110.1/10.0.0.1/g' package/base-files/files/bin/config_generate

# 更改默认 Shell 为 zsh
sed -i 's/\/bin\/ash/\/usr\/bin\/zsh/g' package/base-files/files/etc/passwd

# TTYD 免登录
sed -i 's|/bin/login|/bin/login -f root|g' feeds/packages/utils/ttyd/files/ttyd.config

# WiFi 设置
sed -i 's/ssid="ImmortalWrt-2.4G"/ssid="ZeroWrt-2.4G"/g; s/ssid="ImmortalWrt-5G"/ssid="ZeroWrt-5G"/g' package/mtk/applications/mtwifi-cfg/files/mtwifi.sh
sed -i 's/set wireless\.default_${dev}\.encryption=none/set wireless.default_${dev}.encryption=psk2/g' package/mtk/applications/mtwifi-cfg/files/mtwifi.sh
sed -i '/set wireless\.default_${dev}\.encryption=psk2/a\					set wireless.default_${dev}.key=1234567890' package/mtk/applications/mtwifi-cfg/files/mtwifi.sh

# 版本设置
sed -i 's/VERSION_DIST:=$(if $(VERSION_DIST),$(VERSION_DIST),ImmortalWrt)/VERSION_DIST:=$(if $(VERSION_DIST),$(VERSION_DIST),ZeroWrt)/' include/version.mk
sed -i 's/VERSION_MANUFACTURER:=$(if $(VERSION_MANUFACTURER),$(VERSION_MANUFACTURER),ImmortalWrt)/VERSION_MANUFACTURER:=$(if $(VERSION_MANUFACTURER),$(VERSION_MANUFACTURER),ZeroWrt)/' include/version.mk

# 移除要替换的包
rm -rf feeds/packages/lang/{golang,rust,node}
rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/packages/net/{open-app-filter,xray-core,v2ray-geodata,sing-box,chinadns-ng,dns2socks,hysteria,ipt2socks,mosdns,microsocks,naiveproxy,shadowsocks-libev,shadowsocks-rust,shadowsocksr-libev,simple-obfs,tcping,trojan-plus,tuic-client,v2ray-plugin,xray-plugin,geoview,shadow-tls}
rm -rf feeds/luci/applications/{luci-app-argon-config,luci-app-appfilter,luci-app-diskman,luci-app-dockerman,luci-app-homeproxy,luci-app-openclash,luci-app-openlist,luci-app-passwall,luci-app-ramfree}

# Go 1.26
git clone --depth=1 -b 26.x https://github.com/sbwml/packages_lang_golang feeds/packages/lang/golang

# Rust
git clone --depth=1 https://github.com/sbwml/packages_lang_rust feeds/packages/lang/rust

# Node - prebuilt
rm -rf feeds/packages/lang/node
git clone --depth=1 -b packages-25.12 https://github.com/sbwml/feeds_packages_lang_node feeds/packages/lang/node

# 我的插件源
git clone --depth=1 https://github.com/MinimaxFlora/openwrt_package package/new/helloworld

# 应用补丁
pushd feeds/luci
    curl -s https://github.com/MinimaxFlora/OpenWrt_MediaTek_Builder/raw/refs/heads/master/scripts/0001-luci-mod-status-add-help-and-feedback-links.patch | patch -p1
    curl -s https://github.com/MinimaxFlora/OpenWrt_MediaTek_Builder/raw/refs/heads/master/scripts/0002-luci-base-add-Chinese-translations-for-support-links.patch | patch -p1
popd

./scripts/feeds update -a
./scripts/feeds install -a
