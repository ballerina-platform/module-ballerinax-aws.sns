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
import ballerina/random;

int random = check random:createIntInRange(1, 100000);

@test:Config {
    groups: ["sms-sandbox"],
    enable: false
}
function createSMSSandboxPhoneNumberTest1() returns error? {
    check amazonSNSClient->createSMSSandboxPhoneNumber("+947719" + random.toString());
}

@test:Config {
    groups: ["sms-sandbox"],
    enable: false
}
function createSMSSandboxPhoneNumberTest2() returns error? {
    check amazonSNSClient->createSMSSandboxPhoneNumber("+9411223344667788990");
    check amazonSNSClient->deleteSMSSandboxPhoneNumber("+9411223344667788990");
}

@test:Config {
    groups: ["sms-sandbox"],
    enable: false
}
function createSMSSandboxPhoneNumberTest3() returns error? {
    check amazonSNSClient->createSMSSandboxPhoneNumber("123456789");
    check amazonSNSClient->deleteSMSSandboxPhoneNumber("123456789");

}

@test:Config {
    groups: ["sms-sandbox"],
    enable: false
}
function creatSMSSandboxPhoneNumberInvalidTest1() returns error? {
    Error? e = amazonSNSClient->createSMSSandboxPhoneNumber("invalid phone number");
    test:assertTrue(e is OperationError);
    test:assertEquals((<OperationError>e).message(), "1 validation error detected: Value 'invalid phone number' at 'phoneNumber' failed to satisfy constraint: Member must satisfy regular expression pattern: ^(\\+[0-9]{8,}|[0-9]{0,9})$");
}

@test:Config {
    groups: ["sms-sandbox"]
}
function creatSMSSandboxPhoneNumberInvalidTest2() returns error? {
    Error? e = amazonSNSClient->createSMSSandboxPhoneNumber("1234567890");
    test:assertTrue(e is OperationError);
    test:assertEquals((<OperationError>e).message(), "1 validation error detected: Value '1234567890' at 'phoneNumber' failed to satisfy constraint: Member must satisfy regular expression pattern: ^(\\+[0-9]{8,}|[0-9]{0,9})$");
}

@test:Config {
    groups: ["sms-sandbox"]
}
function creatSMSSandboxPhoneNumberInvalidTest3() returns error? {
    Error? e = amazonSNSClient->createSMSSandboxPhoneNumber("+94489347594376598435346594365943695348562987");
    test:assertTrue(e is OperationError);
    test:assertEquals((<OperationError>e).message(), "1 validation error detected: Value '+94489347594376598435346594365943695348562987' at 'phoneNumber' failed to satisfy constraint: Member must have length less than or equal to 20");
}

@test:Config {
    groups: ["sms-sandbox"],
    enable: false
}
function createSMSSandboxPhoneNumberWithLanugageCodeTest() returns error? {
    check amazonSNSClient->createSMSSandboxPhoneNumber("+9477123456701", EN_US);
    runtime:sleep(2);
    check amazonSNSClient->deleteSMSSandboxPhoneNumber("+941234401");

    check amazonSNSClient->createSMSSandboxPhoneNumber("+9412344502", EN_GB);
    runtime:sleep(2);
    check amazonSNSClient->deleteSMSSandboxPhoneNumber("+9412344502");

    check amazonSNSClient->createSMSSandboxPhoneNumber("+9412344503", ES_419);
    runtime:sleep(2);
    check amazonSNSClient->deleteSMSSandboxPhoneNumber("+9412345678903");

    check amazonSNSClient->createSMSSandboxPhoneNumber("+9412345678904", ES_ES);
    runtime:sleep(2);
    check amazonSNSClient->deleteSMSSandboxPhoneNumber("+9412345678904");

    check amazonSNSClient->createSMSSandboxPhoneNumber("+9412345678905", DE_DE);
    runtime:sleep(2);
    check amazonSNSClient->deleteSMSSandboxPhoneNumber("+9412345678905");

    check amazonSNSClient->createSMSSandboxPhoneNumber("+9412345678906", FR_FR);
    runtime:sleep(2);
    check amazonSNSClient->deleteSMSSandboxPhoneNumber("+9412345678906");

    check amazonSNSClient->createSMSSandboxPhoneNumber("+9412345678907", FR_CA);
    runtime:sleep(2);
    check amazonSNSClient->deleteSMSSandboxPhoneNumber("+9412345678907");

    check amazonSNSClient->createSMSSandboxPhoneNumber("+9412345678908", IT_IT);
    runtime:sleep(2);
    check amazonSNSClient->deleteSMSSandboxPhoneNumber("+9412345678908");

    check amazonSNSClient->createSMSSandboxPhoneNumber("+9412345678909", JA_JP);
    runtime:sleep(2);
    check amazonSNSClient->deleteSMSSandboxPhoneNumber("+9412345678909");

    check amazonSNSClient->createSMSSandboxPhoneNumber("+9412345678910", PT_BR);
    runtime:sleep(2);
    check amazonSNSClient->deleteSMSSandboxPhoneNumber("+9412345678910");

    check amazonSNSClient->createSMSSandboxPhoneNumber("+9412345678911", KR_KR);
    runtime:sleep(2);
    check amazonSNSClient->deleteSMSSandboxPhoneNumber("+9412345678911");

    check amazonSNSClient->createSMSSandboxPhoneNumber("+9412345678912", ZH_CN);
    runtime:sleep(2);
    check amazonSNSClient->deleteSMSSandboxPhoneNumber("+9412345678912");

    check amazonSNSClient->createSMSSandboxPhoneNumber("+9412345678913", ZH_TW);
    runtime:sleep(2);
    check amazonSNSClient->deleteSMSSandboxPhoneNumber("+9412345678913");
}

@test:Config {
    groups: ["sms-sandbox"]
}
function listSMSSandboxPhoneNumbersTest() returns error? {
    stream<SMSSandboxPhoneNumber, Error?> phoneNumberStream = amazonSNSClient->listSMSSandboxPhoneNumbers();
    SMSSandboxPhoneNumber[] phoneNumbers = check from SMSSandboxPhoneNumber phoneNumber in phoneNumberStream
        select phoneNumber;

    test:assertEquals(phoneNumbers.length(), 10);
    _ = from SMSSandboxPhoneNumber phoneNumber in phoneNumbers
        do {
            test:assertTrue(phoneNumber.phoneNumber.startsWith("+947719"));
            test:assertTrue(phoneNumber.status == PENDING || phoneNumber.status == VERIFIED);
        };
}

@test:Config {
    groups: ["sms-sandboxx"]
}
function getSMSSandboxAccountStatusTest() returns error? {
    boolean status = check amazonSNSClient->getSMSSandboxAccountStatus();
    test:assertTrue(status);
}
