#include include\Gdip.ahk
;~ guiDebug:=1
pToken := Gdip_Startup()
Gui, -Caption +ToolWindow hwndgui_id
Gui, Color, ffffff, ffffff
Gui, Add, pic, x20 y40 w340 h30 hwndhTitle, 
Gui, Font, s14, Zpix C.O.D.E
Gui, Add, Edit, w340 r20 vediter hwndhEdit1, 1=G`nbpm=150`n1 3 5 ( 1- 3- 5- )

;~ Gui, Add, Button, w100 hwndhButton1 +0xE, BUTTON
Gui, Show, AutoSize
buttonpicDir:="button\"
addPicButton("play","w100 h30",buttonpicDir "b2_up.png",buttonpicDir "b2_over.png",buttonpicDir "b2_down.png")
addPicButton("stop","xp+120 w100 h30",buttonpicDir "b4_up.png",buttonpicDir "b4_over.png",buttonpicDir "b4_down.png")
addPicButton("about","xp+120 yp w100 h30",buttonpicDir "b3_up.png",buttonpicDir "b3_over.png",buttonpicDir "b3_down.png")
exitnum:=addPicButton("exit","x356 y0 w34 h30",buttonpicDir "x_up.png",buttonpicDir "x_over.png",buttonpicDir "x_down.png")
tabnum:=addPicButton("winMove","x30 y0 w326 h30 gwinMove",buttonpicDir "tab_up.png",buttonpicDir "tab_over.png",buttonpicDir "tab_over.png")
pinnum:=addPicButton("winPin","x0 y0 w30 h30",buttonpicDir "pin2_blue.png",buttonpicDir "pin2_over_yellow.png",buttonpicDir "pin2_pined.png")

pBitmap%pinnum%_blue_:=Gdip_CreateBitmapFromFile(buttonpicDir "pin2_blue.png")
pBitmap%pinnum%_yellow_:=Gdip_CreateBitmapFromFile(buttonpicDir "pin2_yellow.png")
pBitmap%pinnum%_over_yellow_:=Gdip_CreateBitmapFromFile(buttonpicDir "pin2_over_yellow.png")

pBitmap%pinnum%_pined_blue_:=Gdip_CreateBitmapFromFile(buttonpicDir "pin2_pined_blue.png")
pBitmap%pinnum%_pined_yellow_:=Gdip_CreateBitmapFromFile(buttonpicDir "pin2_pined_yellow.png")

pBitmap%pinnum%_pined_shijiao_:=Gdip_CreateBitmapFromFile(buttonpicDir "pin2_pined_shijiao.png")
pBitmap%pinnum%_shijiao_:=Gdip_CreateBitmapFromFile(buttonpicDir "pin2_shijiao.png")

pBitmap%pinnum%_blue:=pBitmap%pinnum%_blue_
pBitmap%pinnum%_yellow:=pBitmap%pinnum%_yellow_
pBitmap%pinnum%_over_yellow:=pBitmap%pinnum%_over_yellow_
pBitmap%pinnum%_shijiao:=pBitmap%pinnum%_shijiao_

Gui, Show, w390

Parent :=  DllCall( "GetParent", "uint", gui_id)
msgbox, %Parent%
ControlGet,d_id,hwnd,,SHELLDLL_DefView1,ahk_class Progman
if d_id=   
    ControlGet,d_id,hwnd,,SHELLDLL_DefView1,ahk_class WorkerW
ControlGet,Desktop_ID,hwnd,,SysListView321,ahk_id %d_id%
Parent := DllCall( "SetParent", UInt, gui_id, UInt, Desktop_ID)
; Parent :=  DllCall( "GetParent", "uint", gui_id)
msgbox, %Parent%
Parent := DllCall( "SetParent", UInt, gui_id, UInt, Parent)
msgbox, %Parent%
Parent := DllCall( "SetParent", UInt, gui_id, UInt, Parent)
msgbox, %Parent%
Parent := DllCall( "SetParent", UInt, gui_id, UInt, Parent)
msgbox, %Parent%

OnMessage(0x200, "MouseMove")
OnMessage(0x201, "MouseDown")
OnMessage(0x203, "MouseDown")
OnMessage(0x202, "MouseUp")
OnMessage(0x86,"NCactivate")
;~ OnMessage(0x202, "MouseLeave")
;~ OnMessage(0x2A3, "MouseLeave")
;~ hBitmap1:=Gdip_CreateHBITMAPFromBitmap(pBitmap1)

