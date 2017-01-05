import 'dart:async';
import 'dart:io';
import 'package:resource/resource.dart';
import '../project.dart';

typedef Future DirectoryGeneratorCallback(DirectoryGenerator file);
typedef Future FileGeneratorCallback(FileGenerator file);
const String CURSES_NORMAL = '\x1b[0m';

class DirectoryGenerator {
  final Directory io;
  final Project project;
  final Map<DirectoryGenerator, DirectoryGeneratorCallback> directories = {};
  final Map<FileGenerator, FileGeneratorCallback> files = {};

  DirectoryGenerator(this.io, this.project);

  _streamProcess(Process process) {
    stdout.addStream(process.stdout);
    stderr.addStream(process.stderr);
  }

  Future<bool> _success(Process process) async {
    return (await process.exitCode) == 0 ? true : false;
  }

  Future clone(String repo,
      {int depth, bool recursive: false, bool keepGitDir: false}) async {
    List<String> args = [];

    if (depth != null) args.add('--depth=$depth');

    if (recursive == true) args.add('--recursive');

    args.addAll([repo, io.absolute.path]);

    project.notify
        .busy("Cloning Git repository '$repo' to '${io.absolute.path}'...");
    var git = await Process.start('git', args);
    _streamProcess(git);

    if (!await _success(git)) {
      throw new Exception('Failed to clone repo.');
    }

    if (keepGitDir != true) {
      var gitDir = new Directory.fromUri(io.uri.resolve('.git'));
      if (await gitDir.exists()) await gitDir.delete();
    }

    project.notify.success('Clone complete.');
  }

  Future generate(Project project) async {
    for (var dir in directories.keys) {
      project.notify.task("Creating directory '${dir.io.absolute.path}'...");
      await dir.io.create(recursive: true);
      await directories[dir](dir);
      await dir.generate(project);
    }

    for (var file in files.keys) {
      project.notify.task("Creating file '${file.io.absolute.path}'...");
      await file.io.create(recursive: true);
      await files[file](file);
    }
  }

  DirectoryGenerator directory(String name,
      [DirectoryGeneratorCallback callback]) {
    var dir = new DirectoryGenerator(
        new Directory.fromUri(io.uri.resolve(name)), project);

    if (callback == null) {
      if (!dir.io.existsSync()) dir.io.createSync(recursive: true);
      return dir;
    }

    directories[dir] = callback;
    return dir;
  }

  FileGenerator file(String filename, [FileGeneratorCallback callback]) {
    var file =
        new FileGenerator(new File.fromUri(io.uri.resolve(filename)), project);

    if (callback == null) {
      if (!file.io.existsSync()) file.io.createSync(recursive: true);
      return file;
    }

    files[file] = callback;
    return file;
  }

  Future<bool> run(String executable, List<String> args) async {
    var process = await Process.start(executable, args,
        workingDirectory: io.absolute.path);
    _streamProcess(process);
    return await _success(process);
  }
}

class FileGenerator {
  final File io;
  final Project project;

  FileGenerator(this.io, this.project);

  Future download(url) async {
    var client = new HttpClient();
    var rq = await client.openUrl('GET', url is Uri ? url : Uri.parse(url));
    project.notify.busy("Downloading URL '$url' to '${io.absolute.path}'...");
    var rs = await rq.close();
    project.notify.success('Download complete.');
    await client.close();
    await rs.pipe(io.openWrite());
  }

  Future copyFile(File file) async {
    project.notify
        .busy("Copying file ${file.absolute.path} to '${io.absolute.path}'...");
    await file.openRead().pipe(io.openWrite());
    project.notify.success('Copy complete.');
  }

  Future copyResource(uri) async {
    project.notify.busy("Copying resource $uri to '${io.absolute.path}'...");
    var resource = new Resource(uri);
    await resource.openRead().pipe(io.openWrite());
    project.notify.success('Copy complete.');
  }
}
