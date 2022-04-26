import 'package:flutter/material.dart';
import 'package:learningdart/constants/routes.dart';
import 'package:learningdart/views/services/auth/auth_service.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({Key? key}) : super(key: key);

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

void signOutAndReset(context) async {
  await AuthService.firebase().signOut();
  Navigator.of(context).pushNamedAndRemoveUntil(
    registerRoute,
    (route) => false,
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
              onPressed: () async {
                await AuthService.firebase().sendEmailVerification();
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
