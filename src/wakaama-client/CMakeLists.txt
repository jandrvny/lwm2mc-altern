cmake_minimum_required(VERSION 3.13)

project(lwm2mclient C)

add_subdirectory(tools)
include(${CMAKE_CURRENT_LIST_DIR}/../../lwm2mc-altern.cmake)

include_directories(
    ${WAKAAMA_HEADERS_DIR}
    ${CORE_HEADERS_DIR} 
    ${COAP_HEADERS_DIR} 
    ${DATA_HEADERS_DIR}  
    ${TOOLS_HEADERS_DIR} 
    ${CMAKE_CURRENT_LIST_DIR})

SET(SOURCES
    ${CMAKE_CURRENT_LIST_DIR}/lwm2mclient.c
    ${CMAKE_CURRENT_LIST_DIR}/lwm2mclient.h
    ${CMAKE_CURRENT_LIST_DIR}/system_api.c
    ${CMAKE_CURRENT_LIST_DIR}/object_security.c
    ${CMAKE_CURRENT_LIST_DIR}/object_server.c
    ${CMAKE_CURRENT_LIST_DIR}/object_device.c
    ${CMAKE_CURRENT_LIST_DIR}/object_firmware.c
    ${CMAKE_CURRENT_LIST_DIR}/object_location.c
    ${CMAKE_CURRENT_LIST_DIR}/object_connectivity_moni.c
    ${CMAKE_CURRENT_LIST_DIR}/object_connectivity_stat.c
    ${CMAKE_CURRENT_LIST_DIR}/object_access_control.c
)

# Client with DTLS support provided by mbedtls
add_executable(lwm2mclient
                ${SOURCES} 
                ${WAKAAMA_SOURCES} 
                ${COAP_SOURCES} 
                ${DATA_SOURCES} 
                ${TOOLS_SOURCES})
set_target_properties(lwm2mclient PROPERTIES DTLS "mbedtls")
target_compile_definitions(lwm2mclient PUBLIC ${TOOLS_DEFINITIONS} LWM2M_CLIENT_MODE LWM2M_BOOTSTRAP LWM2M_SUPPORT_TLV)
target_sources_waakama(lwm2mclient)

#SOURCE_GROUP(lwm2m-altern FILES ${WAKAAMA_SOURCES})