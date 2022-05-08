import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learningdart/services/auth/bloc/auth_bloc.dart';
import 'package:learningdart/services/auth/bloc/auth_event.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({Key? key}) : super(key: key);

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

void signOutAndReset(context) async {
  context.read<AuthBloc>().add(
        const AuthEventSignOut(),
      );
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify email"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
                "We've sent you a verification email. Please open it to verify your account."),
            const Text(
                "If you haven't received a verification email yet, press the button below."),
            TextButton(
              onPressed: () {
                context.read<AuthBloc>().add(
                      const AuthEventSendEmailVerification(),
                    );
                // await AuthService.firebase().sendEmailVerification();
              },
              child: const Text("Resend verification email"),
            ),
            TextButton(
              onPressed: () => signOutAndReset(context),
              child: const Text("Register using another email"),
            ),
          ],
        ),
      ),
    );
  }
}
