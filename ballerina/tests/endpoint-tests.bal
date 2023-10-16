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
