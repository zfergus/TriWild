# libigl (https://github.com/Yixin-Hu/aabbcc)
# License: zlib
if(TARGET aabbcc::aabbcc)
    return()
endif()

message(STATUS "Third-party: creating target 'aabbcc::aabbcc'")

include(CPM)
CPMAddPackage("gh:Yixin-Hu/aabbcc#7be592fba329ccfc806d8bf26675538ae5262947")

add_library(aabbcc_aabbcc ${aabbcc_SOURCE_DIR}/src/AABB.cc)
target_include_directories(aabbcc_aabbcc PUBLIC ${aabbcc_SOURCE_DIR}/src)

add_library(aabbcc::aabbcc ALIAS aabbcc_aabbcc)