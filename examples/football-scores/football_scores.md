# Football Scores

This use case shows how the AWS SNS API can be used to build an application that delivers live football scores to fans. This example leverages the topic, subscription, and message-filtering capabilities of the AWS SNS API so that each fan receives only the scores of matches involving the player they follow.

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

Additionally, set the subscriber email addresses in `main.bal` by replacing the `<MESSI_FAN_EMAIL>` and `<RONALDO_FAN_EMAIL>` placeholders.

## Run the example

Execute the following command to run the example:

```bash
bal run
```
