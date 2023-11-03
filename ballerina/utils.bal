// Copyright (c) 2021 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
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
import ballerina/jballerina.java;
import ballerina/http;
import ballerina/lang.'int as langint;
import ballerina/lang.'boolean as langboolean;

isolated function sendRequest(http:Client amazonSNSClient, http:Request request) 
    returns json|Error {
    do {
        http:Response httpResponse = check amazonSNSClient->post("/", request);
        return handleResponse(httpResponse);
    } on fail error e {
        return error Error(ERROR_OCCURRED_WHILE_INVOKING_REST_API_MSG, e);
    }
}

isolated function handleResponse(http:Response httpResponse) returns json|Error {
    if httpResponse.statusCode == http:STATUS_NO_CONTENT {
        return error ResponseHandleFailedError(NO_CONTENT_SET_WITH_RESPONSE_MSG);
    }

    json|http:ClientError response = httpResponse.getJsonPayload();
    if response is http:ClientError {
        return error ResponseHandleFailedError(response.toString());
    }

    if httpResponse.statusCode == http:STATUS_OK {
        return response;
    }

    do {
        return error OperationError(check response.Error.Message);
    } on fail {
        // Unreachable code - not testable
        return error InternalError(response.toString());
    }
}

isolated function initiateRequest(string actionName) returns map<string> {
    map<string> parameterMap = {};
    parameterMap[ACTION] = actionName;
    parameterMap[VERSION] = VERSION_NUMBER;
    return parameterMap;
}

isolated function validateCredentails(string accessKeyId, string secretAccessKey) returns error? {    
    if ((accessKeyId == EMPTY_STRING) && (secretAccessKey == EMPTY_STRING)) {
        return error("Access Key Id and Secret Access Key credential is empty");
    }

    if (accessKeyId == EMPTY_STRING) {
        return error("Access Key Id credential is empty");
    }

    if (secretAccessKey == EMPTY_STRING) {
        return error("Secret Access Key credential is empty");
    }
}

isolated function utcToString(time:Utc utc, string pattern) returns string|error {
    [int, decimal] [epochSeconds, lastSecondFraction] = utc;
    int nanoAdjustments = (<int>lastSecondFraction * 1000000000);
    var instant = ofEpochSecond(epochSeconds, nanoAdjustments);
    var zoneId = getZoneId(java:fromString("Z"));
    var zonedDateTime = atZone(instant, zoneId);
    var dateTimeFormatter = ofPattern(java:fromString(pattern));
    handle formatString = format(zonedDateTime, dateTimeFormatter);
    return formatString.toBalString();
}

isolated function uppercaseFirstLetter(string str) returns string {
    string firstLetter = str.substring(0, 1);
    string remainingLetters = str.substring(1);
    return firstLetter.toUpperAscii() + remainingLetters;
}

isolated function lowercaseFirstLetter(string str) returns string {
    string firstLetter = str.substring(0, 1);
    string remainingLetters = str.substring(1);
    return firstLetter.toLowerAscii() + remainingLetters;
}

isolated function stringToInt(string str) returns int|error {
    return check langint:fromString(str.toString());
}

isolated function stringToBoolean(string str) returns boolean|error {
    return check langboolean:fromString(str.toString());
}

isolated function stringToTimestamp(string str) returns time:Civil|error {
    time:Utc utc = [check stringToInt(str), 0];
    return time:utcToCivil(utc);
}
