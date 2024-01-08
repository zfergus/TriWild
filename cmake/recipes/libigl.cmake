# libigl (https://github.com/libigl/libigl)
# License: MPL-2.0
if(TARGET igl::core)
    return()
endif()

message(STATUS "Third-party: creating target 'igl::core'")

include(CPM)
CPMAddPackage("gh:libigl/libigl@2.5.0")