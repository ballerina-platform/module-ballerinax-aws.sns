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

configurable string accessKeyId = os:getEnv("ACCESS_KEY_ID");
configurable string secretAccessKey = os:getEnv("SECRET_ACCESS_KEY");
configurable string region = os:getEnv("REGION");

string testTopic = "TestTopic";
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
    if (response is CreateTopicResponse) {
        topicArn = response.createTopicResult.topicArn.toString();
    }
    else {
        test:assertFail(response.toString());
    }
}

@test:Config{dependsOn: [testCreateTopic]}
function testSubscribe() {
    SubscribeResponse|error response = amazonSNSClient->subscribe(topicArn, SMS, "+94776718102", true);
    if (response is SubscribeResponse) {
        subscriptionArn = response.subscribeResult.subscriptionArn.toString();
    }
    else {
        test:assertFail(response.toString());
    }
}

@test:Config{dependsOn: [testSubscribe]}
function testPublish() {
    PublishResponse|error response = amazonSNSClient->publish("Notification Message", topicArn);
    if (response is error) {
        test:assertFail(response.toString());
    }
}

@test:Config{dependsOn: [testPublish]}
function testGetSMSAttributes() {
    GetSMSAttributesResponse|error response = amazonSNSClient->getSMSAttributes();
    if (response is error) {
        test:assertFail(response.toString());
    }
}

@test:Config{dependsOn: [testGetSMSAttributes]}
function testGetTopicAttributes() {
    GetTopicAttributesResponse|error response = amazonSNSClient->getTopicAttributes(topicArn);
    if (response is error) {
        test:assertFail(response.toString());
    }
}

@test:Config{dependsOn: [testGetTopicAttributes]}
function testGetSubscriptionAttributes() {
    GetSubscriptionAttributesResponse|error response = amazonSNSClient->getSubscriptionAttributes(subscriptionArn);
    if (response is error) {
        test:assertFail(response.toString());
    }
}

@test:Config{dependsOn: [testGetSubscriptionAttributes]}
function testUnsubscribe() {
    UnsubscribeResponse|error response = amazonSNSClient->unsubscribe(subscriptionArn);
    if (response is error) {
        test:assertFail(response.toString());
    }
}

@test:AfterSuite {}
function testDeleteTopic() {
    DeleteTopicResponse|error response = amazonSNSClient->deleteTopic(topicArn);
    if (response is error) {
        test:assertFail(response.toString());
    }
}