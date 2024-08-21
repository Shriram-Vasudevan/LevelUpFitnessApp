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
            const challengeName = item.Name;

            const endpointResponse = await pinpoint.getUserEndpoints({
                ApplicationId: applicationId,
                UserId: userId,
            }).promise();

            for (const endpoint of endpointResponse.EndpointsResponse.Item) {

                console.log(`The endpoint data: ${JSON.stringify(endpoint, null, 2)}`);

                const endpointId = endpoint.Id;
                console.log(`the endpointID is ${endpointId}`)
                await sendPushNotification(endpoint, challengeName);
            }
        }
    } catch (error) {
        console.error('Error processing challenges:', error);
    }
};

const sendPushNotification = async (endpoint, challengeName) => {
    const deviceToken = endpoint.Address;
    console.log(`Device token: ${deviceToken}`);

    const params = {
        ApplicationId: applicationId,
        MessageRequest: {
            Addresses: {
                [deviceToken]: { ChannelType: 'APNS_SANDBOX' },
            },
            MessageConfiguration: {
                APNSMessage: {
                    Body: `The ${challengeName} is ending soon!`,
                    Title: 'Come Back!',
                    Action: 'OPEN_APP',
                },
            },
        },
    };

    try {
        const result = await pinpoint.sendMessages(params).promise();

        console.log('Push notification response:', JSON.stringify(result, null, 2));
        
        const messageResponse = result.MessageResponse;
        const requestResult = messageResponse?.Result?.[deviceToken];
        console.log('Detailed response for the device token:', JSON.stringify(requestResult, null, 2));

    } catch (error) {
        console.error('Error sending push notification:', error);
    }
};
