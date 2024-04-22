import json, csv, boto3, requests
from datetime import datetime

def lambda_handler(event, context):
   s3bucket = "covid19data2020"
   dt = datetime.now().strftime("%Y%m%d%H%M%S")
   filename = dt + "_data.csv"
   lambda_path = "/tmp/" + filename
   s3_path = "data/" + filename
   url = "https://corona.lmao.ninja/v2/jhucsse"
   response = requests.get(url)
   data = response.text
   json_load = json.loads(data)
   file = open(lambda_path,'w')
   csv_writer = csv.writer(file)
   count = 0
   for row in json_load:
      if count == 0:
         header = row.keys()
         csv_writer.writerow(header)
         count += 1
      csv_writer.writerow(row.values())

   file.close()
   
   s3 = boto3.resource('s3')
   s3.meta.client.upload_file(lambda_path, s3bucket, s3_path)
