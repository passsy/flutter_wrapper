import 'package:cli_script/cli_script.dart';
import 'package:file/local.dart';
import 'package:test/test.dart';

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

  group('gitmodules update', () {
    test(
      'flutter channel <X> updates gitmodules (single module)',
      () async {
        final repo = const LocalFileSystem().systemTempDirectory.createTempSync('repo');
        addTearDown(() {
          repo.deleteSync(recursive: true);
        });
        await run('git init -b master', workingDirectory: repo.absolute.path);
        await runInstallScript(workingDirectory: repo.absolute.path);
        await run('git commit -a -m "initial commit"', workingDirectory: repo.absolute.path);
        expect(repo.childFile('.gitmodules').readAsStringSync(), contains('branch = stable'));

        await run('./flutterw channel beta', workingDirectory: repo.absolute.path);
        expect(repo.childFile('.gitmodules').readAsStringSync(), contains('branch = beta'));
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );

    test(
      'flutter channel without second arg does not update gitmodules (single module)',
      () async {
        final repo = const LocalFileSystem().systemTempDirectory.createTempSync('repo');
        addTearDown(() {
          repo.deleteSync(recursive: true);
        });
        await run('git init -b master', workingDirectory: repo.absolute.path);
        await runInstallScript(workingDirectory: repo.absolute.path);
        await run('git commit -a -m "initial commit"', workingDirectory: repo.absolute.path);
        expect(repo.childFile('.gitmodules').readAsStringSync(), contains('branch = stable'));

        await run('./flutterw channel', workingDirectory: repo.absolute.path);
        expect(repo.childFile('.gitmodules').readAsStringSync(), contains('branch = stable'));
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );

    test(
      'flutter channel <X> called from package updates gitmodules in root',
      () async {
        final repo = const LocalFileSystem().systemTempDirectory.createTempSync('repo');
        addTearDown(() {
          repo.deleteSync(recursive: true);
        });
        await run('git init -b master', workingDirectory: repo.absolute.path);
        await runInstallScript(workingDirectory: repo.absolute.path);
        await run('git commit -a -m "initial commit"', workingDirectory: repo.absolute.path);
        expect(repo.childFile('.gitmodules').readAsStringSync(), contains('branch = stable'));

        // create package
        final package = repo.childDirectory('packages/xyz')..createSync(recursive: true);

        await run('./../../flutterw channel beta', workingDirectory: package.absolute.path);
        // doesn't accidentally create a .gitmodules file in package
        expect(package.childFile('.gitmodules').existsSync(), isFalse);
        // updates .gitmodules in root
        expect(repo.childFile('.gitmodules').readAsStringSync(), contains('branch = beta'));
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );

    test(
      'flutter channel without second arg called from package updates gitmodules in root',
      () async {
        final repo = const LocalFileSystem().systemTempDirectory.createTempSync('repo');
        addTearDown(() {
          repo.deleteSync(recursive: true);
        });
        await run('git init -b master', workingDirectory: repo.absolute.path);
        await runInstallScript(workingDirectory: repo.absolute.path);
        await run('git commit -a -m "initial commit"', workingDirectory: repo.absolute.path);
        expect(repo.childFile('.gitmodules').readAsStringSync(), contains('branch = stable'));

        // create package
        final package = repo.childDirectory('packages/xyz')..createSync(recursive: true);

        await run('./../../flutterw channel', workingDirectory: package.absolute.path);
        // doesn't accidentally create a .gitmodules file in package
        expect(package.childFile('.gitmodules').existsSync(), isFalse);
        // Doesn't update .gitmodules in root
        expect(repo.childFile('.gitmodules').readAsStringSync(), contains('branch = stable'));
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
