# Ballerina Amazon SNS Connector

[![Build](https://github.com/ballerina-platform/module-ballerinax-aws.sns/workflows/CI/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-aws.sns/actions?query=workflow%3ACI)
[![codecov](https://codecov.io/gh/ballerina-platform/module-ballerinax-aws.sns/branch/main/graph/badge.svg)](https://codecov.io/gh/ballerina-platform/module-ballerinax-aws.sns)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/ballerina-platform/module-ballerinax-aws.sns.svg)](https://github.com/ballerina-platform/module-ballerinax-aws.sns/commits/master)
[![GraalVM Check](https://github.com/ballerina-platform/module-ballerinax-aws.sns/actions/workflows/build-with-bal-test-native.yml/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-aws.sns/actions/workflows/build-with-bal-test-native.yml)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

[Amazon SNS](https://aws.amazon.com/sns/) is a message notification service developed by Amazon.

This connector provides operations for connecting and interacting with Amazon SNS endpoints over the network. Its main capabilities are to define SNS topics, publish messages, and to subscribe email, sms and sqs etc. to SNS topics. Following modules are available in the connector. 

- [`aws.sns`](sns/Module.md)

## Building from the source
### Setting up the prerequisites

1. Download and install Java SE Development Kit (JDK) version 11. You can install either [OpenJDK](https://adoptopenjdk.net/) or [Oracle JDK](https://www.oracle.com/java/technologies/javase-jdk11-downloads.html).

    > **Note:** Set the JAVA_HOME environment variable to the path name of the directory in which you installed JDK.

2. Download and install [Ballerina Swan Lake](https://ballerina.io/). 

### Building the source
Execute the following commands to build from the source:

* To build the package:
    ```    
    bal pack ./sns
    ```
* To run tests after build:
    ```
    bal test ./sns
    ```
## Contributing to Ballerina
As an open source project, Ballerina welcomes contributions from the community. 

For more information, see the [Contribution Guidelines](https://github.com/ballerina-platform/ballerina-lang/blob/master/CONTRIBUTING.md).

## Code of conduct
All contributors are encouraged to read the [Ballerina Code of Conduct](https://ballerina.io/code-of-conduct).

## Useful links
* Discuss about code changes of the Ballerina project via [ballerina-dev@googlegroups.com](mailto:ballerina-dev@googlegroups.com).
* Chat live with us via our [Discord server](https://discord.gg/ballerinalang).
* Post all technical questions on Stack Overflow with the [#ballerina](https://stackoverflow.com/questions/tagged/ballerina) tag.
