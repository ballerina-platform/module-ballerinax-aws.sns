# Specification: Ballerina AWS SNS package

_Owners_: @kaneeldias \
_Reviewers_: @daneshk \
_Created_: 2022/11/15 \
_Updated_: 2023/11/15 \
_Edition_: Swan Lake

## Introduction

This is the specification for the `aws.sns` package of the [Ballerina language](https://ballerina.io). This package provides client functionalities to interact with the [AWS SNS API](https://docs.aws.amazon.com/sns/latest/api/welcome.html).

The `aws.sns` package specification has evolved and may continue to evolve in the future. The released versions of the specification can be found under the relevant GitHub tag.

If you have any feedback or suggestions about the package, start a discussion via a [GitHub issue](https://github.com/ballerina-platform/ballerina-standard-library/issues) or in the [Discord server](https://discord.gg/ballerinalang). Based on the outcome of the discussion, the specification and implementation can be updated. Community feedback is always welcome. Any accepted proposal, which affects the specification, is stored under `/docs/proposals`. Proposals under discussion can be found with the label `type/proposal` on GitHub.

The conforming implementation of the specification is released and included in the distribution. Any deviation from the specification is considered a bug.

## Contents

1.  [Overview](#1-overview)
2.  [Client](#2-client)
     * 2.1 [Initializing the client](#21-initializing-the-client)
3.  [Topics](#3-topics)
4.  [Publishing messages](#4-publishing-messages)
5.  [Subscriptions](#5-subscriptions)
6.  [Platform applications](#6-platform-applications)
7.  [Endpoints](#7-endpoints)
8.  [SMS sandbox phone numbers](#8-sms-sandbox-phone-numbers)
9.  [Origination numbers](#9-origination-numbers)
10. [Phone numbers](#10-phone-numbers)
11. [Tags](#11-tags)
12. [Permissions](#12-permissions)
13. [Data protection policies](#13-data-protection-policies)
14. [SMS attributes](#14-sms-attributes)

## 1. Overview

The Ballerina language offers first-class support for writing network-oriented programs. The `aws.sns` package leverages these language features to create a programming model for consuming the AWS SNS REST API.

It offers intuitive resource methods to interact with the [AWS SNS API](https://docs.aws.amazon.com/sns/latest/api/welcome.html).

## 2. Client

This section outlines the client of the Ballerina `aws.sns` package. To utilize the Ballerina `aws.sns` package, a user must first import it.

#### Example: Importing the AWS SNS package

```ballerina
import ballerinax/aws.sns;
```

The `sns:Client` allows you to connect to the AWS SNS RESTful API. The client currently supports the processing of 
`Topics`, `Publishing messages`, `Subscriptions`, `Platform applications`, `Endpoints`, `SMS sandbox phone numbers`, 
`Origination numbers`, `Phone numbers`, `Tags`, `Permissions`, `Data protection policies`, and `SMS attributes`. 
The client employs HTTP as the underlying protocol for communication with the API.

#### 2.1 Initializing the client

The `sns:Client` initialization method requires valid authentication credentials.

```ballerina
sns:ConnectionConfig config = {
    accessKeyId: accessKeyId,
    secretAccessKey: secretAccessKey,
    region: region
};

sns:Client amazonSNSClient = check new(config);
```

The `sns:Client` uses an `http:Client` as its underlying implementation. You can configure this `http:Client` by providing the `sns:ConnectionConfig` as a parameter during the `sns:Client` initialization.

## 3. Topics

A topic is a communication channel to send messages and subscribe to notifications.

A topic can have the following attributes.
```ballerina
# Represents the attributes of an Amazon SNS topic.
#
# + deliveryPolicy - The policy that defines how Amazon SNS retries failed deliveries to HTTP/S endpoints
# + displayName - The display name to use for a topic with SMS subscriptions
# + fifoTopic - Set to true to create a FIFO topic
# + policy - The policy that defines who can access your topic
# + signatureVersion - The signature version corresponds to the hashing algorithm used while creating the signature 
#                      of the notifications, subscription confirmations, or unsubscribe confirmation messages sent by
#                      Amazon SNS
# + tracingConfig - Tracing mode of an Amazon SNS topic
# + kmsMasterKeyId - The ID of an AWS-managed customer master key (CMK) for Amazon SNS or a custom CMK
# + contentBasedDeduplication - Enables content-based deduplication for FIFO topics. Applies only to FIFO topics
# + httpMessageDeliveryLogging - The configurations for message delivery logging for the HTTP delivery protocol
# + firehoseMessageDeliveryLogging - The configurations for message delivery logging for the Amazon Kinesis Data
#                                    Firehose delivery stream delivery protocol
# + lambdaMessageDeliveryLogging - The configurations for message delivery logging for the Lambda delivery protocol
# + applicationMessageDeliveryLogging - The configurations for message delivery logging for the application delivery
# + sqsMessageDeliveryLogging - The configurations for message delivery logging for the Amazon SQS delivery protocol
# + topicArn - The topic's ARN
# + effectiveDeliveryPolicy - The policy that defines how Amazon SNS retries failed deliveries to HTTP/S endpoints,
#                             taking system defaults into account.
# + owner - The AWS account ID of the topic's owner
# + policy - The policy that defines who can access your topic
# + subscriptionsConfirmed - The number of confirmed subscriptions for the topic
# + subscriptionsDeleted - The number of deleted subscriptions for the topic
# + subscriptionsPending - The number of subscriptions pending confirmation for the topic
public type TopicAttributes record {|

    // Initializable topic attributes
    json deliveryPolicy?;
    string displayName?;
    boolean fifoTopic?;
    json policy?;
    SignatureVersion signatureVersion?;
    TracingConfig tracingConfig?;
    string kmsMasterKeyId?;
    boolean contentBasedDeduplication?;
    MessageDeliveryLoggingConfig httpMessageDeliveryLogging?;
    MessageDeliveryLoggingConfig firehoseMessageDeliveryLogging?;
    MessageDeliveryLoggingConfig lambdaMessageDeliveryLogging?;
    MessageDeliveryLoggingConfig applicationMessageDeliveryLogging?;
    MessageDeliveryLoggingConfig sqsMessageDeliveryLogging?;
    
    // Retrievable topic attributes (read-only)
    string topicArn;
    json effectiveDeliveryPolicy;
    string owner;
    json policy;
    int subscriptionsConfirmed;
    int subscriptionsDeleted;
    int subscriptionsPending;
|};
```

You can create, list, retrieve, update and delete SNS topics using the relevant methods.

| Method                 | Description                             |
|------------------------|-----------------------------------------|
| `createTopic()`        | Creates a topic.                        |
| `deleteTopic()`        | Deletes a topic.                        |
| `listTopics()`         | Lists all available topics as a stream. |
| `getTopicAttributes()` | Retrieves the attributes of a topic.    |
| `setTopicAttributes()` | Updates the attributes of a topic.      |


#### Example: Retrieves all SNS topics as an array of strings

```ballerina
 stream<string, Error?> topicsStream = amazonSNSClient->listTopics();
 string[] topics = check from string topic in topicsStream
     select topic;
```

## 4. Publishing messages

A message can be published to a topic/phone number/endpoint using the `publish()` and `publishBatch()` methods. The user can define different messages to be published based on the target protocol.

```ballerina
public type Message string|MessageRecord;

public type MessageRecord record {|
    string default;
    string subject?;
    string email?;
    string emailJson?;
    string sqs?;
    string lambda?;
    string http?;
    string https?;
    string sms?;
    string firehose?;
    string apns?;
    string apnsSandbox?;
    string apnsVoip?;
    string apnsVoipSandbox?;
    string macos?;
    string macosSandbox?;
    string gcm?;
    string adm?;
    string baidu?;
    string mpns?;
    string wns?;
    string...;
|};
```

| Method           | Description                  |
|------------------|------------------------------|
| `publish()`      | Publishes a single message.  |
| `publishBatch()` | Publishes multiple messages. |

## 5. Subscriptions

Subscriptions are maintained as a list of endpoints for a topic. When a message is published to a topic, the message is sent to all the subscribed endpoints.

A subscription can have the following attributes.
```ballerina
# Represents the Amazon SNS subscription attributes.
# 
# + subscriptionArn - The subscription's ARN
# + endpoint - The subscription's endpoint (format depends on the protocol)
# + protocol - The subscription's protocol
# + topicArn - The ARN of the subscription's topic
# + subscriptionPrincipal - The subscription's principal
# + confirmationWasAuthenticated - Whether the subscription confirmation request was authenticated
# + deliveryPolicy - The policy that defines how Amazon SNS retries failed deliveries to HTTP/S endpoints
# + effectiveDeliveryPolicy - The policy that defines how Amazon SNS retries failed deliveries to HTTP/S endpoints, 
#                             taking system defaults into account
# + filterPolicy - The filter policy that is assigned to the subscription which lets the subscriber receive only a
#                  subset of the messages published to the topic
# + filterPolicyScope - Defines whether the filter policy is applied to the message attributes or the message body
# + owner - The AWS account ID of the owner of the subscription
# + pendingConfirmation - Whether the subscription has been confirmed
# + rawMessageDelivery - Whether raw message delivery is enabled for the subscription
# + redrivePolicy - The redrive policy attached to the subscription
# + subscriptionRoleArn - The ARN of the IAM role that has permission to write to the Kinesis Data Firehose delivery and
#                         has Amazon SNS listed as a trusted entity. Applies only to Amazon Kinesis Data Firehose
#                         delivery stream subscriptions.
public type SubscriptionAttributes record {
    string subscriptionArn;
    string endpoint;
    SubscriptionProtocol protocol;
    string topicArn;
    string subscriptionPrincipal;
    boolean confirmationWasAuthenticated;
    json deliveryPolicy?;
    json effectiveDeliveryPolicy?;
    json filterPolicy?;
    FilterPolicyScope filterPolicyScope?;
    string owner;
    boolean pendingConfirmation;
    boolean rawMessageDelivery;
    json redrivePolicy?;
    string subscriptionRoleArn?;
};
```

You can create, list, retrieve, update and delete SNS subscriptions using the relevant methods.

| Method                        | Description                                                            |
|-------------------------------|------------------------------------------------------------------------|
| `subscribe()`                 | Creates a subscription.                                                |
| `confirmSubscription()`       | Verifies a subscription with the consent of the owner of the endpoint. |
| `listSubscriptions()`         | Lists all subscriptions as a stream.                                   |
| `getSubscriptionAttributes()` | Retrieves the attributes of a subscription.                            |
| `setSubscriptionAttributes()` | Updates the attributes of a subscription.                              |
| `unsubscribe()`               | Deletes a subscription.                                                |


## 6. Platform applications

A platform application is an app that you register with a notification service, such as Apple Push Notification Service (APNS) and Google Cloud Messaging (GCM).

The following attributes are available for a platform application.

```ballerina
# Represents the attributes of an Amazon SNS platform appication.
#
# + enabled - Whether the platform application is enabled for direct publishing from Amazon SNS
# + appleCertificateExpiryDate - The expiry date of the SSL certificate used to configure certificate-based 
#                                authentication
# + applePlatformTeamId - The Apple developer account ID used to configure token-based authentication
# + applePlatformBundleId - The bundle identifier used to configure token-based authentication
# + eventEndpointCreated - The topic ARN to which `EndpointCreated` event notifications should be sent
# + eventEndpointDeleted - The topic ARN to which `EndpointDeleted` event notifications should be sent
# + eventEndpointUpdated - The topic ARN to which `EndpointUpdated` event notifications should be sent
# + eventDeliveryFailure - The topic ARN to which `DeliveryFailure` event notifications should be sent upon Direct
#                          Publish delivery failure (permanent) to one of the application's endpoints
# + successFeedbackRoleArn - The IAM role ARN used to give Amazon SNS write access to use CloudWatch Logs on your behalf
# + failureFeedbackRoleArn - The IAM role ARN used to give Amazon SNS write access to use CloudWatch Logs on your behalf
# + successFeedbackSampleRate - The percentage of success to sample (0-100)
# + platformCredential - The credential received from the notification service
# + platformPrincipal - The principal received from the notification service
# + applePlatformTeamId - The identifier that's assigned to your Apple developer account team
# + applePlatformBundleId - The bundle identifier that's used for APNs tokens
public type PlatformApplicationAttributes record {|
    boolean enabled;
    string appleCertificateExpiryDate?;
    string applePlatformTeamId?;
    string applePlatformBundleId?;
    string eventEndpointCreated?;
    string eventEndpointDeleted?;
    string eventEndpointUpdated?;
    string eventDeliveryFailure?;
    string successFeedbackRoleArn?;
    string failureFeedbackRoleArn?;
    int successFeedbackSampleRate?;
    string platformCredential?;
    string platformPrincipal?;
    string applePlatformTeamId?;
    string applePlatformBundleId?;
|};
```

You can create, list, retrieve, update and delete platform applications using the relevant methods.

| Method                               | Description                                         |
|--------------------------------------|-----------------------------------------------------|
| `createPlatformApplication()`        | Creates a platform application.                     |
| `listPlatformApplications()`         | Lists all platform applications.                    |
| `getPlatformApplicationAttributes()` | Retrieves the attributes of a platform application. |
| `setPlatformApplicationAttributes()` | Updates the attributes of a platform application.   |
| `deletePlatformApplication()`        | Deletes a platform application.                     |

## 7. Endpoints

An endpoint is an instance of a platform application that can receive messages from SNS.

The following attributes are available for an endpoint.

```ballerina
# Represents the attributes of an Amazon SNS platform application endpoint.
# 
# + customUserData - Arbitrary user data to associate with the endpoint
# + enabled - flag that enables/disables delivery to the endpoint
# + token - Unique identifier created by the notification service for an app on a device. The specific name for 
#           the token will vary, depending on which notification service is being used
public type EndpointAttributes record {|
    string customUserData?;
    boolean enabled?;
    string token?;
|};
```

You can create, list, retrieve, update and delete endpoints using the relevant methods.

| Method                    | Description                              |
|---------------------------|------------------------------------------|
| `createEndpoint()`        | Creates a platform application endpoint. |
| `listEndpoints()`         | Lists all endpoints.                     |
| `getEndpointAttributes()` | Retrieves the attributes of an endpoint. |
| `setEndpointAttributes()` | Updates the attributes of an endpoint.   |
| `deleteEndpoint()`        | Deletes an endpoint.                     |


## 8. SMS sandbox phone numbers

An SMS sandbox phone number is a phone number that's verified with Amazon SNS and that you can use to send SMS messages to test your app.

You can create, verify, list, and delete SMS sandbox phone numbers using the relevant methods.

| Method                        | Description                                         |
|-------------------------------|-----------------------------------------------------|
| `createSMSSandboxPhoneNumber()`| Creates an SMS sandbox phone number.                |
| `verifySMSSandboxPhoneNumber()`| Verifies an SMS sandbox phone number.               |
| `listSMSSandboxPhoneNumbers()`| Lists all SMS sandbox phone numbers.                |
| `deleteSMSSandboxPhoneNumber()`| Deletes an SMS sandbox phone number.                |

## 9. Origination numbers

An origination number is a long code, short code, or toll-free number that's assigned to your Amazon SNS account which is used to send SMS messages.

You can list origination numbers using the `listOriginationNumbers()` method.

## 10. Phone numbers

A phone number is a number to which messages can be sent to and subscriptions created for. The owner of the phone number may opt out of receiving messages from your account.

| Method                           | Description                                                      |
|----------------------------------|------------------------------------------------------------------|
| `listPhoneNumbersOptedOut()`     | Lists phone numbers that are ipted out out receiving messages.   |
| `checkIfPhoneNumberIsOptedOut()` | Check whether a phone number is opted out of receiving messages. |
| `optInPhoneNumber()`             | Opts in a phone number that is already opted out.                |  


## 11. Tags

Tags are key-value pairs that you can add to an Amazon SNS topic to categorize and manage topics.

| Method            | Description                      |
|-------------------|----------------------------------|
| `tagResource()`   | Adds tags to an SNS topic.       |
| `listTags()`      | Lists all tags for an SNS topic. |
| `untagResource()` | Removed tags from an SNS topic.  |  


## 12. Permissions

Permissions are used to grant access to SNS topics.

| Method               | Description                                               |
|----------------------|-----------------------------------------------------------|
| `addPermission()`    | Adds a statement to a topic's access control policy.      |
| `removePermission()` | Removes a statement from a topic's access control policy. |

## 13. Data protection policies

Amazon SNS uses data protection policies to select the sensitive data for which you want to scan, and the actions that you want to take to protect that data from being exchanged by your Amazon SNS topics.

| Method                      | Description                                              |
|-----------------------------|----------------------------------------------------------|
| `putDataProtectionPolicy()` | Creates or updates a data protection policy for a topic. |
| `getDataProtectionPolicy()` | Retrieves the data protection policy for a topic.        |

## 14. SMS attributes

SMS attributes are used to set the default settings for sending SMS messages and receiving daily SMS usage reports.

Following attributes are available for SMS attributes.

```ballerina
# Represents the attributes for sending SMS messages with Amazon SNS.
# 
# + monthlySpendLimit - The maximum amount in USD that you are willing to spend each month to send SMS messages. When
#                       Amazon SNS determines that sending an SMS message would incur a cost that exceeds this limit,
#                       it stops sending SMS messages within minutes
# + deliveryStatusIAMRole - The ARN of the IAM role that allows Amazon SNS to write logs about SMS deliveries in
#                           CloudWatch logs
# + deliveryStatusSuccessSamplingRate - The percentage of successful SMS deliveries for which Amazon SNS will write
#                                       logs in CloudWatch Logs
# + defaultSenderID - A string that is displayed as the sender on the receiving device
# + defaultSMSType - The type of SMS message that you will send by default
# + usageReportS3Bucket - The name of the Amazon S3 bucket to receive daily SMS usage reports from Amazon SNS
public type SMSAttributes record {|
    int monthlySpendLimit?;
    string deliveryStatusIAMRole?;
    int deliveryStatusSuccessSamplingRate?;
    string defaultSenderID?;
    SMSMessageType defaultSMSType?;
    string usageReportS3Bucket?;
|};
```

| Method                    | Description                           |
|---------------------------|---------------------------------------|
| `setSMSAttributes()`      | Sets the default SMS attributes.      |
| `getSMSAttributes()`      | Retrieves the default SMS attributes. |