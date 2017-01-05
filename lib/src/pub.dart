import 'dart:async';
import 'dart:io';

class Pub {
  final Directory rootDirectory;

  Pub(this.rootDirectory);

  _streamProcess(Process process) {
    stdout.addStream(process.stdout);
    stderr.addStream(process.stderr);
  }

  Future<bool> _success(Process process) async {
    return (await process.exitCode) == 0 ? true : false;
  }

  Future<bool> build() async {
    var process = await Process.start('pub', ['build'],
        workingDirectory: rootDirectory.absolute.path);
    _streamProcess(process);
    return await _success(process);
  }

  Future<bool> get() async {
    var process = await Process.start('pub', ['get'],
        workingDirectory: rootDirectory.absolute.path);
    _streamProcess(process);
    return await _success(process);
  }

  Future<bool> serve() async {
    var process = await Process.start('pub', ['serve'],
        workingDirectory: rootDirectory.absolute.path);
    _streamProcess(process);
    return await _success(process);
  }

  Future<bool> upgrade() async {
    var process = await Process.start('pub', ['upgrade'],
        workingDirectory: rootDirectory.absolute.path);
    _streamProcess(process);
    return await _success(process);
  }
}
