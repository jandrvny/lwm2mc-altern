# LwM2M client based on Wakaama SDK
___
*This file is part of the [lwm2mc-altern](https://github.com/jandrvny/lwm2mc-altern) project, developed during an internship at Itron.
By Jonathan Andrianarivony (jonathan.andrianarivony@itron.com).*
___

## Description

The following directory contains an LwM2M client based on the Wakaama SDK, developed as part of my internship project for the Edge Gateway project.

The developed client is compatible with embedded Linux (POSIX) platforms with limited resources. It can be executed from the command line and supports direct or bootstrap connections, with or without security.

The client includes the following objects:
+ Security Object (ID: 0)
+ Server Object (ID: 1)
+ Access Control Object (ID: 2)
+ Device Object (ID: 3)
+ Firmware Object (ID: 5) with a functional implementation of Firmware Upgrade Over The Air (FOTA).

It is executable with the following specific options:
+ **-n:** to configure the client's endpoint name.
<span style="color: green;">Default: ITRON_TEST_lwm2mc</span>
+ **-h:** to configure the LwM2M server's URI with its port.
<span style="color: green;">Default: coap://localhost:5683</span>
+ **-L:** to configure the logging level (DEBUG, INFO, WARNING, ERROR, CRITICAL).
<span style="color: green;">Default: INFO</span>
+ **-t:** to configure the frequency, in seconds, of the registration update message.
<span style="color: green;">Default: 60</span>

To implement the aforementioned functionalities, the client will need to use the following libraries:
>***COMPLETE THIS SECTION***


## Structure
>***COMPLETE THIS SECTION***

## Getting started
>***COMPLETE THIS SECTION***