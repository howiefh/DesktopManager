; 下面是一个比此页面顶部附近那个更精巧的可运行脚本.
; 它显示用户文件夹中的文件, 且每个文件分配一个与其类型关联的图标.
; 用户在一个文件上双击或在一个或多个文件上右击后, 会显示上下文菜单.
BeforRemoveToolTip=
DM_bgColor := "000000" ; 可以为任意 RGB 颜色 (在下面会被设置为透明).
DM_sizeW   := 710
DM_sizeH   := A_ScreenHeight - 40
DM_fontC   := "ffffff"
DM_toggle  := true
Gui, Color, %DM_bgColor%
Gui, Font, c%DM_fontC%, Arial

Gui +ToolWindow +HwndhDesktopManager +MinSize%DM_sizeW%x%DM_sizeH% ;+LastFound    ; +ToolWindow 避免显示任务栏按钮和 alt-tab 菜单项.
Gui -Caption -Border
; 允许用户最大化窗口或拖动来改变窗口的大小:
; 加了会显示边框
; Gui +Resize

; 创建一些按钮:
Gui, Add, Button, Default gDM_btnLoadFolder vDM_btnLoadFolder , Load a folder
Gui, Add, Button, x+10 gDM_btnClear vDM_btnClear, Clear List
Gui, Add, Button, x+10 vDM_btnSwitchView, Switch View
Gui, Add, Edit, x+10 w120 vDM_CheckText gDM_CheckText cFF2211
Gui, Add, Button, x+10 gDM_btnRefresh vDM_btnRefresh, Refresh
Gui, Add, Button, x+10 gDM_btnClose vDM_btnClose, Quit

; 创建 ListView 及其列:
Gui, Add, ListView, xm r10 w%DM_sizeW% vDM_ListView gDM_ListView +Icon , Name|In Folder|Size (KB)|Type
LV_ModifyCol(3, "Integer")  ; 为了排序, 表示 Size 列中的内容是整数.

; 创建图像列表, 这样 ListView 才可以显示图标:
DM_ImageListID1 := IL_Create(10)
DM_ImageListID2 := IL_Create(10, 10, true)  ; 大图标列表和小图标列表.

; 关联图像列表到 ListView, 然而它就可以显示图标了:
LV_SetImageList(DM_ImageListID1)
LV_SetImageList(DM_ImageListID2)

; 创建作为上下文菜单的弹出菜单:
Menu, MyContextMenu, Add, Open, DM_OpenFile
Menu, MyContextMenu, Add, Properties, DM_Properties
Menu, MyContextMenu, Add, Clear from ListView, DM_ClearRows
Menu, MyContextMenu, Add, Delete, DM_Delete
Menu, MyContextMenu, Default, Open  ; 让 "Open" 粗体显示表示双击时会执行相同的操作.


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

; 设置透明和钉在桌面冲突
; http://ahk.haotui.com/viewthread.php?tid=4532
; WinSet, TransColor, %DM_bgColor% 150, ahk_id %hDesktopManager%
; WinSet, Transparent, 150, ahk_id %hDesktopManager%

GuiControl +BackgroundDM_bgColor, DM_ListView 
; 钉在桌面上
ControlGet,DM_id,hwnd,,SHELLDLL_DefView1,ahk_class Progman
if DM_id=   ;如果用户设定的是动态桌面
{
    ControlGet,DM_id,hwnd,,SHELLDLL_DefView1,ahk_class WorkerW
}
ControlGet,DM_DesktopID,hwnd,,SysListView321,ahk_id %DM_id%
DllCall( "SetParent", UInt, hDesktopManager, UInt, DM_DesktopID)
; 隐藏顶部按钮
ToggleButton(DM_toggle)
; 圆角
; WinSet, Region, 0-0 W%DM_sizeW% H%DM_sizeH% R40-40, ahk_id %hDesktopManager%

DM_filename := "WINAssist.ini"
DM_section := "FolderPath"
IniRead, DM_Folder, %DM_filename% , %DM_section% , folder
ifnotexist DM_Folder 
{
    FileCreateDir, %DM_Folder%
}

gosub LoadFile
return

