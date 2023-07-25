################################################################################
#########               WAKAAAMA CMake configuration                   ######### 
################################################################################

set(ROOT_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}")
set(SRC_DIRECTORY "${ROOT_DIRECTORY}/src")
set(WAKAAMA_DIRECTORY "${ROOT_DIRECTORY}/libs/wakaama")
set(WAKAAMA_TOOLS_DIRECTORY "${WAKAAMA_DIRECTORY}/examples/shared")

# Add data format source files to an existing target.
function(target_sources_data target)
    target_sources(
        ${target}
        PRIVATE ${WAKAAMA_DIRECTORY}/data/data.c ${WAKAAMA_DIRECTORY}/data/json.c
                ${WAKAAMA_DIRECTORY}/data/json_common.c ${WAKAAMA_DIRECTORY}/data/senml_json.c
                ${WAKAAMA_DIRECTORY}/data/tlv.c
    )
    # We should not (have to) do this!
    target_include_directories(${target} PRIVATE ${WAKAAMA_DIRECTORY}/coap)
endfunction()

# Add CoAP source files to an existing target.
function(target_sources_coap target)
    target_sources(
        ${target}
        PRIVATE ${WAKAAMA_DIRECTORY}/coap/block.c ${WAKAAMA_DIRECTORY}/coap/er-coap-13/er-coap-13.c
                ${WAKAAMA_DIRECTORY}/coap/transaction.c
    )
endfunction()

#### Add Wakaama source files to the target.

# The following definitions are needed and default values get applied if not set:
# - LWM2M_COAP_DEFAULT_BLOCK_SIZE
# - Either LWM2M_LITTLE_ENDIAN or LWM2M_BIG_ENDIAN

function(target_sources_wakaama target)
    target_sources(
    ${target}
    PRIVATE ${WAKAAMA_DIRECTORY}/core/bootstrap.c
            ${WAKAAMA_DIRECTORY}/core/discover.c
            ${WAKAAMA_DIRECTORY}/core/internals.h
            ${WAKAAMA_DIRECTORY}/core/liblwm2m.c
            ${WAKAAMA_DIRECTORY}/core/list.c
            ${WAKAAMA_DIRECTORY}/core/management.c
            ${WAKAAMA_DIRECTORY}/core/objects.c
            ${WAKAAMA_DIRECTORY}/core/observe.c
            ${WAKAAMA_DIRECTORY}/core/packet.c
            ${WAKAAMA_DIRECTORY}/core/registration.c
            ${WAKAAMA_DIRECTORY}/core/uri.c
            ${WAKAAMA_DIRECTORY}/core/utils.c
    )
    target_include_directories(${target} PRIVATE ${WAKAAMA_DIRECTORY}/include)
    target_include_directories(${target} PRIVATE ${WAKAAMA_DIRECTORY}/core)
    

    # Extract pre-existing target specific definitions WARNING: Directory properties are not taken into account!
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
        target_compile_definitions(${target} PRIVATE "LWM2M_COAP_DEFAULT_BLOCK_SIZE=${LWM2M_COAP_DEFAULT_BLOCK_SIZE}")
        message(STATUS "${target}: Default CoAP block size not set, using ${LWM2M_COAP_DEFAULT_BLOCK_SIZE}")
    endif()

    # Detect invalid configuration already during CMake run
    if(NOT CURRENT_TARGET_COMPILE_DEFINITIONS MATCHES "LWM2M_SERVER_MODE|LWM2M_BOOTSTRAP_SERVER_MODE|LWM2M_CLIENT_MODE")
        message(FATAL_ERROR "${target}: At least one mode (client, server, bootstrap server) must be enabled!")
    endif()

    target_sources_coap(${target})
    target_sources_data(${target})
endfunction()

##### Add shared source files to the target.
function(target_sources_shared target)
    get_target_property(TARGET_PROPERTY_DTLS ${target} DTLS)

    target_sources(
        ${target} PRIVATE ${WAKAAMA_TOOLS_DIRECTORY}/commandline.c
                          ${WAKAAMA_TOOLS_DIRECTORY}/platform.c
    )

    if(NOT TARGET_PROPERTY_DTLS)
        target_sources(${target} PRIVATE ${WAKAAMA_TOOLS_DIRECTORY}/connection.c)
    elseif(TARGET_PROPERTY_DTLS MATCHES "tinydtls")
        include(${WAKAAMA_TOOLS_DIRECTORY}/tinydtls.cmake)
        target_sources(${target} PRIVATE ${WAKAAMA_TOOLS_DIRECTORY}/dtlsconnection.c)
        target_compile_definitions(${target} PRIVATE WITH_TINYDTLS)
        target_sources_tinydtls(${target})
    else()
        message(FATAL_ERROR "${target}: Unknown DTLS implementation '${TARGET_PROPERTY_DTLS} requested")
    endif()

    target_include_directories(${target} PUBLIC ${WAKAAMA_TOOLS_DIRECTORY})
endfunction()

# Enforce a certain level of hygiene
add_compile_options(
    -Waggregate-return
    -Wall
    -Wcast-align
    -Wextra
    -Wfloat-equal
    -Wpointer-arith
    -Wshadow
    -Wswitch-default
    -Wwrite-strings
    -pedantic

    # Reduce noise: Unused parameters are common in this ifdef-littered code-base, but of no danger
    -Wno-unused-parameter
    # Reduce noise: Too many false positives
    -Wno-uninitialized

     # Turn (most) warnings into errors
    -Werror
    # Disabled because of existing, non-trivially fixable code
    -Wno-error=cast-align
)

# The maximum buffer size that is provided for resource responses and must be respected due to the limited IP buffer.
# Larger data must be handled by the resource and will be sent chunk-wise through a TCP stream or CoAP blocks. Block
# size is set to 1024 bytes if not specified otherwise to avoid block transfers in common use cases.
set(LWM2M_COAP_DEFAULT_BLOCK_SIZE
    1024
    CACHE STRING "Default CoAP block size; Used if not set on a per-target basis"
)
