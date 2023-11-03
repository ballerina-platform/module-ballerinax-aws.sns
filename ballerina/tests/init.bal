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

import ballerina/time;
import ballerina/lang.regexp;
import ballerina/test;
import ballerina/log;
import ballerina/os;

string testRunId = regexp:replaceAll(re `[:.]`, time:utcToString(time:utcNow()), "");

configurable string accessKeyId = os:getEnv("ACCESS_KEY_ID");
configurable string secretAccessKey = os:getEnv("SECRET_ACCESS_KEY");
configurable string region = os:getEnv("REGION");

ConnectionConfig config = {
    accessKeyId: accessKeyId,
    secretAccessKey: secretAccessKey,
    region: region,
    retryConfig: {
        count: 3,
        interval: 10
    } 
};

Client amazonSNSClient = check new(config);

string testHttp = "http://www.wso2.com";
string testHttps = "https://www.wso2.com";
string testEmail = "test@wso2.com";
string testPhoneNumber = "+94123456789";
string testApplication = "";
string testEndpoint = "";

configurable string admClientId = os:getEnv("ADM_CLIENT_ID");
configurable string admClientSecret = os:getEnv("ADM_CLIENT_SECRET");
configurable string testIamRole = os:getEnv("TEST_IAM_ROLE");
configurable string testAwsAccountId = os:getEnv("AWS_ACCOUNT_ID");

@test:BeforeSuite
function resetEnvironment() returns error? {
    check deleteAllTopics();
    check deleteAllPlatformApplications();
    check deleteAllSubscriptions();
    check initializeTestVariables();
}

// Existing topics need to be deleted as SNS imposes a limit on the # of topics an account may have
function deleteAllTopics() returns error? {
    stream<string, Error?> topicStream = amazonSNSClient->listTopics();
    string[] topicArns = check from string topicArn in topicStream select topicArn;
    
    foreach int i in 1...topicArns.length() {
        check amazonSNSClient->deleteTopic(topicArns[i-1]);
        log:printInfo(i.toString() + "/" + topicArns.length().toString() + " topics deleted - " + topicArns[i-1]);
    }
}

// Existing applications need to be deleted as SNS imposes a limit on the # of applications an account may have
function deleteAllPlatformApplications() returns error? {
    stream<PlatformApplication, Error?> applicationStream = amazonSNSClient->listPlatformApplications();
    string[] applicationArns = check from PlatformApplication application in applicationStream
        select application.platformApplicationArn;
    
    foreach int i in 1...applicationArns.length() {
        check amazonSNSClient->deletePlatformApplication(applicationArns[i-1]);
        log:printInfo(i.toString() + "/" + applicationArns.length().toString() + " platform applications deleted");
    }
}

// Existing subscriptions need to be deleted as SNS imposes a limit on the # of subscriptions an account may have
function deleteAllSubscriptions() returns error? {
    stream<Subscription, Error?> subscriptionStream = amazonSNSClient->listSubscriptions();
    string[] subscriptionArns = check from Subscription subscription in subscriptionStream
        where subscription.subscriptionArn != "PendingConfirmation"
        select subscription.subscriptionArn;
    
    foreach int i in 1...subscriptionArns.length() {
        check amazonSNSClient->unsubscribe(subscriptionArns[i-1]);
        log:printInfo(i.toString() + "/" + subscriptionArns.length().toString() + " subscriptions deleted");
    }
}

function initializeTestVariables() returns error? {
    testApplication = check amazonSNSClient->createPlatformApplication(testRunId + "AmazonPlatformApplication",
        AMAZON_DEVICE_MESSAGING, auth = {platformCredential: admClientSecret, platformPrincipal: admClientId});
    testEndpoint = check amazonSNSClient->createEndpoint(testApplication, testRunId + "testDeviceToken");
}

function isArn(string arn) returns boolean {
    return arn.startsWith("arn:aws:");
}
