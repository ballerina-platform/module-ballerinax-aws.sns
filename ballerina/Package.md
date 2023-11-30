[Amazon SNS](https://aws.amazon.com/sns/) is a message notification service provided by Amazon.com Inc., enabling users to publish messages to topics, which are then delivered to subscribing endpoints or clients.

The `ballerinax/aws.sns` package offers APIs to connect and interact with [AWS SNS API](https://docs.aws.amazon.com/sns/latest/api/welcome.html) endpoints.

## Quickstart

**Note**: Ensure you follow the [prerequisites](https://github.com/ballerina-platform/module-ballerinax-aws.sns#set-up-aws-sns-api) to set up the AWS SNS API.

To use the `aws.sns` connector in your Ballerina application, modify the `.bal` file as follows:

### Step 1: Import the connector
Import the `ballerinax/aws.sns` package into your Ballerina project.
```ballerina
import ballerinax/aws.sns;
```

### Step 2: Instantiate a new connector
Create a `sns:ConnectionConfig` record with the obtained `accessKeyId` and `secretAccessKey` and initialize the connector with it.
```ballerina
sns:ConnectionConfig config = {
    accessKeyId: accessKeyId,
    secretAccessKey: secretAccessKey,
    region: region
};

sns:Client amazonSNSClient = check new(config);
```

### Step 3: Invoke the connector operation
Now, utilize the available connector operations.
```ballerina
string topicArn = check amazonSNSClient->createTopic("FirstTopic");
```

For comprehensive information about the connector's functionality, configuration, and usage in Ballerina programs, refer to the `aws.sns` connector's reference guide in [Ballerina Central](https://central.ballerina.io/ballerinax/aws.sns/latest).

## Set up AWS SNS API

1. Create an [AWS account](https://portal.aws.amazon.com/billing/signup)

2. [Obtain access keys](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html)

3. For detailed steps, including necessary links, refer to the [setup guide](https://github.com/ballerina-platform/module-ballerinax-aws.sns/tree/master/docs/setup/setup.md).

## Report Issues
To report bugs, request new features, start new discussions, view project boards, etc., go to the [Ballerina library parent repository](https://github.com/ballerina-platform/ballerina-library).

## Useful Links
- Chat live with us via our [Discord server](https://discord.gg/ballerinalang).
- Post all technical questions on Stack Overflow with the [#ballerina](https://stackoverflow.com/questions/tagged/ballerina) tag.