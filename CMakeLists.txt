# Detects whether this is a top-level project
get_directory_property(HAS_PARENT PARENT_DIRECTORY)
if(HAS_PARENT)
  set(TRIWILD_TOPLEVEL_PROJECT OFF)
else()
  set(TRIWILD_TOPLEVEL_PROJECT ON)
endif()

# Check required CMake version
set(REQUIRED_CMAKE_VERSION "3.18.0")
if(TRIWILD_TOPLEVEL_PROJECT)
  cmake_minimum_required(VERSION ${REQUIRED_CMAKE_VERSION})
else()
  # Don't use cmake_minimum_required here to avoid implicitly overriding parent policies
  if(${CMAKE_VERSION} VERSION_LESS ${REQUIRED_CMAKE_VERSION})
    message(FATAL_ERROR "CMake required version to build TriWild is ${REQUIRED_CMAKE_VERSION}")
  endif()
endif()

# Include user-provided default options if available. We do that before the main
# `project()` so that we can define the C/C++ compilers from the option file.
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/TriWildOptions.cmake)
  message(STATUS "Using local options file: ${CMAKE_CURRENT_SOURCE_DIR}/TriWildOptions.cmake")
  include(${CMAKE_CURRENT_SOURCE_DIR}/TriWildOptions.cmake)
endif()

# Enable ccache if available
find_program(CCACHE_PROGRAM ccache)
if(CCACHE_PROGRAM)
  option(TRIWILD_WITH_CCACHE "Enable ccache when building TriWild" ${TRIWILD_TOPLEVEL_PROJECT})
else()
  option(TRIWILD_WITH_CCACHE "Enable ccache when building TriWild" OFF)
endif()
if(TRIWILD_WITH_CCACHE AND CCACHE_PROGRAM)
  message(STATUS "Enabling Ccache support (${CCACHE_PROGRAM})")
  set(ccacheEnv
    CCACHE_BASEDIR=${CMAKE_BINARY_DIR}
    CCACHE_SLOPPINESS=clang_index_store,include_file_ctime,include_file_mtime,locale,pch_defines,time_macros
  )
  foreach(lang IN ITEMS C CXX)
    set(CMAKE_${lang}_COMPILER_LAUNCHER
      ${CMAKE_COMMAND} -E env ${ccacheEnv} ${CCACHE_PROGRAM}
    )
  endforeach()
endif()

################################################################################
# CMake Policies
################################################################################

cmake_policy(SET CMP0054 NEW) # Only interpret if() arguments as variables or keywords when unquoted.
cmake_policy(SET CMP0076 NEW) # target_sources() command converts relative paths to absolute.
if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.24")
  cmake_policy(SET CMP0135 NEW) # Set the timestamps of all extracted contents to the time of the extraction.
endif()

################################################################################

project(TriWild
		LANGUAGES C CXX)

list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake/triwild/")
list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake/recipes/")
list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake/find/")

# General CMake utils
include(triwild_cpm_cache)

# Build static binaries
#set(BUILD_SHARED_LIBS OFF)
set(BUILD_STATIC_RUNTIME OFF)
set(BUILD_DYNAMIC_RUNTIME ON)

# Use folder in Visual Studio
set_property(GLOBAL PROPERTY USE_FOLDERS ON)

# Export compile flags (used for autocompletion of the C++ code)
set(CMAKE_EXPORT_COMPILE_COMMANDS 1)

# Generate position independent code
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

#ADD_DEFINITIONS("-D_DLL")

################################################################################
# TriWild Library
################################################################################

add_library(triwild_lib
	src/triwild/Logger.h
	src/triwild/Args.cpp src/triwild/Args.h
	src/triwild/meshio.hpp src/triwild/meshio.cpp

	src/triwild/auto_p_bases.hpp src/triwild/auto_p_bases.cpp
	src/triwild/auto_det_checker.hpp src/triwild/auto_det_checker.cpp
	src/triwild/Curves.h src/triwild/Curves.cpp
	src/triwild/CurvedTriUntangler.hpp src/triwild/CurvedTriUntangler.cpp

	src/triwild/Rational.h
	src/triwild/Point_2.h src/triwild/Point_2f.h
	src/triwild/TrimeshElements.h
	src/triwild/triangulation.cpp src/triwild/triangulation.h
	src/triwild/AMIPS.h src/triwild/AMIPS.cpp
	src/triwild/optimization.cpp src/triwild/optimization.h
	src/triwild/edge_collapsing.cpp src/triwild/edge_collapsing.h
	src/triwild/edge_splitting.cpp src/triwild/edge_splitting.h
	src/triwild/edge_swapping.cpp src/triwild/edge_swapping.h
	src/triwild/vertex_smoothing.cpp src/triwild/vertex_smoothing.h

	src/triwild/FeatureElements.cpp src/triwild/FeatureElements.h
	src/triwild/feature_preprocessing.cpp src/triwild/feature_preprocessing.h
	src/triwild/feature.cpp src/triwild/feature.h

	src/triwild/reference_triangle.cpp src/triwild/reference_triangle.h
	src/triwild/do_triwild.cpp src/triwild/do_triwild.h

	# --- External but included in the repo ------------------------------------
	extern/pymesh/MshLoader.h extern/pymesh/MshLoader.cpp
	extern/pymesh/MshSaver.h extern/pymesh/MshSaver.cpp
	extern/pymesh/Exception.h
	extern/CLI11.hpp
)
add_library(triwild::triwild ALIAS triwild_lib)

target_include_directories(triwild_lib PUBLIC "src")

target_compile_definitions(triwild_lib PRIVATE _REF_VS=\"${CMAKE_CURRENT_SOURCE_DIR}/src/triwild/reference_triangle_vertices.txt\")
target_compile_definitions(triwild_lib PRIVATE _REF_FS=\"${CMAKE_CURRENT_SOURCE_DIR}/src/triwild/reference_triangle_faces.txt\")

if(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
	target_compile_definitions(triwild_lib PRIVATE _ENABLE_EXTENDED_ALIGNED_STORAGE)
endif()

################################################################################
# Dependencies
################################################################################

# libigl
include(libigl)
target_link_libraries(triwild_lib PUBLIC igl::core)

# nlopt
include(nlopt)
target_link_libraries(triwild_lib PUBLIC nlopt)

# geogram
include(geogram)
target_link_libraries(triwild_lib PUBLIC geogram)

# GMP
find_package(GMP REQUIRED)
target_link_libraries(triwild_lib PUBLIC gmp::gmp)

# json
include(json)
target_link_libraries(triwild_lib PUBLIC nlohmann_json::nlohmann_json)

# aabbcc
include(aabbcc)
target_link_libraries(triwild_lib PUBLIC aabbcc::aabbcc)

################################################################################
# TriWild Executable
################################################################################

if(TRIWILD_TOPLEVEL_PROJECT)
	#add_executable(TriWild main.cpp UIPanel.hpp UIPanel.cpp)
	add_executable(TriWild src/main.cpp)
	target_link_libraries(TriWild triwild::triwild)
endif()