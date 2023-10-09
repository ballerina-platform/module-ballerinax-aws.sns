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
   
json validPolicy = {"Version": "2008-10-17", "Id": "__default_policy_ID", "Statement": [{"Sid": "__default_statement_ID", "Effect": "Allow", "Principal": {"AWS": "*"}, "Action": ["SNS:Publish", "SNS:RemovePermission", "SNS:SetTopicAttributes", "SNS:DeleteTopic", "SNS:ListSubscriptionsByTopic", "SNS:GetTopicAttributes", "SNS:AddPermission", "SNS:Subscribe"], "Resource": "", "Condition": {"StringEquals": {"AWS:SourceOwner": "482724125666"}}}, {"Sid": "__console_sub_0", "Effect": "Allow", "Principal": {"AWS": "*"}, "Action": "SNS:Subscribe", "Resource": ""}]};
json invalidPolicy = {"Version": "2008-10-17", "Id": "__default_policy_ID", "Statement": [{"Sid": "__default_statement_ID", "Effect": "Allow", "Principal": {"AWS": "*"}, "Action": ["SNS:Publishx", "SNS:RemovePermission", "SNS:SetTopicAttributes", "SNS:DeleteTopic", "SNS:ListSubscriptionsByTopic", "SNS:GetTopicAttributes", "SNS:AddPermission", "SNS:Subscribe"], "Resource": "", "Condition": {"StringEquals": {"AWS:SourceOwner": "482724125666"}}}, {"Sid": "__console_sub_0", "Effect": "Allow", "Principal": {"AWS": "*"}, "Action": ["SNS:Subscribe"], "Resource": ""}]};

record {} validDeliveryPolicy = {
    "http": {
        defaultHealthyRetryPolicy: {
            minDelayTarget: 10,
            maxDelayTarget: 20,
            numRetries: 3,
            numNoDelayRetries: 1,
            numMinDelayRetries: 1,
            numMaxDelayRetries: 1,
            backoffFunction: LINEAR
        },
        disableSubscriptionOverrides: true,
        defaultRequestPolicy: {
            headerContentType: APPLICATION_JSON
        }
    }
};

record {} invalidDeliveryPolicy = {
    "http": {
        defaultHealthyRetryPolicy: {
            minDelayTarget: 10,
            maxDelayTarget: 20,
            numRetries: 300,
            numNoDelayRetries: 1,
            numMinDelayRetries: 1,
            numMaxDelayRetries: 1,
            backoffFunction: LINEAR
        },
        disableSubscriptionOverrides: true,
        defaultRequestPolicy: {
            headerContentType: APPLICATION_JSON
        }
    }
};

json validDataProtectionPolicy = {"Name": "basicPII-protection", "Description": "Protect basic types of sensitive data", "Version": "2021-06-01", "Statement": [{"Sid": "basicPII-inbound-protection", "DataDirection": "Inbound", "Principal": ["*"], "DataIdentifier": ["arn:aws:dataprotection::aws:data-identifier/Name", "arn:aws:dataprotection::aws:data-identifier/PhoneNumber-US"], "Operation": {"Deny": {}}}]};
json invalidDataProtectionPolicy = {"Name": "basicPII-protection", "Description": "Protect basic types of sensitive data", "Version": "2021-06-01", "Statement": [{"Sid": "basicPII-inbound-protection", "DataDirection": "Inbxound", "Principal": ["*"], "DataIdentifier": ["arn:aws:dataprotection::aws:data-identifier/Name", "arn:aws:dataprotection::aws:data-identifier/PhoneNumber-US"], "Operation": {"Deny": {}}}]};

@test:Config {
    groups: ["topics"]
}
function createTopicBasicTest() returns error? {
    string topicArn = check amazonSNSClient->createTopic(testRunId + "FirstTopic");
    test:assertNotEquals(topicArn, "", "Topic ARN should not be empty.");
}

