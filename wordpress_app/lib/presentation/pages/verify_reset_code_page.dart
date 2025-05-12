import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:wordpress_app/domain/blocs/auth/auth_bloc.dart';
import 'package:wordpress_app/domain/blocs/auth/auth_event.dart';
import 'package:wordpress_app/domain/blocs/auth/auth_state.dart';
import 'package:wordpress_app/presentation/pages/reset_password_page.dart';
import 'package:wordpress_app/presentation/widgets/loading_overlay.dart';

class VerifyResetCodePage extends StatefulWidget {
  final String email;

  const VerifyResetCodePage({
    super.key,
    required this.email,
  });

  @override
  State<VerifyResetCodePage> createState() => _VerifyResetCodePageState();
}

class _VerifyResetCodePageState extends State<VerifyResetCodePage> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          setState(() {
            _isSubmitting = true;
          });
        } else {
          setState(() {
            _isSubmitting = false;
          });

          if (state is PasswordResetCodeVerified) {
            // Navigate to reset password page
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ResetPasswordPage(
                  email: state.email,
                  resetToken: state.resetToken,
                ),
              ),
            );
          } else if (state is AuthError) {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Verify Code'),
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Go back to the forgot password page
              Navigator.of(context).pop();
            },
          ),
        ),
        body: LoadingOverlay(
          isLoading: _isSubmitting,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Icon(
                  Icons.lock_reset,
                  size: 80,
                  color: Colors.blue,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Verify Reset Code',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Enter the verification code sent to ${widget.email}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                FormBuilder(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.disabled,
                  child: Column(
                    children: [
                      FormBuilderTextField(
                        name: 'code',
                        decoration: const InputDecoration(
                          labelText: 'Verification Code',
                          hintText: 'Enter the 6-digit code',
                          prefixIcon: Icon(Icons.security),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.minLength(6,
                              errorText: 'Code must be 6 digits'),
                          FormBuilderValidators.maxLength(6,
                              errorText: 'Code must be 6 digits'),
                          FormBuilderValidators.numeric(),
                        ]),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: _isSubmitting
                            ? null
                            : () {
                                if (_formKey.currentState?.saveAndValidate() ??
                                    false) {
                                  final formData = _formKey.currentState!.value;
                                  context.read<AuthBloc>().add(
                                        VerifyPasswordResetCodeEvent(
                                          email: widget.email,
                                          code: formData['code'],
                                        ),
                                      );
                                }
                              },
                        child: _isSubmitting
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text('Verify Code'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        // Go back to the forgot password page
                        Navigator.of(context).pop();
                      },
                      child: const Text('Back to Forgot Password'),
                    ),
                    TextButton(
                      onPressed: _isSubmitting
                          ? null
                          : () {
                              // Request a new code
                              context.read<AuthBloc>().add(
                                    RequestPasswordResetCodeEvent(
                                      email: widget.email,
                                    ),
                                  );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'A new verification code has been sent to your email'),
                                ),
                              );
                            },
                      child: const Text('Resend Code'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
