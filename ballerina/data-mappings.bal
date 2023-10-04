import ballerina/lang.'int as langint;
import ballerina/lang.'boolean as langboolean;

isolated function setAttributes(map<string> parameters, map<anydata> attributes) {
    int attributeNumber = 1;
    foreach [string, anydata] [key, value] in attributes.entries() {
        string attributeName = uppercaseFirstLetter(key);
        parameters["Attributes.entry." + attributeNumber.toString() + ".key"] = attributeName;

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
    record {} response = check jsonResponse.cloneWithType();

    GettableTopicAttributes gettableTopicAttributes = {
        topicArn: "",
        effectiveDeliveryPolicy: {},
        owner: "",
        displayName: "",
        subscriptionsPending: 0,
        subscriptionsConfirmed: 0,
        subscriptionsDeleted: 0,
        policy: ""
    };

    foreach [string, anydata] [key, value] in response.entries() {
        anydata val = value;
        if intFields.indexOf(key) is int {
            val = check langint:fromString(value.toString());
        }
        if booleanFields.indexOf(key) is int {
            val = check langboolean:fromString(value.toString());
        }
        if key is "EffectiveDeliveryPolicy" {
            val = check value.toString().fromJsonString();
        }
        gettableTopicAttributes[lowercaseFirstLetter(key)] = val;
    }
    return gettableTopicAttributes;
}