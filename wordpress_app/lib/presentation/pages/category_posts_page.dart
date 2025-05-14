import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:wordpress_app/data/datasources/posts_remote_data_source.dart';
import 'package:wordpress_app/data/models/wordpress_post.dart';
import 'post_detail_page.dart';

class CategoryPostsPage extends StatefulWidget {
  final String categoryName;
  final int categoryId;
  const CategoryPostsPage({super.key, required this.categoryName, required this.categoryId});

  @override
  State<CategoryPostsPage> createState() => _CategoryPostsPageState();
}

class _CategoryPostsPageState extends State<CategoryPostsPage> {
  late Future<List<WordpressPost>> _futurePosts;
  late final PostsRemoteDataSource _dataSource;

  @override
  void initState() {
    super.initState();
    _dataSource = PostsRemoteDataSource(dio: Dio());
    _futurePosts = _dataSource.fetchPostsByCategory(widget.categoryId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.categoryName} Posts')),
      body: FutureBuilder<List<WordpressPost>>(
        future: _futurePosts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: \\${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No posts found.'));
          }
          final posts = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: posts.length,
            separatorBuilder: (context, i) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final post = posts[i];
              return Card(
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.article),
                  title: Text(post.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                  subtitle: Text(post.excerpt.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '').trim(), maxLines: 2, overflow: TextOverflow.ellipsis),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PostDetailPage(post: post),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
