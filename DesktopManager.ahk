; ************************************************************************************************
;           Date:  2014/05/12
;		Platform:  Windows 7
;	      Author:  howiefh
;         E-mail:  howiefh@gmail.com
;    Description:  Desktop Manager
; ************************************************************************************************
;  NOTE:PLEASE DO NOT REMOVE INFO ABOVE THIS LINE WHEN YOUR BUILD YOUR OWN SCRIPT
; ************************************************************************************************
#SingleInstance, force
#include include\WatchDirectory.ahk
#include include\ShellContextMenu.ahk
version:="1.2.0"
FileRead, ver, version.txt
if(ver!=version || !FileExist("DesktopManager.ini"))
{
; fileinstall必须先创建目录
ifnotexist %a_workingdir%\img
    FileCreateDir,%a_workingdir%\img
ifnotexist %a_workingdir%\templates
    FileCreateDir,%a_workingdir%\templates
FileInstall, img\clear.png, %a_workingdir%\img\clear.png, 1
FileInstall, img\clear_over.png, %a_workingdir%\img\clear_over.png, 1
FileInstall, img\file.png, %a_workingdir%\img\file.png, 1
FileInstall, img\file_over.png, %a_workingdir%\img\file_over.png, 1
FileInstall, img\folder.png, %a_workingdir%\img\folder.png, 1
FileInstall, img\folder_over.png, %a_workingdir%\img\folder_over.png, 1
FileInstall, img\home.png, %a_workingdir%\img\home.png, 1
FileInstall, img\home_over.png, %a_workingdir%\img\home_over.png, 1
FileInstall, img\move.png, %a_workingdir%\img\move.png, 1
FileInstall, img\move_over.png, %a_workingdir%\img\move_over.png, 1
FileInstall, img\quit.png, %a_workingdir%\img\quit.png, 1
FileInstall, img\quit_over.png, %a_workingdir%\img\quit_over.png, 1
FileInstall, img\soft.png, %a_workingdir%\img\soft.png, 1
FileInstall, img\soft_over.png, %a_workingdir%\img\soft_over.png, 1
FileInstall, img\switch.png, %a_workingdir%\img\switch.png, 1
FileInstall, img\switch_over.png, %a_workingdir%\img\switch_over.png, 1
FileInstall, img\refresh.png, %a_workingdir%\img\refresh.png, 1
FileInstall, img\refresh_over.png, %a_workingdir%\img\refresh_over.png, 1
FileInstall, templates\Microsoft PowerPoint 演示文稿.pptx, %a_workingdir%\templates\Microsoft PowerPoint 演示文稿.pptx, 1
FileInstall, templates\Microsoft Excel 工作表.xlsx  , %a_workingdir%\templates\Microsoft Excel 工作表.xlsx  , 1
FileInstall, templates\Microsoft Word 文档.docx       , %a_workingdir%\templates\Microsoft Word 文档.docx       , 1
FileInstall, templates\文本文档.txt               , %a_workingdir%\templates\文本文档.txt               , 1
FileInstall, DesktopManager.ini, %a_workingdir%\DesktopManager.ini, 1
filedelete , version.txt
FileAppend , %version%, version.txt
}
; 下面是一个比此页面顶部附近那个更精巧的可运行脚本.
; 它显示用户文件夹中的文件, 且每个文件分配一个与其类型关联的图标.
; 用户在一个文件上双击或在一个或多个文件上右击后, 会显示上下文菜单.
;================================
; read config file start
;================================
; 语言文件是记事本中的unicode格式
DM_iniFilename := "DesktopManager.ini"
DM_gsection := "DesktopManager"
IniRead , DM_Folder      , %DM_iniFilename% , %DM_gsection% , folder, DMFiles
IniRead , DM_gitCmd      , %DM_iniFilename% , %DM_gsection% , gitCmd
IniRead , DM_cmdCmd      , %DM_iniFilename% , %DM_gsection% , cmdCmd
IniRead , DM_compressCmd , %DM_iniFilename% , %DM_gsection% , compressCmd
; DM_decompressCmd:= """D:\Applications\HaoZip\HaoZip.exe"" "
IniRead , DM_decompressCmd , %DM_iniFilename% , %DM_gsection% , decompressCmd
IniRead , DM_CompExtList    , %DM_iniFilename% , %DM_gsection% , compExtList, zip,7z,rar,gz,tar,bz,bz2,bzip2,deb,001
IniRead , DM_EditExtList, %DM_iniFilename% , %DM_gsection% , editExtList, doc,docx,ppt,pptx,xls,xlsx,txt,md,ahk,c,h,cpp,java,ini,xml,html,css,js
IniRead , DM_templatesDir  , %DM_iniFilename% , %DM_gsection% , templatesDir  , templates
IniRead , DM_shortcutDir, %DM_iniFilename% , %DM_gsection% , shortcutDir, shortcut

; 鼠标移动到窗口上方显示按钮。 true 的话显示
IniRead , DM_isMouseActiveBtn , %DM_iniFilename% , %DM_gsection% , isMouseActiveBtn , true
IniRead , DM_isIconView       , %DM_iniFilename% , %DM_gsection% , isIconView       , true
; 可以为任意 RGB 颜色 (在下面会被设置为透明).
IniRead , DM_bgColor , %DM_iniFilename% , %DM_gsection% , bgColor , 000000
IniRead , DM_sizeW   , %DM_iniFilename% , %DM_gsection% , sizeW   , 710
IniRead , DM_sizeH   , %DM_iniFilename% , %DM_gsection% , sizeH   , % A_ScreenHeight - 40
if(DM_sizeW == ""){
    DM_sizeW   := 710
}
if(DM_sizeH == ""){
    DM_sizeH   := A_ScreenHeight - 40
}
IniRead , DM_fontC   , %DM_iniFilename% , %DM_gsection% , fontC   , ffffff
IniRead , DM_X, %DM_iniFilename%, %DM_gsection%, WinX, % A_ScreenWidth - DM_sizeW
IniRead , DM_Y, %DM_iniFilename%, %DM_gsection%, WinY, 0
if(DM_X == ""){
    DM_X := A_ScreenWidth - DM_sizeW
}
if(DM_Y == ""){
    DM_Y := 0
}
IniRead , DM_isAutoStart, %DM_iniFilename% , %DM_gsection% , isAutoStart, 1
IniRead , DM_isLinks, %DM_iniFilename% , %DM_gsection% , isLinks, 1
if(DM_Folder==""){
    DM_Folder:= a_workingdir . "\DMFiles"
}
ifnotexist % DM_Folder 
{
    FileCreateDir, %DM_Folder%
}
if(DM_isAutoStart==0){
    FileDelete, C:\Users\%a_username%\Links\DM.lnk
}else{
    FileCreateShortcut,%DM_Folder%,C:\Users\%a_username%\Links\DM.lnk
}
if(DM_isLinks==0){
    FileDelete, %A_Startup%\DesktopManager.lnk
}else{
    FileCreateShortcut,%a_scriptfullpath%,%A_Startup%\DesktopManager.lnk, %a_scriptdir%
}
if( DM_templatesDir ==""){
    DM_templatesDir:="templates"
}
ifnotexist % DM_templatesDir
{
    FileCreateDir, %DM_templatesDir%
}
if(InStr(DM_shortcutDir,":")==0){
    DM_shortcutDir := a_workingdir . "\" DM_shortcutDir
}
if(DM_shortcutDir==""){
    DM_shortcutDir:="shortcut"
}
ifnotexist % DM_shortcutDir
{
    FileCreateDir, %DM_shortcutDir%
}

DM_lsection := "DMLang"
IniRead, DM_MenuIOpenFile          , %DM_iniFilename%, %DM_lsection%, MenuIOpenFile         , 打开
IniRead, DM_MenuIEditFile          , %DM_iniFilename%, %DM_lsection%, MenuIEditFile         , 编辑
IniRead, DM_MenuIOpenFileDir       , %DM_iniFilename%, %DM_lsection%, MenuIOpenFileDir      , 打开所在位置
IniRead, DM_MenuIGitShell          , %DM_iniFilename%, %DM_lsection%, MenuIGitShell         , Git shell
IniRead, DM_MenuICMD               , %DM_iniFilename%, %DM_lsection%, MenuICMD              , 命令行
IniRead, DM_MenuIProperties        , %DM_iniFilename%, %DM_lsection%, MenuIProperties       , 属性
IniRead, DM_MenuIClearRows         , %DM_iniFilename%, %DM_lsection%, MenuIClearRows        , 移除
IniRead, DM_MenuICompress          , %DM_iniFilename%, %DM_lsection%, MenuICompress         , 压缩
IniRead, DM_MenuIDecompress        , %DM_iniFilename%, %DM_lsection%, MenuIDecompress       , 解压缩
IniRead, DM_MenuIDelete            , %DM_iniFilename%, %DM_lsection%, MenuIDelete           , 删除
IniRead, DM_MenuIAdd               , %DM_iniFilename%, %DM_lsection%, MenuIAdd              , 添加
IniRead, DM_MenuIDeleteAll         , %DM_iniFilename%, %DM_lsection%, MenuIDeleteAll        , 清空
IniRead, DM_MenuIRename            , %DM_iniFilename%, %DM_lsection%, MenuIRename           , 重命名
IniRead, DM_MenuICopy              , %DM_iniFilename%, %DM_lsection%, MenuICopy             , 复制
IniRead, DM_MenuICut               , %DM_iniFilename%, %DM_lsection%, MenuICut              , 剪切
IniRead, DM_MenuIPaste             , %DM_iniFilename%, %DM_lsection%, MenuIPaste            , 粘贴
IniRead, DM_MenuICreateShortcut    , %DM_iniFilename%, %DM_lsection%, MenuICreateShortcut   , 创建快捷方式
IniRead, DM_MenuISystemContextMenu , %DM_iniFilename%, %DM_lsection%, MenuISystemContextMenu, 系统菜单
IniRead, DM_MenuICreateFolder      , %DM_iniFilename%, %DM_lsection%, MenuICreateFolder     , 新建文件夹
IniRead, DM_MenuINew               , %DM_iniFilename%, %DM_lsection%, MenuINew              , 新建
IniRead, DM_MenuIRefresh           , %DM_iniFilename%, %DM_lsection%, MenuIRefresh          , 刷新
IniRead, DM_btnLoadFolderTip       , %DM_iniFilename%, %DM_lsection%, btnLoadFolderTip      , 加载文件夹
IniRead, DM_btnClearTip            , %DM_iniFilename%, %DM_lsection%, btnClearTip           , 清空
IniRead, DM_btnSwitchViewTip       , %DM_iniFilename%, %DM_lsection%, btnSwitchViewTip      , 切换视图
IniRead, DM_btnRefreshTip          , %DM_iniFilename%, %DM_lsection%, btnRefreshTip         , 刷新
IniRead, DM_btnMoveTip             , %DM_iniFilename%, %DM_lsection%, btnMoveTip            , 移动
IniRead, DM_btnCloseTip            , %DM_iniFilename%, %DM_lsection%, btnCloseTip           , 退出
IniRead, DM_btnHomeTip            , %DM_iniFilename%, %DM_lsection%, btnHomeTip           , 主界面
IniRead, DM_btnSoftTip            , %DM_iniFilename%, %DM_lsection%, btnSoftTip           , 常用软件
IniRead, DM_btnFileTip            , %DM_iniFilename%, %DM_lsection%, btnFileTip           , 常用文件

;================================
; read config file end
;================================

;================================
; initial variables start
;================================

DM_MinWinW:=520
DM_MinWinH:=118
; 加载文件
; 计算 SHFILEINFO 结构需要的缓存大小.
sfi_size := A_PtrSize + 8 + (A_IsUnicode ? 680 : 340)
VarSetCapacity(sfi, sfi_size)

BeforRemoveToolTip=
; 图片目录
DM_img     := "img"
; 对于在本程序界面中的操作，不需要监控程序监控后进行常规操作,直接在listview操作即可
isDMCreateFile := false
isDMRenameFile := false

; 主界面，常用软件，常用文件
isDMHome := true
isShowExt:= true
isfirstStart:= true
isDMSoft := false
isDMFile := false

; 上方的按钮默认隐藏，鼠标移动到窗口上方显示。
; 如果是按f12显示的话，鼠标移动不会改变按钮隐藏或显示
DM_btnIsAlwaysShow := DM_btnIsShow := false

LVM_SETEXTENDEDLISTVIEWSTYLE  := 0x1036
LVM_SETHOVERTIME              := 0x1047
LVS_EX_TRACKSELECT            := 0x00000008

LVM_EDITLABELA := 0x1017
LVM_EDITLABELW := 0x1076
LVM_EDITLABEL := A_IsUnicode ? LVM_EDITLABELW : LVM_EDITLABELA

DM_SoftShortcutDir := DM_shortcutDir . "\software"
DM_FileShortcutDir := DM_shortcutDir . "\file"
ifnotexist % DM_SoftShortcutDir
    FileCreateDir % DM_SoftShortcutDir
ifnotexist % DM_FileShortcutDir
    FileCreateDir % DM_FileShortcutDir
;================================
; initial variables end
;================================

Gui, DMMain:New
Gui, DMMain:Color, %DM_bgColor%, %DM_bgColor%
Gui, DMMain:Font, c%DM_fontC%, Arial

Gui, DMMain:+ToolWindow +HwndhDesktopManager +MinSize%DM_sizeW%x%DM_sizeH% ;+LastFound    ; +ToolWindow 避免显示任务栏按钮和 alt-tab 菜单项.
Gui, DMMain:-Caption -Border
; #ifwinactive 不支持变量 %
GroupAdd, f12group, ahk_id %hDesktopManager%
; 允许用户最大化窗口或拖动来改变窗口的大小:
; 加了会显示边框
; Gui +Resize

; 创建一些按钮:
addPicButton("DM_btnLoadFolder",DM_img . "\folder", ,"x+5",DM_btnLoadFolderTip)
addPicButton("DM_btnClear",DM_img . "\clear", ,"x+10",DM_btnClearTip)
addPicButton("DM_btnSwitchView",DM_img . "\switch", ,"x+10",DM_btnSwitchViewTip)
Gui, DMMain:Add, Edit, x+10 w120 vDM_CheckText gDM_CheckText cFF2211
addPicButton("DM_btnRefresh",DM_img . "\refresh", ,"x+10",DM_btnRefreshTip)
addPicButton("DM_btnMove",DM_img . "\move", ,"x+10",DM_btnMoveTip)
addPicButton("DM_btnHome",DM_img . "\home", ,"x+10",DM_btnHomeTip)
addPicButton("DM_btnSoft",DM_img . "\soft", ,"x+10",DM_btnSoftTip)
addPicButton("DM_btnFile",DM_img . "\file", ,"x+10",DM_btnFileTip)
addPicButton("DM_btnClose",DM_img . "\quit", ,"x+10",DM_btnCloseTip)

; 创建 ListView 及其列:
Gui, DMMain:Add, ListView, xm r10 w%DM_sizeW% vDM_ListView gDM_ListView HWNDhDM_ListView +Icon -readonly AltSubmit, Name|In Folder|Size (KB)|Type
LV_ModifyCol(3, "Integer")  ; 为了排序, 表示 Size 列中的内容是整数.

; 创建图像列表, 这样 ListView 才可以显示图标:
DM_ImageListID1 := IL_Create(10)
DM_ImageListID2 := IL_Create(10, 10, true)  ; 大图标列表和小图标列表.

; 关联图像列表到 ListView, 然而它就可以显示图标了:
LV_SetImageList(DM_ImageListID1)
LV_SetImageList(DM_ImageListID2)

; 创建作为上下文菜单的弹出菜单:
Menu, DM_ContextMenu, Add, % DM_MenuIOpenFile, DM_OpenFile
Menu, DM_ContextMenu, Add, % DM_MenuIEditFile, DM_EditFile
Menu, DM_ContextMenu, Add, % DM_MenuIOpenFileDir, DM_OpenFileDir
if(DM_compressCmd!="")
    Menu, DM_ContextMenu, Add, % DM_MenuICompress, DM_Compress
if(DM_decompressCmd!="")
    Menu, DM_ContextMenu, Add, % DM_MenuIDecompress, DM_Decompress
if(DM_gitCmd!="")
    Menu, DM_ContextMenu, Add, % DM_MenuIGitShell, DM_GitShell
if(DM_cmdCmd!="")
    Menu, DM_ContextMenu, Add, % DM_MenuICMD, DM_CMD
Menu, DM_ContextMenu, Add, 
Menu, DM_ContextMenu, Add, % DM_MenuICopy, DM_Copy
Menu, DM_ContextMenu, Add, % DM_MenuICut, DM_Cut
Menu, DM_ContextMenu, Add, 
Menu, DM_ContextMenu, Add, % DM_MenuICreateShortcut, DM_CreateShortcut
Menu, DM_ContextMenu, Add, % DM_MenuIRename, DM_Rename
Menu, DM_ContextMenu, Add, % DM_MenuIClearRows, DM_ClearRows
Menu, DM_ContextMenu, Add, % DM_MenuIDelete, DM_Delete
Menu, DM_ContextMenu, Add, 
Menu, DM_ContextMenu, Add, % DM_MenuIProperties, DM_Properties
Menu, DM_ContextMenu, Default, % DM_MenuIOpenFile ; 让 "打开" 粗体显示表示双击时会执行相同的操作.
Menu, DM_ContextMenu, Add, % DM_MenuISystemContextMenu, DM_SystemContextMenu

; 在其他位置点右键
Menu, DM_ContextMenuNewFile, Add, % DM_MenuICreateFolder, DM_CreateFolder
Menu, DM_ContextMenuNewFile, Add, 
DM_templates := Object()
Loop %DM_templatesDir%\* ,1  ;获取目录下文件和文件夹，默认为0仅获取文件。
{
    SplitPath, A_LoopFileFullPath, , , , DM_filename_no_ext
    DM_templates[DM_filename_no_ext] := A_LoopFileFullPath
    Menu, DM_ContextMenuNewFile, Add, % DM_filename_no_ext, DM_newFiles
}

Menu, DM_ContextMenu0, Add, % DM_MenuIRefresh, DM_menuRefresh
Menu, DM_ContextMenu0, Add, % DM_MenuIPaste, DM_Paste
Menu, DM_ContextMenu0, Add, % DM_MenuINew, :DM_ContextMenuNewFile
Menu, DM_ContextMenu0, Add, % DM_MenuISystemContextMenu, DM_SystemContextMenu


Menu, DM_ContextMenu1, Add, % DM_MenuIOpenFile, DM_OpenFile
Menu, DM_ContextMenu1, Add, % DM_MenuIOpenFileDir, DM_OpenFileDir
if(DM_cmdCmd!="")
    Menu, DM_ContextMenu1, Add, % DM_MenuICMD, DM_CMD
Menu, DM_ContextMenu1, Add, 
Menu, DM_ContextMenu1, Add, % DM_MenuIRename, DM_Rename
Menu, DM_ContextMenu1, Add, % DM_MenuIClearRows, DM_ClearRows
Menu, DM_ContextMenu1, Add, % DM_MenuIDelete, DM_Delete
Menu, DM_ContextMenu1, Add, % DM_MenuIAdd, DM_AddShortcut
Menu, DM_ContextMenu1, Add, 
Menu, DM_ContextMenu1, Add, % DM_MenuIProperties, DM_Properties
Menu, DM_ContextMenu1, Add, % DM_MenuISystemContextMenu, DM_SystemContextMenu

Menu, DM_ContextMenu2, Add, % DM_MenuIAdd, DM_AddShortcut
Menu, DM_ContextMenu2, Add, % DM_MenuIDeleteAll, DM_DeleteAll
; 设置背景图片
/*
; Show the Gui, but make it invisible to retrieve the dimensions
Gui, Show, Hide
DetectHiddenWIndows, On	;necessary
WinGetPos,,, GuiWidth, GuiHeight, ahk_id %hDesktopManager%
WinGet, ControlListHwnd , ControlListHwnd, ahk_id %hDesktopManager%

; Add the picture with the retrieved dimensions.
Gui, Add, Picture, x0 y0 W%GuiWidth% H%GuiHeight% hwndhWndPicControl, bg.png
*/

Gui, DMMain:Show, Hide

; 鼠标移动
OnMessage(0x200, "DM_WM_MOUSEMOVE") 
; 设置透明和钉在桌面冲突
; http://ahk.haotui.com/viewthread.php?tid=4532
; WinSet, TransColor, %DM_bgColor% 150, ahk_id %hDesktopManager%
; WinSet, Transparent, 150, ahk_id %hDesktopManager%

; 可以有gui color的第二个颜色指定
; GuiControl +Backgroundblack, DM_ListView 
; 钉在桌面上
ControlGet,DM_id,hwnd,,SHELLDLL_DefView1,ahk_class Progman
if DM_id=   ;如果用户设定的是动态桌面
{
    ControlGet,DM_id,hwnd,,SHELLDLL_DefView1,ahk_class WorkerW
}
ControlGet,DM_DesktopID,hwnd,,SysListView321,ahk_id %DM_id%
DllCall( "SetParent", UInt, hDesktopManager, UInt, DM_DesktopID)

; 显示窗口并返回. 当用户执行预期的动作时
; 操作系统会通知脚本:
Gui, DMMain:Show, % "W" . DM_sizeW . "H" . DM_sizeH . "X" . DM_X . "Y" . DM_Y

; 隐藏顶部按钮
DM_ToggleButton(DM_btnIsShow)
; 圆角
; WinSet, Region, 0-0 W%DM_sizeW% H%DM_sizeH% R40-40, ahk_id %hDesktopManager%
; gosub LoadFile
gosub DM_btnHome
onexit, ExitSub
return

ExitSub:
WinGetPos, DM_X, DM_Y, DM_sizeW, DM_sizeH, ahk_id %hDesktopManager%
IniWrite, %DM_X%, %DM_iniFilename%, %DM_gsection%, WinX
IniWrite, %DM_Y%, %DM_iniFilename%, %DM_gsection%, WinY
IniWrite, %DM_sizeW%, %DM_iniFilename%, %DM_gsection%, sizeW 
IniWrite, %DM_sizeH%, %DM_iniFilename%, %DM_gsection%, sizeH
ExitApp

DM_AddShortcut:
;================================
; 添加快捷方式窗口 start
;================================
Gui, gShortcut:New
Gui, gShortcut:-Resize +ToolWindow
Gui, gShortcut:Add, ListBox, x22 y20 w340 h310 Multi AltSubmit vDM_ListBox hwndhDM_ListBox, 
Gui, gShortcut:Add, CheckBox, x22 y340 w120 h20 gDM_SCisAll vDM_isAll, All/Deselect All
Gui, gShortcut:Add, Button, x152 y340 w60 h20 gDM_SCAddFile, Add File
Gui, gShortcut:Add, Button, x222 y340 w60 h20 gDM_SCAddFolder vDM_AddFolder, Add Dir.
Gui, gShortcut:Add, Button, x292 y340 w60 h20 gDM_SCAddOK, OK
;================================
; 添加快捷方式窗口 end
;================================
ListBoxItems := 
ShortcutPaths :=
ShortcutPaths := Object()
Shortcutcount:=0
if(isDMSoft){
    ; 当前用户的程序文件夹
    Loop, %a_programs%\*.lnk, , 1  ; 递归子文件夹.
    {
        if A_LoopFileName contains Uninstall,Update,卸载,升级,注册,帮助,Help
            continue

        FileGetShortcut, %A_LoopFileFullPath%, OutTarget ;, OutDir, OutArgs, OutDesc, OutIcon, OutIconNum, OutRunState
        SplitPath , OutTarget, , , ext
        if (ext != "exe") 
            continue

        SplitPath , A_LoopFileFullPath,,,,filename_no_ext
        ListBoxItems .= filename_no_ext . "|"
        ShortcutPaths[++Shortcutcount] := A_LoopFileFullPath
        ; IfExist % OutTarget
            ; fileappend, "%OutTarget%"`,"%filename_no_ext%"`,"%outicon%"`,"%outiconnum%"`,"%OutArgs%"`n, software.txt
    }
    ; 公共的程序文件夹
    Loop, %a_programscommon%\*.lnk, , 1  ; 递归子文件夹.
    {
        if A_LoopFileName contains Uninstall,Update,卸载,升级,注册,帮助,Help
            continue

        FileGetShortcut, %A_LoopFileFullPath%, OutTarget ;, OutDir, OutArgs, OutDesc, OutIcon, OutIconNum, OutRunState
        SplitPath , OutTarget, , , ext
        if (ext != "exe") 
            continue

        SplitPath , A_LoopFileFullPath,,,,filename_no_ext
        ;; 公共和用户可能有重复的程序
        if(InStr(ListBoxItems,filename_no_ext))
            continue
        ListBoxItems .= filename_no_ext . "|"
        ShortcutPaths[++Shortcutcount] := A_LoopFileFullPath
        ; IfExist % OutTarget
            ; fileappend, "%OutTarget%"`,"%filename_no_ext%"`,"%outicon%"`,"%outiconnum%"`,"%OutArgs%"`n, software.txt
    }
    GuiControl, gShortcut:-Redraw, DM_ListBox
    GuiControl, gShortcut:, DM_ListBox, % ListBoxitems
    GuiControl, gShortcut:+Redraw, DM_ListBox

    GuiControl, gShortcut:Disable, DM_AddFolder
} else if(isDMFile){
    GuiControl, gShortcut:Enable, DM_AddFolder
}
initShortcutCount:=Shortcutcount
Gui, gShortcut:Show, w390 h386, 选择添加的项目
return

DM_SCisAll:
Gui ,gShortcut:+LastFound  ; 让后面不需要指定 WinTitle.
Gui, gShortcut:Submit,NoHide
if(DM_isAll==1){
    PostMessage, 0x185, 1, -1, , % "ahk_id " . hDM_ListBox  ; 选择所有项目. 0x185 is LB_SETSEL.
}else{
    PostMessage, 0x185, 0, -1, , % "ahk_id " . hDM_ListBox  ; 取消选择所有项目.
}
return

DM_SCAddFolder:
Gui gShortcut:+OwnDialogs  ; 强制用户解除此对话框后才可以操作主窗口.
FileSelectFolder, SelectedFolder,, 3, 添加目录
if( SelectedFolder == ""){ ; 用户取消了对话框.
    ; myToolTip("没有选择目录")
    return
}
ShortcutPaths[++Shortcutcount]:=SelectedFolder
SplitPath,SelectedFolder,,,,FileNameNoExt
GuiControl, gShortcut:, DM_ListBox, %FileNameNoExt%||
Return

DM_SCAddFile:
Gui gShortcut:+OwnDialogs  ; 强制用户解除此对话框后才可以操作主窗口.
if(isDMSoft){
    FileSelectFile, SelectedFile,  M11, , 选择文件, Executable Files(*.exe)
} else if(isDMFile){
    FileSelectFile, SelectedFile,  M11, , 选择文件
}
if( SelectedFile == ""){ ; 用户取消了对话框.
    ; myToolTip("没有选择目录")
    return
}
SelectedFileDir:=
SelectedFiles:=
Loop, parse, SelectedFile, `n
{
    ; 文件存在的文件夹
    if a_index = 1
        SelectedFileDir:=A_LoopField
    else
    {
        FileFullName:=SelectedFileDir . "\" . A_LoopField
        ShortcutPaths[++Shortcutcount]:=FileFullName
        SplitPath,FileFullName,,,,FileNameNoExt
        SelectedFiles .= FileNameNoExt . "||"
    }
}
GuiControl, gShortcut:, DM_ListBox, % SelectedFiles
return

DM_SCAddOK:
Gui, gShortcut:Submit,NoHide
Loop, parse, DM_ListBox, |
{
    if(A_LoopField>initShortcutCount){
        createShortcut(ShortcutPaths[A_LoopField],curShortcutDir)
    } else {
        fileOrFolderCopy(ShortcutPaths[A_LoopField],curShortcutDir)
    }
}
return

gShortcutGuiClose:
Gui, gShortcut:Destroy
Return

DM_DeleteAll:
FileRecycle, % curShortcutDir . "\*"
return

DM_btnLoadFolder:
if(!DM_buttons["DM_btnLoadFolder"]["enable"])
    return
Gui DMMain:+OwnDialogs  ; 强制用户解除此对话框后才可以操作主窗口.
DM_temp:=DM_Folder
FileSelectFolder, DM_Folder,, 3, 选择目录加载
if not DM_Folder  ; 用户取消了对话框.
{
    DM_Folder:=DM_temp
    return
}
gosub DM_btnRefresh
Return

LoadFile:
Gui, DMMain:Default
; 检查文件夹名称的最后一个字符是否为反斜线, 对于根目录则会如此,
; 例如 C:\. 如果是, 则移除这个反斜线以避免之后出现两个反斜线.
StringRight, LastChar, DM_Folder, 1
if LastChar = \
    StringTrimRight, DM_Folder, DM_Folder, 1  ; 移除尾随的反斜线.

; 获取所选择文件夹中的文件名列表并添加到 ListView:
GuiControl, DMMain:-Redraw, DM_ListView  ; 在加载时禁用重绘来提升性能.
Loop %DM_Folder%\%DM_CheckText%* ,1  ;获取DM_Folder下文件和文件夹，默认为0仅获取文件。
{
    if A_LoopFileAttrib contains H,R,S  ; 跳过具有 H (隐藏), R (只读) 或 S (系统) 属性的任何文件. 注意: 在 "H,R,S" 中不含空格.
        continue  ; 跳过这个文件并前进到下一个.
    DM_addFile(A_LoopFileFullPath, isShowExt,A_LoopFileName,A_LoopFileDir,A_LoopFileSizeKB)
}
GuiControl, DMMain:+Redraw, DM_ListView  ; 重新启用重绘 (上面把它禁用了).
LV_ModifyCol()  ; 根据内容自动调整每列的大小.
LV_ModifyCol(3, 60) ; 把 Size 列加宽一些以便显示出它的标题.
; 监视目录变化
; www.autohotkey.com/board/topic/60125-ahk-lv2-watchdirectory-report-directory-changes/
WatchDirectory("")
WatchDirectory(DM_Folder,"ReportChanges")
return

LoadShortCut:
; dm_addfile函数有对listview操作 所以需要设置为default
Gui, DMMain:Default
if(isDMSoft){
    curShortcutDir := DM_SoftShortcutDir
} else {
    curShortcutDir := DM_FileShortcutDir
}
; 监视目录变化
WatchDirectory("")
WatchDirectory(curShortcutDir,"ReportChanges")
; 获取所选择文件夹中的文件名列表并添加到 ListView:
GuiControl, DMMain:-Redraw, DM_ListView  ; 在加载时禁用重绘来提升性能.
Loop %curShortcutDir%\%DM_CheckText%*.lnk ,0  ;获取文件0仅获取文件。
{
    if A_LoopFileAttrib contains H,R,S  ; 跳过具有 H (隐藏), R (只读) 或 S (系统) 属性的任何文件. 注意: 在 "H,R,S" 中不含空格.
        continue  ; 跳过这个文件并前进到下一个.
    DM_addFile(A_LoopFileFullPath, isShowExt,A_LoopFileName,A_LoopFileDir,A_LoopFileSizeKB)
}
GuiControl, DMMain:+Redraw, DM_ListView  ; 重新启用重绘 (上面把它禁用了).
return

DM_btnClear:
LV_Delete()  ; 清理 ListView, 但为了简化保留了图标缓存.
return

DM_menuRefresh:
Gui, DMMain: Default
DM_btnRefresh:
LV_Delete()  ; 清理 ListView, 但为了简化保留了图标缓存.
if(isDMHome)
    gosub LoadFile
else
    gosub LoadShortCut
return

DM_btnHome:
if(!isDMHome||isfirstStart){
    isDMHome:=true
    isDMSoft:=false
    isDMFile:=false
    isShowExt:=true
    LV_Delete()
    gosub LoadFile
    enablePicButton("DM_btnSwitchView",true,DM_btnSwitchViewTip)
    enablePicButton("DM_btnLoadFolder",true,DM_btnLoadFolderTip)
}
if(isfirstStart==true)
    isfirstStart := false
Return

DM_btnSoft:
if(!isDMSoft){
    isDMHome:=false
    isDMSoft:=true
    isDMFile:=false
    isShowExt:=False
    LV_Delete()
    gosub LoadShortCut
    enablePicButton("DM_btnSwitchView",false)
    enablePicButton("DM_btnLoadFolder",False)
}
return

DM_btnFile:
if(!isDMFile){
    isDMHome:=false
    isDMSoft:=false
    isDMFile:=true
    isShowExt:=False
    LV_Delete()
    gosub LoadShortCut
    enablePicButton("DM_btnSwitchView",false)
    enablePicButton("DM_btnLoadFolder",False)
}
return

DM_btnMove:
; 移动窗口
PostMessage, 0xA1, 2
return

DM_btnSwitchView:
if(DM_buttons[A_ThisLabel]["enable"]){
if (!DM_isIconView){
    GuiControl, DMMain:+Icon, DM_ListView    ; 切换到图标视图.
} else {
    GuiControl, DMMain:+Report, DM_ListView  ; 切换回详细信息视图.
    LV_ModifyCol()  ; 根据内容自动调整每列的大小.
    LV_ModifyCol(3, 60) ; 把 Size 列加宽一些以便显示出它的标题.
}
DM_isIconView := !DM_isIconView             ; 进行反转以为下次做准备.
}
return

DM_ListView:
; NOTE:这个标签不用指定默认的gui?
; GUI 线程 是由 GUI 动作启动的. GUI 动作包括从 GUI 窗口的 菜单栏 中选择一个项目或触发其某个 g 标签 (例如按下按钮).
; Source: <mk:@MSITStore:D:\PortableApps\AutoHotkey\AutoHotkey.chm::/docs/commands/Gui.htm>
; 所以界面中的g标签不用再指定default，右键菜单不算gui的一部分。其它有listview函数的地方需要设置default gui
; Gui, DMMain:Default
if (A_GuiEvent == "DoubleClick"){  ; 脚本还可以检查许多其他的可能值.
    SelectedRowNumber := LV_GetNext(0)  ; 查找选中的行.
    if(SelectedRowNumber != 0){ ;有被选中的
        LV_GetText(DM_FileName, A_EventInfo, 1) ; 从首个字段中获取文本.
        LV_GetText(DM_FileDir, A_EventInfo, 2)  ; 从第二个字段中获取文本.
        if(isShowExt)
            Run %DM_FileDir%\%DM_FileName%,, UseErrorLevel
        else{
            LV_GetText(DM_FileExt, A_EventInfo, 4)  ; 从第4个字段中获取文本.
            Run %DM_FileDir%\%DM_FileName%.%DM_FileExt%,, UseErrorLevel
        }
        if ErrorLevel
            MsgBox Could not open "%DM_FileDir%\%DM_FileName%".
    }
} else if (A_GuiEvent == "E") { ; 开始编辑
    LV_GetText(DM_OldFileName, A_EventInfo, 1) ; 从首个字段中获取文本.
} else if (A_GuiEvent == "e") { ; 完成编辑
    LV_GetText(DM_FileName, A_EventInfo, 1) ; 从首个字段中获取文本.
    LV_GetText(DM_FileDir, A_EventInfo, 2)  ; 从第二个字段中获取文本.
    if(isShowExt)
        res := fileOrFolderRename(DM_FileDir . "\" . DM_OldFileName,DM_FileName)
    else{
        LV_GetText(DM_FileExt, A_EventInfo, 4)  ; 从第4个字段中获取文本.
        res := fileOrFolderRename(DM_FileDir . "\" . DM_OldFileName . "." . DM_FileExt,DM_FileName . "." . DM_FileExt)
    }
    if(res == false){
        LV_Modify(A_EventInfo, , DM_OldFileName)
    }
    isDMRenameFile := true
    ; gosub DM_btnRefresh
} else If (A_GuiEvent == "D" && isDMHome) {      ; 拖拽事件
    DragItems:=
    DragItems:=Object()
    RowNumber := 0
    count:=0
    Loop
    {
        RowNumber := LV_GetNext(RowNumber)  ; 在前一次找到的位置后继续搜索.
        if not RowNumber  ; 上面返回零, 所以选择的行已经都找到了.
            break
        LV_GetText(Text, RowNumber)
        DragItems[A_Index]:=Text
        count:=A_Index
    }
    DragTip:=count . " file" . (count>1?"s":"")
    ; Set list-view ex-style LVS_EX_TRACKSELECT on the target control
    SendMessage, LVM_SETEXTENDEDLISTVIEWSTYLE, LVS_EX_TRACKSELECT, LVS_EX_TRACKSELECT, , ahk_id %hDM_ListView%
    ; Set hover time to 10 ms
    SendMessage, LVM_SETHOVERTIME, 0, 10, , ahk_id %hDM_ListView% ; Set hovertime to 10 ms
    SetTimer, DDToolTip, 25
    KeyWait, LButton
    ; Remove list-view ex-style LVS_EX_TRACKSELECT
    SendMessage, LVM_SETEXTENDEDLISTVIEWSTYLE, LVS_EX_TRACKSELECT, 0, , ahk_id %hDM_ListView%
    SetTimer, DDToolTip, off
    ToolTip
    RowNumber := 0
    RowNumber := LV_GetNext(RowNumber)  ; 在前一次找到的位置后继续搜索.
    LV_GetText(DM_FileName, RowNumber,1)
    LV_GetText(DM_FileDir, RowNumber,2)
    FileFullName:=DM_FileDir . "\" . DM_FileName
    Loop % count
    {
        if(DragItems[A_Index]==DM_FileName){
            DragItems:=
            Return
        }
    }
	if (InStr(FileExist(FileFullName),"D")){
        myToolTip("移动到" . FileFullName)
        Loop % count
        {
            fileOrFolderMove(DM_FileDir . "\" . DragItems[A_Index],FileFullName)
        }
    }
    DragItems:=
}
return

DDToolTip:
	ToolTip, %DragTip% ; Shows the dragged item next to the mousepointer
Return
Killtip:
	SetTimer, DDToolTip, Off
	ToolTip
return

DMMainGuiContextMenu:  ; 运行此标签来响应右键点击或按下 Appskey.
if (A_GuiControl != "DM_ListView")  ; 仅在 ListView 中点击时才显示菜单.
    return
FocusedRowNumber := LV_GetNext(0, "F")  ; 查找焦点行.
SelectedRowNumber := LV_GetNext(0)  ; 查找选中的行.
; 在提供的坐标处显示菜单, A_GuiX 和 A_GuiY.  应该使用这些
; 因为即使用户按下 Appskey 它们也会提供正确的坐标:
if(isDMHome){
    if(SelectedRowNumber != 0){ ;有被选中的
        LV_GetText(DM_ext, FocusedRowNumber,4)
        if(DM_decompressCmd!=""){
            if DM_ext in % DM_CompExtList 
                Menu, DM_ContextMenu, Enable, % DM_MenuIDecompress
            else
                Menu, DM_ContextMenu, Disable, % DM_MenuIDecompress
        }
        if DM_ext in % DM_EditExtList
            Menu, DM_ContextMenu, Enable, % DM_MenuIEditFile
        else
            Menu, DM_ContextMenu, Disable, % DM_MenuIEditFile
        Menu, DM_ContextMenu, Show, %A_GuiX%, %A_GuiY%
    } else {
        pid:=DllCall("GetCurrentProcessId","uint")
        hwnd:=WinExist("ahk_pid " . pid)
        if(DllCall("OpenClipboard","UPtr",hwnd)){
            ; 剪切板有文件
            if(DllCall("IsClipboardFormatAvailable","uint",0xF)){ ; 0xF = CF_HDROP
                Menu, DM_ContextMenu0, Enable, % DM_MenuIPaste
            } else{
                Menu, DM_ContextMenu0, Disable, % DM_MenuIPaste
            }
            DllCall("CloseClipboard")
        }
        Menu, DM_ContextMenu0, Show, %A_GuiX%, %A_GuiY%
    }
} else {
    if(SelectedRowNumber != 0){ ;有被选中的
        Menu, DM_ContextMenu1, Show, %A_GuiX%, %A_GuiY%
    }else{
        Menu, DM_ContextMenu2, Show, %A_GuiX%, %A_GuiY%
    }
}
return

DM_newFiles:
DM_fileFullPath := DM_templates[A_ThisMenuItem]
; 菜单中对应文件模板存在
If (FileExist(DM_fileFullPath)){
    SplitPath, DM_fileFullPath, , dir, ext 
    FormatTime, DM_fileName,, yyyy-MM-dd [HH.mm.ss]
    ; 如果扩展名为空，创建文件时windows会自动忽略最后的点号
    ; 为保险还是加了判断
    fileOrFolderCopy(DM_fileFullPath,DM_Folder, dm_filename . (ext==""?"":"." . ext))
    isDMCreateFile := true
}
Return

DM_paste:
InvokeVerb(DM_Folder, "Paste",False)
return

DM_CreateFolder:
FormatTime, DM_DirName,, yyyy-MM-dd [HH.mm.ss]
DM_newFolder := DM_Folder . "\" . DM_DirName
ifnotexist % DM_newFolder
{
    FileCreateDir, %DM_newFolder%
    isDMCreateFile := true
}
return

DM_OpenFile:  ; 用户在上下文菜单中选择了 "打开".
DM_EditFile:
DM_Properties:  ; 用户在上下文菜单中选择了 "属性".
DM_OpenFileDir:  ; 用户在上下文菜单中选择了 "打开所在位置".
DM_Rename:
DM_CreateShortcut:
DM_GitShell:
DM_CMD:
DM_Decompress:
Gui, DMMain:Default
; 解压文件，创建快捷方式会有对话框
Gui DMMain:+OwnDialogs  ; 强制用户解除此对话框后才可以操作主窗口.
; 为了简化, 仅对焦点行进行操作而不是所有选择的行:
FocusedRowNumber := LV_GetNext(0, "F")  ; 查找焦点行.
if (FocusedRowNumber==0)  ; 没有焦点行.
    return
LV_GetText(DM_FileName, FocusedRowNumber, 1) ; 获取首个字段的文本.
LV_GetText(DM_FileDir, FocusedRowNumber, 2)  ; 获取第二个字段的文本.
LV_GetText(DM_FileExt, FocusedRowNumber, 4)  ; 获取第4个字段的文本.
If (A_ThisMenuItem == DM_MenuIOpenFile){   ; 用户在上下文菜单中选择了 "打开".
    if(isShowExt)
        Run %DM_FileDir%\%DM_FileName%,, UseErrorLevel
    else
        Run %DM_FileDir%\%DM_FileName%.%DM_FileExt%,, UseErrorLevel
} else If (A_ThisMenuItem == DM_MenuIEditFile){   ; 用户在上下文菜单中选择了 "编辑".
    if DM_FileExt in % DM_EditExtList
    {
        FileFullName:=DM_FileDir . "\" . DM_FileName
        InvokeVerb(FileFullName, "Edit",False)
    }
/*
    if(isShowExt)
        FileFullName:=DM_FileDir . "\" . DM_FileName
    else{
        FileFullName:=DM_FileDir . "\" . DM_FileName . "." . DM_FileExt
    }
    SplitPath , FileFullName ,,,FileExt
    ; 如果是链接，获取链接到的文件
    if(FileExt=="lnk"){
        FileGetShortcut, FileFullName, targetFile
        FileFullName:=targetFile
        SplitPath , FileFullName ,,,FileExt
    }
    if FileExt in % EditFileExts
        InvokeVerb(FileFullName, "Edit",False)
*/
} else If (A_ThisMenuItem == DM_MenuIOpenFileDir)  ; 用户在上下文菜单中选择了 "打开位置".
    if(isDMHome)
        run Explorer /select`,%DM_FileDir%\%DM_FileName%,,UseErrorLevel
    else{
        FileGetShortcut, %DM_FileDir%\%DM_FileName%.%DM_FileExt%, OutTarget
        run Explorer /select`,%OutTarget%,,UseErrorLevel
    }
else If (A_ThisMenuItem == DM_MenuIProperties)   ; 用户在上下文菜单中选择了 "属性".
    if(isShowExt)
        Run Properties "%DM_FileDir%\%DM_FileName%",, UseErrorLevel
    else
        Run Properties "%DM_FileDir%\%DM_FileName%.%DM_FileExt%",, UseErrorLevel
else If (A_ThisMenuItem == DM_MenuIRename){   ; 用户在上下文菜单中选择了 "重命名".
    ; PostMessage, LVM_EDITLABEL, FocusedRowNumber-1, 0, SysListView321, % "ahk_id " . hDesktopManager
    ; 下面和上面是等效的
    PostMessage, LVM_EDITLABEL, FocusedRowNumber-1, 0, , % "ahk_id " . hDM_ListView
} else If (A_ThisMenuItem == DM_MenuICreateShortcut){   ; 用户在上下文菜单中选择了 "创建快捷方式".
    createShortcut(DM_FileDir . "\" . DM_FileName)
} else If (A_ThisMenuItem == DM_MenuIGitShell){   ; 用户在上下文菜单中选择了 "git shell".
    cmdHere(DM_gitCmd, DM_FileDir . "\" . DM_FileName)
} else If (A_ThisMenuItem == DM_MenuICMD){   ; 用户在上下文菜单中选择了 "命令行".
    if(isShowExt)
        cmdHere(DM_cmdCmd, DM_FileDir . "\" . DM_FileName)
    else{
        FileGetShortcut, %DM_FileDir%\%DM_FileName%.%DM_FileExt%, OutTarget
        cmdHere(DM_cmdCmd, OutTarget)
    }
} else If (A_ThisMenuItem == DM_MenuIDecompress){   ; 用户在上下文菜单中选择了 "解压缩".
    LV_GetText(DM_FileExt, FocusedRowNumber, 4)  ; 获取第二个字段的文本.
    if DM_FileExt in % DM_CompExtList
    {
        decompressFile(DM_decompressCmd, DM_FileDir . "\" . DM_FileName)
    }
}
if (ErrorLevel) {
    myToolTip("对" . DM_FileDir . "\" . DM_FileName . "执行命令失败")
}
return

DM_SystemContextMenu:
Gui, DMMain:Default
FocusedRowNumber := LV_GetNext(0, "F")  ; 查找焦点行.
SelectedRowNumber := LV_GetNext(0)  ; 查找选中的行.
if( FocusedRowNumber != 0){
    LV_GetText(DM_FileName, FocusedRowNumber, 1) ; 获取首个字段的文本.
    LV_GetText(DM_FileDir, FocusedRowNumber, 2)
}  ; 获取第二个字段的文本.
If (A_ThisMenuItem == DM_MenuISystemContextMenu){   ; 用户在上下文菜单中选择了 "系统菜单".
    if(isDMHome){
        if (SelectedRowNumber == 0) {
            ShellContextMenu(DM_Folder)
        } else {
            ShellContextMenu(DM_FileDir . "\" . DM_FileName)
        }
    } else {
        LV_GetText(DM_FileExt, FocusedRowNumber, 4)
        FileGetShortcut, %DM_FileDir%\%DM_FileName%.%DM_FileExt%, OutTarget
        ShellContextMenu(OutTarget)
    }
}
Return

DM_ClearRows:  ; 用户在上下文菜单中选择了 "Clear".
Gui, DMMain:Default
RowNumber = 0  ; 这会使得首次循环从顶部开始搜索.
Loop
{
    ; 由于删除了一行使得此行下面的所有行的行号都减小了,
    ; 所以把行号减 1, 这样搜索里包含的行号才会与之前找到的行号相一致
    ; (以防选择了相邻行):
    RowNumber := LV_GetNext(RowNumber - 1)
    if not RowNumber  ; 上面返回零, 所以没有更多选择的行了.
        break
    LV_Delete(RowNumber)  ; 从 ListView 中删除行.
}
return

DM_Copy:
DM_Cut:
Gui, DMMain:Default
RowNumber = 0  ; 这会使得首次循环从顶部开始搜索.
FileFullNames := ""
Loop
{
    ; 由于删除了一行使得此行下面的所有行的行号都减小了,
    ; 所以把行号减 1, 这样搜索里包含的行号才会与之前找到的行号相一致
    ; (以防选择了相邻行):
    RowNumber := LV_GetNext(RowNumber)
    if not RowNumber  ; 上面返回零, 所以没有更多选择的行了.
        break
    LV_GetText(DM_FileName, RowNumber, 1) ; 从首个字段中获取文本.
    LV_GetText(DM_FileDir, RowNumber, 2)  ; 从第二个字段中获取文本.
    FileFullNames .= DM_FileDir . "\" . DM_FileName . "`n"
}
StringTrimRight, FileFullNames, FileFullNames, 1
If (A_ThisMenuItem == DM_MenuICopy){   ; 用户在上下文菜单中选择了 "复制".
    FilesToClipboard(FileFullNames)
} else If (A_ThisMenuItem == DM_MenuICut){   ; 用户在上下文菜单中选择了 "剪切".
    FilesToClipboard(FileFullNames,1)
}
FileFullNames:=
Return

DM_Compress:
Gui, DMMain:Default
Gui DMMain:+OwnDialogs  ; 强制用户解除此对话框后才可以操作主窗口.
RowNumber = 0  ; 这会使得首次循环从顶部开始搜索.
FileFullNames := ""
DM_fileCount := 0
Loop
{
    ; 由于删除了一行使得此行下面的所有行的行号都减小了,
    ; 所以把行号减 1, 这样搜索里包含的行号才会与之前找到的行号相一致
    ; (以防选择了相邻行):
    RowNumber := LV_GetNext(RowNumber)
    if not RowNumber  ; 上面返回零, 所以没有更多选择的行了.
        break
    LV_GetText(DM_FileName, RowNumber, 1) ; 从首个字段中获取文本.
    LV_GetText(DM_FileDir, RowNumber, 2)  ; 从第二个字段中获取文本.
    FileFullNames .= """" . DM_FileDir . "\" . DM_FileName . """ "
    DM_fileCount++ 
}
; 去掉最后的空格
StringTrimRight, FileFullNames, FileFullNames, 1
If (A_ThisMenuItem == DM_MenuICompress){   ; 用户在上下文菜单中选择了 "压缩".
    comPressFiles(DM_compressCmd, FileFullNames,DM_fileCount)
}
FileFullNames :=
Return

