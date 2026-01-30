import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DateFormatter {
  static String fullDate(DateTime date) {
    return DateFormat('dd/MM/yyyy (EEEE)').format(date);
  }

  static String fullDateTime(DateTime date) {
    final formatted = DateFormat('dd/MM/yyyy (EEEE) hh:mm aa').format(date);
    return formatted.replaceAll('am', 'AM').replaceAll('pm', 'PM');
  }

  static String shortDateTime(DateTime date) {
    final formatted = DateFormat('dd/MM/yyyy  hh:mm aa').format(date);
    return formatted.replaceAll('am', 'AM').replaceAll('pm', 'PM');
  }

  static String shortDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String format24Hour(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  static String format12Hour(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  static String format12HourUpper(DateTime date) {
    return DateFormat('hh:mm a')
        .format(date)
        .replaceAll('am', 'AM')
        .replaceAll('pm', 'PM');
  }

  static String format12HourMinuteSecondsUpper(DateTime date) {
    return DateFormat('hh:mm:ss a')
        .format(date)
        .replaceAll('am', 'AM')
        .replaceAll('pm', 'PM');
  }

  static String formatTimestamp24hour(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();

    if (now.difference(date).inDays == 0) {
      return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } else if (now.difference(date).inDays < 7) {
      const weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
      return weekdays[date.weekday % 7];
    } else {
      return "${date.day}/${date.month}";
    }
  }

  static String formatTimestamp12hour(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();

    if (now.difference(date).inDays == 0) {
      return DateFormat('hh:mm a').format(date);
    } else if (now.difference(date).inDays < 7) {
      const weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
      return weekdays[date.weekday % 7];
    } else {
      return DateFormat('dd/MM').format(date);
    }
  }

  static String formatShortDate(Timestamp timestamp) {
    return DateFormatter.shortDate(timestamp.toDate());
  }

  static String formatLongDate(Timestamp timestamp) {
    return DateFormatter.fullDate(timestamp.toDate());
  }

  static String formatDateTime(Timestamp timestamp) {
    return DateFormatter.fullDateTime(timestamp.toDate());
  }

  static String format12hourDate(Timestamp timestamp) {
    return DateFormatter.formatTimestamp12hour(timestamp);
  }

}
