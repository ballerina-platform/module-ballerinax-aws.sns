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

import ballerina/jballerina.java;
import ballerina/http;
import ballerina/time;

isolated function buildQueryString(string actionName, map<string> parameterMap, string... parameterValues) returns @tainted map<string> {
    int index = 0;
    string parameterValueString = "";
    parameterMap[ACTION] = actionName;
    parameterMap[VERSION] = VERSION_NUMBER;
    foreach string? parameterValue in parameterValues {
        parameterMap[getAttributeName(parameterValue)] = parameterValue;            
        index += 1;
    }
    return parameterMap;
}

isolated function createQueryString(string actionName, map<string> parameterMap) returns @tainted map<string> {
    int index = 0;
    string parameterValueString = "";
    parameterMap[ACTION] = actionName;
    parameterMap[VERSION] = VERSION_NUMBER;
    return parameterMap;
}

isolated function addTopicOptionalParameters(map<string> parameterMap, TopicAttributes? attributes = (), map<string>? tags = ()) returns @tainted map<string>|error {
    map<string> parameters = {};
    if (attributes is TopicAttributes) {
        parameters = setTopicAttributes(parameterMap, attributes);
    }
    if (tags is map<string>) {
        parameters = setTags(parameterMap, tags);
    }
    return parameterMap;
}

isolated function addSubscriptionOptionalParameters(map<string> parameterMap, string? endpoint = (), boolean? returnSubscriptionArn = (), SubscriptionAttribute? attributes = ()) returns @tainted map<string>|error {
    map<string> parameters = {};
    if (endpoint is string) {
        parameterMap["Endpoint"] = endpoint.toString();
    }
    if (returnSubscriptionArn is boolean) {
        parameterMap["ReturnSubscriptionArn"] = returnSubscriptionArn.toString();
    }
    if (attributes is SubscriptionAttribute) {
        parameters = setSubscriptionAttributes(parameterMap, attributes);
    }
    return parameterMap;
}

isolated function addPublishOptionalParameters(map<string> parameterMap, string? topicArn = (), string? targetArn = (), string? subject = (), string? phoneNumber = (), string? messageStructure = (), string? messageDeduplicationId = (), string? messageGroupId = (), MessageAttribute? messageAttributes = ()) returns @tainted map<string>|error {
    map<string> parameters = {};
    if (topicArn is string) {
        parameterMap["TopicArn"] = topicArn.toString();
    }
    if (targetArn is string) {
        parameterMap["TargetArn"] = targetArn.toString();
    }
    if (subject is string) {
        parameterMap["Subject"] = subject.toString();
    }
    if (phoneNumber is string) {
        parameterMap["PhoneNumber"] = phoneNumber.toString();
    }
    if (messageStructure is string) {
        parameterMap["MessageStructure"] = messageStructure.toString();
    }
    if (messageDeduplicationId is string) {
        parameterMap["MessageDeduplicationId"] = messageDeduplicationId.toString();
    }
    if (messageGroupId is string) {
        parameterMap["MessageGroupId"] = messageGroupId.toString();
    }
    if (messageAttributes is MessageAttribute) {
        parameters = setMessageAttributes(parameterMap, messageAttributes);
    }
    return parameterMap;
}

isolated function addCreateSandboxOptionalParameters(map<string> parameterMap, string? languageCode = ()) returns @tainted map<string>|error {
    if (languageCode is string) {
        parameterMap["LanguageCode"] = languageCode.toString();
    }
    return parameterMap;
}

isolated function addOptionalStringParameters(map<string> parameterMap, string?... optionalParameterValues) returns @tainted map<string>|error {
    int index = 0;
    string parameterValueString = "";
    foreach string? optionalParameterValue in optionalParameterValues {
        if(optionalParameterValue is string) {
            parameterMap[getAttributeName(optionalParameterValue)] = optionalParameterValue;            
        }
        index += 1;
    }
    return parameterMap;
}

isolated function sendRequest(http:Client amazonSNSClient, http:Request|error request) returns @tainted xml|error {
    if (request is http:Request) {
        http:Response|error httpResponse = amazonSNSClient->post("/", request);
        xml|error response = handleResponse(httpResponse);
        if (response is xml) {
            return response;
        } else {
            return response;
        }
    } else {
        return error(REQUEST_ERROR);
    }
}

