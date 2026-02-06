# WindowSwitcher

A comprehensive AutoHotkey v2 script for enhanced Windows virtual desktop navigation with i3-style visual desktop indicator, automatic window focusing, and intuitive mouse/keyboard controls. Generated using AI, tested in usage manually.

Using [VirtualDesktopAccessor.dll](https://github.com/Ciantic/VirtualDesktopAccessor).

## ✨ Features

### Mouse Controls
- **Side buttons on taskbar**: Switch between virtual desktops
- **Side buttons on window title bars**: Move specific windows between desktops  
- **Ctrl + side buttons on taskbar**: Move active window to adjacent desktop
- **Both side buttons together**: Open Task View anywhere

### Keyboard Shortcuts
- `Win + 1-9`: Switch to specific desktop by number
- `Win + Tab` / `Win + Shift + Tab`: Switch to next/previous desktop
- `Win + Shift + 1-9`: Move active window to specific desktop (without switching view)
- `Win + ` (backtick)` or `Ctrl + Win + Tab`: Open Task View (default Windows hotkey is Win + Tab)
- `Alt + Win + Left/Right`: Move active window to adjacent desktop
- `Win + Ctrl + 0`: Show desktop tracking status

### Visual Interface
- **Desktop indicator**: i3-style clickable desktop bar shows current desktop and allows direct navigation

### Smart Features
- **Automatic window activation**: Switches focus to the appropriate window when changing desktops
- **Multi-monitor taskbar support**: Works on all monitors' taskbars
- **Intelligent title bar detection**: Prevents button pass-through in browsers and modern apps

## 🔧 Dependencies

### Required
- **AutoHotkey v2.0+**: Download from [autohotkey.com](https://www.autohotkey.com/)
- **Windows 10/11**: Virtual desktop support

### Optional (for enhanced performance)
- **VirtualDesktopAccessor.dll**: For zero-CPU-overhead desktop tracking and smoother window movement
  - Place the DLL in the same folder as the script or in your PATH
  - Available from [https://github.com/Ciantic/VirtualDesktopAccessor](https://github.com/Ciantic/VirtualDesktopAccessor)

## 🚀 Installation

1. Download and install AutoHotkey v2.0+
2. Download `WindowSwitcher.ahk` 
3. Download VirtualDesktopAccessor.dll
4. Double-click the .ahk file to run, or add it to your Windows startup folder to start it with Windows

## 🎮 Usage

- **Mouse controls**: Use side buttons on taskbar to switch desktops or on title bars to move windows
- **Desktop indicator**: Click any desktop number in the indicator bar to jump directly to that desktop
- **Keyboard shortcuts**: Use Win + number keys for direct desktop access and window management
- **Task View**: Press both side buttons simultaneously anywhere to open Task View

## 📝 Notes

- **Multi-monitor aware**: Detects taskbars on all monitors but positions indicator only on the main screen
- **Graceful fallbacks**: Works with or without VirtualDesktopAccessor.dll for maximum compatibility

## 🤖 Development

This script was entirely developed using AI assistance (LLM-powered "vibe coding"). It represents an iterative approach to solving virtual desktop navigation pain points through conversational development.

## 📄 License

Feel free to use, modify, and distribute this script as needed.