DM_Delete:
Gui, DMMain:Default
RowNumber = 0  ; 这会使得首次循环从顶部开始搜索.
WatchDirectory("")
if(isDMHome){
    Loop
    {
        ; 由于删除了一行使得此行下面的所有行的行号都减小了,
        ; 所以把行号减 1, 这样搜索里包含的行号才会与之前找到的行号相一致
        ; (以防选择了相邻行):
        RowNumber := LV_GetNext(RowNumber)
        if not RowNumber  ; 上面返回零, 所以没有更多选择的行了.
            break
        LV_GetText(DM_FileName, RowNumber, 1) ; 从首个字段中获取文本.
        LV_GetText(DM_FileDir, RowNumber, 2)  ; 从第二个字段中获取文本.
        FileFullName := DM_FileDir . "\" . DM_FileName
        FileRecycle, %FileFullName%
        If (ErrorLevel == 1){
            ; myToolTip("无法删除")
            ; 跳出循环，否则获取 Rownumber 一直一样,会死循环
            break
        }
    }
    WatchDirectory(DM_Folder,"ReportChanges")
}else{
    Loop
    {
        ; 由于删除了一行使得此行下面的所有行的行号都减小了,
        ; 所以把行号减 1, 这样搜索里包含的行号才会与之前找到的行号相一致
        ; (以防选择了相邻行):
        RowNumber := LV_GetNext(RowNumber - 1)
        if not RowNumber  ; 上面返回零, 所以没有更多选择的行了.
            break
        LV_GetText(DM_FileName, RowNumber, 1) ; 从首个字段中获取文本.
        LV_GetText(DM_FileDir, RowNumber, 2)  ; 从第二个字段中获取文本.
        LV_GetText(DM_FileExt, RowNumber, 4)  ; 从第4个字段中获取文本.
        FileFullName := DM_FileDir . "\" . DM_FileName . "." . DM_FileExt
        FileRecycle, %FileFullName%
        If (ErrorLevel == 1){
            ; myToolTip("无法删除")
            ; 跳出循环，否则获取 Rownumber 一直一样,会死循环
            break
        }
    }
    WatchDirectory(curShortcutDir,"ReportChanges")
}
; 如果在删除过程中还有其它操作，需要刷新一次，以显示最新的文件
gosub DM_btnRefresh
Return

