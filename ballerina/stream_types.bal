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

import ballerina/http;

# Used to fetch and return a stream of SNS topics. The logic of fetching the topics is abstracted away from the user.
class TopicStream {

    private final http:Client amazonSNSClient;
    private final (isolated function(map<string>) returns http:Request|Error) & readonly generateRequest;

    private string[] topics = [];
    private string? nextToken = ();
    private boolean initialized = false;

    public isolated function init(http:Client amazonSNSClient, 
        isolated function (map<string>) returns http:Request|Error generateRequest) {
        self.amazonSNSClient = amazonSNSClient;
        self.generateRequest = generateRequest;
    }

    private isolated function fetchTopics() returns Error? {
        map<string> parameters = initiateRequest("ListTopics");
        if self.nextToken is string {
            parameters["NextToken"] = <string>self.nextToken;
        }

        http:Request request = check self.generateRequest(parameters);
        json response = check sendRequest(self.amazonSNSClient, request);

        json|error nextToken = response.ListTopicsResponse.ListTopicsResult.NextToken;
        if nextToken is json && nextToken != () {
            self.nextToken = nextToken.toString();
        } else {
            self.nextToken = ();
        }

        do {
            json[] topics = <json[]>(check response.ListTopicsResponse.ListTopicsResult.Topics);
            foreach json topic in topics {
                self.topics.push((check topic.TopicArn).toString());
            }
        } on fail error e {
            return error ResponseHandleFailedError(e.message(), e);
        }
    }

    public isolated function next() returns record {|string value;|}|Error? {
        if self.topics.length() == 0 {
            if self.initialized && self.nextToken is () {
                return ();
            }

            Error? e = self.fetchTopics();
            self.initialized = true;
            if e is error {
                return e;
            }
        }

        if self.topics.length() == 0 {
            return ();
        }
    
        return {value: self.topics.remove(0)};
    }

    public isolated function close() returns Error? {
        return ();
    }
}

# Used to fetch and return a stream of SNS subscriptions. The logic of fetching the subscriptions is abstracted away 
# from the user.
class SubscriptionStream {

    private final http:Client amazonSNSClient;
    private final (isolated function (map<string>) returns http:Request|Error) & readonly generateRequest;
    private final string? topicArn;

    private Subscription[] subscriptions = [];
    private string? nextToken = ();
    private boolean initialized = false;

    public isolated function init(http:Client amazonSNSClient,
            isolated function (map<string>) returns http:Request|Error generateRequest,
            string? topicArn) {
        self.amazonSNSClient = amazonSNSClient;
        self.generateRequest = generateRequest;
        self.topicArn = topicArn;
    }

    private isolated function fetchSubscriptions() returns Error? {
        map<string> parameters;
        if self.topicArn is string {
            parameters = initiateRequest("ListSubscriptionsByTopic");
            parameters["TopicArn"] = <string>self.topicArn;
        } else {
            parameters = initiateRequest("ListSubscriptions");
        }

        if self.nextToken is string {
            parameters["NextToken"] = <string>self.nextToken;
        }

        http:Request request = check self.generateRequest(parameters);
        json response = check sendRequest(self.amazonSNSClient, request);

        json|error nextToken;
        if self.topicArn is string {
            nextToken = response.ListSubscriptionsByTopicResponse.ListSubscriptionsByTopicResult.NextToken;
        } else {
            nextToken = response.ListSubscriptionsResponse.ListSubscriptionsResult.NextToken;
        }

        if nextToken is json && nextToken != () {
            self.nextToken = nextToken.toString();
        } else {
            self.nextToken = ();
        }

        do {
            json[] subscriptions;
            if self.topicArn is string {
                subscriptions = <json[]>
                    (check response.ListSubscriptionsByTopicResponse.ListSubscriptionsByTopicResult.Subscriptions);
            } else {
                subscriptions = 
                    <json[]>(check response.ListSubscriptionsResponse.ListSubscriptionsResult.Subscriptions);
            }

            foreach json subscription in subscriptions {
                self.subscriptions.push({
                    subscriptionArn: (check subscription.SubscriptionArn),
                    topicArn: (check subscription.TopicArn),
                    owner: (check subscription.Owner),
                    protocol: <SubscriptionProtocol>(check subscription.Protocol),
                    endpoint: (check subscription.Endpoint)
                });
            }
        } on fail error e {
            return error ResponseHandleFailedError(e.message(), e);
        }
    }

