import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learningdart/constants/routes.dart';
import 'package:learningdart/services/auth/bloc/auth_bloc.dart';
import 'package:learningdart/services/auth/bloc/auth_event.dart';
import 'package:learningdart/services/auth/bloc/auth_state.dart';
import 'package:learningdart/services/auth/firebase_auth_provider.dart';
import 'package:learningdart/utilities/dialogs/error_dialog.dart';
import 'package:learningdart/views/login_view.dart';
import 'package:learningdart/views/notes/create_update_note_view.dart';
import 'package:learningdart/views/register_view.dart';
import 'package:learningdart/views/verify_email_view.dart';
import 'views/notes/notes_view.dart';
import 'dart:developer' as devtools show log;

// * Luodaan stateless HomePage widget
// * Tämä INITIALIZEE Firebasen ja valitsee
// * oikean näkymän riippuen käyttäjän statesta (kirjautunut vai ei)

// * Joissain tapauksissa Firebasen kanssa ennen initializeApp:in suorittamista
// * käyttäjä voi olla null.

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // ? BlocProvider injectaa AuthBlocin koko sovelluksen contextiin
      home: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(FirebaseAuthProvider()),
        child: const HomePage(),
      ),
      // * Named routes
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        notesRoute: (context) => const NotesView(),
        verifyEmailRoute: (context) => const VerifyEmailView(),
        createOrUpdateNoteRoute: (context) => const CreateUpdateNoteView(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ? Voidaan lukea BlocProviderin injektoima AuthBloc, ja kommunikoida
    // ? sen kanssa .add metodilla lähettämällä eventin
    context.read<AuthBloc>().add(const AuthEventInitialize());

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthStateSignedIn) {
          return const NotesView();
        } else if (state is AuthStateNeedsVerification) {
          return const VerifyEmailView();
        } else if (state is AuthStateSignedOut) {
          return const LoginView();
        } else {
          return const Scaffold(
            body: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

/*
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CounterBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Bloc Counter"),
        ),
        // * Tarvitaan consumer, sillä jokaisen napin painalluksen jälkeen halutaan tyhjentää tekstikenttä (side-effect)
        body: BlocConsumer<CounterBloc, CounterState>(
          listener: (context, state) {
            // * Jokaisen uuden staten (listener kuuntelee) yhteydessä nollataan tekstikenttä (builder tekee)
            _controller.clear();
          },
          builder: (context, state) {
            // * Builder palauttaa widgetin staten perusteella (onko invalid vai ei)
            final invalidValue =
                (state is CounterStateInvalidNumber) ? state.invalidValue : "";

            return Column(
              children: [
                Text("Current value is: ${state.value}"),
                Visibility(
                  child: Text("Invalid input: $invalidValue"),
                  visible: state is CounterStateInvalidNumber,
                ),
                TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: "Enter a number here",
                  ),
                  keyboardType: TextInputType.number,
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        // * Painettaessa otetaan tekstikentän arvo ja lähetetään Blocille event
                        context
                            .read<CounterBloc>()
                            .add(DecrementEvent(_controller.text));
                      },
                      child: const Text("-"),
                    ),
                    TextButton(
                      onPressed: () {
                        // * Painettaessa otetaan tekstikentän arvo ja lähetetään Blocille event
                        context
                            .read<CounterBloc>()
                            .add(IncrementEvent(_controller.text));
                      },
                      child: const Text("+"),
                    ),
                  ],
                )
              ],
            );
          },
        ),
      ),
    );
  }
}

// * Blocin ulostulo on state, joten voidaan luoda siitä oma class
@immutable
abstract class CounterState {
  final int value;
  const CounterState(this.value);
}

// * State voi olla invalid (käyttäjä antaa merkkijonon) tai valid (antaa numeron)
class CounterStateValid extends CounterState {
  const CounterStateValid(int value) : super(value);
}

class CounterStateInvalidNumber extends CounterState {
  final String invalidValue;

  const CounterStateInvalidNumber({
    required this.invalidValue,
    required int previousValue,
  }) : super(previousValue);
}

// * Event on Blocin sisääntulo
// * Event täytyy triggeröidä UI:ssa ja lähetää Blocille
@immutable
abstract class CounterEvent {
  final String value;

  const CounterEvent(this.value);
}

class IncrementEvent extends CounterEvent {
  const IncrementEvent(String value) : super(value);
}

class DecrementEvent extends CounterEvent {
  const DecrementEvent(String value) : super(value);
}

// * Tälle classille UI lähettää eventejä (increment tällä arvolla, decrement tällä arvolla)
class CounterBloc extends Bloc<CounterEvent, CounterState> {
  // * Jokaisella Blocilla oltava initial state -> menee superille
  CounterBloc() : super(const CounterStateValid(0)) {
    on<IncrementEvent>(((event, emit) {
      final integer = int.tryParse(event.value);

      if (integer == null) {
        // * Emit lähettää staten ulos
        emit(
          CounterStateInvalidNumber(
            invalidValue: event.value,
            previousValue: state.value,
          ),
        );
      } else {
        emit(CounterStateValid(state.value + integer));
      }
    }));

    on<DecrementEvent>(((event, emit) {
      final integer = int.tryParse(event.value);

      if (integer == null) {
        // * Emit lähettää staten ulos
        emit(
          CounterStateInvalidNumber(
            invalidValue: event.value,
            previousValue: state.value,
          ),
        );
      } else {
        emit(CounterStateValid(state.value - integer));
      }
    }));
  }
}
*/