cmake_minimum_required(VERSION 3.16)

if (NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release CACHE STRING "Choose Debug or Release" FORCE)
endif()

project(cythgfx)

set(SOURCES
    main.c
)

add_subdirectory(third_party/raylib)
add_subdirectory(third_party/cyth)

add_executable(cythgfx ${SOURCES})

target_include_directories(cythgfx PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/third_party/raylib/src/external)
target_link_libraries(cythgfx PRIVATE raylib)
target_link_libraries(cythgfx PRIVATE libcyth)
