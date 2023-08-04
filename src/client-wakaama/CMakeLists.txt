cmake_minimum_required(VERSION 3.13)

add_compile_options(-Wno-error=switch-default)
project(client C)
#set(CMAKE_CXX_STANDARD 14)

include(../../lwm2mc-altern.cmake)

set(SOURCES
    client.c
    client.h
    object_access_control.c
    object_device.c
    object_firmware.c
    object_security.c
    object_server.c
    system_api.c
)

# Client without DTLS support
add_executable(client ${SOURCES})
target_compile_definitions(client PRIVATE LWM2M_CLIENT_MODE LWM2M_BOOTSTRAP LWM2M_SUPPORT_TLV)
target_sources_wakaama(client)
target_sources_add(client)

# Client with DTLS support provided by tinydtls
#add_executable(client_tinydtls ${SOURCES})
#set_target_properties(client_tinydtls PROPERTIES DTLS "tinydtls")
#target_compile_definitions(client_tinydtls PRIVATE LWM2M_CLIENT_MODE LWM2M_BOOTSTRAP LWM2M_SUPPORT_TLV)
#target_sources_wakaama(client_tinydtls)
#target_sources_add(client_tinydtls)

# Client with DTLS support provided by mbedtls
add_executable(client_mbedtls ${SOURCES})
set_target_properties(client_mbedtls PROPERTIES DTLS "mbedtls")
target_compile_definitions(client_mbedtls PRIVATE LWM2M_CLIENT_MODE LWM2M_BOOTSTRAP LWM2M_SUPPORT_TLV)
target_sources_wakaama(client_mbedtls)
target_sources_add(client_mbedtls)