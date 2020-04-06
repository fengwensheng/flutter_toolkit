import 'package:sqflite/sqflite.dart';

// Future<Database> createDataBase(String fileName) async {
//   return await openDatabase(fileName);
// }

Future<void> deleteDataBase(String fileName) async {
  await deleteDatabase(fileName);
}

Future<void> createTable(Database database, List table,[String tableName="UserInfo"]) async {
  await database.execute('CREATE TABLE $tableName (${table.join(",")})');
}

Future<void> insertValue(Database database, Map<String, String> value,[String tableName="UserInfo"]) async {
  await database.transaction((txn) async {
    await txn.rawInsert(
        'INSERT INTO $tableName(${value.keys.join(",")}) VALUES(${value.values.join(",")})');
  });
}
