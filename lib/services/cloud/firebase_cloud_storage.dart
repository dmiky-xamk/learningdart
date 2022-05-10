import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learningdart/services/cloud/cloud_note.dart';
import 'package:learningdart/services/cloud/cloud_storage_constants.dart';
import 'package:learningdart/services/cloud/cloud_storage_exceptions.dart';

// * Singleton
class FirebaseCloudStorage {
  // * Talking with FireStore -> grabbing all notes
  // * CollectionReference = stream you can read from and write to
  // * notes = collection nimi FireStoressa
  final notes = FirebaseFirestore.instance.collection("notes");

  // ? Jokaisella notella on oma ID notes collectionin sisällä
  // esim. notes/note1

  Future<void> deleteNote({required String documentId}) async {
    try {
      // * documentId on path dokumenttiin (notes/documentId)
      await notes.doc(documentId).delete();
    } catch (_) {
      throw CouldNotDeleteNoteException();
    }
  }

  Future<void> updateNote({
    required String documentId,
    required String text,
  }) async {
    try {
      // * documentId on path dokumenttiin (notes/documentId)
      await notes.doc(documentId).update({textFieldName: text});
    } catch (_) {
      throw CouldNotUpdateNoteException();
    }
  }

  // * Stream jolle UI pystyy subscribeemaan ja saamaan käyttäjän notet
  // * .snapshots() lukee noteja reaaliaikasesti (see all the changes as they are happening)
  // * Streamin sisällä on dokumentit, joista tehdään oma CloudNote instance
  // * jos noten omistajan ID on sama kuin käyttäjän ID
  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) {
    final allNotes = notes
        .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
        .snapshots()
        .map((event) => event.docs.map((doc) => CloudNote.fromSnapshot(doc)));

    return allNotes;
  }

  Future<CloudNote> createNewNote({required String ownerUserId}) async {
    final document = await notes.add({
      ownerUserIdFieldName: ownerUserId,
      textFieldName: "",
    });

    final fetchedNote = await document.get();

    return CloudNote(
      documentId: fetchedNote.id,
      ownerUserId: ownerUserId,
      text: "",
    );
  }

  // * Kutsuu private constructoria
  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();

  // * Private constructor
  FirebaseCloudStorage._sharedInstance();

  // * Factory constructor
  // * Kutsuu static final fieldiä
  factory FirebaseCloudStorage() => _shared;
}
