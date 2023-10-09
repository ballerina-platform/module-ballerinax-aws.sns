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

string topic = "";
string fakeTopic = "";

@test:BeforeGroups {value: ["subscribe", "subscribex"]}
function beforeSubscribeTests() returns error? {
    topic = check amazonSNSClient->createTopic(testRunId + "SubscribeTopic");
    fakeTopic = check amazonSNSClient->createTopic(testRunId + "FakeSubscribeTopic");
    _ = check amazonSNSClient->deleteTopic(fakeTopic);
}

   
@test:Config {
    groups: ["subscribe"]
}
function subscribeWithoutReturnArnTest() returns error? {
    string subsriptionArn = check amazonSNSClient->subscribe(topic, testEmail, EMAIL);
    test:assertEquals(subsriptionArn, "pending confirmation");
}

@test:Config {
    groups: ["subscribe"]
}
function subscribeWithReturnArnTest() returns error? {
    string subsriptionArn = 
        check amazonSNSClient->subscribe(topic, testEmail, EMAIL, returnSubscriptionArn = true);
    test:assertTrue(isArn(subsriptionArn), "Returned value is not an ARN.");
}

@test:Config {
    groups: ["subscribe"]
}
function subscribeHttpTest() returns error? {
    string subsriptionArn =
        check amazonSNSClient->subscribe(topic, testHttp, HTTP, returnSubscriptionArn = true);
    test:assertTrue(isArn(subsriptionArn), "Returned value is not an ARN.");
}

@test:Config {
    groups: ["subscribe"]
}
function subscribeHttpsTest() returns error? {
    string subsriptionArn =
        check amazonSNSClient->subscribe(topic, testHttps, HTTPS, returnSubscriptionArn = true);
    test:assertTrue(isArn(subsriptionArn), "Returned value is not an ARN.");
}

@test:Config {
    groups: ["subscribe"]
}
function subscribeEmailTest() returns error? {
    string subsriptionArn =
        check amazonSNSClient->subscribe(topic, testEmail, EMAIL, returnSubscriptionArn = true);
    test:assertTrue(isArn(subsriptionArn), "Returned value is not an ARN.");
}

@test:Config {
    groups: ["subscribe"]
}
function subscribeEmailJsonTest() returns error? {
    string subsriptionArn =
        check amazonSNSClient->subscribe(topic, testEmail, EMAIL_JSON, returnSubscriptionArn = true);
    test:assertTrue(isArn(subsriptionArn), "Returned value is not an ARN.");
}

@test:Config {
    groups: ["subscribe"]
}
function subscribeSmsTest()returns error? {
    string subsriptionArn =
        check amazonSNSClient->subscribe(topic, testPhoneNumber, SMS, returnSubscriptionArn = true);
    test:assertTrue(isArn(subsriptionArn), "Returned value is not an ARN.");
}

// TODO: Enable test case for SQS
// @test:Config {
//     groups: ["subscribex"]
// }
// function subscribeSqsTest() returns error? {
//     string subsriptionArn =
//         check amazonSNSClient->subscribe(topic, testSqs, SQS, returnSubscriptionArn = true);
//     test:assertTrue(subsriptionArn.matches(arnRegex), "Returned value is not an ARN.");
// }

@test:Config {
    groups: ["subscribe"]
}
function subscribeApplicationTest() returns error? {
    string subsriptionArn =
        check amazonSNSClient->subscribe(topic, testApplication, APPLICATION, returnSubscriptionArn = true);
    test:assertTrue(isArn(subsriptionArn), "Returned value is not an ARN.");
}

// TODO: Enable test case for Lambda
// @test:Config {
//     groups: ["subscribex"]
// }
// function subscribeLambdaTest() returns error? {
//     string subsriptionArn =
//         check amazonSNSClient->subscribe(topic, testLambda, LAMBDA, returnSubscriptionArn = true);
//     test:assertTrue(subsriptionArn.matches(arnRegex), "Returned value is not an ARN.");
// }

