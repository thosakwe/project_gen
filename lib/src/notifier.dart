import 'package:console/console.dart';
import 'package:intl/intl.dart';

class Notifier {
  final DateFormat _fmt = new DateFormat.Hms();
  final TextPen _pen = new TextPen();

  void _showDate() {
    _pen
      ..reset()
      ..lightGray()
      ..lightCyan()
      ..text('[')
      ..yellow()
      ..text(_fmt.format(new DateTime.now()))
      ..lightCyan()
      ..text('] ')
      ..normal();
  }

  void busy(String message) {
    _showDate();
    _pen
      ..blue()
      ..text(message)
      ..print();
  }

  void creatingProject(String name) {
    _showDate();
    _pen
      ..lightGray()
      ..text('Generating project ')
      ..cyan()
      ..text("'$name'")
      ..lightGray()
      ..text('...')
      ..print();
  }

  void error(String message) {
    _showDate();
    _pen
      ..red()
      ..text(Icon.BALLOT_X)
      ..text(' ' + message)
      ..print();
  }

  void success(String message) {
    _showDate();
    _pen
      ..green()
      ..text(Icon.CHECKMARK)
      ..text(' ' + message)
      ..print();
  }

  void task(String message) {
    _showDate();
    _pen
      ..lightGray()
      ..text(message)
      ..print();
  }
}