DMMainGuiSize:  ; 扩大或缩小 ListView 来响应用户对窗口大小的改变.
if A_EventInfo = 1  ; 窗口被最小化了.  无需进行操作.
    return
; 否则, 窗口的大小被调整过或被最大化了. 调整 ListView 的大小来适应.
GuiControl, DMMain:Move, DM_ListView, % "W" . (A_GuiWidth - 20) . " H" . (A_GuiHeight - 40)
return

DM_btnClose:
DMMainGuiClose:  ; 当窗口关闭时, 自动退出脚本:
ExitApp

DMMainGuiDropFiles:
if(A_GuiControl == "DM_ListView"){
    ; 在拖拽移动文件前，停止监视目录，否则界面会多出图标
    if(isDMHome){
        WatchDirectory("")
        Loop, parse, A_GuiEvent, `n
        {
            fileOrFolderMove(A_LoopField,DM_Folder)
            DM_addFile(A_LoopField,isShowExt)
        }
        WatchDirectory(DM_Folder,"ReportChanges")
    } else {
        WatchDirectory("")
        Loop, parse, A_GuiEvent, `n
        {
            SplitPath ,A_LoopField,,,,FileNameNoExt
            newPath:=curShortcutDir . "\" . FileNameNoExt . ".lnk"
            if(!FileExist(newPath)){
                FileCreateShortcut, %A_LoopField%, %newPath%
                DM_addFile(newPath,isShowExt)
            }
        }
        WatchDirectory(curShortcutDir,"ReportChanges")
    }
}
; 过程中还有其它操作，需要刷新一次，以显示最新的文件
gosub DM_btnRefresh
Return


