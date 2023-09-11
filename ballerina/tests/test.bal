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
import ballerina/log;

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
function testCreateTopic() returns error? {
    TopicAttributes attributes = {
        "displayName" : "Test"
    };
    CreateTopicResponse response = check amazonSNSClient->createTopic(testTopic, attributes);
    topicArn = response.createTopicResult.topicArn.toString();
}

@test:Config{dependsOn: [testCreateTopic]}
function testSubscribe() returns error? {
    SubscribeResponse response = check amazonSNSClient->subscribe(topicArn, SMS, "+94776718102", true);
    subscriptionArn = response.subscribeResult.subscriptionArn.toString();
    log:printInfo(response.toString());
}

@test:Config{dependsOn: [testSubscribe]}
function testPublish() returns error? {
    PublishResponse response = check amazonSNSClient->publish("Notification Message", topicArn);
    log:printInfo(response.toString());
}

@test:Config{dependsOn: [testPublish]}
function testGetSMSAttributes() returns error? {
    GetSMSAttributesResponse response = check amazonSNSClient->getSMSAttributes();
    log:printInfo(response.toString());
}

@test:Config{dependsOn: [testGetSMSAttributes]}
function testGetTopicAttributes() returns error? {
    GetTopicAttributesResponse response = check amazonSNSClient->getTopicAttributes(topicArn);
    log:printInfo(response.toString());
}

@test:Config{dependsOn: [testGetTopicAttributes]}
function testGetSubscriptionAttributes() returns error? {
    GetSubscriptionAttributesResponse response = check amazonSNSClient->getSubscriptionAttributes(subscriptionArn);
    log:printInfo(response.toString());
}   

@test:Config{dependsOn: [testGetSubscriptionAttributes]}
function testUnsubscribe() returns error? {
    UnsubscribeResponse response = check amazonSNSClient->unsubscribe(subscriptionArn);
    log:printInfo(response.toString());
}

@test:AfterSuite {}
function testDeleteTopic() returns error? {
    DeleteTopicResponse response = check amazonSNSClient->deleteTopic(topicArn);
    log:printInfo(response.toString());
}