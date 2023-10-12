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
import ballerina/io;
import ballerina/lang.runtime as runtime;

configurable string firebaseServerKey = ?;
configurable string amazonClientId = ?;
configurable string amazonClientSecret = ?;
   
@test:Config {
    groups: ["platformApplication"]
}
function createFirebasePlatformApplicationTest() returns error? {
    string arn = check amazonSNSClient->createPlatformApplication(testRunId + "FirebasePlatformApplication", 
        FIREBASE_CLOUD_MESSAGING, auth = {platformCredential: firebaseServerKey});
    test:assertTrue(isArn(arn));
}

@test:Config {
    groups: ["platformApplication"]
}
function createAmazonPlatformApplicationTest() returns error? {
    string arn = check amazonSNSClient->createPlatformApplication(testRunId + "AmazonPlatformApplication",
        AMAZON_DEVICE_MESSAGING, auth = {platformCredential: amazonClientSecret, platformPrincipal: amazonClientId});
    test:assertTrue(isArn(arn));
}

@test:Config {
    groups: ["platformApplication"]
}
function createPlatformApplicationWithInvalidKeyTest1() returns error? {
    string|Error arn = amazonSNSClient->createPlatformApplication(testRunId + "InvalidPlatformApplication",
        FIREBASE_CLOUD_MESSAGING, auth = {platformCredential: "invalid"});
    test:assertTrue(arn is OperationError);
    test:assertEquals((<OperationError>arn).message(), "Invalid parameter: Attributes Reason: Platform credentials are invalid");
}

@test:Config {
    groups: ["platformApplication"]
}
function createPlatformApplicationWithInvalidKeyTest2() returns error? {
    string|Error arn = amazonSNSClient->createPlatformApplication(testRunId + "InvalidPlatformApplication",
        AMAZON_DEVICE_MESSAGING, auth = {platformCredential: amazonClientSecret, platformPrincipal: "invalid"});
    test:assertTrue(arn is OperationError);
    test:assertEquals((<OperationError>arn).message(), "Invalid parameter: Attributes Reason: Platform credentials are invalid");
}

@test:Config {
    groups: ["platformApplication"]
}
function createPlatformApplicationWithAttributesTest() returns error? {
    string topicArn = check amazonSNSClient->createTopic(testRunId + "PlatformApplicationTopic");
    PlatformApplicationAttributes attributes = {
        eventDeliveryFailure: topicArn,
        eventEndpointCreated: topicArn,
        eventEndpointDeleted: topicArn,
        eventEndpointUpdated: topicArn,
        successFeedbackRoleArn: testIamRole,
        failureFeedbackRoleArn: testIamRole,
        successFeedbackSampleRate: 5
    };

    string arn = check amazonSNSClient->createPlatformApplication(testRunId + "PlatformApplicationWithAttributes",
        AMAZON_DEVICE_MESSAGING, auth = {platformCredential: amazonClientSecret, platformPrincipal: amazonClientId},
        attributes = attributes);
    test:assertTrue(isArn(arn));
}

@test:Config {
    groups: ["platformApplication"]
}
function createPlatformApplicationAlreadyExists() returns error? {
    string topicArn = check amazonSNSClient->createTopic(testRunId + "PlatformApplicationTopic");
    PlatformApplicationAttributes attributes = {
        eventDeliveryFailure: topicArn,
        eventEndpointDeleted: topicArn,
        eventEndpointUpdated: topicArn,
        successFeedbackRoleArn: testIamRole,
        failureFeedbackRoleArn: testIamRole,
        successFeedbackSampleRate: 5
    };

    _ = check amazonSNSClient->createPlatformApplication(testRunId + "PlatformApplicationAlreadyExists",
        AMAZON_DEVICE_MESSAGING, auth = {platformCredential: amazonClientSecret, platformPrincipal: amazonClientId},
        attributes = attributes);

    attributes.eventEndpointCreated = topicArn;
    string|error arn = amazonSNSClient->createPlatformApplication(testRunId + "PlatformApplicationAlreadyExists",
        AMAZON_DEVICE_MESSAGING, auth = {platformCredential: amazonClientSecret, platformPrincipal: amazonClientId},
        attributes = attributes);
    test:assertTrue(arn is OperationError);
    test:assertEquals((<OperationError>arn).message(), "Invalid parameter: Name Reason: An application with the same name but different properties already exists");
}

