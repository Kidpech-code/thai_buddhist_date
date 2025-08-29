/// High-performance in-memory cache service
/// Uses LRU (Least Recently Used) eviction policy for memory efficiency
class CacheService {
  CacheService({this.maxSize = 1000, this.ttlSeconds = 3600});

  final int maxSize;
  final int ttlSeconds;
  final Map<String, _CacheEntry> _cache = <String, _CacheEntry>{};
  final Map<String, String> _accessOrder = <String, String>{};

  /// Get cached value
  T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;

    // Check TTL
    if (_isExpired(entry)) {
      remove(key);
      return null;
    }

    // Update access order for LRU
    _updateAccessOrder(key);

    return entry.value as T?;
  }

  /// Set cached value with automatic LRU eviction
  void set<T>(String key, T value) {
    // Remove expired entries first
    _cleanupExpired();

    // Evict if at capacity
    if (_cache.length >= maxSize && !_cache.containsKey(key)) {
      _evictLeastRecentlyUsed();
    }

    final entry = _CacheEntry(
      value: value,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    _cache[key] = entry;
    _updateAccessOrder(key);
  }

  /// Remove specific entry
  void remove(String key) {
    _cache.remove(key);
    _accessOrder.remove(key);
  }

  /// Clear all entries
  void clear() {
    _cache.clear();
    _accessOrder.clear();
  }

  /// Get cache statistics
  CacheStats get stats {
    _cleanupExpired();
    return CacheStats(
      size: _cache.length,
      maxSize: maxSize,
      hitRate: 0.0, // Could be implemented with counters
    );
  }

  bool _isExpired(_CacheEntry entry) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return (now - entry.timestamp) > (ttlSeconds * 1000);
  }

  void _updateAccessOrder(String key) {
    _accessOrder.remove(key);
    _accessOrder[key] = key; // Move to end (most recent)
  }

  void _evictLeastRecentlyUsed() {
    if (_accessOrder.isNotEmpty) {
      final lruKey = _accessOrder.keys.first;
      remove(lruKey);
    }
  }

  void _cleanupExpired() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final expiredKeys = <String>[];

    _cache.forEach((key, entry) {
      if ((now - entry.timestamp) > (ttlSeconds * 1000)) {
        expiredKeys.add(key);
      }
    });

    for (final key in expiredKeys) {
      remove(key);
    }
  }
}

class _CacheEntry {
  const _CacheEntry({required this.value, required this.timestamp});

  final Object? value;
  final int timestamp;
}

class CacheStats {
  const CacheStats({
    required this.size,
    required this.maxSize,
    required this.hitRate,
  });

  final int size;
  final int maxSize;
  final double hitRate;

  @override
  String toString() =>
      'CacheStats(size: $size/$maxSize, hitRate: ${(hitRate * 100).toStringAsFixed(1)}%)';
}
