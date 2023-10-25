import ballerina/time;

# The hashing algorithm used while creating the signature of the notifications, subscription confirmations, or 
# unsubscribe confirmation messages sent by Amazon SNS.
# 
# + SignatureVersion1 - Amazon SNS creates the signature based on the SHA1 hash of the message
# + SignatureVersion2 - Amazon SNS creates the signature based on the SHA256 hash of the message
public enum SignatureVersion {
    SignatureVersion1 = "1",
    SignatureVersion2 = "2"
}

# The function that Amazon SNS uses to calculate the time to wait between retries.
public enum BackoffFunction {
    ARITHMETIC = "arithmetic",
    EXPONENTIAL = "exponential",
    GEOMETRIC = "geometric",
    LINEAR = "linear"
}

# The content type of the notification being sent to HTTP/S endpoints.
public enum HeaderContentType {
    TEXT_CSS = "text/css",
    TEXT_CSV = "text/csv",
    TEXT_HTML = "text/html",
    TEXT_PLAIN = "text/plain",
    TEXT_XML = "text/xml",
    APPLICATION_ATOM_XML = "application/atom+xml",
    APPLICATION_JSON = "application/json",
    APPLICATION_OCTET_STREAM = "application/octet-stream",
    APPLICATION_SOAP_XML = "application/soap+xml",
    APPLICATION_X_WWW_FORM_URLENCODED = "application/x-www-form-urlencoded",
    APPLICATION_XHTML_XML = "application/xhtml+xml",
    APPLICATION_XML = "application/xml"
}

public enum TracingConfig {
    PASS_THROUGH = "PassThrough",
    ACTIVE = "Active"
}

# The types of targets to which a message can be published.
public enum TargetType {
    TOPIC,
    ARN,
    PHONE_NUMBER
}

# The scopes to which a subscription filter policy can be applied to.
public enum FilterPolicyScope {
    MESSAGE_ATTRIBUTES = "MessageAttributes",
    MESSAGE_BODY = "MessageBody"
}

# The possible subscription protocols.
public enum SubscriptionProtocol {
    HTTP = "http",
    HTTPS = "https",
    EMAIL = "email",
    EMAIL_JSON = "email-json",
    SMS = "sms",
    SQS = "sqs",
    APPLICATION = "application",
    LAMBDA = "lambda",
    FIREHOSE = "firehose"
}

# The types of application platforms supported.
public enum Platform {
    AMAZON_DEVICE_MESSAGING = "ADM",
    APPLE_PUSH_NOTIFICATION_SERVICE = "APNS",
    APPLE_PUSH_NOTIFICATION_SERVICE_SANDBOX = "APNS_SANDBOX",
    FIREBASE_CLOUD_MESSAGING = "GCM",
    BAIDU_CLOUD_PUSH = "BAIDU",
    MICROSOFT_PUSH_NOTIFICATION_SERVICE = "MPNS",
    WINDOWS_NOTIFICATION_SERVICE = "WNS"
};

# The types of actions that can be performed on a topic.
# https://docs.aws.amazon.com/sns/latest/dg/sns-access-policy-language-api-permissions-reference.html
public enum Action {
    ADD_PERMISSION = "AddPermission",
    DELETE_TOPIC = "DeleteTopic",
    GET_DATA_PROTECTION_POLICY = "GetDataProtectionPolicy",
    GET_TOPIC_ATTRIBUTES = "GetTopicAttributes",
    LIST_SUBSCRIPTIONS = "ListSubscriptionsByTopic",
    LIST_TAGS = "ListTagsForResource",
    PUBLISH = "Publish",
    PUT_DATA_PROTECTION_POLICY = "PutDataProtectionPolicy",
    REMOVE_PERMISSION = "RemovePermission",
    SET_TOPIC_ATTRIBUTES = "SetTopicAttributes",
    SUBSCRIBE = "Subscribe"
};

# The languages supported by Amazon SNS for sending SMS OTP messages.
public enum LanguageCode {
    EN_US = "en-US",
    EN_GB = "en-GB",
    ES_419 = "es-419",
    ES_ES = "es-ES",
    DE_DE = "de-DE",
    FR_CA = "fr-CA",
    FR_FR = "fr-FR",
    IT_IT = "it-IT",
    JA_JP = "ja-JP",
    PT_BR = "pt-BR",
    KR_KR = "kr-KR",
    ZH_CN = "zh-CN",
    ZH_TW = "zh-TW"
};

