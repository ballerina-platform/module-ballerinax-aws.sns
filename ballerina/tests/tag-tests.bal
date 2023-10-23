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
    groups: ["tag"]
}
function tagResourceInlineTest() returns error? {
    string topic = check amazonSNSClient->createTopic(testRunId + "testTagsTopic");
    check amazonSNSClient->tagResource(topic, testKey = "testValue", hello = "world");
}

@test:Config {
    groups: ["tagx"]
}
function tagResourceRecordTest() returns error? {
    Tags tags = {
        "testKey": "testValue",
        "hello": "world"
    };

    string topic = check amazonSNSClient->createTopic(testRunId + "testTagsTopic2");
    check amazonSNSClient->tagResource(topic, tags);
}

@test:Config {
    groups: ["tag"]
}
function tagResourceEmptyTest1() returns error? {
    string topic = check amazonSNSClient->createTopic(testRunId + "testTagsTopic3");
    Error? e = amazonSNSClient->tagResource(topic, {});
    test:assertTrue(e is Error, "Error expected.");
    test:assertEquals((<Error>e).message(), "At least one tag must be specified.");
}

@test:Config {
    groups: ["tag"]
}
function tagResourceEmptyTest() returns error? {
    string topic = check amazonSNSClient->createTopic(testRunId + "testTagsTopic4");
    Error? e = amazonSNSClient->tagResource(topic);
    test:assertTrue(e is Error, "Error expected.");
    test:assertEquals((<Error>e).message(), "At least one tag must be specified.");
}

@test:Config {
    groups: ["tagx"]
}
function tagResourceTooLongTest() returns error? {
    string topic = check amazonSNSClient->createTopic(testRunId + "testTagsTopic5");
    Error? e = amazonSNSClient->tagResource(topic, tag1hkfhksdhfkjhdsfkhskfhdskjfbdskjfhsdkfhsdkfhdsjkhfkjdshfkdshfkjdshfksdhkfshdkfhdskjfhsdkfhsdkjfhdkjsfhskdjhfkjsdhfkjdshfkjsdhfkjsdhfkjhsdkfjhsdkjfsdkjhfkj = "testTag");
    test:assertTrue(e is Error, "Error expected.");
    test:assertTrue((<Error>e).message().endsWith("Member must have length less than or equal to 128"));
}

@test:Config {
    groups: ["tagx"]
}
function tagResourceTooManyTest() returns error? {
    Tags tags = {"tag1": "value1", "tag2": "value2", "tag3": "value3", "tag4": "value4", "tag5": "value5", "tag6": "value6", "tag7": "value7", "tag8": "value8", "tag9": "value9", "tag10": "value10", "tag11": "value11", "tag12": "value12", "tag13": "value13", "tag14": "value14", "tag15": "value15", "tag16": "value16", "tag17": "value17", "tag18": "value18", "tag19": "value19", "tag20": "value20", "tag21": "value21", "tag22": "value22", "tag23": "value23", "tag24": "value24", "tag25": "value25", "tag26": "value26", "tag27": "value27", "tag28": "value28", "tag29": "value29", "tag30": "value30", "tag31": "value31", "tag32": "value32", "tag33": "value33", "tag34": "value34", "tag35": "value35", "tag36": "value36", "tag37": "value37", "tag38": "value38", "tag39": "value39", "tag40": "value40", "tag41": "value41", "tag42": "value42", "tag43": "value43", "tag44": "value44", "tag45": "value45", "tag46": "value46", "tag47": "value47", "tag48": "value48", "tag49": "value49", "tag50": "value50", "tag51": "value51"};
    string topic = check amazonSNSClient->createTopic(testRunId + "testTagsTopic6");
    Error? e = amazonSNSClient->tagResource(topic, tags);
    test:assertTrue(e is Error, "Error expected.");
    test:assertEquals((<Error>e).message(), "Could not complete request: tag quota of per resource exceeded");
}

