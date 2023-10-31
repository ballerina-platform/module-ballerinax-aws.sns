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

import ballerina/test;

string standardTopic = "";
string fifoTopicWithCBD = "";
string fifoTopicWithoutCBD = "";
string invalidApplicationArn = testApplication + "x";

@test:BeforeGroups {value: ["publish"]}
function beforePublishTests() returns error? {
    standardTopic = check amazonSNSClient->createTopic(testRunId + "PublishStandardTopic");
    fifoTopicWithCBD = check amazonSNSClient->createTopic(testRunId + "PublishFifoTopicWithCBD", 
        {fifoTopic: true, contentBasedDeduplication: true});
    fifoTopicWithoutCBD = check amazonSNSClient->createTopic(testRunId + "PublishFifoTopicWithoutCDB", 
        {fifoTopic: true});
}

@test:Config {
    groups: ["publish"]
}
function publishToStandardTopicTest() returns error? {
    PublishMessageResponse response = check amazonSNSClient->publish(standardTopic, "Test Message");
    test:assertTrue(response.messageId != "", "MessageID is empty.");
}

@test:Config {
    groups: ["publish"]
}
function publishToFifoTopicWithCBDTest() returns error? {
    PublishMessageResponse response = check amazonSNSClient->publish(fifoTopicWithCBD,
        "Test Message", groupId = "test");
    test:assertTrue(response.messageId != "", "MessageID is empty.");
    test:assertTrue(response.sequenceNumber is string && response.sequenceNumber != "", "SequenceNumber is empty.");
}

@test:Config {
    groups: ["publish"]
}
function publishToFifoTopicWithCBDNegativeTest() returns error? {
    PublishMessageResponse|Error response = amazonSNSClient->publish(fifoTopicWithCBD, "Test Message");
    test:assertTrue(response is Error);
    test:assertEquals((<Error>response).message(), "A message published to a FIFO topic requires a group ID.");
}


@test:Config {
    groups: ["publish"]
}
function publishToFifoTopicWithoutCBDTest() returns error? {
    PublishMessageResponse response = check amazonSNSClient->publish(fifoTopicWithoutCBD,
        "Test Message", groupId = "test", deduplicationId = "test");
    test:assertTrue(response.messageId != "", "MessageID is empty.");
    test:assertTrue(response.sequenceNumber is string && response.sequenceNumber != "", "SequenceNumber is empty.");
}

@test:Config {
    groups: ["publish"]
}
function publishToFifoTopicWithoutCBDNegativeTest() returns error? {
    PublishMessageResponse|Error response = amazonSNSClient->publish(fifoTopicWithoutCBD,
        "Test Message", groupId = "test");
    test:assertTrue(response is OperationError);
    test:assertEquals((<Error>response).message(), "Invalid parameter: The topic should either have ContentBasedDeduplication enabled or MessageDeduplicationId provided explicitly");
}

@test:Config {
    groups: ["publish"]
}
function publishToPhoneNumber() returns error? {
    PublishMessageResponse response = check amazonSNSClient->publish("+94771952226", "Test Message",
        targetType = PHONE_NUMBER);
    test:assertTrue(response.messageId != "", "MessageID is empty.");
}

@test:Config {
    groups: ["publish"]
}
function publishToInvalidPhoneNumber() returns error? {
    PublishMessageResponse|Error response = amazonSNSClient->publish("InvalidPhoneNumber", "Test Message",
        targetType = PHONE_NUMBER);
    test:assertTrue(response is OperationError);
    test:assertEquals((<Error>response).message(), "Invalid parameter: PhoneNumber Reason: InvalidPhoneNumber is not valid to publish to");
}

@test:Config {
    groups: ["publish"],
    enable: false
}
function publishToApplication() returns error? {
    PublishMessageResponse response = check amazonSNSClient->publish(testEndpoint, "Test Message",
        targetType = ARN);
    test:assertTrue(response.messageId != "", "MessageID is empty.");
}

@test:Config {
    groups: ["publish"]
}
function publishToInvalidApplication() returns error? {
    PublishMessageResponse|Error response = amazonSNSClient->publish(invalidApplicationArn, "Test Message",
        targetType = ARN);
    test:assertTrue(response is OperationError);
    test:assertEquals((<Error>response).message(), "Invalid parameter: TargetArn Reason: ARN specifies an invalid endpointId: UUID must be encoded in exactly 36 characters.");
}

