# libigl (https://github.com/stevengj/nlopt)
# License: LGPL
if(TARGET nlopt::nlopt)
    return()
endif()

message(STATUS "Third-party: creating target 'nlopt::nlopt'")

option(NLOPT_PYTHON OFF)
option(NLOPT_GUILE OFF)
option(NLOPT_SWIG OFF)
option(NLOPT_OCTAVE OFF)
option(NLOPT_MATLAB OFF)
option(NLOPT_TESTS OFF)
option(NLOPT_FORTRAN OFF)
option(BUILD_SHARED_LIBS OFF)

include(CPM)
CPMAddPackage("gh:stevengj/nlopt#37b74a8c2037eea5dc72fea7eeb9b850fa978913")