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
        return <Error>error("If content-based deduplication is enabled, it must also be a FIFO topic.");
    }
}

isolated function validatePublishParameters(string topicArn, TargetType targetType, string? groupId) returns Error? {
    // If the topic is a FIFO topic, then a group ID must be provided
    if (targetType is TOPIC && topicArn.endsWith(".fifo") && groupId == ()) {
        return <Error>error("A message published to a FIFO topic requires a group ID.");
    }
}