; 根据实时输入显示文件或文件夹
DM_CheckText:
SetTimer %A_ThisLabel%,Off
Gui, DMMain:Submit, NoHide
LV_Delete() 
if(isDMHome)
    gosub, LoadFile
else
    gosub, LoadShortCut
return

; 双击桌面隐藏、显示桌面图标
; http://www.autohotkey.com/board/topic/38006-double-click-desktop-to-hide-icons/
~LButton::
 If ( A_PriorHotKey = A_ThisHotKey && A_TimeSincePriorHotkey < 400 ) {
   WinGetClass, Class, A
   If Class in Progman,WorkerW
   {
    var := (flag=0) ? "Show" : "Hide"
   ControlGet, SelectedCount, List, Count Selected, SysListView321, ahk_class  %Class%
    if(SelectedCount == 0){
        flag := !flag
        Control,%var%,, SysListView321, ahk_class Progman
        Control,%var%,, SysListView321, ahk_class WorkerW
    }
   }
}
Return

#ifwinactive ahk_group f12group
f12::
DM_btnIsShow := !DM_btnIsShow
DM_ToggleButton(DM_btnIsShow)
DM_btnIsAlwaysShow := DM_btnIsShow
Return

~LButton::
coordmode, mouse
MouseGetPos,DM_X1,DM_Y1, , Control_id ,2
if(Control_id != "")
    Return
