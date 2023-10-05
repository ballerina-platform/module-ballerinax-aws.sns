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
import ballerina/io;
import ballerina/url;

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
        check validateCredentails(self.accessKeyId,  self.secretAccessKey);

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

        if (attributes is InitializableTopicAttributes) {
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

        if (tags is map<string>) {
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

    # Returns a list of the topics ARNs. Each call returns a limited list of topics, up to 100.
    # If there are more topics, a NextToken is also returned, which can be used to retrieve the next set of topics.
    # 
    # + return - A stream of topic ARNs or `sns:Error` in case of failure
    isolated remote function listTopics() returns stream<string, Error?> {
        TopicsStream topicsStreamObject = new (self.amazonSNSClient, self.generateRequest);
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

    # Modifies the attributes of an Amazon SNS topic.
    #   
    # + topicArn - The Amazon Resource Name (ARN) of the topic
    # + attributes - The attributes to modify
    # + return - `()` or `sns:Error` in case of failure
    isolated remote function setTopicAttributes(string topicArn, SettableTopicAttributes attributes) returns Error? {
        map<string> parameters = initiateRequest("SetTopicAttributes");
        parameters["TopicArn"] = topicArn;

        record {} formattedTopicAttributes = check formatAttributes(attributes, SPECIAL_TOPIC_ATTRIBUTES_MAP);
        foreach [string, anydata] [key, value] in formattedTopicAttributes.entries() {
            parameters["AttributeName"] = key;
            if value is record {} {
                parameters["AttributeValue"] = value.toJsonString();
            } else {
                parameters["AttributeValue"] = value.toString();
            }

            http:Request request = check self.generateRequest(parameters);
            _ = check sendRequest(self.amazonSNSClient, request);
        }
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
    // TODO: can we move subject into Message? - DONE
    // TODO: can we use soemthing like spread operator - unsure
    isolated remote function publish(string target, Message message, TargetType targetType = TOPIC, 
    map<MessageAttributeValue>? attributes = (), string? deduplicationId = (), string? groupId = ())
        returns PublishMessageResponse|Error {
        _ = check validatePublishParameters(target, targetType, groupId);
        map<string> parameters = initiateRequest("Publish");

        if (targetType == TOPIC) {
            parameters["TopicArn"] = target;
        } else if (targetType == ARN) {
            parameters["TargetArn"] = target;
        } else {
            parameters["PhoneNumber"] = target;
        }
        
        if message is string {
            parameters["Message"] = <string>message;
        } else {
            parameters["MessageStructure"] = "json";

            if message.hasKey("subject") {
                parameters["Subject"] = message["subject"].toString();
                _ = message.remove("subject");
            }

            parameters["Message"] = mapMessageRecordToJson(message).toJsonString();
            io:println(mapMessageRecordToJson(message));
        }

        if (deduplicationId is string) {
            parameters["MessageDeduplicationId"] = deduplicationId;
        }

        if (groupId is string) {
            parameters["MessageGroupId"] = groupId;
        }

        if (attributes is map<MessageAttributeValue>) {
            setMessageAttributes(parameters, attributes);
        }

        http:Request request = check self.generateRequest(parameters);
        json response = check sendRequest(self.amazonSNSClient, request);

        do {
            PublishMessageResponse publishMessageResponse = {
                messageId: (check response.PublishResponse.PublishResult.MessageId).toString()
            };

            json|error sequenceNumber = response.PublishResponse.PublishResult.SequenceNumber;
            if sequenceNumber is json && sequenceNumber.toString() != "" {
                publishMessageResponse.sequenceNumber = sequenceNumber.toString();
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
        return <Error>error ("Not implemented");
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
        return <Error>error ("Not implemented");
    };

    # Verifies an endpoint owner's intent to receive messages by validating the token sent to the endpoint by an 
    # earlier subscribe action.
    #
    # + topicArn - The ARN of the topic for which you wish to confirm a subscription
    # + token - Short-lived token sent to an endpoint during the subscribe action
    # + authenticateOnUnsubscribe - Disallows unauthenticated unsubscribes of the subscription. If the value of this 
    #                               parameter is `true``, then only the topic owner and the subscription owner can 
    #                               unsubscribe the endpoint.
    isolated remote function confirmSubscription(string topicArn, string token, boolean authenticateOnUnsubscribe)
        returns string|Error {
        return <Error>error("Not implemented");
    };

    # Modifies the attributes of a subscription.
    # 
    # + subscriptionArn - The ARN of the subscription to modify
    # + attributes - The attributes to modify
    # + return - `()` or `sns:Error` in case of failure
    isolated remote function setSubscriptionAttributes(string subscriptionArn, SubscriptionAttributes attributes)
        returns Error? {
        return <Error>error ("Not implemented");
    };

    # Deletes a subscription. If the subscription requires authentication for deletion, only the owner of the 
    # subscription or the owner of the topic may unsubscribe. If the unsubscribe call does not require authentication 
    # and the requester is not the subscription owner, a final cancellation message is delivered to the endpoint, so 
    # that the endpoint owner can easily resubscribe to the topic if the unsubscribe request was unintended.
    # 
    # + subscriptionArn - The ARN of the subscription to be deleted
    # + return - `()` or `sns:Error` in case of failure
    isolated remote function unsubscribe(string subscriptionArn) returns Error? {
        return <Error>error ("Not implemented");
    };

    # Retrieves a list of the requester's subscriptions. Each call returns a limited list of subscriptions, up to 100. If 
    # there are more subscriptions, a NextToken is also returned. Use the NextToken parameter in a new ListSubscriptions
    # call to get further results.
    # 
    # + topicArn - The ARN of the topic for which you wish list the subscriptions
    # + nextToken - The token returned by the previous `listSubscriptions` call
    # + return - A tuple of `SubscriptionListObject[]` and `string?` containing the subscriptions and NextToken (if exists), or an
    #            `sns:Error` in case of failure
    isolated remote function listSubscriptions(string? topicArn = (), string? nextToken = ()) 
        returns [SubscriptionListObject[], string?]|Error {
        return <Error>error ("Not implemented");
    };

    # Retrieves the attributes of the requested subscription.
    # 
    # + subscriptionArn - The ARN of the subscription
    # + return - `SubscriptionObject` or `sns:Error` in case of failure
    isolated remote function getSubscription(string subscriptionArn) returns SubscriptionObject|Error {
        return <Error>error ("Not implemented");
    };

    # Creates a platform application object for one of the supported push notification services. You must specify 
    # `attributes.platformPrincipal` and `attributes.platformCredential` attributes.
    # - for `ADM` the `platformPrincipal` is the `client id` and `platformCredential` is the `client secret`
    # - for `APNS` and `APNS_SANDBOX` using certificate credentials, the `platformPrincipal` is the `SSL certificate` 
    #   and `platformCredential` is the `private key`
    # - for `APNS` and `APNS_SANDBOX` using token credentials, the `platformPrincipal` is the `signing key ID` and the 
    #   `platformCredential` is the `signing key` 
    # - for `FCM` there is no `platformPrincipal` and `platformCredential` is the `API key`
    # - for `BAIDU` the `platformPrincipal` is the `API key` and `platformCredential` is the `secret key`
    # - for `MPNS` the `platformPrincipal` is the `TLS certificate` and `platformCredential` is the `private key`
    # - for `WNS` the `platformPrincipal` is the `Package Security Identifier` and `platformCredential` is the `secret 
    #   key`
    # 
    # + name - The name of the platform application object to create
    # + platform - The platform of the application
    # + attributes - Attributes of the platform application
    # + return - The ARN of the platform application if successful, or `sns:Error` in case of failure
    isolated remote function createPlatformApplication(string name, Platform platform, 
        PlatformApplicationAttributes attributes) returns string|Error {
        return <Error>error ("Not implemented");
    };

    # Lists the platform application objects for the supported push notification services. Each call returns a limited
    # list of applications, up to 100. If there are more applications, a NextToken is also returned. Use the NextToken
    # parameter in a new `listPlatformApplications` call to get further results.
    # 
    # + nextToken - The token returned by the previous `listPlatformApplications` call
    # + return - A tuple of `PlatformApplication[]` and `string?` containing the platform applications and NextToken 
    isolated remote function listPlatformApplications(string? nextToken = ()) 
        returns [PlatformApplication[], string?]|Error {
        return <Error>error ("Not implemented");
    };

    # Retrieves a platform application object for one of the supported push notification services.
    # 
    # + platformApplicationArn - The ARN of the platform application object to retrieve
    # + return - `PlatformApplication` or `sns:Error` in case of failure
    isolated remote function getPlatformApplication(string platformApplicationArn) 
        returns PlatformApplication|Error {
        return <Error>error ("Not implemented");
    };

    # Modifies the attributes of a platform application object for one of the supported push notification services.
    # 
    # + platformApplicationArn - The ARN of the platform application object to modify
    # + attributes - The attributes to modify
    # + return - `()` or `sns:Error` in case of failure
    isolated remote function setPlatformApplicationAttributes(string platformApplicationArn, 
        PlatformApplicationAttributes attributes) returns Error? {
        return <Error>error ("Not implemented");
    };

    # Deletes a platform application object for one of the supported push notification services.
    # 
    # + platformApplicationArn - The ARN of the platform application object to delete
    # + return - `()` or `sns:Error` in case of failure
    isolated remote function deletePlatformApplication(string platformApplicationArn) returns Error? {
        return <Error>error ("Not implemented");
    };

    # Creates an endpoint for a device and mobile app on one of the supported push notification services. This action is
    # idempotent, so  if the requester already owns an endpoint with the same device token and attributes, that 
    # endpoint's ARN is returned without creating a new endpoint.
    # 
    # + platformApplicationArn - The ARN of the platform application
    # + token - Unique identifier created by the notification service for an app on a device. The specific name for 
    #           the token will vary, depending on which notification service is being used
    # + attributes - Attributes of the endpoint
    # + return - The ARN of the endpoint if successful, or `sns:Error` in case of failure
    isolated remote function createEndpoint(string platformApplicationArn, string token, 
        EndpointAttributes? attributes = ()) returns string|Error {
        return <Error>error ("Not implemented");
    };

    # Lists the endpoints associated with a specific platform application. Each call returns a limited list of 
    # endpoints, up to 100. If there are more applications, a NextToken is also returned. Use the `nextToken` parameter
    # in a new `listEndpoints` call to get further results.
    # 
    # + platformApplicationArn - The ARN of the platform application to retrieve endpoints for
    # + nextToken - The token returned by the previous `listEndpoints` call
    # + return - A tuple of `Endpoint[]` and `string?` containing the endpoints and the NextToken
    isolated remote function listEndpoints(string platformApplicationArn, string? nextToken = ()) 
        returns [Endpoint[], string?]|Error {
        return <Error>error ("Not implemented");
    };

    # Retrieves a platform application endpoint.
    # 
    # + endpointArn - The ARN of the endpoint
    # + return - An `Endpoint` or `sns:Error` in case of failure
    isolated remote function getEndpoint(string endpointArn) returns Endpoint|Error {
        return <Error>error ("Not implemented");
    };

    # Modifies the attributes of a platform application endpoint.
    # 
    # + endpointArn - The ARN of the endpoint
    # + attributes - The attributes to modify
    # + return - `()` or `sns:Error` in case of failure
    isolated remote function setEndpointAttributes(string endpointArn, EndpointAttributes attributes) 
        returns Error? {
        return <Error>error ("Not implemented");
    };

    # Deletes a platform application endpoint. This action is idempotent. When you delete an endpoint that is also 
    # subscribed to a topic, then you must also unsubscribe the endpoint from the topic.
    # 
    # + endpointArn - The ARN of the endpoint
    # + return - `()` or `sns:Error` in case of failure
    isolated remote function deleteEndpoint(string endpointArn) returns Error? {
        return <Error>error ("Not implemented");
    };

    # Adds a destination phone number to an AWS account in the SMS sandbox and sends a one-time password (OTP) to that 
    # phone number.
    # 
    # + phoneNumber - The destination phone number to verify
    # + languageCode - The language to use for sending the OTP
    # + return - `()` or `sns:Error` in case of failure
    isolated remote function createSMSSandboxPhoneNumber(string phoneNumber, LanguageCode? languageCode = EN_US) 
        returns Error? {
        return <Error>error ("Not implemented");
    };

    # Verifies a destination phone number with a one-time password (OTP) for the calling AWS account.
    # 
    # + phoneNumber - The destination phone number to verify
    # + otp - The OTP sent to the destination number
    # + return - `()` or `sns:Error` in case of failure
    isolated remote function verifySMSSandboxPhoneNumber(string phoneNumber, string otp) returns Error? {
        return <Error>error ("Not implemented");
    };

    # Lists the current verified and pending destination phone numbers in the SMS sandbox. Each call returns a limited 
    # list of phone numbers, up to 100. If there are more phone numbers, a NextToken is also returned. Use the 
    # `nextToken` parameter in a new `listSMSSandboxPhoneNumbers` call to get further results.
    # 
    # + maxResults - The maximum number of phone numbers to return
    # + nextToken - The token returned by the previous `listSMSSandboxPhoneNumbers` call
    # + return - A tuple of `SMSSandboxPhoneNumber[]` and `string?` containing the phone numbers and the NextToken
    isolated remote function listSMSSandboxPhoneNumbers(int maxResults, string? nextToken = ()) 
        returns [SMSSandboxPhoneNumber[], string?]|Error {
        return <Error>error ("Not implemented");
    };

    # Deletes a verified or pending phone number from the SMS sandbox.
    # 
    # + phoneNumber - The destination phone number to delete
    # + return - `()` or `sns:Error` in case of failure
    isolated remote function deleteSMSSandboxPhoneNumber(string phoneNumber) returns Error? {
        return <Error>error ("Not implemented");
    };

    # Retrieves the SMS sandbox status for the calling AWS account in the target AWS Region.
    # 
    # + return - The SMS sandbox status for the calling AWS account in the target AWS Region or `sns:Error` in case of
    #            failure
    isolated remote function getSMSSandboxAccountStatus() returns boolean|Error {
        return <Error>error ("Not implemented");
    };

    # Lists the calling AWS account's dedicated origination numbers and their metadata. Each call returns a limited 
    # list of phone numbers, up to 30. If there are more phone numbers, a NextToken is also returned. Use the 
    # `nextToken` parameter in a new `listOriginationNumbers` call to get further results.
    # 
    # + maxResults - The maximum number (between 1 and 30 inclusive) of phone numbers to return
    # + nextToken - The token returned by the previous `listOriginationNumbers` call
    # + return - A tuple of `PhoneNumber[]` and `string?` containing the phone numbers and the NextToken
    isolated remote function listOriginationNumbers(int maxResults, string? nextToken = ()) 
        returns [OriginationPhoneNumber[], string?]|Error {
        return <Error>error ("Not implemented");
    }

    # Returns a list of phone numbers that are opted out, meaning you cannot send SMS messages to them. Each call 
    # returns a limited list of phone numbers, up to 100. If there are more phone numbers, a NextToken is also returned.
    # Use the `nextToken` parameter in a new `listPhoneNumbersOptedOut` call to get further results.
    # 
    # + nextToken - The token returned by the previous `listPhoneNumbersOptedOut` call
    # + return - A tuple of `string[]` and `string?` containing the phone numbers and the NextToken
    isolated remote function listPhoneNumbersOptedOut(string? nextToken = ()) 
        returns [string[], string?]|Error {
        return <Error>error ("Not implemented");
    }

    # Checks whether a phone number is opted out, meaning you cannot send SMS messages to it.
    # 
    # + phoneNumber - The phone number for which you want to check the opt out status.
    # + return - `true` if the phone number is opted out, `false` otherwise or `sns:Error` in case of failure
    isolated remote function checkIfPhoneNumberIsOptedOut(string phoneNumber) returns boolean|Error {
        return <Error>error ("Not implemented");
    }

    # Requests to opt in a phone number that is opted out, which enables you to resume sending SMS messages to the 
    # number. You can opt in a phone number only once every 30 days.
    # 
    # + phoneNumber - The destination phone number to opt in (in E.164 format)
    # + return - `()` or `sns:Error` in case of failure
    isolated remote function optInPhoneNumber(string phoneNumber) returns Error? {
        return <Error>error ("Not implemented");
    };

    # Adds tags to the specified Amazon SNS topic. A new tag with a key identical to that of an existing tag overwrites 
    # the existing tag.
    # 
    # + topicArn - The ARN of the topic to which to add tags
    # + tags - The tags to add to the specified topic
    # + return - `()` or `sns:Error` in case of failure
    // TODO: Can we do similar to the log module
    isolated remote function tagResource(string topicArn, map<string> tags) returns Error? {
        return <Error>error ("Not implemented");
    };

    # Lists the tags for the specified Amazon SNS topic.
    # 
    # + topicArn - The ARN of the topic for which to list tags
    # + return - A map of tag keys to tag values or `sns:Error` in case of failure
    isolated remote function listTags(string topicArn) returns map<string>|Error {
        return <Error>error ("Not implemented");
    };

    # Removes tags from the specified Amazon SNS topic.
    # 
    # + topicArn - The ARN of the topic from which to remove tags
    # + tagKeys - The list of tag keys to remove from the specified topic
    # + return - `()` or `sns:Error` in case of failure
    isolated remote function untagResource(string topicArn, string[] tagKeys) returns Error? {
        return <Error>error ("Not implemented");
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
        return <Error>error ("Not implemented");
    };

    # Removes a statement from a topic's access control policy.
    # 
    # + topicArn - The ARN of the topic from which to remove the policy
    # + label - The unique identifier for the policy statement to be removed
    # + return - `()` or `sns:Error` in case of failure
    isolated remote function removePermission(string topicArn, string label) returns Error? {
        return <Error>error ("Not implemented");
    };

    # Adds or updates the data protection policy of the specified Amazon SNS topic.
    # 
    # + topicArn - The ARN of the topic to which to add the policy
    # + policy - The policy document to add to the specified topic
    # + return - `()` or `sns:Error` in case of failure
    # // TODO: Check if in mulesoft and remove if not
    isolated function putDataProtectionPolicy(string topicArn, json dataProtectionPolicy) returns Error? {
        return <Error>error ("Not implemented");
    };

    # Retrieves the data protection policy for the specified Amazon SNS topic.
    # 
    # + topicArn - The ARN of the topic for which to retrieve the policy
    # + return - The data protection policy for the specified topic or `sns:Error` in case of failure
    isolated function getDataProtectionPolicy(string topicArn) returns json|Error {
        return <Error>error ("Not implemented");
    };

    # Sets the default settings for sending SMS messages and receiving daily SMS usage reports.
    # 
    # + attributes - The settings for sending SMS messages and receiving daily SMS usage reports
    # + return - `()` or `sns:Error` in case of failure
    isolated remote function setSMSAttributes(SMSAttributes attributes) returns Error? {
        return <Error>error ("Not implemented");
    };

    # Retrieves the default settings for sending SMS messages and receiving daily SMS usage reports.
    # 
    # + return - The default settings for sending SMS messages and receiving daily SMS usage reports or `sns:Error` in
    #            case of failure
    isolated remote function getSMSAttributes() returns SMSAttributes|Error {
        return <Error>error ("Not implemented");
    };


    private isolated function generateRequest(map<string> parameters)
    returns http:Request|Error {
        [int, decimal] & readonly currentTime = time:utcNow();
        string|error xamzDate = utcToString(currentTime, "yyyyMMdd'T'HHmmss'Z'");
        string|error dateStamp = utcToString(currentTime, "yyyyMMdd");

        if (xamzDate is string && dateStamp is string) {
            string contentType = "application/x-www-form-urlencoded";
            string|url:Error requestParameters = self.createPayload(parameters);
            if requestParameters is url:Error {
                return error GenerateRequestFailed(requestParameters.message(), requestParameters);
            }
            io:println(requestParameters);

            string canonicalQuerystring = EMPTY_STRING;
            string? availableSecurityToken = self.securityToken;
            string canonicalHeaders = EMPTY_STRING;
            string signedHeaders = EMPTY_STRING;

            //Create a canonical request for Signature Version 4
            if (availableSecurityToken is string) {
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
            if (parameterNumber > 1) {
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
# + accessKeyId - AWS access key ID
# + secretAccessKey - AWS secret access key
# + securityToken - AWS security token
# + region - AWS SNS region
public type ConnectionConfig record {|
    *config:ConnectionConfig;
    never auth?;
    string accessKeyId;
    string secretAccessKey;
    string securityToken?;
    string region = "us-east-1";
|};
