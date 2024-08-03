/* Amplify Params - DO NOT EDIT
	ENV
	REGION
	STORAGE_LEVELUPFITNESSCUSTOMPROGRAMREQUESTDB_ARN
	STORAGE_LEVELUPFITNESSCUSTOMPROGRAMREQUESTDB_NAME
	STORAGE_LEVELUPFITNESSCUSTOMPROGRAMREQUESTDB_STREAMARN
Amplify Params - DO NOT EDIT */

const AWS = require('aws-sdk');
const { DocumentClient } = require('aws-sdk/clients/dynamodb');
const { json } = require('stream/consumers');

const dynamoDb = new AWS.DynamoDB.DocumentClient();

/**
 * @type {import('@types/aws-lambda').APIGatewayProxyHandler}
 */
exports.handler = async (event) => {
    console.log(`EVENT: ${JSON.stringify(event)}`);

    if (event.path == "/createCustomProgramRequest" && event.httpMetod == "PUT") {
        const body = JSON.parse(event.body)
        const UserID = body.UserID
        const Time = body.Time
        const Description = event.Description

        const params = {
            TableName: "custom-program-request-db-dev",
            Item: {
                UserID: UserID,
                Time: Time,
                Description: Description
            }
        }
        try {
            const response = await dynamoDb.put(params).promise();

            return {
                statusCode: 200,
                headers: {
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Headers": "*"
                },
                body: JSON.stringify(response)
            };
        } catch (error) {
            return {
                statusCode: 500,
                headers: {
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Headers": "*"
                },
                body: JSON.stringify(`Operation Failed! Error: ${error}!`),
            };
        }
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