# The types of phone number verification status.
public enum Status {
    PENDING = "Pending",
    VERIFIED = "Verified"
};

# The types of capabilities supported by an origination phone number.
public enum NumberCapabilities {
    _SMS = "SMS",
    MMS,
    VOICE
};

# The types of routes supported by an origination phone number.
public enum RouteType {
    TRANSACTIONAL = "Transactional",
    PROMOTIONAL = "Promotional",
    PREMIUM = "Premium"
};

# The types of SMS messages that may be sent.
public enum SMSMessageType {
    PROMOTIONAL = "Promotional",
    TRANSACTIONAL = "Transactional"
};

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

// TODO: convert fifo to ENUM (Standard/FIFO)
public type InitializableTopicAttributes record {|
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
|};

public type MessageDeliveryLoggingConfig record {|
    string successFeedbackRoleArn?;
    string failureFeedbackRoleArn?;
    int successFeedbackSampleRate?;
|};

# Represents the attributes of an Amazon SNS topic.
#
# + fifoTopic - not settable
public type SettableTopicAttributes record {|
    *InitializableTopicAttributes;
    never fifoTopic?;
|};


// # Represents the message delivery retry policies which defines how Amazon SNS retries the delivery of messages when
// # server-side errors occur for HTTP/S endpoints. When the delivery policy is exhausted, Amazon SNS stops retrying the 
// # delivery and discards the message—unless a dead-letter queue is attached to the subscription
// # 
// # + minDelayTarget - The minimum delay for a retry (in seconds)
// # + maxDelayTarget - The maximum delay for a retry (in seconds)
// # + numRetries - The total number of retries, including immediate, pre-backoff, backoff, and post-backoff
// # + numNoDelayRetries - The number of retries to be done immediately, with no delay between them
// # + numMinDelayRetries - The number of retries in the pre-backoff phase, with the specified minimum delay between them
// # + numMaxDelayRetries - The number of retries in the post-backoff phase, with the maximum delay between them
// # + backoffFunction - The model for backoff between retries
// # + maxReceivesPerSecond - The maximum number of deliveries per second, per subscription
// # + headerContentType - The content type of the notification being sent to HTTP/S endpoints	
// public type DeliveryPolicy record {|
//     record {|
//         record {|
//             int minDelayTarget?;
//             int maxDelayTarget?;
//             int numRetries?;
//             int numNoDelayRetries?;
//             int numMinDelayRetries?;
//             int numMaxDelayRetries?;
//             BackoffFunction backoffFunction?;
//         |} defaultHealthyRetryPolicy?;
//         boolean disableSubscriptionOverrides?;
//         record {|
//             string headerContentType?;
//         |} defaultRequestPolicy?;
//     |} http;
// |};

# Represents an Amazon SNS topic.
#
# + topicArn - The topic's ARN
# + effectiveDeliveryPolicy - The policy that defines how Amazon SNS retries failed deliveries to HTTP/S endpoints,
#                             taking system defaults into account.
# + owner - The AWS account ID of the topic's owner
# + policy - The policy that defines who can access your topic
# + subscriptionsConfirmed - The number of confirmed subscriptions for the topic
# + subscriptionsDeleted - The number of deleted subscriptions for the topic
# + subscriptionsPending - The number of subscriptions pending confirmation for the topic
public type GettableTopicAttributes record {
    *InitializableTopicAttributes;
    string topicArn;
    json effectiveDeliveryPolicy;
    string owner;
    json policy;
    int subscriptionsConfirmed;
    int subscriptionsDeleted;
    int subscriptionsPending;
};

# Represents a message that is published to an Amazon SNS topic. If you are publishing to a topic and you want to send
# the same message to all transport protocols, include the text of the message as a `string` value. If you want to send
# different messages for each transport protocol use a `MessageRecord` value. 
public type Message string|MessageRecord;

