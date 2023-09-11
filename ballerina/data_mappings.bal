// Copyright (c) 2023 WSO2 LLC. (http://www.wso2.org).
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

xmlns "http://sns.amazonaws.com/doc/2010-03-31/" as namespace;

isolated function xmlToCreatedTopic(xml response) returns CreateTopicResponse|error {
    xml createdTopicResponse = response/<namespace:CreateTopicResult>;
    xml responseMeta = response/<namespace:ResponseMetadata>;
    if createdTopicResponse.toString()!= EMPTY_STRING {
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
    if createdSubscriptionResponse.toString()!= EMPTY_STRING {
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
    if publishResponse.toString()!= EMPTY_STRING {
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
    if responseMeta.toString()!= EMPTY_STRING {
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
    if responseMeta.toString()!= EMPTY_STRING {
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
    if getTopicAttributesResponses.toString()!= EMPTY_STRING {
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
    if getSMSAttributesResponses.toString()!= EMPTY_STRING {
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
    if getSubscriptionAttributesResponses.toString()!= EMPTY_STRING {
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
    if confirmSubscriptionResponse.toString()!= EMPTY_STRING {
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

isolated function xmlToConfirmedSubscription(xml response) returns string|error {
    string|error subscriptionName = (response/<namespace:ConfirmSubscriptionResult>/<namespace:SubscriptionArn>/*).toString();
    if subscriptionName is string{
        return subscriptionName != EMPTY_STRING ? subscriptionName.toString() : EMPTY_STRING;
    } else {
        return subscriptionName;
    }
}

isolated function xmlToHttpResponse(xml response) returns error? {
    string|error httpResponse = (response/<namespace:ResponseMetadata>/<namespace:RequestId>/*).toString();
    if httpResponse is string{
        return null;
    } else {
        return error(OPERATION_ERROR);
    }
}
