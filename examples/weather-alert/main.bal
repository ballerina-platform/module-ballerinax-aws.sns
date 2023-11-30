// Copyright (c) 2023, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

import ballerinax/aws.sns;
import ballerina/os;
import ballerina/io;

configurable string accessKeyId = os:getEnv("ACCESS_KEY_ID");
configurable string secretAccessKey = os:getEnv("SECRET_ACCESS_KEY");
configurable string region = os:getEnv("REGION");

final string yourEmail = "<YOUR_EMAIL>";
final string yourPhone = "<YOUR_PHONE_NUMBER>";

sns:ConnectionConfig config = {
    accessKeyId: accessKeyId,
    secretAccessKey: secretAccessKey,
    region: region
};

sns:Client amazonSNSClient = check new(config);

public function main() returns error? {
    // First we would need to create separate topics for each city. If a topic with the same name already exists,
    // the existing topic will be returned
    string colombo = check amazonSNSClient->createTopic("Colombo");
    string london = check amazonSNSClient->createTopic("London");
    string washington = check amazonSNSClient->createTopic("Washington");

    // If you create a subscription for an email address, you need to confirm the subscription by clicking on the
    // link sent to your email
    _ = check amazonSNSClient->subscribe(colombo, yourEmail, sns:EMAIL);
    _ = io:readln("Please confirm the subscription to the Colombo topic by clicking on the link sent to your email and press any key to continue.");

    _ = check amazonSNSClient->subscribe(washington, yourEmail, sns:EMAIL);
    _ = io:readln("Please confirm the subscription to the Washington topic by clicking on the link sent to your email and press any key to continue.");

    // If your SNS account is in the sandbox mode, you need to verify your phone number before subscribing to a topic
    _ = check amazonSNSClient->createSMSSandboxPhoneNumber(yourPhone);
    string otp = io:readln("Please verify the phone number by entering the OTP sent to your mobile: ");
    _ = check amazonSNSClient->verifySMSSandboxPhoneNumber(yourPhone, otp);

    // You can create a subscription for a phone number without confirming it
    _ = check amazonSNSClient->subscribe(london, yourPhone, sns:SMS);
    _ = check amazonSNSClient->subscribe(washington, yourPhone, sns:SMS);

    // You can publish the a message to a topic. The same message will be sent to all the subscribers of the topic.
    // You should see the message in your email and SMS inbox
    _ = check amazonSNSClient->publish(colombo, "The temperature in Colombo is 24 degrees Celsius");
    _ = check amazonSNSClient->publish(london, "The temperature in London is 18 degrees Celsius");

    // You can also publish different messages to different subscribers of the same topic. The message delivered 
    // to a subscriber depends on the protocol of the subscription
    _ = check amazonSNSClient->publish(washington, {
        "default": "The temperature in Washington is 30 degrees Celsius",
        "sms": "Hello! The temperature in Washington is 30 degrees Celsius",
        "email": "Good morning! The temperature in Washington is 30 degrees Celsius"
    });

    // Finally you can list all subscriptions for the 3 topics and unsubscribe from them
    _ = check from sns:Subscription subscription in amazonSNSClient->listSubscriptions()
        where subscription.topicArn == colombo || 
                subscription.topicArn == london || 
                subscription.topicArn == washington
        do {
            check amazonSNSClient->unsubscribe(subscription.subscriptionArn);
        };
}
