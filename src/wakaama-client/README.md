# LwM2M client based on Wakaama SDK
___
*This file is part of the [lwm2mc-altern](https://github.com/jandrvny/lwm2mc-altern) project, as a part of an Itron's intern project.
Contributor(s):* 
- *Jonathan Andrianarivony (jonathan.andrianarivony@itron.com)*
___

## Description

The following directory contains an LwM2M client based on the Wakaama SDK, developed as part a internship project alongside to an Itron intern project.

Wakaama is an open-source SDK created by Eclipse to facilitate the development of an LwM2M client *(see the wakaama.md file for more information)*. In our current client, it is integrated as a submodule within the */libs/wakaama* directory.

The developed client is written in C++ and compatible with embedded Linux (POSIX) platforms. It can be executed from the command line and supports both direct connection and bootstrap, with or without security via DTLS connection with [Mbed-TLS](https://github.com/Mbed-TLS/mbedtls) library.

This work is mainly based on the examples provided in the [Wakaama](https://github.com/eclipse/wakaama) SDK's git repository, modified to meet the project's requirements. The code is under the Eclipse Public License v2.0 and Eclipse Distribution License v1.0, and is subject to the copyright indicated at the beginning of each file.

The client includes the necessary objects for the project:
+ **Security Object** (ID: 0)
+ **Server Object** (ID: 1)
+ **Access Control Object** Object (ID: 2)
+ **Device Object** (ID: 3)
+ **Firmware Object** (ID: 5) with a functional implementation of Firmware Upgrade Over The Air (FOTA).

In addition, it includes the following objects provided by the SDK:
+ **Connectivity monitoring Object** (ID: 4)
+ **Connectivity statistic Object** (ID: 7)
+ **Location Object** Object (ID: 6)


This client uses the following libraries:
+   [Mbed-TLS](https://github.com/Mbed-TLS/mbedtls): This library implements DTLS, adding security to the UDP layer. Instead of using the default TinyDTLS library provided by Wakaama, Mbed-TLS was implemented for maintenance and scalability reasons. It includes support for DTLS 1.3 and features introduced by DTLS extensions (e.g., Connection ID for improved performance by maintaining sessions with the server despite changes in IP address and network switching). This client version was built using Mbed-TLS version 3.4.1, integrated as a submodule.


>***COMPLETE THIS SECTION***


## Structure

     +- client-wakaama/         This directory contains the files related to the client 
          |                     based on the Wakaama SDK.
          |
          +- lwm2mclient.c/h    These files host the necessary code to operate the client
          |                     (contain the main function).
          |
          +- object.c files     These files host the necessary code to implement the LwM2M 
          |                     objects associated with the client.
          |
          +- tools/             This directory contains the code implementing MbedTLS 
                |               instead of TinyDTLS. The included files are based on the
                |               following branch, initiated by an issue ticket of Wakaama
                |               GitHub repository:
                |               https://github.com/LukasKarel/wakaama/tree/feature/mbedtls2
                |
                +- dtls/        This directory contains the necessary configuration files 
                                for MbedTLS.

## Getting started

### Dependencies and Tools

Before proceeding, please ensure that you have followed the instructions in the "Getting started" section of the README.md file at the root of the [lwm2mc-altern](https://github.com/jandrvny/lwm2mc-altern) project.

Also, be mindful of the requirements outlined in the "III-Operation" section of the *wakaama.md* file.

Using Mbed-TLS for security additionally requires the installation of the following module:
```bash
pip3 install jsonschema
```
Next, navigate to the /libs/wakaama directory and load the required submodules for Wakaama:
```bash
git submodule update --init --recursive
```

### Configuration

In the CMakeLists.txt file of the current directory, provide the appropriate compilation definitions within the <span style="color: orange;">*target_compile_definitions*</span> function. For more details, refer to the "Configuration and Compilation" section of the wakaama.md document.

If not specified, the MSB format will be automatically determined.  *LWM2M_COAP_DEFAULT_BLOCK_SIZE* is set to 1024 bytes if not specified otherwise to avoid block transfers in common use cases. The maximum buffer size that is provided for resource responses and must be respected due to the limited IP buffer. Larger data must be handled by the resource and will be sent chunk-wise through a TCP stream or CoAP blocks.

### Client launch

To build the client, follow these instructions:
+   Create a "build" directory at the root of the lwm2mc-altern project and change to that:
    ```bash
    mkdir build
    ```
    ```bash
    cd build
    ```
+   Execute the following commands to build the binary files:
    ```bash
    cmake [lwm2m-altern directory]/src/wakaama-client
    ```
    ```bash
    make
    ```

These instructions will build an LwM2M client named "lwm2mclient". Additionally, a DTLS-enabled variant named "lwm2mclient_mbedtls" will also be built alongside.

To launch the client, follow one of these instructions:
+   To launch the client, follow these instructions:
    ```bash
    ./lwm2mclient [Options]
    ```
+   To run the client with security, execute:
    ```bash
    ./lwm2mclient_mbedtls [Options]
    ```

Options are:
```
Usage: lwm2mclient [OPTION]
Launch a LWM2M client.
Options:
  -n NAME	Set the endpoint name of the Client. Default: testlwm2mclient
  -l PORT	Set the local UDP port of the Client. Default: 56830
  -h HOST	Set the hostname of the LWM2M Server to connect to. Default: localhost
  -p PORT	Set the port of the LWM2M Server to connect to. Default: 5683
  -4		Use IPv4 connection. Default: IPv6 connection
  -t TIME	Set the lifetime of the Client. Default: 300
  -b		Bootstrap requested.
  -c		Change battery level over time.
  -S BYTES	CoAP block size. Options: 16, 32, 64, 128, 256, 512, 1024. Default: 1024

```

Additional values for the lwm2mclient_tinydtls binary:
```
  -i Set the device management or bootstrap server PSK identity. If not set use none secure mode
  -s Set the device management or bootstrap server Pre-Shared-Key. If not set use none secure mode
```

Type 'help' for a list of supported commands.

**Notes:**

+ If you intend to modify the code, it's advisable to maintain the code format of the SDK for better readability and consistency (refer to the .clang-format file), as mentioned in the Wakaama documentation (wakaama.md).
To check if your code matches the expected style, the following commands are helpful:
    - `git clang-format-14 --diff`: Show what needs to be changed to match the expected code style
    - `git clang-format-14`: Apply all needed changes directly
    - `git clang-format-14 --commit master`: Fix code style for all changes since master

+ If you plan to add or remove objects, adjust the code accordingly:
    - lwm2mclient.c: Modify the OBJ_COUNT and objArray variables, as well as their initialization.
    - CMakeLists.txt: Add or remove the .c file(s) from the list of source files.
+ The Cumulo City servers default to handling data in TLV format, so be sure to consider this when making changes.