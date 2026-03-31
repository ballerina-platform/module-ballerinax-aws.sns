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

import io.ballerina.runtime.api.creators.ErrorCreator;
import io.ballerina.runtime.api.creators.TypeCreator;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.types.MapType;
import io.ballerina.runtime.api.types.PredefinedTypes;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;
import software.amazon.awssdk.auth.credentials.AwsBasicCredentials;
import software.amazon.awssdk.auth.credentials.AwsCredentials;
import software.amazon.awssdk.auth.credentials.AwsCredentialsProvider;
import software.amazon.awssdk.auth.credentials.AwsSessionCredentials;
import software.amazon.awssdk.auth.credentials.DefaultCredentialsProvider;
import software.amazon.awssdk.auth.credentials.StaticCredentialsProvider;

/**
 * {@code CredentialProvider} resolves AWS credentials for the Ballerina AWS SNS connector.
 *
 * <p>Supports three credential sources:
 * <ul>
 *   <li>{@code StaticAuthConfig} – explicit access key / secret key / optional session token</li>
 *   <li>{@code ProfileAuthConfig} – named profile from an AWS credentials file</li>
 *   <li>{@code DEFAULT_CREDENTIALS} – AWS default credential provider chain (environment variables,
 *       ECS/EKS container credentials, EC2 instance profile, etc.)</li>
 * </ul>
 */
public class CredentialProvider {

    private static final BString ACCESS_KEY_ID = StringUtils.fromString("accessKeyId");
    private static final BString SECRET_ACCESS_KEY = StringUtils.fromString("secretAccessKey");
    private static final BString SESSION_TOKEN = StringUtils.fromString("sessionToken");
    private static final BString PROFILE_NAME = StringUtils.fromString("profileName");
    private static final BString CREDENTIALS_FILE_PATH = StringUtils.fromString("credentialsFilePath");

    private CredentialProvider() {}

    /**
     * Resolves AWS credentials from the given credential configuration.
     *
     * <p>The {@code bCredentials} parameter is the Ballerina value of the {@code credentials} field
     * in {@code ConnectionConfig}. It is one of:
     * <ul>
     *   <li>A {@link BString} with value {@code "DEFAULT_CREDENTIALS"}</li>
     *   <li>A {@link BMap} representing {@code StaticAuthConfig} (contains {@code accessKeyId})</li>
     *   <li>A {@link BMap} representing {@code ProfileAuthConfig} (contains {@code profileName})</li>
     * </ul>
     *
     * @param bCredentials the Ballerina credential configuration value
     * @return a {@link BMap} with {@code accessKeyId}, {@code secretAccessKey}, and optionally
     *         {@code sessionToken}; or a Ballerina {@link io.ballerina.runtime.api.values.BError}
     */
    @SuppressWarnings("unchecked")
    public static Object resolveCredentials(Object bCredentials) {
        try {
            AwsCredentialsProvider provider = buildProvider(bCredentials);
            AwsCredentials creds = provider.resolveCredentials();

            MapType mapType = TypeCreator.createMapType(PredefinedTypes.TYPE_ANYDATA);
            BMap<BString, Object> result = ValueCreator.createMapValue(mapType);
            result.put(ACCESS_KEY_ID, StringUtils.fromString(creds.accessKeyId()));
            result.put(SECRET_ACCESS_KEY, StringUtils.fromString(creds.secretAccessKey()));
            if (creds instanceof AwsSessionCredentials sessionCreds) {
                result.put(SESSION_TOKEN, StringUtils.fromString(sessionCreds.sessionToken()));
            }
            return result;
        } catch (Exception e) {
            return ErrorCreator.createError(
                    StringUtils.fromString("Failed to resolve AWS credentials: " + e.getMessage()));
        }
    }

    @SuppressWarnings("unchecked")
    private static AwsCredentialsProvider buildProvider(Object bCredentials) {
        if (bCredentials instanceof BString) {
            // DEFAULT_CREDENTIALS constant — use the full AWS credential provider chain
            return DefaultCredentialsProvider.create();
        }

        BMap<BString, Object> bAuthConfig = (BMap<BString, Object>) bCredentials;

        if (bAuthConfig.containsKey(ACCESS_KEY_ID)) {
            // StaticAuthConfig
            String accessKeyId = bAuthConfig.getStringValue(ACCESS_KEY_ID).getValue();
            String secretAccessKey = bAuthConfig.getStringValue(SECRET_ACCESS_KEY).getValue();
            AwsCredentials creds;
            if (bAuthConfig.containsKey(SESSION_TOKEN)) {
                String sessionToken = bAuthConfig.getStringValue(SESSION_TOKEN).getValue();
                creds = AwsSessionCredentials.create(accessKeyId, secretAccessKey, sessionToken);
            } else {
                creds = AwsBasicCredentials.create(accessKeyId, secretAccessKey);
            }
            return StaticCredentialsProvider.create(creds);
        }

        if (bAuthConfig.containsKey(PROFILE_NAME)) {
            // ProfileAuthConfig
            String profileName = bAuthConfig.getStringValue(PROFILE_NAME).getValue();
            String credentialsFilePath = bAuthConfig.getStringValue(CREDENTIALS_FILE_PATH).getValue();
            return ProfileAuthConfig.fromConfig(profileName, credentialsFilePath);
        }

        throw new IllegalArgumentException("Unsupported authentication configuration");
    }
}
