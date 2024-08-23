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
        const ProgramName = event.queryStringParameters.ProgramName
        
        const params =  {
            Bucket: "level-up-fitness-storage-bucket33cf0-dev",
            Key: `public/UserPrograms/${UserID}/${ProgramName}.json`
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
    else if (event.path == "/getStandardProgramNames" && event.httpMethod == "GET") {
        const params = {
            Bucket: "level-up-fitness-storage-bucket33cf0-dev",
            Prefix: "public/StandardPrograms/"
        };

        try {
            const data = await s3.listObjectsV2(params).promise();

            const objectsList = data.Contents ? data.Contents.map(item => item.Key.split('/').pop()) : [];

            if (objectsList.length > 0) {
                objectsList.shift();
            }
            
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
    else if (event.path == "/leaveProgram" && event.httpMethod == "DELETE") {
        const UserID = event.queryStringParameters.UserID
        const ProgramName = event.queryStringParameters.ProgramName

        const params = {
            Bucket: "level-up-fitness-storage-bucket33cf0-dev",
            Key: `public/UserPrograms/${UserID}/${ProgramName}`
        }

        try {
            const response = await s3.deleteObject(params).promise()

            return {
                statusCode: 200,
                headers: {
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Headers": "*"
                },
                body: JSON.stringify("Success")
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
    else if (event.path == "/getUserProgramNames" && event.httpMethod == "GET") {
        const UserID = event.queryStringParameters.UserID;
    
        const params = {
            Bucket: "level-up-fitness-storage-bucket33cf0-dev",
            Prefix: `public/UserPrograms/${UserID}/`,
            Delimiter: "/"
        };
    
        try {
            const response = await s3.listObjectsV2(params).promise();
    
            console.log(response);

            const folderNames = response.CommonPrefixes ? response.CommonPrefixes.map(item => item.Prefix.split('/').filter(Boolean).pop()) : [];
    
            console.log(folderNames);
    
            return {
                statusCode: 200,
                headers: {
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Headers": "*"
                },
                body: JSON.stringify(folderNames)
            };
        } catch (error) {
            console.log(error);
    
            return {
                statusCode: 500,
                headers: {
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Headers": "*"
                },
                body: JSON.stringify(error)
            };
        }
    }    
    else if (event.path == "/getUserProgramFiles" && event.httpMethod == "GET") {
        const UserID = event.queryStringParameters.UserID;
        const FolderName = event.queryStringParameters.FolderName;
    
        const params = {
            Bucket: "level-up-fitness-storage-bucket33cf0-dev",
            Prefix: `public/UserPrograms/${UserID}/${FolderName}/`
        };
    
        try {
            const response = await s3.listObjectsV2(params).promise();
    
            console.log(response);
            
            const fileNames = response.Contents ? response.Contents.map(item => item.Key.split('/').pop()) : [];
    
            console.log(fileNames);
    
            return {
                statusCode: 200,
                headers: {
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Headers": "*"
                },
                body: JSON.stringify(fileNames)
            };
        } catch (error) {
            console.log(error);
    
            return {
                statusCode: 500,
                headers: {
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Headers": "*"
                },
                body: JSON.stringify(error)
            };
        }
    }
    
    return {
        statusCode: 200,
        headers: {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "*"
        },
        body: JSON.stringify('Hello from Lambda!')
    };
};
