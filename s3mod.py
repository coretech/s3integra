import boto3, json, os
from botocore.exceptions import NoCredentialsError





def s3up(secret_key,key_id,bucket_name,region,filename):

#secret_key = 'oCojrL0FdPwcPVGv+KE48hXftZSRf1VoHbn4uGHz'
#key_id = 'AKIA5I5O4T3ZPGAVVFHP'
#bucket_name = 'mytestsuperbucket190522'
#region = 'eu-central-1'
#file_upload =  'testdata.txt'

   s3 = boto3.client('s3', aws_access_key_id=key_id, aws_secret_access_key=secret_key)
   s3.upload_file(filename, bucket_name, filename)
   return("comlete")

#def s3del(secret_key,key_id,bucket_name,region,file_upload):
#
#   s3 = boto3.client('s3', aws_access_key_id=key_id, aws_secret_access_key=secret_key)
#   s3.delete_object(Bucket=bucket_name, Key=file_upload)
#   print("Delete comlete!")