@test:Config {
    groups: ["publish"]
}
function publishWithComplexPayload() returns error? {
    Message message = {
        default: "Default message",
        subject: "Test message7",
        email: "Normal email",
        emailJson: "JSON email",
        sqs: "SQS",
        lambda: "Lambda",
        http: "HTTP",
        https: "HTTPS",
        sms: "SMS",
        firehose: "Firehose",
        apns: {title: "APNS", body: "APNS Body"}.toString(),
        apnsSandbox: {title: "APNS Sandbox", body: "APNS Sandbox Body"}.toString(),
        apnsVoip: {title: "APNS Voip", body: "APNS Voip Body"}.toString(),
        apnsVoipSandbox: {title: "APNS Voip Sandbox", body: "APNS Voip Sandbox Body"}.toString(),
        macos: {title: "MacOS", body: "MacOS Body"}.toString(),
        macosSandbox: {title: "MacOS Sandbox", body: "MacOS Sandbox Body"}.toString(),
        gcm: {title: "GCM", body: "GCM Body"}.toString(),
        adm: {title: "ADM", body: "ADM Body"}.toString(),
        baidu: {title: "Baidu", body: "Baidu Body"}.toString(),
        mpns: {title: "MPNS", body: "MPNS Body"}.toString(),
        wns: {title: "WNS", body: "WNS Body"}.toString()
    };
    PublishMessageResponse response = check amazonSNSClient->publish(standardTopic, message);
    test:assertTrue(response.messageId != "", "MessageID is empty.");
}

@test:Config {
    groups: ["publish"]
}
function publishWithAttributesTest() returns error? {
    map<MessageAttributeValue> attributes = {
        "StringAttribute": "StringAttributeValue",
        "IntAttribute": 123,
        "FloatAttribute": 123.45,
        "BinaryAttribute": "BinaryAttributeValue".toBytes(),
        "StringArrayAttribute": ["StringListAttributeValue1", "StringListAttributeValue2", true, false, (), 123, 123.45]
    };
    PublishMessageResponse response = check amazonSNSClient->publish(standardTopic, "Test Message", 
        attributes = attributes);
    test:assertTrue(response.messageId != "", "MessageID is empty.");
}

@test:Config {
    groups: ["publish", "batch"]
}
function publishBatchTest() returns error? {
    PublishBatchRequestEntry[] entries = [
        {message: "Test Message 1"},
        {message: "Test Message 2"},
        {message: "Test Message 3"}
    ];
    PublishBatchResponse response = check amazonSNSClient->publishBatch(standardTopic, entries);
    test:assertEquals(response.successful.length(), 3);
    test:assertEquals(response.failed.length(), 0);
}

@test:Config {
    groups: ["publish", "batch"]
}
function publishBatchWithIdsTest() returns error? {
    PublishBatchRequestEntry[] entries = [
        {id: "id1", message: "Test Message 1"},
        {id: "id2", message: "Test Message 2"},
        {id: "id3", message: "Test Message 3"}
    ];
    PublishBatchResponse response = check amazonSNSClient->publishBatch(standardTopic, entries);
    test:assertEquals(response.successful.length(), 3);
    test:assertEquals(response.failed.length(), 0);
    test:assertEquals(response.successful[0].id, "id1");
    test:assertEquals(response.successful[1].id, "id2");
    test:assertEquals(response.successful[2].id, "id3");
    test:assertTrue(response.successful[0].messageId.length() > 0);
    test:assertTrue(response.successful[1].messageId.length() > 0);
    test:assertTrue(response.successful[2].messageId.length() > 0);
}

@test:Config {
    groups: ["publish", "batch"]
}
function publishBatchToFifoTest() returns error? {
    PublishBatchRequestEntry[] entries = [
        {id: "id1", message: "Test Message 1", groupId: "group1", deduplicationId: "dedup1"},
        {id: "id2", message: "Test Message 2", groupId: "group2", deduplicationId: "dedup2"},
        {id: "id3", message: "Test Message 3", groupId: "group3", deduplicationId: "dedup3"}
    ];
    PublishBatchResponse response = check amazonSNSClient->publishBatch(fifoTopicWithoutCBD, entries);
    test:assertEquals(response.successful.length(), 3);
    test:assertEquals(response.failed.length(), 0);
    test:assertEquals(response.successful[0].id, "id1");
    test:assertEquals(response.successful[1].id, "id2");
    test:assertEquals(response.successful[2].id, "id3");
    test:assertTrue(response.successful[0].messageId.length() > 0);
    test:assertTrue(response.successful[1].messageId.length() > 0);
    test:assertTrue(response.successful[2].messageId.length() > 0);
    test:assertTrue(response.successful[0].sequenceNumber is string);
    test:assertTrue(response.successful[1].sequenceNumber is string);
    test:assertTrue(response.successful[2].sequenceNumber is string);
}

