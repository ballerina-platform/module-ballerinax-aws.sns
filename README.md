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

### Step 1: Create an AWS account

* If you don't already have an AWS account, you need to create one. Go to the [AWS Management Console](https://console.aws.amazon.com/console/home), click on "Create a new AWS Account," and follow the instructions.

### Step 2: Get the access key ID and the secret access key

Once you log in to your AWS account, you need to create a user group and a user with the necessary permissions to access SNS. To do this, follow the steps below:

1. Create an AWS user group

* Navigate to the Identity and Access Management (IAM) service. Click on "Groups" and then "Create New Group."

   <img src=https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-aws.sns/main/docs/setup/resources/create-group.png alt="Create user group" width="50%">

* Enter a group name and attach the necessary policies to the group. For example, you can attach the "AmazonSNSFullAccess" policy to provide full access to SNS.

   <img src=https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-aws.sns/main/docs/setup/resources/create-group-policies.png alt="Attach policy" width="50%">

2. Create an IAM user

* In the IAM console, navigate to "Users" and click on "Add user."

   <img src=https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-aws.sns/main/docs/setup/resources/create-user.png alt="Add user" width="50%">

* Enter a username, tick the "Provide user access to the AWS Management Console - optional" checkbox, and click "I want to create an IAM user". This will enable programmatic access through access keys.

   <img src=https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-aws.sns/main/docs/setup/resources/create-user-iam-user.png alt="Create IAM user" width="50%">

* Click through the permission setup, and add the user to the user group we previously created.

   <img src=https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-aws.sns/main/docs/setup/resources/create-user-set-permission.png alt="Attach user group" width="50%">

* Review the details and click "Create user."

   <img src=https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-aws.sns/main/docs/setup/resources/create-user-review.png alt="Review user" width="50%">

3. Generate access key ID and secret access key

* Once the user is created, you will see a success message. Navigate to the "Users" tab, and select the user you created.

   <img src=https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-aws.sns/main/docs/setup/resources/view-user.png alt="View User" width="50%">

* Click on the "Create access key" button to generate the access key ID and secret access key.

   <img src=https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-aws.sns/main/docs/setup/resources/create-access-key.png alt="Create access key" width="50%">

* Follow the steps and download the CSV file containing the credentials.

   <img src=https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-aws.sns/main/docs/setup/resources/download-access-key.png alt="Download credentials" width="50%">

## Quickstart

To use the `aws.sns` connector in your Ballerina project, modify the `.bal` file as follows:

### Step 1: Import the connector

Import the `ballerinax/aws.sns` package into your Ballerina project.
```ballerina
import ballerinax/aws.sns;
```

### Step 2: Instantiate a new connector

Instantiate a new `sns` client using the access key ID, secret access key, and region.
```ballerina
sns:Client sns = check new({
    credentials: {
        accessKeyId,
        secretAccessKey
    },
    region
});
```

### Step 3: Invoke the connector operation

Now, utilize the available connector operations.
```ballerina
string topicArn = check sns->createTopic("FirstTopic");
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

## Issues and projects

The **Issues** and **Projects** tabs are disabled for this repository as this is part of the Ballerina library. To report bugs, request new features, start new discussions, view project boards, etc., visit the Ballerina library [parent repository](https://github.com/ballerina-platform/ballerina-library).

This repository only contains the source code for the package.

## Building from the source

### Prerequisites

1. Download and install Java SE Development Kit (JDK) version 17. You can download it from either of the following sources:

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
