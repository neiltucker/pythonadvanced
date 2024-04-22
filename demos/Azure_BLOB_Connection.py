# Import the required libraries
# python -m pip install azure-storage-blob
from azure.storage.blob import BlobServiceClient, BlobClient, ContainerClient

# Set the connection string for the storage account, including the SAS token
connection_string = "YourStorageConnectionStringWithSASToken"
container_name = "YourContainerName

# Create a connection using the connection string
blob_service_client = BlobServiceClient.from_connection_string(connection_string)

# Create a new Blob storage file
blob_name = "aaablobfile.txt"
blob_client = BlobClient(blob_service_client.url, container_name, blob_name)
blob_client.upload_blob("File created with Python using Blob upload.", overwrite=True)

############################

import requests

url = "http://neiltucker.github.io"
request = requests.get(url)
print(request.status_code)



