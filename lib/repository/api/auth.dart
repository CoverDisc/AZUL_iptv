part of 'api.dart';

class AuthApi {
  final ProvisioningApi _provisioningApi;

  AuthApi({ProvisioningApi? provisioningApi})
      : _provisioningApi = provisioningApi ?? ProvisioningApi();

  Future<UserModel?> registerUser(
    String username,
    String password,
    String serviceCode,
    String name,
  ) async {
    List<ProvisionedServer> servers;

    try {
      servers = await _provisioningApi.resolveServiceCode(serviceCode);
    } on ProvisioningException catch (error) {
      debugPrint('Service provisioning failed: ${error.code}');
      return null;
    }

    for (final server in servers) {
      try {
        final endpoint = Uri.parse('${server.baseUrl}/')
            .resolve('player_api.php')
            .replace(
          queryParameters: {
            'username': username,
            'password': password,
          },
        );

        final Response<String> response = await _dio.getUri<String>(endpoint);
        if (response.statusCode != 200 || response.data == null) {
          continue;
        }

        final decoded = jsonDecode(response.data!);
        if (decoded is! Map<String, dynamic>) {
          continue;
        }

        final rawUserInfo = decoded['user_info'];
        if (rawUserInfo is! Map) {
          continue;
        }

        final userInfo = Map<String, dynamic>.from(rawUserInfo);
        final isAuthenticated = userInfo['auth'].toString() == '1';
        final status = userInfo['status']?.toString().trim().toLowerCase();

        // A valid Xtream response with a rejected or inactive account is an
        // account problem, not a server outage. Do not try other endpoints.
        if (!isAuthenticated || status != 'active') {
          return null;
        }

        final user = UserModel.fromJson(decoded, server.baseUrl);
        await LocaleApi.saveUser(user);
        await locale.write('service_code', serviceCode.trim().toUpperCase());
        await locale.write('active_server', server.baseUrl);
        await locale.write(
          'provisioned_servers',
          servers.map((item) => item.toMap()).toList(),
        );
        return user;
      } on DioException {
        // Transport errors and unavailable endpoints trigger the next server.
        continue;
      } on FormatException {
        continue;
      } catch (_) {
        continue;
      }
    }

    return null;
  }
}