NCactivate(wParam, lParam, msg, hwnd)
{
	global
	If(WinExist("A")=gui_id)
	{
		Gdip_DrawImage(G%tabnum%, pBitmap%tabnum%_up, 0, 0, 326, 30, 0, 0, 326, 30)
		Gdip_DrawImage(G%exitnum%, pBitmap%exitnum%_up, 0, 0, 34, 30, 0, 0, 34, 30)
		Gdip_DrawImage(G%pinnum%, pBitmap%pinnum%_blue, 0, 0, 30, 30, 0, 0, 30, 30)
	}
	Else
	{
		Gdip_DrawImage(G%tabnum%, pBitmap%tabnum%_shijiao, 0, 0, 326, 30, 0, 0, 326, 30)
		Gdip_DrawImage(G%exitnum%, pBitmap%exitnum%_over, 0, 0, 34, 30, 0, 0, 34, 30)
		Gdip_DrawImage(G%pinnum%, pBitmap%pinnum%_shijiao, 0, 0, 30, 30, 0, 0, 30, 30)
	}
}


MouseUp(wParam, lParam, msg, hwnd)
{
	global
	local mhwnd
	MouseGetPos,,,,mhwnd,2
	MouseUpHwnd:=mhwnd
	If(mhwnd)
	{
		Loop, % buttons["max"]
		{
			If(mhwnd = hButton%A_Index%)
			Gdip_DrawImage(G%A_Index%, pBitmap%A_Index%_over, 0, 0, buttons[A_Index]["w"], buttons[A_Index]["h"], 0, 0, buttons[A_Index]["w"], buttons[A_Index]["h"])
		}
		If(MouseUpHwnd=MouseDownHwnd)
		{
			If(events[MouseUpHwnd]!="")
			Gosub, % events[MouseUpHwnd]
		}
	}
	Return
}

MouseDown(wParam, lParam, msg, hwnd)
{
	global
	local mhwnd
	MouseGetPos,,,,mhwnd,2
	MouseDownHwnd:=mhwnd
;~ 	MsgBox, Mouse Down %mhwnd%.
	If(mhwnd)
	Loop, % buttons["max"]
	{
		If(mhwnd = hButton%A_Index% And mhwnd != hButton%pinnum%)
		{
			Gdip_DrawImage(G%A_Index%, pBitmap%A_Index%_down, 0, 0, buttons[A_Index]["w"], buttons[A_Index]["h"], 0, 0, buttons[A_Index]["w"], buttons[A_Index]["h"])
		}
	}
	Return
}

MouseMove(wParam, lParam, msg, hwnd)
{
	Global
	local mhwnd
	If(WinExist("A")!=gui_id)
    {
        Return
    }
	MouseGetPos,,,,mhwnd,2
	Static _LastButtonData = true
	If(mhwnd != _LastButtonData)	;光标移动到新控件
	{
        ;标题栏额外处理
		if(mhwnd == hButton%tabnum% || mhwnd == hButton%exitnum% || mhwnd == hButton%pinnum%)
		{
			Gdip_DrawImage(G%tabnum%, pBitmap%tabnum%_down, 0, 0, buttons[tabnum]["w"], buttons[tabnum]["h"], 0, 0, buttons[tabnum]["w"], buttons[tabnum]["h"])
			If(mhwnd == hButton%tabnum%)
			{
				Gdip_DrawImage(G%exitnum%, pBitmap%exitnum%_down, 0, 0, buttons[exitnum]["w"], buttons[exitnum]["h"], 0, 0, buttons[exitnum]["w"], buttons[exitnum]["h"])
				Gdip_DrawImage(G%pinnum%, pBitmap%pinnum%_yellow, 0, 0, buttons[pinnum]["w"], buttons[pinnum]["h"], 0, 0, buttons[pinnum]["w"], buttons[pinnum]["h"])
			}
			Else If(mhwnd == hButton%pinnum%)
			{
				Gdip_DrawImage(G%pinnum%, pBitmap%pinnum%_over_yellow, 0, 0, buttons[pinnum]["w"], buttons[pinnum]["h"], 0, 0, buttons[pinnum]["w"], buttons[pinnum]["h"])
				Gdip_DrawImage(G%exitnum%, pBitmap%exitnum%_down, 0, 0, buttons[exitnum]["w"], buttons[exitnum]["h"], 0, 0, buttons[exitnum]["w"], buttons[exitnum]["h"])
			}
			Else If(mhwnd == hButton%exitnum%)
			{
				Gdip_DrawImage(G%exitnum%, pBitmap%exitnum%_over, 0, 0, buttons[exitnum]["w"], buttons[exitnum]["h"], 0, 0, buttons[exitnum]["w"], buttons[exitnum]["h"])
				Gdip_DrawImage(G%tabnum%, pBitmap%tabnum%_up, 0, 0, buttons[tabnum]["w"], buttons[tabnum]["h"], 0, 0, buttons[tabnum]["w"], buttons[tabnum]["h"])
				Gdip_DrawImage(G%pinnum%, pBitmap%pinnum%_blue, 0, 0, buttons[pinnum]["w"], buttons[pinnum]["h"], 0, 0, buttons[pinnum]["w"], buttons[pinnum]["h"])
			}
		}
		If(_LastButtonData == hButton%tabnum% || _LastButtonData == hButton%exitnum% || _LastButtonData == hButton%pinnum%)
		{
			Gdip_DrawImage(G%exitnum%, pBitmap%exitnum%_up, 0, 0, buttons[exitnum]["w"], buttons[exitnum]["h"], 0, 0, buttons[exitnum]["w"], buttons[exitnum]["h"])
			Gdip_DrawImage(G%tabnum%, pBitmap%tabnum%_up, 0, 0, buttons[tabnum]["w"], buttons[tabnum]["h"], 0, 0, buttons[tabnum]["w"], buttons[tabnum]["h"])
			Gdip_DrawImage(G%pinnum%, pBitmap%pinnum%_blue, 0, 0, buttons[pinnum]["w"], buttons[pinnum]["h"], 0, 0, buttons[pinnum]["w"], buttons[pinnum]["h"])

		}
		Else
        {
            Loop, % buttons["max"]
            {
                If(mhwnd = hButton%A_Index% And mhwnd != hButton%exitnum%)	;移入
                {
                    Gdip_DrawImage(G%A_Index%, pBitmap%A_Index%_over, 0, 0, buttons[A_Index]["w"], buttons[A_Index]["h"], 0, 0, buttons[A_Index]["w"], buttons[A_Index]["h"])
                }
                If(_LastButtonData = hButton%A_Index% And _LastButtonData != hButton%exitnum%)	;移出
                {
                    Gdip_DrawImage(G%A_Index%, pBitmap%A_Index%_up, 0, 0, buttons[A_Index]["w"], buttons[A_Index]["h"], 0, 0, buttons[A_Index]["w"], buttons[A_Index]["h"])
                }
            }
        }
	}
	_LastButtonData := mhwnd
;~ 	ToolTip, % wParam "," lParam "," msg "," hwnd
;~ 	ToolTip, % mhwnd
	Return
}