@test:Config {
    groups: ["topics"]
}
function createTopicWithInvalidNameTest() returns error? {
    string|Error response = amazonSNSClient->createTopic(testRunId + "@TopicWithInvalidCharacters#");
    test:assertTrue(response is Error, "Error expected.");
    test:assertEquals((<Error>response).message(), "Invalid parameter: Topic Name");
}

@test:Config {
    groups: ["topics"]
}
function createTopicWithAttributesTest() returns error? {
    InitializableTopicAttributes attributes = {
        deliveryPolicy: validDeliveryPolicy.toJson(),
        displayName: "Test4",
        fifoTopic: true,
        signatureVersion: SignatureVersion1,
        policy: validPolicy,
        tracingConfig: ACTIVE,
        kmsMasterKeyId: "testxyz",
        contentBasedDeduplication: false,
        httpMessageDeliveryLogging: {
            successFeedbackRoleArn: "arn:aws:iam::482724125666:role/SNSSuccessFeedback",
            failureFeedbackRoleArn: "arn:aws:iam::482724125666:role/SNSFailureFeedback",
            successFeedbackSampleRate: 5
        },
        lambdaMessageDeliveryLogging: {
            successFeedbackRoleArn: "arn:aws:iam::482724125666:role/SNSSuccessFeedback",
            failureFeedbackRoleArn: "arn:aws:iam::482724125666:role/SNSFailureFeedback",
            successFeedbackSampleRate: 5
        },
        firehoseMessageDeliveryLogging: {
            successFeedbackRoleArn: "arn:aws:iam::482724125666:role/SNSSuccessFeedback",
            failureFeedbackRoleArn: "arn:aws:iam::482724125666:role/SNSFailureFeedback",
            successFeedbackSampleRate: 5
        },
        applicationMessageDeliveryLogging: {
            successFeedbackRoleArn: "arn:aws:iam::482724125666:role/SNSSuccessFeedback",
            failureFeedbackRoleArn: "arn:aws:iam::482724125666:role/SNSFailureFeedback",
            successFeedbackSampleRate: 5
        },
        sqsMessageDeliveryLogging: {
            successFeedbackRoleArn: "arn:aws:iam::482724125666:role/SNSSuccessFeedback",
            failureFeedbackRoleArn: "arn:aws:iam::482724125666:role/SNSFailureFeedback",
            successFeedbackSampleRate: 5
        }
    };

    string topicArn = check amazonSNSClient->createTopic(testRunId + "TopicWithAttributes.fifo", attributes);
    test:assertNotEquals(topicArn, "", "Topic ARN should not be empty.");
}

@test:Config {
    groups: ["topics"]
}
function createTopicWithInvalidAttributesTest() returns error? {
    InitializableTopicAttributes attributes = {
        deliveryPolicy: validDeliveryPolicy.toJson(),
        displayName: "Test4",
        fifoTopic: true,
        signatureVersion: SignatureVersion1,
        policy: validPolicy,
        tracingConfig: ACTIVE,
        kmsMasterKeyId: "testxyz",
        contentBasedDeduplication: false,
        httpMessageDeliveryLogging: {
            successFeedbackRoleArn: "arn:aws:iam::482724125666:role/SNSSuccessFeedback",
            failureFeedbackRoleArn: "arn:aws:iam::482724125666:role/SNSFailureFeedback",
            successFeedbackSampleRate: 5
        },
        lambdaMessageDeliveryLogging: {
            successFeedbackRoleArn: "arn:aws:iam::482724125666:role/SNSSuccessFeedback",
            failureFeedbackRoleArn: "arn:aws:iam::482724125666:role/SNSFailureFeedback",
            successFeedbackSampleRate: 5
        },
        firehoseMessageDeliveryLogging: {
            successFeedbackRoleArn: "arn:aws:iam::482724125666:role/SNSSuccessFeedback",
            failureFeedbackRoleArn: "arn:aws:iam::482724125666:role/SNSFailureFeedback",
            successFeedbackSampleRate: 5
        },
        applicationMessageDeliveryLogging: {
            successFeedbackRoleArn: "arn:aws:iam::482724125666:role/SNSSuccessFeedback",
            failureFeedbackRoleArn: "arn:aws:iam::482724125666:role/SNSFailureFeedback",
            successFeedbackSampleRate: 5
        },
        sqsMessageDeliveryLogging: {
            successFeedbackRoleArn: "arn:aws:iam::482724125666:role/SNSSuccessFeedback",
            failureFeedbackRoleArn: "arn:aws:iam::482724125666:role/SNSFailureFeedback",
            successFeedbackSampleRate: 500
        }
    };

    string|Error topicArn = amazonSNSClient->createTopic(testRunId + "TopicWithAttributes.fifo", attributes);
    test:assertTrue(topicArn is Error, "Error expected.");
    test:assertEquals((<Error>topicArn).message(), "Invalid parameter: Attributes Reason: SQSSuccessFeedbackSampleRate: 500 value provided is not an integer between 0-100");
}

