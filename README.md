# WindowSwitcher

A comprehensive AutoHotkey v2 script for enhanced Windows virtual desktop navigation and window management using mouse side buttons and keyboard shortcuts. Generated using AI, tested in usage manually.

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

### Smart Features
- **Automatic window activation**: When switching desktops, the topmost window gets focus for immediate typing
- **Multi-monitor taskbar support**: Works on all monitors' taskbars
- **Intelligent title bar detection**: Prevents button pass-through in browsers and modern apps
- **Visual feedback**: Tooltips show which windows are being moved and desktop boundaries

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

- Hover over any taskbar and use mouse side buttons to switch desktops
- Hover over any window's title area and use mouse side buttons to move that window
- Use keyboard shortcuts for direct desktop access and window management
- Press both side buttons simultaneously anywhere to open Task View

## 📝 Notes

- **Multi-monitor aware**: Detects taskbars on all monitors
- **Browser-friendly**: Prevents side button pass-through in Chrome, Firefox, Edge.
- **Customizable detection areas**: Tuned for modern application UIs and browser tab areas
- **Graceful fallbacks**: Works with or without VirtualDesktopAccessor.dll

## 🤖 Development

This script was entirely developed using AI assistance (LLM-powered "vibe coding"). It represents an iterative approach to solving virtual desktop navigation pain points through conversational development.

## 📄 License

Feel free to use, modify, and distribute this script as needed.