Clear-Host

$Computer = $args[0]

#$Computer =  Read-Host "Computername"

$Ping = Test-Connection -ComputerName $Computer -Quiet -Count 1

if ($Ping -eq "true")
{
    $UserCredential = Get-Credential
  
    $computerSystem = get-wmiobject Win32_ComputerSystem -Computer $Computer -Credential $UserCredential
    $computerBIOS = get-wmiobject Win32_BIOS -Computer $Computer -Credential $UserCredential
    $computerOS = get-wmiobject Win32_OperatingSystem -Computer $Computer -Credential $UserCredential
    $computerCPU = get-wmiobject Win32_Processor -Computer $Computer -Credential $UserCredential
    $computerHDD = Get-WmiObject Win32_LogicalDisk -ComputerName $Computer -Filter drivetype=3 -Credential $UserCredential
    $computerNetwork = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE -ComputerName $Computer -Credential $UserCredential | Select-Object -Property MACAddress, IPAddress
    write-host "System Information for: " $computerSystem.Name -BackgroundColor DarkCyan
    "-------------------------------------------------------"
    "Manufacturer: " + $computerSystem.Manufacturer
    "Model: " + $computerSystem.Model
    "Serial Number: " + $computerBIOS.SerialNumber
    "CPU: " + $computerCPU.Name
    "HDD Capacity: "  + "{0:N2}" -f ($computerHDD.Size/1GB) + "GB"
    "HDD Space: " + "{0:P2}" -f ($computerHDD.FreeSpace/$computerHDD.Size) + " Free (" + "{0:N2}" -f ($computerHDD.FreeSpace/1GB) + "GB)"
    "RAM: " + "{0:N2}" -f ($computerSystem.TotalPhysicalMemory/1GB) + "GB"
    "MAC: " + $computerNetwork.MACAddress
    "IP: " + $computerNetwork.IPAddress
    "Operating System: " + $computerOS.caption + ", Service Pack: " + $computerOS.ServicePackMajorVersion
    "User logged In: " + $computerSystem.UserName
    "Last Reboot: " + $computerOS.ConvertToDateTime($computerOS.LastBootUpTime)
    ""
    "-------------------------------------------------------"
}

else
{
    Write-Host "\c04EJPC ist offline/c04EJ" 
}

