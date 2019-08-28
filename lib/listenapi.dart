import 'package:dio/dio.dart';
import 'models.dart';

class ListenAPI {
  static final String baseUrl = 'https://listen-api.listennotes.com/api/v2';
  static final String apiKey = '8c5425ad6ed043838fbddab4ecc7c2e8';
  final Dio dio = Dio();

  Future<Podcast> getPodcast(String id, {sort = 'recent_first'}) async {
    print('retrieving podcast $id');

    var response = await dio.get('$baseUrl/podcasts/$id?sort=$sort', options: Options(headers: _headers()));

    if (response.statusCode == 200) {
      return Podcast.fromJson(response.data);
    }

    return null;
  }

  Map<String, String> _headers() {
    return {'X-ListenAPI-Key': apiKey};
  }
}
