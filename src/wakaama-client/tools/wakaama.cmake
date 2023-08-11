################################################################################
#########                        WAKAAAMA CMake                        ######### 
################################################################################

#===============================================================================
#
# This file is This file is part of the lwm2mc-altern project
# (https://github.com/jandrvny/lwm2mc-altern), as a part of an Itron's intern 
# project. 
# Contributor : Jonathan Andrianarivony (jonathan.andrianarivony@itron.com)
#
# The file contains all the necessary CMake functions and variables to compile
# the LwM2M client based on the Wakaama SDK, implementing DTLS security layer
# with MbeDTLS. See the README.md file for more information.
#===============================================================================


#########                      WAKAAMA CORE PART                      #########

# - Provides core source files and directory variables
set(WAKAAMA_CORE_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/../../../libs/wakaama/core)
set(CORE_SOURCES_DIR ${WAKAAMA_CORE_DIRECTORY})
set(CORE_HEADERS_DIR ${WAKAAMA_CORE_DIRECTORY})
set(WAKAAMA_HEADERS_DIR ${WAKAAMA_CORE_DIRECTORY}/../include)

set(WAKAAMA_SOURCES
    ${CORE_SOURCES_DIR}/liblwm2m.c
    ${CORE_SOURCES_DIR}/uri.c
    ${CORE_SOURCES_DIR}/utils.c
    ${CORE_SOURCES_DIR}/objects.c
    ${CORE_SOURCES_DIR}/list.c
    ${CORE_SOURCES_DIR}/packet.c
    ${CORE_SOURCES_DIR}/registration.c
    ${CORE_SOURCES_DIR}/bootstrap.c
    ${CORE_SOURCES_DIR}/management.c
    ${CORE_SOURCES_DIR}/observe.c
    ${CORE_SOURCES_DIR}/discover.c
    ${CORE_SOURCES_DIR}/internals.h
)

#########                      WAKAAMA COAP PART                      #########

# - Provides coap source files and directory variables
set(WAKAAMA_COAP_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/../../../libs/wakaama/coap)
set(COAP_SOURCES_DIR ${WAKAAMA_COAP_DIRECTORY})
set(COAP_HEADERS_DIR ${WAKAAMA_COAP_DIRECTORY})

set(COAP_SOURCES
    ${COAP_SOURCES_DIR}/transaction.c
    ${COAP_SOURCES_DIR}/block.c
    ${COAP_SOURCES_DIR}/er-coap-13/er-coap-13.c
)


#########                      WAKAAMA DATA PART                      #########

# - Provides data source files and directory variables
set(WAKAAMA_DATA_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/../../../libs/wakaama/data)
set(DATA_SOURCES_DIR ${WAKAAMA_DATA_DIRECTORY})
set(DATA_HEADERS_DIR ${WAKAAMA_DATA_DIRECTORY})

set(DATA_SOURCES
    ${DATA_SOURCES_DIR}/data.c
    ${DATA_SOURCES_DIR}/tlv.c
    ${DATA_SOURCES_DIR}/json.c
    ${DATA_SOURCES_DIR}/senml_json.c
    ${DATA_SOURCES_DIR}/json_common.c
)

#########                      WAKAAMA TOOLS PART                     #########

# - Provides tools source files and directory variables
set(WAKAAMA_TOOLS_DIRECTORY ${CMAKE_CURRENT_LIST_DIR})
set(TOOLS_SOURCES_DIR ${WAKAAMA_TOOLS_DIRECTORY})
set(TOOLS_HEADERS_DIR ${WAKAAMA_TOOLS_DIRECTORY})

set(TOOLS_SOURCES 
    ${TOOLS_SOURCES_DIR}/commandline.c
    ${TOOLS_SOURCES_DIR}/platform.c
    ${TOOLS_SOURCES_DIR}/connection.c
    ${TOOLS_SOURCES_DIR}/object_utils.c
)

set(TOOLS_DEFINITIONS "")
if(DTLS_MBEDTLS)
    list(APPEND TOOLS_SOURCES ${TOOLS_SOURCES_DIR}/mbedtlsconnection.c)
    list(APPEND TOOLS_DEFINITIONS DTLS)
    link_libraries(mbedtls)
endif()

#     target_link_libraries(${PROJECT_NAME} PRIVATE mbedtls)


#########                        VERIFICATION                        #########

# - Sets default CoAP Block size to 1024 bytes
set(LWM2M_COAP_DEFAULT_BLOCK_SIZE
    1024
    CACHE STRING "Default CoAP block size; Used if not set on a per-target basis"
)

# - Does necessary compile definition verifications on the target
function(target_compile_definitions_verif target)
     # Extract pre-existing target specific definitions 
     # WARNING: Directory properties are not taken into account!
     get_target_property(CURRENT_TARGET_COMPILE_DEFINITIONS ${target} COMPILE_DEFINITIONS)

     if(NOT CURRENT_TARGET_COMPILE_DEFINITIONS MATCHES "LWM2M_LITTLE_ENDIAN|LWM2M_BIG_ENDIAN")
         # Replace TestBigEndian once we require CMake 3.20+
         include(TestBigEndian)
         test_big_endian(machine_is_big_endian)
         if(machine_is_big_endian)
             target_compile_definitions(${target} PRIVATE LWM2M_BIG_ENDIAN)
             message(STATUS "${target}: Endiannes not set, defaulting to big endian")
         else()
             target_compile_definitions(${target} PRIVATE LWM2M_LITTLE_ENDIAN)
             message(STATUS "${target}: Endiannes not set, defaulting to little endian")
         endif()
     endif()
 
     # LWM2M_COAP_DEFAULT_BLOCK_SIZE is needed by source files -> always set it
     if(NOT CURRENT_TARGET_COMPILE_DEFINITIONS MATCHES "LWM2M_COAP_DEFAULT_BLOCK_SIZE=")
         target_compile_definitions(${target} 
                                    PRIVATE "LWM2M_COAP_DEFAULT_BLOCK_SIZE=${LWM2M_COAP_DEFAULT_BLOCK_SIZE}")
         message(STATUS "${target}: Default CoAP block size not set, using ${LWM2M_COAP_DEFAULT_BLOCK_SIZE}")
     endif()
 
     # Detect invalid configuration already during CMake run
     if(NOT CURRENT_TARGET_COMPILE_DEFINITIONS 
        MATCHES "LWM2M_SERVER_MODE|LWM2M_BOOTSTRAP_SERVER_MODE|LWM2M_CLIENT_MODE")
         message(FATAL_ERROR "${target}: At least one mode (client, server, bootstrap server) must be enabled!")
     endif()

endfunction()
