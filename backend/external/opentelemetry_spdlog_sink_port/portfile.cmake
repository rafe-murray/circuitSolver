if(VCPKG_TARGET_IS_WINDOWS)
  vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO open-telemetry/opentelemetry-cpp-contrib
  REF 3a9af54209da6388ef2afcdb52f2f86fbe9ad6d1
  HEAD_REF main
  SHA512 81299daba70412b56a182b252b63d9017213b1b93a7a26b6ce6fb4faaa96c69b312d95514208eb90051c93166532c433bd3af4d1d3dac5146b1af21bdd170ce8
  PATCHES
    fix-thread_id_type.patch
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}/instrumentation/spdlog"
  OPTIONS
    -DOPENTELEMETRY_INSTALL=ON
    -DWITH_EXAMPLES=OFF
    -DBUILD_TESTING=OFF
    -DCMAKE_CXX_STANDARD=17
    -DCMAKE_CXX_STANDARD_REQUIRED=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
  PACKAGE_NAME opentelemetry_spdlog_sink
  CONFIG_PATH "lib/cmake/opentelemetry_spdlog_sink"
)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
