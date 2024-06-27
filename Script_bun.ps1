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
$outputPath = "%userprofile%/Downloads\image.jpg" 
Invoke-WebRequest -Uri $imageUrl -OutFile $outputPath 
Write-Output "Image downloaded successfully to $outputPath"

# Minimizeaza toate aplicatiile care ruleaza
$shell = New-Object -ComObject Shell.Application
$shell.MinimizeAll()

# Seteaza imaginea descarcata ca desktop background
[Wallpaper]::SystemParametersInfo(20, 0, "%userprofile%/Downloads\image.jpg" , 3)

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

}

Catch {"Scriptul a returnat eroare"}
