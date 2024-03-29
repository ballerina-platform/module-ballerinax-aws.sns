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

const string DEFAULT_REGION = "us-east-1";
const string EMPTY_STRING = "";
const string ACTION = "Action";
const string VERSION = "Version";
const string VERSION_NUMBER = "2010-03-31";

const map<string> SPECIAL_TOPIC_ATTRIBUTES_MAP = {
    "httpMessageDeliveryLogging": "HTTP",
    "lambdaMessageDeliveryLogging": "Lambda",
    "sqsMessageDeliveryLogging": "SQS",
    "firehoseMessageDeliveryLogging": "Firehose",
    "applicationMessageDeliveryLogging": "Application"
};

const map<string> MESSAGE_RECORD_MAP = {
    "emailJson": "email-json",
    "apns": "APNS",
    "apnsSandbox": "APNS_SANDBOX",
    "apnsVoip": "APNS_VOIP",
    "apnsVoipSandbox": "APNS_VOIP_SANDBOX",
    "macos": "MACOS",
    "macosSandbox": "MACOS_SANDBOX",
    "gcm": "GCM",
    "adm": "ADM",
    "baidu": "BAIDU",
    "mpns": "MPNS",
    "wns": "WNS"
};
