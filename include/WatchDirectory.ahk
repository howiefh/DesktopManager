#include include\_Struct.ahk
WatchDirectory(p*){
;Structures
static FILE_NOTIFY_INFORMATION:="DWORD NextEntryOffset,DWORD Action,DWORD FileNameLength,WCHAR FileName[1]"
static OVERLAPPED:="ULONG_PTR Internal,ULONG_PTR InternalHigh,{struct{DWORD offset,DWORD offsetHigh},PVOID Pointer},HANDLE hEvent"
;Variables
static running,sizeof_FNI=65536,temp1:=VarSetCapacity(nReadLen,8),WatchDirectory:=RegisterCallback("WatchDirectory","F",0,0)
static timer,ReportToFunction,LP,temp2:=VarSetCapacity(LP,(260)*(A_PtrSize/2),0)
static @:=Object(),reconnect:=Object(),#:=Object(),DirEvents,StringToRegEx="\\\|.\.|+\+|[\[|{\{|(\(|)\)|^\^|$\$|?\.?|*.*"
;ReadDirectoryChanges related
static FILE_NOTIFY_CHANGE_FILE_NAME=0x1,FILE_NOTIFY_CHANGE_DIR_NAME=0x2,FILE_NOTIFY_CHANGE_ATTRIBUTES=0x4
,FILE_NOTIFY_CHANGE_SIZE=0x8,FILE_NOTIFY_CHANGE_LAST_WRITE=0x10,FILE_NOTIFY_CHANGE_CREATION=0x40
,FILE_NOTIFY_CHANGE_SECURITY=0x100
static FILE_ACTION_ADDED=1,FILE_ACTION_REMOVED=2,FILE_ACTION_MODIFIED=3
,FILE_ACTION_RENAMED_OLD_NAME=4,FILE_ACTION_RENAMED_NEW_NAME=5
static OPEN_EXISTING=3,FILE_FLAG_BACKUP_SEMANTICS=0x2000000,FILE_FLAG_OVERLAPPED=0x40000000
,FILE_SHARE_DELETE=4,FILE_SHARE_WRITE=2,FILE_SHARE_READ=1,FILE_LIST_DIRECTORY=1
If p.MaxIndex(){
If (p.MaxIndex()=1 && p.1=""){
for i,folder in #
DllCall("CloseHandle","Uint",@[folder].hD),DllCall("CloseHandle","Uint",@[folder].O.hEvent)
,@.Remove(folder)
#:=Object()
DirEvents:=new _Struct("HANDLE[1000]")
DllCall("KillTimer","Uint",0,"Uint",timer)
timer=
Return 0
} else {
if p.2
ReportToFunction:=p.2
If !IsFunc(ReportToFunction)
Return -1 ;DllCall("MessageBox","Uint",0,"Str","Function " ReportToFunction " does not exist","Str","Error Missing Function","UInt",0)
RegExMatch(p.1,"^([^/\*\?<>\|""]+)(\*)?(\|.+)?$",dir)
if (SubStr(dir1,0)="\")
StringTrimRight,dir1,dir1,1
StringTrimLeft,dir3,dir3,1
If (p.MaxIndex()=2 && p.2=""){
for i,folder in #
If (dir1=SubStr(folder,1,StrLen(folder)-1))
Return 0 ,DirEvents[i]:=DirEvents[#.MaxIndex()],DirEvents[#.MaxIndex()]:=0
@.Remove(folder),#[i]:=#[#.MaxIndex()],#.Remove(i)
Return 0
}
}
if !InStr(FileExist(dir1),"D")
Return -1 ;DllCall("MessageBox","Uint",0,"Str","Folder " dir1 " does not exist","Str","Error Missing File","UInt",0)
for i,folder in #
{
If (dir1=SubStr(folder,1,StrLen(folder)-1) || (InStr(dir1,folder) && @[folder].sD))
Return 0
else if (InStr(SubStr(folder,1,StrLen(folder)-1),dir1 "\") && dir2){ ;replace watch
DllCall("CloseHandle","Uint",@[folder].hD),DllCall("CloseHandle","Uint",@[folder].O.hEvent),reset:=i
}
}
LP:=SubStr(LP,1,DllCall("GetLongPathName","Str",dir1,"Uint",&LP,"Uint",VarSetCapacity(LP))) "\"
If !(reset && @[reset]:=LP)
#.Insert(LP)
@[LP,"dir"]:=LP
@[LP].hD:=DllCall("CreateFile","Str",StrLen(LP)=3?SubStr(LP,1,2):LP,"UInt",0x1,"UInt",0x1|0x2|0x4
,"UInt",0,"UInt",0x3,"UInt",0x2000000|0x40000000,"UInt",0)
@[LP].sD:=(dir2=""?0:1)

Loop,Parse,StringToRegEx,|
StringReplace,dir3,dir3,% SubStr(A_LoopField,1,1),% SubStr(A_LoopField,2),A
StringReplace,dir3,dir3,%A_Space%,\s,A
Loop,Parse,dir3,|
{
If A_Index=1
dir3=
pre:=(SubStr(A_LoopField,1,2)="\\"?2:0)
succ:=(SubStr(A_LoopField,-1)="\\"?2:0)
dir3.=(dir3?"|":"") (pre?"\\\K":"")
. SubStr(A_LoopField,1+pre,StrLen(A_LoopField)-pre-succ)
. ((!succ && !InStr(SubStr(A_LoopField,1+pre,StrLen(A_LoopField)-pre-succ),"\"))?"[^\\]*$":"") (succ?"$":"")
}
@[LP].FLT:="i)" dir3
@[LP].FUNC:=ReportToFunction
@[LP].CNG:=(p.3?p.3:(0x1|0x2|0x4|0x8|0x10|0x40|0x100))
If !reset {
@[LP].SetCapacity("pFNI",sizeof_FNI)
@[LP].FNI:=new _Struct(FILE_NOTIFY_INFORMATION,@[LP].GetAddress("pFNI"))
@[LP].O:=new _Struct(OVERLAPPED)
}
@[LP].O.hEvent:=DllCall("CreateEvent","Uint",0,"Int",1,"Int",0,"UInt",0)
If (!DirEvents)
DirEvents:=new _Struct("HANDLE[1000]")
DirEvents[reset?reset:#.MaxIndex()]:=@[LP].O.hEvent
DllCall("ReadDirectoryChangesW","UInt",@[LP].hD,"UInt",@[LP].FNI[""],"UInt",sizeof_FNI
,"Int",@[LP].sD,"UInt",@[LP].CNG,"UInt",0,"UInt",@[LP].O[""],"UInt",0)
Return timer:=DllCall("SetTimer","Uint",0,"UInt",timer,"Uint",50,"UInt",WatchDirectory)
} else {
Sleep, 0
for LP in reconnect
{
If (FileExist(@[LP].dir) && reconnect.Remove(LP)){
DllCall("CloseHandle","Uint",@[LP].hD)
@[LP].hD:=DllCall("CreateFile","Str",StrLen(@[LP].dir)=3?SubStr(@[LP].dir,1,2):@[LP].dir,"UInt",0x1,"UInt",0x1|0x2|0x4
,"UInt",0,"UInt",0x3,"UInt",0x2000000|0x40000000,"UInt",0)
DllCall("ResetEvent","UInt",@[LP].O.hEvent)
DllCall("ReadDirectoryChangesW","UInt",@[LP].hD,"UInt",@[LP].FNI[""],"UInt",sizeof_FNI
,"Int",@[LP].sD,"UInt",@[LP].CNG,"UInt",0,"UInt",@[LP].O[""],"UInt",0)
}
}
if !( (r:=DllCall("MsgWaitForMultipleObjectsEx","UInt",#.MaxIndex()
,"UInt",DirEvents[""],"UInt",0,"UInt",0x4FF,"UInt",6))>=0
&& r<#.MaxIndex() ){
return
}
DllCall("KillTimer", UInt,0, UInt,timer)
LP:=#[r+1],DllCall("GetOverlappedResult","UInt",@[LP].hD,"UInt",@[LP].O[""],"UIntP",nReadLen,"Int",1)
If (A_LastError=64){ ; ERROR_NETNAME_DELETED - The specified network name is no longer available.
If !FileExist(@[LP].dir) ; If folder does not exist add to reconnect routine
reconnect.Insert(LP,LP)
} else
Loop {
FNI:=A_Index>1?(new _Struct(FILE_NOTIFY_INFORMATION,FNI[""]+FNI.NextEntryOffset)):(new _Struct(FILE_NOTIFY_INFORMATION,@[LP].FNI[""]))
If (FNI.Action < 0x6){
FileName:=@[LP].dir . StrGet(FNI.FileName[""],FNI.FileNameLength/2,"UTF-16")
If (FNI.Action=FILE_ACTION_RENAMED_OLD_NAME)
FileFromOptional:=FileName
If (@[LP].FLT="" || RegExMatch(FileName,@[LP].FLT) || FileFrom)
If (FNI.Action=FILE_ACTION_ADDED){
FileTo:=FileName
} else If (FNI.Action=FILE_ACTION_REMOVED){
FileFrom:=FileName
} else If (FNI.Action=FILE_ACTION_MODIFIED){
FileFrom:=FileTo:=FileName
} else If (FNI.Action=FILE_ACTION_RENAMED_OLD_NAME){
FileFrom:=FileName
} else If (FNI.Action=FILE_ACTION_RENAMED_NEW_NAME){
FileTo:=FileName
}
If (FNI.Action != 4 && (FileTo . FileFrom) !="")
@[LP].Func(FileFrom=""?FileFromOptional:FileFrom,FileTo)
,FileFrom:="",FileFromOptional:="",FileTo:=""
}
} Until (!FNI.NextEntryOffset || ((FNI[""]+FNI.NextEntryOffset) > (@[LP].FNI[""]+sizeof_FNI-12)))
DllCall("ResetEvent","UInt",@[LP].O.hEvent)
DllCall("ReadDirectoryChangesW","UInt",@[LP].hD,"UInt",@[LP].FNI[""],"UInt",sizeof_FNI
,"Int",@[LP].sD,"UInt",@[LP].CNG,"UInt",0,"UInt",@[LP].O[""],"UInt",0)
timer:=DllCall("SetTimer","Uint",0,"UInt",timer,"Uint",50,"UInt",WatchDirectory)
Return
}
Return
}
