// Copyright (c) 2023 WSO2 LLC. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/crypto;
import ballerina/http;
import ballerina/lang.array;
import ballerina/time;
import ballerinax/'client.config;
import ballerina/url;
import ballerina/io;

# Ballerina Amazon SNS API connector provides the capability to access Amazon's Simple Notification Service.
# This connector allows you to create and manage SNS topics and subscriptions.
#
# + amazonSNSClient - Connector HTTP endpoint
# + accessKeyId - Amazon API access key
# + secretAccessKey - Amazon API secret key
# + securityToken - Security token
# + region - Amazon API Region
# + amazonHost - Amazon host name
@display {label: "Amazon SNS Client", iconPath: "icon.png"}
public isolated client class Client {
    final string accessKeyId;
    final string secretAccessKey;
    final string? securityToken;
    final string region;
    final string amazonHost;
    final http:Client amazonSNSClient;

    # Initializes the connector.
    #
    # + configuration - Configuration for the connector
    # + httpClientConfig - HTTP Configuration
    # + return - `http:Error` in case of failure to initialize or `null` if successfully initialized
    public isolated function init(ConnectionConfig config) returns error? {
        self.accessKeyId = config.accessKeyId;
        self.secretAccessKey = config.secretAccessKey;
        self.securityToken = (config?.securityToken is string) ? <string>(config?.securityToken) : ();
        self.region = config.region;
        self.amazonHost = "sns." + self.region + ".amazonaws.com";
        string baseURL = "https://" + self.amazonHost;
        check validateCredentails(self.accessKeyId, self.secretAccessKey);

        http:ClientConfiguration httpClientConfig = check config:constructHTTPClientConfig(config);
        self.amazonSNSClient = check new (baseURL, httpClientConfig);
    }

    # Creates a topic to which notifications can be published. This action is idempotent, so if the requester already 
    # owns a topic with the specified name, that topic's ARN is returned without creating a new topic.
    #
    # + name - Name of topic
    # + attributes - Topic attributes
    # + dataProtectionPolicy - The body of the policy document you want to use for this topic. 
    #                          You can only add one policy per topic
    # + tags - List of tags to add to a new topic
    # + return - `CreateTopicResponse` or `sns:Error` in case of failure
    isolated remote function createTopic(string name, InitializableTopicAttributes? attributes = (),
        json? dataProtectionPolicy = (), map<string>? tags = ()) returns string|Error {
        map<string> parameters = initiateRequest("CreateTopic");
        parameters["Name"] = name;

        if attributes is InitializableTopicAttributes {
            _ = check validateInitializableTopicAttributes(attributes);

            // The suffix ".fifo" must be added to all topic names that are FIFO
            if attributes.fifoTopic is boolean && <boolean>attributes.fifoTopic && !name.endsWith(".fifo") {
                parameters["Name"] = name + ".fifo";
            }

            record {} formattedTopicAttributes = check formatAttributes(attributes, SPECIAL_TOPIC_ATTRIBUTES_MAP);
            setAttributes(parameters, formattedTopicAttributes);
        }

        if dataProtectionPolicy != () {
            parameters["DataProtectionPolicy"] = dataProtectionPolicy.toString();
        }

        if tags is map<string> {
            setTags(parameters, tags);
        }

        http:Request request = check self.generateRequest(parameters);
        json response = check sendRequest(self.amazonSNSClient, request);

        do {
            return (check response.CreateTopicResponse.CreateTopicResult.TopicArn).toString();
        } on fail error e {
            return error ResponseHandleFailedError(e.message(), e);
        }
    }

    # Deletes a topic and all its subscriptions. Deleting a topic might prevent some messages previously sent to the
    # topic from being delivered to subscribers. This action is idempotent, so deleting a topic that does not exist
    # does not result in an error.
    # 
    # + topicArn - The Amazon Resource Name (ARN) of the topic to be deleted
    # + return - `()` or `sns:Error` in case of failure
    isolated remote function deleteTopic(string topicArn) returns Error? {
        map<string> parameters = initiateRequest("DeleteTopic");
        parameters["TopicArn"] = topicArn;

        http:Request request = check self.generateRequest(parameters);
        _ = check sendRequest(self.amazonSNSClient, request);
    }

    # Returns the topics ARNs that are owned by the AWS account.
    # 
    # + return - A stream of topic ARNs
    isolated remote function listTopics() returns stream<string, Error?> {
        TopicStream topicsStreamObject = new (self.amazonSNSClient, self.generateRequest);
        stream<string, Error?> topicsStream = new (topicsStreamObject);
        return topicsStream;
    }

    # Retrieves an existing topic along with its attributes.
    # 
    # + topicArn - The Amazon Resource Name (ARN) of the topic 
    # + return - `Topic` or `sns:Error` in case of failure
    isolated remote function getTopicAttributes(string topicArn) returns GettableTopicAttributes|Error {
        map<string> parameters = initiateRequest("GetTopicAttributes");
        parameters["TopicArn"] = topicArn;

        http:Request request = check self.generateRequest(parameters);
        json response = check sendRequest(self.amazonSNSClient, request);

        do {
            json attributes = check response.GetTopicAttributesResponse.GetTopicAttributesResult.Attributes;
            return check mapJsonToGettableTopicAttributes(attributes);
        } on fail error e {
            return error ResponseHandleFailedError(e.message(), e);
        }
    }

    # Modifies the a single attribute of an Amazon SNS topic.
    #   
    # + topicArn - The Amazon Resource Name (ARN) of the topic
    # + attributeName - The name of the attribute you want to set
    # + value - The new value for the attribute
    # + return - `()` or `sns:Error` in case of failure
    isolated remote function setTopicAttributes(string topicArn, TopicAttributeName attributeName, 
        json|string|int|boolean value) returns Error? {
        check validateTopicAttribute(attributeName, value);

        map<string> parameters = initiateRequest("SetTopicAttributes");
        parameters["TopicArn"] = topicArn;
        parameters["AttributeName"] = attributeName;
        parameters["AttributeValue"] = value.toString();

        http:Request request = check self.generateRequest(parameters);
        _ = check sendRequest(self.amazonSNSClient, request);
    }

    # Publishes a message to an SNS topic, a phone number, or a mobile platform endpoint.
    # 
    # + target - The target (topic ARN, target ARN or phone number) to which to publish the message to
    # + message - The message to publish. If you are publishing to a topic and you want to send the same message to all
    #             transport protocols, include the text of the message as a `string` value. If you want to send 
    #             different messages for each transport protocol, use a `MessageRecord` value
    # + targetType - The type of target (topic, phone number, or application endpoint) to publish the message to
    # + attributes - Attributes of the message
    # + deduplicationId - Every message must have a unique `deduplicationId`, which is a token used for deduplication 
    #                     of sent messages. If a message with a particular `deduplicationId` is sent successfully, any 
    #                     message sent with the same `deduplicationId` during the 5-minute deduplication interval is 
    #                     treated as a duplicate. If the topic has `contentBasedDeduplication` set, the system 
    #                     generates a `deduplicationId` based on the contents of the message. Your `deduplicationId`
    #                     overrides the generated one. Applies to FIFO topics only
    # + groupId - Specifies the message group to which a message belongs to. Messages that belong to the same message 
    #             group are processed in a FIFO manner (however, messages in different message groups might be processed
    #             out of order). Every message must include a `groupId`. Applies to FIFO topics only
    # + return - `PublishMessageResponse` or `sns:Error` in case of failure
    isolated remote function publish(string target, Message message, TargetType targetType = TOPIC, 
    map<MessageAttributeValue>? attributes = (), string? deduplicationId = (), string? groupId = ())
        returns PublishMessageResponse|Error {
        _ = check validatePublishParameters(target, targetType, groupId);
        map<string> parameters = initiateRequest("Publish");

        if targetType == TOPIC {
            parameters["TopicArn"] = target;
        } else if targetType == ARN {
            parameters["TargetArn"] = target;
        } else {
            parameters["PhoneNumber"] = target;
        }
        
        if message is string {
            parameters["Message"] = message;
        } else {
            parameters["MessageStructure"] = "json";

            if message.hasKey("subject") {
                parameters["Subject"] = <string>message.subject;
                _ = message.remove("subject");
            }

            parameters["Message"] = mapMessageRecordToJson(message).toJsonString();
        }

        if deduplicationId is string {
            parameters["MessageDeduplicationId"] = deduplicationId;
        }

        if groupId is string {
            parameters["MessageGroupId"] = groupId;
        }

        if attributes is map<MessageAttributeValue> {
            check setMessageAttributes(parameters, attributes);
        }

        http:Request request = check self.generateRequest(parameters);
        json response = check sendRequest(self.amazonSNSClient, request);

        do {
            PublishMessageResponse publishMessageResponse = {
                messageId: (check response.PublishResponse.PublishResult.MessageId).toString()
            };

            json|error sequenceNumber = response.PublishResponse.PublishResult.SequenceNumber;
            if sequenceNumber is json && sequenceNumber.toString() != "" {
                publishMessageResponse.sequenceNumber = check sequenceNumber;
            }

            return publishMessageResponse;
        } on fail error e {
            return error ResponseHandleFailedError(e.message(), e);
        }
    };

    # Publishes up to ten messages to the specified topic.
    # 
    # + topicArn - The Amazon Resource Name (ARN) of the topic
    # + entries - A list of `PublishBatchRequestEntry` objects that contain the separate messages to publish
    # + return - `PublishBatchResponse` or `sns:Error` in case of failure
    isolated remote function publishBatch(string topicArn, PublishBatchRequestEntry[] entries) 
        returns PublishBatchResponse|Error {
        map<string> parameters = initiateRequest("PublishBatch");
        parameters["TopicArn"] = topicArn;

        check setPublishBatchEntries(parameters, entries);

        http:Request request = check self.generateRequest(parameters);
        json response = check sendRequest(self.amazonSNSClient, request);

        do {
            PublishBatchResponse publishBatchResponse = {
                successful: [],
                failed: []
            };

            json[] successful = check (check response.PublishBatchResponse.PublishBatchResult.Successful).ensureType();
            foreach [int, json] [_ , successfulEntry] in successful.enumerate() {
                PublishBatchResultEntry entry = {
                    id: check successfulEntry.Id,
                    messageId: check successfulEntry.MessageId
                };

                if successfulEntry.SequenceNumber is json {
                    entry.sequenceNumber = (check successfulEntry.SequenceNumber);
                }

                publishBatchResponse.successful.push(entry);
            }

            json[] failed = check (check response.PublishBatchResponse.PublishBatchResult.Failed).ensureType();
            foreach [int, json] [_, failedEntry] in failed.enumerate() {
                BatchResultErrorEntry entry = {
                    code: check failedEntry.Code,
                    id: check failedEntry.Id,
                    senderFault: check failedEntry.SenderFault
                };

                if failedEntry.Message is json {
                    entry.message = check failedEntry.Message;
                }

                publishBatchResponse.failed.push(entry);
            }

            return publishBatchResponse;
        } on fail error e {
            return error ResponseHandleFailedError(e.message(), e);
        }
    };

    # Creates a subscription to a topic. If the endpoint type is HTTP/S or email, or if the endpoint and the topic are
    # not in the same AWS account, the endpoint owner must confirm the subscription.
    # 
    # + topicArn - The Amazon Resource Name (ARN) of the topic you want to subscribe to
    # + endpoint - The endpoint that you want to receive notifications to.
    # + protocol - The protocol you want to use.
    # + attributes - Attributes of the subscription
    # + returnSubscriptionArn - Whether the response from the Subscribe request includes the subscription ARN, even if 
    #                           the subscription is not yet confirmed. 
    # + return - The ARN of the subscription if it is confirmed, or the string "pending confirmation" if the 
    #            subscription requires confirmation. However, if the `returnSubscriptionArn` parameter is set to `true`, 
    #            then the value is always the subscription ARN, even if the subscription requires confirmation. 
    isolated remote function subscribe(string topicArn, string endpoint, SubscriptionProtocol protocol, 
        SubscriptionAttributes? attributes = (), boolean returnSubscriptionArn = false) 
        returns string|Error {
        map<string> parameters = initiateRequest("Subscribe");
        parameters["TopicArn"] = topicArn;
        parameters["Endpoint"] = endpoint;
        parameters["Protocol"] = protocol;
        parameters["ReturnSubscriptionArn"] = returnSubscriptionArn.toString();

        if attributes is SubscriptionAttributes {
            record {} formattedSubscriptionsAttributes = check formatAttributes(attributes);
            setAttributes(parameters, formattedSubscriptionsAttributes);
        }

        http:Request request = check self.generateRequest(parameters);
        json response = check sendRequest(self.amazonSNSClient, request);

        do {
            return (check response.SubscribeResponse.SubscribeResult.SubscriptionArn).toString();
        } on fail error e {
            return error ResponseHandleFailedError(e.message(), e);
        }
    };

    # Verifies an endpoint owner's intent to receive messages by validating the token sent to the endpoint by an 
    # earlier subscribe action.
    #
    # + topicArn - The ARN of the topic for which you wish to confirm a subscription
    # + token - Short-lived token sent to an endpoint during the subscribe action
    # + authenticateOnUnsubscribe - Disallows unauthenticated unsubscribes of the subscription. If the value of this 
    #                               parameter is `true`, then only the topic owner and the subscription owner can 
    #                               unsubscribe the endpoint.
    # + return - The ARN of the created subscription or `sns:Error` in case of failure
    isolated remote function confirmSubscription(string topicArn, string token, boolean? authenticateOnUnsubscribe = ())
        returns string|Error {
        map<string> parameters = initiateRequest("ConfirmSubscription");
        parameters["TopicArn"] = topicArn;
        parameters["Token"] = token;

        if authenticateOnUnsubscribe is boolean {
            parameters["AuthenticateOnUnsubscribe"] = authenticateOnUnsubscribe.toString();
        }

        http:Request request = check self.generateRequest(parameters);
        json response = check sendRequest(self.amazonSNSClient, request);

        do {
            return (check response.ConfirmSubscriptionResponse.ConfirmSubscriptionResult.SubscriptionArn).toString();
        } on fail error e {
            return error ResponseHandleFailedError(e.message(), e);
        }
    };

    # Retrieves the requester's subscriptions.
    # 
    # + topicArn - The ARN of the topic for which you wish list the subscriptions
    # + return - A stream of `Subscription` records
    isolated remote function listSubscriptions(string? topicArn = ()) returns stream<Subscription, Error?> {
        SubscriptionStream subscriptionsStreamObject = new (self.amazonSNSClient, self.generateRequest, topicArn);
        stream<Subscription, Error?> subscriptionsStream = new (subscriptionsStreamObject);
        return subscriptionsStream;
    } 

    # Retrieves the attributes of the requested subscription.
    # 
    # + subscriptionArn - The ARN of the subscription
    # + return - `SubscriptionObject` or `sns:Error` in case of failure
    isolated remote function getSubscriptionAttributes(string subscriptionArn) returns GettableSubscriptionAttributes|Error {
        map<string> parameters = initiateRequest("GetSubscriptionAttributes");
        parameters["SubscriptionArn"] = subscriptionArn;

        http:Request request = check self.generateRequest(parameters);
        json response = check sendRequest(self.amazonSNSClient, request);

        do {
            json attributes = 
                check response.GetSubscriptionAttributesResponse.GetSubscriptionAttributesResult.Attributes;
            return check mapJsonToSubscriptionAttributes(attributes);
        } on fail error e {
            return error ResponseHandleFailedError(e.message(), e);
        }
    };

    # Modifies a single of a subscription.
    # 
    # + subscriptionArn - The ARN of the subscription to modify
    # + attributeName - The name of the attribute you want to set
    # + value - The new value for the attribute
    # + return - `()` or `sns:Error` in case of failure
    isolated remote function setSubscriptionAttributes(string subscriptionArn, SubscriptionAttributeName attributeName, 
        json|FilterPolicyScope|boolean|string value) returns Error? {
        check validateSubscriptionAttribute(attributeName, value);

        map<string> parameters = initiateRequest("SetSubscriptionAttributes");
        parameters["SubscriptionArn"] = subscriptionArn;
        parameters["AttributeName"] = attributeName.toString();
        parameters["AttributeValue"] = value.toString();

        http:Request request = check self.generateRequest(parameters);
        _ = check sendRequest(self.amazonSNSClient, request);
    };

    # Deletes a subscription. If the subscription requires authentication for deletion, only the owner of the 
    # subscription or the owner of the topic may unsubscribe. If the unsubscribe call does not require authentication 
    # and the requester is not the subscription owner, a final cancellation message is delivered to the endpoint, so 
    # that the endpoint owner can easily resubscribe to the topic if the unsubscribe request was unintended.
    # 
    # + subscriptionArn - The ARN of the subscription to be deleted
    # + return - `()` or `sns:Error` in case of failure
    isolated remote function unsubscribe(string subscriptionArn) returns Error? {
        map<string> parameters = initiateRequest("Unsubscribe");
        parameters["SubscriptionArn"] = subscriptionArn;

        http:Request request = check self.generateRequest(parameters);
        _ = check sendRequest(self.amazonSNSClient, request);
    };

    # Creates a platform application object for one of the supported push notification services. You must specify 
    # `auth.platformPrincipal` and `auth.platformCredential` parameters.
    # - for `ADM` the `platformPrincipal` is the `client id` and `platformCredential` is the `client secret`
    # - for `APNS` and `APNS_SANDBOX` using certificate credentials, the `platformPrincipal` is the `SSL certificate` 
    #   and `platformCredential` is the `private key`
    # - for `APNS` and `APNS_SANDBOX` using token credentials, the `platformPrincipal` is the `signing key ID` and the 
    #   `platformCredential` is the `signing key` 
    # - for `FCM` there is no `platformPrincipal` and `platformCredential` is the `API key`
    # - for `BAIDU` the `platformPrincipal` is the `API key` and `platformCredential` is the `secret key`
    # - for `MPNS` the `platformPrincipal` is the `TLS certificate` and `platformCredential` is the `private key`
    # - for `WNS` the `platformPrincipal` is the `Package Security Identifier` and `platformCredential` is the 
    #   `secret key`
    # 
    # + name - The name of the platform application object to create
    # + platform - The platform of the application
    # + attributes - Attributes of the platform application
    # + auth - Authentication credentials for the platform application
    # + return - The ARN of the platform application if successful, or `sns:Error` in case of failure
    isolated remote function createPlatformApplication(string name, Platform platform, 
        PlatformApplicationAuthentication auth, PlatformApplicationAttributes? attributes = ()) returns string|Error {
        map<string> parameters = initiateRequest("CreatePlatformApplication");
        parameters["Name"] = name;
        parameters["Platform"] = platform;

        record {} attributesRecord = {};
        if attributes is PlatformApplicationAttributes {
            attributesRecord = {
                ...auth,
                ...attributes
            };
        } else {
            attributesRecord = auth;
        }

        record {} formattedPlatformApplicationAttributes = check formatAttributes(attributesRecord);
        setAttributes(parameters, formattedPlatformApplicationAttributes);

        http:Request request = check self.generateRequest(parameters);
        json response = check sendRequest(self.amazonSNSClient, request);

        do {
            return (check response.CreatePlatformApplicationResponse.CreatePlatformApplicationResult
                .PlatformApplicationArn).toString();
        } on fail error e {
            return error ResponseHandleFailedError(e.message(), e);
        }
    };

    # Retrives the platform application objects for the supported push notification services.
    # 
    # + return - A stream of `PlatformApplication` records
    isolated remote function listPlatformApplications() returns stream<PlatformApplication, Error?> {
        PlatformApplicationStream platformApplicationsStreamObject = new (self.amazonSNSClient, self.generateRequest);
        stream<PlatformApplication, Error?> platformApplicationsStream = new (platformApplicationsStreamObject);
        return platformApplicationsStream;
    };

    # Retrieves a platform application object for one of the supported push notification services.
    # 
    # + platformApplicationArn - The ARN of the platform application object to retrieve
    # + return - `PlatformApplication` or `sns:Error` in case of failure
    isolated remote function getPlatformApplicationAttributes(string platformApplicationArn) 
        returns RetrievablePlatformApplicationAttributes|Error {
        map<string> parameters = initiateRequest("GetPlatformApplicationAttributes");
        parameters["PlatformApplicationArn"] = platformApplicationArn;

        http:Request request = check self.generateRequest(parameters);
        json response = check sendRequest(self.amazonSNSClient, request);
        io:println("-------------------------- original response ---------------------------------");
        io:println(response);
        io:println("-------------------------- original response ---------------------------------");

        do {
            json attributes =
                check response.GetPlatformApplicationAttributesResponse.GetPlatformApplicationAttributesResult
                    .Attributes;
            return check mapJsonToPlatformApplicationAttributes(attributes);
        } on fail error e {
            return error ResponseHandleFailedError(e.message(), e);
        }
    };

    # Modifies the attributes of a platform application object for one of the supported push notification services.
    # 
    # + platformApplicationArn - The ARN of the platform application object to modify
    # + attributes - The attributes to modify
    # + return - `()` or `sns:Error` in case of failure
    isolated remote function setPlatformApplicationAttributes(string platformApplicationArn, 
        SettablePlatformApplicationAttributes attributes) returns Error? {
        map<string> parameters = initiateRequest("SetPlatformApplicationAttributes");
        parameters["PlatformApplicationArn"] = platformApplicationArn;

        record {} formattedPlatformApplicationAttributes = check formatAttributes(attributes);
        setAttributes(parameters, formattedPlatformApplicationAttributes);
        io:println("-----------------parameters----------------");
        io:println(parameters);
        io:println("--------------parameters--------------");

        http:Request request = check self.generateRequest(parameters);
        json msg = check sendRequest(self.amazonSNSClient, request);
        io:println("+++++++++++++message+++++++++");
        io:println(msg);
        io:println("+++++++++++++message+++++++++");
    };

    # Deletes a platform application object for one of the supported push notification services.
    # 
    # + platformApplicationArn - The ARN of the platform application object to delete
    # + return - `()` or `sns:Error` in case of failure
    isolated remote function deletePlatformApplication(string platformApplicationArn) returns Error? {
        map<string> parameters = initiateRequest("DeletePlatformApplication");
        parameters["PlatformApplicationArn"] = platformApplicationArn;

        http:Request request = check self.generateRequest(parameters);
        _ = check sendRequest(self.amazonSNSClient, request);
    };

    # Creates an endpoint for a device and mobile app on one of the supported push notification services. This action is
    # idempotent, so  if the requester already owns an endpoint with the same device token and attributes, that 
    # endpoint's ARN is returned without creating a new endpoint.
    # 
    # + platformApplicationArn - The ARN of the platform application
    # + token - Unique identifier created by the notification service for an app on a device. The specific name for 
    #           the token will vary, depending on which notification service is being used
    # + attributes - Attributes of the endpoint
    # + customUserData - Arbitrary user data to associate with the endpoint. Amazon SNS does not use this data
    # + return - The ARN of the endpoint if successful, or `sns:Error` in case of failure
    isolated remote function createEndpoint(string platformApplicationArn, string token, 
        EndpointAttributes? attributes = (), string? customUserData = ()) returns string|Error {
        map<string> parameters = initiateRequest("CreatePlatformEndpoint");
        parameters["PlatformApplicationArn"] = platformApplicationArn;
        parameters["Token"] = token;

        if customUserData is string {
            parameters["CustomUserData"] = customUserData;
        }

        if attributes is EndpointAttributes {
            record {} formattedTopicAttributes = check formatAttributes(attributes);
            setAttributes(parameters, formattedTopicAttributes);
        }

        http:Request request = check self.generateRequest(parameters);
        json response = check sendRequest(self.amazonSNSClient, request);

        do {
            return (check response.CreatePlatformEndpointResponse.CreatePlatformEndpointResult.EndpointArn).toString();
        } on fail error e {
            return error ResponseHandleFailedError(e.message(), e);
        }
    };

    # Retrieves the endpoints associated with a specific platform application.
    # 
    # + platformApplicationArn - The ARN of the platform application to retrieve endpoints for
    # + return - A stream of `Endpoint` records
    isolated remote function listEndpoints(string platformApplicationArn) 
        returns stream<Endpoint, Error?> {
        EndpointStream endpointsStreamObject = new (self.amazonSNSClient, self.generateRequest, platformApplicationArn);
        stream<Endpoint, Error?> endpointsStream = new (endpointsStreamObject);
        return endpointsStream;
    };

    # Retrieves a platform application endpoint.
    # 
    # + endpointArn - The ARN of the endpoint
    # + return - The attributes of the endpoint or `sns:Error` in case of failure
    isolated remote function getEndpointAttributes(string endpointArn) returns EndpointAttributes|Error {
        map<string> parameters = initiateRequest("GetEndpointAttributes");
        parameters["EndpointArn"] = endpointArn;

        http:Request request = check self.generateRequest(parameters);
        json response = check sendRequest(self.amazonSNSClient, request);

        do {
            json attributes = check response.GetEndpointAttributesResponse.GetEndpointAttributesResult.Attributes;
            return check mapJsonToEndpointAttributes(attributes);
        } on fail error e {
            return error ResponseHandleFailedError(e.message(), e);
        }
    };

    # Modifies the attributes of a platform application endpoint.
    # 
    # + endpointArn - The ARN of the endpoint
    # + attributes - The attributes to modify
    # + return - `()` or `sns:Error` in case of failure
    isolated remote function setEndpointAttributes(string endpointArn, EndpointAttributes attributes) 
        returns Error? {
        map<string> parameters = initiateRequest("SetEndpointAttributes");
        parameters["EndpointArn"] = endpointArn;

        record {} formattedPlatformApplicationAttributes = check formatAttributes(attributes);
        setAttributes(parameters, formattedPlatformApplicationAttributes);

        http:Request request = check self.generateRequest(parameters);
        _ = check sendRequest(self.amazonSNSClient, request);
    };

    # Deletes a platform application endpoint. This action is idempotent. When you delete an endpoint that is also 
    # subscribed to a topic, then you must also unsubscribe the endpoint from the topic.
    # 
    # + endpointArn - The ARN of the endpoint
    # + return - `()` or `sns:Error` in case of failure
    isolated remote function deleteEndpoint(string endpointArn) returns Error? {
        map<string> parameters = initiateRequest("DeleteEndpoint");
        parameters["EndpointArn"] = endpointArn;

        http:Request request = check self.generateRequest(parameters);
        _ = check sendRequest(self.amazonSNSClient, request);
    };

    # Adds a destination phone number to an AWS account in the SMS sandbox and sends a one-time password (OTP) to that 
    # phone number.
    # 
    # + phoneNumber - The destination phone number to verify
    # + languageCode - The language to use for sending the OTP
    # + return - `()` or `sns:Error` in case of failure
    isolated remote function createSMSSandboxPhoneNumber(string phoneNumber, LanguageCode? languageCode = EN_US) 
        returns Error? {
        map<string> parameters = initiateRequest("CreateSMSSandboxPhoneNumber");
        parameters["PhoneNumber"] = phoneNumber;
        if languageCode is LanguageCode {
            parameters["LanguageCode"] = languageCode.toString();
        }

        http:Request request = check self.generateRequest(parameters);
        _ = check sendRequest(self.amazonSNSClient, request);
    };

    # Verifies a destination phone number with a one-time password (OTP) for the calling AWS account.
    # 
    # + phoneNumber - The destination phone number to verify
    # + otp - The OTP sent to the destination number
    # + return - `()` or `sns:Error` in case of failure
    isolated remote function verifySMSSandboxPhoneNumber(string phoneNumber, string otp) returns Error? {
        map<string> parameters = initiateRequest("VerifySMSSandboxPhoneNumber");
        parameters["PhoneNumber"] = phoneNumber;
        parameters["OneTimePassword"] = otp;

        http:Request request = check self.generateRequest(parameters);
        _ = check sendRequest(self.amazonSNSClient, request);
    };

    # Retrieves the current verified and pending destination phone numbers in the SMS sandbox.
    # 
    # + return - A stream of `SMSSandboxPhoneNumber` records
    isolated remote function listSMSSandboxPhoneNumbers() 
        returns stream<SMSSandboxPhoneNumber, Error?> {
        SMSSandboxPhoneNumberStream SMSSandboxPhoneNumberStreamObject = 
            new (self.amazonSNSClient, self.generateRequest);
        stream<SMSSandboxPhoneNumber, Error?> SMSSandboxPhoneNumberStream = new (SMSSandboxPhoneNumberStreamObject);
        return SMSSandboxPhoneNumberStream;
    };

    # Deletes a verified or pending phone number from the SMS sandbox.
    # 
    # + phoneNumber - The destination phone number to delete
    # + return - `()` or `sns:Error` in case of failure
    isolated remote function deleteSMSSandboxPhoneNumber(string phoneNumber) returns Error? {
        map<string> parameters = initiateRequest("DeleteSMSSandboxPhoneNumber");
        parameters["PhoneNumber"] = phoneNumber;

        http:Request request = check self.generateRequest(parameters);
        _ = check sendRequest(self.amazonSNSClient, request);
    };

    # Retrieves the SMS sandbox status for the calling AWS account in the target AWS Region.
    # 
    # + return - The SMS sandbox status for the calling AWS account in the target AWS Region or `sns:Error` in case of
    #            failure
    isolated remote function getSMSSandboxAccountStatus() returns boolean|Error {
        map<string> parameters = initiateRequest("GetSMSSandboxAccountStatus");

        http:Request request = check self.generateRequest(parameters);
        json response = check sendRequest(self.amazonSNSClient, request);

        do {
            return check 
                (check response.GetSMSSandboxAccountStatusResponse.GetSMSSandboxAccountStatusResult.IsInSandbox)
                .ensureType(boolean);
        } on fail error e {
            return error ResponseHandleFailedError(e.message(), e);
        }
    };

    # Retrieves the calling AWS account's dedicated origination numbers and their metadata. 
    # 
    # + return - A stream of `OriginationPhoneNumber` records
    isolated remote function listOriginationNumbers() returns stream<OriginationPhoneNumber, Error?> {
        OriginationPhoneNumberStream originationPhoneNumberStreamObject =
            new (self.amazonSNSClient, self.generateRequest);
        stream<OriginationPhoneNumber, Error?> orignationPhoneNumberStream = new (originationPhoneNumberStreamObject);
        return orignationPhoneNumberStream;
    }

    # Retrieves a list of phone numbers that are opted out, meaning you cannot send SMS messages to them.
    # 
    # + return - A stream of phone numbers that are opted out
    isolated remote function listPhoneNumbersOptedOut() returns stream<string, Error?> {
        OptedOutPhoneNumberStream optedOutPhoneNumberStreamObject = new (self.amazonSNSClient, self.generateRequest);
        stream<string, Error?> optedOutPhoneNumberStream = new (optedOutPhoneNumberStreamObject);
        return optedOutPhoneNumberStream;
    }

    # Checks whether a phone number is opted out, meaning you cannot send SMS messages to it.
    # 
    # + phoneNumber - The phone number for which you want to check the opt out status.
    # + return - `true` if the phone number is opted out, `false` otherwise or `sns:Error` in case of failure
    isolated remote function checkIfPhoneNumberIsOptedOut(string phoneNumber) returns boolean|Error {
        map<string> parameters = initiateRequest("CheckIfPhoneNumberIsOptedOut");
        parameters["phoneNumber"] = phoneNumber;

        http:Request request = check self.generateRequest(parameters);
        json response = check sendRequest(self.amazonSNSClient, request);

        do {
            return check
                (check response.CheckIfPhoneNumberIsOptedOutResponse.CheckIfPhoneNumberIsOptedOutResult.isOptedOut)
                .ensureType(boolean);
        } on fail error e {
            return error ResponseHandleFailedError(e.message(), e);
        }
    }

    # Requests to opt in a phone number that is opted out, which enables you to resume sending SMS messages to the 
    # number. You can opt in a phone number only once every 30 days.
    # 
    # + phoneNumber - The destination phone number to opt in (in E.164 format)
    # + return - `()` or `sns:Error` in case of failure
    isolated remote function optInPhoneNumber(string phoneNumber) returns Error? {
        map<string> parameters = initiateRequest("OptInPhoneNumber");
        parameters["phoneNumber"] = phoneNumber;

        http:Request request = check self.generateRequest(parameters);
        _ = check sendRequest(self.amazonSNSClient, request);
    };

    # Adds tags to the specified Amazon SNS topic. A new tag with a key identical to that of an existing tag overwrites 
    # the existing tag.
    # 
    # + topicArn - The ARN of the topic to which to add tags
    # + tags - The tags to add to the specified topic
    # + return - `()` or `sns:Error` in case of failure
    isolated remote function tagResource(string topicArn, *Tags tags) returns Error? {
        map<string> parameters = initiateRequest("TagResource");
        parameters["ResourceArn"] = topicArn;
        
        if tags.length() is 0 {
            return error Error("At least one tag must be specified.");
        }
        setTags(parameters, tags);

        http:Request request = check self.generateRequest(parameters);
        _ = check sendRequest(self.amazonSNSClient, request);
    };

    # Lists the tags for the specified Amazon SNS topic.
    # 
    # + topicArn - The ARN of the topic for which to list tags
    # + return - A `Tags` record consisting of the tags or an `sns:Error` in case of failure
    isolated remote function listTags(string topicArn) returns Tags|Error {
        map<string> parameters = initiateRequest("ListTagsForResource");
        parameters["ResourceArn"] = topicArn;

        http:Request request = check self.generateRequest(parameters);
        json response = check sendRequest(self.amazonSNSClient, request);

        do {
            json[] tags =
                check response.ListTagsForResourceResponse.ListTagsForResourceResult.Tags.ensureType();
            return check mapJsonToTags(tags);
        } on fail error e {
            return error ResponseHandleFailedError(e.message(), e);
        }
    };

    # Removes tags from the specified Amazon SNS topic.
    # 
    # + topicArn - The ARN of the topic from which to remove tags
    # + tagKeys - The list of tag keys to remove from the specified topic
    # + return - `()` or `sns:Error` in case of failure
    isolated remote function untagResource(string topicArn, string[] tagKeys) returns Error? {
        map<string> parameters = initiateRequest("UntagResource");
        parameters["ResourceArn"] = topicArn;

        if tagKeys.length() is 0 {
            return error Error("At least one tag key must be specified.");
        }
        foreach [int, string] [i, tagKey] in tagKeys.enumerate() {
            parameters["TagKeys.member." + (i + 1).toString()] = tagKey;
        }

        http:Request request = check self.generateRequest(parameters);
        _ = check sendRequest(self.amazonSNSClient, request);
    };

    # Adds a statement to a topic's access control policy, granting access for the specified AWS accounts to the \
    # specified actions.
    # 
    # + topicArn - The ARN of the topic to which to add the policy
    # + actions - The actions to allow for the specified users
    # + awsAccountIds - The AWS account IDs of the users who will be given access to the specified actions
    # + label - A unique identifier for the new policy statement
    # + return - `()` or `sns:Error` in case of failure
    isolated remote function addPermission(string topicArn, Action[] actions, string[] awsAccountIds, string label) 
        returns Error? {
        map<string> parameters = initiateRequest("AddPermission");
        parameters["TopicArn"] = topicArn;
        parameters["Label"] = label;

        if actions.length() is 0 {
            return error Error("At least one action must be specified.");
        }
        foreach [int, Action] [i, action] in actions.enumerate() {
            parameters["ActionName.member." + (i + 1).toString()] = action.toString();
        }

        if awsAccountIds.length() is 0 {
            return error Error("At least one AWS account ID must be specified.");
        }
        foreach [int, string] [i, awsAccountId] in awsAccountIds.enumerate() {
            parameters["AWSAccountId.member." + (i + 1).toString()] = awsAccountId;
        }

        http:Request request = check self.generateRequest(parameters);
        _ = check sendRequest(self.amazonSNSClient, request);
    };

    # Removes a statement from a topic's access control policy.
    # 
    # + topicArn - The ARN of the topic from which to remove the policy
    # + label - The unique identifier for the policy statement to be removed
    # + return - `()` or `sns:Error` in case of failure
    isolated remote function removePermission(string topicArn, string label) returns Error? {
        map<string> parameters = initiateRequest("RemovePermission");
        parameters["TopicArn"] = topicArn;
        parameters["Label"] = label;

        http:Request request = check self.generateRequest(parameters);
        _ = check sendRequest(self.amazonSNSClient, request);
    };

    # Adds or updates the data protection policy of the specified Amazon SNS topic.
    # 
    # + topicArn - The ARN of the topic to which to add the policy
    # + dataProtectionPolicy - The policy document to add to the specified topic
    # + return - `()` or `sns:Error` in case of failure
    isolated remote function putDataProtectionPolicy(string topicArn, json dataProtectionPolicy) returns Error? {
        map<string> parameters = initiateRequest("PutDataProtectionPolicy");
        parameters["ResourceArn"] = topicArn;
        parameters["DataProtectionPolicy"] = dataProtectionPolicy.toJsonString();

        http:Request request = check self.generateRequest(parameters);
        _ = check sendRequest(self.amazonSNSClient, request);
    };

    # Retrieves the data protection policy for the specified Amazon SNS topic.
    # 
    # + topicArn - The ARN of the topic for which to retrieve the policy
    # + return - The data protection policy for the specified topic or `sns:Error` in case of failure
    isolated remote function getDataProtectionPolicy(string topicArn) returns json|Error {
        map<string> parameters = initiateRequest("GetDataProtectionPolicy");
        parameters["ResourceArn"] = topicArn;

        http:Request request = check self.generateRequest(parameters);
        json response = check sendRequest(self.amazonSNSClient, request);

        do {
            return check response.GetDataProtectionPolicyResponse.GetDataProtectionPolicyResult.DataProtectionPolicy;
        } on fail error e {
            return error ResponseHandleFailedError(e.message(), e);
        }
    };

    # Sets the default settings for sending SMS messages and receiving daily SMS usage reports.
    # 
    # + attributes - The settings for sending SMS messages and receiving daily SMS usage reports
    # + return - `()` or `sns:Error` in case of failure
    isolated remote function setSMSAttributes(SMSAttributes attributes) returns Error? {
        map<string> parameters = initiateRequest("SetSMSAttributes");

        record {} formattedSMSAttributes = check formatAttributes(attributes);
        setAttributes(parameters, formattedSMSAttributes, true);

        http:Request request = check self.generateRequest(parameters);
        _ = check sendRequest(self.amazonSNSClient, request);
    };

    # Retrieves the default settings for sending SMS messages and receiving daily SMS usage reports.
    # 
    # + return - The default settings for sending SMS messages and receiving daily SMS usage reports or `sns:Error` in
    #            case of failure
    isolated remote function getSMSAttributes() returns SMSAttributes|Error {
        map<string> parameters = initiateRequest("GetSMSAttributes");

        http:Request request = check self.generateRequest(parameters);
        json response = check sendRequest(self.amazonSNSClient, request);

        do {
            json attributes = check response.GetSMSAttributesResponse.GetSMSAttributesResult.attributes;
            return check mapJsonToSMSAttributes(attributes);
        } on fail error e {
            return error ResponseHandleFailedError(e.message(), e);
        }
    };

    private isolated function generateRequest(map<string> parameters)
    returns http:Request|Error {
        [int, decimal] & readonly currentTime = time:utcNow();
        string|error xamzDate = utcToString(currentTime, "yyyyMMdd'T'HHmmss'Z'");
        string|error dateStamp = utcToString(currentTime, "yyyyMMdd");

        if xamzDate is string && dateStamp is string {
            string contentType = "application/x-www-form-urlencoded";
            string|url:Error requestParameters = self.createPayload(parameters);
            if requestParameters is url:Error {
                return error GenerateRequestFailed(requestParameters.message(), requestParameters);
            }

            string canonicalQuerystring = EMPTY_STRING;
            string? availableSecurityToken = self.securityToken;
            string canonicalHeaders = EMPTY_STRING;
            string signedHeaders = EMPTY_STRING;

            //Create a canonical request for Signature Version 4
            if availableSecurityToken is string {
                canonicalHeaders = "content-type:" + contentType + "\n" + "host:" + self.amazonHost + "\n"
                + "x-amz-date:" + xamzDate + "\n" + "x-amz-security-token" + availableSecurityToken + "\n";
                signedHeaders = "content-type;host;x-amz-date;x-amz-security-token";
            } else {
                canonicalHeaders = "content-type:" + contentType + "\n" + "host:" + self.amazonHost + "\n"
                    + "x-amz-date:" + xamzDate + "\n";
                signedHeaders = "content-type;host;x-amz-date";
            }
            string payloadHash = array:toBase16(crypto:hashSha256(requestParameters.toBytes())).toLowerAscii();
            string canonicalRequest = "POST" + "\n" + "/" + "\n" + canonicalQuerystring + "\n"
                + canonicalHeaders + "\n" + signedHeaders + "\n" + payloadHash;
            string algorithm = "AWS4-HMAC-SHA256";
            string credentialScope = dateStamp + "/" + self.region + "/" + "sns"
                + "/" + "aws4_request";

            //Create a string to sign for Signature Version 4
            string stringToSign = algorithm + "\n" + xamzDate + "\n" + credentialScope + "\n"
                + array:toBase16(crypto:hashSha256(canonicalRequest.toBytes())).toLowerAscii();

            //Calculate the signature for AWS Signature Version 4
            string signature;
            do {
                byte[] signingKey = check self.calculateSignature(self.secretAccessKey, dateStamp, self.region, "sns");
                signature = array:toBase16(check crypto:hmacSha256(stringToSign.toBytes(), signingKey)).toLowerAscii();
            } on fail error e {
                return error CalculateSignatureFailedError(e.message(), e);
            }

            //Add the signature to the HTTP request
            string authorizationHeader = algorithm + " " + "Credential=" + self.accessKeyId + "/"
                + credentialScope + ", " + "SignedHeaders=" + signedHeaders + ", " + "Signature=" + signature;
            map<string> headers = {};
            headers["Content-Type"] = contentType;
            headers["X-Amz-Date"] = xamzDate;
            headers["Authorization"] = authorizationHeader;
            headers["Accept"] = "application/json";

            http:Request request = new;
            request.setTextPayload(requestParameters);

            foreach var [key, value] in headers.entries() {
                request.setHeader(key, value);
            }
            
            return request;
        } else {
            return error GenerateRequestFailed(GENERATE_REQUEST_FAILED_MSG);
        }
    }

    //Calculate the signature for AWS Signature Version 4.
    private isolated function calculateSignature(string secretAccessKey, string datestamp, string region, string serviceName)
                                            returns byte[]|error {
        string kSecret = secretAccessKey;
        byte[] kDate = check crypto:hmacSha256(datestamp.toBytes(), ("AWS4" + kSecret).toBytes());
        byte[] kRegion = check crypto:hmacSha256(region.toBytes(), kDate);
        byte[] kService = check crypto:hmacSha256(serviceName.toBytes(), kRegion);
        byte[] kSigning = check crypto:hmacSha256("aws4_request".toBytes(), kService);
        return kSigning;
    }

    private isolated function createPayload(map<string> parameters) returns string|url:Error {
        string payload = EMPTY_STRING;
        int parameterNumber = 1;
        foreach var [key, value] in parameters.entries() {
            if parameterNumber > 1 {
                payload = payload + "&";
            }
            payload = payload + key + "=" + check url:encode(value, "UTF-8");
            parameterNumber = parameterNumber + 1;
        }
        return payload;
    }

}

# Represents the AWS SNS client connection configuration.
#
# + auth - Do not provide authentication credentials here
# + accessKeyId - AWS access key ID
# + secretAccessKey - AWS secret access key
# + securityToken - AWS security token
# + region - AWS SNS region. Default value is "us-east-1"
public type ConnectionConfig record {|
    *config:ConnectionConfig;
    never auth?;
    string accessKeyId;
    string secretAccessKey;
    string securityToken?;
    string region = DEFAULT_REGION;
|};
