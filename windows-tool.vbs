Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("Shell.Application")

currentDir = fso.GetParentFolderName(WScript.ScriptFullName)
batPath = currentDir & "\bin\menu.bat"

If Not fso.FileExists(batPath) Then
    MsgBox "Erreur : repair.bat introuvable dans le dossier bin.", 16, "Repair Tool"
    WScript.Quit
End If

shell.ShellExecute "cmd.exe", "/k """ & batPath & """", currentDir, "runas", 1