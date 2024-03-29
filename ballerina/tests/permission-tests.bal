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

@test:Config {
    groups: ["permission"]
}
function addPermissionBasicTest() returns error? {
    string topic = check amazonSNSClient->createTopic(testRunId + "testPermissionsTopic1");
    check amazonSNSClient->addPermission(topic, [PUBLISH], [testAwsAccountId], "testLabel");
}

@test:Config {
    groups: ["permission"]
}
function addPermissionComplexTest() returns error? {
    string topic = check amazonSNSClient->createTopic(testRunId + "testPermissionsTopic2");
    check amazonSNSClient->addPermission(
        topic, 
        [ADD_PERMISSION, DELETE_TOPIC, GET_DATA_PROTECTION_POLICY, GET_TOPIC_ATTRIBUTES, LIST_SUBSCRIPTIONS, LIST_TAGS,
        PUBLISH, PUT_DATA_PROTECTION_POLICY, REMOVE_PERMISSION, SET_TOPIC_ATTRIBUTES, SUBSCRIBE],
        [testAwsAccountId], 
        "testLabel"
    );
}

@test:Config {
    groups: ["permission"]
}
function addPermissionComplexTest2() returns error? {
    string topic = check amazonSNSClient->createTopic(testRunId + "testPermissionsTopic3");
    check amazonSNSClient->addPermission(
        topic, 
        [ADD_PERMISSION, DELETE_TOPIC, GET_DATA_PROTECTION_POLICY, GET_TOPIC_ATTRIBUTES, LIST_SUBSCRIPTIONS, LIST_TAGS,
        PUBLISH, PUT_DATA_PROTECTION_POLICY, REMOVE_PERMISSION, SET_TOPIC_ATTRIBUTES, SUBSCRIBE],
        [testAwsAccountId, testAwsAccountId], 
        "testLabel"
    );
}

@test:Config {
    groups: ["permission"]
}
function addPermissionInvalidAccountIdTest() returns error? {
    string topic = check amazonSNSClient->createTopic(testRunId + "testPermissionsTopic4");
    Error? e = amazonSNSClient->addPermission(
        topic,
        [
            ADD_PERMISSION,
            DELETE_TOPIC,
            GET_DATA_PROTECTION_POLICY,
            GET_TOPIC_ATTRIBUTES,
            LIST_SUBSCRIPTIONS,
            LIST_TAGS,
            PUBLISH,
            PUT_DATA_PROTECTION_POLICY,
            REMOVE_PERMISSION,
            SET_TOPIC_ATTRIBUTES,
            SUBSCRIBE
        ],
        ["InvalidAccountId"],
        "testLabel"
    );
    test:assertTrue(e is OperationError, "OperationError expected.");
    test:assertEquals((<OperationError>e).message(), "Invalid parameter: A provided account ID is not valid");
}

@test:Config {
    groups: ["permission"]
}
// SNS allows duplicate permissions to be added.
function addPermissionWithDuplicatesTest() returns error? {
    string topic = check amazonSNSClient->createTopic(testRunId + "testPermissionsTopic5");
    check amazonSNSClient->addPermission(topic, [PUBLISH, PUBLISH], [testAwsAccountId], "testLabel");
}

@test:Config {
    groups: ["permission"]
}
function removePermissionTest() returns error? {
    string topic = check amazonSNSClient->createTopic(testRunId + "testPermissionsTopic6");
    check amazonSNSClient->addPermission(topic, [PUBLISH], [testAwsAccountId], "testLabel");
    check amazonSNSClient->removePermission(topic, "testLabel");
}

@test:Config {
    groups: ["permission"]
}
function removePermissionTest2() returns error? {
    string topic = check amazonSNSClient->createTopic(testRunId + "testPermissionsTopic7");
    check amazonSNSClient->addPermission(topic, [PUBLISH], [testAwsAccountId], "testLabel");
    check amazonSNSClient->addPermission(topic, [PUBLISH], [testAwsAccountId], "testLabel2");
    check amazonSNSClient->removePermission(topic, "testLabel");
}

@test:Config {
    groups: ["permission"]
}
// SNS allows removing a permission label that does not exist.
function removePermissionDoesNotExistTest() returns error? {
    string topic = check amazonSNSClient->createTopic(testRunId + "testPermissionsTopic8");
    check amazonSNSClient->removePermission(topic, "ThisLabelDoesNotExist");
}

@test:Config {
    groups: ["permission"]
}
function removePermissionTopicDoesNotExistTest() returns error? {
    string topic = check amazonSNSClient->createTopic(testRunId + "testPermissionsTopic9");
    check amazonSNSClient->addPermission(topic, [PUBLISH], [testAwsAccountId], "testLabel");
    Error? e = amazonSNSClient->removePermission(topic + "invalid", "testLabel");
    test:assertTrue(e is OperationError, "OperationError expected.");
    test:assertEquals((<OperationError>e).message(), "Topic does not exist");
}
