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


Function Unprotect-File
{
[CmdletBinding(DefaultParameterSetName='SecureString')]
[OutputType([System.IO.FileInfo[]])]
Param(
    [Parameter(Mandatory=$true, Position=1, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
    [Alias('PSPath','LiteralPath')]
    [string[]]$FileName,
    [Parameter(Mandatory=$false, Position=2, ValueFromPipelineByPropertyName=$true)]
    [ValidateSet('AES','DES','RC2','Rijndael','TripleDES')]
    [String]$Algorithm = 'AES',
    [Parameter(Mandatory=$true, Position=3, ValueFromPipelineByPropertyName=$true, ParameterSetName='SecureString')]
    [System.Security.SecureString]$Key,
    [Parameter(Mandatory=$true, Position=3, ParameterSetName='PlainText')]
    [String]$KeyAsPlainText,
    [Parameter(Mandatory=$false, Position=4, ValueFromPipelineByPropertyName=$true)]
    [System.Security.Cryptography.CipherMode]$CipherMode = 'CBC',
    [Parameter(Mandatory=$false, Position=5, ValueFromPipelineByPropertyName=$true)]
    [System.Security.Cryptography.PaddingMode]$PaddingMode = 'PKCS7',
    [Parameter(Mandatory=$false, Position=6)]
    [String]$Suffix, #Assigning default value in code due to it not processing ".$Algorithm" properly when Algorithm is ValueFromPipelineByPropertyName
    [Parameter()]
    [Switch]$RemoveSource
)
    Process
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
            $Crypto.Mode = $CipherMode
            $Crypto.Padding = $PaddingMode
            $Crypto.KeySize = $EncryptionKey.Length*8
            $Crypto.Key = $EncryptionKey
        }
        Catch
        {
            Write-Error $_ -ErrorAction Stop
        }

        if(-not $PSBoundParameters.ContainsKey('Suffix'))
        {
            $Suffix = ".$Algorithm"
        }

        #Used to store successfully decrypted file names.
        $Files = Get-Item -LiteralPath $FileName

        ForEach($File in $Files)
        {
            #Verify file ends with supplied suffix
            If(-not $File.Name.EndsWith($Suffix))
            {
                Write-Error "$($File.FullName) does not have an extension of '$Suffix'."
                Continue
            }

            $DestinationFile = $File.FullName -replace "$Suffix$"

            Try
            {
                $FileStreamReader = New-Object System.IO.FileStream($File.FullName, [System.IO.FileMode]::Open)
                $FileStreamWriter = New-Object System.IO.FileStream($DestinationFile, [System.IO.FileMode]::Create)

                #Get IV from file
                [Byte[]]$LenIV = New-Object Byte[] 4
                $FileStreamReader.Seek(0, [System.IO.SeekOrigin]::Begin) | Out-Null
                $FileStreamReader.Read($LenIV,  0, 3) | Out-Null
                [Int]$LIV = [System.BitConverter]::ToInt32($LenIV,  0)
                [Byte[]]$IV = New-Object Byte[] $LIV
                $FileStreamReader.Seek(4, [System.IO.SeekOrigin]::Begin) | Out-Null
                $FileStreamReader.Read($IV, 0, $LIV) | Out-Null
                $Crypto.IV = $IV

                #Peform Decryption
                $Transform = $Crypto.CreateDecryptor()
                $CryptoStream = New-Object System.Security.Cryptography.CryptoStream($FileStreamWriter, $Transform, [System.Security.Cryptography.CryptoStreamMode]::Write)
                $FileStreamReader.CopyTo($CryptoStream)

                #Close open files
                $CryptoStream.FlushFinalBlock()
                $CryptoStream.Close()
                $FileStreamReader.Close()
                $FileStreamWriter.Close()

                #Delete encrypted file
                if($RemoveSource){Remove-Item $File.FullName}

                #Output decrypted file
                Get-Item $DestinationFile | Add-Member –MemberType NoteProperty –Name SourceFile –Value $File.FullName -PassThru
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



$taskbarHwnd = [Taskbar]::FindWindow("Shell_TrayWnd", "")
[Taskbar]::ShowWindow($taskbarHwnd, [Taskbar]::SW_SHOW)


try{
# Descarca imaginea
$imageURL = "https://similarpng.com/wp-content/uploadPngfree/thumbnail/2024/02/Business-Technology-Digital-High-Tech-World-Background.png"
$outputPath = "C:\Users\ionut\Downloads\unPwned.jpg" 
Invoke-WebRequest -Uri $imageURL -OutFile $outputPath 
Write-Output "Image downloaded successfully to $outputPath"

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

#Protect-File "C:\Users\ionut\Desktop\Test\test1.txt" -Algorithm AES -Key $key -RemoveSource 

for ($i=0; $i -lt $files.Count; $i++) {
    $outfile = $files[$i].FullName
    Unprotect-File $outfile -Algorithm AES -Key $key -RemoveSource 
}

Stop-Transcript

# Unhide icons on desktop
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name HideIcons -Value 0

}
catch{}
