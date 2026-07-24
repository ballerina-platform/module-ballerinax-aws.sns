# Weather Alert Service

This use case shows how the AWS SNS API can be used to send weather alerts for multiple cities. This example leverages the topic, subscription, and multi-protocol publishing capabilities of the AWS SNS API so that users can subscribe to different cities and receive alerts for their city only, over email or SMS.

## Prerequisites

### 1. Setup AWS account

Refer to the [Setup guide](https://github.com/ballerina-platform/module-ballerinax-aws.sns/blob/main/README.md#setup-guide) to obtain necessary credentials (access key ID, secret access key, region).

### 2. Configuration

Create a `Config.toml` file in the example's root directory and provide your AWS account related configurations as follows:

```toml
accessKeyId = "<access-key-id>"
secretAccessKey = "<secret-access-key>"
region = "<region>"
```

Additionally, set your contact details in `main.bal` by replacing the `<YOUR_EMAIL>` and `<YOUR_PHONE_NUMBER>` placeholders.

## Run the example

Execute the following command to run the example:

```bash
bal run
```
