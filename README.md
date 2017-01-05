# project_gen
A simple scaffolding framework for Dart CLI tools. This makes it easier to get projects off the ground.
It also depends on `args` and `console`, so those packages are available for your
usage.

# Usage
`project_gen` has a simple, callback-based structure, and ultimately just provides
abstractions to create files within a project directory.

Placing your code in callbacks will ensure files are created in order. Directories are
created first, and then files.

```dart
import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:project_gen/project_gen.dart';

class InitCommand extends Command {
    @override
    String get name => 'init';

    @override
    String get description => 'Initializes a new project.';

    @override
    run() async {
        // New project in the current dir
        var project = new Project('<project-name>');

        project.root.directory('web', (web) async {
            // Clone a repo into a directory.
            // By default, the .git dir will be deleted.
            await web.clone('git://path/to/repo');
        });

        project.root.directory('views', (views) async {
            views.file('index.jade', (index) async {
                await index.copyResource('package:example/res/views/index.jade');
                await index.download('http://example.com/index.jade');
                await index.copyFile(new File('/path/to/file'));
            });
            
            views.directory('admin', (admin) async {
                // Without a callback
                var foo = admin.file('foo.txt');

                // Access underlying `dart:io` File or Directory
                await someStream().pipe(foo.io.openWrite());
            });
        });

        // Run all generators and actions, and also run `pub get`
        await project.generate();

        // Pre-build assets
        await project.run(Platform.executable, ['tool/build.dart']);
        await project.pub.build();
    }
}
```

# Maintaining Projects
The API's in `project_gen` only create directories/files if they do not exist, so
they can be used to modify existing projects.

You generally will not need to use callbacks for existing projects.

```dart
import 'package:project_gen/project_gen.dart';

main() async {
    // Load project out of current dir
    var project = await Project.load();

    // Create file if it doesn't exist, otherwise just open the existing one
    var readme = project.file('README.md');
    await readme.download('https://github.com/path/to/readme');
}
```