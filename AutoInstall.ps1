$IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
$CPUArch = (@{0="x86";1="MIPS";2="Alpha";3="PowerPC";5="ARM";6="Itanium-based systems";9="x64"})[[int](Get-WMIObject -Class Win32_Processor).Architecture]
$ComputerBrand = (Get-CimInstance -ClassName Win32_ComputerSystem).Manufacturer
$ComputerModel = (Get-CimInstance -ClassName Win32_ComputerSystem).Model

$Name = (Get-WmiObject -class Win32_OperatingSystem).Caption

$FullScriptPath = "$($PSCommandPath)"
$ScriptName = "$($PSScriptRoot)"
$ScriptPath = "$($MyInvocation.MyCommand.Name)"
 



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
  }


$Drivers_Utilities_Path = ".\$ComputerBrand\$ComputerModel\"
$Common_Drivers = "$Drivers_Utilities_Path\Common\"
$Third_Party = "$Drivers_Utilities_Path\Third-Party\"
# $Post-Install = ".\Post-Install\" Not implemented
$OS_Dir = "$($OS_Vers)_$($CPUArch)"
$Drivers_Dir = "$Drivers_Utilities_Path\$OS_Dir\"
$INF_Dir = "$($Drivers_Dir)\INF\"
$App_Dir = "$Drivers_Dir\App\"
$LogDir = "C:\ASRSAutoinstall\$($ComputerBrand)Logs"
$LogPath ="$LogDir\DriverInstallation.log"
$ListePilotes = $(Get-ChildItem $INF_Dir -Recurse -Filter "*.inf")
$ListeApp = $(Get-ChildItem $App_Dir -Recurse -Filter "Setup_APP.cmd")
$Liste3rdParty = $(Get-ChildItem $App_Dir -Recurse -Filter "*Setup.exe")

if(!(Test-Path -Path $LogDir ))
{
    New-Item -ItemType directory -Path $LogDir
}

write-host "Installation des pilotes"
ForEach ($Pilote in $ListePilotes)
{ 
echo "$(Get-Date) [Log TRACE]  pnputil /add-driver $Pilote.Name  /install" >> $LogPath
  try {
         $ PNPUtil.exe /add-driver $Pilote.FullName /install 
  }
# Si ça marche pas, on désinstalle avant.
  Catch {
        PNPUtil.Exe /delete-driver $Pilote.Fullname /uninstall /force
        PNPUtil.exe /add-driver $Pilote.FullName /install 
  }
}
echo "$(Get-Date) [Log TRACE]  Fin installation Pilotes " >> $LogPath
write-host "Pilote installé"
write-host "Installation des pilotes et logiciel supplémentaire"
echo "$(Get-Date) [Log TRACE]  installation Pilotes et logiciels 3rd party (intel) " >> $LogPath

ForEach ($3rdParty in $Liste3rdParty)
{ 
echo "$(Get-Date) [Log TRACE]  $3rdParty.name  -s " >> $LogPath

  & $3rdParty.FullName -s
}

echo "$(Get-Date) [Log TRACE] Fin installation Pilotes et logiciels 3rd party (intel) " >> $LogPath

echo "Fin installation Pilotes et logiciels 3rd party"

echo "$(Get-Date) [Log TRACE] début installation App (Acer) "  >> $LogPath
echo "début installation App (Acer)"



ForEach ($App in $ListeApp)
{ 
echo "$(Get-Date) [Log TRACE]  $App.name  -s " >> $LogPath

  & $App.FullName
}

echo "Vous devez redémarer"
