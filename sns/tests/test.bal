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
function testCreateTopic() return error? {
    TopicAttribute attributes = {
        displayName : "Test"
    };
    CreateTopicResponse response = check amazonSNSClient->createTopic(testTopic, attributes);
    topicArn = response.createTopicResult.topicArn;
    test:assertTrue(response is CreateTopicResponse);
}

@test:Config{dependsOn: [testCreateTopic]}
function testSubscribe() return error? {
    SubscribeResponse response = check amazonSNSClient->subscribe(topicArn, EMAIL, "kapilraaj1995@gmail.com", true);
    subscriptionArn = response.subscribeResult.subscriptionArn;
    test:assertTrue(response is SubscribeResponse);
}

@test:Config{dependsOn: [testSubscribe]}
function testPublish() return error? {
    PublishResponse response = check amazonSNSClient->publish("Notification Message", topicArn);
    test:assertTrue(response is PublishResponse);
}

@test:Config{dependsOn: [testPublish]}
function testUnsubscribe() return error? {
    UnsubscribeResponse response = check amazonSNSClient->unsubscribe(subscriptionArn);
    test:assertTrue(response is UnsubscribeResponse);
}

@test:Config{}
function testGetSMSAttributes() return error? {
    GetSMSAttributesResponse response = check amazonSNSClient->getSMSAttributes();
    test:assertTrue(response is GetSMSAttributesResponse);
}

@test:Config{}
function testGetTopicAttributes() return error? {
    GetTopicAttributesResponse response = check amazonSNSClient->getTopicAttributes(topicArn);
    test:assertTrue(response is GetTopicAttributesResponse);
}

@test:Config{}
function testGetSubscriptionAttributes() return error? {
    GetSubscriptionAttributesResponse response = check amazonSNSClient->getSubscriptionAttributes(subscriptionArn);
    test:assertTrue(response is GetSubscriptionAttributesResponse);
}

@test:AfterSuite {}
function testDeleteTopic() return error? {
    DeleteTopicResponse response = check amazonSNSClient->deleteTopic(topicArn);
    test:assertTrue(response is DeleteTopicResponse);
}