@test:Config {
    groups: ["topics"]
}
function createTopicWithInvalidDeliveryPolicyTest() returns error? {
    InitializableTopicAttributes attributes = {
        deliveryPolicy: invalidDeliveryPolicy.toJson(),
        displayName: "Test4",
        fifoTopic: true,
        signatureVersion: SignatureVersion1,
        policy: validPolicy,
        tracingConfig: ACTIVE,
        kmsMasterKeyId: "testxyz",
        contentBasedDeduplication: false
    };

    string|error response = amazonSNSClient->createTopic(testRunId + "TopicWithInvalidDeliveryPolicy.fifo", attributes);
    test:assertTrue(response is Error, "Error expected.");
    test:assertEquals((<Error>response).message(), "Invalid parameter: Attributes Reason: DeliveryPolicy: http.defaultHealthyRetryPolicy.numRetries must be less than or equal to 100");
}

@test:Config {
    groups: ["topics"]
}
function createTopicWithInvalidPolicy() returns error? {
    InitializableTopicAttributes attributes = {
        deliveryPolicy: validDeliveryPolicy.toJson(),
        displayName: "Test4",
        fifoTopic: true,
        signatureVersion: SignatureVersion1,
        policy: invalidPolicy,
        tracingConfig: ACTIVE,
        kmsMasterKeyId: "testxyz",
        contentBasedDeduplication: false
    };

    string|error response = amazonSNSClient->createTopic(testRunId + "TopicWithInvalidPolicy.fifo", attributes);
    test:assertTrue(response is Error, "Error expected.");
    test:assertEquals((<Error>response).message(), "Invalid parameter: Attributes Reason: Policy statement action out of service scope!");
}

@test:Config {
    groups: ["topics"]
}
function createTopicAlreadyExistsWithDifferentAttributesTest() returns error? {
    InitializableTopicAttributes attributes = {
        deliveryPolicy: validDeliveryPolicy.toJson(),
        displayName: "Test4",
        fifoTopic: true,
        signatureVersion: SignatureVersion1,
        policy: validPolicy,
        tracingConfig: ACTIVE,
        kmsMasterKeyId: "testxyz",
        contentBasedDeduplication: false
    };
    _ = check amazonSNSClient->createTopic(testRunId + "TopicAlreadyExists.fifo", attributes);

    attributes.displayName = "Test5";
    string|Error response = amazonSNSClient->createTopic(testRunId + "TopicAlreadyExists.fifo", attributes);
    test:assertTrue(response is Error, "Error expected.");
    test:assertEquals((<Error>response).message(), "Invalid parameter: Attributes Reason: Topic already exists with different attributes");
}

@test:Config {
    groups: ["topics"]
}
function createFifoTopicWithoutSuffix() returns error? {
    InitializableTopicAttributes attributes = {
        fifoTopic: true
    };

    string topicArn = check amazonSNSClient->createTopic(testRunId + "FifoTopicWithoutSuffix", attributes);
    test:assertNotEquals(topicArn, "", "Topic ARN should not be empty.");
}

