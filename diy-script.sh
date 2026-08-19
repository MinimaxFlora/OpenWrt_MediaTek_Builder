#!/bin/bash

# 修改默认IP
sed -i 's/192.168.1.1/10.0.0.1/g' package/base-files/files/bin/config_generate

# 更改默认 Shell 为 zsh
sed -i 's/\/bin\/ash/\/usr\/bin\/zsh/g' package/base-files/files/etc/passwd

# TTYD 免登录
sed -i 's|/bin/login|/bin/login -f root|g' feeds/packages/utils/ttyd/files/ttyd.config

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

./scripts/feeds update -a
./scripts/feeds install -a