# Contains the messages to be published for each transport protocol.
# 
# + default - The default message that's used for all transport protocols if no individual message is specified
# + subject - Optional parameter to be used as the "Subject" line when the message is delivered to email endpoints
# + email - The message to be sent to email endpoints
# + emailJson - The message to be sent to email endpoints formatted as a JSON object
# + sqs - The message to be sent to Amazon SQS endpoints
# + lambda - The message to be sent to AWS Lambda (Lambda) endpoints
# + http - The message to be sent to HTTP endpoints
# + https - The message to be sent to HTTPS endpoints
# + sms - The message to be sent to SMS endpoints
# + firehose - The message to be sent to Amazon Kinesis Data Firehose endpoints
# + apns - The payload to be sent to APNS endpoints
# + apnsSandbox - The payload to be sent to APNS sandbox endpoints
# + apnsVoip - The payload to be sent to APNS VoIP endpoints
# + apnsVoipSandbox - The payload to be sent to APNS VoIP sandbox endpoints
# + macos - The payload to be sent to MacOS endpoints
# + macosSandbox - The payload to be sent to MacOS sandbox endpoints
# + gcm - The payload to be sent to GCM endpoints
# + adm - The payload to be sent to ADM endpoints
# + baidu - The payload to be sent to Baidu endpoints
# + mpns - The payload to be sent to MPNS endpoints
# + wns - The payload to be sent to WNS endpoints
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

# Represents an attribute value of a message.
public type MessageAttributeValue string|StringArrayElement[]|int|float|decimal|byte[];

# Represents an element of the String.Array type of a message attribute value.
public type StringArrayElement string|int|float|decimal|boolean|();

# Represents the details of a single message in a publish batch request.
# 
# + id - A unique identifier for the message in the batch
# + message - The message to send
# + attributes - The attributes of the message
# + deduplicationId - Every message must have a unique `deduplicationId`, which is a token used for deduplication 
#                     of sent messages. If a message with a particular `deduplicationId` is sent successfully, any 
#                     message sent with the same `deduplicationId` during the 5-minute deduplication interval is 
#                     treated as a duplicate. If the topic has `contentBasedDeduplication` set, the system 
#                     generates a `deduplicationId` based on the contents of the message. Your `deduplicationId`
#                     overrides the generated one. Applies to FIFO topics only
# + groupId - Specifies the message group to which a message belongs to. Messages that belong to the same message 
#             group are processed in a FIFO manner (however, messages in different message groups might be processed
#             out of order). Every message must include a `groupId`. Applies to FIFO topics only
public type PublishBatchRequestEntry record {|
    string id?;
    Message message;
    map<MessageAttributeValue> attributes?;
    string deduplicationId?;
    string groupId?;
|};

# Represents the attributes that can be set when creating a subscription.
# 
# + deliveryPolicy - The policy that defines how Amazon SNS retries failed deliveries to HTTP/S endpoints
# + filterPolicy - The filter policy that is assigned to the subscription which lets the subscriber receive only a 
#                  subset of the messages published to the topic
# + filterPolicyScope - Defines whether the filter policy is applied to the message attributes or the message body
# + rawMessageDelivery - When set to true, enables raw message delivery to Amazon SQS or HTTP/S endpoints
# + redrivePolicy - When specified, sends undeliverable messages to the specified Amazon SQS dead-letter queue
# + subscriptionRoleArn - The ARN of the IAM role that has permission to write to the Kinesis Data Firehose delivery 
#                         stream and has Amazon SNS listed as a trusted entity. Applies only to Amazon Kinesis Data 
#                         Firehose delivery stream subscriptions.
public type SubscriptionAttributes record {|
    json deliveryPolicy?;
    json filterPolicy?; // TODO: change to open record
    FilterPolicyScope filterPolicyScope?;
    boolean rawMessageDelivery?;
    json redrivePolicy?;
    string subscriptionRoleArn?;
|};

# Represents an Amazon SNS subscription object returned when calling the `listSubscriptions` operation.
# 
# + subscriptionArn - The subscription's ARN
# + owner - The subscription's owner
# + protocol - The subscription's protocol
# + endpoint - The subscription's endpoint (format depends on the protocol)
# + topicArn - The ARN of the subscription's topic
public type Subscription record {|
    string subscriptionArn;
    string owner;
    SubscriptionProtocol protocol;
    string endpoint;
    string topicArn;
|};

