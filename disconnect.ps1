# Check if the script is running with administrator privileges
if (-Not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "You need to run this script as an administrator."
    pause
    exit
}

# Check if an argument is provided
if ($args.Length -eq 0) {
    Write-Host "No argument was provided. Please provide the name of the disk to disconnect as an argument."
    pause
    exit
} else {
    # Access the first argument (index 0)
    $argumentValue = $args[0]

    # Check if the argument value is not empty
    if (![string]::IsNullOrEmpty($argumentValue)) {
        $DISK_CUSTOM_NAME = "$argumentValue"
        $csvFilePath = "disks.csv"

        # Read the CSV file
        $diskInfoList = Import-Csv -Path $csvFilePath

        # Find the record with the target disk number
        $targetDiskInfo = $diskInfoList | Where-Object { $_.CustomName -eq $DISK_CUSTOM_NAME }

        # Get the volume with the specified custom name
        $volume = Get-Volume | Where-Object { $_.FileSystemLabel -eq $DISK_CUSTOM_NAME }
        if ($volume) {
            $diskNumber = (Get-Partition | Where-Object { $_.DriveLetter -eq $volume.DriveLetter }).DiskNumber

            if ($diskNumber) {
                # Disconnect the disk
                Set-Disk -Number $diskNumber -IsOffline $true
                Write-Host "Disk with custom name '$DISK_CUSTOM_NAME' has been disconnected"
                if ($targetDiskInfo) { 
                    if ($diskNumber -ne $targetDiskInfo.DiskNumber) {
                        $targetDiskInfo.DiskNumber = $diskNumber
                        # Save updated record into the CSV file
                        $diskInfoList | Export-Csv -Path $csvFilePath -NoTypeInformation
                        Write-Host "Updated record into the CSV file"
                    }
                } else {
                    $diskInfo = [PSCustomObject]@{
                        CustomName = $DISK_CUSTOM_NAME
                        DiskNumber = $diskNumber
                    }
                    # Save new record into the CSV file
                    $diskInfo | Export-Csv -Path $csvFilePath -Append -NoTypeInformation
                    Write-Host "Saved a new record into the CSV file"
                }
            } else {
                Write-Host "Disk with custom name '$DISK_CUSTOM_NAME' found, but could not be disconnected."
            }
        } else {
            Write-Host "Disk with custom name '$DISK_CUSTOM_NAME' not found or could not be disconnected."
        }
    } else {
        Write-Host "The disk name value is empty."
    }
}
pause