@test:Config {
    groups: ["platformApplication"]
}
function createPlatformWithInvalidAttributes() returns error? {
    string topicArn = check amazonSNSClient->createTopic(testRunId + "PlatformApplicationTopic");
    PlatformApplicationAttributes attributes = {
        eventDeliveryFailure: topicArn,
        eventEndpointDeleted: topicArn,
        eventEndpointUpdated: topicArn,
        successFeedbackRoleArn: testIamRole,
        failureFeedbackRoleArn: testIamRole,
        successFeedbackSampleRate: 101
    };

    string|error arn = amazonSNSClient->createPlatformApplication(testRunId + "PlatformApplicationAlreadyExists",
        AMAZON_DEVICE_MESSAGING, auth = {platformCredential: amazonClientSecret, platformPrincipal: amazonClientId},
        attributes = attributes);
    test:assertTrue(arn is OperationError);
    test:assertEquals((<OperationError>arn).message(), "Invalid parameter: Attributes Reason: Invalid value for attribute: SuccessFeedbackSampleRate: 101 value provided is not an integer between 0-100");
}

@test:Config {
    groups: ["platformApplication"]
}
function listPlatformApplicationsTest() returns error? {
    string topicArn = check amazonSNSClient->createTopic(testRunId + "ListPlatformApplicationsTopic");
    PlatformApplicationAttributes attributes = {
        eventEndpointCreated: topicArn,
        eventDeliveryFailure: topicArn,
        eventEndpointDeleted: topicArn,
        eventEndpointUpdated: topicArn,
        successFeedbackRoleArn: testIamRole,
        failureFeedbackRoleArn: testIamRole,
        successFeedbackSampleRate: 5
    };

    string arn = check amazonSNSClient->createPlatformApplication(testRunId + "ListPlatformApplications",
        AMAZON_DEVICE_MESSAGING, auth = {platformCredential: amazonClientSecret, platformPrincipal: amazonClientId},
        attributes = attributes);

    // Validate newly created platform application
    stream<PlatformApplication, Error?> platformApplications = amazonSNSClient->listPlatformApplications();
    PlatformApplication[] retrievedPlatformApplications = 
        check from PlatformApplication platformApplication in platformApplications
        where platformApplication.platformApplicationArn == arn
        select platformApplication;
    test:assertEquals(retrievedPlatformApplications.length(), 1);
    test:assertEquals(retrievedPlatformApplications[0].platformApplicationArn, arn);
    test:assertEquals(retrievedPlatformApplications[0].eventEndpointCreated, topicArn);
    test:assertEquals(retrievedPlatformApplications[0].eventDeliveryFailure, topicArn);
    test:assertEquals(retrievedPlatformApplications[0].eventEndpointDeleted, topicArn);
    test:assertEquals(retrievedPlatformApplications[0].eventEndpointUpdated, topicArn);
    test:assertEquals(retrievedPlatformApplications[0].successFeedbackRoleArn, testIamRole);
    test:assertEquals(retrievedPlatformApplications[0].failureFeedbackRoleArn, testIamRole);
    test:assertEquals(retrievedPlatformApplications[0].successFeedbackSampleRate, 5);
    test:assertEquals(retrievedPlatformApplications[0].enabled, true);

    platformApplications = amazonSNSClient->listPlatformApplications();
    string[] arns = check from PlatformApplication platformApplication in platformApplications
                    select platformApplication.platformApplicationArn;

    test:assertTrue(arns.length() > 100, "There should be over 100 platform applications.");

    // Ensure there are no duplicates
    foreach string platformApplicationArn in arns {
        test:assertEquals(arns.indexOf(platformApplicationArn), arns.lastIndexOf(platformApplicationArn),
            "Platform application " + platformApplicationArn + " duplicated in the list.");
    }
}

@test:Config {
    groups: ["platformApplication"]
}
function getPlatformApplicationTest() returns error? {
    string topicArn = check amazonSNSClient->createTopic(testRunId + "GetPlatformApplicationsTopic");
    PlatformApplicationAttributes attributes = {
        eventEndpointCreated: topicArn,
        eventDeliveryFailure: topicArn,
        eventEndpointDeleted: topicArn,
        eventEndpointUpdated: topicArn,
        successFeedbackRoleArn: testIamRole,
        failureFeedbackRoleArn: testIamRole,
        successFeedbackSampleRate: 5
    };
    string arn = check amazonSNSClient->createPlatformApplication(testRunId + "GetPlatformApplication",
        AMAZON_DEVICE_MESSAGING, auth = {platformCredential: amazonClientSecret, platformPrincipal: amazonClientId},
        attributes = attributes);

    RetrievablePlatformApplicationAttributes retrieved = check amazonSNSClient->getPlatformApplicationAttributes(arn);
    test:assertEquals(retrieved.eventEndpointCreated, topicArn);
    test:assertEquals(retrieved.eventDeliveryFailure, topicArn);
    test:assertEquals(retrieved.eventEndpointDeleted, topicArn);
    test:assertEquals(retrieved.eventEndpointUpdated, topicArn);
    test:assertEquals(retrieved.successFeedbackRoleArn, testIamRole);
    test:assertEquals(retrieved.failureFeedbackRoleArn, testIamRole);
    test:assertEquals(retrieved.successFeedbackSampleRate, 5);
    test:assertEquals(retrieved.enabled, true);
}

