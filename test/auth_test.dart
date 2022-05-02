import 'package:learningdart/views/services/auth/auth_exceptions.dart';
import 'package:learningdart/views/services/auth/auth_provider.dart';
import 'package:learningdart/views/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group("Mock Authentication", () {
    final provider = MockAuthProvider();

    test("Should not be initialized to begin with", () {
      expect(
        provider.isInitalized,
        false,
      );
    });

    test("Cannot log out if not initialized", () {
      expect(
        provider.signOut(),
        throwsA(isA<NotInitializedException>()),
      );
    });

    test(
      "Should be able to be initialized",
      () async {
        await provider.initialize();
        expect(provider.isInitalized, true);
      },
    );

    test(
      "User should be null after initialization",
      () {
        expect(provider.currentUser, null);
      },
    );

    // * Testing timeout (if something takes longer than x amount)
    test(
      "Should be able to initialize in less than 2 seconds",
      () async {
        await provider.initialize();
        expect(provider.isInitalized, true);
      },
      timeout: const Timeout(Duration(seconds: 2)),
    );

    // ? Useampi yhden testin sisällä :(
    test("SignUp should delegate to signIn function", () async {
      final badEmailUser = provider.signUp(
        email: "foo@bar.com",
        password: "anypassword",
      );

      expect(
        badEmailUser,
        throwsA(isA<UserNotFoundAuthException>()),
      );

      final badPasswordUser = provider.signUp(
        email: "anyemail@lol.com",
        password: "foobar",
      );

      expect(badPasswordUser, throwsA(isA<WrongPasswordAuthException>()));

      final user = await provider.signUp(
        email: "foo",
        password: "bar",
      );

      expect(provider.currentUser, user);
      expect(user.isEmailVerified, false);
    });

    test("Logged in user should be able to get verified", () {
      provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });

    test("Should be able to sign out and sign in again", () async {
      await provider.signOut();
      await provider.signIn(
        email: "email",
        password: "password",
      );

      final user = provider.currentUser;
      expect(user, isNotNull);
    });
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  // * Luo automaattisesti "null"
  AuthUser? _user;
  var _isInitialized = false;

  bool get isInitalized => _isInitialized;

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitalized) throw NotInitializedException();
    final user = _user;

    // * Tarkistaa onhan käyttäjä olemassa ensin
    if (user == null) throw UserNotFoundAuthException();

    const newUser = AuthUser(isEmailVerified: true, email: templateEmail);

    _user = newUser;
  }

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) {
    if (!isInitalized) throw NotInitializedException();

    // * Testejä tälle funktiolle
    if (email == "foo@bar.com") throw UserNotFoundAuthException();
    // if (!email.contains("@")) throw InvalidEmailAuthException();
    // if (email.trim().isEmpty) throw InvalidEmailAuthException();
    if (password == "foobar") throw WrongPasswordAuthException();

    const user = AuthUser(isEmailVerified: false, email: templateEmail);
    _user = user;

    return Future.value(_user);
  }

  @override
  Future<void> signOut() async {
    if (!isInitalized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundAuthException();

    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<AuthUser> signUp({
    required String email,
    required String password,
  }) async {
    if (!isInitalized) throw NotInitializedException();

    // * Tee rekisteröitymiselle omia testejä
    await Future.delayed(const Duration(seconds: 1));
    return signIn(
      email: email,
      password: password,
    );
  }
}

const templateEmail = "foo@bar.baz";