@test:Config {
    groups: ["topics"]
}
function createStandardTopicWithContentBasedDeduplicationEnabled() returns error? {
    InitializableTopicAttributes attributes = {
        fifoTopic: false,
        contentBasedDeduplication: true
    };

    string|error response = amazonSNSClient->createTopic(testRunId + "StandardTopicWithContentBasedDeduplicationEnabled", attributes);
    test:assertTrue(response is Error, "Error expected.");
    test:assertEquals((<Error>response).message(), "If content-based deduplication is enabled, it must also be a FIFO topic.");
}

@test:Config {
    groups: ["topics"]
}
function createStandardTopicWithContentBasedDeduplicationEnabled2() returns error? {
    InitializableTopicAttributes attributes = {
        contentBasedDeduplication: true
    };

    string|error response = amazonSNSClient->createTopic(testRunId + "StandardTopicWithContentBasedDeduplicationEnabled", attributes);
    test:assertTrue(response is Error, "Error expected.");
    test:assertEquals((<Error>response).message(), "If content-based deduplication is enabled, it must also be a FIFO topic.");
}

@test:Config {
    groups: ["topics"]
}
function createTopicWithDataProtectionPolicy() returns error? {
    string topicArn = check amazonSNSClient->createTopic(testRunId + "TopicWithDataProtectionPolicy",
        dataProtectionPolicy = validDataProtectionPolicy);
    test:assertNotEquals(topicArn, "", "Topic ARN should not be empty.");
}

@test:Config {
    groups: ["topics"]
}
function createTopicWithInvalidDataProtectionPolicy() returns error? {
    string|error response = amazonSNSClient->createTopic(testRunId + "TopicWithInvalidDataProtectionPolicy",
        dataProtectionPolicy = invalidDataProtectionPolicy);
    test:assertTrue(response is Error, "Error expected.");
    test:assertEquals((<Error>response).message(), "Invalid parameter: DataProtectionPolicy Reason: Statement DataDirection must be either Inbound or Outbound");
}

@test:Config {
    groups: ["topics"]
}
function createTopicWithTags() returns error? {
    map<string> tags = {"tag1": "value1", "tag2": "value2"};
    string topicArn = check amazonSNSClient->createTopic(testRunId + "TopicWithTags", tags = tags);
    test:assertNotEquals(topicArn, "", "Topic ARN should not be empty.");
}

@test:Config {
    groups: ["topics"]
}
function createTopicWithTagsNegative1() returns error? {
    map<string> tags = {"tag1hkfhksdhfkjhdsfkhskfhdskjfbdskjfhsdkfhsdkfhdsjkhfkjdshfkdshfkjdshfksdhkfshdkfhdskjfhsdkfhsdkjfhdkjsfhskdjhfkjsdhfkjdshfkjsdhfkjsdhfkjhsdkfjhsdkjfsdkjhfkj": "value1", "tag2": "value2"};
    string|error response = amazonSNSClient->createTopic(testRunId + "TopicWithTagsNegative1", tags = tags);
    test:assertTrue(response is Error, "Error expected.");
    test:assertEquals((<Error>response).message(), "1 validation error detected: Value 'tag1hkfhksdhfkjhdsfkhskfhdskjfbdskjfhsdkfhsdkfhdsjkhfkjdshfkdshfkjdshfksdhkfshdkfhdskjfhsdkfhsdkjfhdkjsfhskdjhfkjsdhfkjdshfkjsdhfkjsdhfkjhsdkfjhsdkjfsdkjhfkj' at 'tags.1.member.key' failed to satisfy constraint: Member must have length less than or equal to 128");
}

