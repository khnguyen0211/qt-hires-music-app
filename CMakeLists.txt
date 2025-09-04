cmake_minimum_required(VERSION 3.16)

project(HiResMusicApp VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 17)

# Qt components - thêm Core cho QProcess support
find_package(Qt6 REQUIRED COMPONENTS Quick Core)

qt_standard_project_setup(REQUIRES 6.8)

# Debug info
message(STATUS "Current source dir: ${CMAKE_CURRENT_SOURCE_DIR}")

# PortAudio configuration
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
    audio_decoder.h
    audio_decoder.cpp
    audio_player.h
    audio_player.cpp
    track.h
    track.cpp
    playlist_manager.h
    playlist_manager.cpp
)

qt_add_qml_module(appHiResMusicApp
    URI HiResMusicApp
    VERSION 1.0
    QML_FILES
        Main.qml
        components/Header.qml
        components/PlayerControls.qml
        components/PlaybackButtons.qml
        components/LoadButtons.qml
        components/PlaylistView.qml
        components/ErrorDialog.qml
        components/LoadingOverlay.qml
)

# Include PortAudio headers
target_include_directories(appHiResMusicApp PRIVATE
    ${PORTAUDIO_INCLUDE_DIR}
)

# Link libraries
target_link_libraries(appHiResMusicApp PRIVATE
    Qt6::Quick
    Qt6::Core                                    # ← Thêm Qt Core cho QProcess
    "${PORTAUDIO_LIB_DIR}/libportaudio.a"      # PortAudio library
    winmm                                        # Windows multimedia
    ole32                                        # Windows OLE
    uuid                                         # Windows UUID
    setupapi                                     # Windows setup API
    ksuser                                       # Windows kernel streaming
    advapi32                                     # Windows advanced API
)

# Copy FFmpeg binary to output directory (Windows)
if(WIN32)
    # Look for ffmpeg.exe in common locations
    find_program(FFMPEG_EXECUTABLE
        NAMES ffmpeg ffmpeg.exe
        PATHS
            ${CMAKE_CURRENT_SOURCE_DIR}/bin
            ${CMAKE_CURRENT_SOURCE_DIR}/ffmpeg
            ENV PATH
        DOC "FFmpeg executable"
    )

    if(FFMPEG_EXECUTABLE)
        message(STATUS "✅ Found FFmpeg: ${FFMPEG_EXECUTABLE}")

        # Copy FFmpeg to output directory
        add_custom_command(TARGET appHiResMusicApp POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "${FFMPEG_EXECUTABLE}"
            "$<TARGET_FILE_DIR:appHiResMusicApp>/ffmpeg.exe"
            COMMENT "Copying FFmpeg binary"
        )
    else()
        message(WARNING "⚠️ FFmpeg not found. App will only support WAV files.")
        message(STATUS "To enable multi-format support:")
        message(STATUS "  1. Download FFmpeg from https://www.gyan.dev/ffmpeg/builds/")
        message(STATUS "  2. Place ffmpeg.exe in ./bin/ folder")
        message(STATUS "  3. Re-run cmake")
    endif()
endif()

# Enable console for debug output on Windows
if(WIN32)
    set_target_properties(appHiResMusicApp PROPERTIES
        WIN32_EXECUTABLE FALSE  # Enables console window for debugging
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
