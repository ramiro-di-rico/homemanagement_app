import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_management_app/data/local/local_category.service.dart';
import 'package:home_management_app/data/local/local_database.dart';
import 'package:home_management_app/data/services/sources/category_data_source.dart';
import 'package:home_management_app/domain/models/category.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  late Directory dir;
  late File file;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('migration');
    file = File('${dir.path}/local.sqlite');
  });

  tearDown(() => dir.deleteSync(recursive: true));

  /// A database exactly as schema 1 left it: names unique through an ASCII-only
  /// `lower(name)` index, and no `name_key` column.
  void createSchema1(List<String> categoryNames) {
    final raw = sqlite.sqlite3.open(file.path);
    raw.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL CHECK (length(name) BETWEEN 1 AND 100),
        icon TEXT NOT NULL,
        color TEXT NOT NULL DEFAULT '#ffffff',
        measurable INTEGER NOT NULL DEFAULT 1,
        is_active INTEGER NOT NULL DEFAULT 1,
        server_id INTEGER NULL UNIQUE
      );
      CREATE UNIQUE INDEX categories_name_lower ON categories (lower(name));
    ''');
    for (final name in categoryNames) {
      raw.execute("INSERT INTO categories (name, icon) VALUES (?, 'x')", [name]);
    }
    raw.execute('PRAGMA user_version = 1');
    raw.close();
  }

  test('schema 1 data gets its name keys and keeps working', () async {
    createSchema1(['Rent', 'Útiles', 'Café']);

    final db = LocalDatabase(NativeDatabase(file));
    final rows = await db.select(db.categories).get();

    expect(rows.map((c) => (c.name, c.nameKey)),
        [('Rent', 'rent'), ('Útiles', 'útiles'), ('Café', 'café')]);
    expect((await db.customSelect('PRAGMA user_version').getSingle()).data.values.first, 2);
    final indexes = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'index' AND tbl_name = 'categories'")
        .get();
    expect(indexes.map((r) => r.read<String>('name')), contains('categories_name_key'));
    expect(indexes.map((r) => r.read<String>('name')), isNot(contains('categories_name_lower')));

    await expectLater(
        LocalCategoryService(db).add(CategoryModel(0, 0, 'ÚTILES', 'x', true, true, '#ffffff')),
        throwsA(isA<CategoryNameTakenException>()));
    await db.close();
  });

  test('names that only differed by accents are both kept, with distinct keys', () async {
    // Schema 1 allowed "Útiles" and "útiles" together, because lower() ignores accents.
    createSchema1(['Útiles', 'útiles']);

    final db = LocalDatabase(NativeDatabase(file));
    final rows = await db.select(db.categories).get();

    expect(rows.map((c) => c.name), ['Útiles', 'útiles']);
    expect(rows.map((c) => c.nameKey).toSet(), hasLength(2));
    await db.close();
  });

  test('a new database starts at schema 2 with keyed default categories', () async {
    final db = LocalDatabase(NativeDatabase(file));

    final rows = await db.select(db.categories).get();
    expect(rows.every((c) => c.nameKey == categoryNameKey(c.name) && c.nameKey.isNotEmpty), isTrue);
    expect((await db.customSelect('PRAGMA user_version').getSingle()).data.values.first, 2);
    await db.close();
  });
}
