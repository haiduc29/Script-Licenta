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

$taskbarHwnd = [Taskbar]::FindWindow("Shell_TrayWnd", "")
[Taskbar]::ShowWindow($taskbarHwnd, [Taskbar]::SW_SHOW)

# Arata icons de pe desktop
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name HideIcons -Value 0

try{
# Descarca imaginea
$imageURL = "https://similarpng.com/wp-content/uploadPngfree/thumbnail/2024/02/Business-Technology-Digital-High-Tech-World-Background.png"
$outputPath = "C:\Users\ionut\Downloads\unPwned.jpg" 
Invoke-WebRequest -Uri $imageURL -OutFile $outputPath 
Write-Output "Image downloaded successfully to $outputPath"

# Seteaza imaginea descarcata ca desktop background
[Wallpaper]::SystemParametersInfo(20, 0, "C:\Users\ionut\Downloads\unPwned.jpg" , 3)


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
$cert = Import-PfxCertificate -FilePath $certPath -CertStoreLocation "Cert:\CurrentUser\My" -Password $certPassword

# Output the thumbprint of the imported certificate
$certThumbprint = $cert.Thumbprint
Write-Host "Imported certificate with thumbprint: $certThumbprint"

# Define the path to the folder to be encrypted
$folderPath = "C:\Users\ionut\Desktop\Test"

try {
    $decryptCommand = "cipher /d /s:`"$folderPath`""
    Invoke-Expression -Command $decryptCommand

    # Verify decryption status
    $verifyCommand = "cipher /c /s:`"$folderPath`""
    Invoke-Expression -Command $verifyCommand
} catch {
    Write-Error "Failed to decrypt folder: $_"
    exit
}

}
catch{}
