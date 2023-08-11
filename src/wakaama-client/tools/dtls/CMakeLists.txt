cmake_minimum_required(VERSION 3.13)

include(${CMAKE_CURRENT_LIST_DIR}/../../../../lwm2mc-altern.cmake)

set(MBEDTLS_SOURCES_DIR "${MBEDTLS_DIRECTORY}")
set(MBEDTLS_BIN_DIR "${CMAKE_CURRENT_BINARY_DIR}/mbedtls")

# add config for mbedtls
add_compile_definitions(MBEDTLS_CONFIG_FILE="${CMAKE_CURRENT_LIST_DIR}/config-ccm-psk-dtls1_2.h")
add_subdirectory(${MBEDTLS_SOURCES_DIR} ${MBEDTLS_BIN_DIR}) # Tricks to make mbedtls build as a subdirectory
# add config for target which use mbedtls
target_compile_definitions(mbedtls PUBLIC MBEDTLS_CONFIG_FILE="${CMAKE_CURRENT_LIST_DIR}/config-ccm-psk-dtls1_2.h")