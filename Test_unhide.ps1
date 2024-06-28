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

try{
# Descarca imaginea
$imageURL = "https://similarpng.com/wp-content/uploadPngfree/thumbnail/2024/02/Business-Technology-Digital-High-Tech-World-Background.png"
$outputPath = "$env:USERPROFILE\Downloads\unPwned.jpg" 
Invoke-WebRequest -Uri $imageURL -OutFile $outputPath 
Write-Output "Image downloaded successfully to $outputPath"

# Seteaza imaginea descarcata ca desktop background
[Wallpaper]::SystemParametersInfo(20, 0, "$env:USERPROFILE\Downloads\unPwned.jpg" , 3)
}
catch{}
