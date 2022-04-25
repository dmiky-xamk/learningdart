// ! Null aware operator ??
// * Valitsee ensimmäisen arvon joka ei ole null
// var nimi = etunimi ?? keskinimi ?? sukunimi

// ! Null-aware assignment operator ??=
// * Asettaa muuttujaan arvon vain jos se on null
// var ikä ??= 18

// ! Conditional invocation
// * Tarkistetaan onko null ennen kuin luetaan property
// nimet?.length

// ! Enumerations
// * Named list of related items
// * Jokainen alkukirjain alkaa isolla
// * Ovat int

// ! Classes
// * Luodaan class joka paketoi yhteen kuuluvat tiedot
// * Classia käyttääkesen siitä luodaan instance 
// * ^ Instanciate -> Luodaan kopio classista joka annetaan ohjelmoijan käytettäväksi
// * Jokainen luokka perii huomaamattomasti "Object" -luokalta

// ! Constructors / Initializer
// * Allow you to create an instance of a class with optional parameters
// * Generative constructor -> palauttaa aina uuden instancen luokasta
// Person(this.name, this.age)

// ! Factory constructors
// * Helpottaa usean saman nimisen class instancen luomista
// * Voi palauttaa jo olemassa olevan instancen luokasta
// factory Cat.viiru() { return Cat("Viiru")}

// ! Method / Instance method
// * Funktio luokan sisällä
// * Instance method = funktio joka on luokasta luotujen instancien käytettävissä
// * Vältä "this" käyttöä metodien sisällä

// ! Inheritance and Subclassing
// * Aliluokka perii ylemmältä luokalta
// class Cat extends LivingThing

// ! Abstract classes
// * Kuten normaali class, mutta siitä ei voida tehdä instanceja
// * Kerää sisälleen logiikkaa vain muiden luokkien käytettäväksi
// * "Utility" class

// ! Custom operators
// * Voi ylikuormittaa operaattoreita (+, -, /) esim. lisäämään luokkia yhteen
// * Alunperin saa perii operaattorit "Object" -luokalta
// * Ne voidaan kuitenkin korvata käyttämällä @override
/*
@override
bool operator == (covariant Cat other) => other.name == name;
*/

// ! Extensions
// * Adding logic to existing classes
// * Käytettävä harkiten -> milloin luodaan metodi ja milloin luodaan extension?
/* 
extension FullName on Person 
{
  String get fullName => "$firstName $lastName";
}
*/

// ! Future
// * Data to be returned in the future (async)
/* 
Future<int> multiply(int a)
{
  return Future.delayed(const Duration(seconds: 3), () => a * 2);
}
*/

// ! Async and await
// * Funktio, jolla voi kestää palauttaa dataa kutsutaan "await" -keywordilla
// * "await" -keywordia käyttävä funktio merkitään "async" -keywordilla

// ! Streams
// * An asynchronous "pipe" of data
// * Data ei koskaan lopu, esim. kellonaika päivittyy koko ajan
/*
Stream<String> getName();
{
  return Stream.value("Foo");

  // * Palauttaa sekunnin välein
  return Stream.periodic(const Duration(seconds: 1), (value) => "Foo");
}

await for (final value in getName())
{
  print(value);
}
*/

// ! Iterable
// * Collection of elements that can be accessed sequentially
// * Kuten string, list, map, set...
// * ELEMENTIT: List: Used to read elements by indexes, Set: Used to contain elements that only occur once, Map: Used to reading elements using a key

// ! Generators
// * Generating "iterables" marked with sync* and async*
// * sync* luo generaattorifunktion, joka palauttaa list of things synkroonisesti
// * async* luo generaattorifunktion joka palauttaa Streamin asynkroonisesti
/*
Iterable<int> getOneTwoThree() sync*
{
  yield 1;
  yield 2;
  yield 3;
}

// * Palauttaa kaikki kerralla
print(getOneTwoThree());

// * Palauttaa yhden kerralla
for (final value in getOneTwoThree())
{
  print(value);
}

// * Asynkrooninen tapa (kutsutaan await for loopissa)
Stream<Iterable<int>> getOneTwoThree() async*
{
  yield [1, 2, 3];
}
*/

// ! Generics
// * To avoid re-writing similar code
// * Kuten templates C++
/*
class Pair<A, B>
{
  final A value1;
  final B value2;

  Pair(this.value1, this.value2);
}

final x = Pair("string", "string");
final y = Pair("string", 5);
*/

// ! Objects
// * Objects are instances of classes

// ! Const
// * Compile time constant

// ! Final
// * Run time constant

// ! Late final
// * Voidaan luoda ilman arvoa, mutta asetettava arvo ennen käyttöä

// ! Versionumero
// * Yleensä kolme tai neljä numeroa pitkä
// * Esim. 1.0.0+1
// * Major number, minor number, build number

/*
Sovelluskehityksessä sovellus alkaa ideasta. Tämä on yleensä versionumero 1.0.0.
Päivityksiä sovellukseen tehdessä mietitään onko päivitys iso (major) vai pieni (minor).
Pienen päivityksen luodessa versionumero päivittyy vähintään yhdellä: 1.1.0.
Build number päivitetään kun sovelluksesta luodaan uusi build?


https://softwareengineering.stackexchange.com/questions/24987/what-exactly-is-the-build-number-in-major-minor-buildnumber-revision
I've never seen it written out in that form. Where I work, we are using the form MAJOR.MINOR.REVISION.BUILDNUMBER, where:

    MAJOR is a major release (usually many new features or changes to the UI or underlying OS)
    MINOR is a minor release (perhaps some new features) on a previous major release
    REVISION is usually a fix for a previous minor release (no new functionality)
    BUILDNUMBER is incremented for each latest build of a revision.

For example, a revision may be released to QA (quality control), and they come back with an issue which requires a change. The bug would be fixed, and released back to QA with the same REVISION number, but an incremented BUILDNUMBER.
*/

// ! Dev dependencies
// * Ulkoista koodia jota käytetään vain kehityksen aikana 
// * Esim. koodintarkastaja ja korjaaja -> lint

// ! Package manager komentoja
// * Lisää dependency
// flutter pub add *
// * Asentaa kaikki dependencyt
// flutter pub get
// * Siivoaa platformin dependencyt
// flutter clean ios

// ! iOS
// * Development certificate
// Antaa mahdollisuuden debugata sovellusta oikealla laitteella
// * Älypuhelimen UUID pitää rekisteröidä Applen sivulla jotta voidaan käyttää debuggaamiseen
// * Luodaan oma profiili kehitykseen (development) sekä julkaisuun (distribution, production)

// ! Hot reload / restart
// * Hot reload toimii suurimmassa osassa tapauksista (state pysyy)
// * Hot restart vaaditaan joskus kun tehty suurempia muutoksia (uusii staten)

// ! Statefulwidget
// * Pitää staten hot reloadin jälkeen

// ! Scaffold
// * Pitää sisällään applikaation

// ! Named routes vs anonymous routes
// * Route on matka joka alkaa näkymästä ja päättyy näkymään
// * Anonymous route on kun näkymä pusketaan aiemman näkymän päälle
// * Named route on kun aiempi näkymä korvataan toisella näkymällä
// * ja named routesta kerrotaan Flutterille etukäteen jotain