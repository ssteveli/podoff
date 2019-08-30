import 'dart:async';

import 'package:podcast/player_manager.dart';
import 'package:sqflite/sqflite.dart';

class Db {
  final PlayerManager playerManager;
  Database _db;

  Db({this.playerManager}) {
    _initialize();
  }

  void _initialize() async {
    _db = await openDatabase('poddoff.db', version: 1, onCreate: (Database db, int version) async {
      // When creating the db, create the table
      await db.execute('CREATE TABLE Positions (id VARCHAR(255) PRIMARY KEY, position INTEGER)');
      await db.execute('CREATE TABLE Locals (id VARCHAR(255) PRIMARY KEY, path VARCHAR(255))');
    });

    playerManager?.addListener(() async {
      if (playerManager.currentId != null && playerManager.position != null) {
        await _db.execute('INSERT OR REPLACE INTO Positions (id, position) VALUES (?,?)',
            [playerManager.currentId, playerManager.position.inMilliseconds]);
      }
    });
  }

  Future<int> currentPosition(String id) async {
    return Sqflite.firstIntValue(await _db.rawQuery('SELECT position FROM Positions WHERE id = ?', [id]));
  }

  Future<void> updateLocals(String id, String path) async {
    await _db.rawQuery('INSERT OR RELACE INTO Locals (id, path) VALUES (?,?)', [id, path]);
  }

  Future<void> delete(String id) async {
    await _db.rawQuery('DELETE FROM Locals WHERE id = ?', [id]);
  }

  Future<bool> exists(String id) async {
    return Sqflite.firstIntValue(await _db.rawQuery('SELECT COUNT(*) FROM Locals WHERE id = ?', [id])) >= 1;
  }

  void close() {
    _db?.close();
  }
}