    public isolated function next() returns record {|Subscription value;|}|Error? {
        if self.subscriptions.length() == 0 {
            if self.initialized && self.nextToken is () {
                return ();
            }

            Error? e = self.fetchSubscriptions();
            self.initialized = true;
            if e is error {
                return e;
            }
        }

        if self.subscriptions.length() == 0 {
            return ();
        }

        return {value: self.subscriptions.remove(0)};
    }

    public isolated function close() returns Error? {
        return ();
    }
}

# Used to fetch and return a stream of SNS platform applications. The logic of fetching the platform applications is
# abstracted away from the user.
 class PlatformApplicationStream {

    private final http:Client amazonSNSClient;
    private final (isolated function (map<string>) returns http:Request|Error) & readonly generateRequest;

    private PlatformApplication[] platformApplications = [];
    private string? nextToken = ();
    private boolean initialized = false;

    public isolated function init(http:Client amazonSNSClient, 
        isolated function (map<string>) returns http:Request|Error generateRequest) {
        self.amazonSNSClient = amazonSNSClient;
        self.generateRequest = generateRequest;
    }

    private isolated function fetchPlatformApplications() returns Error? {
        map<string> parameters = initiateRequest("ListPlatformApplications");

        if self.nextToken is string {
            parameters["NextToken"] = <string>self.nextToken;
        }

        http:Request request = check self.generateRequest(parameters);
        json response = check sendRequest(self.amazonSNSClient, request);

        json|error nextToken = response.ListPlatformApplicationsResponse.ListPlatformApplicationsResult.NextToken;

        if nextToken is json && nextToken != () {
            self.nextToken = nextToken.toString();
        } else {
            self.nextToken = ();
        }

        do {
            json[] platformApplications = <json[]>(check response.ListPlatformApplicationsResponse
                .ListPlatformApplicationsResult.PlatformApplications);

            foreach json platformApplication in platformApplications {

                RetrievablePlatformApplicationAttributes attributes = 
                    check mapJsonToPlatformApplicationAttributes(check platformApplication.Attributes);
                PlatformApplication application = {
                    platformApplicationArn: (check platformApplication.PlatformApplicationArn),
                    ...attributes
                };
                self.platformApplications.push(application);
                
            }
        } on fail error e {
            return error ResponseHandleFailedError(e.message(), e);
        }
    }

    public isolated function next() returns record {|PlatformApplication value;|}|Error? {
        if self.platformApplications.length() == 0 {
            if self.initialized && self.nextToken is () {
                return ();
            }

            Error? e = self.fetchPlatformApplications();
            self.initialized = true;
            if e is error {
                return e;
            }
        }

        if self.platformApplications.length() == 0 {
            return ();
        }

        return {value: self.platformApplications.remove(0)};
    }

    public isolated function close() returns Error? {
        return ();
    }
}

# Used to fetch and return a stream of SNS endpoints. The logic of fetching the endpoints is abstracted away from the
# user.
class EndpointStream {

    private final http:Client amazonSNSClient;
    private final (isolated function (map<string>) returns http:Request|Error) & readonly generateRequest;
    private final string platformApplicationArn;

    private Endpoint[] endpoints = [];
    private string? nextToken = ();
    private boolean initialized = false;

    public isolated function init(http:Client amazonSNSClient,
            isolated function (map<string>) returns http:Request|Error generateRequest, 
            string platformApplicationArn) {
        self.amazonSNSClient = amazonSNSClient;
        self.generateRequest = generateRequest;
        self.platformApplicationArn = platformApplicationArn;
    }

