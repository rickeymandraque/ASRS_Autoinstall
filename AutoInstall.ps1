
$id = [System.Security.Principal.WindowsIdentity]::GetCurrent()

    $p = New-Object System.Security.Principal.WindowsPrincipal($id)

    if ($p.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator))
	{
$ARCH = $env:PROCESSOR_ARCHITECTURE
$Name = (Get-WmiObject -class Win32_OperatingSystem).Caption
$ComputerBrand = (Get-CimInstance -ClassName Win32_ComputerSystem).Manufacturer
$ComputerModel = (Get-CimInstance -ClassName Win32_ComputerSystem).Model
$LogDir = C:\ASRSAutoinstall\$($ComputerBrand)Logs
$LogPath="$LogDir\DriverInstallation.log"

function PSCommandPath() { return $PSCommandPath; }

if(!(Test-Path -Path $LogDir ))
{
    New-Item -ItemType directory -Path $LogDir
}
if ($ARCH -like "AMD64")
{
$CPU_Arch = 64
}
else
{
$CPU_Arch = 32
}

if ($Name -like "*Windows 10*")
{

$OS_Vers = "Win10"
}
elseif  ($Name -like "*Windows 11*")
{
$OS_Vers = "Win11"
}

else
{
echo "OS non-reconnu"
exit 1
}
$OS_Dir = "$ComputerBrand\$ComputerModel\$($OS_Vers)_$($CPU_Arch)"

		
$ListePilotes = Get-ChildItem ".\$OS_Dir" -Recurse -Filter "*.inf"
ForEach ($Pilote in $ListePilotes)
{ 
  try {
         $ PNPUtil.exe /add-driver $Pilote.FullName /install 
  }
# Si ça marche pas, on désinstalle avant.
  Catch {
        PNPUtil.Exe /delete-driver $Pilote.Fullname /uninstall /force
        PNPUtil.exe /add-driver $Pilote.FullName /install 
  }
}

  if ($($OS_Vers)_$($CPU_Arch) -like "Win10_64")
  {
  & ".\$OS_Dir\Turbo Boost_Intel\SetupME.exe" -s
  }
  echo "vous devez redémmarrer le PC"
  & PAUSE
	}
	else
	{
		echo "vous n'êtes pas en admin, relancer le script"
		& pause
	}
