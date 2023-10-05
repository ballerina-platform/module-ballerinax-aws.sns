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
string applicationArn = "arn:aws:sns:us-east-1:482724125666:endpoint/GCM/KaneelApplication/e1097da7-0f72-32e1-bb1e-8df05ad14443";
string invalidApplicationArn = "arn:aws:sns:us-east-1:482724125666:endpoint/GCM/KaneelApplication/e1097da7-0f72-32e1-bb1e-8df05ad14444";
string temp = "arn:aws:sns:us-east-1:482724125666:2023-10-05T104426830397ZPublishStandardTopic";

@test:BeforeGroups {value: ["publish", "publishx"]}
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
    groups: ["publish"]
}
function publishToApplication() returns error? {
    PublishMessageResponse response = check amazonSNSClient->publish(applicationArn, "Test Message",
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
    test:assertEquals((<Error>response).message(), "Invalid parameter: TargetArn Reason: No endpoint found for the target arn specified");
}

@test:Config {
    groups: ["publishx"]
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
    PublishMessageResponse response = check amazonSNSClient->publish(temp, message);
    test:assertTrue(response.messageId != "", "MessageID is empty.");
}