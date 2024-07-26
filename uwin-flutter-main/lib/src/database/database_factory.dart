import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseFactory {
  Future<Database> create(String filepath, int version) async {
    final doc = await getDatabasesPath();
    final path = join(doc, filepath);

    return openDatabase(path, version: version,
        onCreate: (Database newDb, int version) {
      newDb.execute("""
          CREATE TABLE http_cache (
            id INTEGER primary key,
            key Text NOT NULL UNIQUE,
            last_modified_at INTEGER NOT NULL,
            data Text NOT NULL
          )
        """);
    });
  }
}
