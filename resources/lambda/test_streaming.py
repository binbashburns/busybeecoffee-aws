import pytest
import sys
import boto3
import json
# import streaming
from botocore.exceptions import ClientError
import logging

from .backup_helper import S3BackupFileUpdates
from .new_record_event_handler import NewDynamoDbEventHandler


s3 = boto3.client('s3')
event = {
	"Records": [{
		"eventID": "51a8b8e16e261cd2ad068cc03280921a",
		"eventName": "INSERT",
		"eventVersion": "1.1",
		"eventSource": "aws:dynamodb",
		"awsRegion": "us-east-1",
		"dynamodb": {
			"ApproximateCreationDateTime": 1592538735.0,
			"Keys": {
				"ID": {
					"N": "58"
				}
			},
			"NewImage": {
				"Category": {
					"S": "Traditional"
				},
				"Price": {
					"S": "2"
				},
				"Size": {
					"S": "Small"
				},
				"ID": {
					"N": "58"
				},
				"Beverage": {
					"S": "Brewed"
				}
			},
			"SequenceNumber": "5200000000064821726634",
			"SizeBytes": 56,
			"StreamViewType": "NEW_IMAGE"
		},
		"eventSourceARN": "arn:aws:dynamodb:us-east-1:764364320071:table/busybee-menu-database/stream/2020-06-19T03:22:23.139"
	}]
}

# from scripts.store_organizations import StoreAccountInfo 
def get_subaccount_session(account_id, region):
    """ Get boto3 session for account
    """
    print("Starting get_subaccount_session for {} {}".format(account_id, region))
    assume_role_response = boto3.Session(profile_name='my-sandbox')
    return assume_role_response

# @pytest.mark.skip(reason="test_accounts_are_stored_and_fetched: dont want it uploading objects to s3 all the time")
def test_menu_items_are_fetched():
    account_id = "764364320071"
    session = get_subaccount_session(account_id, "us-west-2")
    s3Client = session.client('s3')
    # s3://xgzy2-busybee-menu-backup/items.json
    try:
        # s3://xgzy2-busybee-menu-backup/items.json
        fileContents = s3Client.get_object(Bucket="a123-placeholder", Key='items.json')
        existing_items = json.loads(fileContents["Body"].read().decode())
        for put_request in existing_items['busybee-menu-database']:
            print(put_request['PutRequest'])

    except ClientError as e:
        logging.error(e)
        return False
    return True

def test_when_event_is_added():
    account_id = "764364320071"
    session = get_subaccount_session(account_id, "us-west-2")
    s3Client = session.client('s3')
    # s3://xgzy2-busybee-menu-backup/items.json
    try:
        # s3://xgzy2-busybee-menu-backup/items.json
        fileContents = s3Client.get_object(Bucket="a123-placeholder", Key='items.json')
        existing_items = json.loads(fileContents["Body"].read().decode())
        newRecordHandler = NewDynamoDbEventHandler(event)
        newPutRequestItem = newRecordHandler.getNewPutRequest()
       
        backupUpdater = S3BackupFileUpdates(bucketName="a123-placeholder", fileName="items.json")
        backupUpdater.add_or_update(databaseName = 'busybee-menu-database', existingRecords = existing_items, newRecord = newPutRequestItem)
        
        print(existing_items)

    except ClientError as e:
        logging.error(e)
        return False
    return True


def test_add_to_csv():
    account_id = "764364320071"
    session = get_subaccount_session(account_id, "us-west-2")
    s3Client = session.client('s3')
    try:
        # s3://xgzy2-busybee-menu-backup/items.json
        fileContents = s3Client.get_object(Bucket="leasu-busybee-menu-backup", Key='busybee_drink_menu.csv')
        csvData = fileContents["Body"].read().decode()
        newRecordHandler = NewDynamoDbEventHandler(event)
        newCsvRow = newRecordHandler.new_record_as_csv()
        csvData = csvData + "\n" + newCsvRow
        print(csvData)
        s3Client.put_object(Body = csvData, Bucket="leasu-busybee-menu-backup", Key='busybee_drink_menu.csv')
        
    except ClientError as e:
        logging.error(e)
        return False
    return True
