import 'crud_exceptions.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory, MissingPlatformDirectoryException;
import 'package:sqflite/sqflite.dart';

// * Crud service joka toimii SQLite databasen kanssa

class NotesService {
  Database? _db;

  // Database get db => _getDatabaseOrThrow();

  // * Päivittää noten
  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String text,
  }) async {
    final db = _getDatabaseOrThrow();

    await getNote(id: note.id);

    final updatesCount = await db.update(noteTable, {
      textColumn: text,
      isSyncedWithCloudColumn: 0,
    });

    if (updatesCount == 0) {
      throw CouldNotUpdateNoteException();
    }

    return await getNote(id: note.id);
  }

  // * Etsitään kaikki notet
  Future<Iterable<DatabaseNote>> getAllNotes() async {
    final db = _getDatabaseOrThrow();

    final notes = await db.query(
      noteTable,
    );

    return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
  }

  // * Etsitään note
  Future<DatabaseNote> getNote({required int id}) async {
    final db = _getDatabaseOrThrow();

    final notes = await db.query(
      noteTable,
      limit: 1,
      where: "id = ?",
      whereArgs: [id],
    );

    if (notes.isEmpty) {
      throw CouldNotFindNoteException();
    }

    return DatabaseNote.fromRow(notes.first);
  }

  // * Poistetaan kaikki notet
  Future<int> deleteAllNotes() async {
    final db = _getDatabaseOrThrow();

    return await db.delete(noteTable);
  }

  // * Poista note
  Future<void> deleteNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      noteTable,
      where: "id = ?",
      whereArgs: [id],
    );

    if (deletedCount == 0) {
      throw CouldNotDeleteNoteException();
    }
  }

  // * Luo uuden noten
  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    final db = _getDatabaseOrThrow();

    //  Make sure the owner exists in the database with the correct id
    final dbUser = await getUser(email: owner.email);

    if (dbUser != owner) {
      throw CouldNotFindUserException();
    }

    const text = "";

    // Create the note
    final noteId = await db.insert(noteTable, {
      userIdColumn: owner.id,
      textColumn: text,
      isSyncedWithCloudColumn: 1,
    });

    final note = DatabaseNote(
      id: noteId,
      userId: owner.id,
      text: text,
      isSyncedWithCloud: true,
    );

    return note;
  }

  // * Palauttaa listan käyttäjän datasta
  Future<List> _queryUserTableItems({required String email}) async {
    final db = _getDatabaseOrThrow();

    final results = await db.query(
      userTable,
      limit: 1,
      where: "email = ?",
      whereArgs: [email.toLowerCase()],
    );

    return results;
  }

  // * Haetaan käyttäjä sähköpostin perusteella
  Future<DatabaseUser> getUser({required String email}) async {
    final db = _getDatabaseOrThrow();

    final userTableItems = await _queryUserTableItems(email: email);
    final userNotInDatabase = userTableItems.isEmpty;

    if (userNotInDatabase) {
      throw CouldNotFindUserException();
    }

    return DatabaseUser.fromRow(userTableItems.first);
  }

  // * Luodaan käyttäjä
  Future<DatabaseUser> createUser({required String email}) async {
    final db = _getDatabaseOrThrow();

    // * Tarkistetaan eihän samalla sähköpostilla ole jo käyttäjää
    final userTableItems = await _queryUserTableItems(email: email);
    final isUserInDatabase = userTableItems.isNotEmpty;

    if (isUserInDatabase) {
      throw UserAlreadyExistsException();
    }

    final userId = await db.insert(userTable, {
      emailColumn: email.toLowerCase(),
    });

    return DatabaseUser(
      id: userId,
      email: email,
    );
  }

  // * Poistetaan käyttäjä databasesta
  Future<void> deleteUser({required String email}) async {
    final db = _getDatabaseOrThrow();

    // * Poistetaan userTablesta sähköpostit, joiden arvo on email.toLowerCase()
    final deletedCount = await db.delete(
      userTable,
      where: "email = ?",
      whereArgs: [email.toLowerCase()],
    );

    // * Service voi heittää exceptionin, jotta se voidaan käsitellä
    // * halutulla tavalla UI koodin puolella
    if (deletedCount != 1) {
      throw CouldNotDeleteUserException();
    }
  }

  // * Apufunktio jottei tarvitse tehdä samaa if-lauseketta useassa funktiossa
  Database _getDatabaseOrThrow() {
    final db = _db;

    if (db == null) {
      throw DatabaseNotOpenException();
    } else {
      return db;
    }
  }

  // * Avaa databasen ja luo databasen tarvittaessa
  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }

    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      // Create user table
      await db.execute(createUserTable);

      // Create note table
      await db.execute(createNoteTable);
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectoryException();
    }
  }

  // * Sulkee databasen
  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseNotOpenException();
    } else {
      await db.close();
      _db = null;
    }
  }
}

// * Class on periaatteessa sama user table joka oli DB Browserissa
@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({
    required this.id,
    required this.email,
  });

  // ? Miten tämä toimii?
  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => "Person, ID = $id, email $email";

  // * Käytetään covariant jotta voidaan verrata _saman tyyppisen_ classin kanssa (ei vain Object tyyppisten)
  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  const DatabaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
  });

  // ? Miten tämä toimii?
  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSyncedWithCloud =
            (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

  @override
  String toString() =>
      "Note, ID = $id, userId = $userId, isSyncedWithCloud = $isSyncedWithCloud, text = $text";

  // * Käytetään covariant jotta voidaan verrata _saman tyyppisen_ classin kanssa (ei vain Object tyyppisten)
  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = "notes.db";
const userTable = "user";
const noteTable = "note";
const idColumn = "id";
const emailColumn = "email";
const userIdColumn = "user_id";
const textColumn = "text";
const isSyncedWithCloudColumn = "is_synced_with_cloud";

const createUserTable = """
CREATE TABLE IF NOT EXISTS "user" (
  "id"	INTEGER NOT NULL,
  "email"	TEXT NOT NULL UNIQUE,
  PRIMARY KEY("id" AUTOINCREMENT)
);
""";

const createNoteTable = """
CREATE TABLE IF NOT EXISTS "note" (
  "id"	INTEGER NOT NULL,
  "user_id"	INTEGER NOT NULL,
  "text"	TEXT,
  "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
  FOREIGN KEY("user_id") REFERENCES "user"("id"),
  PRIMARY KEY("id" AUTOINCREMENT)
);""";
