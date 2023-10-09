import ballerina/time;
import ballerina/lang.regexp;

configurable string accessKeyId = ?;
configurable string secretAccessKey = ?;
configurable string region = ?;

ConnectionConfig config = {
    accessKeyId: accessKeyId,
    secretAccessKey: secretAccessKey,
    region: region
};

Client amazonSNSClient = check new(config);

string testRunId = regexp:replaceAll(re `[:.]`, time:utcToString(time:utcNow()), "");

configurable string testHttp = ?;
configurable string testHttps = ?;
configurable string testEmail = ?;
configurable string testPhoneNumber = ?;
configurable string testApplication = ?;
configurable string testIamRole = ?;

function isArn(string arn) returns boolean {
    return arn.startsWith("arn:aws:");
}