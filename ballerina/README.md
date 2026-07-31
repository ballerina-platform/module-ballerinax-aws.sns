## Overview

[Amazon SNS](https://aws.amazon.com/sns/) (Simple Notification Service) is a fully managed messaging service for both application-to-application (A2A) and application-to-person (A2P) communication. It enables developers to send notifications from their applications to various endpoints, including email, SMS, and mobile push, as well as to other AWS services like SQS, Lambda, and HTTP/S webhooks.

The Amazon SNS connector offers APIs to connect and interact with [Amazon SNS REST API](https://docs.aws.amazon.com/sns/latest/api/welcome.html) endpoints.

### Key Features

- Create, list, and delete topics
- Manage subscriptions and permissions
- Publish messages to topics or directly to endpoints
- Support for SMS and mobile push notifications
- Flexible credential configuration: static keys, AWS credentials file profiles, or the default AWS credential provider chain (EKS Pod Identity, ECS task roles, EC2 instance profiles, environment variables)
- GraalVM compatible for native image builds

## Setup guide

### Obtain IAM user credentials

To create an IAM user and generate an access key, follow the [obtaining IAM user credentials](https://central.ballerina.io/ballerinax/aws/latest#obtaining-iam-user-credentials) guide.

Attach the SNS permissions your application needs to the user — the AWS managed `AmazonSNSFullAccess` policy grants full access, or scope a custom policy to only the SNS actions you call (for example, `sns:CreateTopic`, `sns:Publish`, and `sns:Subscribe`).

## Quickstart

To use the `aws.sns` connector in your Ballerina project, modify the `.bal` file as follows:

### Step 1: Import the connector

Import the `ballerinax/aws.sns` package into your Ballerina project.
```ballerina
import ballerinax/aws;
import ballerinax/aws.sns;
```

### Step 2: Instantiate a new connector

The `sns:Client` accepts a `ConnectionConfig` with a `credentials` field that supports standard authentication modes.

#### Option 1: Static credentials

Use explicit AWS credentials. Suitable for local development and environments where credentials are managed directly.

```ballerina
sns:Client snsClient = check new ({
   credentials: {
      accessKeyId: "<AWS_ACCESS_KEY_ID>",
      secretAccessKey: "<AWS_SECRET_ACCESS_KEY>"
   },
   region: aws:US_EAST_1
});
```

For temporary credentials (e.g., from `aws sts get-session-token`), include the session token:

```ballerina
sns:Client snsClient = check new ({
   credentials: {
      accessKeyId: "<AWS_ACCESS_KEY_ID>",
      secretAccessKey: "<AWS_SECRET_ACCESS_KEY>",
      sessionToken: "<AWS_SESSION_TOKEN>"
   },
   region: aws:US_EAST_1
});
```

#### Option 2: AWS credentials file profile

Use a named profile from your `~/.aws/credentials` file. Suitable for developer workstations with multiple AWS accounts.

```ballerina
sns:Client snsClient = check new ({
   credentials: {
      profileName: "<PROFILE_NAME>",
      credentialsFilePath: "~/.aws/credentials"
   },
   region: aws:US_EAST_1
});
```

#### Option 3: Default credential provider chain

Use `auth:DEFAULT_CREDENTIALS` to let the connector automatically resolve credentials from the environment. This is the recommended approach for AWS-managed environments.

```ballerina
sns:Client snsClient = check new ({
   credentials: auth:DEFAULT_CREDENTIALS,
   region: aws:US_EAST_1
});
```

The standard default credential provider chain tries each of the following in order and takes the first source that yields credentials:

1. Environment variables (`AWS_ACCESS_KEY_ID`/`AWS_SECRET_ACCESS_KEY`, and `AWS_WEB_IDENTITY_TOKEN_FILE` if set)
2. The shared config/credentials file's active profile (`AWS_PROFILE`, or `default` if unset) — which may itself resolve via SSO, an external process, or a chained `AssumeRole` call, depending on that profile's configuration
3. Container credentials (ECS/EKS)
4. EC2 instance profile (IMDS)

> **Note:** Beyond the three options above, the `credentials` field also accepts `auth:AssumeRoleConfig` (STS assume-role), `auth:WebIdentityConfig` (web identity / OIDC), `auth:SsoAuthConfig` (IAM Identity Center), and `auth:ProcessAuthConfig` (external credential process). See the [`Ballerina AWS`](https://central.ballerina.io/ballerinax/aws/latest) documentation for details.

### Step 3: Invoke the connector operation

Now, utilize the available connector operations.
```ballerina
string topicArn = check snsClient->createTopic("FirstTopic");
```

### Step 4: Run the Ballerina application

Use the following command to compile and run the Ballerina program.

```bash
bal run
```

## Examples

The `sns` connector provides practical examples illustrating usage in various scenarios. Explore these [examples](https://github.com/ballerina-platform/module-ballerinax-aws.sns/tree/master/examples).

1. [Football scores](https://github.com/ballerina-platform/module-ballerinax-aws.sns/tree/master/examples/football-scores)
   This example shows how to use SNS to implement an application to subscribe to receive football game scores.

2. [Weather alert service](https://github.com/ballerina-platform/module-ballerinax-aws.sns/tree/master/examples/weather-alert)
   This example shows how to use SNS to send weather alerts for multiple cities. Users can subscribe to different cities to receive alerts for their city only.
