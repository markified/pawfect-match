import 'package:flutter/material.dart';
import 'paw_text_field.dart';
import '../../tokens/paw_spacing.dart';


class PawTextFieldExample extends StatefulWidget {
  const PawTextFieldExample({super.key});

  @override
  State<PawTextFieldExample> createState() => _PawTextFieldExampleState();
}

class _PawTextFieldExampleState extends State<PawTextFieldExample> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _bioController = TextEditingController();

  String? _emailError;
  bool _emailSuccess = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _validateEmail(String value) {
    setState(() {
      if (value.isEmpty) {
        _emailError = null;
        _emailSuccess = false;
      } else if (!value.contains('@')) {
        _emailError = 'Please enter a valid email address';
        _emailSuccess = false;
      } else {
        _emailError = null;
        _emailSuccess = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PawTextField Examples')),
      body: SingleChildScrollView(
        padding: PawSpacing.screenInsets,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Text Field',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            PawSpacing.verticalSM,
            PawTextField(
              label: 'Dog Name',
              hint: 'Enter your dog\'s name',
              controller: _nameController,
              prefixIcon: const Icon(Icons.pets),
            ),
            PawSpacing.verticalLG,

            const Text(
              'Email Field with Validation',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            PawSpacing.verticalSM,
            PawTextField(
              label: 'Email',
              hint: 'Enter your email address',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(Icons.email),
              errorText: _emailError,
              showSuccessState: _emailSuccess,
              onChanged: _validateEmail,
              helperText: 'We\'ll never share your email',
            ),
            PawSpacing.verticalLG,

            const Text(
              'Password Field',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            PawSpacing.verticalSM,
            PawTextField(
              label: 'Password',
              hint: 'Enter your password',
              controller: _passwordController,
              obscureText: true,
              prefixIcon: const Icon(Icons.lock),
              helperText: 'Must be at least 8 characters',
            ),
            PawSpacing.verticalLG,

            const Text(
              'Multiline Text Field',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            PawSpacing.verticalSM,
            PawTextField(
              label: 'Biography',
              hint: 'Tell us about your dog',
              controller: _bioController,
              maxLines: 5,
              maxLength: 500,
              showCharacterCount: true,
              prefixIcon: const Icon(Icons.description),
            ),
            PawSpacing.verticalLG,

            const Text(
              'Disabled Field',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            PawSpacing.verticalSM,
            const PawTextField(
              label: 'Disabled',
              hint: 'This field is disabled',
              enabled: false,
              prefixIcon: Icon(Icons.block),
            ),
            PawSpacing.verticalXL,
          ],
        ),
      ),
    );
  }
}