addPicButton(label,Option,picUp,picOver,picDown)
{
	global
	local hwndget,w,h,hdc
	static buttonIndex=0
	buttonIndex++
	If(!isObject(buttons))
	buttons:=Object()
	If(!isObject(events))
	events:=Object()
;~ 	Gui, Add, Pic, % Option " hwndhButton" buttonIndex, % "PicButton" buttonIndex
	Gui, Add, Pic, % Option " hwndhButton" buttonIndex,
	Gui, Show, AutoSize
	pBitmap%buttonIndex%_up:=Gdip_CreateBitmapFromFile(picUp)
	pBitmap%buttonIndex%_over:=Gdip_CreateBitmapFromFile(picOver)
	pBitmap%buttonIndex%_down:=Gdip_CreateBitmapFromFile(picDown)
	hdc:=GetDC(hButton%buttonIndex%)
	G%buttonIndex% := Gdip_GraphicsFromHDC(hdc)
	hwndget:=hButton%buttonIndex%
	ControlGetPos, ,, w, h,,ahk_id %hwndget%
	buttons[buttonIndex,"w"]:=w
	buttons[buttonIndex,"h"]:=h
	buttons["max"]:=buttonIndex
	events[hwndget]:=label
	Gdip_DrawImage(G%buttonIndex%, pBitmap%buttonIndex%_up, 0, 0, w, h, 0, 0, w, h)
	buttonMax:=buttonIndex
	Return, buttonIndex
}

winMove:
PostMessage, 0xA1, 2
Return

winPin:
onTop:=!onTop
If onTop
{
Gui, +AlwaysOnTop
pBitmap%pinnum%_blue:=pBitmap%pinnum%_pined_blue_
pBitmap%pinnum%_yellow:=pBitmap%pinnum%_pined_yellow_
pBitmap%pinnum%_over_yellow:=pBitmap%pinnum%_pined_yellow
pBitmap%pinnum%_shijiao:=pBitmap%pinnum%_pined_shijiao_
}
Else
{
Gui, -AlwaysOnTop
pBitmap%pinnum%_blue:=pBitmap%pinnum%_blue_
pBitmap%pinnum%_yellow:=pBitmap%pinnum%_yellow_
pBitmap%pinnum%_over_yellow:=pBitmap%pinnum%_over_yellow_
pBitmap%pinnum%_shijiao:=pBitmap%pinnum%_shijiao_
}
Gdip_DrawImage(G%pinnum%, pBitmap%pinnum%_yellow, 0, 0, buttons[pinnum]["w"], buttons[pinnum]["h"], 0, 0, buttons[pinnum]["w"], buttons[pinnum]["h"])
Return