; Get the initial window position and size.
WinGetPos,DM_WinX1,DM_WinY1,DM_WinW,DM_WinH,ahk_id %hDesktopManager%
; Define the window region the mouse is currently in.
; The four regions are Up and Left, Up and Right, Down and Left, Down and Right.
If (DM_X1 < DM_WinX1 + DM_WinW / 2)
   DM_WinLeft := 1
Else
   DM_WinLeft := -1
If (DM_Y1 < DM_WinY1 + DM_WinH / 2)
   DM_WinUp := 1
Else
   DM_WinUp := -1
Loop
{
    GetKeyState,DM_Button,LButton,P ; Break if button has been released.
    If DM_Button = U
    {
        gosub DM_menuRefresh
        break
    }
    MouseGetPos,DM_X2,DM_Y2 ; Get the current mouse position.
    ; Get the current window position and size.
    WinGetPos,DM_WinX1,DM_WinY1,DM_WinW,DM_WinH,ahk_id %hDesktopManager%
    DM_X2 -= DM_X1 ; Obtain an offset from the initial mouse position.
    DM_Y2 -= DM_Y1
    NewWinW:=DM_WinW  -     DM_WinLeft  *DM_X2
    NewWinH:=DM_WinH  -       DM_WinUp  *DM_Y2
    ; Then, act according to the defined region.
    if(NewWinH>DM_MinWinH&&NewWinW>DM_MinWinW) {
    WinMove,ahk_id %hDesktopManager%,, DM_WinX1 + (DM_WinLeft+1)/2*DM_X2  ; X of resized window
                            , DM_WinY1 +   (DM_WinUp+1)/2*DM_Y2  ; Y of resized window
                            , NewWinW  ; W of resized window
                            , NewWinH  ; H of resized window
    } else {
        ; myToolTip("已移动到最小")
    }
    DM_X1 := (DM_X2 + DM_X1) ; Reset the initial position for the next iteration.
    DM_Y1 := (DM_Y2 + DM_Y1)
}
Return
#IfWinActive