@test:Config {
    groups: ["topics"]
}
function createTopicWithTagsNegative2() returns error? {
    map<string> tags = {"tag1": "value1", "tag2": "value2", "tag3": "value3", "tag4": "value4", "tag5": "value5", "tag6": "value6", "tag7": "value7", "tag8": "value8", "tag9": "value9", "tag10": "value10", "tag11": "value11", "tag12": "value12", "tag13": "value13", "tag14": "value14", "tag15": "value15", "tag16": "value16", "tag17": "value17", "tag18": "value18", "tag19": "value19", "tag20": "value20", "tag21": "value21", "tag22": "value22", "tag23": "value23", "tag24": "value24", "tag25": "value25", "tag26": "value26", "tag27": "value27", "tag28": "value28", "tag29": "value29", "tag30": "value30", "tag31": "value31", "tag32": "value32", "tag33": "value33", "tag34": "value34", "tag35": "value35", "tag36": "value36", "tag37": "value37", "tag38": "value38", "tag39": "value39", "tag40": "value40", "tag41": "value41", "tag42": "value42", "tag43": "value43", "tag44": "value44", "tag45": "value45", "tag46": "value46", "tag47": "value47", "tag48": "value48", "tag49": "value49", "tag50": "value50", "tag51": "value51"};
    string|error response = amazonSNSClient->createTopic(testRunId + "TopicWithTagsNegative2", tags = tags);
    test:assertTrue(response is Error, "Error expected.");
    test:assertEquals((<Error>response).message(), "Could not complete request: tag quota of per resource exceeded");
}

@test:Config {
    groups: ["topics"]
}
function listTopicsTest() returns error? {
    string topicArn = check amazonSNSClient->createTopic(testRunId + "ListTopicsTest");
    stream<string, Error?> topicsStream = amazonSNSClient->listTopics();
    string[] topics = check from string topic in topicsStream
        select topic;
    test:assertTrue(topics.indexOf(topicArn) is int, topicArn + " not found in the list.");
    test:assertTrue(topics.length() > 100, "There should be over 100 topics.");

    // Ensure there are no duplicates
    foreach string topic in topics {
        test:assertEquals(topics.indexOf(topic), topics.lastIndexOf(topic),
            "Topic " + topic + " duplicated in the list.");
    }
}

@test:Config {
    groups: ["topics"]
}
function deleteTopicTest() returns error? {
    string topicArn = check amazonSNSClient->createTopic(testRunId + "TopicToDelete");
    _ = check amazonSNSClient->deleteTopic(topicArn);
}

@test:Config {
    groups: ["topics"]
}
function deleteTopicWithInvalidArnTest() returns error? {
    Error? e = amazonSNSClient->deleteTopic(testRunId + "Invalid:Topic:Arn");
    test:assertTrue(e is OperationError, "Error expected.");
    test:assertEquals((<OperationError>e).message(), "Invalid parameter: TopicArn Reason: An ARN must have at least 6 elements, not 3");
}

@test:Config {
    groups: ["topics"]
}
function deleteTopicWithArnThatDoesNotExistTest() returns error? {
    // This action is idempotent, so deleting a topic that does not exist does not result in an error.
    _ = check amazonSNSClient->deleteTopic("arn:aws:sns:us-east-1:482724125666:2023-10-03T102648743022ZArnDoesNotExist");
}

@test:Config {
    groups: ["topics"]
}
function getTopicAttributesTest1() returns error? {
    string topicArn = check amazonSNSClient->createTopic(testRunId + "TopicToRetrieve1");
    GettableTopicAttributes attributes = check amazonSNSClient->getTopicAttributes(topicArn);

    test:assertEquals(attributes.topicArn, topicArn);
    test:assertEquals(attributes.displayName, "");
    test:assertNotEquals(attributes.effectiveDeliveryPolicy, {});
    test:assertNotEquals(attributes.owner, "");
    test:assertNotEquals(attributes.policy, {});
    test:assertEquals(attributes.subscriptionsConfirmed, 0);
    test:assertEquals(attributes.subscriptionsDeleted, 0);
    test:assertEquals(attributes.subscriptionsPending, 0);
}

