/* Amplify Params - DO NOT EDIT
	ENV
	REGION
	STORAGE_LEVELUPFITNESSSTORAGE_BUCKETNAME
Amplify Params - DO NOT EDIT */

const AWS = require('aws-sdk')
const { S3Client } = require('aws-sdk/clients/s3')

const s3 = new AWS.S3();

/**
 * @type {import('@types/aws-lambda').APIGatewayProxyHandler}
 */
exports.handler = async (event) => {
    if (event.path == "/getUserProgram" && event.httpMethod == "GET") {
        const UserID = event.queryStringParameters.UserID

        const params =  {
            Bucket: "level-up-fitness-storage-bucket33cf0-dev",
            Key: `public/UserPrograms/${UserID}.json`
        }

        try {
            const data = await s3.getObject(params).promise()
            const programData = data.body.toString('utf-8')

            return {
                statusCode: 200,
                headers: {
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Headers": "*"
                },
                body: JSON.stringify(programData)
            };
        } catch (error) {
            console.log(error)
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
    else if (event.path == "/getStandardProgramNames", event.httpMethod == "GET") {
        const params =  {
            Bucket: "level-up-fitness-storage-bucket33cf0-dev",
            Prefix: "public/StandardPrograms/"
        }

        try {
            const data = s3.listObjectsV2(params).promise()

            const objectsList = data.Contents ? data.Contents.map(item => item.Key) : []

            return {
                statusCode: 200,
                headers: {
                  "Access-Control-Allow-Origin": "*",
                  "Access-Control-Allow-Headers": "*"
                },
                body: JSON.stringify(objectsList)
              };

        } catch (error) {
            console.log(error);
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
    else if (event.path == "/getStandardProgram" && event.httpMethod == "GET") {

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
