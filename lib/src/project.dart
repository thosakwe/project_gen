import 'dart:async';
import 'dart:io';
import 'package:id/id.dart';
import 'package:path/path.dart' as p;
import 'package:pubspec/pubspec.dart';
import 'actions/filesystem.dart' show DirectoryGenerator;
import 'notifier.dart';
import 'pub.dart';

String _toSnake(String str) {
  return idFromString(p.basename(str.toLowerCase()).replaceAll('-', '_')).snake;
}

typedef Future ProjectAction(Project project);

class Project {
  Pub _pub;
  PubSpec _pubspec;
  String _name;
  DirectoryGenerator _root;

  final List<ProjectAction> actions = [];
  final Notifier notify = new Notifier();

  String get name => _name;
  DirectoryGenerator get root => _root;
  Pub get pub => _pub;
  PubSpec get pubspec => _pubspec;

  Project(String name, [Directory rootDirectory]) {
    var dir = rootDirectory ?? Directory.current;
    _name = _toSnake(name);
    _pub = new Pub(dir);
    _pubspec = new PubSpec(name: name);
    _root = new DirectoryGenerator(dir, this);
  }

  static Future<Project> load([Directory directory]) async {
    var dir = directory ?? Directory.current;
    var pubspec = await PubSpec.load(dir);
    return new Project(
        pubspec.name?.isNotEmpty == true
            ? pubspec.name
            : _toSnake(p.basename(dir.path)),
        dir).._pubspec = pubspec;
  }

  static Project loadSync([Directory directory]) {
    var dir = directory ?? Directory.current;
    var pubspecFile = new File.fromUri(dir.uri.resolve('pubspec.yaml'));
    var pubspec = new PubSpec.fromYamlString(pubspecFile.readAsStringSync());

    return new Project(
        pubspec.name?.isNotEmpty == true
            ? pubspec.name
            : _toSnake(p.basename(dir.path)),
        dir).._pubspec = pubspec;
  }

  Future generate({bool runPubGet: true}) async {
    try {
      notify.creatingProject(name);

      List<ProjectAction> toRun = [savePubspec]..addAll(actions);

      if (!await root.io.exists()) await root.io.create(recursive: true);
      await root.generate(this);

      for (var action in toRun) {
        await action(this);
      }

      if (runPubGet) {
        if (!await pub.get()) {
          notify.error('Failed to install Pub dependencies.');
          return;
        }
      }

      notify.success('Successfully created project $name.');
    } catch (e, st) {
      stderr..writeln(e)..writeln(st);
      notify.error('Failed to create project $name.');
    }
  }
}

Future savePubspec(Project project) {
  project.notify.task('Generating pubspec in ${project.root.io.path}...');
  return project.pubspec.save(project.root.io);
}