@test:Config {
    groups: ["topics"]
}
function getTopicAttributesTest2() returns error? {
    InitializableTopicAttributes setAttributes = {
        deliveryPolicy: validDeliveryPolicy.toJson(),
        displayName: "Test4",
        fifoTopic: true,
        signatureVersion: SignatureVersion1,
        policy: validPolicy,
        tracingConfig: ACTIVE,
        kmsMasterKeyId: "testxyz",
        contentBasedDeduplication: false
    };
    string topicArn = check amazonSNSClient->createTopic(testRunId + "TopicToRetrieve2", attributes = setAttributes,
        tags = {"tag1": "value1", "tag2": "value2"});

    GettableTopicAttributes attributes = check amazonSNSClient->getTopicAttributes(topicArn);
    test:assertEquals(attributes.topicArn, topicArn);
    test:assertEquals(attributes.displayName, setAttributes.displayName);
    test:assertNotEquals(attributes.effectiveDeliveryPolicy, {});
    test:assertNotEquals(attributes.owner, "");
    test:assertEquals(attributes.policy, validPolicy);
    test:assertEquals(attributes.subscriptionsConfirmed, 0);
    test:assertEquals(attributes.subscriptionsDeleted, 0);
    test:assertEquals(attributes.subscriptionsPending, 0);
    test:assertEquals(attributes?.deliveryPolicy, validDeliveryPolicy.toJson());
    test:assertEquals(attributes?.fifoTopic, true);
    test:assertEquals(attributes?.signatureVersion, SignatureVersion1);
    test:assertEquals(attributes?.tracingConfig, ACTIVE);
    test:assertEquals(attributes?.kmsMasterKeyId, "testxyz");
    test:assertEquals(attributes?.contentBasedDeduplication, false);
}

@test:Config {
    groups: ["topics"]
}
function setTopicAttributesTest1() returns error? {
    string topicArn = check amazonSNSClient->createTopic(testRunId + "SetTopicAttributes1", {
        fifoTopic: true,
        contentBasedDeduplication: true
    });
    GettableTopicAttributes attributes = check amazonSNSClient->getTopicAttributes(topicArn);
    test:assertEquals(attributes.topicArn, topicArn);
    test:assertEquals(attributes.displayName, "");
    test:assertNotEquals(attributes.effectiveDeliveryPolicy, {});
    test:assertNotEquals(attributes.owner, "");
    test:assertNotEquals(attributes.policy, {});
    test:assertEquals(attributes.subscriptionsConfirmed, 0);
    test:assertEquals(attributes.subscriptionsDeleted, 0);
    test:assertEquals(attributes.subscriptionsPending, 0);
    test:assertEquals(attributes.fifoTopic, true);
    test:assertEquals(attributes.contentBasedDeduplication, true);

    _ = check amazonSNSClient->setTopicAttributes(topicArn, {contentBasedDeduplication: false});
    attributes = check amazonSNSClient->getTopicAttributes(topicArn);
    test:assertEquals(attributes.topicArn, topicArn);
    test:assertEquals(attributes.displayName, "");
    test:assertNotEquals(attributes.effectiveDeliveryPolicy, {});
    test:assertNotEquals(attributes.owner, "");
    test:assertNotEquals(attributes.policy, {});
    test:assertEquals(attributes.subscriptionsConfirmed, 0);
    test:assertEquals(attributes.subscriptionsDeleted, 0);
    test:assertEquals(attributes.subscriptionsPending, 0);
    test:assertEquals(attributes.fifoTopic, true);
    test:assertEquals(attributes.contentBasedDeduplication, false);
};

