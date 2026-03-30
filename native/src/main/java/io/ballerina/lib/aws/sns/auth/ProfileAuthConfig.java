// Copyright (c) 2026 WSO2 LLC. (http://www.wso2.com).
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

package io.ballerina.lib.aws.sns.auth;

import software.amazon.awssdk.auth.credentials.AwsCredentialsProvider;
import software.amazon.awssdk.auth.credentials.ProfileCredentialsProvider;
import software.amazon.awssdk.profiles.ProfileFile;

import java.nio.file.Paths;

/**
 * {@code ProfileAuthConfig} provides a utility to create an AWS credentials provider
 * using a named profile from a specified AWS credentials file.
 *
 * <p>The credentials file should be in the standard AWS format, and the profile name
 * must exist in that file.
 */
public class ProfileAuthConfig {

    private ProfileAuthConfig() {}

    /**
     * Creates an {@link AwsCredentialsProvider} backed by the named profile in the given
     * credentials file.
     *
     * @param profileName         the AWS profile name (e.g. {@code "default"})
     * @param credentialsFilePath the absolute path to the AWS credentials file
     * @return an {@link AwsCredentialsProvider} for the specified profile
     */
    public static AwsCredentialsProvider fromConfig(String profileName, String credentialsFilePath) {
        String resolvedPath = credentialsFilePath.replaceFirst("^~", System.getProperty("user.home"));
        return ProfileCredentialsProvider.builder()
                .profileName(profileName)
                .profileFile(ProfileFile.builder()
                        .content(Paths.get(resolvedPath))
                        .type(ProfileFile.Type.CREDENTIALS)
                        .build())
                .build();
    }
}
