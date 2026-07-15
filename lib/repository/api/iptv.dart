part of 'api.dart';

class IpTvApi {
  /// Categories
  Future<List<CategoryModel>> getCategories(String type) async {
    try {
      final response = await xtreamGet<String>(
        type,
        options: Options(responseType: ResponseType.plain),
      );
      if (response.statusCode != 200) return [];

      final decoded = jsonDecode(response.data ?? '[]');
      if (decoded is! List) return [];
      return decoded.map((item) => CategoryModel.fromJson(item)).toList();
    } catch (error) {
      debugPrint('Category request failed: $error');
      return [];
    }
  }

  /// Channels Live
  Future<List<ChannelLive>> getLiveChannels(String catyId) async {
    try {
      final response = await xtreamGet<String>(
        'get_live_streams',
        extraQueryParameters: {
          if (catyId.isNotEmpty) 'category_id': catyId,
        },
        options: Options(responseType: ResponseType.plain),
      );
      if (response.statusCode != 200) return [];

      final decoded = jsonDecode(response.data ?? '[]');
      if (decoded is! List) return [];

      final isAdultFilterEnabled = LocaleApi.getAdultFilter();
      return decoded.map((item) => ChannelLive.fromJson(item)).where((channel) {
        if (!isAdultFilterEnabled) return true;
        return !_containsAdultMarker(channel.name);
      }).toList();
    } catch (error) {
      log('Live channel request failed: $error');
      return [];
    }
  }

  /// Channels Movie
  Future<List<ChannelMovie>> getMovieChannels(String catyId) async {
    try {
      final response = await xtreamGet<String>(
        'get_vod_streams',
        extraQueryParameters: {
          if (catyId.isNotEmpty) 'category_id': catyId,
        },
        options: Options(responseType: ResponseType.plain),
      );
      if (response.statusCode != 200) return [];

      final decoded = jsonDecode(response.data ?? '[]');
      if (decoded is! List) return [];

      final isAdultFilterEnabled = LocaleApi.getAdultFilter();
      return decoded.map((item) => ChannelMovie.fromJson(item)).where((channel) {
        if (!isAdultFilterEnabled) return true;
        return !_containsAdultMarker(channel.name);
      }).toList();
    } catch (error) {
      debugPrint('Movie channel request failed: $error');
      return [];
    }
  }

  /// Channels Series
  Future<List<ChannelSerie>> getSeriesChannels(String catyId) async {
    try {
      final response = await xtreamGet<String>(
        'get_series',
        extraQueryParameters: {
          if (catyId.isNotEmpty) 'category_id': catyId,
        },
        options: Options(responseType: ResponseType.plain),
      );
      if (response.statusCode != 200) return [];

      final decoded = jsonDecode(response.data ?? '[]');
      if (decoded is! List) return [];

      final isAdultFilterEnabled = LocaleApi.getAdultFilter();
      return decoded.map((item) => ChannelSerie.fromJson(item)).where((channel) {
        if (!isAdultFilterEnabled) return true;
        return !_containsAdultMarker(channel.name);
      }).toList();
    } catch (error) {
      debugPrint('Series channel request failed: $error');
      return [];
    }
  }

  /// Movie Detail
  static Future<MovieDetail?> getMovieDetails(String movieId) async {
    try {
      final response = await xtreamGet<String>(
        'get_vod_info',
        extraQueryParameters: {'vod_id': movieId},
        options: Options(responseType: ResponseType.plain),
      );
      if (response.statusCode != 200) return null;

      final decoded = jsonDecode(response.data ?? '{}');
      if (decoded is! Map<String, dynamic>) return null;
      return MovieDetail.fromJson(decoded);
    } catch (error) {
      debugPrint('Movie detail request failed: $error');
      return null;
    }
  }

  /// Serie Detail
  static Future<SerieDetails?> getSerieDetails(String serieId) async {
    try {
      final response = await xtreamGet<String>(
        'get_series_info',
        extraQueryParameters: {'series_id': serieId},
        options: Options(responseType: ResponseType.plain),
      );
      if (response.statusCode != 200) return null;

      final decoded = jsonDecode(response.data ?? '{}');
      if (decoded is! Map<String, dynamic>) return null;
      return SerieDetails.fromJson(decoded);
    } catch (error) {
      debugPrint('Series detail request failed: $error');
      return null;
    }
  }

  /// EPG LIVE
  static Future<List<EpgModel>> getEPGbyStreamId(String streamId) async {
    try {
      final response = await xtreamGet<String>(
        'get_short_epg',
        extraQueryParameters: {'stream_id': streamId},
        options: Options(responseType: ResponseType.plain),
      );
      if (response.statusCode != 200) return [];

      final decoded = jsonDecode(response.data ?? '{}');
      if (decoded is! Map) return [];
      final listings = decoded['epg_listings'];
      if (listings is! List) return [];
      return listings.map((item) => EpgModel.fromJson(item)).toList();
    } catch (error) {
      debugPrint('EPG request failed: $error');
      return [];
    }
  }

  static bool _containsAdultMarker(String? value) {
    final normalized = (value ?? '').toLowerCase();
    return normalized.contains('18+') ||
        normalized.contains('+18') ||
        normalized.contains('adult') ||
        normalized.contains('xxx') ||
        normalized.contains('للكبار');
  }
}
