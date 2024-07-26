
import 'package:sqflite/sqlite_api.dart';

class HttpCacheManager {
  final Database db;
  final String tableName;

  HttpCacheManager(this.db, {this.tableName = 'http_cache'});

  Future<HttpCacheData> getData(String key) async {
    final rows = await db.query(
      tableName,
      columns: ['id', 'key', 'data', 'last_modified_at'],
      where: 'key = ?',
      whereArgs: [key],
      orderBy: 'last_modified_at desc',
    );

    if (rows.length == 0) {
      return null;
    }

    if (rows.length > 1) {
      print(
          '[http_cache_manager] multiple entry for $key. Count: ${rows.length} ');
    }

    return HttpCacheData(
      id: rows[0]['id'],
      key: rows[0]['key'],
      data: rows[0]['data'],
      lastModifiedAt: rows[0]['last_modified_at'],
    );
  }

  Future<void> setData(
    String key,
    String data, {
    int lastModifiedAt = -1,
  }) async {
    if (lastModifiedAt == -1) {
      lastModifiedAt = DateTime.now().millisecondsSinceEpoch;
    }
    final cache = await getData(key);

    if (cache == null) {
      await db.insert(tableName, <String, dynamic>{
        'key': key,
        'data': data,
        'last_modified_at': lastModifiedAt,
      });
    } else {
      await db.update(
        tableName,
        <String, dynamic>{
          'data': data,
          'last_modified_at': lastModifiedAt,
        },
        where: 'key = ?',
        whereArgs: [key],
      );
    }
  }
}

class HttpCacheData {
  final int id;
  final String key;
  final String data;
  final int lastModifiedAt;

  HttpCacheData({
    this.id,
    this.key,
    this.data,
    this.lastModifiedAt,
  });

  hasExpired(Duration duration, {DateTime now}) {
    final end = now == null
        ? DateTime.now().millisecondsSinceEpoch
        : now.millisecondsSinceEpoch;

    return lastModifiedAt + duration.inMilliseconds < end;
  }
}
