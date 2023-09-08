# Check if the script is running with administrator privileges
if (-Not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "You need to run this script as an administrator."
    pause
    exit
}

# Check if an argument is provided
if ($args.Length -eq 0) {
    Write-Host "No argument was provided. Please provide the name of the disk to reconnect as an argument."
    pause
    exit
} else {
    # Access the first argument (index 0)
    $argumentValue = $args[0]

    # Check if the argument value is not empty
    if (![string]::IsNullOrEmpty($argumentValue)) {
        $DISK_CUSTOM_NAME = "$argumentValue"

        # Import disk information from the CSV file
        $diskInfo = Import-Csv -Path "disks.csv" | Where-Object { $_.CustomName -eq $DISK_CUSTOM_NAME }

        if ($diskInfo) {
            # Reconnect the disk using the stored disk number
            Set-Disk -Number $diskInfo.DiskNumber -IsOffline $false
            Write-Host "Disk with custom name '$DISK_CUSTOM_NAME' has been reconnected."
        } else {
            Write-Host "Disk with custom name '$DISK_CUSTOM_NAME' not found in the CSV file or could not be reconnected."
        }
    }
}
pause