// TODO: Enable test case for Firehose
// @test:Config {
//     groups: ["subscribex"]
// }
// function subscribeFirehoseTest() returns error? {
//     string subsriptionArn =
//         check amazonSNSClient->subscribe(topic, testFirehose, FIREHOSE, returnSubscriptionArn = true);
//     test:assertTrue(subsriptionArn.matches(arnRegex), "Returned value is not an ARN.");
// }

@test:Config {
    groups: ["subscribe"]
}
function subscribeToNonExistantTopicTest() returns error? {
    string|Error subsriptionArn = 
        amazonSNSClient->subscribe(fakeTopic, testApplication, APPLICATION, returnSubscriptionArn = true);
    
    test:assertTrue(subsriptionArn is OperationError, "Expected error.");
    test:assertEquals((<OperationError>subsriptionArn).message(), "Topic does not exist");
}

@test:Config {
    groups: ["subscribe"]
}
function subscribeWithInvalidEndpointTest() returns error? {
    string|Error subsriptionArn =
        amazonSNSClient->subscribe(topic, "this is not an email", EMAIL, returnSubscriptionArn = true);
    test:assertTrue(subsriptionArn is OperationError, "Expected error.");
    test:assertEquals((<OperationError>subsriptionArn).message(), "Invalid parameter: Email address");
}

@test:Config {
    groups: ["subscribe"]
}
function subscribeWithInvalidArnTest() returns error? {
    string|Error subsriptionArn =
        amazonSNSClient->subscribe(topic, topic, APPLICATION, returnSubscriptionArn = true);
    test:assertTrue(subsriptionArn is OperationError, "Expected error.");
    test:assertTrue((<OperationError>subsriptionArn).message().startsWith("Invalid parameter: Application endpoint arn invalid:arn"));
}

@test:Config {
    groups: ["subscribe"]
}
function subscribeWithAttributesTest() returns error? {
    string topic = check amazonSNSClient->createTopic(testRunId + "SubscribeTopic2");
    SubscriptionAttributes attributes = {
        deliveryPolicy: {healthyRetryPolicy: {numRetries: 3, minDelayTarget: 5, maxDelayTarget: 10}},
        filterPolicy: {store:["example_corp"]},
        filterPolicyScope: MESSAGE_BODY,
        //TODO: test redrive policy and subscription role ARN
        rawMessageDelivery: true
    };
    string subsriptionArn =
        check amazonSNSClient->subscribe(topic, testHttp, HTTP, attributes, true);
    test:assertTrue(isArn(subsriptionArn), "Returned value is not an ARN.");
}

@test:Config {
    groups: ["subscribe"]
}
function subscribeWithInvalidAttributeTest() returns error? {
    SubscriptionAttributes attributes = {
        deliveryPolicy: {healthyRetryPolicy: {numRetries: 3, minDelayTarget: 5, maxDelayTarget: 10}},
        filterPolicy: {store: ["example_corp"]},
        filterPolicyScope: MESSAGE_BODY,
        rawMessageDelivery: true
    };
    string|Error subsriptionArn =
        amazonSNSClient->subscribe(topic, testEmail, EMAIL, attributes, true);
    test:assertTrue(subsriptionArn is Error, "Expected error.");
    test:assertEquals((<OperationError>subsriptionArn).message(), "Invalid parameter: Attributes Reason: Delivery protocol [email] does not support raw message delivery.");
}

@test:Config {
    groups: ["subscribe"],
    enable: true
}
function confirmSubscriptionTest() returns error? {
    string topic = check amazonSNSClient->createTopic(testRunId + "SubscribeTopic3");
    _ = check amazonSNSClient->subscribe(topic, testEmail, EMAIL);
    string token = "2336412f37fb687f5d51e6e2425c464cefc6029303415bf22f632d6c1109584e3a0c5a9cb81735ec0ba6302001ae62e84c830f41c6cae9c7eeea0532b02990b572d9105532fe2ee1e97e3e06eb4b7931171f38d544f59f1077fe3dba807e1b570e992ebd62fef0677d928fafd61cf2a3b91e511bf54e99ae3270528fbd38b10709758e4c1d77ff77bbc7d460ef177618";
    string subsriptionArn = check amazonSNSClient->confirmSubscription(topic, token);
    test:assertTrue(isArn(subsriptionArn), "Returned value is not an ARN.");
}

