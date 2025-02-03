 .\tx.ps1 `
    -TenantId "your tenantid" `
    -ClientId "your client id" `
    -ClientSecret "your client secret value" `
    -UserUPN "onedrive user email id" `
    -StorageAccountName "your blob storage account name" `
    -ContainerName "Your Blob Storage containerName" `
    -StorageAccountKey "Your storage AccessKey" `
    -SourceOnedrivePath "testshare/myBook.xlsx" `
    -DestinationBlobPath "test1/myBook.xlsx"