import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// LRU cache manager for profile images.
class ProfileImageCacheManager extends CacheManager {
  static const key = 'profileImageCache';

  static final ProfileImageCacheManager _instance =
      ProfileImageCacheManager._internal();

  factory ProfileImageCacheManager() => _instance;

  ProfileImageCacheManager._internal()
      : super(Config(
          key,
          maxNrOfCacheObjects: 50,
          stalePeriod: const Duration(days: 7),
        ));
}
