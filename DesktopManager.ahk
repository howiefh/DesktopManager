#SingleInstance, force
#include include\WatchDirectory.ahk
; 下面是一个比此页面顶部附近那个更精巧的可运行脚本.
; 它显示用户文件夹中的文件, 且每个文件分配一个与其类型关联的图标.
; 用户在一个文件上双击或在一个或多个文件上右击后, 会显示上下文菜单.
DM_gitCmd:= """C:\Windows\system32\wscript"" ""D:\PortableApps\Git\Git Bash.vbs"" "
DM_cmdCmd:= "cmd.exe /s /k pushd"
; """D:\Applications\HaoZip\HaoZip.exe""
DM_compressCmd:= """D:\Applications\HaoZip\HaoZipC.exe"" a -tzip "
DM_decompressCmd:= """D:\Applications\HaoZip\HaoZipC.exe"" x "
DM_ExtList := "zip,7z,rar"
DM_templatesDir := a_scriptdir . "\templates"

ifnotexist DM_templatesDir
{
    FileCreateDir, %DM_templatesDir%
}

DM_MenuIOpenFile:= "打开"
DM_MenuIOpenFileDir:= "打开所在位置"
DM_MenuIGitShell:= "Git shell"
DM_MenuICMD:= "命令行"
DM_MenuIProperties:= "属性"
DM_MenuIClearRows:= "移除"
DM_MenuICompress:= "压缩"
DM_MenuIDecompress:= "解压缩"
DM_MenuIDelete:= "删除"
DM_MenuIRename:= "重命名"
DM_MenuICopy:= "复制"
DM_MenuICut:= "剪切"
DM_MenuICreateShortcut:= "创建快捷方式"

DM_MenuICreateFolder:= "新建文件夹"
DM_MenuINew:= "新建"
DM_MenuIRefresh:= "刷新"

DM_btnLoadFolderTip := "加载文件夹"
DM_btnClearTip:= "清空"
DM_btnSwitchViewTip:= "切换视图"
DM_btnRefreshTip:= "刷新"
DM_btnMoveTip:= "移动"
DM_btnCloseTip:= "退出"

; 鼠标移动到窗口上方显示按钮。 true 的话显示
DM_isMouseActiveBtn := true
IconView := true
BeforRemoveToolTip=
; 上方的按钮默认隐藏，鼠标移动到窗口上方显示。
DM_btnIsAlwaysShow := DM_btnIsShow := false

LVM_EDITLABELA := 0x1017
LVM_EDITLABELW := 0x1076
LVM_EDITLABEL := A_IsUnicode ? LVM_EDITLABELW : LVM_EDITLABELA

DM_bgColor := "000000" ; 可以为任意 RGB 颜色 (在下面会被设置为透明).
DM_sizeW   := 710
DM_sizeH   := A_ScreenHeight - 40
DM_fontC   := "ffffff"
DM_img     := "img"
Gui, Color, %DM_bgColor%, %DM_bgColor%
Gui, Font, c%DM_fontC%, Arial

Gui +ToolWindow +HwndhDesktopManager +MinSize%DM_sizeW%x%DM_sizeH% ;+LastFound    ; +ToolWindow 避免显示任务栏按钮和 alt-tab 菜单项.
Gui -Caption -Border
; #ifwinactive 不支持变量 %
GroupAdd, f12group, ahk_id %hDesktopManager%
; 允许用户最大化窗口或拖动来改变窗口的大小:
; 加了会显示边框
; Gui +Resize

; 创建一些按钮:
addPicButton("DM_btnLoadFolder",DM_img . "\folder", ,"x+5",DM_btnLoadFolderTip)
addPicButton("DM_btnClear",DM_img . "\clear", ,"x+10",DM_btnClearTip)
addPicButton("DM_btnSwitchView",DM_img . "\switch", ,"x+10",DM_btnSwitchViewTip)
Gui, Add, Edit, x+10 w120 vDM_CheckText gDM_CheckText cFF2211
addPicButton("DM_btnRefresh",DM_img . "\refresh", ,"x+10",DM_btnRefreshTip)
addPicButton("DM_btnMove",DM_img . "\move", ,"x+10",DM_btnMoveTip)
addPicButton("DM_btnClose",DM_img . "\quit", ,"x+10",DM_btnCloseTip)

; 创建 ListView 及其列:
Gui, Add, ListView, xm r10 w%DM_sizeW% vDM_ListView gDM_ListView HWNDhDM_ListView +Icon -readonly AltSubmit, Name|In Folder|Size (KB)|Type
LV_ModifyCol(3, "Integer")  ; 为了排序, 表示 Size 列中的内容是整数.

