class WordpressPost {
  final int id;
  final String title;
  final String content;
  final String excerpt;
  final String slug;
  final String status;
  final String link;
  final DateTime date;
  final DateTime modified;
  final int author;
  final int featuredMedia;
  final List<int> categories;
  final List<int> tags;
  final String format;
  final bool sticky;
  final String? featuredMediaUrl; // To be fetched via /media endpoint if needed

  WordpressPost({
    required this.id,
    required this.title,
    required this.content,
    required this.excerpt,
    required this.slug,
    required this.status,
    required this.link,
    required this.date,
    required this.modified,
    required this.author,
    required this.featuredMedia,
    required this.categories,
    required this.tags,
    required this.format,
    required this.sticky,
    this.featuredMediaUrl,
  });

  factory WordpressPost.fromJson(Map<String, dynamic> json) {
    return WordpressPost(
      id: json['id'],
      title: json['title']['rendered'],
      content: json['content']['rendered'],
      excerpt: json['excerpt']['rendered'],
      slug: json['slug'],
      status: json['status'],
      link: json['link'],
      date: DateTime.parse(json['date']),
      modified: DateTime.parse(json['modified']),
      author: json['author'],
      featuredMedia: json['featured_media'],
      categories: List<int>.from(json['categories'] ?? []),
      tags: List<int>.from(json['tags'] ?? []),
      format: json['format'],
      sticky: json['sticky'],
      // featuredMediaUrl can be fetched separately if needed
    );
  }
}
