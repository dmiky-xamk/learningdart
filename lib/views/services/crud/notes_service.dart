import 'dart:async';

import 'crud_exceptions.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory, MissingPlatformDirectoryException;
import 'package:sqflite/sqflite.dart';

// * Crud service joka toimii SQLite databasen kanssa

class NotesService {
  Database? _db;

  // * Caching list of notes
  // * Sisältää ajankohtaiset käyttäjän notet
  List<DatabaseNote> _notes = [];

  // * Singleton (private initializer)
  static final NotesService _shared = NotesService._sharedInstance();
  NotesService._sharedInstance();
  factory NotesService() => _shared;

  // * Yhteys / interface UI:n sekä _notes:in välillä. UI kuuntelee muutoksia tässä streamissa.
  // * "Contains _notes"
  final _notesStreamController =
      StreamController<List<DatabaseNote>>.broadcast();

  Stream<List<DatabaseNote>> get allNotes => _notesStreamController.stream;

  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {
      // empty
    }
  }

  // * FutureBuilder subscribee tähän funktioon, ja rakentaa UI:n tämän palauduttua
  Future<DatabaseUser> getOrCreateUser({required String email}) async {
    try {
      // * Jos getUser heittää errorin -> käyttäjää ei vielä ole -> luodaan uusi käyttäjä
      final user = await getUser(email: email);
      return user;
    } on CouldNotFindUserException {
      final createdUser = await createUser(email: email);
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _cacheNotes() async {
    final allNotes = await getAllNotes();

    // * Lisätään notet paikalliseen muuttujaan
    _notes = allNotes.toList();

    // * Ilmoitetaan streamille päivitetyt notet
    _notesStreamController.add(_notes);
  }

  // * Päivittää noten
  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String text,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    // Make sure note exists
    await getNote(id: note.id);

    // Update DB
    final updatesCount = await db.update(noteTable, {
      textColumn: text,
      isSyncedWithCloudColumn: 0,
    });

    if (updatesCount == 0) {
      throw CouldNotUpdateNoteException();
    }

    final updatedNote = await getNote(id: note.id);

    _notes.removeWhere((note) => note.id == updatedNote.id);
    _notes.add(updatedNote);
    _notesStreamController.add(_notes);

    return updatedNote;
  }

  // * Etsitään kaikki notet
  Future<Iterable<DatabaseNote>> getAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final notes = await db.query(
      noteTable,
    );

    return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
  }

  // * Etsitään note
  Future<DatabaseNote> getNote({required int id}) async {
    await _ensureDbIsOpen();
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

    final note = DatabaseNote.fromRow(notes.first);

    _notes.removeWhere((note) => note.id == id);
    _notes.add(note);
    _notesStreamController.add(_notes);

    return note;
  }

  // * Poistetaan kaikki notet
  Future<int> deleteAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final deletionsCount = await db.delete(noteTable);

    _notes.clear();
    _notesStreamController.add(_notes);

    return deletionsCount;
  }

  // * Poista note
  Future<void> deleteNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      noteTable,
      where: "id = ?",
      whereArgs: [id],
    );

    if (deletedCount == 0) {
      throw CouldNotDeleteNoteException();
    }

    _notes.removeWhere((note) => note.id == id);
    _notesStreamController.add(_notes);
  }

  // * Luo uuden noten
  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    await _ensureDbIsOpen();
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

    _notes.add(note);

    // * Ilmoitetaan streamille päivitetyt notet
    _notesStreamController.add(_notes);

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
    await _ensureDbIsOpen();
    // final _ = _getDatabaseOrThrow();

    final userTableItems = await _queryUserTableItems(email: email);
    final userNotInDatabase = userTableItems.isEmpty;

    if (userNotInDatabase) {
      throw CouldNotFindUserException();
    }

    return DatabaseUser.fromRow(userTableItems.first);
  }

  // * Luodaan käyttäjä
  Future<DatabaseUser> createUser({required String email}) async {
    await _ensureDbIsOpen();
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
    await _ensureDbIsOpen();
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

  // * Avaa databasen tai luo sen tarvittaessa
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

      // * Cache notes
      await _cacheNotes();
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

  // * Otetaan ulkoisesta databasesta tiedot joista luodaan DatabaseNote
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

  // * Otetaan ulkoisesta databasesta tiedot joista luodaan DatabaseNote
  // ? Miksi annetaan Object?
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
