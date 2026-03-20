Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("Shell.Application")

currentDir = fso.GetParentFolderName(WScript.ScriptFullName)
batPath = currentDir & "\repair.bat"

If Not fso.FileExists(batPath) Then
    MsgBox "Erreur : repair.bat introuvable dans le meme dossier.", 16, "Erreur"
    WScript.Quit
End If

shell.ShellExecute "cmd.exe", "/c """ & batPath & """", currentDir, "runas", 1