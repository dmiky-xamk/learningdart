// * Luodaan extension kaikille Streameille joiden sisältämä <T> on Iterable
extension Count<T extends Iterable> on Stream<T> {
  Stream<int> get getLength => map((event) => event.length);
}
