import 'dart:async';
import 'dart:io' as io;

import 'package:cli_script/cli_script.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:synchronized/synchronized.dart';
import 'package:test/test.dart';

void main() {
  group('install', () {
    test(
      'report missing git',
      () async {
        final dir = io.Directory.systemTemp.createTempSync('root');
        addTearDown(() {
          dir.deleteSync(recursive: true);
        });

        final script = Script.capture((_) async {
          await runInstallScript(
              appDir: dir.absolute.path, gitRootDir: dir.absolute.path);
        });
        // access fields before accessing them or they crash
        final exitCodeFuture = script.exitCode;
        final outFuture = script.stdout.text;

        final err = await outFuture;
        expect(
            err, contains("Not a git repository, to fix this run: git init"));
        final code = await exitCodeFuture;
        expect(code, 1);
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );

    group("install in git root", () {
      late Directory gitRootDir;
      late Directory appDir;

      tearDownAll(() {
        // appDir.parent.deleteSync(recursive: true);
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

      test('flutterw was downloaded', () async {
        expect(appDir.childFile('flutterw').existsSync(), isTrue);
      });

      test('flutterw is executable', () async {
        final flutterw = appDir.childFile('flutterw');
        final script =
            Script.capture((_) async => run("stat ${flutterw.absolute.path}"));
        expect(await script.stdout.text, contains("-rwxr-xr-x"));
      });

      test('created .flutter submodule in appDir', () async {
        final flutterw = appDir.childFile('flutterw');
        expect(flutterw.existsSync(), isTrue);
      });

      test('downloaded dart tools', () async {
        expect(
            gitRootDir
                .childFile(".flutter/bin/cache/dart-sdk/bin/dart")
                .existsSync(),
            isTrue);
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

      test('subdir flutterw was downloaded', () async {
        final flutterw = appDir.childFile('flutterw');
        expect(flutterw.existsSync(), isTrue);
      });

      test('subdir flutterw is executable', () async {
        final flutterw = appDir.childFile('flutterw');
        final script =
            Script.capture((_) async => run("stat ${flutterw.absolute.path}"));
        expect(await script.stdout.text, contains("-rwxr-xr-x"));
      });

      test('subdir created .flutter submodule', () async {
        final flutterDir = gitRootDir.childDirectory('.flutter');
        expect(flutterDir.existsSync(), isTrue);
      });

      test('subdir downloaded dart tools', () async {
        final dartBinary =
            gitRootDir.childFile(".flutter/bin/cache/dart-sdk/bin/dart");
        expect(dartBinary.existsSync(), isTrue);
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

bool _precached = false;
Lock precacheLock = Lock();

Future<void> runInstallScript({
  required String appDir,
  required String gitRootDir,
}) async {
  const fs = LocalFileSystem();
  final repoRoot = fs.currentDirectory.parent;
  // Get path from line
  //     • Flutter version 2.2.0-10.1.pre at /usr/local/Caskroom/flutter/latest/flutter
  final doctor = Script.capture((_) async => run('flutter doctor -v'));
  final lines = await doctor.stdout.lines.toList();
  final flutterRepoPath = lines
      .firstWhere((line) => line.contains("Flutter version"))
      .split(" ")
      .last;
  final localFlutterExists = fs.directory(flutterRepoPath).existsSync();
  if (!localFlutterExists) {
    throw "Did not find a flutter repo on your system";
  }

  await precacheLock.synchronized(() async {
    if (!_precached) {
      await run('sudo cd "$flutterRepoPath/" && ls -la');
      await run('sudo git -C "$flutterRepoPath/" checkout stable');
      await run('flutter precache');
      _precached = true;
    }
  });

  final buildDir = fs.directory(appDir).childDirectory('build')
    ..createSync(recursive: true);

  final File testableInstall = repoRoot
      .childFile('install.sh')
      .copySync(buildDir.childFile('testable_install.sh').path);

  await run('chmod 755 ${testableInstall.path}');
  {
    // modify install script to use local dependencies
    var modified = testableInstall.readAsStringSync();

    // Close local repo instead of remote
    modified = modified.replaceFirst(
        'https://github.com/flutter/flutter.git', flutterRepoPath);

    // Instead of getting dependencies, preload flutter dependencies
    modified = modified.replaceFirst(
      '''if [ -f pubspec.yaml ]; then
  ./flutterw packages get
fi''',
      'mkdir -p $appDir/.flutter/bin/cache/ \n'
          'cp -R -L -f $flutterRepoPath/bin/ $gitRootDir/.flutter/bin/ \n'
          'cp -R -L -f $flutterRepoPath/packages/flutter_tools/ $gitRootDir/.flutter/packages/flutter_tools/ \n'
          './flutterw \n',
    );

    // Don't load version from repo
    modified = modified.replaceFirst(
      'VERSION_TAG=\$(curl -s "https://raw.githubusercontent.com/passsy/flutter_wrapper/master/version")',
      'VERSION_TAG=T.E.S.T',
    );

    // Local local flutterw file
    modified = modified.replaceFirst(
      'https://raw.githubusercontent.com/passsy/flutter_wrapper/\$VERSION_TAG/flutterw',
      'file://${repoRoot.childFile('flutterw').path}',
    );

    testableInstall.writeAsStringSync(modified);
  }

  final script = Script(
    "${testableInstall.absolute.path}",
    name: 'install.sh (testable)',
    workingDirectory: appDir,
  );
  await script.done;
}
