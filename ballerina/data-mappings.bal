import ballerina/lang.'int as langint;
import ballerina/lang.'boolean as langboolean;

isolated function setAttributes(map<string> parameters, map<anydata> attributes) {
    int attributeNumber = 1;
    foreach [string, anydata] [key, value] in attributes.entries() {
        parameters["Attributes.entry." + attributeNumber.toString() + ".key"] = key;

        if value is record {} {
            parameters["Attributes.entry." + attributeNumber.toString() + ".value"] = value.toJsonString();
        } else {
            parameters["Attributes.entry." + attributeNumber.toString() + ".value"] = value.toString();
        }

        attributeNumber = attributeNumber + 1;
    }
}

isolated function setTags(map<string> parameters, map<string> tags) {
    int tagNumber = 1;
    foreach [string, string] [key, value] in tags.entries() {
        parameters["Tags.member." + tagNumber.toString() + ".Key"] = key;
        parameters["Tags.member." + tagNumber.toString() + ".Value"] = value;
        tagNumber = tagNumber + 1;
    }
}

isolated function mapJsonToGettableTopicAttributes(json jsonResponse) returns GettableTopicAttributes|error {
    string[] intFields = ["SubscriptionsPending", "SubscriptionsConfirmed", "SubscriptionsDeleted"];
    string[] booleanFields = ["FifoTopic", "ContentBasedDeduplication"];
    string[] jsonFields = ["EffectiveDeliveryPolicy", "Policy", "DeliveryPolicy"];
    string[] skipFields = [
        "HTTPSuccessFeedbackRoleArn", "HTTPFailureFeedbackRoleArn", "HTTPSuccessFeedbackSampleRate",
        "FirehoseSuccessFeedbackRoleArn", "FirehoseFailureFeedbackRoleArn", "FirehoseSuccessFeedbackSampleRate",
        "LambdaSuccessFeedbackRoleArn", "LambdaFailureFeedbackRoleArn", "LambdaSuccessFeedbackSampleRate",
        "SQSSuccessFeedbackRoleArn", "SQSFailureFeedbackRoleArn", "SQSSuccessFeedbackSampleRate",
        "ApplicationSuccessFeedbackRoleArn", "ApplicationFailureFeedbackRoleArn", "ApplicationSuccessFeedbackSampleRate"
    ];
    record {} response = check jsonResponse.cloneWithType();

    GettableTopicAttributes topicAttributes = {
        topicArn: "",
        effectiveDeliveryPolicy: {},
        owner: "",
        displayName: "",
        subscriptionsPending: 0,
        subscriptionsConfirmed: 0,
        subscriptionsDeleted: 0,
        policy: {}
    };

    foreach [string, anydata] [key, value] in response.entries() {
        if (skipFields.indexOf(key) is int) {
            continue;
        }

        anydata val = value;
        if intFields.indexOf(key) is int {
            val = check langint:fromString(value.toString());
        } else if booleanFields.indexOf(key) is int {
            val = check langboolean:fromString(value.toString());
        } else if jsonFields.indexOf(key) is int {
            val = check value.toString().fromJsonString();
        }
        topicAttributes[lowercaseFirstLetter(key)] = val;
    }

    check addMessageDeliveryLoggingFieldsToTopicAttributes(topicAttributes, response);
    return topicAttributes;
}

isolated function formatAttributes(record {} r, map<string> formatMap) returns record {}|Error {
    record {} flattenedRecord = {};
    string[] elementKeys = formatMap.keys();

    foreach string key in r.keys() {
        if (elementKeys.indexOf(key) is int) {
            record {}|error nestedRecord = r[key].ensureType();
            if (nestedRecord is error) {
                return error GenerateRequestFailed(nestedRecord.message(), nestedRecord);
            }

            foreach string nestedKey in nestedRecord.keys() {
                flattenedRecord[formatMap.get(key) + uppercaseFirstLetter(nestedKey)] = nestedRecord[nestedKey];
            }
        } else {
            flattenedRecord[uppercaseFirstLetter(key)] = r[key];
        }
    }

    return flattenedRecord;
}

