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
    _SMS,
    MMS,
    VOICE
};

# The types of routes supported by an origination phone number.
public enum RouteType {
    TRANSACTIONAL = "Transactional",
    PROMOTIONAL = "Promotional",
    PREMIUM = "Premium"
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
|};

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
// TODO: convert fifo to ENUM (Standard/FIFO)
public type SettableTopicAttributes record {|
    json deliveryPolicy?;
    string displayName?;
    json policy?;
    SignatureVersion signatureVersion?;
    TracingConfig tracingConfig?;
    string kmsMasterKeyId?;
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
# + deliveryPolicy - The policy that defines how Amazon SNS retries failed deliveries to HTTP/S endpoints
# + displayName - The human-readable name used in the From field for notifications to email and email-json endpoints
# + effectiveDeliveryPolicy - The policy that defines how Amazon SNS retries failed deliveries to HTTP/S endpoints,
#                             taking system defaults into account.
# + owner - The AWS account ID of the topic's owner
# + policy - The policy that defines who can access your topic
# + signatureVersion - The signature version corresponds to the hashing algorithm used while creating the signature
# + subscriptionsConfirmed - The number of confirmed subscriptions for the topic
# + subscriptionsDeleted - The number of deleted subscriptions for the topic
# + subscriptionsPending - The number of subscriptions pending confirmation for the topic
# + tracingConfig - The tracing mode of an Amazon SNS topic
# + kmsMasterKeyId - The ID of an AWS-managed customer master key (CMK) for Amazon SNS or a custom CMK
# + fifoTopic - Whether the topic is an Amazon SNS FIFO (first-in first-out) topic
# + contentBasedDeduplication - Whether content-based deduplication is enabled for the topic.
public type GettableTopicAttributes record {
    string topicArn;
    json deliveryPolicy?;
    string displayName;
    json effectiveDeliveryPolicy;
    string owner;
    json policy;
    SignatureVersion signatureVersion?;
    int subscriptionsConfirmed;
    int subscriptionsDeleted;
    int subscriptionsPending;
    TracingConfig tracingConfig?;
    string kmsMasterKeyId?;
    boolean fifoTopic?;
    boolean contentBasedDeduplication?;
};

# Represents a message that is published to an Amazon SNS topic. If you are publishing to a topic and you want to send
# the same message to all transport protocols, include the text of the message as a `string` value. If you want to send
# different messages for each transport protocol use a `MessageRecord` value. 
public type Message string|MessageRecord;

# Contains the messages to be published for each transport protocol.
public type MessageRecord record {|
    string default?;
    string email?;
    string sqs?;
    string lambda?;
    string http?;
    string https?;
    string sms?;
    string firehose?;
    json apns?;
    json apns_sandbox?;
    json apns_voip?;
    json apns_voip_sandbox?;
    json macos?;
    json macos_sanbox?;
    json gcm?;
    json adm?;
    json baidu?;
    json mpns?;
    json wns?;
|};

# Represents an attribute value of a message.
public type MessageAttributeValue string|string[]|int|float|decimal|byte[];

# Represents the details of a single message in a publish batch request.
public type PublishBatchRequestEntry record {|
    string id;
    Message message;
    map<MessageAttributeValue>? attributes = ();
    string? deduplicationId;
    string? groupId;
    string? subject;
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
#                         stream and has Amazon SNS listed as a trusted entity.Applies only to Amazon Kinesis Data 
#                         Firehose delivery stream subscriptions.
public type SubscriptionAttributes record {|
    json deliveryPolicy?;
    json filterPolicy?; // TODO: change to open record
    FilterPolicyScope filterPolicyScope?;
    boolean rawMessageDelivery?;
    RedrivePolicy redrivePolicy?;
    string subscriptionRoleArn?;
|};

# Represents the redrive policy attached to a subscription.
# 
# + deadLetterTargetArn - The Amazon Resource Name (ARN) of the dead-letter queue to which Amazon SNS moves messages
public type RedrivePolicy record {|
    string deadLetterTargetArn;
|};

# Represents an Amazon SNS subscription object returned when calling the `listSubscriptions` operation.
# 
# + subscriptionArn - The subscription's ARN
# + owner - The subscription's owner
# + protocol - The subscription's protocol
# + endpoint - The subscription's endpoint (format depends on the protocol)
# + topicArn - The ARN of the subscription's topic
public type SubscriptionListObject record {|
    string subscriptionArn;
    string owner;
    SubscriptionProtocol protocol;
    string endpoint;
    string topicArn;
|};

# Represents an Amazon SNS subscription object returned when calling the `getSubscription` operation.
# 
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
# + subscriptionArn - The subscription's ARN
# + topicArn - The ARN of the subscription's topic
# + subscriptionRoleArn - The ARN of the IAM role that has permission to write to the Kinesis Data Firehose delivery and
#                         has Amazon SNS listed as a trusted entity. Applies only to Amazon Kinesis Data Firehose
#                         delivery stream subscriptions.
# + subscriptionArn - The subscription's ARN
public type SubscriptionObject record {|
    boolean confirmationWasAuthenticated;
    json deliveryPolicy;
    json effectiveDeliveryPolicy;
    json filterPolicy;
    FilterPolicyScope filterPolicyScope;
    string owner;
    boolean pendingConfirmation;
    boolean rawMessageDelivery;
    RedrivePolicy redrivePolicy;
    string subscriptionArn;
    string topicArn;
    string subscriptionRoleArn;
|};

# Represents the attributes of an Amazon SNS platform appication.
#
# + platformCredential - The credential received from the notification service
# + platformPrincipal - The principal received from the notification service
# + eventEndpointCreated - The topic ARN to which `EndpointCreated` event notifications should be sent
# + eventEndpointDeleted - The topic ARN to which `EndpointDeleted` event notifications should be sent
# + eventEndpointUpdated - The topic ARN to which `EndpointUpdated` event notifications should be sent
# + eventDeliveryFailure - The topic ARN to which `DeliveryFailure` event notifications should be sent upon Direct
#                          Publish delivery failure (permanent) to one of the application's endpoints
# + successFeedbackRoleArn - The IAM role ARN used to give Amazon SNS write access to use CloudWatch Logs on your behalf
# + failureFeedbackRoleArn - The IAM role ARN used to give Amazon SNS write access to use CloudWatch Logs on your behalf
# + successFeedbackSampleRate - The percentage of success to sample (0-100)
# + applePlatformTeamId - The identifier that's assigned to your Apple developer account team
# + applePlatformBundleId - The bundle identifier that's used for APNs tokens
public type PlatformApplicationAttributes record {|
    string platformCredential;
    string platformPrincipal?;
    string eventEndpointCreated?;
    string eventEndpointDeleted?;
    string eventEndpointUpdated?;
    string eventDeliveryFailure?;
    string successFeedbackRoleArn?;
    string failureFeedbackRoleArn?;
    int successFeedbackSampleRate?;
    string applePlatformTeamId?;
    string applePlatformBundleId?;
|};

# Represents the attributes of an Amazon SNS platform application that can be retrieved.
# 
# + appleCertificateExpiryDate - The expiry date of the SSL certificate used to configure certificate-based 
#                                authentication
# + applePlatformTeamId - The Apple developer account ID used to configure token-based authentication
# + applePlatformBundleId - The bundle identifier used to configure token-based authentication
# + eventEndpointCreated - The topic ARN to which `EndpointCreated` event notifications should be sent
# + eventEndpointDeleted - The topic ARN to which `EndpointDeleted` event notifications should be sent
# + eventEndpointUpdated - The topic ARN to which `EndpointUpdated` event notifications should be sent
# + eventDeliveryFailure - The topic ARN to which `DeliveryFailure` event notifications should be sent upon Direct
#                          Publish delivery failure (permanent) to one of the application's endpoints
public type RetrievablePlatformApplicationAttributes record {|
    time:Date appleCertificateExpiryDate?;
    string applePlatformTeamId?;
    string applePlatformBundleId?;
    string eventEndpointCreated?;
    string eventEndpointDeleted?;
    string eventEndpointUpdated?;
    string eventDeliveryFailure?;
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
# + customUserData - Arbitrary user data associated with the endpoint
# + enabled - flag that enables/disables delivery to the endpoint
# + token - Unique identifier created by the notification service for an app on a device
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
public type SMSAttributes record {|
    float monthlySpendLimit?;
    string deliveryStatusIAMRole?;
    int deliveryStatusSuccessSamplingRate?;
    string defaultSenderID?;
    // TODO: fix
    // SMSMessageType defaultSMSType?;
    string usageReportS3Bucket?;
|};