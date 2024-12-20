cmake_minimum_required(VERSION 3.16)
project(Ocelot)

set(CMAKE_CXX_STANDARD 14)
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()
set(CMAKE_CXX_FLAGS "-Wall -Wextra")
set(CMAKE_CXX_FLAGS_DEBUG "-g")
set(CMAKE_CXX_FLAGS_RELEASE "-O3")

execute_process(COMMAND bash -c "git rev-parse --short HEAD | tr -d '\n'" OUTPUT_VARIABLE COMMIT)
message(STATUS "version: ${COMMIT}\n")

execute_process(COMMAND bash -c "sed -e 's/COMMIT/${COMMIT}/g' version.cpp.template > version.cpp")

include_directories(. /usr/include/mysql/ /usr/include/)
link_directories(/usr/lib/x86_64-linux-gnu/)

add_definitions(-D__DEBUG_BUILD__)

add_executable(Ocelot
        config.cpp
        config.h
        db.cpp
        db.h
        events.cpp
        events.h
        misc_functions.cpp
        misc_functions.h
        ocelot.cpp
        ocelot.h
        report.cpp
        report.h
        response.cpp
        response.h
        schedule.cpp
        schedule.h
        site_comm.cpp
        site_comm.h
        user.cpp
        user.h
        worker.cpp
        worker.h
        version.cpp
        version.h)

target_link_libraries(Ocelot
        ev
        mysqlpp
        pthread
        boost_system
        boost_iostreams
        glog)