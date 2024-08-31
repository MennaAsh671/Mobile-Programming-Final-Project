import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  Database? MyDb;

  Future<Database?> myDatabaseChecker() async {
    if (MyDb == null) {
      MyDb = await initDatabase();
      return MyDb;
    } else {
      return MyDb;
    }
  }

  int Version = 1;
  initDatabase() async {
    String databaseDestination = await getDatabasesPath();
    String databasePath = join(databaseDestination, 'MyDatabase.db');
    Database myDatabase1 = await openDatabase(
      databasePath,
      version: Version,
      onCreate: (db, version) {
        db.execute('''CREATE TABLE IF NOT EXISTS 'TABLE1'(
      'ID' INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      'name' TEXT NOT NULL,
      'mobile' TEXT NOT NULL,
      'email' TEXT NOT NULL,
      'password' TEXT NOT NULL)
       ''');
        print("Database has been created");
      },
    );
    return myDatabase1;
  }

  checking() async {
    String databaseDestination = await getDatabasesPath();
    String databasePath = join(databaseDestination, 'MyDatabase.db');
    await databaseExists(databasePath) ? print("it exists") : print("hardluck");
  }

  resetting() async {
    String databaseDestination = await getDatabasesPath();
    String databasePath = join(databaseDestination, 'MyDatabase.db');
    await deleteDatabase(databasePath);
  }

  reading(sql) async {
    Database? variable = await myDatabaseChecker();
    var response = variable!.rawQuery(sql);
    return response;
  }

  writing(sql) async {
    Database? variable = await myDatabaseChecker();
    var response = variable!.rawInsert(sql);
    return response;
  }

  deleting(sql) async {
    Database? variable = await myDatabaseChecker();
    var response = variable!.rawDelete(sql);
    return response;
  }

  updating(sql) async {
    Database? variable = await myDatabaseChecker();
    var response = variable!.rawUpdate(sql);
    return response;
  }
}