    private isolated function fetchPlatformApplicationEndpoints() returns Error? {
        map<string> parameters = initiateRequest("ListEndpointsByPlatformApplication");
        parameters["PlatformApplicationArn"] = <string>self.platformApplicationArn;

        if self.nextToken is string {
            parameters["NextToken"] = <string>self.nextToken;
        }

        http:Request request = check self.generateRequest(parameters);
        json response = check sendRequest(self.amazonSNSClient, request);

        json|error nextToken = response.ListEndpointsByPlatformApplicationResponse
            .ListEndpointsByPlatformApplicationResult.NextToken;

        if nextToken is json && nextToken != () {
            self.nextToken = nextToken.toString();
        } else {
            self.nextToken = ();
        }

        do {
            json[] platformApplicationEndpoints = <json[]>(check response.ListEndpointsByPlatformApplicationResponse
                .ListEndpointsByPlatformApplicationResult.Endpoints);

            foreach json platformApplicationEndpoint in platformApplicationEndpoints {

                EndpointAttributes attributes = check mapJsonToEndpointAttributes(
                    check platformApplicationEndpoint.Attributes);
                Endpoint endpoint = {
                    endpointArn: check platformApplicationEndpoint.EndpointArn,
                    ...attributes
                };
                self.endpoints.push(endpoint);

            }
        } on fail error e {
            return error ResponseHandleFailedError(e.message(), e);
        }
    }

    public isolated function next() returns record {|Endpoint value;|}|Error? {
        if self.endpoints.length() == 0 {
            if self.initialized && self.nextToken is () {
                return ();
            }

            Error? e = self.fetchPlatformApplicationEndpoints();
            self.initialized = true;
            if e is error {
                return e;
            }
        }

        if self.endpoints.length() == 0 {
            return ();
        }

        return {value: self.endpoints.remove(0)};
    }

    public isolated function close() returns Error? {
        return ();
    }
}

# Used to fetch and return a stream of SNS sandbox phone numbers. The logic of fetching the phone numbers is abstracted
# away from the user.
class SMSSandboxPhoneNumberStream {

    private final http:Client amazonSNSClient;
    private final (isolated function (map<string>) returns http:Request|Error) & readonly generateRequest;

    private SMSSandboxPhoneNumber[] phoneNumbers = [];
    private string? nextToken = ();
    private boolean initialized = false;

    public isolated function init(http:Client amazonSNSClient,
            isolated function (map<string>) returns http:Request|Error generateRequest) {
        self.amazonSNSClient = amazonSNSClient;
        self.generateRequest = generateRequest;
    }

    private isolated function fetchSMSSandboxPhoneNumbers() returns Error? {
        map<string> parameters = initiateRequest("ListSMSSandboxPhoneNumbers");

        if self.nextToken is string {
            parameters["NextToken"] = <string>self.nextToken;
        }

        http:Request request = check self.generateRequest(parameters);
        json response = check sendRequest(self.amazonSNSClient, request);

        json|error nextToken = response.ListSMSSandboxPhoneNumbersResponse.ListSMSSandboxPhoneNumbersResult.NextToken;

        if nextToken is json && nextToken != () {
            self.nextToken = nextToken.toString();
        } else {
            self.nextToken = ();
        }

        do {
            json[] phoneNumbers = <json[]>(check response.ListSMSSandboxPhoneNumbersResponse
                .ListSMSSandboxPhoneNumbersResult.PhoneNumbers);

            foreach json phoneNumber in phoneNumbers {
                SMSSandboxPhoneNumber smsSandboxPhoneNumber = {
                    phoneNumber: check phoneNumber.PhoneNumber,
                    status: <Status>(check phoneNumber.Status)
                };
                self.phoneNumbers.push(smsSandboxPhoneNumber);

            }
        } on fail error e {
            return error ResponseHandleFailedError(e.message(), e);
        }
    }

    public isolated function next() returns record {|SMSSandboxPhoneNumber value;|}|Error? {
        if self.phoneNumbers.length() == 0 {
            if self.initialized && self.nextToken is () {
                return ();
            }

            Error? e = self.fetchSMSSandboxPhoneNumbers();
            self.initialized = true;
            if e is error {
                return e;
            }
        }

        if self.phoneNumbers.length() == 0 {
            return ();
        }

        return {value: self.phoneNumbers.remove(0)};
    }

    public isolated function close() returns Error? {
        return ();
    }
}

# Used to fetch and return a stream of SNS origination phone numbers. The logic of fetching the phone numbers is
# abstracted away from the user.
class OriginationPhoneNumberStream {

    private final http:Client amazonSNSClient;
    private final (isolated function (map<string>) returns http:Request|Error) & readonly generateRequest;

