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
import ballerina/lang.runtime;

// We need to wait 2s between each request because SMSAttributes APIs are throttled at 1 per second

@test:Config {
    groups: ["sms-attributes"]
}
function setSMSAttributesTest() returns error? {
    runtime:sleep(2);
    check amazonSNSClient->setSMSAttributes({
        monthlySpendLimit: 1,
        deliveryStatusIAMRole: testIamRole,
        deliveryStatusSuccessSamplingRate: 5,
        defaultSenderID: "test",
        defaultSMSType: TRANSACTIONAL
    });
}

@test:Config {
    groups: ["sms-attributes"],
    dependsOn: [setSMSAttributesTest]
}
function setSMSAttributesWithInvalidSenderIDTest() returns error? {
    runtime:sleep(2);
    Error? e = amazonSNSClient->setSMSAttributes({
        monthlySpendLimit: 1,
        deliveryStatusIAMRole: testIamRole,
        deliveryStatusSuccessSamplingRate: 5,
        defaultSenderID: "testSenderID", // too long
        defaultSMSType: TRANSACTIONAL
    });
    test:assertTrue(e is OperationError, "OperationError expected.");
    test:assertEquals((<OperationError>e).message(), "DefaultSenderID is invalid");
}

@test:Config {
    groups: ["sms-attributes"],
    dependsOn: [setSMSAttributesWithInvalidSenderIDTest]
}
function setSMSAttributesWithInvalidS3BucketTest() returns error? {
    runtime:sleep(2);
    Error? e = amazonSNSClient->setSMSAttributes({
        monthlySpendLimit: 1,
        deliveryStatusIAMRole: testIamRole,
        deliveryStatusSuccessSamplingRate: 5,
        defaultSenderID: "test",
        defaultSMSType: TRANSACTIONAL,
        usageReportS3Bucket: "thisS3BucketDoesNotExist"
    });
    test:assertTrue(e is OperationError, "OperationError expected.");
    test:assertEquals((<OperationError>e).message(), "Invalid parameter: UsageReportS3Bucket Reason: The bucket you provided does not exist");
}

@test:Config {
    groups: ["sms-attributes"],
    dependsOn: [setSMSAttributesWithInvalidS3BucketTest]
}
function setSMSAttributesWithInvalidSampleRateTest() returns error? {
    runtime:sleep(2);
    Error? e = amazonSNSClient->setSMSAttributes({
        monthlySpendLimit: 1,
        deliveryStatusIAMRole: testIamRole,
        deliveryStatusSuccessSamplingRate: 101, // max value is 100
        defaultSenderID: "test",
        defaultSMSType: TRANSACTIONAL
    });
    test:assertTrue(e is OperationError, "OperationError expected.");
    test:assertEquals((<OperationError>e).message(), "DeliveryStatusSuccessSamplingRate is not an integer between 0-100");
}

@test:Config {
    groups: ["sms-attributes"],
    dependsOn: [setSMSAttributesWithInvalidSampleRateTest]
}
function getSMSAttributesTest() returns error? {
    runtime:sleep(2);
    check amazonSNSClient->setSMSAttributes({
        monthlySpendLimit: 1,
        deliveryStatusIAMRole: testIamRole,
        deliveryStatusSuccessSamplingRate: 50,
        defaultSenderID: "test2",
        defaultSMSType: PROMOTIONAL
    });

    SMSAttributes attributes = check amazonSNSClient->getSMSAttributes();
    test:assertEquals(attributes.monthlySpendLimit, 1);
    test:assertEquals(attributes.deliveryStatusIAMRole, testIamRole);
    test:assertEquals(attributes.deliveryStatusSuccessSamplingRate, 50);
    test:assertEquals(attributes.defaultSenderID, "test2");
    test:assertEquals(attributes.defaultSMSType, PROMOTIONAL);
}
