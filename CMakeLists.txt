cmake_minimum_required(VERSION 3.16)

project(HiResMusicApp VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 17)

find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_standard_project_setup(REQUIRES 6.8)

# Debug info
message(STATUS "Current source dir: ${CMAKE_CURRENT_SOURCE_DIR}")

# PortAudio configuration - Windows paths
set(PORTAUDIO_INCLUDE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/libs/portaudio/include")
set(PORTAUDIO_LIB_DIR "${CMAKE_CURRENT_SOURCE_DIR}/libs/portaudio/lib")

message(STATUS "PortAudio include dir: ${PORTAUDIO_INCLUDE_DIR}")
message(STATUS "PortAudio lib dir: ${PORTAUDIO_LIB_DIR}")

# Check files exist
if(EXISTS "${PORTAUDIO_INCLUDE_DIR}/portaudio.h")
    message(STATUS "✅ Found portaudio.h")
else()
    message(FATAL_ERROR "❌ portaudio.h not found at ${PORTAUDIO_INCLUDE_DIR}/portaudio.h")
endif()

if(EXISTS "${PORTAUDIO_LIB_DIR}/libportaudio.a")
    message(STATUS "✅ Found libportaudio.a")
else()
    message(FATAL_ERROR "❌ libportaudio.a not found at ${PORTAUDIO_LIB_DIR}/libportaudio.a")
endif()

qt_add_executable(appHiResMusicApp
    main.cpp
    audiomanager.h
    audiomanager.cpp
)

qt_add_qml_module(appHiResMusicApp
    URI HiResMusicApp
    VERSION 1.0
    QML_FILES
        Main.qml
)

# Include PortAudio headers
target_include_directories(appHiResMusicApp PRIVATE
    ${PORTAUDIO_INCLUDE_DIR}
)

# Link PortAudio library (Windows)
target_link_libraries(appHiResMusicApp PRIVATE
    Qt6::Quick
    "${PORTAUDIO_LIB_DIR}/libportaudio.a"  # Full path to library
    winmm
    ole32
    uuid
    setupapi
    ksuser
    advapi32
)

# Enable console for debug output on Windows
if(WIN32)
    set_target_properties(appHiResMusicApp PROPERTIES
        WIN32_EXECUTABLE FALSE  # Enables console window
    )
endif()

set_target_properties(appHiResMusicApp PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
)

include(GNUInstallDirs)
install(TARGETS appHiResMusicApp
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