    private OriginationPhoneNumber[] phoneNumbers = [];
    private string? nextToken = ();
    private boolean initialized = false;

    public isolated function init(http:Client amazonSNSClient,
            isolated function (map<string>) returns http:Request|Error generateRequest) {
        self.amazonSNSClient = amazonSNSClient;
        self.generateRequest = generateRequest;
    }

    private isolated function fetchOriginationPhoneNumbers() returns Error? {
        map<string> parameters = initiateRequest("ListOriginationNumbers");

        if self.nextToken is string {
            parameters["NextToken"] = <string>self.nextToken;
        }

        http:Request request = check self.generateRequest(parameters);
        json response = check sendRequest(self.amazonSNSClient, request);

        json|error nextToken = response.ListOriginationNumbersResponse.ListOriginationNumbersResult.NextToken;

        if nextToken is json && nextToken != () {
            self.nextToken = nextToken.toString();
        } else {
            self.nextToken = ();
        }

        do {
            json[] phoneNumbers = <json[]>(check response.ListOriginationNumbersResponse
                .ListOriginationNumbersResult.PhoneNumbers);

            foreach json phoneNumber in phoneNumbers {
                OriginationPhoneNumber originationPhoneNumber = check mapJsonToOriginationNumber(phoneNumber);
                self.phoneNumbers.push(originationPhoneNumber);

            }
        } on fail error e {
            return error ResponseHandleFailedError(e.message(), e);
        }
    }

    public isolated function next() returns record {|OriginationPhoneNumber value;|}|Error? {
        if self.phoneNumbers.length() == 0 {
            if self.initialized && self.nextToken is () {
                return ();
            }

            Error? e = self.fetchOriginationPhoneNumbers();
            self.initialized = true;
            if e is error {
                return e;
            }
        }

        if self.phoneNumbers.length() == 0 {
            return ();
        }

        return {value: self.phoneNumbers.remove(0)};
    }

    public isolated function close() returns Error? {
        return ();
    }
}

# Used to fetch and return a stream of SNS opted out phone numbers. The logic of fetching the phone numbers is
# abstracted away from the user.
class OptedOutPhoneNumberStream {

    private final http:Client amazonSNSClient;
    private final (isolated function (map<string>) returns http:Request|Error) & readonly generateRequest;

    private string[] phoneNumbers = [];
    private string? nextToken = ();
    private boolean initialized = false;

    public isolated function init(http:Client amazonSNSClient,
            isolated function (map<string>) returns http:Request|Error generateRequest) {
        self.amazonSNSClient = amazonSNSClient;
        self.generateRequest = generateRequest;
    }

    private isolated function fetchOptedOutPhoneNumbers() returns Error? {
        map<string> parameters = initiateRequest("ListPhoneNumbersOptedOut");
        if self.nextToken is string {
            parameters["nextToken"] = <string>self.nextToken;
        }

        http:Request request = check self.generateRequest(parameters);
        json response = check sendRequest(self.amazonSNSClient, request);

        json|error nextToken = response.ListPhoneNumbersOptedOutResponse.ListPhoneNumbersOptedOutResult.nextToken;
        if nextToken is json && nextToken != () {
            self.nextToken = nextToken.toString();
        } else {
            self.nextToken = ();
        }

        do {
            json[] phoneNumbers = <json[]>(check response.ListPhoneNumbersOptedOutResponse
                .ListPhoneNumbersOptedOutResult.phoneNumbers);
            foreach json phoneNumber in phoneNumbers {
                self.phoneNumbers.push(phoneNumber.toString());
            }
        } on fail error e {
            return error ResponseHandleFailedError(e.message(), e);
        }
    }

    public isolated function next() returns record {|string value;|}|Error? {
        if self.phoneNumbers.length() == 0 {
            if self.initialized && self.nextToken is () {
                return ();
            }

            Error? e = self.fetchOptedOutPhoneNumbers();
            self.initialized = true;
            if e is error {
                return e;
            }
        }

        if self.phoneNumbers.length() == 0 {
            return ();
        }

        return {value: self.phoneNumbers.remove(0)};
    }

    public isolated function close() returns Error? {
        return ();
    }
}