DM_btnLoadFolder:
Gui +OwnDialogs  ; 强制用户解除此对话框后才可以操作主窗口.
FileSelectFolder, DM_Folder,, 3, Select a folder to read:
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
    FileName := A_LoopFileFullPath  ; 必须保存到可写的变量中供后面使用.

    ; 建立唯一的扩展 ID 以避免变量名中的非法字符,
    ; 例如破折号.  这种使用唯一 ID 的方法也会执行地更好,
    ; 因为在数组中查找项目不需要进行搜索循环.
    SplitPath, FileName,,, FileExt  ; 获取文件扩展名.
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
        if not DllCall("Shell32\SHGetFileInfo" . (A_IsUnicode ? "W":"A"), "str", FileName
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
        /*
        if InStr(FileExist(FileName),"D"){
            MsgBox % IconNumber
        }
        */
    }

    ; 如果是文件夹,显示folder
	if InStr(FileExist(FileName),"D"){
       	FileExt := "Folder"
	}

    ; 在 ListView 中创建新行并把它和上面的图标编号进行关联:
    LV_Add("Icon" . IconNumber, A_LoopFileName, A_LoopFileDir, A_LoopFileSizeKB, FileExt)
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

DM_btnSwitchView:
if not IconView
    GuiControl, +Icon, DM_ListView    ; 切换到图标视图.
else
{
    GuiControl, +Report, DM_ListView  ; 切换回详细信息视图.
    LV_ModifyCol()  ; 根据内容自动调整每列的大小.
    LV_ModifyCol(3, 60) ; 把 Size 列加宽一些以便显示出它的标题.
}
IconView := not IconView             ; 进行反转以为下次做准备.
return

DM_ListView:
if A_GuiEvent = DoubleClick  ; 脚本还可以检查许多其他的可能值.
{
    LV_GetText(FileName, A_EventInfo, 1) ; 从首个字段中获取文本.
    LV_GetText(FileDir, A_EventInfo, 2)  ; 从第二个字段中获取文本.
    Run %FileDir%\%FileName%,, UseErrorLevel
    if ErrorLevel
        MsgBox Could not open "%FileDir%\%FileName%".
}
return

GuiContextMenu:  ; 运行此标签来响应右键点击或按下 Appskey.
if A_GuiControl <> DM_ListView  ; 仅在 ListView 中点击时才显示菜单.
    return
; 在提供的坐标处显示菜单, A_GuiX 和 A_GuiY.  应该使用这些
; 因为即使用户按下 Appskey 它们也会提供正确的坐标:
Menu, MyContextMenu, Show, %A_GuiX%, %A_GuiY%
return

DM_OpenFile:  ; 用户在上下文菜单中选择了 "Open".
DM_Properties:  ; 用户在上下文菜单中选择了 "Properties".
; 为了简化, 仅对焦点行进行操作而不是所有选择的行:
FocusedRowNumber := LV_GetNext(0, "F")  ; 查找焦点行.
if not FocusedRowNumber  ; 没有焦点行.
    return
LV_GetText(FileName, FocusedRowNumber, 1) ; 获取首个字段的文本.
LV_GetText(FileDir, FocusedRowNumber, 2)  ; 获取第二个字段的文本.
IfInString A_ThisMenuItem, Open  ; 用户在上下文菜单中选择了 "Open".
    Run %FileDir%\%FileName%,, UseErrorLevel
else  ; 用户在上下文菜单中选择了 "Properties".
    Run Properties "%FileDir%\%FileName%",, UseErrorLevel
if ErrorLevel
    MsgBox Could not perform requested action on "%FileDir%\%FileName%".
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
    LV_GetText(FileName, RowNumber, 1) ; 从首个字段中获取文本.
    LV_GetText(FileDir, RowNumber, 2)  ; 从第二个字段中获取文本.
    FileFullName := FileDir . "\" . FileName
    MsgBox, 4,, Would you like to Delete %FileFullName%? (press Yes or No)
    IfMsgBox Yes 
    {
        FileRecycle, %FileFullName%
        LV_Delete(RowNumber)  ; 从 ListView 中删除行.
    }
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
    ; 如果是文件夹
	if InStr(FileExist(A_LoopField),"D"){
        SplitPath, A_LoopField, FolderName
        FileMoveDir ,%A_LoopField%, %DM_Folder%\%FolderName%
	} else {
        FileMove ,%A_LoopField%, %DM_Folder%
    }
    ToolTip, % "move" . A_LoopField . "to" . DM_Folder
    SetTimer, RemoveToolTip, 2000
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

ToggleButton(hide){
    ; 和hwnd不同，如果关联变量不需要%%包含，hwnd需要
    GuiControl, Hide%hide%, DM_btnLoadFolder
    GuiControl, Hide%hide%, DM_btnClear
    GuiControl, Hide%hide%, DM_btnSwitchView
    GuiControl, Hide%hide%, DM_CheckText
    GuiControl, Hide%hide%, DM_btnRefresh
    GuiControl, Hide%hide%, DM_btnClose
}

f12::
DM_toggle := !DM_toggle
ToggleButton(DM_toggle)
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