;清除提示
RemoveToolTip:
SetTimer, RemoveToolTip, Off
If (BeforRemoveToolTip<>"")
{
ToolTip,%BeforRemoveToolTip%
sleep,1000
BeforRemoveToolTip=
}
ToolTip
return

DM_ToggleButton(show){
    ; 和hwnd不同，如果关联变量则不需要%%包含，hwnd需要
    GuiControl, DMMain:show%show%, DM_btnLoadFolder
    GuiControl, DMMain:show%show%, DM_btnClear
    GuiControl, DMMain:show%show%, DM_btnSwitchView
    GuiControl, DMMain:show%show%, DM_CheckText
    GuiControl, DMMain:show%show%, DM_btnRefresh
    GuiControl, DMMain:show%show%, DM_btnMove
    GuiControl, DMMain:show%show%, DM_btnClose
    GuiControl, DMMain:show%show%, DM_btnHome
    GuiControl, DMMain:show%show%, DM_btnSoft
    GuiControl, DMMain:show%show%, DM_btnFile
}
; FUNCTION TO HANDLE BOTH TOOLTIP AND MOUSEOVER EVENT 
DM_WM_MOUSEMOVE() 
{ 
    global DM_buttons,DM_btnIsShow,DM_btnIsAlwaysShow,DM_isMouseActiveBtn
    static CurrControl, PrevControl
    CurrControl := A_GuiControl 

    ; f12切换显示的话就让它一直显示
    if(DM_isMouseActiveBtn && !DM_btnIsAlwaysShow){
        ; 鼠标移动到按钮位置是显示
        MouseGetPos, xpos, ypos 
        if((ypos < 40 && !DM_btnIsShow)||(ypos > 40 && DM_btnIsShow)){
            DM_btnIsShow := !DM_btnIsShow
            DM_ToggleButton(DM_btnIsShow)
        }
    }
    ; 上一个控件是图片按钮，则恢复正常
    If (StrLen(PrevControl) && DM_buttons.HasKey(PrevControl) && CurrControl != PrevControl) 
    { 
        ; 清空提示
        ToolTip
        GuiControl,DMMain:, % PrevControl, % DM_buttons[PrevControl]["picpre"] . "." . DM_buttons[PrevControl]["pictype"]
    }
    ; 当前控件是图片按钮，显示激活的图片,并显示提示
    If (StrLen(CurrControl) && DM_buttons.HasKey(CurrControl) && CurrControl != PrevControl) 
    { 
        ; The leading percent sign tell it to use an expression. 
        mytoolTip(DM_buttons[CurrControl]["tipinfo"])
        if(DM_buttons[CurrControl]["enable"])
            GuiControl,DMMain:, % CurrControl, % DM_buttons[CurrControl]["picpre"] . "_over." . DM_buttons[CurrControl]["pictype"] 
    } 
    PrevControl := CurrControl 
    return 
} 

