part of 'api.dart';

class ProvisioningException implements Exception {
  final String code;
  final String message;

  const ProvisioningException(this.code, this.message);

  @override
  String toString() => message;
}

class ProvisionedServer {
  final String baseUrl;
  final int priority;

  const ProvisionedServer({
    required this.baseUrl,
    required this.priority,
  });

  factory ProvisionedServer.fromMap(Map<String, dynamic> map) {
    final rawUrl = (map['baseUrl'] ?? map['url'] ?? '').toString().trim();
    final uri = Uri.tryParse(rawUrl);

    if (uri == null ||
        !uri.hasScheme ||
        !uri.hasAuthority ||
        (uri.scheme != 'https' && uri.scheme != 'http')) {
      throw const ProvisioningException(
        'invalid-server',
        'The service configuration contains an invalid server.',
      );
    }

    final normalizedUrl = rawUrl.endsWith('/')
        ? rawUrl.substring(0, rawUrl.length - 1)
        : rawUrl;

    return ProvisionedServer(
      baseUrl: normalizedUrl,
      priority: int.tryParse((map['priority'] ?? 100).toString()) ?? 100,
    );
  }

  Map<String, dynamic> toMap() => {
        'baseUrl': baseUrl,
        'priority': priority,
      };
}

class ProvisioningApi {
  static const _functionName = 'resolveServerProfile';
  static const _functionRegion = 'europe-west1';

  FirebaseFunctions get _functions =>
      FirebaseFunctions.instanceFor(region: _functionRegion);

  Future<List<ProvisionedServer>> resolveServiceCode(String serviceCode) async {
    final normalizedCode = serviceCode.trim().toUpperCase();

    if (!RegExp(r'^[A-Z0-9]{3,12}$').hasMatch(normalizedCode)) {
      throw const ProvisioningException(
        'invalid-code',
        'Enter a valid service code.',
      );
    }

    if (Firebase.apps.isEmpty) {
      throw const ProvisioningException(
        'firebase-not-configured',
        'The service directory is not configured on this build.',
      );
    }

    try {
      final callable = _functions.httpsCallable(_functionName);
      final result = await callable.call<dynamic>({'code': normalizedCode});
      final data = Map<String, dynamic>.from(result.data as Map);

      if (data['enabled'] != true) {
        throw const ProvisioningException(
          'service-disabled',
          'This service code is not active.',
        );
      }

      final rawServers = data['servers'];
      if (rawServers is! List || rawServers.isEmpty) {
        throw const ProvisioningException(
          'no-servers',
          'No server is available for this service code.',
        );
      }

      final servers = rawServers
          .whereType<Map>()
          .map((item) => ProvisionedServer.fromMap(
                Map<String, dynamic>.from(item),
              ))
          .toList()
        ..sort((a, b) => a.priority.compareTo(b.priority));

      final uniqueServers = <String, ProvisionedServer>{};
      for (final server in servers) {
        uniqueServers.putIfAbsent(server.baseUrl, () => server);
      }

      if (uniqueServers.isEmpty) {
        throw const ProvisioningException(
          'no-servers',
          'No valid server is available for this service code.',
        );
      }

      final resolved = uniqueServers.values.toList();
      await locale.write(
        'provisioning_$normalizedCode',
        resolved.map((server) => server.toMap()).toList(),
      );
      await locale.write('last_service_code', normalizedCode);

      return resolved;
    } on FirebaseFunctionsException catch (error) {
      final cached = _readCachedProfile(normalizedCode);
      if (_isTransientFirebaseError(error.code) && cached.isNotEmpty) {
        return cached;
      }

      switch (error.code) {
        case 'not-found':
          throw const ProvisioningException(
            'unknown-code',
            'Service code not found.',
          );
        case 'failed-precondition':
          throw ProvisioningException(
            'service-unavailable',
            error.message ?? 'This service code is currently unavailable.',
          );
        case 'permission-denied':
          throw const ProvisioningException(
            'permission-denied',
            'This app is not authorized to access the service directory.',
          );
        default:
          throw ProvisioningException(
            error.code,
            error.message ?? 'Unable to load the service configuration.',
          );
      }
    } on ProvisioningException {
      rethrow;
    } catch (_) {
      final cached = _readCachedProfile(normalizedCode);
      if (cached.isNotEmpty) {
        return cached;
      }

      throw const ProvisioningException(
        'provisioning-unavailable',
        'Unable to contact the service directory.',
      );
    }
  }

  List<ProvisionedServer> _readCachedProfile(String normalizedCode) {
    final raw = locale.read('provisioning_$normalizedCode');
    if (raw is! List) {
      return [];
    }

    try {
      final servers = raw
          .whereType<Map>()
          .map((item) => ProvisionedServer.fromMap(
                Map<String, dynamic>.from(item),
              ))
          .toList()
        ..sort((a, b) => a.priority.compareTo(b.priority));
      return servers;
    } catch (_) {
      return [];
    }
  }

  bool _isTransientFirebaseError(String code) {
    return code == 'unavailable' ||
        code == 'deadline-exceeded' ||
        code == 'internal';
  }
}
