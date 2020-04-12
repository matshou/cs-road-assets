file := "de/asset_list.txt"
FileRead, LoadedText, %file%
oText := StrSplit(LoadedText, "`n")
index = 1

`::
asset=% oText[index]
clipboard := % asset
RunWait, update.sh de --stage %asset%, Hide
index+=1
return

Alt::
Send, 101
return
