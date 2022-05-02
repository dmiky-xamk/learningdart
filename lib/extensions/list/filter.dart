// * Funktion sisällä voidaan päästä käsiksi T:hen

// * Stream containing List of things
// * We want a stream of List containing the same things
// * if the thing passes the test (where clause)
extension Filter<T> on Stream<List<T>> {
  Stream<List<T>> filter(bool Function(T) where) =>
      map((items) => items.where(where).toList());
}

// * Stream jossa on lista joka sisältää asioita
// * Halutaan stream jossa on lista joka sisältää samat asiat,
// * jos yksittäinen asia läpäisee testin