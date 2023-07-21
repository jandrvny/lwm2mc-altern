cmake_minimum_required(VERSION 3.13)

# This project is designed for POSIX systems
add_compile_definitions(_POSIX_C_SOURCE=200809)

add_subdirectory(client-wakaama)