; 创建图像列表, 这样 ListView 才可以显示图标:
DM_ImageListID1 := IL_Create(10)
DM_ImageListID2 := IL_Create(10, 10, true)  ; 大图标列表和小图标列表.

; 关联图像列表到 ListView, 然而它就可以显示图标了:
LV_SetImageList(DM_ImageListID1)
LV_SetImageList(DM_ImageListID2)


; 创建作为上下文菜单的弹出菜单:
Menu, DM_ContextMenu, Add, % DM_MenuIOpenFile, DM_OpenFile
Menu, DM_ContextMenu, Add, % DM_MenuIOpenFileDir, DM_OpenFileDir
Menu, DM_ContextMenu, Add, 
Menu, DM_ContextMenu, Add, % DM_MenuICompress, DM_Compress
Menu, DM_ContextMenu, Add, % DM_MenuIDecompress, DM_Decompress
Menu, DM_ContextMenu, Add, 
Menu, DM_ContextMenu, Add, % DM_MenuIGitShell, DM_GitShell
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


Menu, DM_ContextMenuNewFile, Add, % DM_MenuICreateFolder, DM_CreateFolder
Menu, DM_ContextMenuNewFile, Add, 
DM_templates := Object()
Loop %DM_templatesDir%\* ,1  ;获取目录下文件和文件夹，默认为0仅获取文件。
{
    SplitPath, A_LoopFileFullPath, , , , DM_filename_no_ext
    DM_templates[DM_filename_no_ext] := A_LoopFileFullPath
    Menu, DM_ContextMenuNewFile, Add, % DM_filename_no_ext, DM_newFiles
}

Menu, DM_ContextMenu0, Add, % DM_MenuIRefresh, DM_btnRefresh
Menu, DM_ContextMenu0, Add, % DM_MenuINew, :DM_ContextMenuNewFile

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

; 显示窗口并返回. 当用户执行预期的动作时
; 操作系统会通知脚本:
Gui, Show, % "W" . DM_sizeW . "H" . DM_sizeH . "X" . A_ScreenWidth-DM_sizeW

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
; 隐藏顶部按钮
DM_ToggleButton(DM_btnIsShow)
; 圆角
; WinSet, Region, 0-0 W%DM_sizeW% H%DM_sizeH% R40-40, ahk_id %hDesktopManager%

DM_iniFilename := "DesktopManager.ini"
DM_section := "FolderPath"
IniRead, DM_Folder, %DM_iniFilename% , %DM_section% , folder
ifnotexist DM_Folder 
{
    FileCreateDir, %DM_Folder%
}
; 监视目录变化
; www.autohotkey.com/board/topic/60125-ahk-lv2-watchdirectory-report-directory-changes/
WatchDirectory(DM_Folder,"ReportChanges")
gosub LoadFile
return

DM_btnLoadFolder:
Gui +OwnDialogs  ; 强制用户解除此对话框后才可以操作主窗口.
FileSelectFolder, DM_Folder,, 3, 选择目录加载
if not DM_Folder  ; 用户取消了对话框.
    return

gosub LoadFile
Return

LoadFile:
; 检查文件夹名称的最后一个字符是否为反斜线, 对于根目录则会如此,
; 例如 C:\. 如果是, 则移除这个反斜线以避免之后出现两个反斜线.
StringRight, LastChar, DM_Folder, 1
if LastChar = \
    StringTrimRight, DM_Folder, DM_Folder, 1  ; 移除尾随的反斜线.

; 计算 SHFILEINFO 结构需要的缓存大小.
sfi_size := A_PtrSize + 8 + (A_IsUnicode ? 680 : 340)
VarSetCapacity(sfi, sfi_size)

; 获取所选择文件夹中的文件名列表并添加到 ListView:
GuiControl, -Redraw, DM_ListView  ; 在加载时禁用重绘来提升性能.
Loop %DM_Folder%\%DM_CheckText%* ,1  ;获取DM_Folder下文件和文件夹，默认为0仅获取文件。
{
    DM_addFile(A_LoopFileFullPath,A_LoopFileName,A_LoopFileDir,A_LoopFileSizeKB)
}
GuiControl, +Redraw, DM_ListView  ; 重新启用重绘 (上面把它禁用了).
LV_ModifyCol()  ; 根据内容自动调整每列的大小.
LV_ModifyCol(3, 60) ; 把 Size 列加宽一些以便显示出它的标题.
return