# Represents an Amazon SNS subscription object returned when calling the `getSubscription` operation.
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
public type GettableSubscriptionAttributes record {
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

# Represents the attributes of an Amazon SNS platform appication.
#
# + eventEndpointCreated - The topic ARN to which `EndpointCreated` event notifications should be sent
# + eventEndpointDeleted - The topic ARN to which `EndpointDeleted` event notifications should be sent
# + eventEndpointUpdated - The topic ARN to which `EndpointUpdated` event notifications should be sent
# + eventDeliveryFailure - The topic ARN to which `DeliveryFailure` event notifications should be sent upon Direct
#                          Publish delivery failure (permanent) to one of the application's endpoints
# + successFeedbackRoleArn - The IAM role ARN used to give Amazon SNS write access to use CloudWatch Logs on your behalf
# + failureFeedbackRoleArn - The IAM role ARN used to give Amazon SNS write access to use CloudWatch Logs on your behalf
# + successFeedbackSampleRate - The percentage of success to sample (0-100)
public type PlatformApplicationAttributes record {|
    string eventEndpointCreated?;
    string eventEndpointDeleted?;
    string eventEndpointUpdated?;
    string eventDeliveryFailure?;
    string successFeedbackRoleArn?;
    string failureFeedbackRoleArn?;
    int successFeedbackSampleRate?;
|};

# Represents the authentication attributes of an Amazon SNS platform appication that can be set.
# 
# + platformCredential - The credential received from the notification service
# + platformPrincipal - The principal received from the notification service
# + applePlatformTeamId - The identifier that's assigned to your Apple developer account team
# + applePlatformBundleId - The bundle identifier that's used for APNs tokens
public type PlatformApplicationAuthentication record {|
    string platformCredential;
    string platformPrincipal?;
    string applePlatformTeamId?;
    string applePlatformBundleId?;
|};

# Represents the attributes of an Amazon SNS platform appication that can be set using the 
# `setPlatformApplicationAttributes` action.
# 
# + platformCredential - The credential received from the notification service
# + platformPrincipal - The principal received from the notification service
# + applePlatformTeamId - The identifier that's assigned to your Apple developer account team
# + applePlatformBundleId - The bundle identifier that's used for APNs tokens

public type SettablePlatformApplicationAttributes record {|
    *PlatformApplicationAttributes;
    string platformCredential?;
    string platformPrincipal?;
    string applePlatformTeamId?;
    string applePlatformBundleId?;
|};

# Represents the attributes of an Amazon SNS platform application that can be retrieved.
# 
# + enabled - Whether the platform application is enabled for direct publishing from Amazon SNS
# + appleCertificateExpiryDate - The expiry date of the SSL certificate used to configure certificate-based 
#                                authentication
# + applePlatformTeamId - The Apple developer account ID used to configure token-based authentication
# + applePlatformBundleId - The bundle identifier used to configure token-based authentication
public type RetrievablePlatformApplicationAttributes record {|
    boolean enabled;
    string appleCertificateExpiryDate?;
    string applePlatformTeamId?;
    string applePlatformBundleId?;
    *PlatformApplicationAttributes;
|};

# Represents an Amazon SNS platform appication.
# 
# + platformApplicationArn - The ARN of the platform application object
# Publish delivery failure (permanent) to one of the application's endpoints
public type PlatformApplication record {|
    string platformApplicationArn;
    *RetrievablePlatformApplicationAttributes;
|};

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

# Represents an Amazon SNS platform appication endpoint.
# 
# + endpointArn - The endpoint's ARN
public type Endpoint record {|
    string endpointArn;
    *EndpointAttributes;
|};

# Represent an SMS sandbox phone number.
# 
# + phoneNumber - The destination phone number
# + status - The destination phone number's verification status
public type SMSSandboxPhoneNumber record {|
    string phoneNumber;
    Status status;
|};

# Represents an origination phone number.
# 
# + createdAt - The date and time when the origination phone number was created
# + iso2CountryCode - The two-character code, in ISO 3166-1 alpha-2 format, for the country or region where the
#                     origination phone number was originally registered
# + numberCapabilities - The capabilities of the origination phone number
# + phoneNumber - The phone number
# + routeType - The route type
# + status - The status of the origination phone number
public type OriginationPhoneNumber record {|
    time:Civil createdAt;
    string iso2CountryCode;
    NumberCapabilities[] numberCapabilities;
    string phoneNumber;
    RouteType routeType;
    string status;
|};

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

# Represents the tags associated with an Amazon SNS topic.
# 
# + topicArn - The ARN of the topic to which the tags are added
public type Tags record {|
    never topicArn?;
    string...;
|};