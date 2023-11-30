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

sns:ConnectionConfig config = {
    accessKeyId: accessKeyId,
    secretAccessKey: secretAccessKey,
    region: region
};

sns:Client amazonSNSClient = check new(config);

string messiFanEmail = "<MESSI_FAN_EMAIL>";
string ronaldoFanEmail = "<RONALDO_FAN_EMAIL>";

public function main() returns error? {
    string footballScores = check amazonSNSClient->createTopic("FootballScores");

    _ = check amazonSNSClient->subscribe(footballScores, messiFanEmail, sns:EMAIL, 
        attributes = {
            filterPolicy: {messiPlaying: ["true"]},
            filterPolicyScope: sns:MESSAGE_ATTRIBUTES
        }
    );
    _ = io:readln("Please confirm the subscription for the Messi fan by clicking on the link sent to your email and press any key to continue.");

    _ = check amazonSNSClient->subscribe(footballScores, messiFanEmail, sns:EMAIL, 
        attributes = {
            filterPolicy: {ronaldoPlaying: ["true"]},
            filterPolicyScope: sns:MESSAGE_ATTRIBUTES
        }
    );
    _ = io:readln("Please confirm the subscription for the Ronaldo fan by clicking on the link sent to your email and press any key to continue.");

    _ = check amazonSNSClient->publish(footballScores, "The score for Barcelona vs. Liverpool is 1-0", 
        attributes = {messiPlaying: "true"}
    );

    _ = check amazonSNSClient->publish(footballScores, "The score for Real Madrid vs. Machester City is 2-0", 
        attributes = {messiPlaying: "true"}
    );

    _ = check amazonSNSClient->publish(footballScores, "The score for Barcelona vs. Real Madrid is 2-2", 
        attributes = {messiPlaying: "true", ronaldoPlaying: "true"}
    );
}
