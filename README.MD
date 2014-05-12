# DesktopManager

这是一个用AutoHotKey脚本写的桌面管理工具。如果桌面图标太多，或许可以通过它来管理。本软件窗体是透明的，嵌入到了桌面里，这意味着即使你显示桌面，这个窗口仍旧会在，就像桌面一样。本软件可以加载一个目录下的所有文件，并且可以对文件进行一些操作，如复制，粘贴，删除，压缩，解压缩，打开命令行，新建文件，打开系统右键菜单等等，这种模式是主模式，这种模式下你所做的操作都是对源文件操作。另外一种模式是加载快捷方式文件，这些文件分为常用文件和常用软件存放在两个不同文件夹中，这个模式所做的操作部分是对源文件进行操作，如打开所在位置，打开命令行，打开系统右键菜单。无论哪一种模式，都可以方便地将文件或文件夹拖入窗口中，不同的是主模式是将文件移动到一个目录，而快捷模式只是创建拖入文件的快捷方式，后者还可以通过右键添加文件。

在桌面空白处双击可以隐藏或显示桌面图标。如果鼠标划过顶部，顶部按钮会自动显示，离开后会隐藏，但是如果是通过F12键激活了顶部按钮，则会一直显示。

**注意**:不要删除Desktopmanager.ini和version.txt及其他第一次使用后生成的文件。否则配置文件会被重写，软件运行也会有错。


## 安装

本软件是绿色软件，复制到任何地方都可以运行。下载:<http://pan.baidu.com/s/1jG5e0IU>

## 配置

配置文件是DesktopManager.ini，配置文件需要用记事本保存成Unicode编码
```ini
[DesktopManager]
# 主模式默认加载的目录
folder           = "D:\DM"
# git命令
gitCmd           = ""C:\Windows\system32\wscript" "D:\PortableApps\Git\Git Bash.vbs" "
# cmd命令
cmdCmd           = "cmd.exe /s /k pushd"
# 压缩命令
compressCmd      = ""D:\Applications\HaoZip\HaoZipC.exe" a -tzip "
# 解压缩命令
decompressCmd    = ""D:\Applications\HaoZip\HaoZipC.exe" x "
# 压缩文件后缀
compExtList       = "zip,7z,rar,gz,tar,bz,bz2,bzip2,deb,001"
# 模板目录
templatesDir     = "templates"
# 是否启用鼠标滑过显示按钮的功能，默认启用
isMouseActiveBtn = 1
# listview初始显示是图标模式
isIconView       = 1
# 背景色
bgColor          = "000000"
# 窗口宽度
sizeW            = 710
# 窗口高度
sizeH            = 
# 字体颜色
fontC            = "ffffff"
# 快捷方式存放的目录
shortcutDir      = "shortcut"
```
