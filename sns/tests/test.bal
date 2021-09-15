// Copyright (c) 2021 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
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
import ballerina/os;

configurable string testTopic = os:getEnv("TOPIC_NAME");
configurable string accessKeyId = os:getEnv("ACCESS_KEY_ID");
configurable string secretAccessKey = os:getEnv("SECRET_ACCESS_KEY");
configurable string region = os:getEnv("REGION");

string topicArn = "";
string subscriptionArn = "";

AwsCredentials awsCredentials = {
    accessKeyId: accessKeyId,
    secretAccessKey: secretAccessKey
};

ConnectionConfig config = {
    credentials: awsCredentials,
    region: region
};

Client amazonSNSClient = check new(config);

@test:Config{}
function testCreateTopic() {
    TopicAttribute attributes = {
        displayName : "Test"
    };
    CreateTopicResponse|error response = amazonSNSClient->createTopic(testTopic, attributes);
    if (response is error) {
        test:assertFail(response.toString());
    } else {
        topicArn = response.createTopicResult.topicArn;
        test:assertTrue(response is CreateTopicResponse);
    }
}

@test:Config{dependsOn: [testCreateTopic]}
function testSubscribe() {
    SubscribeResponse|error response = amazonSNSClient->subscribe(topicArn, EMAIL, "kapilraaj1995@gmail.com", true);
    if (response is error) {
        test:assertFail(response.toString());
    } else {
        subscriptionArn = response.subscribeResult.subscriptionArn;
        test:assertTrue(response is SubscribeResponse);
    }
}

@test:Config{dependsOn: [testSubscribe]}
function testPublish() {
    PublishResponse|error response = amazonSNSClient->publish("Notification Message", topicArn);
    if (response is error) {
        test:assertFail(response.toString());
    } else {
        test:assertTrue(response is PublishResponse);
    }
}

@test:Config{
    dependsOn: [testPublish]
    }
function testUnsubscribe() {
    UnsubscribeResponse|error response = amazonSNSClient->unsubscribe(subscriptionArn);
    if (response is error) {
        test:assertFail(response.toString());
    } else {
        test:assertTrue(response is UnsubscribeResponse);
    }
}

@test:Config{dependsOn: [testUnsubscribe]}
function testDeleteTopic() {
    DeleteTopicResponse|error response = amazonSNSClient->deleteTopic(topicArn);
    if (response is error) {
        test:assertFail(response.toString());
    } else {
        test:assertTrue(response is DeleteTopicResponse);
    }
}

@test:Config{}
function testGetSMSAttributes() {
    GetSMSAttributesResponse|error response = amazonSNSClient->getSMSAttributes();
    if (response is error) {
        test:assertFail(response.toString());
    } else {
        test:assertTrue(response is GetSMSAttributesResponse);
    }
}

@test:Config{}
function testGetTopicAttributes() {
    GetTopicAttributesResponse|error response = amazonSNSClient->getTopicAttributes(topicArn);
    if (response is error) {
        test:assertFail(response.toString());
    } else {
        test:assertTrue(response is GetTopicAttributesResponse);
    }
}

@test:Config{}
function testCreateSMSSandboxPhoneNumber() {
    json|error response = amazonSNSClient->createSMSSandboxPhoneNumber("+94776718102", "en-US");
    if (response is error) {
        test:assertFail(response.toString());
    } else {
        topicArn = response.toString();
    }
}

@test:Config{}
function testGetSubscriptionAttributes() {
    GetSubscriptionAttributesResponse|error response = amazonSNSClient->getSubscriptionAttributes(subscriptionArn);
    if (response is error) {
        test:assertFail(response.toString());
    } else {
        test:assertTrue(response is GetSubscriptionAttributesResponse);
    }
}