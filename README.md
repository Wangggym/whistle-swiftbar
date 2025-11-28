# Whistle SwiftBar Plugin

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![SwiftBar](https://img.shields.io/badge/SwiftBar-Plugin-blue)](https://github.com/swiftbar/SwiftBar)

A powerful [SwiftBar](https://github.com/swiftbar/SwiftBar) plugin for managing [Whistle](https://github.com/avwo/whistle) proxy rules directly from your macOS menu bar. Toggle rules on/off with just one click!

[中文文档](README_CN.md)

## Features

- 🔧 **Menu Bar Integration** - Access all your Whistle rules from the menu bar
- ⚡ **One-Click Toggle** - Enable/disable rules instantly
- 🔄 **Auto Refresh** - Automatically updates rule status every 30 seconds
- 🔔 **Desktop Notifications** - Get notified when rules are toggled
- ⚙️ **Configurable** - Customize host, port, icon, and more
- 🌐 **Remote Support** - Manage Whistle instances on other machines
- 📊 **Status Display** - See how many rules are currently enabled

## Prerequisites

- macOS 10.15 or later
- [SwiftBar](https://github.com/swiftbar/SwiftBar) - Menu bar app for script-based plugins
- [Whistle](https://github.com/avwo/whistle) - HTTP proxy debugger (running instance)

## Installation

### Quick Install (Recommended)

1. Clone or download this repository:
   ```bash
   git clone https://github.com/your-username/whistle-swiftbar.git
   cd whistle-swiftbar
   ```

2. Run the install script:
   ```bash
   ./install.sh
   ```

3. Edit the config file to set your Whistle host and port:
   ```bash
   nano ~/Library/Application\ Support/SwiftBar/config.sh
   ```

4. Launch or refresh SwiftBar

### Manual Installation

1. Copy the plugin to SwiftBar's plugin directory:
   ```bash
   mkdir -p ~/Library/Application\ Support/SwiftBar
   cp whistle.30s.sh ~/Library/Application\ Support/SwiftBar/
   cp -r utils ~/Library/Application\ Support/SwiftBar/
   cp config.example.sh ~/Library/Application\ Support/SwiftBar/config.sh
   ```

2. Make scripts executable:
   ```bash
   chmod +x ~/Library/Application\ Support/SwiftBar/whistle.30s.sh
   chmod +x ~/Library/Application\ Support/SwiftBar/utils/*.sh
   ```

3. Edit the config file and refresh SwiftBar

## Configuration

Edit `~/Library/Application Support/SwiftBar/config.sh`:

```bash
# Whistle server host (default: 127.0.0.1 for local)
WHISTLE_HOST="127.0.0.1"

# Whistle server port (default: 8899)
WHISTLE_PORT="8899"

# Menu bar icon (emoji or text)
MENU_BAR_ICON="🔧"

# Show desktop notifications when toggling rules
SHOW_NOTIFICATIONS="true"

# Maximum number of rules to display in menu (0 = unlimited)
MAX_RULES_DISPLAY=20

# Show rule values in menu
SHOW_RULE_VALUES="false"
```

### Common Configurations

**Local Whistle instance:**
```bash
WHISTLE_HOST="127.0.0.1"
WHISTLE_PORT="8899"
```

**Remote Whistle on LAN:**
```bash
WHISTLE_HOST="192.168.1.100"
WHISTLE_PORT="8899"
```

**Custom port:**
```bash
WHISTLE_HOST="127.0.0.1"
WHISTLE_PORT="8888"
```

## Usage

### Basic Operations

1. **View Rules** - Click the 🔧 icon in your menu bar
2. **Toggle Rule** - Click any rule to enable/disable it
   - ✓ = Enabled
   - ○ = Disabled
3. **Open Whistle Web UI** - Select "Open Whistle Web UI" from the menu
4. **Refresh** - Select "Refresh" to manually update the rule list

### Menu Structure

```
🔧
---
✓ local_conductor      ← Click to toggle
○ production
○ development
---
📊 1/3 rules enabled
---
🔄 Refresh
🌐 Open Whistle Web UI
⚙️ Settings
  --Host: 127.0.0.1:8899
  --Edit Config
  --Copy Config Example
```

### Keyboard Shortcuts

While there are no built-in keyboard shortcuts, you can use macOS accessibility features or tools like [BetterTouchTool](https://folivora.ai/) to assign global shortcuts that click menu items.

## Troubleshooting

### Plugin not showing in menu bar

1. Make sure SwiftBar is running
2. Refresh SwiftBar: Select "Refresh All" from SwiftBar's menu
3. Check if the script is executable: `ls -la ~/Library/Application\ Support/SwiftBar/whistle.30s.sh`

### "Whistle not connected" error

1. Verify Whistle is running: `w2 status`
2. Check your config file has correct host and port
3. Test connection: `curl http://127.0.0.1:8899/`
4. If using remote Whistle, ensure firewall allows connections

### Rules not toggling

1. Check Whistle logs for errors
2. Verify you have permission to modify rules
3. Try toggling from Whistle's web UI to confirm it works
4. Check if Proxy Auth is enabled (may require authentication)

### No notifications appearing

1. Check System Preferences → Notifications
2. Ensure notifications are enabled for SwiftBar or Script Editor
3. Set `SHOW_NOTIFICATIONS="true"` in config.sh

## Advanced Usage

### Custom Refresh Interval

The refresh interval is controlled by the filename. To change it:

1. Rename the script in SwiftBar's plugin directory:
   ```bash
   cd ~/Library/Application\ Support/SwiftBar
   mv whistle.30s.sh whistle.10s.sh  # Refresh every 10 seconds
   ```

2. Refresh SwiftBar

Available intervals: `1s`, `5s`, `10s`, `30s`, `1m`, `5m`, `10m`, `30m`, `1h`

### Multiple Whistle Instances

To manage multiple Whistle instances, duplicate the plugin with different names:

```bash
cd ~/Library/Application\ Support/SwiftBar
cp whistle.30s.sh whistle-dev.30s.sh
cp whistle.30s.sh whistle-prod.30s.sh
cp config.sh config-dev.sh
cp config.sh config-prod.sh
```

Edit each script to load its respective config file.

## Uninstallation

Run the uninstall script:

```bash
cd whistle-swiftbar
./uninstall.sh
```

Or manually remove files:

```bash
rm ~/Library/Application\ Support/SwiftBar/whistle.30s.sh
rm -r ~/Library/Application\ Support/SwiftBar/utils
rm ~/Library/Application\ Support/SwiftBar/config.sh
```

## Development

### Project Structure

```
whistle-swiftbar/
├── whistle.30s.sh          # Main SwiftBar plugin
├── config.example.sh       # Configuration template
├── install.sh              # Installation script
├── uninstall.sh            # Uninstallation script
├── utils/
│   ├── whistle-api.sh      # Whistle API wrapper
│   └── notifier.sh         # Notification helper
└── README.md               # Documentation
```

### API Functions

The plugin uses Whistle's HTTP API:

- `GET /cgi-bin/init` - Get client ID
- `GET /cgi-bin/rules/list` - List all rules
- `POST /cgi-bin/rules/select` - Enable a rule
- `POST /cgi-bin/rules/unselect` - Disable a rule

### Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [SwiftBar](https://github.com/swiftbar/SwiftBar) - Amazing menu bar app
- [Whistle](https://github.com/avwo/whistle) - Powerful HTTP proxy tool
- Inspired by [PopClip](https://www.popclip.app/) for quick actions

## Related Projects

- [whistle](https://github.com/avwo/whistle) - HTTP, HTTP2, HTTPS, Websocket debugging proxy
- [whistle-client](https://github.com/avwo/whistle-client) - Official Whistle desktop client
- [SwiftBar](https://github.com/swiftbar/SwiftBar) - Powerful macOS menu bar customization tool

## Support

If you find this plugin helpful, please ⭐ star this repository!

For issues and feature requests, please [open an issue](https://github.com/your-username/whistle-swiftbar/issues).

