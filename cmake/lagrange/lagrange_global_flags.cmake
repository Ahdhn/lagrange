#
# Copyright 2020 Adobe. All rights reserved.
# This file is licensed to you under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You may obtain a copy
# of the License at http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under
# the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
# OF ANY KIND, either express or implied. See the License for the specific language
# governing permissions and limitations under the License.
#
include_guard(GLOBAL)

# options
if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
    # Reduce the warning level of external files to the selected value (W1 - only major).
    # Requires Visual Studio 2017 version 15.7
    # https://blogs.msdn.microsoft.com/vcblog/2017/12/13/broken-warnings-theory/

    # There is an issue in using these flags in earlier versions of MSVC:
    # https://developercommunity.visualstudio.com/content/problem/220812/experimentalexternal-generates-a-lot-of-c4193-warn.html
    if(MSVC_VERSION GREATER 1920)
        add_compile_options(/experimental:external)
        add_compile_options(/external:W1)
    endif()

    # When building in parallel, MSVC sometimes fails with the following error:
    # > fatal error C1090: PDB API call failed, error code '23'
    # To avoid this problem, we force PDB write to be synchronous with /FS.
    # https://developercommunity.visualstudio.com/content/problem/48897/c1090-pdb-api-call-failed-error-code-23.html
    add_compile_options(/FS)

    # Boost::hana requires /EHsc, so we need to enable it globally
    include(lagrange_filter_flags)
    set(LAGRANGE_GLOBAL_FLAGS
        /EHsc # Compatibility with Boost::hana
    )
    lagrange_filter_flags(LAGRANGE_GLOBAL_FLAGS)
    message(STATUS "Adding global flags: ${LAGRANGE_GLOBAL_FLAGS}")
    add_compile_options(${LAGRANGE_GLOBAL_FLAGS})
else()
    include(lagrange_filter_flags)
    set(LAGRANGE_GLOBAL_FLAGS
        -fdiagnostics-color=always # GCC
        -fcolor-diagnostics # Clang
    )
    lagrange_filter_flags(LAGRANGE_GLOBAL_FLAGS)
    message(STATUS "Adding global flags: ${LAGRANGE_GLOBAL_FLAGS}")
    add_compile_options(${LAGRANGE_GLOBAL_FLAGS})
endif()

if(LAGRANGE_WITH_TRACY)
    include(lagrange_filter_flags)
    set(LAGRANGE_GLOBAL_FLAGS
        "-fno-omit-frame-pointer"
        "-g"
    )
    lagrange_filter_flags(LAGRANGE_GLOBAL_FLAGS)
    message(STATUS "Adding global flags: ${LAGRANGE_GLOBAL_FLAGS}")
    add_compile_options(${LAGRANGE_GLOBAL_FLAGS})
endif()

if(EMSCRIPTEN)
    # Use the "-fexceptions" flag to allow C++ code to catch C++ exceptions after compilation to
    # WebAssembly. At some point, when more WASM engines support exceptions natively, change
    # "-fexceptions" to "-fwasm-exceptions". See https://emscripten.org/docs/porting/exceptions.html.

    # Use "-pthread" to allow multi-threading. See https://emscripten.org/docs/porting/pthreads.html.

    if(LAGRANGE_USE_WASM_EXCEPTIONS)
        set(EMSCRIPTEN_EXCEPTION_HANDLER_FLAG "-fwasm-exceptions")
    else()
        set(EMSCRIPTEN_EXCEPTION_HANDLER_FLAG "-fexceptions")
    endif()

    add_compile_options(${EMSCRIPTEN_EXCEPTION_HANDLER_FLAG} -pthread)
    add_link_options(${EMSCRIPTEN_EXCEPTION_HANDLER_FLAG} -pthread)
endif()