@test:Config {
    groups: ["publish", "batch"]
}
function publishBatchToFifoTestNegative() returns error? {
    PublishBatchRequestEntry[] entries = [
        {id: "id1", message: "Test Message 1", groupId: "group1", deduplicationId: "dedup1"},
        {id: "id2", message: "Test Message 2", groupId: "group2", deduplicationId: "dedup2"},
        {id: "id3", message: "Test Message 3", groupId: "group3"}
    ];
    PublishBatchResponse|error response = amazonSNSClient->publishBatch(fifoTopicWithoutCBD, entries);
    test:assertTrue(response is OperationError);
    test:assertEquals((<Error>response).message(), "Invalid parameter: The topic should either have ContentBasedDeduplication enabled or MessageDeduplicationId provided explicitly");
}

@test:Config {
    groups: ["publish", "batch"]
}
function publishBatchWithComplexPayload() returns error? {
    PublishBatchRequestEntry[] entries = [
        {id: "id1", message: {default: "Test Message 1", subject: "Subject"}},
        {id: "id2", message: {default: "Test Message 2", subject: "Subject", email: "Normal email", emailJson: "JSON email", sqs: "SQS", lambda: "Lambda", http: "HTTP", https: "HTTPS", sms: "SMS", firehose: "Firehose", apns: {title: "APNS", body: "APNS Body"}.toString(), apnsSandbox: {title: "APNS Sandbox", body: "APNS Sandbox Body"}.toString(), apnsVoip: {title: "APNS Voip", body: "APNS Voip Body"}.toString(), apnsVoipSandbox: {title: "APNS Voip Sandbox", body: "APNS Voip Sandbox Body"}.toString(), macos: {title: "MacOS", body: "MacOS Body"}.toString(), macosSandbox: {title: "MacOS Sandbox", body: "MacOS Sandbox Body"}.toString(), gcm: {title: "GCM", body: "GCM Body"}.toString(), adm: {title: "ADM", body: "ADM Body"}.toString(), baidu: {title: "Baidu", body: "Baidu Body"}.toString(), mpns: {title: "MPNS", body: "MPNS Body"}.toString(), wns: {title: "WNS", body: "WNS Body"}.toString()}},
        {id: "id3", message: {default: "Test Message 2", subject: "Subject", email: "Normal email", emailJson: "JSON email", sqs: "SQS", lambda: "Lambda", http: "HTTP", https: "HTTPS", sms: "SMS", firehose: "Firehose", apns: {title: "APNS", body: "APNS Body"}.toString(), apnsSandbox: {title: "APNS Sandbox", body: "APNS Sandbox Body"}.toString(), apnsVoip: {title: "APNS Voip", body: "APNS Voip Body"}.toString(), apnsVoipSandbox: {title: "APNS Voip Sandbox", body: "APNS Voip Sandbox Body"}.toString(), macos: {title: "MacOS", body: "MacOS Body"}.toString(), macosSandbox: {title: "MacOS Sandbox", body: "MacOS Sandbox Body"}.toString(), gcm: {title: "GCM", body: "GCM Body"}.toString(), adm: {title: "ADM", body: "ADM Body"}.toString(), baidu: {title: "Baidu", body: "Baidu Body"}.toString(), mpns: {title: "MPNS", body: "MPNS Body"}.toString(), wns: {title: "WNS", body: "WNS Body"}.toString()}}
    ];
    PublishBatchResponse response = check amazonSNSClient->publishBatch(standardTopic, entries);
    test:assertEquals(response.successful.length(), 3);
    test:assertEquals(response.failed.length(), 0);
    test:assertEquals(response.successful[0].id, "id1");
    test:assertEquals(response.successful[1].id, "id2");
    test:assertEquals(response.successful[2].id, "id3");
    test:assertTrue(response.successful[0].messageId.length() > 0);
    test:assertTrue(response.successful[1].messageId.length() > 0);
    test:assertTrue(response.successful[2].messageId.length() > 0);
}

@test:Config {
    groups: ["publish", "batch"]
}
function publishBatchWithAttributes() returns error? {
    map<MessageAttributeValue> attributes = {
        "StringAttribute": "StringAttributeValue",
        "IntAttribute": 123,
        "FloatAttribute": 123.45,
        "BinaryAttribute": "BinaryAttributeValue".toBytes(),
        "StringArrayAttribute": ["StringListAttributeValue1", "StringListAttributeValue2", true, false, (), 123, 123.45]
    };

    PublishBatchRequestEntry[] entries = [
        {message: "Test Message 1", attributes: attributes},
        {message: "Test Message 2", attributes: attributes},
        {message: "Test Message 3", attributes: attributes}
    ];
    PublishBatchResponse response = check amazonSNSClient->publishBatch(standardTopic, entries);
    test:assertEquals(response.successful.length(), 3);
    test:assertEquals(response.failed.length(), 0);
    test:assertEquals(response.successful[0].id, "1");
    test:assertEquals(response.successful[1].id, "2");
    test:assertEquals(response.successful[2].id, "3");
    test:assertTrue(response.successful[0].messageId.length() > 0);
    test:assertTrue(response.successful[1].messageId.length() > 0);
    test:assertTrue(response.successful[2].messageId.length() > 0);
}

