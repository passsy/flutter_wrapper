// ignore_for_file: avoid_print

import 'package:cli_script/cli_script.dart';
import 'package:cli_script/src/config.dart';
import 'package:file/local.dart';
import 'package:test/test.dart';

import 'install_test.dart';

void main() {
  test(
    'Calling ./../../fluttew from packages/xyz/',
    () async {
      await withConfig(() async {
        // setup repo
        final repo =
            const LocalFileSystem().systemTempDirectory.createTempSync('repo');
        addTearDown(() {
          repo.deleteSync(recursive: true);
        });
        await run('git init', workingDirectory: repo.absolute.path);
        await runInstallScript(
            appDir: repo.absolute.path, gitRootDir: repo.absolute.path);
        await run('git commit -a -m "initial commit"',
            workingDirectory: repo.absolute.path);

        // create package
        final package = repo.childDirectory('packages/xyz')
          ..createSync(recursive: true);
        await run('./flutterw create packages/xyz',
            workingDirectory: repo.absolute.path);

        // Make sure flutterw can be executed in package
        final script = Script.capture((_) async =>
            run('./../../flutterw', workingDirectory: package.absolute.path));
        final output = await script.combineOutput().text;
        print(output);
        expect(
            output,
            isNot(contains(
                'fatal: cannot change to \'\.flutter\': No such file or directory')));
      }, verboseTrace: true, debug: true);
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );
}
