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
    groups: ["endpoint"]
}
function createEndpointTest() returns error? {
    string arn = check amazonSNSClient->createEndpoint(applicationArn, testRunId + "testDeviceToken");
    test:assertTrue(isArn(arn));
}

@test:Config {
    groups: ["endpoint"]
}
function createEndpointWithEmptyTokenTest() returns error? {
    string|Error arn = amazonSNSClient->createEndpoint(applicationArn, "");
    test:assertTrue(arn is OperationError);
    test:assertEquals((<OperationError>arn).message(), "Invalid parameter: Token Reason: cannot be empty");
}

@test:Config {
    groups: ["endpoint"]
}
function createEndpointWithInvalidArnTest() returns error? {
    string|Error arn = amazonSNSClient->createEndpoint(invalidApplicationArn, testRunId + "testDeviceToken2");
    test:assertTrue(arn is OperationError);
    test:assertEquals((<OperationError>arn).message(), "Invalid parameter: PlatformApplicationArn Reason: Wrong number of slashes in relative portion of the ARN.");
}

@test:Config {
    groups: ["endpoint"]
}
function createEndpointWithCustomUserDataTest() returns error? {
    string arn = check amazonSNSClient->createEndpoint(applicationArn, testRunId + "testDeviceToken3",
        customUserData = "testCustomUserData");
    test:assertTrue(isArn(arn));
}

@test:Config {
    groups: ["endpoint"]
}
function createEndpointWithAttributes() returns error? {
    EndpointAttributes attributes = {enabled: true, token: testRunId + "testToken4", customUserData: "testCustomUserData2"};
    string arn = check amazonSNSClient->createEndpoint(applicationArn, testRunId + "testDeviceToken4", attributes);
    test:assertTrue(isArn(arn));
}

@test:Config {
    groups: ["endpoint"]
}
function createEndpointWithInvalidAttributes() returns error? {
    EndpointAttributes attributes = {enabled: true, token: "", customUserData: "testCustomUserData2"};
    string|Error arn = amazonSNSClient->createEndpoint(applicationArn, testRunId + "testDeviceToken5", attributes);
    test:assertTrue(arn is OperationError);
    test:assertEquals((<OperationError>arn).message(), "Invalid parameter: Attributes Reason: Invalid value for attribute: Token: cannot be empty");
}

@test:Config {
    groups: ["endpoint"]
}
function listPlatformApplicationEndpointsTest() returns error? {
    EndpointAttributes attributes = {enabled: false};
    string arn = check amazonSNSClient->createEndpoint(applicationArn, testRunId + "testDeviceTokenNew", attributes,
        "CustomDataNew");

    stream<Endpoint, Error?> endpointStream = 
        amazonSNSClient->listEndpoints(applicationArn);
    Endpoint[] endpoints = check from Endpoint endpoint in endpointStream
                                                    select endpoint;

    test:assertTrue(endpoints.length() > 100, "Over 100 endpoints should be listed");

    Endpoint[] findEndpoint = from Endpoint endpoint in endpoints
                                                 where arn == endpoint.endpointArn
                                                 select endpoint;
    test:assertTrue(findEndpoint.length() == 1, "Newly created endpoint not found");
    test:assertEquals(findEndpoint[0].token, testRunId + "testDeviceTokenNew");
    test:assertEquals(findEndpoint[0].customUserData, "CustomDataNew");
    test:assertEquals(findEndpoint[0].enabled, false);
}

@test:Config {
    groups: ["endpoint"]
}
function getEndpointAttributesTest() returns error? {
    EndpointAttributes attributes = {enabled: false};
    string arn = check amazonSNSClient->createEndpoint(applicationArn, testRunId + "testDeviceToken7", attributes,
        "CustomData7");

    EndpointAttributes retrievedAttributes = check amazonSNSClient->getEndpointAttributes(arn);
    test:assertEquals(retrievedAttributes.token, testRunId + "testDeviceToken7");
    test:assertEquals(retrievedAttributes.customUserData, "CustomData7");
    test:assertEquals(retrievedAttributes.enabled, false);
}

@test:Config {
    groups: ["endpoint"]
}
function getEndpointAttributesWithInvalidArnTest() returns error? {
    EndpointAttributes attributes = {enabled: false};
    string arn = check amazonSNSClient->createEndpoint(applicationArn, testRunId + "testDeviceToken7", attributes,
        "CustomData7");

    EndpointAttributes|Error retrievedAttributes = amazonSNSClient->getEndpointAttributes(arn + "invalid");
    test:assertTrue(retrievedAttributes is OperationError);
    test:assertEquals((<OperationError>retrievedAttributes).message(), "Invalid parameter: EndpointArn Reason: ARN specifies an invalid endpointId: UUID must be encoded in exactly 36 characters.");
}

@test:Config {
    groups: ["endpoint"]
}
function setEndpointAttributesTest() returns error? {
    string arn = check amazonSNSClient->createEndpoint(applicationArn, testRunId + "testDeviceToken8");
    _ = check amazonSNSClient->setEndpointAttributes(arn, {
            enabled: false, token: testRunId + "testDeviceToken9", customUserData: "CustomData9"
    });

    EndpointAttributes retrievedAttributes = check amazonSNSClient->getEndpointAttributes(arn);
    test:assertEquals(retrievedAttributes.token, testRunId + "testDeviceToken9");
    test:assertEquals(retrievedAttributes.customUserData, "CustomData9");
    test:assertEquals(retrievedAttributes.enabled, false);
}

@test:Config {
    groups: ["endpoint"]
}
function setEndpointAttributesWithInvalidArnTest() returns error? {
    string arn = check amazonSNSClient->createEndpoint(applicationArn, testRunId + "testDeviceToken10");
    Error? e = amazonSNSClient->setEndpointAttributes(arn + "invalid", {
        enabled: false,
        token: testRunId + "testDeviceToken10",
        customUserData: "CustomData10"
    });

    test:assertTrue(e is OperationError);
    test:assertEquals((<OperationError>e).message(), "Invalid parameter: EndpointArn Reason: ARN specifies an invalid endpointId: UUID must be encoded in exactly 36 characters.");
}

@test:Config {
    groups: ["endpoin"]
}
function deleteEndpointTest() returns error? {
    string arn = check amazonSNSClient->createEndpoint(applicationArn, testRunId + "testDeviceToken11");
    _ = check amazonSNSClient->deleteEndpoint(arn);
    
    EndpointAttributes|Error attributes = amazonSNSClient->getEndpointAttributes(arn);
    test:assertTrue(attributes is OperationError);
    test:assertEquals((<OperationError>attributes).message(), "Endpoint does not exist");
}

@test:Config {
    groups: ["endpoint"]
}
function deleteEndpointWithInvalidTest() returns error? {
    string arn = check amazonSNSClient->createEndpoint(applicationArn, testRunId + "testDeviceToken11");
    Error? e = amazonSNSClient->deleteEndpoint(arn + "invalid");

    test:assertTrue(e is OperationError);
    test:assertEquals((<OperationError>e).message(), "Invalid parameter: EndpointArn Reason: ARN specifies an invalid endpointId: UUID must be encoded in exactly 36 characters.");
}
