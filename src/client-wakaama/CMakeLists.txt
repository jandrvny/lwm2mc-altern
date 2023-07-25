cmake_minimum_required(VERSION 3.13)

project(client)
#set(CMAKE_CXX_STANDARD 14)

include(../../lwm2mc-altern.cmake)

set(SOURCES
    client.cpp
    client.hpp
    object_access_control.cpp
    object_device.cpp
    object_firmware.cpp
    object_security.cpp
    object_server.cpp
    system_api.cpp
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