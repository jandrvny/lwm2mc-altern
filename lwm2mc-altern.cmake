################################################################################
#########                           MAIN CMake                         ######### 
################################################################################

#===============================================================================
#
# This file is part of the lwm2mc-altern project
# (https://github.com/jandrvny/lwm2mc-altern), as a part of an Itron's intern 
# project. 
# Contributor(s) : 
# - Jonathan Andrianarivony (jonathan.andrianarivony@itron.com)
#
# The file contains all the necessary CMake functions and variables to compile
# all the LwM2M clients. See the README.md file for more information.
#
#===============================================================================

set(MBEDTLS_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}/libs/mbedtls")

#============================== WAKAAMA CLIENT ===============================#

set(WAKAAMA_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}/libs/wakaama")
set(WAKAAMA_CLIENT_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}/src/wakaama-client")
set(WAKAAMA_TOOLS_DIRECTORY "${WAKAAMA_CLIENT_DIRECTORY}/tools")


#########                      WAKAAMA CORE PART                      #########

# - Provides core source files and directory variables
set(WAKAAMA_CORE_DIRECTORY ${WAKAAMA_DIRECTORY}/core)
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

# - Add wakaama files and directory to an existing target.
function(target_sources_core target)
    target_sources(${target} PRIVATE ${WAKAAMA_SOURCES})
    # We should not (have to) do this!
    target_include_directories(${target} PRIVATE ${WAKAAMA_HEADERS_DIR})
    target_include_directories(${target} PRIVATE ${CORE_HEADERS_DIR})
endfunction()


#########                      WAKAAMA COAP PART                      #########

# - Provides coap source files and directory variables
set(WAKAAMA_COAP_DIRECTORY ${WAKAAMA_DIRECTORY}/coap)
set(COAP_SOURCES_DIR ${WAKAAMA_COAP_DIRECTORY})
set(COAP_HEADERS_DIR ${WAKAAMA_COAP_DIRECTORY})

set(COAP_SOURCES
    ${COAP_SOURCES_DIR}/transaction.c
    ${COAP_SOURCES_DIR}/block.c
    ${COAP_SOURCES_DIR}/er-coap-13/er-coap-13.c
)

# - Add coap files and directory to an existing target.
function(target_sources_coap target)
    target_sources(${target} PRIVATE ${COAP_SOURCES})
    # We should not (have to) do this!
    target_include_directories(${target} PRIVATE ${COAP_HEADERS_DIR})
endfunction()


#########                      WAKAAMA DATA PART                      #########

# - Provides data source files and directory variables
set(WAKAAMA_DATA_DIRECTORY ${WAKAAMA_DIRECTORY}/data)
set(DATA_SOURCES_DIR ${WAKAAMA_DATA_DIRECTORY})
set(DATA_HEADERS_DIR ${WAKAAMA_DATA_DIRECTORY})

set(DATA_SOURCES
    ${DATA_SOURCES_DIR}/data.c
    ${DATA_SOURCES_DIR}/tlv.c
    ${DATA_SOURCES_DIR}/json.c
    ${DATA_SOURCES_DIR}/senml_json.c
    ${DATA_SOURCES_DIR}/json_common.c
)

# - Add data files and directory to an existing target.
function(target_sources_data target)
    target_sources(${target} PRIVATE ${DATA_SOURCES})
    # We should not (have to) do this!
    target_include_directories(${target} PRIVATE ${DATA_HEADERS_DIR})
endfunction()


#########                      WAKAAMA TOOLS PART                     #########

# - Provides tools source files and directory variables
set(TOOLS_SOURCES_DIR ${WAKAAMA_TOOLS_DIRECTORY})
set(TOOLS_HEADERS_DIR ${WAKAAMA_TOOLS_DIRECTORY})

set(TOOLS_SOURCES 
    ${TOOLS_SOURCES_DIR}/commandline.c
    ${TOOLS_SOURCES_DIR}/platform.c
    ${TOOLS_SOURCES_DIR}/connection.c
    ${TOOLS_SOURCES_DIR}/object_utils.c
)

#set(TOOLS_DEFINITIONS "")
#if(DTLS_MBEDTLS)
#    list(APPEND TOOLS_SOURCES ${TOOLS_SOURCES_DIR}/mbedtlsconnection.c)
#    list(APPEND TOOLS_DEFINITIONS DTLS)
#    link_libraries(mbedtls)
#endif()

# - Add tools files and directory to an existing target.
function(target_sources_tool target)
    target_sources(${target} PRIVATE ${TOOLS_SOURCES})
    # We should not (have to) do this!
    target_include_directories(${target} PRIVATE ${TOOLS_HEADERS_DIR})

    get_target_property(TARGET_PROPERTY_DTLS ${target} DTLS)

    if(NOT TARGET_PROPERTY_DTLS)
    elseif(TARGET_PROPERTY_DTLS MATCHES "mbedtls")
        target_sources(${target} PRIVATE ${TOOLS_SOURCES_DIR}/mbedtlsconnection.c)
        target_compile_definitions(${target} PRIVATE DTLS)
        target_link_libraries(${target} PRIVATE mbedtls)    
    else()
        message(FATAL_ERROR "${target}: Unknown DTLS implementation '${TARGET_PROPERTY_DTLS} requested")
    endif()

endfunction()


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


#########                      COMPLETE WAKAAMA                      #########

# - Does necessary operations to compile the target
function(target_sources_waakama target)
    target_sources_core(${target})
    target_sources_coap(${target})
    target_sources_data(${target})
    target_sources_tool(${target})
    target_compile_definitions_verif(${target})
endfunction()


#target_link_libraries(${PROJECT_NAME} PRIVATE mbedtls)