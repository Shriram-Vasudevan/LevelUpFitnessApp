/* Amplify Params - DO NOT EDIT
	ENV
	REGION
Amplify Params - DO NOT EDIT */const AWS = require('aws-sdk');
const dynamodb = new AWS.DynamoDB.DocumentClient();
const { DateTime } = require('luxon');

/**
 * @type {import('@types/aws-lambda').APIGatewayProxyHandler}
 */
exports.handler = async (event) => {
    console.log(`EVENT: ${JSON.stringify(event)}`);

    const currentDate = DateTime.utc().toISO();

    const params = {
        TableName: "user-challenges-list-db-dev",
        IndexName: "EndDateIndexGSI",
        KeyConditionExpression: "EndDate < :currentDate",
        ExpressionAttributeValues: {
            ":currentDate": currentDate
        }
    }

    try {
        for (const challenge of challenges) {
            const deleteParams = {
                TableName: "user-challenges-list-db-dev",  
                Key: {
                    partitionKey: challenge["endDate"],
                }
            };
            await dynamodb.delete(deleteParams).promise();
        }
    } catch (error) {
        return {
            statusCode: 500,
            headers: {
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Headers": "*"
            },
            body: JSON.stringify(error),
        };
    }

    return {
        statusCode: 200,
        headers: {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "*"
        },
        body: JSON.stringify('Hello from Lambda!'),
    };
};
