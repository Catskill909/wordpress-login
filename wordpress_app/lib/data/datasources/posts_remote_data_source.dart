import 'package:dio/dio.dart';
import 'package:wordpress_app/data/models/wordpress_post.dart';

class PostsRemoteDataSource {
  final Dio dio;
  PostsRemoteDataSource({required this.dio});

  Future<List<WordpressPost>> fetchPostsByCategory(int categoryId) async {
    final response = await dio.get(
      'https://djchucks.com/tester/wp-json/wp/v2/posts',
      queryParameters: {
        'categories': categoryId,
        'per_page': 20,
        '_embed': true, // To get author/media details
      },
    );
    if (response.statusCode == 200) {
      final List data = response.data;
      return data.map((json) => WordpressPost.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }
}
