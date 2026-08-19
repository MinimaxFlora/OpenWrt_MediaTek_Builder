<p align="center">
  <img src="https://raw.githubusercontent.com/MinimaxFlora/OpenWrt_MediaTek_Builder/master/assets/logo.svg" width="120" alt="Logo">
  <h1 align="center">OpenWrt MediaTek Builder</h1>
  <p align="center">
    <strong>🚀 MT798x 系列路由器固件一键云端编译</strong>
  </p>
  <p align="center">
    <a href="https://github.com/MinimaxFlora/OpenWrt_MediaTek_Builder/actions"><img src="https://img.shields.io/github/actions/workflow/status/MinimaxFlora/OpenWrt_MediaTek_Builder/build-release.yml?style=for-the-badge&logo=githubactions&logoColor=white&label=Build" alt="Build Status"></a>
    <a href="https://github.com/MinimaxFlora/OpenWrt_MediaTek_Builder/releases"><img src="https://img.shields.io/github/v/release/MinimaxFlora/OpenWrt_MediaTek_Builder?style=for-the-badge&logo=github&logoColor=white&label=Release" alt="Release"></a>
    <a href="https://github.com/MinimaxFlora/OpenWrt_MediaTek_Builder"><img src="https://img.shields.io/badge/Platform-Linux%20%7C%20GitHub%20Actions-FF6B6B?style=for-the-badge&logo=linux&logoColor=white" alt="Platform"></a>
    <a href="LICENSE"><img src="https://img.shields.io/badge/License-GPLv3-2ECC71?style=for-the-badge&logo=gnu&logoColor=white" alt="License"></a>
  </p>
</p>

---

## 🌟 项目简介

**OpenWrt MediaTek Builder** 是一个基于 **GitHub Actions** 的 MT798x 系列路由器固件云端编译平台。

只需在 GitHub 页面点几下鼠标，即可自动完成源码拉取、依赖安装、固件编译、版本定制、Release 发布的全流程 —— **无需本地环境，随时随地编译你专属的 OpenWrt 固件**。

### 🎯 核心特性

| 特性 | 说明 |
|------|------|
| ☁️ **云端编译** | 全流程 GitHub Actions 自动化，零本地依赖 |
| 🖥️ **多设备支持** | 6 款 MT7986 设备一键切换 |
| ⚙️ **参数化构建** | 设备 / 版本 / 缓存 / IP / 密码 全部可定制 |
| 🚀 **编译加速** | ccache + 工具链缓存，二次构建大幅提速 |
| 🏷️ **自动发布** | 编译完成自动上传 Artifact + 发布 Release |
| 🧩 **配置自维护** | `configs/` 目录按设备维护 .config，灵活扩展 |

---

## 📡 支持的设备

| # | 设备 | 芯片 | 说明 |
|---|------|------|------|
| 1 | 磊科 N60 Pro | MT7986A | 双 2.5G 网口 · 高功率 WiFi |
| 2 | 京东云百里 | MT7986A | 百里路由器 · 2.5G 网口 |
| 3 | 锐捷天蝎 X60 NEW | MT7986A | 2.5G 网口 · 高功率 WiFi 6 |
| 4 | GL.iNet GL-MT6000 | MT7986A | 高性能 WiFi 6 |
| 5 | TP-Link TL-XDR6086 | MT7986A | 双频 WiFi 6 |
| 6 | TP-Link TL-XDR6088 | MT7986A | 双 2.5G 网口 · WiFi 6 |

> 💡 新增设备：在 `configs/` 目录添加 `24-config-musl-<设备ID>` 配置文件，并在 workflow 的 `device` 选项中注册即可。

---

## 🚀 快速开始

### 1️⃣ 触发构建

进入仓库 **Actions** 页面 → 选择 **Build releases** 工作流 → 点击 **Run workflow**：

### 2️⃣ 配置参数

| 参数 | 说明 | 默认值 |
|------|------|--------|
| **device** | 选择编译设备 | `ruijie_rg-x60-new` |
| **version** | 源码版本（24.10 / 25.12） | `openwrt-24.10` |
| **ccache** | 启用编译缓存（加速二次构建） | `false` |
| **lan_addr** | 默认 LAN IP 地址 | `10.0.0.1` |
| **root_password** | root 密码（留空=无密码） | 空 |
| **build_options** | 构建选项（空格分隔） | `ENABLE_CCACHE=y` |

### 3️⃣ 等待编译

编译过程约 **30-60 分钟**（视设备与插件数量），期间可在 Actions 页面实时查看：

- 📊 **分步日志**：源码获取 → feeds → 配置 → 定制 → 编译，每步可折叠查看
- 🧊 **编译缓存**：工具链缓存自动保存，下次构建大幅加速

### 4️⃣ 获取固件

编译完成后自动：

- 📦 上传 **Artifact**（保留 14 天，随时下载）
- 🏷️ 发布 **Release**（固件 + sha256sums + config.buildinfo）

---

## 🛠️ 构建流程

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  环境准备    │ →  │  源码获取    │ →  │  配置加载    │ →  │  固件定制    │
│ 清理/依赖/   │    │ clone       │    │ configs/    │    │ LAN/密码/    │
│ 磁盘扩容     │    │ feeds init  │    │ + ccache    │    │ 版本信息     │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
                                                                  ↓
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  Release    │ ←  │  固件收集    │ ←  │  编译固件    │ ←  │  构建准备    │
│ 自动发布     │    │ sysupgrade  │    │ MTK 串行    │    │ defconfig   │
│ + Artifact  │    │ sha256sums  │    │ + 并行编译   │    │ + download  │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
```

### ⚙️ 技术亮点

- **内存感知并行度**：按 1.5GB/核 计算 `-jN`，避免 GitHub Runner OOM
- **MTK 串行编译**：warp → mt_wifi 先串行编译，避免内核模块竞争
- **LLVM/Clang 工具链**：预装 sbwml 官方 LLVM 环境
- **磁盘扩容**：`free-disk` 清理 + `/builder` 挂载，构建空间充足
- **大陆网络友好**：代理自动检测，克隆/下载全程稳定

---

## 📁 项目结构

```
OpenWrt_MediaTek_Builder
├── .github/workflows/
│   └── build-release.yml      # 构建工作流（参数化）
├── configs/                   # 设备配置（用户自维护）
│   └── 24-config-musl-<设备>  # 每个设备一个完整 .config
├── build.sh                   # 编译脚本（sbwml 风格）
└── README.md
```

---

## 📄 License

本项目基于 **GPL-3.0** 许可证开源，遵循 OpenWrt / ImmortalWrt 社区协议。

---

<p align="center">
  <sub>Made with ❤️ by <a href="https://github.com/MinimaxFlora">MinimaxFlora</a></sub>
</p>
