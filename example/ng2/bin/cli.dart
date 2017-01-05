#!/usr/bin/env dart
import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:project_gen/project_gen.dart';

main(List<String> args) {
  var runner = new CommandRunner('ng2', 'Generates Angular2 projects.')
    ..addCommand(new InitCommand());
  return runner.run(args);
}

class InitCommand extends Command {
  @override
  String get name => 'init';

  @override
  String get description => 'Creates a new project.';

  @override
  run() async {
    var project = new Project('sample_project',
        new Directory.fromUri(Directory.current.uri.resolve('sample_project')));

    project.root
      ..directory('lib', (dir) {
        dir.file('${project.name}.dart', (file) {
          var sink = file.io.openWrite();

          sink
            ..writeln('/// Generated via project_gen')
            ..writeln('library ${project.name};');
          return sink.close();
        });
      })
      ..file('README.md', (file) {
        file.io.writeAsString('# ${project.name}');
      })
      ..file('jquery.js', (jquery) async {
        await jquery
            .download('https://code.jquery.com/jquery-3.1.1.slim.min.js');
      });

    await project.generate();
  }
}
