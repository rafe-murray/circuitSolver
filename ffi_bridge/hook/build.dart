import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:logging/logging.dart';
import 'package:native_toolchain_cmake/native_toolchain_cmake.dart';
import 'package:native_toolchain_cmake/src/utils/env_from_native_config.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    if (input.config.buildCodeAssets) {
      final envFile = input.userDefines['env_file']?.toString();
      if (envFile == null) {
        throw Exception(
          "user_defines.env_file unset. You must set this in your pubspec.yaml and include VCPKG_ROOT as a key",
        );
      }
      final config = await getUserEnvConfig(input: input, envFile: envFile);
      final vcpkgRoot = config['VCPKG_ROOT'];
      if (vcpkgRoot == null) {
        throw Exception(
          "VCPKG_ROOT not found. Make sure to include it in your .env file. Setting the environment variable is not sufficient",
        );
      }

      final logger = Logger('')
        ..level = Level.ALL
        ..onRecord.listen((record) => stdout.writeln(record));
      final cmake = CMakeBuilder.create(
        name: input.packageName,
        sourceDir: input.packageRoot.resolve('../native_lib'),
        generator: Generator.ninja,
        defines: {
          'CMAKE_PROJECT_TOP_LEVEL_INCLUDES':
              '$vcpkgRoot/scripts/buildsystems/vcpkg.cmake',
          'BUILD_SHARED_LIBS': 'ON',
          'CMAKE_BUILD_TYPE': 'Release',
          'CMAKE_INSTALL_PREFIX':
              '${input.outputDirectory.toFilePath()}/install',
        },
        targets: ['install'],
      );
      await cmake.run(input: input, output: output, logger: logger);
      logger.info("Finished building libcircuitsolver");
      final buildjson = input.config.json;
      logger.info('Build output: $buildjson');

      // automatically search and add libraries
      final outLibs = await output.findAndAddCodeAssets(
        input,
        names: {r'(lib)?circuitsolver\.(dll|so|dylib)': 'ffi_bridge.dart'},
        outDir: input.outputDirectory.resolve('install'),
        logger: logger,
        regExp: true,
      );

      logger.info('Found libs: $outLibs');
    }
  });
}
