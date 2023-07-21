# lwm2mc-altern
___
*As part of my internship at Itron, this project aims to develop an LwM2M client based on an open SDK as an alternative to the current client developed with the IOWA SDK.*
___
## Description

lwm2mc-altern is a project developed during my internship at Itron. It is associated with the Edge Gateway project, which aims to produce an LwM2M client for an embedded Linux-based edge gateway, enabling device management.

lwm2mc-altern aims to develop one or more LwM2M clients (mostly executable through the command line) based on an open-source SDK as an alternative to the current client developed with the IOWA SDK. The objective is to have a client that offers the same functionalities as the current one.

Regarding the server side, the client is intended to work with Cumulocity, a platform that also facilitates device management, selected for the Edge Gateway project.

This repository provides the first alternative based on the Wakaama SDK, with its structure and functionality explained.

## Structure

The repository is structured as follows:

     +- libs                    (This directory contains all the files to be compiled from  
     |    |                     all the LwM2M SDKs used to develop the existing client(s))
     |    |
     |    +- wakaama            (This directory is related to the Wakaama SDK and contains
     |                          the files that need to be compiled for its usage. 
     |                          The file /libs/wakaama/wakaama.md provides an explanation 
     |                          of the SDK and its usage.)
     |
     +- src                     (This directory contains the directories for the alternative
          |                     client(s) being developed. Each directory contains files
          |                     specific to the corresponding client.)
          |
          +- client-wakaama     (This directory contains a client based on the Wakaama SDK.
                                For more information, refer to the file 
                                /src/client-wakaama/READ.me.)
  



