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

public type TopicAttribute record {
    string deliveryPolicy?;
    string displayName?;
    boolean fifoTopic?;
    boolean contentBasedDeduplication?;
    string kmsMasterKeyId?;
    string policy?;
};

public type Topic record {
    string topicArn;
    string requestId;
};

public type CreateTopicResponse record {
    CreateTopicResult createTopicResult;
    ResponseMetadata responseMetadata;
};

public type CreateTopicResult record {
    string topicArn;
};

public type SubscribeResponse record {
    SubscribeResult subscribeResult;
    ResponseMetadata responseMetadata;
};

public type SubscribeResult record {
    string subscriptionArn;
};

public type PublishResponse record {
    PublishResult publishResult;
    ResponseMetadata responseMetadata;
};

public type PublishResult record {
    string messageId;
};

public type ConfirmedSubscriptionResponse record {
    ConfirmedSubscriptionResult confirmedSubscriptionResult;
    ResponseMetadata responseMetadata;
};

public type ConfirmedSubscriptionResult record {
    string subscriptionArn;
};

public type UnsubscribeResponse record {
    ResponseMetadata responseMetadata;
};

public type DeleteTopicResponse record {
    ResponseMetadata responseMetadata;
};

public type GetTopicAttributesResponse record {
    GetTopicAttributesResult getTopicAttributesResult;
    ResponseMetadata responseMetadata;
};

public type GetTopicAttributesResult record {
    json attributes;
};

public type GetSMSAttributesResponse record {
    GetSMSAttributesResult getSMSAttributesResult;
    ResponseMetadata responseMetadata;
};

public type GetSMSAttributesResult record {
    json attributes;
};

public type GetSubscriptionAttributesResponse record {
    GetSubscriptionAttributesResult getSubscriptionAttributesResult;
    ResponseMetadata responseMetadata;
};

public type GetSubscriptionAttributesResult record {
    json attributes;
};

public type ResponseMetadata record {
    string requestId;
};

public type SubscriptionAttribute record {
    string deliveryPolicy?;
    string filterPolicy?;
    boolean rawMessageDelivery?;
    boolean redrivePolicy?;
    string subscriptionRoleArn?;
};

public type SmsAttribute record {
    string monthlySpendLimit?;
    string deliveryStatusIAMRole?;
    string deliveryStatusSuccessSamplingRate?;
    string defaultSenderID?;
    string defaultSMSType?;
    string usageReportS3Bucket?;
};

public type SubscriptionList record {
    string owner?;
    string endpoint?;
    string protocol?;
    string subscriptionArn?;
    string topicArn?;
};

public type SmsAttributeArray record {
    string key?;
    string value?;
};

public type SmsAttributes record {
    SmsAttributeArray[] smsAttribute?;
};

public type TopicAttributes record {
    TopicAttributeArray[] topicAttribute?;
};

public type TopicAttributeArray record {
    string key?;
    string value?;
};

public type SubscriptionAttributeArray record {
    string key?;
    string value?;
};

public type SubscriptionAttributes record {
    SubscriptionAttributeArray[] subscriptionAttribute?;
};

public type MessageAttribute record {
    string key?;
    string value?;
};
