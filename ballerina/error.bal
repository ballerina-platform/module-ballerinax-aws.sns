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

# Reperesents the generic error type for the `aws.sns` module.
public type Error distinct error;

# Represents an error that occurs when generating an API request.
public type GenerateRequestFailed distinct Error;

# Represents an error that occurs when the API action cannot be completed due to user error.
public type OperationError distinct Error;

# Represents an error that occurs when the API response is in an unexpected format.
public type ResponseHandleFailedError distinct Error;

# Represents an error that occurs when calculating the signature.
public type CalculateSignatureFailedError distinct Error;

# Represents an error that occurs when the API action cannot be completed due to an unknown server error.
public type InternalError distinct Error;

const string GENERATE_REQUEST_FAILED_MSG = "Error occurred while generating POST request.";
const string NO_CONTENT_SET_WITH_RESPONSE_MSG = "No Content was sent with the response.";
const string ERROR_OCCURRED_WHILE_INVOKING_REST_API_MSG = "Error occurred while invoking the REST API.";
