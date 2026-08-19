#!/bin/bash

# 修改主机名称
sed -i 's/ImmortalWrt/ZeroWrt/g' package/base-files/files/bin/config_generate

# 修改默认IP
sed -i 's/192.168.1.1/10.0.0.1/g' package/base-files/files/bin/config_generate

# 更改默认 Shell 为 zsh
# sed -i 's/\/bin\/ash/\/usr\/bin\/zsh/g' package/base-files/files/etc/passwd

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

# 移除要替换的包
rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/packages/lang/{golang,rust,node}
rm -rf feeds/packages/utils/{docker,dockerd,containerd,runc}
rm -rf feeds/packages/net/{open-app-filter,xray-core,v2ray-geodata,sing-box,chinadns-ng,dns2socks,hysteria,ipt2socks,mosdns,microsocks,naiveproxy,open-app-filter,shadowsocks-libev,shadowsocks-rust,shadowsocksr-libev,simple-obfs,tcping,trojan-plus,tuic-client,v2ray-plugin,xray-plugin,geoview,shadow-tls}
rm -rf feeds/luci/applications/{luci-app-argon-config,luci-app-appfilter,luci-app-diskman,luci-app-dockerman,luci-app-homeproxy,luci-app-openclash,luci-app-openlist,luci-app-passwall,luci-app-ramfree}

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
popd

./scripts/feeds update -a
./scripts/feeds install -a
