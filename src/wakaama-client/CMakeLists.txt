cmake_minimum_required(VERSION 3.13)

project(lwm2mclient)

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
    ${CMAKE_CURRENT_LIST_DIR}/lwm2mclient.cpp
    ${CMAKE_CURRENT_LIST_DIR}/lwm2mclient.hpp
    ${CMAKE_CURRENT_LIST_DIR}/system_api.cpp
    ${CMAKE_CURRENT_LIST_DIR}/object_security.cpp
    ${CMAKE_CURRENT_LIST_DIR}/object_server.cpp
    ${CMAKE_CURRENT_LIST_DIR}/object_device.cpp
    ${CMAKE_CURRENT_LIST_DIR}/object_firmware.cpp
    ${CMAKE_CURRENT_LIST_DIR}/object_location.cpp
    ${CMAKE_CURRENT_LIST_DIR}/object_connectivity_moni.cpp
    ${CMAKE_CURRENT_LIST_DIR}/object_connectivity_stat.cpp
    ${CMAKE_CURRENT_LIST_DIR}/object_access_control.cpp
)

# Client without DTLS support
add_executable(lwm2mclient
                ${SOURCES} 
                ${WAKAAMA_SOURCES} 
                ${COAP_SOURCES} 
                ${DATA_SOURCES} 
                ${TOOLS_SOURCES})
target_compile_definitions(lwm2mclient PUBLIC ${TOOLS_DEFINITIONS} LWM2M_CLIENT_MODE LWM2M_BOOTSTRAP LWM2M_SUPPORT_TLV)
target_sources_waakama(lwm2mclient)

# Client with DTLS support provided by mbedtls
add_executable(lwm2mclient_mbedtls
                ${SOURCES} 
                ${WAKAAMA_SOURCES} 
                ${COAP_SOURCES} 
                ${DATA_SOURCES} 
                ${TOOLS_SOURCES})
set_target_properties(lwm2mclient_mbedtls PROPERTIES DTLS "mbedtls")
target_compile_definitions(lwm2mclient_mbedtls PUBLIC ${TOOLS_DEFINITIONS} LWM2M_CLIENT_MODE LWM2M_BOOTSTRAP LWM2M_SUPPORT_TLV)
target_sources_waakama(lwm2mclient_mbedtls)

#SOURCE_GROUP(lwm2m-altern FILES ${WAKAAMA_SOURCES})