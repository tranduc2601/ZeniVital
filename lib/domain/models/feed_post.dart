class FeedPost {
  final String id;
  final String userName;
  final String avatarUrl;
  final String content;
  final DateTime timestamp;
  final int initialKudos;

  const FeedPost({
    required this.id,
    required this.userName,
    required this.avatarUrl,
    required this.content,
    required this.timestamp,
    this.initialKudos = 0,
  });
}
