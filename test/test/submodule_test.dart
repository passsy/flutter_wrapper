import 'dart:async';
import 'dart:io' as io;

import 'package:file/local.dart';
import 'package:test/test.dart';
import 'package:cli_script/cli_script.dart';
import 'package:file/file.dart';

import 'install_test.dart';

void main() {
  test(
    'populate submodule when uninitialized',
    () async {
      final origin = const LocalFileSystem().systemTempDirectory.createTempSync('origin');
      addTearDown(() {
        origin.deleteSync(recursive: true);
      });
      await run('git init -b master', workingDirectory: origin.absolute.path);
      await runInstallScript(workingDirectory: origin.absolute.path);
      await run('git commit -a -m "initial commit"', workingDirectory: origin.absolute.path);

      final clone = const LocalFileSystem().systemTempDirectory.createTempSync('clone');
      addTearDown(() {
        clone.deleteSync(recursive: true);
      });
      await run('git clone ${origin.absolute.path} ${clone.absolute.path}');
      // calling flutterw should now automatically initialize the submodule and build the flutter tool
      await run('./flutterw', workingDirectory: clone.absolute.path);

      expect(clone.childFile('.flutter/bin/flutter').existsSync(), isTrue);
      expect(clone.childFile('.flutter/bin/cache/dart-sdk/bin/dart').existsSync(), isTrue);
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );
}
