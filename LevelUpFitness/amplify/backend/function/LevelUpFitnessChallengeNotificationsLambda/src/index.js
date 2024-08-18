/* Amplify Params - DO NOT EDIT
	ENV
	REGION
	STORAGE_LEVELUPFITNESSUSERCHALLENGESDB_ARN
	STORAGE_LEVELUPFITNESSUSERCHALLENGESDB_NAME
	STORAGE_LEVELUPFITNESSUSERCHALLENGESDB_STREAMARN
Amplify Params - DO NOT EDIT */

const AWS = require('aws-sdk');
const dynamodb = new AWS.DynamoDB.DocumentClient();
const pinpoint = new AWS.Pinpoint();
const { DateTime } = require('luxon');

const applicationId = 'f711bc1ad025421f9ebcc25d39dfe943';

exports.handler = async (event) => {
    const now = DateTime.utc();
    const timeWindow = now.plus({ hours: 24 });

    const params = {
        TableName: "user-challenges-db-dev",
        FilterExpression: 'EndDate BETWEEN :start AND :end',
        ExpressionAttributeValues: {
            ':start': now.toISO(),
            ':end': timeWindow.toISO(),
        },
    };

    try {
        const response = await dynamodb.scan(params).promise();

        for (const item of response.Items) {
            const userId = item.UserID;
            const challengeName = item.ChallengeName;

            const endpointResponse = await pinpoint.getUserEndpoints({
                ApplicationId: applicationId,
                UserId: userId,
            }).promise();

            for (const endpoint of endpointResponse.EndpointsResponse.Item) {
                const endpointId = endpoint.Id;
                await sendPushNotification(endpointId, challengeName);
            }
        }
    } catch (error) {
        console.error('Error processing challenges:', error);
    }
};

const sendPushNotification = async (endpointId, challengeName) => {
    const params = {
        ApplicationId: applicationId,
        MessageRequest: {
            Addresses: {
                [endpointId]: { ChannelType: 'APNS' },
            },
            MessageConfiguration: {
                APNSMessage: {
                    Body: `Your challenge: '${challengeName}' is ending soon!`,
                    Title: 'Challenge Ending Soon',
                    Action: 'OPEN_APP',
                },
            },
        },
    };

    try {
        await pinpoint.sendMessages(params).promise();
    } catch (error) {
        console.error('Error sending push notification:', error);
    }
};
