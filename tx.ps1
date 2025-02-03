param (
    [Parameter(Mandatory=$true)]
    [string]$TenantId,
    [Parameter(Mandatory=$true)]
    [string]$ClientId,
    [Parameter(Mandatory=$true)]
    [string]$ClientSecret,
    [Parameter(Mandatory=$true)]
    [string]$UserUPN,
    [Parameter(Mandatory=$true)]
    [string]$StorageAccountName,
    [Parameter(Mandatory=$true)]
    [string]$ContainerName,
    [Parameter(Mandatory=$true)]
    [string]$StorageAccountKey,
    [Parameter(Mandatory=$true)]
    [string]$SourceOnedrivePath,
    [Parameter(Mandatory=$true)]
    [string]$DestinationBlobPath
)

try {
    # Authentication
    $secureClientSecret = ConvertTo-SecureString $ClientSecret -AsPlainText -Force
    $clientSecretCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $ClientId, $secureClientSecret
    Connect-MgGraph -TenantId $TenantId -ClientSecretCredential $clientSecretCredential

    # Get OneDrive ID
    $onedrive = Get-MgUserDrive -UserId $UserUPN
if (-not $onedrive.Id) {
        throw "Drive ID not found for user $UserUPN"
    }
    $driveId = $onedrive.Id.Split(' ')[0]

    # Get root folder
    $currentItem = Get-MgDriveRoot -DriveId $driveId

    # Split source path into segments
    $pathSegments = $SourceOnedrivePath.Split('/') | Where-Object { $_ -ne '' }

    # Navigate through folders
    foreach ($segment in $pathSegments) {
        $children = Get-MgDriveItemChild -DriveId $driveId -DriveItemId $currentItem.Id
        $currentItem = $children | Where-Object { $_.Name -eq $segment }
        
        if (-not $currentItem) {
            throw "Path segment '$segment' not found in OneDrive path"
        }
    }

    # Verify it's a file
    if (-not $currentItem.File) {
        throw "The path '$SourceOnedrivePath' is a directory, not a file"
    }

    # Download the file
    $fileName = [System.IO.Path]::GetFileName($SourceOnedrivePath)
    $localTempFile = Join-Path -Path $env:TEMP -ChildPath $fileName
    Get-MgDriveItemContent -DriveId $driveId -DriveItemId $currentItem.Id -OutFile $localTempFile
    Write-Host "Downloaded '$SourceonedrivePath' to temporary file: $localTempFile"

    # Upload to Blob Storage
$blobStorageContext = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey
    Set-AzStorageBlobContent -File $localTempFile `
        -Container $ContainerName `
        -Blob $DestinationBlobPath `
        -Context $blobStorageContext `
        -Force
    Write-Host "Uploaded to Azure Blob Storage at path: '$DestinationBlobPath'"

    # Cleanup
    Remove-Item -Path $localTempFile -Force
    Write-Host "Temporary file cleaned up"

} catch {
    Write-Host "Error: $_" -ForegroundColor Red
} finally {
    Disconnect-MgGraph -ErrorAction SilentlyContinue
}
