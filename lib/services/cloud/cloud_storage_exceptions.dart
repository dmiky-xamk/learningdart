// * Super class for all cloud exceptions
// * Throw subclasses of this class
class CloudStorageException implements Exception {
  // * Constant constructor to make creating instances easier
  const CloudStorageException();
}

// * Jos FireStore ei pysty luomaan notea (Crud -> create)
class CouldNotCreateNoteException extends CloudStorageException {}

// * FireStore ei pystynyt hakemaan kaikkia noteja (esim. nettiyhteys huono) (cRud -> retrieve)
class CouldNotGetAllNotesException extends CloudStorageException {}

// * (crUd -> update)
class CouldNotUpdateNoteException extends CloudStorageException {}

// * (cruD -> delete)
class CouldNotDeleteNoteException extends CloudStorageException {}
