# Wakaama notice
___
*This file is part of the [lwm2mc-altern](https://github.com/jandrvny/lwm2mc-altern) project, as a part of an Itron's intern project. 
Contributor(s):*
- *Jonathan Andrianarivony (jonathan.andrianarivony@itron.com).*
___

## Foreword

This document aims to be a practical guide to help approach the Eclipse Wakaama SDK, available on the following GitHub repository: 
> https://github.com/eclipse/wakaama

The objectives of this notice are as follows:
- To to review and supplement the existing documentation by providing remarks and observations made during the analysis of the code and documentation, and execution of examples.
- To facilitate the integration of the SDK in an LwM2M client project by offering practical advice and best found practices. This notice will be focused in that direction.

The document is based on personal exploration of the SDK as well as online comments.


>## Table of contents
>
>**I - Introduction**
>- Versions
>- Licenses
>- Warning
>
>**II - Implementation**
>- Repository structure
>- LwM2M Concepts and notions
>- Useful elements
>
>**III - Operation**
>- Requirements
>- Configuration and compilation
>- Example
>
>**IV - Usage**
>
>**Sources**


## I - Introduction

The LwM2M protocol is an open standard based on the CoAP protocol, which is a kind of lightweight version of the HTTP protocol. It is a RESTful protocol that uses the UDP protocol as a transport layer. It is designed to be used in constrained environments, such as IoT devices, and for seamless integration with existing systems. It provides security features and supports various network topologies (as long as it provides IP connectivity). One of the main advantages of LwM2M is its ability to handle both device management and application data using a unified solution.

Wakaama is the open-source SDK by Eclipse for building an LwM2M client and performing the associated interactions defined by the protocol. It is not a library, but rather files to be compiled with an application. These files are written in C and designed to be portable on POSIX-compliant systems.

This SDK is available in the following GitHub repository:
>https://github.com/eclipse/wakaama

### Versions

The SDK exits in two versions, Wakaama 0.5 (September 2017) and Wakaama 1.0 (December 2019), but only version 1.0 was officially released. It is also the latest version of the SDK.

Initially, the December 2019 release, Wakaama 1.0, supported LwM2M version 1.0 as defined by the OMA. However, the latest commits on the main branch of the repository now include support for LwM2M 1.1 and its functionalities.

### Licenses

Regarding the license of the SDK, it is governed by the terms of the Eclipse Distribution License 1.0 and the Eclipse Public License 2.0.
Those licenses are available a the following links:
+ https://www.eclipse.org/org/documents/edl-v10.php
+ https://www.eclipse.org/legal/epl-2.0/

### Warning

As mentioned in the GIT repository, the published version 1.0 of Wakaama is affected by several security issues (CVE-2019-9004, CVE-2021-41040).

+ **CVE-2019-9004:** In Eclipse Wakaama (formerly liblwm2m) 1.0, the file core/er-coap-13/er-coap-13.c in the lwm2mserver of the LWM2M server does not properly handle invalid options, leading to a memory leak. Processing a single maliciously modified packet results in a 24-byte memory leak. This can cause the LWM2M server to stop after exhausting all available memory.
+ **CVE-2021-41040:** In Eclipse Wakaama, from its inception until January 14, 2021, the CoAP parsing code does not properly sanitize network-received data.

Another warning from the repository:
+ Use the latest commit from the main branch (master) because version 1.0 is no longer supported.

## II - Implementation

### Repository structure

The SDK repository is structured as follows:

    -+- core                   (the LWM2M engine)
     |
     +- coap                   (CoAP stack adaptation)
     |    |
     |    +- er-coap-13        (Modified Erbium's CoAP engine from
     |                          https://web.archive.org/web/20180316172739/http://people.inf.ethz.ch/mkovatsc/erbium.php)
     |
     +- data                   (data formats serialization/deserialization)
     |
     +- tests                  (test cases)
     |    |
     |    +- integration       (pytest based integration tests implementing the OMA-ETS-LightweightM2M-V1_1-20190912-D specification
     |                          https://www.openmobilealliance.org/release/LightweightM2M/ETS/OMA-ETS-LightweightM2M-V1_1-20190912-D.pdf)
     |
     +- include                (provides the necessary abstraction elements to use the SDK)
     |
     +- examples
          |
          +- bootstrap_server  (a command-line LWM2M bootstrap server)
          |
          +- client            (a command-line LWM2M client with several test objects)
          |
          +- lightclient       (a very simple command-line LWM2M client with several test objects)
          |
          +- server            (a command-line LWM2M server)
          |
          +- shared            (utility functions for connection handling and command-
                                line interface)

Let's review the different directories:

+ ***core/:*** This directory contains the LwM2M engine that implements the specific functionalities of the LwM2M protocol, such as interfaces and mechanisms.
+ ***coap/:*** This directory hosts the CoAP engine that implements the specific functionalities of the CoAP protocol, which serves as the foundation for the LwM2M protocol.
+ ***data/:*** This directory contains the programs that handle data processing, including serialization/deserialization, encoding/decoding, and associated formats.
+ ***tests/:*** This directory contains the continuous integration (CI) tests for the various tools developed in the SDK.
+ ***tools/:*** This directory contains a script file used to run the unit tests.
+ ***examples/:*** This directory contains usage examples of the SDK that likely show how to implement some functionalities of the SDK.
+ ***include/:*** This directory contains the *liblwm2m.h* file, which defines the available abstraction functions for SDK users.

**Note:** Wakaama includes LwM2M servers in its examples to test the sample clients. Therefore, the SDK incorporates definitions (functions, structures, etc.) specific to the server.

### LwM2M Concepts and notions

In this section, we will delve into how the concepts and notions of LwM2M are implemented in Wakaama from the client side.

**Interfaces et transactions** 

Firstly, the interface concepts inherent to the protocol (sequences of messages exchanged between client and server) and certain mechanisms are encapsulated in the core/ directory. This directory includes the implementation of:
+ bootstrap
+ discover
+ management
+ observe
+ registration

It also includes other files that assist in their functioning. These files are not intended to be directly manipulated by the SDK user.

To simplify, Wakaama has a data structure called <span style="color: #4ec9b0;">*lwm2m_context_t*</span> to store the context associated with the LwM2M protocol. It declares different values depending on the defined mode. For our purpose, which is the Client mode, it includes the following:
+ ___lwm2m_client_state_t :___ the state of the client, represented by the enumerated type <span style="color: #4ec9b0;">*lwm2m_client_state_t*</span>
+ ___endpointName :___ the endpoint name of the client
+ ___msisdn :___ a field to store the client's phone number (Mobile Subscriber Integrated Services Digital Network Number)
+ ___altPath :___ an alternative path for requests to the LwM2M server
+ ___*bootstrapServerList :___ a list of bootstrap servers that the client can connect to for initializing its configuration
+ ___*serverList :___ a list of LwM2M servers to which the client is connected
+ ___*objectList :___ a list of objects exposed by the client
+ ___*observedList :___ a list of entities that are observed by other parties
+ ___nextMID :___ a counter used to generate unique message identifiers (MIDs - Message IDs) in transactions
+ ___*transactionList :___ a list of ongoing transactions, used to manage message exchanges with other parties
+ ___*userData :___ a pointer to data used to store application-specific information.

**Entities and data representation**

In its request and response transactions, the SDK uses its own data structure called <span style="color: #4ec9b0;">*lwm2m_data_t*</span> to handle data. It consists of the following:
+ ___type:___ specifies the entity type (undefined, object, object instance, multiple resources, etc.)
+ ___id:___ provides the ID of the entity
+ ___value:___ a generic variable (declared as a union) capable of storing data of different types (bool, int, float, array of <span style="color: #4ec9b0;">*lwm2m_data_t*</span>, etc.)

Regarding the entities inherent to LwM2M, the SDK provides several dedicated structures.Firstly, Wakaama defines a sorted linked list structure called <span style="color: #4ec9b0;">*lwm2m_list_t*</span>, which allows for creating a list of instances (object or resource instances). It also includes several functions for manipulating this list, using the associated head, node and/or ID, as follows:
+ LWM2M_LIST_ADD(H, N)
+ LWM2M_LIST_RM(H, I, N)
+ LWM2M_LIST_FIND(H, I)
+ LWM2M_LIST_FREE(H)

For objects, the structure is defined as <span style="color: #4ec9b0;">*lwm2m_object_t*</span> (available in the */include/liblwm2m.h* file). It includes the following:

+ ___*next:___ a pointer to the next object structure (used internally by the SDK)
+ ___objID:___ an ID assigned to the object
+ ___versionMajor___ and ___versionMinor:___ major and minor versions of the object
+ ___*instanceList:___ a list of associated instances using the lwm2m_list_t type
+ **pointers to callback functions:** associated with the possible operations on objects (read, write, execute, create, delete, discover)
+ ___*userData:___ a pointer to a data structure that stores information related to the object

Every object should include this structure in its implementation. 

An exception stands for the Server object, for which the SDK considers it unnecessary since its instances are not accessible by LwM2M servers. Therefore, the SDK provides the <span style="color: #4ec9b0;">*_server_instance_ structure*</span> in */examples/object_server.c* file for this object.

As for object instances, the user needs to define a custom structure that will hold the information contained in each object instance. These different instances will be stored as <span style="color: #4ec9b0;">*lwm2m_list_t*</span> in the associated object. Consulting the examples in */examples* folder can help clarify this.

Regarding resources, there are two possibilities:
+ If the resource is a single-instance resource, it can be directly included as a variable in the previous object instance structure.
+ If the resource can have multiple instances, it can be defined as an array of <span style="color: #4ec9b0;">*lwm2m_data_t*</span> structures.

### Useful elements

The *include/liblwm2M.h* file is the most interesting in the repository, providing abstraction functions, structures and definitions that can be implemented directly by the user. We have :

+ SDK **memory allocation** functions.
+ A function to retrieve the startup time (or the last time it was called).
+ Functions and definitions related to the **communication layer** for:
    + Managing connections and disconnections.
    + Managing sessions.
    + Setting the CoAP block size.
    + Defining CoAP error codes.
+ Definitions related to the **mandatory LwM2M objects and resources** to:
    + Define standard object IDs.
    + Define resource IDs for Security and Server objects.
+ Structures and functions related to **sorted linked lists** (for instances) to:
    + Define a linked list structure.
    + Manage the list and its elements.
+ Functions and definitions related to **URIs** for accessing entities to:
    + Define the maximum ID and maximum length for URIs.
    + Manage access to valid entities (in principle).
    + Define a URI structure.
    + Convert a string to a URI.
+ The definition of an **enumerated type for data** : <span style="color: #4ec9b0;">*lwm2m_data_type_t*</span>.
+ A generic **definition of an entity** named <span style="color: #4ec9b0;">*_lwm2m_data_t*</span> containing:
    + The type of entity (undefined, object, object instance, multiple resources, etc.).
    + Its ID.
    + A generic variable (declared as a union) to store bool, int, float, an array of _lwm2m_data_t, etc.
+ Functions and definitions related to **data format and processing** :
    + Defining data types (TLV, JSON, SENML_JSON...) with <span style="color: #4ec9b0;">*lwm2m_media_type_t*</span>.
    + Allocating and freeing space for data structure.
    + Serializing and deserializing data.
    + Reading and writing data into associated data structures.
+ A utility function for **parsing TLV buffers** and retrieving the type, ID, and data.
+ Definition of an **LwM2M object** named <span style="color: #4ec9b0;">*_lwm2m_object_t*</span> containing:
    + ID.
    + Minor and major version.
    + A list of associated object instances.
    + Callback functions for possible operations (read, write, execute, create, delete, discover).
    + User data.
+ General definitions related to **LwM2M objects**:
    + An enumerated type for possible writing operations (partial update, replace resources, and replace instance).
+ Definitions and enumerations related to **Server objects**:
    + Possible statuses.
    + Possible LwM2M versions.
    + Binding mode.
    + Structures for temporarily storing data needed to process requests and responses, including the final  <span style="color: #4ec9b0;">*lwm2m_block_data_t*</span> structure.
    + A concrete structure associated with the server object named <span style="color: #4ec9b0;">*lwm2m_server_t*</span>.
+ Definitions related to **server-side Observation**:
    + Defining the <span style="color: #4ec9b0;">*lwm2m_observation_t*</span> structure to store information related to the command.
    + Defining the signature of the associated callback function.
+ Definitions related to **client-side Observation**:
    + Defining the linked list structure <span style="color: #4ec9b0;">*lwm2m_watcher_t*</span> to store information related to the command for a given entity.
    + Defining the linked list structure <span style="color: #4ec9b0;">*lwm2m_observed_t*</span> to store observed entity.
+ Definitions related to the notion of **LwM2M Attributes**:
    + Defining the <span style="color: #4ec9b0;">*lwm2m_attributes_t*</span> structure.
+ Definitions related to the **LwM2M Client from server-side**:
    + Defining the <span style="color: #4ec9b0;">*lwm2m_client_object_t*</span> structure to store a list of client objects (not to be confused with <span style="color: #4ec9b0;">*lwm2m_object_t*</span>, which describes client-side objects).
    + Defining the <span style="color: #4ec9b0;">*lwm2m_client_t*</span> structure describing the client.
+ Definitions related to **CoAP transactions**:
    + Defining the <span style="color: #4ec9b0;">*lwm2m_transaction_t*</span> structure to store information related to the command.
    + Defining the signature of the associated callback function.
+ Definitions of the enumerated type <span style="color: #4ec9b0;">*lwm2m_client_state_t*</span> related to the **state on client mode**.
+ Functions and definitions related to the **operation of the SDK**, including:
    + The <span style="color: #4ec9b0;">*lwm2m_context_t*</span> structure, seen earlier, to store necessary information.
    + Various functions for client and server mode operations.


## III - Operation

Regarding its operation, Wakaama is single-threaded, meaning it runs with a single execution thread. This means that all operations and processing performed by Wakaama are executed sequentially, one at a time, without parallelism. There is no automatic management of multiple simultaneous threads to improve performance or distribute tasks across multiple processors or processor cores. This is a limitation of the SDK that must be taken into account when using it.

### Requirements

Regarding dependencies and tools, the following is requested:
+ Required:
    + C compiler: GCC or Clang
+ Optional:
    + Build system generator: CMake 3.13+
    + Version control system: Git (and a GitHub account)
    + Git commit message linter: gitlint
    + Build system: ninja
    + C code formatting: clang-format, version 14
    + CMake list files formatting: cmake-format, version 0.6.13
    + Unit testing: CUnit

On Ubuntu 20.04, the dependencies can be installed as follows:

```bash
apt install build-essential clang-format clang-format-14 clang-tools-14 cmake gcovr git libcunit1-dev ninja-build python3-pip
```
```bash
pip3 install -r tools/requirements-compliance.txt
```

Some compilation issues can be resolved by installing the following dependencies:
```bash
sudo apt install autoconf pkg-config
```

Regarding code formatting requirements, the repository requires the use of clang-format if you wish to contribute. It is recommended to follow these requirements when developing code using Wakaama for a product.

### Configuration and compilation

As mentioned before, Wakaama is not a library but rather files to be compiled with an application. For this purpose, Wakaama uses CMake, with a minimum version of 3.13. You can refer to the example file *examples/server/CMakeLists.txt* to see how to include it.

Several preprocessor definitions are supported:

|                             | MODE                                        | DESCRIPTION                                                                                                                                                                                                                                                               | DEFINED |
| --------------------------- | ------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| MSB FORMAT                  | LWM2M_BIG_ENDIAN                            | for a big endian platform                                                                                                                                                                                                                                                 | 1       |
| idem                        | LWM2M_LITTLE_ENDIAN                         | for a platform in little endian format | idem
| ENTITY MODE                 | LWM2M_CLIENT_MODE                           | activates LWM2M client interfaces                                                                                                                                                                                                                                         | 1 or +  |
| idem                        | LWM2M_SERVER_MODE                           | activates LWM2M server interfaces | idem
| idem                        | LWM2M_BOOTSTRAP_SERVER_MODE                 | activates LWM2M bootstrap server interfaces   | idem
|                             | LWM2M_BOOTSTRAP                             | enables LWM2M bootstrap support in an LWM2M client                                                                                                                                                                                                                        | 0 or 1  |
|                             | LWM2M_SUPPORT_TLV                           | enables support for TLV payloads (implicit, except for LWM2M 1.1 clients)                                                                                                                                                                                                 | 0 or 1  |
|                             | LWM2M_SUPPORT_JSON                          | enables support for JSON payloads (implicit when defining LWM2M_SERVER_MODE)                                                                                                                                                                                              | 0 or 1  |
|                             | LWM2M_SUPPORT_SENML_JSON                    | enables support for SenML JSON payloads (implicit for LWM2M 1.1 or higher when defining LWM2M_SERVER_MODE or LWM2M_BOOTSTRAP_SERVER_MODE).                                                                                                                                | 0 or 1  |
|                             | LWM2M_OLD_CONTENT_FORMAT_SUPPORT            | to support obsolete content format values for TLV and JSON                                                                                                                                                                                                                | 0 or 1  |
|                             | LWM2M_VERSION_1_0                           | to support version 1.0 only. By default, LWM2M version 1.1 is supported.<br>Note: Clients only support the specified version, while servers are backward-compatible.                                                                                                      | 0 or 1  |
|                             | LWM2M_RAW_BLOCK1_REQUESTS                   | allows each unprocessed block 1 payload to be transmitted to the application (usually for storage in flash memory).<br>For low-memory client devices where it is not possible to store in memory a large post or put request to be analyzed (typically a firmware write). | 0 or 1  |
|                             | LWM2M_COAP_DEFAULT_BLOCK_SIZE               | sets the CoAP block size used for block transfers.<br>Possible values: 16, 32, 64, 128, 256, 512 and 1024. The default value is 1024.                                                                                                                                     | 0 or 1  |

***Note:*** *Only one definition is possible for the MSB FORMAT (LWM2M_BIG_ENDIAN and LWM2M_LITTLE_ENDIAN) and the ENTITY MODE	(LWM2M_CLIENT_MODE, LWM2M_BOOTSTRAP and LWM2M_BOOTSTRAP_SERVER_MODE).*

## IV - Usage

In the following  section, we will focus on building a basic LwM2M client based on the Wakaama SDK. The objective is to provide a practical guide to help you get started with the SDK.

To build a client repository, it would be useful to separate files related to the SDK functionality from those specific to our client in separate directories. For example, the directories *"wakaama/"* and *"src/"* could be used for this purpose.

In the *"wakaama/"* directory, there are two options available:
+ The first option is to directly copy the necessary source files from the SDK into the repository. To do this, include the following directories, taken from the Wakaama git repository:
    + "coap": includes the CoAP layer
    + "core": includes the LWM2M engine
    + "include": contains the SDK's abstraction elements
    + "shared": located in the "/examples" directory, containing files for establishing a non-secure socket connection or a secure communication with DTLS using TinyDTLS.
+ The second option is integrating the SDK as a submodule to simplify the maintenance of your repository. In this case, the aforementioned directories are automatically present.

In the *"src/"* directory, place the source and header files of the client, as well as the source files of the objects presented by the client. Here are elements that sould exist:

+ The client source file should include:
    + All necessary functions for establishing (opening and closing) connections to LwM2M servers.
    + A main function with:
        + The definition and initiation of various structures and variables required (e.g., <span style="color: #4ec9b0;">*lwm2m_context_t*</span>, endPointName, lifetime, etc.) See the "Useful Elements" section.
        + A loop that manages the client's operation, mainly handling communications from the server.
        + At the end of the loop, free the used resources.
+ The client header file should include the declaration of public functions associated with the objects it integrates.
+ The source files of the objects supported by the client. Each object should be defined in a corresponding .c file (e.g., object_example.c) according to the implementation defined by Wakaama, as explained earlier. This file should include:
    + The definition of a data structure for an object instance. For practical reasons, this structure should contain:
        + A pointer to the next instance, which matches the declaration in the instance list of the  <span style="color: #4ec9b0;">*lwm2m_list_t*</span> object.
        + An instance ID, which matches the one declared in the instance list of the <span style="color: #4ec9b0;">*lwm2m_list_t*</span> object.
        + The definition of the object (Name, ID, Instances, Mandatory), at least as a comment.
        + The definition of its resources (Name, ID, Instances, Mandatory, Type, Range, Units, Description), at least as a comment.
        + Private functions to execute LwM2M operations, such as:
            + *prv_server_delete*
            + *prv_server_create*
            + *prv_get_value*
            + *prv_server_read*
            + *prv_server_discover*
            + *prv_server_write*
            + *prv_server_execute*
        + <span style="color: orange;">*lwm2m_object_t * get_example_object(void)*</span> : A public function to instantiate an example object of type <span style="color: #4ec9b0;">*lwm2m_object_t"*</span>, assign the previous functions to this object, and return a pointer to it.
        + <span style="color: orange;">*void free_example_object(lwm2m_object_t * object)*</span> : A public function to free the instance of the example object.
        + Optionally, a public function <span style="color: orange;">*void display_example_object(lwm2m_object_t * object)*</span> to display (fprintf) the content of the example object.

to compile all the files and generate the executable, create your CMakeLists.txt files based on the adopted structure, making sure to include the necessary definitions (discussed in the "Configuration and compilation" section).

In a more practical way, refer to how the SDK is implemented in the current project or, at a more basic level, the example directories provided in the SDK.


## Sources

+ https://projects.eclipse.org/projects/iot.wakaama
+ https://www.eclipse.org/wakaama/
+ https://github.com/eclipse/wakaama