isolated function checkCredentials(string accessKeyId, string secretAccessKey) returns error? {
    if ((accessKeyId == "") || (secretAccessKey == "")) {
        return error("Access Key Id or Secret Access Key credential are empty");
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

# Handles the HTTP response.
#
# + httpResponse - Http response or error
# + return - If successful returns `xml` response. Else returns error
isolated function handleResponse(http:Response|http:PayloadType|error httpResponse) returns @untainted xml|error {
    if (httpResponse is http:Response) {
        if (httpResponse.statusCode == http:STATUS_NO_CONTENT) {
            return error ResponseHandleFailed(NO_CONTENT_SET_WITH_RESPONSE_MSG);
        }
        var xmlResponse = httpResponse.getXmlPayload();
        if (xmlResponse is xml) {
            if (httpResponse.statusCode == http:STATUS_OK) {
                return xmlResponse;
            } else {
                xmlns "http://sns.amazonaws.com/doc/2010-03-31/" as ns;
                string xmlResponseErrorCode = httpResponse.statusCode.toString();
                string responseErrorMessage = (xmlResponse/<ns:'error>/<ns:message>/*).toString();
                string errorMsg = "status code" + ":" + xmlResponseErrorCode + 
                    ";" + " " + "message" + ":" + " " + 
                    responseErrorMessage;
                return error(errorMsg);
            }
        } else {
            return error(RESPONSE_PAYLOAD_IS_NOT_XML_MSG);
        }
    } else if (httpResponse is http:PayloadType) {
        return error(UNREACHABLE_STATE);
    } else {
        return error(ERROR_OCCURRED_WHILE_INVOKING_REST_API_MSG, httpResponse);
    }
}

# Set topic attributes to a map of string to add as query parameters.
#
# + parameters - Parameter map
# + attributes - TopicAttributes to convert to a map of string
# + return - If successful returns `map<string>` response. Else returns error
isolated function setTopicAttributes(map<string> parameters, TopicAttributes attributes) returns map<string> {
    int attributeNumber = 1;
    map<anydata> attributeMap = <map<anydata>>attributes;
    foreach var [key, value] in attributeMap.entries() {
        string attributeName = getAttributeName(key);
        parameters["Attributes.entry." + attributeNumber.toString() + ".Name"] = attributeName.toString();
        parameters["Attributes.entry." + attributeNumber.toString() + ".Value"] = value.toString();
        attributeNumber = attributeNumber + 1;
    }
    return parameters;
}

# Set tags to a map of string to add as query parameters.
#
# + parameters - Parameter map
# + tags - Tags to convert to a map of string
# + return - If successful returns `map<string>` response. Else returns error
isolated function setTags(map<string> parameters, map<string> tags) returns map<string> {
    int tagNumber = 1;
    foreach var [key, value] in tags.entries() {
        parameters["Tag." + tagNumber.toString() + ".Key"] = key;
        parameters["Tag." + tagNumber.toString() + ".Value"] = value;
        tagNumber = tagNumber + 1;
    }
    return parameters;
}

# Set subscription attributes to a map of string to add as query parameters.
#
# + parameters - Parameter map
# + attributes - SubscriptionAttribute to convert to a map of string
# + return - If successful returns `map<string>` response. Else returns error
isolated function setSubscriptionAttributes(map<string> parameters, SubscriptionAttribute attributes) returns map<string> {
    int attributeNumber = 1;
    map<anydata> attributeMap = <map<anydata>>attributes;
    foreach var [key, value] in attributeMap.entries() {
        string attributeName = getAttributeName(key);
        parameters["Attributes.entry." + attributeNumber.toString() + ".Name"] = attributeName.toString();
        parameters["Attributes.entry." + attributeNumber.toString() + ".Value"] = value.toString();
        attributeNumber = attributeNumber + 1;
    }
    return parameters;
}

# Set message attributes to a map of string to add as query parameters.
#
# + parameters - Parameter map
# + attributes - MessageAttribute to convert to a map of string
# + return - If successful returns `map<string>` response. Else returns error
isolated function setMessageAttributes(map<string> parameters, MessageAttribute attributes) returns map<string> {
    int attributeNumber = 1;
    map<anydata> attributeMap = <map<anydata>>attributes;
    foreach var [key, value] in attributeMap.entries() {
        string attributeName = getAttributeName(key);
        parameters["Attributes.entry." + attributeNumber.toString() + ".Name"] = attributeName.toString();
        parameters["Attributes.entry." + attributeNumber.toString() + ".Value"] = value.toString();
        attributeNumber = attributeNumber + 1;
    }
    return parameters;
}

# Set SMS attributes to a map of string to add as query parameters.
#
# + parameters - Parameter map
# + attributes - SmsAttribute to convert to a map of string
# + return - If successful returns `map<string>` response. Else returns error
isolated function setSmsAttributes(map<string> parameters, SmsAttribute attributes) returns map<string> {
    int attributeNumber = 1;
    map<anydata> attributeMap = <map<anydata>>attributes;
    foreach var [key, value] in attributeMap.entries() {
        string attributeName = getAttributeName(key);
        parameters["Attributes.entry." + attributeNumber.toString() + ".Name"] = attributeName.toString();
        parameters["Attributes.entry." + attributeNumber.toString() + ".Value"] = value.toString();
        attributeNumber = attributeNumber + 1;
    }
    return parameters;
}

# Add SMS attributes.
#
# + parameters - Parameter map
# + attributes - Array of attributes to convert to a map of string
# + return - If successful returns `map<string>` response. Else returns error.
isolated function addSmsAttributes(map<string> parameters, string[] attributes) returns map<string> {
    int attributeNumber = 1;
    foreach var attribute in attributes {
        parameters["attributes.member." + attributeNumber.toString()] = attribute.toString();
        attributeNumber = attributeNumber + 1;
    }
    return parameters;
}

# Get attribute name from field of record.
#
# + attribute - Field name of record
# + return - If successful returns attribute name string. Else returns error
isolated function getAttributeName(string attribute) returns string {
    string firstLetter = attribute.substring(0, 1);
    string otherLetters = attribute.substring(1);
    string upperCaseFirstLetter = firstLetter.toUpperAscii();
    string attributeName = upperCaseFirstLetter + otherLetters;
    return attributeName;
}