@test:Config {
    groups: ["publish", "batch"]
}
function publishBatchWithFailures() returns error? {
    PublishBatchRequestEntry[] entries = [
        {id: "id1", message: {default: "Test Message 1", subject: "Subject"}},
        {id: "id2", message: {default: "Test Message 2", subject: "Invalid\nSubject", email: "Normal email", emailJson: "JSON email", sqs: "SQS", lambda: "Lambda", http: "HTTP", https: "HTTPS", sms: "SMS", firehose: "Firehose", apns: {title: "APNS", body: "APNS Body"}.toString(), apnsSandbox: {title: "APNS Sandbox", body: "APNS Sandbox Body"}.toString(), apnsVoip: {title: "APNS Voip", body: "APNS Voip Body"}.toString(), apnsVoipSandbox: {title: "APNS Voip Sandbox", body: "APNS Voip Sandbox Body"}.toString(), macos: {title: "MacOS", body: "MacOS Body"}.toString(), macosSandbox: {title: "MacOS Sandbox", body: "MacOS Sandbox Body"}.toString(), gcm: {title: "GCM", body: "GCM Body"}.toString(), adm: {title: "ADM", body: "ADM Body"}.toString(), baidu: {title: "Baidu", body: "Baidu Body"}.toString(), mpns: {title: "MPNS", body: "MPNS Body"}.toString(), wns: {title: "WNS", body: "WNS Body"}.toString()}},
        {id: "id3", message: {default: "Test Message 2", subject: "Subject", email: "Normal email", emailJson: "JSON email", sqs: "SQS", lambda: "Lambda", http: "HTTP", https: "HTTPS", sms: "SMS", firehose: "Firehose", apns: {title: "APNS", body: "APNS Body"}.toString(), apnsSandbox: {title: "APNS Sandbox", body: "APNS Sandbox Body"}.toString(), apnsVoip: {title: "APNS Voip", body: "APNS Voip Body"}.toString(), apnsVoipSandbox: {title: "APNS Voip Sandbox", body: "APNS Voip Sandbox Body"}.toString(), macos: {title: "MacOS", body: "MacOS Body"}.toString(), macosSandbox: {title: "MacOS Sandbox", body: "MacOS Sandbox Body"}.toString(), gcm: {title: "GCM", body: "GCM Body"}.toString(), adm: {title: "ADM", body: "ADM Body"}.toString(), baidu: {title: "Baidu", body: "Baidu Body"}.toString(), mpns: {title: "MPNS", body: "MPNS Body"}.toString(), wns: {title: "WNS", body: "WNS Body"}.toString()}},
        {id: "id4", message: {default: "Test Message 2", subject: "Invalid\nSubject", email: "Normal email", emailJson: "JSON email", sqs: "SQS", lambda: "Lambda", http: "HTTP", https: "HTTPS", sms: "SMS", firehose: "Firehose", apns: {title: "APNS", body: "APNS Body"}.toString(), apnsSandbox: {title: "APNS Sandbox", body: "APNS Sandbox Body"}.toString(), apnsVoip: {title: "APNS Voip", body: "APNS Voip Body"}.toString(), apnsVoipSandbox: {title: "APNS Voip Sandbox", body: "APNS Voip Sandbox Body"}.toString(), macos: {title: "MacOS", body: "MacOS Body"}.toString(), macosSandbox: {title: "MacOS Sandbox", body: "MacOS Sandbox Body"}.toString(), gcm: {title: "GCM", body: "GCM Body"}.toString(), adm: {title: "ADM", body: "ADM Body"}.toString(), baidu: {title: "Baidu", body: "Baidu Body"}.toString(), mpns: {title: "MPNS", body: "MPNS Body"}.toString(), wns: {title: "WNS", body: "WNS Body"}.toString()}}
    ];
    PublishBatchResponse response = check amazonSNSClient->publishBatch(standardTopic, entries);
    test:assertEquals(response.successful.length(),2);
    test:assertEquals(response.failed.length(), 2);
    test:assertEquals(response.successful[0].id, "id1");
    test:assertEquals(response.successful[1].id, "id3");
    test:assertTrue(response.successful[0].messageId.length() > 0);
    test:assertTrue(response.successful[1].messageId.length() > 0);
    test:assertEquals(response.failed[0].id, "id2");
    test:assertEquals(response.failed[1].id, "id4");
    test:assertEquals(response.failed[0].code , "InvalidParameter");
    test:assertEquals(response.failed[1].code, "InvalidParameter");
    test:assertEquals(response.failed[0].message, "Invalid parameter: Subject");
    test:assertEquals(response.failed[1].message, "Invalid parameter: Subject");
    test:assertTrue(response.failed[0].senderFault);
    test:assertTrue(response.failed[1].senderFault);
}
