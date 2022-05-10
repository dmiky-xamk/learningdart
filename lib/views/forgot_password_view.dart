import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:learningdart/extensions/buildcontext/loc.dart';
import 'package:learningdart/services/auth/auth_exceptions.dart';
import 'package:learningdart/services/auth/bloc/auth_event.dart';
import 'package:learningdart/utilities/dialogs/error_dialog.dart';
import 'package:learningdart/utilities/dialogs/password_reset_email_sent_dialog.dart';

import '../services/auth/bloc/auth_bloc.dart';
import '../services/auth/bloc/auth_state.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final TextEditingController _email;

  @override
  void initState() {
    _email = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // * Luodaan listener jotta voidaan kuunnella AuthStateForgotPassword
    // * luokan eri mahdollisia stateja ja reagoida niihin
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateForgotPassword) {
          if (state.hasSentEmail) {
            _email.clear();
            await showPasswordResetEmailSentDialog(context);
          } else if (state.exception is InvalidEmailAuthException) {
            await showErrorDialog(
              context,
              context.loc.register_error_invalid_email,
            );
          } else if (state.exception is UserNotFoundAuthException) {
            await showErrorDialog(
              context,
              context.loc.login_error_cannot_find_user,
            );
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(
                context, context.loc.forgot_password_view_generic_error);
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.loc.forgot_password),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                context.loc.forgot_password_view_prompt,
              ),
              TextField(
                autocorrect: false,
                autofocus: true,
                controller: _email,
                decoration: InputDecoration(
                    hintText: context.loc.email_text_field_placeholder),
                keyboardType: TextInputType.emailAddress,
              ),
              TextButton(
                onPressed: () {
                  final email = _email.text;
                  context
                      .read<AuthBloc>()
                      .add(AuthEventForgotPassword(email: email));
                },
                child: Text(context.loc.forgot_password_view_send_me_link),
              ),
              TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(
                        const AuthEventSignOut(),
                      );
                },
                child: Text(context.loc.forgot_password_view_back_to_login),
              )
            ],
          ),
        ),
      ),
    );
  }
}
