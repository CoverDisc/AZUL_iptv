part of 'api.dart';

String activeServerFor(UserModel user) {
  final active = locale.read('active_server')?.toString().trim();
  if (active != null && active.isNotEmpty) {
    return active;
  }
  return user.serverInfo?.serverUrl?.trim() ?? '';
}

List<String> provisionedServersFor(UserModel user) {
  final ordered = <String>[];

  void addServer(String? value) {
    final server = value?.trim();
    if (server == null || server.isEmpty || ordered.contains(server)) {
      return;
    }
    ordered.add(server.endsWith('/')
        ? server.substring(0, server.length - 1)
        : server);
  }

  addServer(locale.read('active_server')?.toString());

  final rawServers = locale.read('provisioned_servers');
  if (rawServers is List) {
    final parsed = <ProvisionedServer>[];
    for (final item in rawServers.whereType<Map>()) {
      try {
        parsed.add(
          ProvisionedServer.fromMap(Map<String, dynamic>.from(item)),
        );
      } catch (_) {
        // Ignore a corrupt cached endpoint and continue with valid entries.
      }
    }
    parsed.sort((a, b) => a.priority.compareTo(b.priority));
    for (final server in parsed) {
      addServer(server.baseUrl);
    }
  }

  addServer(user.serverInfo?.serverUrl);
  return ordered;
}

Future<Response<T>> xtreamGet<T>(
  String action, {
  Map<String, dynamic> extraQueryParameters = const {},
  Options? options,
}) async {
  final user = await LocaleApi.getUser();
  if (user == null || user.userInfo == null) {
    throw StateError('No authenticated IPTV user is available.');
  }

  final servers = provisionedServersFor(user);
  if (servers.isEmpty) {
    throw StateError('No provisioned IPTV server is available.');
  }

  DioException? lastTransportError;

  for (final baseUrl in servers) {
    try {
      final endpoint = Uri.parse('$baseUrl/').resolve('player_api.php');
      final response = await _dio.getUri<T>(
        endpoint,
        queryParameters: {
          'username': user.userInfo!.username,
          'password': user.userInfo!.password,
          'action': action,
          ...extraQueryParameters,
        },
        options: options,
      );

      final statusCode = response.statusCode ?? 0;
      if (statusCode >= 200 && statusCode < 300) {
        if (activeServerFor(user) != baseUrl) {
          await locale.write('active_server', baseUrl);
        }
        return response;
      }

      if (statusCode >= 500) {
        continue;
      }

      return response;
    } on DioException catch (error) {
      lastTransportError = error;
      continue;
    }
  }

  if (lastTransportError != null) {
    throw lastTransportError;
  }
  throw StateError('All provisioned IPTV servers are unavailable.');
}
