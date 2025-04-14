import 'package:intl/intl.dart';

String formatTimeAgo(DateTime? dateTime) {
  if (dateTime == null) {
    return ''; // Or 'Date unknown'
  }

  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inSeconds < 60) {
    return 'now';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes}m ago';
  } else if (difference.inHours < 24) {
    return '${difference.inHours}h ago';
  } else if (difference.inDays < 7) {
    return '${difference.inDays}d ago';
  } else {
    return DateFormat('dd MMM').format(dateTime);
  }
}

String changeDateFormat(DateTime date, String format) {
  try {

    return DateFormat(format).format(date);
  } catch (e) {
    return 'Invalid date';
  }
}
