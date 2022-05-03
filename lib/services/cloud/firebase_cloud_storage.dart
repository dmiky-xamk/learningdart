// * Singleton
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learningdart/services/cloud/cloud_note.dart';
import 'package:learningdart/services/cloud/cloud_storage_constants.dart';
import 'package:learningdart/services/cloud/cloud_storage_exceptions.dart';

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
  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) =>
      notes.snapshots().map((event) => event.docs
          .map((doc) => CloudNote.fromSnapshot(doc))
          .where((note) => note.ownerUserId == ownerUserId));

  void createNewNote({required String ownerUserId}) async {
    await notes.add({
      ownerUserIdFieldName: ownerUserId,
      textFieldName: "",
    });
  }

  Future<Iterable<CloudNote>> fetchNotes({required String ownerUserId}) async {
    try {
      return await notes
          .where(
            ownerUserIdFieldName,
            isEqualTo: ownerUserId,
          )
          .get()
          .then(
            (value) => value.docs.map(
              (doc) {
                return CloudNote(
                  documentId: doc.id,
                  ownerUserId: doc.data()[ownerUserIdFieldName] as String,
                  text: doc.data()[textFieldName] as String,
                );
              },
            ),
          );
    } catch (_) {
      throw CouldNotGetAllNotesException();
    }
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
