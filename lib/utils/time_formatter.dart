import 'package:intl/intl.dart';

final timeFormatter = DateFormat('a h:mm', 'ko_KR');
String formatTime(DateTime timestamp) {
  final formatter = DateFormat('a h:mm', 'ko');
  return formatter
      .format(timestamp)
      .replaceAll('AM', '오전')
      .replaceAll('PM', '오후');
}
