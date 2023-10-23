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

import ballerina/io;
import ballerina/test;

@test:Config {
    groups: ["phone-number"]
}
function listOrignationPhoneNumbersTest() returns error? {
    stream<OriginationPhoneNumber, Error?> phoneNumberStream = amazonSNSClient->listOriginationNumbers();
    OriginationPhoneNumber[] phoneNumbers = check from OriginationPhoneNumber phoneNumber in phoneNumberStream 
                                                  select phoneNumber;
    io:println(phoneNumbers);
    test:assertEquals(phoneNumbers.length(), 1, "Invalid number of origination phone numbers");
}

@test:Config {
    groups: ["phone-number"]
}
function listOptedOutPhoneNumbersTest() returns error? {
    stream<string, Error?> phoneNumberStream = amazonSNSClient->listPhoneNumbersOptedOut();
    string[] phoneNumbers = check from string phoneNumber in phoneNumberStream
        select phoneNumber;
    io:println(phoneNumbers);
    test:assertEquals(phoneNumbers.length(), 0, "Invalid number of opted out phone numbers");
}

@test:Config {
    groups: ["phone-number"]
}
function checkIfPhoneNumberisOptedOutTest() returns error? {
    _ = check amazonSNSClient->checkIfPhoneNumberIsOptedOut(testPhoneNumber);
}

@test:Config {
    groups: ["phone-number"]
}
function checkIfPhoneNumberisOptedOutWithInvalidTest() returns error? {
    boolean|Error optedOut = amazonSNSClient->checkIfPhoneNumberIsOptedOut(testPhoneNumber + "x");
    test:assertTrue(optedOut is OperationError, "Operation Error expected");
    test:assertEquals((<OperationError>optedOut).message(), "Invalid parameter: PhoneNumber Reason: input incorrectly formatted");
}

@test:Config {
    groups: ["phone-number"]
}
function optInPhoneNumberTest() returns error? {
    check amazonSNSClient->optInPhoneNumber(testPhoneNumber);
}

@test:Config {
    groups: ["phone-number"]
}
function optInPhoneNumberInvalidTest() returns error? {
    Error? e = amazonSNSClient->optInPhoneNumber(testPhoneNumber + "x");
    test:assertTrue(e is OperationError, "Operation Error expected");
    test:assertEquals((<OperationError>e).message(), "Invalid parameter: PhoneNumber Reason: input incorrectly formatted");
}