isolated function addMessageDeliveryLoggingFieldsToTopicAttributes(GettableTopicAttributes topicAttributes, 
    record {} response) returns error? {
    if (response.hasKey("HTTPSuccessFeedbackRoleArn") || response.hasKey("HTTPFailureFeedbackRoleArn") ||
        response.hasKey("HTTPSuccessFeedbackSampleRate")) {
        MessageDeliveryLoggingConfig httpMessageDeliveryLogging = {};
        if response.hasKey("HTTPSuccessFeedbackRoleArn") {
            httpMessageDeliveryLogging.successFeedbackRoleArn = response["HTTPSuccessFeedbackRoleArn"].toString();
        }
        if response.hasKey("HTTPFailureFeedbackRoleArn") {
            httpMessageDeliveryLogging.failureFeedbackRoleArn = response["HTTPFailureFeedbackRoleArn"].toString();
        }
        if response.hasKey("HTTPSuccessFeedbackSampleRate") {
            httpMessageDeliveryLogging.successFeedbackSampleRate =
                check langint:fromString(response["HTTPSuccessFeedbackSampleRate"].toString());
        }
        topicAttributes.httpMessageDeliveryLogging = httpMessageDeliveryLogging;
    }

    if (response.hasKey("FirehoseSuccessFeedbackRoleArn") || response.hasKey("FirehoseFailureFeedbackRoleArn") ||
        response.hasKey("FirehoseSuccessFeedbackSampleRate")) {
        MessageDeliveryLoggingConfig firehoseMessageDeliveryLogging = {};
        if response.hasKey("FirehoseSuccessFeedbackRoleArn") {
            firehoseMessageDeliveryLogging.successFeedbackRoleArn =
                response["FirehoseSuccessFeedbackRoleArn"].toString();
        }
        if response.hasKey("FirehoseFailureFeedbackRoleArn") {
            firehoseMessageDeliveryLogging.failureFeedbackRoleArn =
                response["FirehoseFailureFeedbackRoleArn"].toString();
        }
        if response.hasKey("FirehoseSuccessFeedbackSampleRate") {
            firehoseMessageDeliveryLogging.successFeedbackSampleRate =
                check langint:fromString(response["FirehoseSuccessFeedbackSampleRate"].toString());
        }
        topicAttributes.firehoseMessageDeliveryLogging = firehoseMessageDeliveryLogging;
    }

    if (response.hasKey("LambdaSuccessFeedbackRoleArn") || response.hasKey("LambdaFailureFeedbackRoleArn") ||
        response.hasKey("LambdaSuccessFeedbackSampleRate")) {
        MessageDeliveryLoggingConfig lambdaMessageDeliveryLogging = {};
        if response.hasKey("LambdaSuccessFeedbackRoleArn") {
            lambdaMessageDeliveryLogging.successFeedbackRoleArn = response["LambdaSuccessFeedbackRoleArn"].toString();
        }
        if response.hasKey("LambdaFailureFeedbackRoleArn") {
            lambdaMessageDeliveryLogging.failureFeedbackRoleArn = response["LambdaFailureFeedbackRoleArn"].toString();
        }
        if response.hasKey("LambdaSuccessFeedbackSampleRate") {
            lambdaMessageDeliveryLogging.successFeedbackSampleRate =
                check langint:fromString(response["LambdaSuccessFeedbackSampleRate"].toString());
        }
        topicAttributes.lambdaMessageDeliveryLogging = lambdaMessageDeliveryLogging;
    }

    if (response.hasKey("SQSSuccessFeedbackRoleArn") || response.hasKey("SQSFailureFeedbackRoleArn") ||
        response.hasKey("SQSSuccessFeedbackSampleRate")) {
        MessageDeliveryLoggingConfig sqsMessageDeliveryLogging = {};
        if response.hasKey("SQSSuccessFeedbackRoleArn") {
            sqsMessageDeliveryLogging.successFeedbackRoleArn = response["SQSSuccessFeedbackRoleArn"].toString();
        }
        if response.hasKey("SQSFailureFeedbackRoleArn") {
            sqsMessageDeliveryLogging.failureFeedbackRoleArn = response["SQSFailureFeedbackRoleArn"].toString();
        }
        if response.hasKey("SQSSuccessFeedbackSampleRate") {
            sqsMessageDeliveryLogging.successFeedbackSampleRate =
                check langint:fromString(response["SQSSuccessFeedbackSampleRate"].toString());
        }
        topicAttributes.sqsMessageDeliveryLogging = sqsMessageDeliveryLogging;
    }

    if (response.hasKey("ApplicationSuccessFeedbackRoleArn") || response.hasKey("ApplicationFailureFeedbackRoleArn") ||
        response.hasKey("ApplicationSuccessFeedbackSampleRate")) {
        MessageDeliveryLoggingConfig applicationMessageDeliveryLogging = {};
        if response.hasKey("ApplicationSuccessFeedbackRoleArn") {
            applicationMessageDeliveryLogging.successFeedbackRoleArn =
                response["ApplicationSuccessFeedbackRoleArn"].toString();
        }
        if response.hasKey("ApplicationFailureFeedbackRoleArn") {
            applicationMessageDeliveryLogging.failureFeedbackRoleArn =
                response["ApplicationFailureFeedbackRoleArn"].toString();
        }
        if response.hasKey("ApplicationSuccessFeedbackSampleRate") {
            applicationMessageDeliveryLogging.successFeedbackSampleRate =
                check langint:fromString(response["ApplicationSuccessFeedbackSampleRate"].toString());
        }
        topicAttributes.applicationMessageDeliveryLogging = applicationMessageDeliveryLogging;
    }

}