# Change Log
This file contains all the notable changes done to the Ballerina AWS SNS package through the releases.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

This release revamps the connector's authentication and region configuration to use the shared
[`ballerinax/aws`](https://github.com/ballerina-platform/module-ballerinax-aws) package, so that all AWS
connectors share a single, consistent credential model.
([Revamp Connector Authentication Flow](https://github.com/wso2-enterprise/integration-engineering/issues/2105))

It contains breaking changes. See the "Migrating from 3.x" section below.

### Changed
- **[Breaking]** Credentials are now supplied through a single `ConnectionConfig.auth` field of type
  `auth:AuthConfig`, sourced from `ballerinax/aws.auth` instead of being defined locally by this package.
  In 3.x, `auth` was declared `never` and credentials were passed as the flat `accessKeyId`,
  `secretAccessKey` and `securityToken` fields. Every 3.x credential source remains supported, with six
  new ones added.
- **[Breaking]** `ConnectionConfig` no longer includes `ballerinax/client.config:ConnectionConfig`. The
  HTTP configuration fields are now declared directly on the record, which additionally makes
  `socketConfig`, `validation` and `laxDataBinding` available.
- The `ConnectionConfig.region` field type changed from `string` to `aws:Region|string`, and its default
  changed from the `"us-east-1"` string literal to `aws:US_EAST_1`. This is a widening — plain region
  strings continue to work, so regions that are not yet present in the `aws:Region` enum can still be
  supplied directly.
- Temporary credentials (STS assume-role, SSO, container and instance profiles) are now refreshed
  transparently by the credential provider, instead of the connector holding a single set of keys
  resolved at initialization time.
- The package now requires Ballerina distribution `2201.12.0` (was `2201.11.0`).

### Removed
- **[Breaking]** The `ConnectionConfig.accessKeyId`, `ConnectionConfig.secretAccessKey` and
  `ConnectionConfig.securityToken` fields have been removed in favour of `ConnectionConfig.auth`.

### Added
- Support for six additional AWS credential sources, available through `auth:AuthConfig`:
  - `auth:ProfileAuthConfig` — credentials read from a named profile in the shared credentials file.
  - `auth:AssumeRoleConfig` — temporary credentials obtained by assuming an IAM role via AWS STS.
  - `auth:WebIdentityConfig` — web identity (OIDC) federation, including IAM Roles for Service Accounts (IRSA).
  - `auth:SsoAuthConfig` — AWS IAM Identity Center (SSO).
  - `auth:ProcessAuthConfig` — credentials sourced from an external credential process.
  - `auth:DEFAULT_CREDENTIALS` — the AWS default credential provider chain.
- A new optional `ConnectionConfig.endpoint` field of type `aws:EndpointConfig`, for selecting FIPS or
  dualstack endpoint variants and for overriding the endpoint entirely (for example, LocalStack or VPC
  interface endpoints).
- A `Client.close()` method that releases the resources held by the credential provider (background
  refresh threads and any HTTP connections opened for STS/SSO). It is a normal method rather than a
  remote method, since closing the client does not send a request to SNS.

### Migrating from 3.x

Add an `import ballerinax/aws;` alongside the existing SNS import, and move the credential fields under
`auth`:

```ballerina
// 3.x
import ballerinax/aws.sns;

sns:ConnectionConfig config = {
    accessKeyId,
    secretAccessKey,
    region: "us-east-1"
};
```

```ballerina
// 4.0.0
import ballerinax/aws;
import ballerinax/aws.sns;

sns:ConnectionConfig config = {
    auth: {accessKeyId, secretAccessKey},
    region: aws:US_EAST_1
};
```

Temporary credentials move from the top-level `securityToken` field to `sessionToken` inside `auth`:

```ballerina
// 3.x
sns:ConnectionConfig config = {
    accessKeyId,
    secretAccessKey,
    securityToken,
    region: "us-east-1"
};
```

```ballerina
// 4.0.0
sns:ConnectionConfig config = {
    auth: {accessKeyId, secretAccessKey, sessionToken},
    region: aws:US_EAST_1
};
```

Deployments that should resolve credentials from the environment rather than from hardcoded keys can now
use the default credential provider chain:

```ballerina
// 4.0.0
import ballerinax/aws;
import ballerinax/aws.auth;

sns:ConnectionConfig config = {
    auth: auth:DEFAULT_CREDENTIALS,
    region: aws:US_EAST_1
};
```

## [2.2.0] - 2023-09-26

### Added

### Changed
- [Revamp of the connector](https://github.com/ballerina-platform/ballerina-standard-library/issues/4846)
