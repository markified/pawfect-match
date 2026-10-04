import 'package:flutter/material.dart';
import 'paw_button.dart';



class PawButtonExampleScreen extends StatefulWidget {
  const PawButtonExampleScreen({super.key});

  @override
  State<PawButtonExampleScreen> createState() => _PawButtonExampleScreenState();
}

class _PawButtonExampleScreenState extends State<PawButtonExampleScreen> {
  bool _isLoading = false;

  void _handleButtonPress(String buttonName) {
    setState(() {
      _isLoading = true;
    });

    
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$buttonName pressed!')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PawButton Examples'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            
            const Text(
              'Button Types',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            PawButton(
              text: 'Primary Button',
              type: PawButtonType.primary,
              onPressed: () => _handleButtonPress('Primary'),
            ),
            const SizedBox(height: 12),
            PawButton(
              text: 'Secondary Button',
              type: PawButtonType.secondary,
              onPressed: () => _handleButtonPress('Secondary'),
            ),
            const SizedBox(height: 12),
            PawButton(
              text: 'Outlined Button',
              type: PawButtonType.outlined,
              onPressed: () => _handleButtonPress('Outlined'),
            ),
            const SizedBox(height: 12),
            PawButton(
              text: 'Text Button',
              type: PawButtonType.text,
              onPressed: () => _handleButtonPress('Text'),
            ),
            const SizedBox(height: 32),

            
            const Text(
              'Button Sizes',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            PawButton(
              text: 'Small Button',
              size: PawButtonSize.small,
              onPressed: () => _handleButtonPress('Small'),
            ),
            const SizedBox(height: 12),
            PawButton(
              text: 'Medium Button',
              size: PawButtonSize.medium,
              onPressed: () => _handleButtonPress('Medium'),
            ),
            const SizedBox(height: 12),
            PawButton(
              text: 'Large Button',
              size: PawButtonSize.large,
              onPressed: () => _handleButtonPress('Large'),
            ),
            const SizedBox(height: 32),

            
            const Text(
              'Buttons with Icons',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            PawButton(
              text: 'Add Dog',
              icon: Icons.add,
              onPressed: () => _handleButtonPress('Add Dog'),
            ),
            const SizedBox(height: 12),
            PawButton(
              text: 'Edit Profile',
              icon: Icons.edit,
              type: PawButtonType.outlined,
              onPressed: () => _handleButtonPress('Edit Profile'),
            ),
            const SizedBox(height: 12),
            PawButton(
              icon: Icons.favorite,
              type: PawButtonType.secondary,
              onPressed: () => _handleButtonPress('Favorite'),
            ),
            const SizedBox(height: 32),

            
            const Text(
              'Loading State',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            PawButton(
              text: 'Submit',
              isLoading: _isLoading,
              onPressed: _isLoading ? null : () => _handleButtonPress('Submit'),
            ),
            const SizedBox(height: 32),

            
            const Text(
              'Disabled State',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const PawButton(
              text: 'Disabled Primary',
              type: PawButtonType.primary,
              onPressed: null,
            ),
            const SizedBox(height: 12),
            const PawButton(
              text: 'Disabled Outlined',
              type: PawButtonType.outlined,
              onPressed: null,
            ),
            const SizedBox(height: 32),

            
            const Text(
              'Full Width Button',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            PawButton(
              text: 'Full Width Button',
              isFullWidth: true,
              onPressed: () => _handleButtonPress('Full Width'),
            ),
          ],
        ),
      ),
    );
  }
}