DM_btnClear:
LV_Delete()  ; 清理 ListView, 但为了简化保留了图标缓存.
return

DM_btnRefresh:
LV_Delete()  ; 清理 ListView, 但为了简化保留了图标缓存.
gosub LoadFile
return

DM_btnClose:
gosub GuiClose
return

DM_btnMove:
; 移动窗口
PostMessage, 0xA1, 2
return

DM_btnSwitchView:
if (!IconView){
    GuiControl, +Icon, DM_ListView    ; 切换到图标视图.
} else {
    GuiControl, +Report, DM_ListView  ; 切换回详细信息视图.
    LV_ModifyCol()  ; 根据内容自动调整每列的大小.
    LV_ModifyCol(3, 60) ; 把 Size 列加宽一些以便显示出它的标题.
}
IconView := !IconView             ; 进行反转以为下次做准备.
return

DM_ListView:
if (A_GuiEvent == "DoubleClick"){  ; 脚本还可以检查许多其他的可能值.
    SelectedRowNumber := LV_GetNext(0)  ; 查找选中的行.
    if(SelectedRowNumber != 0){ ;有被选中的
        LV_GetText(DM_FileName, A_EventInfo, 1) ; 从首个字段中获取文本.
        LV_GetText(DM_FileDir, A_EventInfo, 2)  ; 从第二个字段中获取文本.
        Run %DM_FileDir%\%DM_FileName%,, UseErrorLevel
        if ErrorLevel
            MsgBox Could not open "%DM_FileDir%\%DM_FileName%".
    }
} else if (A_GuiEvent == "E") { ; 开始编辑
    LV_GetText(DM_OldFileName, A_EventInfo, 1) ; 从首个字段中获取文本.
} else if (A_GuiEvent == "e") { ; 完成编辑
    LV_GetText(DM_FileName, A_EventInfo, 1) ; 从首个字段中获取文本.
    LV_GetText(DM_FileDir, A_EventInfo, 2)  ; 从第二个字段中获取文本.
    res := fileOrFolderRename(DM_FileDir . "\" . DM_OldFileName,DM_FileName)
    if(res == false){
        LV_Modify(A_EventInfo, , DM_OldFileName)
    }
    ; watchdirectory 会监视到更改
    ; gosub DM_btnRefresh
}
return

GuiContextMenu:  ; 运行此标签来响应右键点击或按下 Appskey.
if A_GuiControl <> DM_ListView  ; 仅在 ListView 中点击时才显示菜单.
    return
FocusedRowNumber := LV_GetNext(0, "F")  ; 查找焦点行.
SelectedRowNumber := LV_GetNext(0)  ; 查找选中的行.
; 在提供的坐标处显示菜单, A_GuiX 和 A_GuiY.  应该使用这些
; 因为即使用户按下 Appskey 它们也会提供正确的坐标:
if(SelectedRowNumber != 0){ ;有被选中的
    Menu, DM_ContextMenu, Show, %A_GuiX%, %A_GuiY%
} else {
    Menu, DM_ContextMenu0, Show, %A_GuiX%, %A_GuiY%
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
}
Return

DM_CreateFolder:
FormatTime, DM_DirName,, yyyy-MM-dd [HH.mm.ss]
DM_newFolder := DM_Folder . "\" . DM_DirName
ifnotexist DM_newFolder
{
    FileCreateDir, %DM_newFolder%
}

return
DM_OpenFile:  ; 用户在上下文菜单中选择了 "打开".
DM_Properties:  ; 用户在上下文菜单中选择了 "属性".
DM_OpenFileDir:  ; 用户在上下文菜单中选择了 "打开所在位置".
DM_Rename:
DM_CreateShortcut:
DM_GitShell:
DM_CMD:
DM_Decompress:
; 为了简化, 仅对焦点行进行操作而不是所有选择的行:
FocusedRowNumber := LV_GetNext(0, "F")  ; 查找焦点行.
if not FocusedRowNumber  ; 没有焦点行.
    return
LV_GetText(DM_FileName, FocusedRowNumber, 1) ; 获取首个字段的文本.
LV_GetText(DM_FileDir, FocusedRowNumber, 2)  ; 获取第二个字段的文本.
If (A_ThisMenuItem == DM_MenuIOpenFile)   ; 用户在上下文菜单中选择了 "打开".
    Run %DM_FileDir%\%DM_FileName%,, UseErrorLevel
else If (A_ThisMenuItem == DM_MenuIOpenFileDir)  ; 用户在上下文菜单中选择了 "打开位置".
    run Explorer /select`,%DM_FileDir%\%DM_FileName%,,UseErrorLevel
else If (A_ThisMenuItem == DM_MenuIProperties)   ; 用户在上下文菜单中选择了 "属性".
    Run Properties "%DM_FileDir%\%DM_FileName%",, UseErrorLevel
else If (A_ThisMenuItem == DM_MenuIRename){   ; 用户在上下文菜单中选择了 "重命名".
    ; PostMessage, LVM_EDITLABEL, FocusedRowNumber-1, 0, SysListView321, % "ahk_id " . hDesktopManager
    ; 下面和上面是等效的
    PostMessage, LVM_EDITLABEL, FocusedRowNumber-1, 0, , % "ahk_id " . hDM_ListView
} else If (A_ThisMenuItem == DM_MenuICreateShortcut){   ; 用户在上下文菜单中选择了 "创建快捷方式".
    createShortcut(DM_FileDir . "\" . DM_FileName)
} else If (A_ThisMenuItem == DM_MenuIGitShell){   ; 用户在上下文菜单中选择了 "git shell".
    cmdHere(DM_gitCmd, DM_FileDir . "\" . DM_FileName)
} else If (A_ThisMenuItem == DM_MenuICMD){   ; 用户在上下文菜单中选择了 "命令行".
    cmdHere(DM_cmdCmd, DM_FileDir . "\" . DM_FileName)
} else If (A_ThisMenuItem == DM_MenuIDecompress){   ; 用户在上下文菜单中选择了 "命令行".
    LV_GetText(DM_FileExt, FocusedRowNumber, 4)  ; 获取第二个字段的文本.
    if DM_FileExt in % DM_ExtList
    {
        decompressFile(DM_decompressCmd, DM_FileDir . "\" . DM_FileName)
    }
}
if (ErrorLevel) {
    myToolTip("对" . DM_FileDir . "\" . DM_FileName . "执行命令失败")
}
return

DM_ClearRows:  ; 用户在上下文菜单中选择了 "Clear".
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
    FileToClipboard(FileFullNames)
} else If (A_ThisMenuItem == DM_MenuICut){   ; 用户在上下文菜单中选择了 "剪切".
    FileToClipboard(FileFullNames,"cut")
}
Return

DM_Compress:
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
Return

DM_Delete:
RowNumber = 0  ; 这会使得首次循环从顶部开始搜索.
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
    FileFullName := DM_FileDir . "\" . DM_FileName
    FileRecycle, %FileFullName%
    ; watchdirectory 会更新界面
    ; MsgBox, 4,, Would you like to Delete %FileFullName%? (press Yes or No)
    ; IfMsgBox Yes 
    ; {
        ; FileRecycle, %FileFullName%
        ; LV_Delete(RowNumber)  ; 从 ListView 中删除行.
    ; }
}
Return

GuiSize:  ; 扩大或缩小 ListView 来响应用户对窗口大小的改变.
if A_EventInfo = 1  ; 窗口被最小化了.  无需进行操作.
    return
; 否则, 窗口的大小被调整过或被最大化了. 调整 ListView 的大小来适应.
GuiControl, Move, DM_ListView, % "W" . (A_GuiWidth - 20) . " H" . (A_GuiHeight - 40)
return

GuiClose:  ; 当窗口关闭时, 自动退出脚本:
ExitApp

GuiDropFiles:
Loop, parse, A_GuiEvent, `n
{
    fileOrFolderMove(A_LoopField,DM_Folder)
}
LV_Delete() 
gosub, LoadFile
Return


; 根据实时输入显示文件或文件夹
DM_CheckText:
SetTimer %A_ThisLabel%,Off
Gui, Submit, NoHide
LV_Delete() 
gosub, LoadFile
return

; 双击桌面隐藏、显示桌面图标
; http://www.autohotkey.com/board/topic/38006-double-click-desktop-to-hide-icons/
~LButton::
 If ( A_PriorHotKey = A_ThisHotKey && A_TimeSincePriorHotkey < 400 ) {
   WinGetClass, Class, A
   If Class in Progman,WorkerW
   var := (flag=0) ? "Show" : "Hide"
   flag := !flag
   Control,%var%,, SysListView321, ahk_class Progman
   Control,%var%,, SysListView321, ahk_class WorkerW
}
Return

#ifwinactive ahk_group f12group
f12::
DM_btnIsShow := !DM_btnIsShow
DM_ToggleButton(DM_btnIsShow)
DM_btnIsAlwaysShow := DM_btnIsShow
Return

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
    GuiControl, show%show%, DM_btnLoadFolder
    GuiControl, show%show%, DM_btnClear
    GuiControl, show%show%, DM_btnSwitchView
    GuiControl, show%show%, DM_CheckText
    GuiControl, show%show%, DM_btnRefresh
    GuiControl, show%show%, DM_btnMove
    GuiControl, show%show%, DM_btnClose
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
    If (StrLen(PrevControl) && DM_buttons.HasKey(PrevControl) && CurrControl != PrevControl) 
    { 
        ; 清空提示
        ToolTip
        GuiControl,, % PrevControl, % DM_buttons[PrevControl]["picpre"] . "." . DM_buttons[PrevControl]["pictype"]
    }
    If (StrLen(CurrControl) && DM_buttons.HasKey(CurrControl) && CurrControl != PrevControl) 
    { 
        ; The leading percent sign tell it to use an expression. 
        mytoolTip(DM_buttons[CurrControl]["tipinfo"])
        GuiControl,, % CurrControl, % DM_buttons[CurrControl]["picpre"] . "_over." . DM_buttons[CurrControl]["pictype"] 
    } 
    PrevControl := CurrControl 
    return 
} 

