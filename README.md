# lwm2mc-altern
___
*Alongside to an Itron intern project, this project aims to develop an LwM2M client based on an open SDK as an alternative to a current client developed with the IOWA SDK. This project was initiated as part of an internship at Itron.*
___
## Description

lwm2mc-altern project is associated with the Edge Gateway project, which aims to produce an LwM2M client for an embedded Linux-based edge gateway, enabling device management.

lwm2mc-altern aims to develop one or more LwM2M clients (mostly executable through the command line) based on an open-source SDK as an alternative to the current client developed with the commercial IOWA SDK. The objective is to have a client that offers the same functionalities as the current one.

Regarding the server side, the client is intended to work with Cumulocity, a platform that houses the LwM2M servers and an UI interface for device management, selected for the Edge Gateway project.

This repository provides the first alternative based on the Wakaama SDK, with its structure and functionality explained.

## Structure

The repository is structured as follows:

     +- libs/                   This directory contains all the library directories necessary 
     |    |                     for the operation of the existing client(s). These are mainly
     |    |                     integrated as submodules.
     |    |
     |    +- mbedtls/           This submodule directory is related to the Mbed-TLS library 
     |    |                     and contains the necessary files to be compiled. It enables 
     |    |                     adding security via DTLS to the UDP protocol used by LwM2M 
     |    |                     for communication.
     |    |
     |    +- wakaama/           This submodule directory is related to the Wakaama SDK and 
     |                          contains the files that need to be compiled for its usage. 
     |                          The file /libs/wakaama/wakaama.md provides an explanation 
     |                          of the SDK and its usage.
     |
     +- src/                    This directory contains the directories for the alternative
          |                     client(s) being developed. Each directory contains files
          |                     specific to the corresponding client.
          |
          +- wakaama-client/    This directory contains a client based on the Wakaama SDK.
                                For more information, refer to the file 
                                /src/client-wakaama/READ.me.
  

## Get started

To clone the repository for full use, use the following command:
```bash
git clone --recurse-submodules https://github.com/jandrvny/lwm2mc-altern.git
```
The project uses several submodules, and this command allows you to clone them along with the main project.

To learn how to launch the different existing LwM2M clients, refer to the README.md files in the corresponding directories.

**Note:**

If you're using WSL in your configuration, it's recommended to use the default terminal. Some inconsistencies have been observed.