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