@test:Config {
    groups: ["platformApplication"]
}
function getPlatformApplicationDoesNotExistTest() returns error? {
    string arn = check amazonSNSClient->createPlatformApplication(testRunId + "GetPlatformApplicationDNE",
        AMAZON_DEVICE_MESSAGING, auth = {platformCredential: amazonClientSecret, platformPrincipal: amazonClientId});

    RetrievablePlatformApplicationAttributes|Error retrieved = amazonSNSClient->getPlatformApplicationAttributes(arn + "invalid");
    test:assertTrue(retrieved is OperationError);
    test:assertEquals((<OperationError>retrieved).message(), "PlatformApplication does not exist");
}

@test:Config {
    groups: ["platformApplication"]
}
function setPlatformApplicationAttributesTest() returns error? {
    string topicArn = check amazonSNSClient->createTopic(testRunId + "SetPlatformApplicationsAttrTopic");
    string arn = check amazonSNSClient->createPlatformApplication(testRunId + "SetPlatformApplicationAttr",
        AMAZON_DEVICE_MESSAGING, auth = {platformCredential: amazonClientSecret, platformPrincipal: amazonClientId});

    PlatformApplicationAttributes attributes = {
        eventEndpointCreated: topicArn,
        eventDeliveryFailure: topicArn,
        eventEndpointDeleted: topicArn,
        eventEndpointUpdated: topicArn,
        successFeedbackRoleArn: testIamRole,
        failureFeedbackRoleArn: testIamRole,
        successFeedbackSampleRate: 5
    };
    _ = check amazonSNSClient->setPlatformApplicationAttributes(arn, attributes);

    RetrievablePlatformApplicationAttributes retrieved = check amazonSNSClient->getPlatformApplicationAttributes(arn);
    io:println(retrieved);
    test:assertEquals(retrieved.eventEndpointCreated, topicArn);
    test:assertEquals(retrieved.eventDeliveryFailure, topicArn);
    test:assertEquals(retrieved.eventEndpointDeleted, topicArn);
    test:assertEquals(retrieved.eventEndpointUpdated, topicArn);
    test:assertEquals(retrieved.successFeedbackRoleArn, testIamRole);
    test:assertEquals(retrieved.failureFeedbackRoleArn, testIamRole);
    test:assertEquals(retrieved.successFeedbackSampleRate, 5);
    test:assertEquals(retrieved.enabled, true);
};

@test:Config {
    groups: ["platformApplication"]
}
function setPlatformApplicationAttributesNegativeTest() returns error? {
    string arn = check amazonSNSClient->createPlatformApplication(testRunId + "SetPlatformApplicationNegAttr",
        AMAZON_DEVICE_MESSAGING, auth = {platformCredential: amazonClientSecret, platformPrincipal: amazonClientId});

    string topicArn = check amazonSNSClient->createTopic(testRunId + "SetPlatformApplicationsAttrNegTopic");
    PlatformApplicationAttributes attributes = {
        eventEndpointCreated: topicArn,
        eventDeliveryFailure: topicArn,
        eventEndpointDeleted: topicArn,
        eventEndpointUpdated: topicArn,
        successFeedbackRoleArn: testIamRole,
        failureFeedbackRoleArn: testIamRole,
        successFeedbackSampleRate: 101
    };
    Error? e = amazonSNSClient->setPlatformApplicationAttributes(arn, attributes);
    test:assertTrue(e is OperationError);
    test:assertEquals((<OperationError>e).message(), "Invalid parameter: Attributes Reason: Invalid value for attribute: SuccessFeedbackSampleRate: 101 value provided is not an integer between 0-100");
};

@test:Config {
    groups: ["platformApplication"]
}
function deletePlatformApplicationTest() returns error? {
    string topicArn = check amazonSNSClient->createTopic(testRunId + "SetPlatformApplicationsAttrTopic");
    PlatformApplicationAttributes attributes = {
        eventEndpointCreated: topicArn,
        eventDeliveryFailure: topicArn,
        eventEndpointDeleted: topicArn,
        eventEndpointUpdated: topicArn,
        successFeedbackRoleArn: testIamRole,
        failureFeedbackRoleArn: testIamRole,
        successFeedbackSampleRate: 5
    };

    string arn = check amazonSNSClient->createPlatformApplication(testRunId + "DeletePlatformApplication",
        AMAZON_DEVICE_MESSAGING, auth = {platformCredential: amazonClientSecret, platformPrincipal: amazonClientId}, 
        attributes = attributes);

    _ = check amazonSNSClient->deletePlatformApplication(arn);
    _ = runtime:sleep(10);

    RetrievablePlatformApplicationAttributes|Error retrieved = amazonSNSClient->getPlatformApplicationAttributes(arn);
    test:assertTrue(retrieved is OperationError);
    test:assertEquals((<OperationError>retrieved).message(), "PlatformApplication does not exist");
}
