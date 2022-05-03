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
// * Anonymous route on kun uusi widget pusketaan aiemman näkymän päälle
// * Named routesta kerrotaan Flutterille main funktiossa, ja se pusketaan aiemman näkymän päälle
// /login/, /register/ ...

// ! Print vs Log
// * Printillä tulostetut asiat jäävät puhelimeen muistiin
// * Importataan devtools jonka log funktiota voidaan käyttää printin sijasta

// ! Pushing
// * Sanan käyttö nousi suosiossa iOS ja Androidin takia v. 2007
// * Laitteella näkymästä toiseen siirtyessä uusi näkymä "pushataan" vanhan päälle

// ! pushNamedAndRemoveUntil
// * Pusketaan nimetty näkymä aiemman näkymän päälle ja poistetaan kaikki sitä edeltävät näkymät
// * Esim. onnistuneen kirjautumisen jälkeen ei ole tarvetta pitää kirjautumisnäkymää enää uuden näkymän alapuolella
// * Toisen argumentin ollessa false poistetaan kaikki aiemmat näkymät

// ! Immutable
// * Tarkoittaa että luomisen jälkeen classin tai sen lapsien sisältö ei muutu

// ! Tests
// * Kolme erityyppistä testiä jota voit tehdä Flutterissa:
// Unit tests: Unit voi olla jokin erillinen koodinpätkä tai luokka
// Testataan esim. että AuthService -luokka toimii oikein ja suorittaa kaikki sillä tarkotetut toimenpiteet onnistuneesti

// Widget tests: Sovelluksen UI toimivuutta varmistavia testejä
// Esim. Käyttäjän kirjautuessa kirjautumis painike muuttuu disabled

// Integration tests: Testataan koko sovelluksen toimimista käyttäjän näkökulmasta

// * KOMENTO:
// flutter test test/auth_test.dart

// ! Mocking
// * Testauksessa luodaan esim. testattavasta luokasta kopio, joka ei ole riippuvainen ulkoisista tekijöistä.
// * Testaus voisi epäonnistua esim. palvelimen virheen takia, joihin meillä ei ole vaikutusvaltaa,
// * joten testissä palvelin korvataan omalla datalla.

// ! CRUD Local Storage
// * Create Read Update Delete
// * Neljä perimmäistä toimenpidettä jota datalle voidaan tehdä

// ! SQLite
// * Database-engine (Django ja Flask käyttää tätä(?))
// Mietitään SQLiteä erilissinä komponentteina:
// - Database: Tiedosto joka on levyllä
// - SQLEngine: Pystyy lukemaan ja kirjoittamaan Databaseen
// SQLEngine tarvitsee ympäristön suorittamista varten. 

// ! Databases
// * Tietokannoissa Tableilla on niitä yksilöivä "id" tai "primary key"
// * Yksilöivä avain on yleensä tyyppiä INTEGER
// * Primary key on Tablen itse hallittava tunnistetieto
// user { id: 5 }

// * Foreign key on toisessa Tablessa sijaitseva tunnistetieto
// * joka linkkaa tämän ja toisen tablen yhteen
// FOREIGN KEY("user_id") REFERENCES "user"("id")

// ! Path provider
// * Mobiililaitteilla sovelluksilla on oma "Documents" -kansio
// * jonka path tarvitaan tietokanta tiedoston tallentamiseen sinne

// ! Streams
// * Pipe of data that you can manipulate and perform operations on

// ! Stream controller
// * Interface to your streams
// * Evolution of a value through time

// ! Singleton
// * Class instance where that instance is the only one in the entire application

// ! Collections and Documents (chapter 36)
// * NoSQL is more document based than SQL / SQLite
// * Looser data definition

// * Collection is a group of related objects (esim. notes)
// * Jokaisella käyttäjällä voisi olla oma notes collection esim. käyttäjä ID:n mukaan

// * Document is an object inside a collection (esim. käyttäjän note)

// ! Plugin vs Package
// * Package extends the current capabilities of Flutter
// * Plugin menee Flutterin kykyjen yli
// * Plugin täytyy kirjoittaa eri alustoille omana koodinaan

// ! State management
// * "We have our business logic inside our UI and that's usually not a good idea"
// * Eritellään käyttöliittymän logiikka ja businesslogiikka toisistaan

// ! Bloc
// * Käyttää sisäisesti Streamseja sekä Futureja
// * Tämän käytöllä varmistetaan että UI hoitaa vain visuaalisen puolen
// * eikä tiedä business logiikasta
// * Tarvitaan lisäksi flutter_bloc, jotta voidaan yhdistää Dart -kieltä käyttävä businesslogiikka UI:n kanssa

// * TEORIA

// * Bloc class (the core of the Bloc library)
// Tähän lisätään eventtejä, ja lisätyt eventit voivat tuottaa "staten"
// Class alkaa statella -> output on aina state. (esim. logged in, logged out, error screen...)
// Classin input on events. (esim. log in with this info, register with this info...)

// * BlocProvider
// Instance Bloc classista 

// * BlocListener
// Kuuntelee ja reagoi muutoksiin Bloc statessa

// * BlocBuilder
// Tuottaa widgetin Bloc staten muutoksien mukaan

// * BlocConsumer
// Yhdistää Listenerin ja Builderin.
// Mahdollista kuunnella muutoksia Blocissa ja reagoida niihin side-effectillä ja tai widgetillä