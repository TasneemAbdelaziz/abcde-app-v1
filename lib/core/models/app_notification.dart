/// A single notification, parsed from `GET /notifications` (the `items` list).
///
/// The seed data has no notifications yet, so the exact field names aren't
/// confirmed. This parser is defensive: it accepts the common variants
/// (title/subject, body/message/text, read_at/is_read, …) and also looks inside
/// a nested `data` object (Laravel-style notifications). When real items start
/// arriving, this should "just work"; tweak the key lists if anything differs.
class AppNotification {
  final String id;
  final String title; // server title (may be in another language)
  final String body;
  final String type; // e.g. 'stage_change'
  final Map<String, dynamic> data; // structured payload, e.g. {stage: 'cath'}
  final DateTime? createdAt;
  final bool read;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.data,
    required this.createdAt,
    required this.read,
  });

  AppNotification copyWith({bool? read}) => AppNotification(
        id: id,
        title: title,
        body: body,
        type: type,
        data: data,
        createdAt: createdAt,
        read: read ?? this.read,
      );

  factory AppNotification.fromJson(Map<String, dynamic> j) {
    final data = j['data'] is Map<String, dynamic>
        ? j['data'] as Map<String, dynamic>
        : const <String, dynamic>{};

    // First non-empty value for any of [keys], looking in j then data.
    String pick(List<String> keys) {
      for (final src in [j, data]) {
        for (final k in keys) {
          final v = src[k];
          if (v != null && '$v'.trim().isNotEmpty) return '$v';
        }
      }
      return '';
    }

    bool read = j['read_at'] != null;
    if (j['is_read'] is bool) read = j['is_read'] as bool;
    if (j['read'] is bool) read = j['read'] as bool;

    return AppNotification(
      id: pick(['id', 'notification_id']),
      title: pick(['title', 'subject', 'heading']),
      body: pick(['body', 'message', 'text', 'content', 'description']),
      type: pick(['type', 'category', 'channel']),
      data: data,
      createdAt: DateTime.tryParse(pick(['created_at', 'sent_at', 'createdAt'])),
      read: read,
    );
  }
}
