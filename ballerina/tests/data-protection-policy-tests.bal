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

json updatedDataProtectionPolicy = {"Name": "UpdatedDPPName", "Description": "Protect basic types of sensitive data", "Version": "2021-06-01", "Statement": [{"Sid": "basicPII-inbound-protection", "DataDirection": "Inbound", "Principal": ["*"], "DataIdentifier": ["arn:aws:dataprotection::aws:data-identifier/Name", "arn:aws:dataprotection::aws:data-identifier/PhoneNumber-US"], "Operation": {"Deny": {}}}]};

@test:Config {
    groups: ["data-protection-policy"]
}
function putDataProtectionPolicyTest() returns error? {
    string topic = check amazonSNSClient->createTopic(testRunId + "testDPPTopic1");
    check amazonSNSClient->putDataProtectionPolicy(topic, validDataProtectionPolicy);
}

@test:Config {
    groups: ["data-protection-policy"]
}
function putDataProtectionPolicyInvalidTest() returns error? {
    string topic = check amazonSNSClient->createTopic(testRunId + "testDPPTopic2");
    Error? e = amazonSNSClient->putDataProtectionPolicy(topic, invalidDataProtectionPolicy);
    test:assertTrue(e is OperationError, "OperationError expected");
    test:assertEquals((<OperationError>e).message(), "Invalid parameter: DataProtectionPolicy Reason: Statement DataDirection must be either Inbound or Outbound");
}

@test:Config {
    groups: ["data-protection-policy"]
}
function updateDataProtectionPolicyTest() returns error? {
    string topic = check amazonSNSClient->createTopic(testRunId + "testDPPTopic3", 
        dataProtectionPolicy = validDataProtectionPolicy);
    check amazonSNSClient->putDataProtectionPolicy(topic, updatedDataProtectionPolicy);
}

@test:Config {
    groups: ["data-protection-policy"]
}
function getDataProtectionPolicyTest() returns error? {
    string topic = check amazonSNSClient->createTopic(testRunId + "testDPPTopic4",
        dataProtectionPolicy = validDataProtectionPolicy);
    json dpp = check amazonSNSClient->getDataProtectionPolicy(topic);
    test:assertEquals(dpp, validDataProtectionPolicy.toString());
}

@test:Config {
    groups: ["data-protection-policy"]
}
function getDataProtectionPolicyDoesNotExistTest() returns error? {
    string topic = check amazonSNSClient->createTopic(testRunId + "testDPPTopic5");
    json dpp = check amazonSNSClient->getDataProtectionPolicy(topic);
    test:assertEquals(dpp, "");
}
