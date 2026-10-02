/// Editorial date labels — "Today · 14:20", "Yesterday", "27 September".
abstract final class DateLabels {
  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static String relative(DateTime at, {DateTime? now}) {
    final n = now ?? DateTime.now();
    final day = DateTime(at.year, at.month, at.day);
    final today = DateTime(n.year, n.month, n.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return 'Today · ${_two(at.hour)}:${_two(at.minute)}';
    if (diff == 1) return 'Yesterday';
    final month = _months[at.month - 1];
    return at.year == n.year
        ? '${at.day} $month'
        : '${at.day} $month ${at.year}';
  }

  /// Compact recency — "Just now", "2h ago", "Yesterday", "4 days ago".
  static String ago(DateTime at, {DateTime? now}) {
    final n = now ?? DateTime.now();
    final d = n.difference(at);
    if (d.inMinutes < 1) return 'Just now';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    final day = DateTime(at.year, at.month, at.day);
    final days = DateTime(n.year, n.month, n.day).difference(day).inDays;
    if (days == 0) return '${d.inHours}h ago';
    if (days == 1) return 'Yesterday';
    if (days < 7) return '$days days ago';
    return relative(at, now: n);
  }

  static String _two(int v) => v.toString().padLeft(2, '0');
}