@test:Config {
    groups: ["topics"]
}
function setTopicAttributesTest2() returns error? {
    string topicArn = check amazonSNSClient->createTopic(testRunId + "SetTopicAttributes2");

    SettableTopicAttributes setAttributes = {
        deliveryPolicy: validDeliveryPolicy.toJson(),
        displayName: "Test4",
        signatureVersion: SignatureVersion1,
        policy: validPolicy,
        tracingConfig: ACTIVE,
        kmsMasterKeyId: "testxyz",
        httpMessageDeliveryLogging: {
            successFeedbackRoleArn: "arn:aws:iam::482724125666:role/SNSSuccessFeedback",
            failureFeedbackRoleArn: "arn:aws:iam::482724125666:role/SNSFailureFeedback",
            successFeedbackSampleRate: 5
        },
        lambdaMessageDeliveryLogging: {
            successFeedbackRoleArn: "arn:aws:iam::482724125666:role/SNSSuccessFeedback",
            failureFeedbackRoleArn: "arn:aws:iam::482724125666:role/SNSFailureFeedback",
            successFeedbackSampleRate: 5
        },
        firehoseMessageDeliveryLogging: {
            successFeedbackRoleArn: "arn:aws:iam::482724125666:role/SNSSuccessFeedback",
            failureFeedbackRoleArn: "arn:aws:iam::482724125666:role/SNSFailureFeedback",
            successFeedbackSampleRate: 5
        },
        applicationMessageDeliveryLogging: {
            successFeedbackRoleArn: "arn:aws:iam::482724125666:role/SNSSuccessFeedback",
            failureFeedbackRoleArn: "arn:aws:iam::482724125666:role/SNSFailureFeedback",
            successFeedbackSampleRate: 5
        },
        sqsMessageDeliveryLogging: {
            successFeedbackRoleArn: "arn:aws:iam::482724125666:role/SNSSuccessFeedback",
            failureFeedbackRoleArn: "arn:aws:iam::482724125666:role/SNSFailureFeedback",
            successFeedbackSampleRate: 5
        }
    };
    _ = check amazonSNSClient->setTopicAttributes(topicArn, setAttributes);
    GettableTopicAttributes attributes = check amazonSNSClient->getTopicAttributes(topicArn);
    test:assertEquals(attributes.topicArn, topicArn);
    test:assertEquals(attributes?.deliveryPolicy, setAttributes?.deliveryPolicy);
    test:assertEquals(attributes.displayName, setAttributes.displayName);
    test:assertEquals(attributes.signatureVersion, setAttributes.signatureVersion);
    test:assertEquals(attributes.policy, setAttributes?.policy);
    test:assertEquals(attributes.tracingConfig, setAttributes?.tracingConfig);
    test:assertEquals(attributes.kmsMasterKeyId, setAttributes?.kmsMasterKeyId);
    test:assertEquals(attributes.httpMessageDeliveryLogging, setAttributes?.httpMessageDeliveryLogging);
    test:assertEquals(attributes.lambdaMessageDeliveryLogging, setAttributes?.lambdaMessageDeliveryLogging);
    test:assertEquals(attributes.firehoseMessageDeliveryLogging, setAttributes?.firehoseMessageDeliveryLogging);
    test:assertEquals(attributes.applicationMessageDeliveryLogging, setAttributes?.applicationMessageDeliveryLogging);
    test:assertEquals(attributes.sqsMessageDeliveryLogging, setAttributes?.sqsMessageDeliveryLogging);
}

@test:Config {
    groups: ["topics"]
}
function setTopicAttributesNegativeTest() returns error? {
    string topicArn = check amazonSNSClient->createTopic(testRunId + "SetTopicAttributesNegative");
    GettableTopicAttributes attributes = check amazonSNSClient->getTopicAttributes(topicArn);
    test:assertEquals(attributes.topicArn, topicArn);
    test:assertEquals(attributes.displayName, "");
    test:assertNotEquals(attributes.effectiveDeliveryPolicy, {});
    test:assertNotEquals(attributes.owner, "");
    test:assertNotEquals(attributes.policy, {});
    test:assertEquals(attributes.subscriptionsConfirmed, 0);
    test:assertEquals(attributes.subscriptionsDeleted, 0);
    test:assertEquals(attributes.subscriptionsPending, 0);

    SettableTopicAttributes updateAttributes = {
        deliveryPolicy: invalidDeliveryPolicy.toJson(),
        displayName: "Test4",
        signatureVersion: SignatureVersion1,
        policy: validPolicy,
        tracingConfig: ACTIVE,
        kmsMasterKeyId: "testxyz"
    };
    Error? e = amazonSNSClient->setTopicAttributes(topicArn, updateAttributes);
    test:assertTrue(e is OperationError, "Error expected.");
    test:assertEquals((<OperationError>e).message(), "Invalid parameter: DeliveryPolicy: http.defaultHealthyRetryPolicy.numRetries must be less than or equal to 100");
}