addPicButton(label,picPrefix,picType="png",option="",tooltipInfo="", enable:=true)
{
	global
	local hwndget
	static buttonIndex=0
	buttonIndex++
	If(!isObject(DM_buttons))
	DM_buttons:=Object()
	Gui,DMMain:Add, Pic, % option . " hwndh" . label . " g" . label . " v" . label, % picPrefix . "." . picType
	DM_buttons[label,"pictype"] := picType
	DM_buttons[label,"picpre"]  := picPrefix
	DM_buttons[label,"label"]   := label
	DM_buttons[label,"enable"]   := enable
    DM_buttons[label,"tipinfo"] := tooltipInfo
	Return, buttonIndex
}

enablePicButton(label, enable:=true, tip="禁用"){
    global DM_buttons
    DM_buttons[label,"enable"] := enable
    DM_buttons[label,"tipinfo"] := tip
}
InvokeVerb(path, menu, validate=True) {
   ;by A_Samurai
   ;v 1.0.1 http://sites.google.com/site/ahkref/custom-functions/invokeverb
    objShell := ComObjCreate("Shell.Application")
    if InStr(FileExist(path), "D") || InStr(path, "::{") {
        objFolder := objShell.NameSpace(path)   
        objFolderItem := objFolder.Self
    } else {
        SplitPath, path, name, dir
        objFolder := objShell.NameSpace(dir)
        objFolderItem := objFolder.ParseName(name)
    }
    if validate {
        colVerbs := objFolderItem.Verbs   
        loop % colVerbs.Count {
            verb := colVerbs.Item(A_Index - 1)
            retMenu := verb.name
            retMenu := RegExReplace(retMenu, "\(&.*\)", "")
            ; StringReplace, retMenu, retMenu, &       
            if (retMenu == menu) {
                verb.DoIt
                Return True
            }
        }
        Return False
    } else {
        objFolderItem.InvokeVerbEx(Menu)
    }
}
; http://www.autohotkey.com/board/topic/23162-how-to-copy-a-file-to-the-clipboard/page-4
FilesToClipboard(PathToCopy,iscut=0,delim="`n",omit = "`r")
{
    FileCount:=0
    PathLength:=0

    ; Count files and total string length
    Loop,Parse,PathToCopy, % delim, % omit
    {
        FileCount++
        PathLength+=StrLen(A_LoopField)
    }

    pid:=DllCall("GetCurrentProcessId","uint")
    hwnd:=WinExist("ahk_pid " . pid)
    ; 0x42 = GMEM_MOVEABLE(0x2) | GMEM_ZEROINIT(0x40)
    hPath := DllCall("GlobalAlloc","uint",0x42,"uint",20 + (PathLength + FileCount + 1) * 2,"UPtr")
    pPath := DllCall("GlobalLock","UPtr",hPath)
    NumPut(20,pPath+0),pPath += 16 ; DROPFILES.pFiles = offset of file list
    NumPut(1,pPath+0),pPath += 4 ; fWide = 0 -->ANSI,fWide = 1 -->Unicode
    Offset:=0
    Loop,Parse,PathToCopy, % delim, % omit ; Rows are delimited by linefeeds (`r`n).
        offset += StrPut(A_LoopField,pPath+offset,StrLen(A_LoopField)+1,"UTF-16") * 2

    DllCall("GlobalUnlock","UPtr",hPath)
    DllCall("OpenClipboard","UPtr",hwnd)
    DllCall("EmptyClipboard")
    DllCall("SetClipboardData","uint",0xF,"UPtr",hPath) ; 0xF = CF_HDROP

    ; Write Preferred DropEffect structure to clipboard to switch between copy/cut operations
    ; 0x42 = GMEM_MOVEABLE(0x2) | GMEM_ZEROINIT(0x40)
    mem := DllCall("GlobalAlloc","uint",0x42,"uint",4,"UPtr")
    str := DllCall("GlobalLock","UPtr",mem)

    if (iscut==0)
        DllCall("RtlFillMemory","UPtr",str,"uint",1,"UChar",0x05)
    else if (iscut=1)
        DllCall("RtlFillMemory","UPtr",str,"uint",1,"UChar",0x02)
    else
    {
        DllCall("CloseClipboard")
        return
    }

    DllCall("GlobalUnlock","UPtr",mem)

    cfFormat := DllCall("RegisterClipboardFormat","Str","Preferred DropEffect")
    DllCall("SetClipboardData","uint",cfFormat,"UPtr",mem)
    DllCall("CloseClipboard")
    return
}


