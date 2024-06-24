Add-Type -TypeDefinition @"
    using System;
    using System.Runtime.InteropServices;

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

[Wallpaper]::SystemParametersInfo(20, 0, "C:\Windows\Web\Wallpaper\Windows\img0.jpg" , 3)
