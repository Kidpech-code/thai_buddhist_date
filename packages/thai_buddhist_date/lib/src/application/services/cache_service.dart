import 'dart:collection';

/// High-performance in-memory cache with LRU eviction and TTL expiry.
class CacheService {
  CacheService({this.maxSize = 1000, this.ttlSeconds = 3600});

  final int maxSize;
  final int ttlSeconds;
  final Map<String, _CacheEntry> _cache = <String, _CacheEntry>{};

  /// Insertion-ordered set used for O(1) LRU tracking.
  final LinkedHashSet<String> _accessOrder = LinkedHashSet<String>();

  int _hits = 0;
  int _misses = 0;

  /// Returns the cached value for [key], or `null` on a miss or expiry.
  T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null) {
      _misses++;
      return null;
    }

    if (_isExpired(entry)) {
      remove(key);
      _misses++;
      return null;
    }

    _hits++;
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

  /// Removes the entry for [key].
  void remove(String key) {
    _cache.remove(key);
    _accessOrder.remove(key);
  }

  /// Clears all entries and resets hit/miss counters.
  void clear() {
    _cache.clear();
    _accessOrder.clear();
    _hits = 0;
    _misses = 0;
  }

  /// Returns a snapshot of cache statistics.
  CacheStats get stats {
    _cleanupExpired();
    final total = _hits + _misses;
    return CacheStats(
      size: _cache.length,
      maxSize: maxSize,
      hitRate: total == 0 ? 0.0 : _hits / total,
    );
  }

  bool _isExpired(_CacheEntry entry) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return (now - entry.timestamp) > (ttlSeconds * 1000);
  }

  void _updateAccessOrder(String key) {
    _accessOrder.remove(key);
    _accessOrder.add(key); // Re-insert at end (most recently used)
  }

  void _evictLeastRecentlyUsed() {
    if (_accessOrder.isNotEmpty) {
      final lruKey = _accessOrder.first;
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
