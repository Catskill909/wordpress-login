import 'package:flutter/material.dart';
import 'package:wordpress_app/data/models/wordpress_post.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart'; // Add to pubspec.yaml if not present

class PostDetailPage extends StatelessWidget {
  final WordpressPost post;
  const PostDetailPage({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(post.title)), // Removed unnecessary interpolation
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.title,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.person, size: 18, color: Colors.grey),
                const SizedBox(width: 4),
                Text('Author #${post.author}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(width: 16),
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  post.date.toLocal().toString().split(' ')[0],
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (post.featuredMediaUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  post.featuredMediaUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Center(child: Icon(Icons.broken_image)),
                  ),
                ),
              ),
            if (post.featuredMediaUrl != null) const SizedBox(height: 20),
            HtmlWidget(
              post.content,
              textStyle: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 8,
              children: [
                Chip(label: Text('ID: ${post.id}')),
                Chip(label: Text('Slug: ${post.slug}')),
                Chip(label: Text('Status: ${post.status}')),
                Chip(label: Text('Format: ${post.format}')),
                if (post.sticky) const Chip(label: Text('Sticky', style: TextStyle(color: Colors.white),), backgroundColor: Colors.deepOrange),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
