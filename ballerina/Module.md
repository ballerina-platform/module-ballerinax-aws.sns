# Ballerina Amazon SNS Connector

[![Build](https://github.com/ballerina-platform/module-ballerinax-aws.sns/workflows/CI/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-aws.sns/actions?query=workflow%3ACI)
[![codecov](https://codecov.io/gh/ballerina-platform/module-ballerinax-aws.sns/branch/main/graph/badge.svg)](https://codecov.io/gh/ballerina-platform/module-ballerinax-aws.sns)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/ballerina-platform/module-ballerinax-aws.sns.svg)](https://github.com/ballerina-platform/module-ballerinax-aws.sns/commits/master)
[![GraalVM Check](https://github.com/ballerina-platform/module-ballerinax-aws.sns/actions/workflows/build-with-bal-test-native.yml/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-aws.sns/actions/workflows/build-with-bal-test-native.yml)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

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