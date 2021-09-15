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


xmlns "http://sns.amazonaws.com/doc/2010-03-31/" as namespace;

isolated function xmlToCreatedTopicOld(xml response) returns string|error {
    string|error topicName = (response/<namespace:CreateTopicResult>/<namespace:TopicArn>/*).toString();
    if (topicName is string) {
        return topicName != "" ? topicName.toString() : "";
    } else {
        return topicName;
    }
}

isolated function xmlToCreatedTopic(xml response) returns CreateTopicResponse|error {
    xml createdTopicResponse = response/<namespace:CreateTopicResult>;
    xml responseMeta = response/<namespace:ResponseMetadata>;
    if (createdTopicResponse.toString() != "") {
        CreateTopicResult createTopic = {
            topicArn : (createdTopicResponse/<namespace:TopicArn>/*).toString()
        };
        ResponseMetadata responseMetadata = {
            requestId: (responseMeta/<namespace:RequestId>/*).toString()
        };
        CreateTopicResponse createTopicResponse = {
            createTopicResult : createTopic,
            responseMetadata : responseMetadata 
        };
        return createTopicResponse;
    } else {
        return error(response.toString());
    }
}

isolated function xmlToCreatedSubscription(xml response) returns SubscribeResponse|error {
    xml createdSubscriptionResponse = response/<namespace:SubscribeResult>;
    xml responseMeta = response/<namespace:ResponseMetadata>;
    if (createdSubscriptionResponse.toString() != "") {
        SubscribeResult subscribtionResult = {
            subscriptionArn : (createdSubscriptionResponse/<namespace:SubscriptionArn>/*).toString()
        };
        ResponseMetadata responseMetadata = {
            requestId: (responseMeta/<namespace:RequestId>/*).toString()
        };
        SubscribeResponse subscribeResponse = {
            subscribeResult : subscribtionResult,
            responseMetadata : responseMetadata 
        };
        return subscribeResponse;
    } else {
        return error(response.toString());
    }
}

isolated function xmlToPublishResponse(xml response) returns PublishResponse|error {
    xml publishResponse = response/<namespace:PublishResult>;
    xml responseMeta = response/<namespace:ResponseMetadata>;
    if (publishResponse.toString() != "") {
        PublishResult publishResult = {
            messageId : (publishResponse/<namespace:SubscriptionArn>/*).toString()
        };
        ResponseMetadata responseMetadata = {
            requestId: (responseMeta/<namespace:RequestId>/*).toString()
        };
        PublishResponse publishedResponse = {
            publishResult : publishResult,
            responseMetadata : responseMetadata 
        };
        return publishedResponse;
    } else {
        return error(response.toString());
    }
}

isolated function xmlToUnsubscribeResponse(xml response) returns UnsubscribeResponse|error {
    xml responseMeta = response/<namespace:ResponseMetadata>;
    if (responseMeta.toString() != "") {
        ResponseMetadata responseMetadata = {
            requestId: (responseMeta/<namespace:RequestId>/*).toString()
        };
        UnsubscribeResponse unsubscriptionResponse = {
            responseMetadata : responseMetadata 
        };
        return unsubscriptionResponse;
    } else {
        return error(response.toString());
    }
}

isolated function xmlToDeletedTopicResponse(xml response) returns DeleteTopicResponse|error {
    xml responseMeta = response/<namespace:ResponseMetadata>;
    if (responseMeta.toString() != "") {
        ResponseMetadata responseMetadata = {
            requestId: (responseMeta/<namespace:RequestId>/*).toString()
        };
        DeleteTopicResponse deletedTopice = {
            responseMetadata : responseMetadata 
        };
        return deletedTopice;
    } else {
        return error(response.toString());
    }
}

isolated function xmlToGetTopicAttributes(xml response) returns GetTopicAttributesResponse|error {
    xml getTopicAttributesResponses = response/<namespace:GetTopicAttributesResult>;
    xml responseMeta = response/<namespace:ResponseMetadata>;
    if (getTopicAttributesResponses.toString() != "") {
        GetTopicAttributesResult getTopicAttributesResult = {
            attributes: (getTopicAttributesResponses/<namespace:Attributes>/*).toString()
        };
        ResponseMetadata responseMetadata = {
            requestId: (responseMeta/<namespace:RequestId>/*).toString()
        };
        GetTopicAttributesResponse getTopicAttributesResponse = {
            getTopicAttributesResult : getTopicAttributesResult,
            responseMetadata : responseMetadata 
        };
        return getTopicAttributesResponse;
    } else {
        return error(response.toString());
    }
}

isolated function xmlToGetSmsAttributes(xml response) returns GetSMSAttributesResponse|error {
    xml getSMSAttributesResponses = response/<namespace:GetSMSAttributesResult>;
    xml responseMeta = response/<namespace:ResponseMetadata>;
    if (getSMSAttributesResponses.toString() != "") {
        GetSMSAttributesResult getSMSAttributesResult = {
            attributes: (getSMSAttributesResponses/<namespace:attributes>/*).toString()
        };
        ResponseMetadata responseMetadata = {
            requestId: (responseMeta/<namespace:RequestId>/*).toString()
        };
        GetSMSAttributesResponse getSMSAttributesResponse = {
            getSMSAttributesResult : getSMSAttributesResult,
            responseMetadata : responseMetadata 
        };
        return getSMSAttributesResponse;
    } else {
        return error(response.toString());
    }
}

isolated function xmlToGetSubscriprionAttributes(xml response) returns GetSubscriptionAttributesResponse|error {
    xml getSubscriptionAttributesResponses = response/<namespace:GetSubscriptionAttributesResult>;
    xml responseMeta = response/<namespace:ResponseMetadata>;
    if (getSubscriptionAttributesResponses.toString() != "") {
        GetSubscriptionAttributesResult getSubscriptionAttributesResult = {
            attributes: (getSubscriptionAttributesResponses/<namespace:Attributes>/*).toString()
        };
        ResponseMetadata responseMetadata = {
            requestId: (responseMeta/<namespace:RequestId>/*).toString()
        };
        GetSubscriptionAttributesResponse getSubscriptionAttributesResponse = {
            getSubscriptionAttributesResult : getSubscriptionAttributesResult,
            responseMetadata : responseMetadata 
        };
        return getSubscriptionAttributesResponse;
    } else {
        return error(response.toString());
    }
}

isolated function xmlToConfirmedSubscriptionResponse(xml response) returns ConfirmedSubscriptionResponse|error {
    xml confirmSubscriptionResponse = response/<namespace:ConfirmSubscriptionResult>;
    xml responseMeta = response/<namespace:ResponseMetadata>;
    if (confirmSubscriptionResponse.toString() != "") {
        ConfirmedSubscriptionResult confirmSubscriptionResult = {
            subscriptionArn : (confirmSubscriptionResponse/<namespace:SubscriptionArn>/*).toString()
        };
        ResponseMetadata responseMetadata = {
            requestId: (responseMeta/<namespace:RequestId>/*).toString()
        };
        ConfirmedSubscriptionResponse confirmedSubscriptionResponse = {
            confirmedSubscriptionResult : confirmSubscriptionResult,
            responseMetadata : responseMetadata 
        };
        return confirmedSubscriptionResponse;
    } else {
        return error(response.toString());
    }
}

isolated function xmlTopicListToTopicArray(xml response) returns string|error {
    string|error topicName = (response/<namespace:TopicArn>/*).toString();
    if (topicName is string) {
        return topicName != "" ? topicName.toString() : "";
    } else {
        return topicName;
    }
}

isolated function xmlSubscriptionListToSubscriptionArray(xml response) returns SubscriptionList|error {
    SubscriptionList subscriptionList = {
        owner: (response/<namespace:Owner>/*).toString(),
        endpoint: (response/<namespace:Endpoint>/*).toString(),
        protocol: (response/<namespace:Protocol>/*).toString(),
        subscriptionArn: (response/<namespace:SubscriptionArn>/*).toString(),
        topicArn: (response/<namespace:TopicArn>/*).toString()
    };
    return subscriptionList;
}

isolated function xmlToCreatedSubscriptionOld(xml response) returns string|error {
    string|error subscriptionName = (response/<namespace:SubscribeResult>/<namespace:SubscriptionArn>/*).toString();
    if (subscriptionName is string) {
        return subscriptionName != "" ? subscriptionName.toString() : "";
    } else {
        return subscriptionName;
    }
}

isolated function xmlToConfirmedSubscription(xml response) returns string|error {
    string|error subscriptionName = (response/<namespace:ConfirmSubscriptionResult>/<namespace:SubscriptionArn>/*).toString();
    if (subscriptionName is string) {
        return subscriptionName != "" ? subscriptionName.toString() : "";
    } else {
        return subscriptionName;
    }
}

isolated function xmlToPublished(xml response) returns string|error {
    string|error publishResult = (response/<namespace:PublishResult>/<namespace:MessageId>/*).toString();
    if (publishResult is string) {
        return publishResult != "" ? publishResult.toString() : "";
    } else {
        return publishResult;
    }
}

isolated function xmlToSubscriptionList(xml response) returns SubscriptionList|error {
    xml messages = response/<namespace:ListSubscriptionsResult>/<namespace:Subscriptions>/<namespace:member>;
    SubscriptionList subscriptions = {};
    int i = 0;
    foreach var message in messages.elements() {
        SubscriptionList|error subscription = xmlSubscriptionListToSubscriptionArray(message.elements());
        i = i + 1;
    }
    return subscriptions;
}

isolated function xmlToTopicList(xml response) returns string[]|error {
    xml messages = response/<namespace:ListTopicsResult>/<namespace:Topics>/<namespace:member>;
    string[] topics = [];
    if (messages.elements().length() != 1) {
        int i = 0;
        foreach var message in messages.elements() {
            string|error topic = xmlTopicListToTopicArray(message.elements());
            if (topic is string) {
                topics[i] = topic;
            }
            i = i + 1;
        }
        return topics;
    } else {
        string|error topic = xmlToCreatedTopicOld(messages);
        if (topic is string) {
            return [topic];
        } else {
            return topic;
        }
    }
}

isolated function xmlToSMSAttributes(xml response) returns SmsAttributeArray[]|error {
    xml attributes = response/<namespace:GetSMSAttributesResult>/<namespace:attributes>/<namespace:entry>;
    SmsAttributes smsAttributes = {};
    SmsAttributeArray[] smsAttributeArray = [];
    int i = 0;
    foreach var message in attributes.elements() {
        SmsAttributeArray smsAttribute = {
            key: (message/<namespace:key>/*).toString(),
            value: (message/<namespace:value>/*).toString()
        };
        smsAttributeArray[i] = smsAttribute;
        i = i + 1;
    }
    return smsAttributeArray;
}

isolated function xmlToTopicAttributes(xml response) returns TopicAttributeArray[]|error {
    xml attributes = response/<namespace:GetTopicAttributesResult>/<namespace:Attributes>/<namespace:entry>;
    TopicAttributes topicAttributes = {};
    TopicAttributeArray[] topicAttributeArray = [];
    int i = 0;
    foreach var message in attributes.elements() {
        TopicAttributeArray topicAttribute = {
            key: (message/<namespace:key>/*).toString(),
            value: (message/<namespace:value>/*).toString()
        };
        topicAttributeArray[i] = topicAttribute;
        i = i + 1;
    }
    return topicAttributeArray;
}

isolated function xmlToSubscriptionAttributes(xml response) returns SubscriptionAttributeArray[]|error {
    xml attributes = response/<namespace:GetSubscriptionAttributesResult>/<namespace:Attributes>/<namespace:entry>;
    SubscriptionAttributes subscriptionAttributes = {};
    SubscriptionAttributeArray[] subscriptionAttributeArray = [];
    int i = 0;
    foreach var message in attributes.elements() {
        SubscriptionAttributeArray subscriptionAttribute = {
            key: (message/<namespace:key>/*).toString(),
            value: (message/<namespace:value>/*).toString()
        };
        subscriptionAttributeArray[i] = subscriptionAttribute;
        i = i + 1;
    }
    return subscriptionAttributeArray;
}

isolated function xmlToHttpResponse(xml response) returns error? {
    string|error httpResponse = (response/<namespace:ResponseMetadata>/<namespace:RequestId>/*).toString();
    if (httpResponse is string) {
        return null;
    } else {
        return error(OPERATION_ERROR);
    }
}
