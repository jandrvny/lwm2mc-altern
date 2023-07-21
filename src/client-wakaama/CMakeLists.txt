cmake_minimum_required(VERSION 3.13)

project(client C)

include(../../lwm2mc-test.cmake)

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
target_sources_shared(client)

# Client with DTLS support provided by tinydtls
add_executable(client_tinydtls ${SOURCES})
set_target_properties(client_tinydtls PROPERTIES DTLS "tinydtls")
target_compile_definitions(client_tinydtls PRIVATE LWM2M_CLIENT_MODE LWM2M_BOOTSTRAP LWM2M_SUPPORT_TLV)
target_sources_wakaama(client_tinydtls)
target_sources_shared(client_tinydtls)