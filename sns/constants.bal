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

const string AMAZON_AWS_HOST = "sns.amazonaws.com";
const string DEFAULT_REGION = "us-east-1";
const string EMPTY_STRING = "";
const string ACTION = "Action";
const string VERSION = "Version";
const string VERSION_NUMBER = "2010-03-31";
const string OPERATION_ERROR = "Error has occurred during an operation";
const string REQUEST_ERROR = "Error has occurred during request";

public enum Protocol {
    HTTP = "http",
    HTTPS = "https",
    EMAIL = "email",
    EMAIL_JSON = "email-json",
    SMS = "sms",
    SQS = "sqs",
    APPLICATION = "application",
    LAMBDA = "lambda",
    FIREHOSE = "firehose"
}
