# Copyright (C) 2024 twyleg
function(simple_cpp_project_create_library target_name)

    set(options "")
    set(oneValueArgs
        ALIAS
    )
    set(multiValueArgs
        SOURCES
        HEADERS
        PROPERTIES
        INCLUDE_DIRECTORIES
        FIND_PACKAGES
        LINK_LIBRARIES
    )
    cmake_parse_arguments("" "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    message(CHECK_START "Creating Library: target_name=\"${target_name}\", alias=\"${_ALIAS}\"")

    if(CMAKE_MESSAGE_LOG_LEVEL MATCHES "VERBOSE|DEBUG|TRACE")
        include(CMakePrintHelpers)
        list(APPEND CMAKE_MESSAGE_INDENT "  ")

        cmake_print_variables(target_name)
        cmake_print_variables(_ALIAS)
        cmake_print_variables(_SOURCES)
        cmake_print_variables(_HEADERS)
        cmake_print_variables(_PROPERTIES)
        cmake_print_variables(_INCLUDE_DIRECTORIES)
        cmake_print_variables(_FIND_PACKAGES)
        cmake_print_variables(_LINK_LIBRARIES)

        list(POP_BACK CMAKE_MESSAGE_INDENT)
    endif()

    add_library(${target_name} ${_SOURCES} ${_HEADERS})
    add_library(${_ALIAS} ALIAS ${target_name})

    if(${CMAKE_VERSION} VERSION_GREATER_EQUAL "3.23.0")
        target_sources(${target_name}
            PUBLIC
                FILE_SET HEADERS
                    BASE_DIRS
                        ${_INCLUDE_DIRECTORIES}
                    FILES
                        ${_HEADERS}
        )
    endif()

    foreach(package IN LISTS _FIND_PACKAGES)
        string(REPLACE " " ";" find_command_list "${package}")
        find_package(${find_command_list})
    endforeach()

    set_target_properties(${target_name} PROPERTIES ${_PROPERTIES})
    target_link_libraries(${target_name} ${_LINK_LIBRARIES})


    target_include_directories(${target_name}
        PUBLIC "$<BUILD_INTERFACE:${_INCLUDE_DIRECTORIES}>"
    )

endfunction()


function(simple_cpp_project_create_application target_name)

    set(options "")
    set(oneValueArgs "")
    set(multiValueArgs
        SOURCES
        HEADERS
        PROPERTIES
        INCLUDE_DIRECTORIES
        FIND_PACKAGES
        LINK_LIBRARIES
    )
    cmake_parse_arguments("" "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    message(CHECK_START "Creating application: target_name=\"${target_name}\"")

    if(${CMAKE_MESSAGE_LOG_LEVEL} MATCHES "VERBOSE|DEBUG|TRACE")
        include(CMakePrintHelpers)
        list(APPEND CMAKE_MESSAGE_INDENT "  ")

        cmake_print_variables(target_name)
        cmake_print_variables(_SOURCES)
        cmake_print_variables(_HEADERS)
        cmake_print_variables(_PROPERTIES)
        cmake_print_variables(_INCLUDE_DIRECTORIES)
        cmake_print_variables(_FIND_PACKAGES)
        cmake_print_variables(_LINK_LIBRARIES)

        list(POP_BACK CMAKE_MESSAGE_INDENT)
    endif()

    add_executable(${target_name} ${_SOURCES} ${_HEADERS})

    foreach(package IN LISTS _FIND_PACKAGES)
        string(REPLACE " " ";" find_command_list "${package}")
        find_package(${find_command_list})
    endforeach()

    set_target_properties(${target_name} PROPERTIES ${_PROPERTIES})
    target_link_libraries(${target_name} ${_LINK_LIBRARIES})


    target_include_directories(${target_name}
        PUBLIC "$<BUILD_INTERFACE:${_INCLUDE_DIRECTORIES}>"
    )

endfunction()
