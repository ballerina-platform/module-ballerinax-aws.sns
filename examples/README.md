# Examples

The `aws.sns` connector provides practical examples illustrating usage in various scenarios. Explore these [examples](https://github.com/ballerina-platform/module-ballerinax-aws.sns/tree/master/examples), covering use cases like creating a weather alert service.

1. [Weather alert service](https://github.com/ballerina-platform/module-ballerinax-aws.sns/tree/master/examples/weather-alert/main.bal)
    Send weather alerts for multiple cities. Users can subscribe to different cities to receive alerts for their city only.

## Prerequisites

1. Follow the [instructions](https://github.com/ballerina-platform/module-ballerinax-aws.sns#set-up-aws-sns-api) to set up the AWS SNS API.

2. For each example, create a `Config.toml` file with your access key ID, secret access key, and region. Here's an example of how your Config.toml` file should look:

    ```toml
    accessKeyId = "<your-access-key-id>"
    secretAccessKey = "<your-secret-access-key"
    region = "<aws-instance-region>"
    ```

## Running an Example

Execute the following commands to build an example from the source:

* To build an example:

    ```bash
    bal build
    ```

* To run an example:

    ```bash
    bal run
    ```

## Building the Examples with the Local Module

**Warning**: Due to the absence of support for reading local repositories for single Ballerina files, the Bala of the module is manually written to the central repository as a workaround. Consequently, the bash script may modify your local Ballerina repositories.

Execute the following commands to build all the examples against the changes you have made to the module locally:

* To build all the examples:

    ```bash
    ./build.sh build
    ```

* To run all the examples:

    ```bash
    ./build.sh run
    ```