addPicButton(label,picPrefix,picType="png",option="",tooltipInfo="")
{
	global
	local hwndget
	static buttonIndex=0
	buttonIndex++
	If(!isObject(DM_buttons))
	DM_buttons:=Object()
	Gui, Add, Pic, % option . " hwndh" . label . " g" . label . " v" . label, % picPrefix . "." . picType
	DM_buttons[label,"pictype"] := picType
	DM_buttons[label,"picpre"]  := picPrefix
	DM_buttons[label,"label"]   := label
    DM_buttons[label,"tipinfo"] := tooltipInfo
	Return, buttonIndex
}
; http://www.autohotkey.com/board/topic/23162-how-to-copy-a-file-to-the-clipboard/page-4
FileToClipboard(PathToCopy,Method="copy",delim="`n",omit = "`r")
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

    if (Method="copy")
        DllCall("RtlFillMemory","UPtr",str,"uint",1,"UChar",0x05)
    else if (Method="cut")
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
DM_addFile(FileFullName,FileName="", FileDir="", FileSizeKB="")
{
    global
    local FileExt,ExtID,IconNumber,ExtChar,hIcon,FileNameTmp,FileDirTmp

    ; 建立唯一的扩展 ID 以避免变量名中的非法字符,
    ; 例如破折号.  这种使用唯一 ID 的方法也会执行地更好,
    ; 因为在数组中查找项目不需要进行搜索循环.
    SplitPath, FileFullName,FileNameTmp,FileDirTmp, FileExt  ; 获取文件扩展名.
    if (!StrLen(FileName)) {
        FileName   := FileNameTmp
        FileDir    := FileDirTmp
        FileGetSize, FileSizeKB, FileFullName, K 
    }
    if FileExt in EXE,ICO,ANI,CUR
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

    ; 如果是文件夹,显示folder
	if InStr(FileExist(FileFullName),"D"){
       	FileExt := "Folder"
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

createShortcut(fileName){
SplitPath,filename,name,dir,ext,name_no_ext,drive
FileSelectFolder,target,*%dir%,3,选择目录存放快捷方式`n %filename%
If target<>
  FileCreateShortcut,%filename%,%target%\%name_no_ext%.lnk,%dir%,,,%filename%,,1,
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
    FileSelectFolder, Folder,, 3, 选择解压目录
    if (Folder == ""){ ; 用户取消了对话框.
        ; myToolTip("没有选择目录")
        return false
    }
        
    run % decompressCmd . " """ . FileFullPath . """ -o" . Folder , ,UseErrorLevel Hide
    if (ErrorLevel == "ERROR"){
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
    global hDM_ListView,LVM_EDITLABEL
    if(from == "" && to != ""){
        ; 新建文件
        RowNumber := DM_addFile(to)
        LV_Modify(RowNumber, "+Focus")
        PostMessage, LVM_EDITLABEL, RowNumber-1, 0, , % "ahk_id " . hDM_ListView
    } else if(to == "" && from != ""){
        ; 删除文件
        ; TODO:删除多个文件闪烁明显
        gosub DM_btnRefresh
    } else if(from != to){
        ; 重命名
        gosub DM_btnRefresh
    }
}
