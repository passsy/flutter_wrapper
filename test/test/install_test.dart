import 'dart:async';
import 'dart:io' as io;

import 'package:file/local.dart';
import 'package:test/test.dart';
import 'package:cli_script/cli_script.dart';
import 'package:file/file.dart';

void main() {
  group('install', () {
    test('report missing git', () async {
      final dir = io.Directory.systemTemp.createTempSync('root');
      addTearDown(() {
        dir.deleteSync(recursive: true);
      });

      final script = Script.capture((_) async {
        await runInstallScript(workingDirectory: dir.absolute.path);
      });
      final err = await script.stdout.text;
      expect(err, contains("Not a git repository, to fix this run: git init"));
      final code = await script.exitCode;
      expect(code, 1);
    });

    group("install in git root", () {
      late Directory gitRootDir;
      late Directory appDir;

      setUpAll(() async {
        final dir = const LocalFileSystem().systemTempDirectory.createTempSync('root');
        addTearDown(() {
          dir.deleteSync(recursive: true);
        });
        gitRootDir = appDir = dir.childDirectory('myApp');
        assert(gitRootDir == appDir);

        // create git in appDir
        appDir.createSync();
        await run("git init -b master", workingDirectory: appDir.absolute.path);

        await runInstallScript(workingDirectory: appDir.absolute.path);
        print('init done');
      });

      test('flutterw was downloaded', () async {
        expect(appDir.childFile('flutterw').existsSync(), isTrue);
      });

      test('flutterw is executable', () async {
        final flutterw = appDir.childFile('flutterw');
        final script = Script.capture((_) async => await run("stat ${flutterw.absolute.path}"));
        expect(await script.stdout.text, contains("-rwxr-xr-x"));
      });

      test('created .flutter submodule in appDir', () async {
        final flutterw = appDir.childFile('flutterw');
        print("Checking dir ${flutterw.path}");
        expect(flutterw.existsSync(), isTrue);
      });

      test('downloaded dart tools', () async {
        expect(gitRootDir.childFile(".flutter/bin/cache/dart-sdk/bin/dart").existsSync(), isTrue);
        expect(gitRootDir.childFile(".flutter/bin/cache/dart-sdk/bin/dartanalyzer").existsSync(), isTrue);
        expect(gitRootDir.childFile(".flutter/bin/cache/dart-sdk/bin/dartfmt").existsSync(), isTrue);
        expect(gitRootDir.childFile(".flutter/bin/cache/dart-sdk/bin/pub").existsSync(), isTrue);
      });

      test('flutterw contains version', () async {
        final flutterw = appDir.childFile('flutterw');
        final text = flutterw.readAsStringSync();
        expect(text, isNot(contains("VERSION_PLACEHOLDER")));
        expect(text, isNot(contains("DATE_PLACEHOLDER")));
      });
    });

    group("install in subdir", () {
      late Directory gitRootDir;
      late Directory appDir;

      setUpAll(() async {
        gitRootDir = const LocalFileSystem().systemTempDirectory.createTempSync('root');
        addTearDown(() {
          gitRootDir.deleteSync(recursive: true);
        });
        // git repo in root, flutterw in appDir
        appDir = gitRootDir.childDirectory('myApp')..createSync();

        await run("git init -b master", workingDirectory: gitRootDir.absolute.path);
        await runInstallScript(workingDirectory: appDir.absolute.path);
      });

      test('subdir flutterw was downloaded', () async {
        final flutterw = appDir.childFile('flutterw');
        expect(flutterw.existsSync(), isTrue);
      });

      test('subdir flutterw is executable', () async {
        final flutterw = appDir.childFile('flutterw');
        final script = Script.capture((_) async => await run("stat ${flutterw.absolute.path}"));
        expect(await script.stdout.text, contains("-rwxr-xr-x"));
      });

      test('subdir created .flutter submodule', () async {
        final flutterDir = gitRootDir.childDirectory('.flutter');
        expect(flutterDir.existsSync(), isTrue);
      });

      test('subdir downloaded dart tools', () async {
        expect(gitRootDir.childFile(".flutter/bin/cache/dart-sdk/bin/dart").existsSync(), isTrue);
        expect(gitRootDir.childFile(".flutter/bin/cache/dart-sdk/bin/dartanalyzer").existsSync(), isTrue);
        expect(gitRootDir.childFile(".flutter/bin/cache/dart-sdk/bin/dartfmt").existsSync(), isTrue);
        expect(gitRootDir.childFile(".flutter/bin/cache/dart-sdk/bin/pub").existsSync(), isTrue);
      });

      test('subdir flutterw contains version', () async {
        final flutterw = appDir.childFile('flutterw');
        final text = flutterw.readAsStringSync();
        expect(text, isNot(contains("VERSION_PLACEHOLDER")));
        expect(text, isNot(contains("DATE_PLACEHOLDER")));
      });
    });
  });
}

Future<void> runInstallScript({String? workingDirectory}) async {
  final repoRoot = const LocalFileSystem().currentDirectory.parent;
  // Get path from line
  //     • Flutter version 2.2.0-10.1.pre at /usr/local/Caskroom/flutter/latest/flutter
  final doctor = Script.capture((_) async => await run('flutter doctor -v'));
  final lines = await doctor.stdout.lines.toList();
  final flutterRepoPath = lines.firstWhere((line) => line.contains("Flutter version")).split(" ").last;
  print("doctor exit code ${await doctor.exitCode}");

  const LocalFileSystem().currentDirectory.childDirectory('build').createSync(recursive: true);
  final File testableInstall = repoRoot.childFile('install.sh').copySync('build/testable_install.sh');
  {
    await run('chmod 755 ${testableInstall.path}');
    final modified = testableInstall
        .readAsStringSync()
        .replaceFirst('https://github.com/flutter/flutter.git', flutterRepoPath)
        .replaceFirst('https://raw.githubusercontent.com/passsy/flutter_wrapper/\$VERSION_TAG/flutterw',
            'file://${repoRoot.childFile('flutterw').path}');
    testableInstall.writeAsStringSync(modified);
  }

  await run(
    "${testableInstall.absolute.path}",
    name: 'install.sh (testable)',
    workingDirectory: workingDirectory,
  );
}