@test:Config {
    groups: ["subscribe"],
    enable: true
}
function confirmSubscriptionWithInvalidTokenTest() returns error? {
    string topic = check amazonSNSClient->createTopic(testRunId + "SubscribeTopic4");
    _ = check amazonSNSClient->subscribe(topic, testEmail, EMAIL);
    string token = "2336412f37fb687fd51e6e2425c464cefc6029303415bf22f632d6c1109584e3a0c5a9cb81735ec0ba6302001ae62e84c830f41c6cae9c7eeea0532b02990b572d9105532fe2ee1e97e3e06eb4b7931171f38d544f59f1077fe3dba807e1b570e992ebd62fef0677d928fafd61cf2a3b91e511bf54e99ae3270528fbd38b10709758e4c1d77ff77bbc7d460ef177618";
    string|error subsriptionArn = amazonSNSClient->confirmSubscription(topic, token);
    test:assertTrue(subsriptionArn is OperationError, "Expected error.");
    test:assertEquals((<OperationError>subsriptionArn).message(), "Invalid token");
}

@test:Config {
    groups: ["subscribe"]
}
function getSubscriptionAttributesTest1() returns error? {
    string topic = check amazonSNSClient->createTopic(testRunId + "SubscribeTopic5");
    string subscription = check amazonSNSClient->subscribe(topic, testEmail, EMAIL, returnSubscriptionArn = true);

    GettableSubscriptionAttributes attributes = check amazonSNSClient->getSubscriptionAttributes(subscription);
    test:assertEquals(attributes.subscriptionArn, subscription);
    test:assertEquals(attributes.endpoint, testEmail);
    test:assertEquals(attributes.protocol, EMAIL);
    test:assertEquals(attributes.topicArn, topic);
    test:assertTrue(isArn(attributes.subscriptionPrincipal));
    test:assertEquals(attributes.confirmationWasAuthenticated, false);
    test:assertEquals(attributes.pendingConfirmation, true);
    test:assertEquals(attributes.rawMessageDelivery, false);
    test:assertEquals(attributes.owner.length(), 12);
}

@test:Config {
    groups: ["subscribex"]
}
function getSubscriptionAttributesTest2() returns error? {
    string topic = check amazonSNSClient->createTopic(testRunId + "SubscribeTopic5");

    SubscriptionAttributes setAttributes = {
        deliveryPolicy: {healthyRetryPolicy: {numRetries: 3, minDelayTarget: 5, maxDelayTarget: 10}},
        filterPolicy: {store: ["example_corp"]},
        filterPolicyScope: MESSAGE_BODY,
        //TODO: test redrive policy and subscription role ARN
        rawMessageDelivery: false
    };
    string subscription = check amazonSNSClient->subscribe(topic, testHttp, HTTP, setAttributes, true);

    GettableSubscriptionAttributes attributes = check amazonSNSClient->getSubscriptionAttributes(subscription);
    test:assertEquals(attributes.subscriptionArn, subscription);
    test:assertEquals(attributes.endpoint, testHttp);
    test:assertEquals(attributes.protocol, HTTP);
    test:assertEquals(attributes.topicArn, topic);
    test:assertTrue(isArn(attributes.subscriptionPrincipal));
    test:assertEquals(attributes.confirmationWasAuthenticated, false);
    test:assertEquals(attributes.pendingConfirmation, true);
    test:assertEquals(attributes.rawMessageDelivery, false);
    test:assertEquals(attributes.owner.length(), 12);
    test:assertTrue(attributes?.deliveryPolicy is json);
    test:assertEquals(attributes?.filterPolicy, setAttributes?.filterPolicy);
    test:assertEquals(attributes.filterPolicyScope, setAttributes.filterPolicyScope);
}
