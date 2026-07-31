# Ballerina Amazon SNS Connector

[![Build](https://github.com/ballerina-platform/module-ballerinax-aws.sns/workflows/CI/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-aws.sns/actions?query=workflow%3ACI)
[![codecov](https://codecov.io/gh/ballerina-platform/module-ballerinax-aws.sns/branch/main/graph/badge.svg)](https://codecov.io/gh/ballerina-platform/module-ballerinax-aws.sns)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/ballerina-platform/module-ballerinax-aws.sns.svg)](https://github.com/ballerina-platform/module-ballerinax-aws.sns/commits/master)
[![GraalVM Check](https://github.com/ballerina-platform/module-ballerinax-aws.sns/actions/workflows/build-with-bal-test-graalvm.yml/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-aws.sns/actions/workflows/build-with-bal-test-graalvm.yml)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

[Amazon SNS](https://aws.amazon.com/sns/) is a message notification service provided by Amazon.com Inc., enabling users to publish messages to topics, which are then delivered to subscribing endpoints or clients.

## Overview

The `ballerinax/aws.sns` package offers APIs to connect and interact with [AWS SNS API](https://docs.aws.amazon.com/sns/latest/api/welcome.html) endpoints.

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

3. [Pod Identity / default credentials](https://github.com/ballerina-platform/module-ballerinax-aws.sns/tree/master/examples/pod-identity)
   This example shows how to use `DEFAULT_CREDENTIALS` to run the connector without explicit credentials — works with EKS Pod Identity, ECS task roles, EC2 instance profiles, and AWS environment variables.

## Issues and projects

The **Issues** and **Projects** tabs are disabled for this repository as this is part of the Ballerina library. To report bugs, request new features, start new discussions, view project boards, etc., visit the Ballerina library [parent repository](https://github.com/ballerina-platform/ballerina-library).

This repository only contains the source code for the package.

## Building from the source

### Prerequisites

1. Download and install Java SE Development Kit (JDK) version 21. You can download it from either of the following sources:

    - [Oracle JDK](https://www.oracle.com/java/technologies/downloads/)
    - [OpenJDK](https://adoptium.net/)

   > **Note:** After installation, remember to set the `JAVA_HOME` environment variable to the directory where JDK was installed.

2. Download and install [Ballerina Swan Lake](https://ballerina.io/).

3. Download and install [Docker](https://www.docker.com/get-started).

   > **Note**: Ensure that the Docker daemon is running before executing any tests.

4. Generate a Github access token with read package permissions, then set the following `env` variables:

    ```bash
   export packageUser=<Your GitHub Username>
   export packagePAT=<GitHub Personal Access Token>
    ```

### Build options

Execute the commands below to build from the source.

1. To build the package:

   ```bash
   ./gradlew clean build
   ```

2. To run the tests:

   ```bash
   ./gradlew clean test
   ```

3. To build the without the tests:

   ```bash
   ./gradlew clean build -x test
   ```

4. To debug package with a remote debugger:

   ```bash
   ./gradlew clean build -Pdebug=<port>
   ```

5. To debug with Ballerina language:

   ```bash
   ./gradlew clean build -PbalJavaDebug=<port>
   ```

6. Publish the generated artifacts to the local Ballerina central repository:

   ```bash
   ./gradlew clean build -PpublishToLocalCentral=true
   ```

7. Publish the generated artifacts to the Ballerina central repository:

   ```bash
   ./gradlew clean build -PpublishToCentral=true
   ```

## Contributing to Ballerina

As an open source project, Ballerina welcomes contributions from the community.

For more information, go to the [contribution guidelines](https://github.com/ballerina-platform/ballerina-lang/blob/master/CONTRIBUTING.md).

## Code of conduct

All contributors are encouraged to read the [Ballerina Code of Conduct](https://ballerina.io/code-of-conduct).

## Useful links

* For more information go to the [`aws.sns` package](https://lib.ballerina.io/ballerinax/aws.sns/latest).
* For example demonstrations of the usage, go to [Ballerina By Examples](https://ballerina.io/learn/by-example/).
* Chat live with us via our [Discord server](https://discord.gg/ballerinalang).
* Post all technical questions on Stack Overflow with the [#ballerina](https://stackoverflow.com/questions/tagged/ballerina) tag.
