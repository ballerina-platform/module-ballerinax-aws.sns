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

isolated function validateInitializableTopicAttributes(InitializableTopicAttributes attributes) returns Error? {
    // If content-based deduplication is enabled, then it must also be a FIFO topic
    if (attributes.contentBasedDeduplication is boolean && <boolean>attributes.contentBasedDeduplication) &&
                    (!(attributes.fifoTopic is boolean) || !<boolean>attributes.fifoTopic) {
        return error Error("If content-based deduplication is enabled, it must also be a FIFO topic.");
    }
}

isolated function validateTopicAttribute(TopicAttributeName attributeName,
    json|string|int|boolean value) returns Error? {

    if attributeName is DISPLAY_NAME && !(value is string) {
        return error Error("The display name must be of type string.");
    }
    
    if attributeName is SIGNATURE_VERSION && !(value is SignatureVersion) {
        return error Error("The signature version must be of type SignatureVersion.");
    }

    if attributeName is TRACING_CONFIG && !(value is TracingConfig) {
        return error Error("The tracing config must be of type TracingConfig.");
    }

    if attributeName is KMS_MASTER_KEY_ID && !(value is string) {
        return error Error("The KMS master key ID must be of type string.");
    }

    if attributeName is CONTENT_BASED_DEDUPLICATION && !(value is boolean) {
        return error Error("The content-based deduplication must be of type MessageDeliveryLoggingConfig.");
    }

    if attributeName is HTTP_SUCCESS_FEEDBACK_ROLE_ARN && !(value is string) {
        return error Error("The HTTP success feedback role ARN must be of type string.");
    }

    if attributeName is HTTP_FAILURE_FEEDBACK_ROLE_ARN && !(value is string) {
        return error Error("The HTTP failure feedback role ARN must be of type string.");
    }

    if attributeName is HTTP_SUCCESS_FEEDBACK_SAMPLE_RATE && !(value is int) {
        return error Error("The HTTP success feedback sample rate must be of type int.");
    }

    if attributeName is FIREHOSE_SUCCESS_FEEDBACK_ROLE_ARN && !(value is string) {
        return error Error("The Firehose success feedback role ARN must be of type string.");
    }

    if attributeName is FIREHOSE_FAILURE_FEEDBACK_ROLE_ARN && !(value is string) {
        return error Error("The Firehose failure feedback role ARN must be of type string.");
    }

    if attributeName is FIREHOSE_SUCCESS_FEEDBACK_SAMPLE_RATE && !(value is int) {
        return error Error("The Firehose success feedback sample rate must be of type int.");
    }

    if attributeName is LAMBDA_SUCCESS_FEEDBACK_ROLE_ARN && !(value is string) {
        return error Error("The Lambda success feedback role ARN must be of type string.");
    }

    if attributeName is LAMBDA_FAILURE_FEEDBACK_ROLE_ARN && !(value is string) {
        return error Error("The Lambda failure feedback role ARN must be of type string.");
    }

    if attributeName is LAMBDA_SUCCESS_FEEDBACK_SAMPLE_RATE && !(value is int) {
        return error Error("The Lambda success feedback sample rate must be of type int.");
    }

    if attributeName is APPLICATION_SUCCESS_FEEDBACK_ROLE_ARN && !(value is string) {
        return error Error("The application success feedback role ARN must be of type string.");
    }

    if attributeName is APPLICATION_FAILURE_FEEDBACK_ROLE_ARN && !(value is string) {
        return error Error("The application failure feedback role ARN must be of type string.");
    }

    if attributeName is APPLICATION_SUCCESS_FEEDBACK_SAMPLE_RATE && !(value is int) {
        return error Error("The application success feedback sample rate must be of type int.");
    }

    if attributeName is SQS_SUCCESS_FEEDBACK_ROLE_ARN && !(value is string) {
        return error Error("The SQS success feedback role ARN must be of type string.");
    }

    if attributeName is SQS_FAILURE_FEEDBACK_ROLE_ARN && !(value is string) {
        return error Error("The SQS failure feedback role ARN must be of type string.");
    }

    if attributeName is SQS_SUCCESS_FEEDBACK_SAMPLE_RATE && !(value is int) {
        return error Error("The SQS success feedback sample rate must be of type int.");
    }
}

isolated function validatePublishParameters(string topicArn, TargetType targetType, string? groupId) returns Error? {
    // If the topic is a FIFO topic, then a group ID must be provided
    if (targetType is TOPIC && topicArn.endsWith(".fifo") && groupId == ()) {
        return error Error("A message published to a FIFO topic requires a group ID.");
    }
}

isolated function validateSubscriptionAttribute(SubscriptionAttributeName attributeName, 
    json|FilterPolicyScope|boolean|string value) returns Error? {
    
    if attributeName is FILTER_POLICY_SCOPE && !(value is FilterPolicyScope) {
        return error Error("The filter policy scope must be of type FilterPolicyScope.");
    }

    if attributeName is RAW_MESSAGE_DELIVERY && !(value is boolean) {
        return error Error("The raw message delivery must be of type boolean.");
    }

    if attributeName is SUBSCRIPTION_ROLE_ARN && !(value is string) {
        return error Error("The subscription role ARN must be of type string.");
    }
}

