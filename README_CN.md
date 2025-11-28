# Whistle SwiftBar 插件

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![SwiftBar](https://img.shields.io/badge/SwiftBar-Plugin-blue)](https://github.com/swiftbar/SwiftBar)

一个强大的 [SwiftBar](https://github.com/swiftbar/SwiftBar) 插件，用于直接在 macOS 菜单栏管理 [Whistle](https://github.com/avwo/whistle) 代理规则。一键开关规则！

[English Documentation](README.md)

## 功能特性

- 🔧 **菜单栏集成** - 从菜单栏访问所有 Whistle 规则
- ⚡ **一键切换** - 即时启用/禁用规则
- 🔄 **自动刷新** - 每 30 秒自动更新规则状态
- 🔔 **桌面通知** - 切换规则时收到通知
- ⚙️ **可配置** - 自定义主机、端口、图标等
- 🌐 **远程支持** - 管理其他机器上的 Whistle 实例
- 📊 **状态显示** - 查看当前启用了多少规则

## 前置要求

- macOS 10.15 或更高版本
- [SwiftBar](https://github.com/swiftbar/SwiftBar) - 基于脚本的菜单栏应用
- [Whistle](https://github.com/avwo/whistle) - HTTP 代理调试工具（运行中的实例）

## 安装

### 快速安装（推荐）

1. 克隆或下载此仓库：
   ```bash
   git clone https://github.com/your-username/whistle-swiftbar.git
   cd whistle-swiftbar
   ```

2. 运行安装脚本：
   ```bash
   ./install.sh
   ```

3. 编辑配置文件设置 Whistle 主机和端口：
   ```bash
   nano ~/Library/Application\ Support/SwiftBar/config.sh
   ```

4. 启动或刷新 SwiftBar

### 手动安装

1. 复制插件到 SwiftBar 插件目录：
   ```bash
   mkdir -p ~/Library/Application\ Support/SwiftBar
   cp whistle.30s.sh ~/Library/Application\ Support/SwiftBar/
   cp -r utils ~/Library/Application\ Support/SwiftBar/
   cp config.example.sh ~/Library/Application\ Support/SwiftBar/config.sh
   ```

2. 使脚本可执行：
   ```bash
   chmod +x ~/Library/Application\ Support/SwiftBar/whistle.30s.sh
   chmod +x ~/Library/Application\ Support/SwiftBar/utils/*.sh
   ```

3. 编辑配置文件并刷新 SwiftBar

## 配置

编辑 `~/Library/Application Support/SwiftBar/config.sh`：

```bash
# Whistle 服务器主机（默认：127.0.0.1 本地）
WHISTLE_HOST="127.0.0.1"

# Whistle 服务器端口（默认：8899）
WHISTLE_PORT="8899"

# 菜单栏图标（emoji 或文本）
MENU_BAR_ICON="🔧"

# 切换规则时显示桌面通知
SHOW_NOTIFICATIONS="true"

# 菜单中显示的最大规则数（0 = 无限制）
MAX_RULES_DISPLAY=20

# 在菜单中显示规则值
SHOW_RULE_VALUES="false"
```

### 常用配置

**本地 Whistle 实例：**
```bash
WHISTLE_HOST="127.0.0.1"
WHISTLE_PORT="8899"
```

**局域网远程 Whistle：**
```bash
WHISTLE_HOST="192.168.1.100"
WHISTLE_PORT="8899"
```

**自定义端口：**
```bash
WHISTLE_HOST="127.0.0.1"
WHISTLE_PORT="8888"
```

## 使用方法

### 基本操作

1. **查看规则** - 点击菜单栏中的 🔧 图标
2. **切换规则** - 点击任意规则来启用/禁用
   - ✓ = 已启用
   - ○ = 未启用
3. **打开 Whistle Web UI** - 从菜单中选择"打开 Whistle Web UI"
4. **刷新** - 选择"刷新"手动更新规则列表

### 菜单结构

```
🔧
---
✓ local_conductor      ← 点击切换
○ production
○ development
---
📊 1/3 规则已启用
---
🔄 刷新
🌐 打开 Whistle Web UI
⚙️ 设置
  --主机: 127.0.0.1:8899
  --编辑配置
  --复制配置示例
```

### 键盘快捷键

虽然没有内置键盘快捷键，但您可以使用 macOS 辅助功能或工具（如 [BetterTouchTool](https://folivora.ai/)）为菜单项分配全局快捷键。

## 故障排除

### 插件未显示在菜单栏

1. 确保 SwiftBar 正在运行
2. 刷新 SwiftBar：从 SwiftBar 菜单中选择"刷新全部"
3. 检查脚本是否可执行：`ls -la ~/Library/Application\ Support/SwiftBar/whistle.30s.sh`

### "Whistle 未连接"错误

1. 验证 Whistle 正在运行：`w2 status`
2. 检查配置文件中的主机和端口是否正确
3. 测试连接：`curl http://127.0.0.1:8899/`
4. 如果使用远程 Whistle，确保防火墙允许连接

### 规则无法切换

1. 检查 Whistle 日志是否有错误
2. 验证您有权限修改规则
3. 尝试从 Whistle 的 Web UI 切换以确认其工作正常
4. 检查是否启用了代理认证（可能需要身份验证）

### 没有通知显示

1. 检查系统偏好设置 → 通知
2. 确保为 SwiftBar 或脚本编辑器启用了通知
3. 在 config.sh 中设置 `SHOW_NOTIFICATIONS="true"`

## 高级用法

### 自定义刷新间隔

刷新间隔由文件名控制。要更改它：

1. 在 SwiftBar 插件目录中重命名脚本：
   ```bash
   cd ~/Library/Application\ Support/SwiftBar
   mv whistle.30s.sh whistle.10s.sh  # 每 10 秒刷新一次
   ```

2. 刷新 SwiftBar

可用间隔：`1s`、`5s`、`10s`、`30s`、`1m`、`5m`、`10m`、`30m`、`1h`

### 多个 Whistle 实例

要管理多个 Whistle 实例，使用不同名称复制插件：

```bash
cd ~/Library/Application\ Support/SwiftBar
cp whistle.30s.sh whistle-dev.30s.sh
cp whistle.30s.sh whistle-prod.30s.sh
cp config.sh config-dev.sh
cp config.sh config-prod.sh
```

编辑每个脚本以加载其各自的配置文件。

## 卸载

运行卸载脚本：

```bash
cd whistle-swiftbar
./uninstall.sh
```

或手动删除文件：

```bash
rm ~/Library/Application\ Support/SwiftBar/whistle.30s.sh
rm -r ~/Library/Application\ Support/SwiftBar/utils
rm ~/Library/Application\ Support/SwiftBar/config.sh
```

## 开发

### 项目结构

```
whistle-swiftbar/
├── whistle.30s.sh          # 主 SwiftBar 插件
├── config.example.sh       # 配置模板
├── install.sh              # 安装脚本
├── uninstall.sh            # 卸载脚本
├── utils/
│   ├── whistle-api.sh      # Whistle API 封装
│   └── notifier.sh         # 通知助手
└── README.md               # 文档
```

### API 函数

插件使用 Whistle 的 HTTP API：

- `GET /cgi-bin/init` - 获取客户端 ID
- `GET /cgi-bin/rules/list` - 列出所有规则
- `POST /cgi-bin/rules/select` - 启用规则
- `POST /cgi-bin/rules/unselect` - 禁用规则

### 贡献

欢迎贡献！请随时提交 Pull Request。

1. Fork 此仓库
2. 创建您的特性分支（`git checkout -b feature/AmazingFeature`）
3. 提交您的更改（`git commit -m 'Add some AmazingFeature'`）
4. 推送到分支（`git push origin feature/AmazingFeature`）
5. 开启一个 Pull Request

## 许可证

该项目采用 MIT 许可证 - 有关详细信息，请参阅 [LICENSE](LICENSE) 文件。

## 致谢

- [SwiftBar](https://github.com/swiftbar/SwiftBar) - 出色的菜单栏应用
- [Whistle](https://github.com/avwo/whistle) - 强大的 HTTP 代理工具
- 灵感来自 [PopClip](https://www.popclip.app/) 的快速操作

## 相关项目

- [whistle](https://github.com/avwo/whistle) - HTTP、HTTP2、HTTPS、Websocket 调试代理
- [whistle-client](https://github.com/avwo/whistle-client) - Whistle 官方桌面客户端
- [SwiftBar](https://github.com/swiftbar/SwiftBar) - 强大的 macOS 菜单栏自定义工具

## 支持

如果您觉得这个插件有帮助，请为此仓库加星 ⭐！

如有问题和功能请求，请[提交 issue](https://github.com/your-username/whistle-swiftbar/issues)。

