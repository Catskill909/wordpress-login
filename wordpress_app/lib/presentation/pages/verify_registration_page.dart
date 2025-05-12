import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:wordpress_app/domain/blocs/auth/auth_bloc.dart';
import 'package:wordpress_app/domain/blocs/auth/auth_event.dart';
import 'package:wordpress_app/domain/blocs/auth/auth_state.dart';
import 'package:wordpress_app/presentation/pages/login_page.dart';
import 'package:wordpress_app/presentation/widgets/loading_overlay.dart';

class VerifyRegistrationPage extends StatefulWidget {
  final String email;

  const VerifyRegistrationPage({
    super.key,
    required this.email,
  });

  @override
  State<VerifyRegistrationPage> createState() => _VerifyRegistrationPageState();
}

class _VerifyRegistrationPageState extends State<VerifyRegistrationPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isSubmitting = false;
  bool _isSuccess = false;

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

          if (state is Unauthenticated) {
            // Registration verification successful
            setState(() {
              _isSuccess = true;
            });
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
          title: const Text('Verify Registration'),
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Go back to the login page
              Navigator.of(context).pop();
            },
          ),
        ),
        body: LoadingOverlay(
          isLoading: _isSubmitting,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: _isSuccess ? _buildSuccessContent() : _buildVerificationForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        const Icon(
          Icons.email_outlined,
          size: 80,
          color: Colors.blue,
        ),
        const SizedBox(height: 20),
        const Text(
          'Verify Your Email',
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
                          _verifyRegistration(formData['code']);
                        }
                      },
                child: _isSubmitting
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text('Verify Email'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: _isSubmitting
                  ? null
                  : () {
                      // Request a new code
                      _requestNewCode();
                    },
              child: const Text('Resend Code'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSuccessContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 40),
        const Icon(
          Icons.check_circle_outline,
          size: 100,
          color: Colors.green,
        ),
        const SizedBox(height: 24),
        const Text(
          'Email Verified!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        const Text(
          'Your email has been successfully verified. You can now log in to your account.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
          onPressed: () {
            // Navigate to login page
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const LoginPage(),
              ),
              (route) => false,
            );
          },
          child: const Text('Go to Login'),
        ),
      ],
    );
  }

  void _verifyRegistration(String code) {
    context.read<AuthBloc>().add(
          VerifyRegistrationEvent(
            email: widget.email,
            code: code,
          ),
        );
  }

  void _requestNewCode() {
    context.read<AuthBloc>().add(
          RequestRegistrationCodeEvent(
            email: widget.email,
          ),
        );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('A new verification code has been sent to your email'),
      ),
    );
  }
}
