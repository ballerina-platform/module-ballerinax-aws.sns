## Overview
The Ballerina AWS SNS provides the capability to manage topics and subscriptions in [AWS SNS](https://aws.amazon.com/sns/).

This module supports [Amazon SNS REST API](https://docs.aws.amazon.com/sns/latest/api/welcome.html) `2010-03-31` version.
 
## Prerequisites
Before using this connector in your Ballerina application, complete the following:
1. Create an [AWS account](https://portal.aws.amazon.com/billing/signup?nc2=h_ct&src=default&redirect_url=https%3A%2F%2Faws.amazon.com%2Fregistration-confirmation#/start)
2. [Obtain tokens](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html)

## Quickstart
To use the AWS SNS connector in your Ballerina application, update the .bal file as follows:

### Step 1: Import connector
Import the `ballerinax/aws.sns` module into the Ballerina project.
```ballerina
import ballerinax/aws.sns;
```
### Step 2: Create a new connector instance

You can now enter the credentials in the SNS client configuration and create the SNS client by passing the configuration as follows.

```ballerina
sns:LongTermCredentials longTermCredentials = {
    accessKey: "<ACCESS_KEY_ID>",
    secretKey: "<SECRET_ACCESS_KEY>"
};

sns:ConnectionConfig config = {
    credentials:longTermCredentials,
    region: <REGION>
};

sns:Client snsClient = check new (configuration);
```

### Step 3: Invoke connector operation

1. You can create a topic in SNS as follows with `createTopic` method for a preferred topic name and the required set of attributes.

    ```ballerina
    sns:TopicAttribute attributes = {
        displayName : "Test"
    };
    sns:CreateTopicResponse|error response = amazonSNSClient->createTopic(testTopic, attributes);
    if (response is sns:CreateTopicResponse) {
        log:printInfo("Created topic: " + response.toString());
    }
    ```
2. Use `bal run` command to compile and run the Ballerina program. 

**[You can find more samples here](https://github.com/ballerina-platform/module-ballerinax-aws.sns/tree/master/sns/samples)**
