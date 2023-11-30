## Prerequisites for Running Tests

Before running the tests, ensure you have the following prerequisites in place, including an AWS account and the necessary authentication credentials. You can set up these credentials either in a `Config.toml` file within the tests directory or as environment variables.

### Using a Config.toml File

Create a `Config.toml` file in the tests directory and include your authentication credentials and tokens for the authorized user:

```toml
accessKeyId = "<your-access-key-id>"
secretAccessKey = "<your-secret-access-key"
region = "<aws-instance-region>"
testIamRole = "<test-iam-role>"
testAwsAccountId = "<aws-account-id>"
admClientId = "<adm-client-id>" #used for platform application tests
admClientSecret = "<adm-client-secret>" #used for platform application tests
```

### Using Environment Variables

Alternatively, you can set your authentication credentials as environment variables:
```bash
export ACCESS_KEY_ID="<your-access-key-id>"
export SECRET_ACCESS_KEY="<your-secret-access-key>"
export REGION="<aws-instance-region>"
export TEST_IAM_ROLE="<test-iam-role>"
export AWS_ACCOUNT_ID="<aws-account-id>"
export ADM_CLIENT_ID="<adm-client-id>" #used for platform application tests
export ADM_CLIENT_SECRET="<adm-client-secret>" #used for platform application tests
```