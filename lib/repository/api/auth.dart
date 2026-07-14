part of 'api.dart';

class AuthApi {
  Future<UserModel?> registerUser(
    String username,
    String password,
    String link,
    String name,
  ) async {
    try {
      final normalizedLink = link.endsWith('/') ? link : '$link/';
      final endpoint = Uri.parse(normalizedLink).resolve('player_api.php').replace(
        queryParameters: {
          'username': username,
          'password': password,
        },
      );

      final Response<String> response = await _dio.getUri<String>(endpoint);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.data ?? '');
        final user = UserModel.fromJson(json, link);
        await LocaleApi.saveUser(user);
        return user;
      }

      return null;
    } catch (e) {
      debugPrint('IPTV authentication failed: $e');
      return null;
    }
  }
}
