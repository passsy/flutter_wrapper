import 'package:cli_script/cli_script.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:test/test.dart';

import 'install_test.dart';

void main() {
  group('update', () {
    group("Update flutterw in git root", () {
      late Directory gitRootDir;
      late Directory appDir;

      tearDownAll(() {
        appDir.parent.deleteSync(recursive: true);
      });
      setUpAll(() async {
        final dir =
            const LocalFileSystem().systemTempDirectory.createTempSync('root');
        gitRootDir = appDir = dir.childDirectory('myApp');
        assert(gitRootDir == appDir);

        // create git in appDir
        appDir.createSync();
        await run("git init", workingDirectory: appDir.absolute.path);

        await runInstallScript(
            appDir: appDir.absolute.path, gitRootDir: gitRootDir.absolute.path);
      });

      test('updates flutterw', () async {
        final flutterw = appDir.childFile('flutterw');
        final content = flutterw.readAsStringSync();
        await runInstallScript(
            appDir: appDir.absolute.path, gitRootDir: gitRootDir.absolute.path);

        final update = flutterw.readAsStringSync();
        expect(update, isNot(content));
      });
    });

    group("update in subdir", () {
      late Directory gitRootDir;
      late Directory appDir;

      tearDownAll(() {
        gitRootDir.deleteSync(recursive: true);
      });

      setUpAll(() async {
        gitRootDir =
            const LocalFileSystem().systemTempDirectory.createTempSync('root');
        // git repo in root, flutterw in appDir
        appDir = gitRootDir.childDirectory('myApp')..createSync();

        await run("git init", workingDirectory: gitRootDir.absolute.path);
        await runInstallScript(
            appDir: appDir.absolute.path, gitRootDir: gitRootDir.absolute.path);
      });

      test('updates flutterw', () async {
        final flutterw = appDir.childFile('flutterw');
        final content = flutterw.readAsStringSync();
        await runInstallScript(
            appDir: appDir.absolute.path, gitRootDir: gitRootDir.absolute.path);

        final update = flutterw.readAsStringSync();
        expect(update, isNot(content));
      });
    });
  });
}
