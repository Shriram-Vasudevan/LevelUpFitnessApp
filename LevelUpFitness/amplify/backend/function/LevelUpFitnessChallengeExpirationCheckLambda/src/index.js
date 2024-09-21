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

    if (event.path == "/checkChallengeExpiry" && event.httpMethod == "DELETE") {
        console.log("checking challenge expiry")
        const UserID = event.queryStringParameters.UserID
        const currentDate = DateTime.utc().toISO();

        const params = {
            TableName: "user-challenges-list-db-dev",
            IndexName: "EndDateIndexGSI",
            KeyConditionExpression: "UserID = :userID AND EndDate < :currentDate",
            ExpressionAttributeValues: {
                ":userID": UserID,
                ":currentDate": currentDate
            }
        }
    
        try {
            const challenges = await dynamodb.query(params).promise()
            for (const challenge of challenges.Items) {
                console.log(JSON.stringify(challenge))
                const deleteParams = {
                    TableName: "user-challenges-list-db-dev",  
                    Key: {
                        UserID: UserID,
                        ChallengeTemplateID: challenge["ChallengeTemplateID"]
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
    }
    else if (event.path == "/leaveChallenge" && event.httpMethod == "DELETE") {
        console.log("checking challenge expiry")
        const UserID = event.queryStringParameters.UserID
        const ChallengeTemplateID = event.queryStringParameters.ChallengeTemplateID

        const params = {
            TableName: "user-challenges-list-db-dev",
            Key: {
                UserID: UserID,
                ChallengeTemplateID: ChallengeTemplateID 
            }
        }
    
        try {
            await dynamodb.delete(params).promise();

            return {
                statusCode: 200,
                headers: {
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Headers": "*"
                },
                body: JSON.stringify({
                    message: "Challenge successfully left",
                    UserID: UserID,
                    ChallengeTemplateID: ChallengeTemplateID
                }),
            }; 
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