; 添加一个文件到列表，如果FileName为空，则在函数中获取后三个参数的值
DM_addFile(FileFullName,isShowExt:=true,FileName="", FileDir="", FileSizeKB="")
{
    global
    local FileExt,ExtID,IconNumber,ExtChar,hIcon,FileNameTmp,FileDirTmp

    ; 建立唯一的扩展 ID 以避免变量名中的非法字符,
    ; 例如破折号.  这种使用唯一 ID 的方法也会执行地更好,
    ; 因为在数组中查找项目不需要进行搜索循环.
    SplitPath, FileFullName,FileNameTmp,FileDirTmp, FileExt,FileNameNoExt  ; 获取文件扩展名.
    if (!StrLen(FileName)) {
        FileName   := FileNameTmp
    }
    if(!isShowExt){
        FileName := FileNameNoExt
    }
    if (!StrLen(FileDir)) {
        FileDir    := FileDirTmp
    }
    if (!StrLen(FileSizeKB)) {
        FileGetSize, FileSizeKB, FileFullName, K 
    }
    ; 如果是文件夹,显示folder
	if InStr(FileExist(FileFullName),"D"){
       	FileExt := "Folder"
	}
    if FileExt in EXE,ICO,ANI,CUR,LNK
    {
        ExtID := FileExt  ; 特殊 ID 作为占位符.
        IconNumber = 0  ; 进行标记这样每种类型就含有唯一的图标.
    }
    else  ; 其他的扩展名/文件类型, 计算它们的唯一 ID.
    {
        ExtID = 0  ; 进行初始化来处理比其他更短的扩展名.
        Loop 7     ; 限制扩展名为 7 个字符, 这样之后计算的结果才能存放到 64 位值.
        {
            StringMid, ExtChar, FileExt, A_Index, 1
            if not ExtChar  ; 没有更多字符了.
                break
            ; 把每个字符与不同的位位置进行运算来得到唯一 ID:
            ExtID := ExtID | (Asc(ExtChar) << (8 * (A_Index - 1)))
        }
        ; 检查此文件扩展名的图标是否已经在图像列表中. 如果是,
        ; 可以避免多次调用并极大提高性能,
        ; 尤其对于包含数以百计文件的文件夹而言:
        IconNumber := IconArray%ExtID%
    }
    if not IconNumber  ; 此扩展名还没有相应的图标, 所以进行加载.
    {
        ; 获取与此文件扩展名关联的高质量小图标:
        if not DllCall("Shell32\SHGetFileInfo" . (A_IsUnicode ? "W":"A"), "str", FileFullName
            , "uint", 0, "ptr", &sfi, "uint", sfi_size, "uint", 0x100)  ; 0x101 为 SHGFI_ICON+SHGFI_SMALLICON  0x100:{0x100:SHGFI_ICON} + {0x0:SHGFI_LARGEICON}
            IconNumber = 9999999  ; 把它设置到范围外来显示空图标.
        else ; 成功加载图标.
        {
            ; 从结构中提取 hIcon 成员:
            hIcon := NumGet(sfi, 0)
            ; 直接添加 HICON 到小图标和大图标列表.
            ; 下面加上 1 来把返回的索引从基于零转换到基于一:
            IconNumber := DllCall("ImageList_ReplaceIcon", "ptr", DM_ImageListID1, "int", -1, "ptr", hIcon) + 1
            DllCall("ImageList_ReplaceIcon", "ptr", DM_ImageListID2, "int", -1, "ptr", hIcon)
            ; 现在已经把它复制到图像列表, 所以应销毁原来的:
            DllCall("DestroyIcon", "ptr", hIcon)
            ; 缓存图标来节省内存并提升加载性能:
            IconArray%ExtID% := IconNumber
        }
    }


    ; 在 ListView 中创建新行并把它和上面的图标编号进行关联:
    Return LV_Add("Icon" . IconNumber, FileName, FileDir, FileSizeKB, FileExt)
}
; 复制文件夹或文件到 DestFolder 中
fileOrFolderCopy(FileFullPath,DestFolder,newName=""){
    Atrr:=FileExist(FileFullPath)
    if(Atrr == ""){
        myToolTip(FileFullPath . "不存在")
        Return false
    }

    ; 如果是文件夹
	if (InStr(Atrr,"D")){
        SplitPath, FileFullPath, FolderName
        ; 后面的一句需要加括号，否则会导致destfolder不输出
        FileCopyDir ,% FileFullPath, % DestFolder . "\" . (newName==""?FolderName:newName)
	} else {
        FileCopy,% FileFullPath, % DestFolder . "\" . newName
    }
    if (!ErrorLevel){
        ; myToolTip("复制" . FileFullPath . "到" . DestFolder)
        Return true
    } else {
        myToolTip("复制" . FileFullPath . "失败")
        Return false
    }
}
; 移动文件夹或文件到 DestFolder 中
fileOrFolderMove(FileFullPath,DestFolder,newName=""){
    Atrr:=FileExist(FileFullPath)
    if(Atrr == ""){
        myToolTip(FileFullPath . "不存在")
        Return false
    }

    ; 如果是文件夹
	if (InStr(Atrr,"D")){
        SplitPath, FileFullPath, FolderName
        FileMoveDir ,% FileFullPath, % DestFolder . "\" . (newName==""?FolderName:newName)
	} else {
        FileMove,% FileFullPath, % DestFolder . "\" . newName
    }
    if (!ErrorLevel){
        ; myToolTip("移动" . FileFullPath . "到" . DestFolder)
        Return true
    } else {
        myToolTip("移动" . FileFullPath . "失败")
        Return false
    }
}
; 以 newName 重命名文件夹或文件
fileOrFolderRename(FileFullPath,newName){
    Atrr:=FileExist(FileFullPath)
    if(Atrr == ""){
        myToolTip(FileFullPath . "不存在")
        return false
    }
    
    SplitPath, FileFullPath, FileName, FileDir
    if(FileName == newName)
        Return
    ; 如果是文件夹
	if (InStr(Atrr,"D")){
        FileMoveDir ,%FileFullPath%, %FileDir%\%newName%,R
	} else {
        FileMove ,%FileFullPath%, %FileDir%\%newName%
    }
    if (!ErrorLevel){
        ; myToolTip("重命名" . FileFullPath . "为" . FileDir . "\" . newName)
        Return true
    } else {
        myToolTip("重命名" . FileFullPath . "失败")
        Return false
    }
}

createShortcut(filefullName,targetDir=""){
    SplitPath,filefullname,,dir,,name_no_ext
    if(!FileExist(targetDir)){
        FileSelectFolder,targetDir,*%dir%,3,选择目录存放快捷方式`n %filefullname%
    }
    If (targetDir!=""){
        FileCreateShortcut,%filefullname%,%targetDir%\%name_no_ext%.lnk,%dir%,,,%filefullname%,,1,
    }
}

cmdHere(cmdPath,FileFullPath,isAdmin=false){
    Atrr:=FileExist(FileFullPath)
    if(Atrr == ""){
        myToolTip(FileFullPath . "不存在")
        Return false
    }
    
	if (InStr(Atrr,"D")){
        FileDir := FileFullPath
    } else {
        SplitPath, FileFullPath, , FileDir
    }
    if(isAdmin){
        run ,% "*RunAs " . cmdPath . " """ . FileDir . """" , , UseErrorLevel
    } else {
        run ,% cmdPath . " """ . FileDir . """" , , UseErrorLevel
    }
    if (ErrorLevel == "ERROR"){
        myToolTip("执行命令失败")
        Return false
    }
    Return true
}
; 压缩文件到用户选择的目录
; TODO:没有检验文件是否存在
comPressFiles(compressCmd,files,fileCount){
    ; 没有选中文件
    if(fileCount == 0){
        return
    }else if(fileCount == 1){
        ; 去掉之前加的引号
        filepath := SubStr(files,2,-1)
        SplitPath,filepath,filename
        SplitPath, filepath, , , , filename 
    } else {
        ; 当前时间
        FormatTime, filename,, yyyy-MM-dd [HH.mm.ss]
    }
    FileSelectFile, saveFile,  S27, % filename . ".zip", 保存压缩文件, Compress Files(*.zip)
    if( saveFile == ""){
        ; myToolTip("选择文件为空")
        Return false
    }
        
    run % compressCmd . " """ . saveFile . """ " . files , ,UseErrorLevel Hide
    if (ErrorLevel == "ERROR"){
        myToolTip("压缩" . saveFile . "失败")
        return false
    }
    return true
}
; 解压缩文件到用户选择的目录
; TODO:如果有密码呢
decomPressFile(decompressCmd,FileFullPath){
    Atrr:=FileExist(FileFullPath)
    if(Atrr == ""){
        myToolTip(FileFullPath . "不存在")
        Return false
    }
    SplitPath FileFullPath,,filedir
    FileSelectFolder, Folder,% "*" . filedir, 3, 选择解压目录
    if (Folder == ""){ ; 用户取消了对话框.
        ; myToolTip("没有选择目录")
        return false
    }
        
    run % decompressCmd . " """ . FileFullPath . """ -o" . Folder , ,UseErrorLevel Hide
    if (ErrorLevel == "ERROR" && Folder != filedir){
        myToolTip("解压缩" . FileFullPath . "失败")
        return false
    }
    return true
}
myToolTip(tipinfo, delayTime=2000){
    ToolTip % tipinfo
    SetTimer ,RemoveToolTip, % delayTime
}

ReportChanges(from,to){
    global hDM_ListView,LVM_EDITLABEL,isDMCreateFile,isDMRenameFile,isShowExt,hDesktopManager
    Gui, DMMain:Default
    if(from == "" && to != ""){
        ; 新增文件
        RowNumber := DM_addFile(to,isShowExt)
        if(isDMCreateFile){
            LV_Modify(RowNumber, "+Focus")
            PostMessage, LVM_EDITLABEL, RowNumber-1, 0, , % "ahk_id " . hDM_ListView
            isDMCreateFile := False
        }
    } else if(to == "" && from != ""){
        ; 删除文件
        if(isShowExt)
            SplitPath, from, oldfilename
        else
            SplitPath, from,,,, oldfilename
        RowNumber:=1
        Loop
        {
            ; 失败返回0
            if (!LV_GetText(firstColText, RowNumber))
                break
            if(oldfilename == firstColText) {
                break
            }
            RowNumber++
        }
        if(RowNumber!=0)
            LV_Delete(RowNumber)
        ; gosub DM_btnRefresh
    } else if(from != to){
        ; 重命名
        if(!isDMRenameFile){
            isDMRenameFile := False
            if(isShowExt){
                SplitPath, from, oldfilename
                SplitPath, to, newfilename
            }else{
                SplitPath, from,,,, oldfilename
                SplitPath, to,,,, newfilename
            }
            ; 983个文件 0 毫秒
            RowNumber:=1
            Loop
            {
                ; 失败返回0
                if (!LV_GetText(firstColText, RowNumber))
                    break
                if(oldfilename == firstColText) {
                    break
                }
                RowNumber++
            }
            LV_Modify(RowNumber, , newfilename)
            /*
            ; 983个文件重命名最后一个 234毫秒 即使第一个也耗时171毫秒，controlget比较耗时
            ControlGet, listNames, List, Col1, SysListView321, ahk_id %hDesktopManager% 
            RowNumber:= 0
            Loop, Parse, listNames , `n
            {
               if(oldfilename == A_LoopField) {
                    RowNumber := A_Index
                    break
               }
            }
            if(RowNumber != 0)
                LV_Modify(RowNumber, , newfilename)
            */
        }
        ; gosub DM_btnRefresh
    }
}
