import 'dart:io';

import 'package:process_run/cmd_run.dart' as script;
import 'package:process_run/shell_run.dart' as shell;
import 'package:test/test.dart';

void main() {
  group('install', () {
    test('report missing git', () async {
      final dir = Directory.systemTemp.createTempSync('root');
      addTearDown(() {
        dir.deleteSync(recursive: true);
      });
      final result = await script.run(
        File("../install.sh").absolute.path,
        const <String>[],
        workingDirectory: dir.absolute.path,
      );
      expect(result.stdout,
          contains("Not a git repository, to fix this run: git init"));
    });

    group("install in git root", () {
      Directory gitRootDir;
      Directory appDir;

      setUpAll(() async {
        final dir = Directory.systemTemp.createTempSync('root');
        addTearDown(() {
          // dir.deleteSync(recursive: true);
        });
        gitRootDir = appDir = Directory("${dir.absolute.path}/myApp");
        assert(gitRootDir == appDir);

        // create git in appDir
        appDir.createSync();
        await shell.run("git init", workingDirectory: appDir.absolute.path);

        await script.run(
          File("../install.sh").absolute.path,
          const <String>[],
          workingDirectory: appDir.absolute.path,
          verbose: true,
        );
      });

      test('flutterw was downloaded', () async {
        expect(File("${appDir.path}/flutterw").existsSync(), isTrue);
      });
      test('flutterw is executable', () async {
        final flutterw = File("${appDir.path}/flutterw");
        final result = await Process.run("stat", [flutterw.absolute.path]);
        final String out = result.stdout as String;
        expect(out, contains("-rwxr-xr-x"));
      });
      test('created .flutter submodule', () async {
        print("Checking dir ${gitRootDir.path}/.flutter");
        expect(Directory("${gitRootDir.path}/.flutter").existsSync(), isTrue);
      });
      test('downloaded dart tools', () async {
        expect(
            File("${gitRootDir.path}/.flutter/bin/cache/dart-sdk/bin/dart")
                .existsSync(),
            isTrue);
        expect(
            File("${gitRootDir.path}/.flutter/bin/cache/dart-sdk/bin/dartanalyzer")
                .existsSync(),
            isTrue);
        expect(
            File("${gitRootDir.path}/.flutter/bin/cache/dart-sdk/bin/dartfmt")
                .existsSync(),
            isTrue);
        expect(
            File("${gitRootDir.path}/.flutter/bin/cache/dart-sdk/bin/pub")
                .existsSync(),
            isTrue);
      });
      test('flutterw contains version', () async {
        final flutterw = File("${appDir.path}/flutterw");
        final text = flutterw.readAsStringSync();
        expect(text, isNot(contains("VERSION_PLACEHOLDER")));
        expect(text, isNot(contains("DATE_PLACEHOLDER")));
      });
    });

    group("install in subdir", () {
      Directory gitRootDir;
      Directory appDir;

      setUpAll(() async {
        gitRootDir = Directory.systemTemp.createTempSync('root');
        addTearDown(() {
          //gitRootDir.deleteSync(recursive: true);
        });
        appDir = Directory("${gitRootDir.absolute.path}/myApp");

        // git repo in root, flutterw in appDir
        await shell.run("git init", workingDirectory: gitRootDir.absolute.path);
        appDir.createSync();

        await script.run(
          File("../install.sh").absolute.path,
          const <String>[],
          workingDirectory: appDir.absolute.path,
          verbose: true,
        );
      });

      test('flutterw was downloaded', () async {
        expect(File("${appDir.path}/flutterw").existsSync(), isTrue);
      });
      test('flutterw is executable', () async {
        final flutterw = File("${appDir.path}/flutterw");
        final result = await Process.run("stat", [flutterw.absolute.path]);
        final String out = result.stdout as String;
        expect(out, contains("-rwxr-xr-x"));
      });
      test('created .flutter submodule', () async {
        expect(Directory("${gitRootDir.path}/.flutter").existsSync(), isTrue);
      });
      test('downloaded dart tools', () async {
        expect(
            File("${gitRootDir.path}/.flutter/bin/cache/dart-sdk/bin/dart")
                .existsSync(),
            isTrue);
        expect(
            File("${gitRootDir.path}/.flutter/bin/cache/dart-sdk/bin/dartanalyzer")
                .existsSync(),
            isTrue);
        expect(
            File("${gitRootDir.path}/.flutter/bin/cache/dart-sdk/bin/dartfmt")
                .existsSync(),
            isTrue);
        expect(
            File("${gitRootDir.path}/.flutter/bin/cache/dart-sdk/bin/pub")
                .existsSync(),
            isTrue);
      });
      test('flutterw contains version', () async {
        final flutterw = File("${appDir.path}/flutterw");
        final text = flutterw.readAsStringSync();
        expect(text, isNot(contains("VERSION_PLACEHOLDER")));
        expect(text, isNot(contains("DATE_PLACEHOLDER")));
      });
    });
  });
}
