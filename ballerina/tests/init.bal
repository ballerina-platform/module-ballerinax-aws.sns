configurable string accessKeyId = ?;
configurable string secretAccessKey = ?;
configurable string region = ?;

ConnectionConfig config = {
    accessKeyId: accessKeyId,
    secretAccessKey: secretAccessKey,
    region: region
};

Client amazonSNSClient = check new(config);
