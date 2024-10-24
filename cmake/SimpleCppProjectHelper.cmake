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


function(simple_cpp_project_get_version_from_git version_variable_name_full version_variable_name_short)
    # Check if we are in a git repository
    execute_process(
        COMMAND git rev-parse --is-inside-work-tree
        RESULT_VARIABLE is_git_repo
        OUTPUT_QUIET
        ERROR_QUIET
    )

    # Step 1: If we're not in a git repository, return the default version "0.0.0"
    if(NOT is_git_repo EQUAL 0)        
        set(${version_variable_name_short} 0.0.0 PARENT_SCOPE)
        set(${version_variable_name_full} 0.0.0 PARENT_SCOPE)
        return()
    endif()


    # Step 2: Get the most recent tag that matches semantic versioning (e.g., 0.0.0)
    execute_process(
        COMMAND git tag --list --sort=-v:refname "[0-9]*.[0-9]*.[0-9]*"
        OUTPUT_VARIABLE tags
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    # Step 3: Check if the tag list is empty
    if(tags STREQUAL "")
        set(latest_tag "0.0.0")
    else()
        # Split the tags list and get the latest one
        string(REPLACE "\n" ";" tag_list ${tags})
        list(GET tag_list 0 latest_tag)
    endif()

    # Step 4: Get the description based on the latest matching tag
    execute_process(
        COMMAND git describe --tags --match ${latest_tag}
        RESULT_VARIABLE describe_result
        OUTPUT_VARIABLE describe_output
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_QUIET
    )

    # Step 5: If no description is found, fallback to the tag
    if(NOT describe_result EQUAL 0)
        set(describe_output "${latest_tag}")
    endif()

    # Step 6: Append "-dirty" if there are uncommitted changes
    set(version_short "${latest_tag}")
    set(version_full "${describe_output}${dirty}")

    # Step 5: Return the version
    set(${version_variable_name_short} ${version_short} PARENT_SCOPE)
    set(${version_variable_name_full} ${version_full} PARENT_SCOPE)

endfunction()
