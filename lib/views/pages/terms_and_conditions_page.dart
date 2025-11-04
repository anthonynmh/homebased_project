import 'package:flutter/material.dart';

class TermsPage extends StatefulWidget {
  const TermsPage({super.key});

  @override
  State<TermsPage> createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage> {
  bool _agreed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/ion_home.png',
              width: 30,
              height: 30,
              color: const Color(0xFFFF7949),
            ),
            const SizedBox(width: 8),
            const Text(
              'Terms of Service',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable Terms Text
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  child: const Text(
                    '''
Welcome to Knock Knock!

Please read these Terms of Service carefully before using our app. 
By using the app, you agree to be bound by these terms.

1. **Usage**
   You agree to use this app responsibly and for lawful purposes only.

2. **Account**
   You are responsible for maintaining the confidentiality of your account and password.

3. **Privacy**
   We respect your privacy. Please review our Privacy Policy to understand how we handle your data.

4. **Termination**
   We may suspend or terminate accounts that violate our terms.

5. **Updates**
   These terms may change over time. Continued use of the app constitutes acceptance of any updates.

Thank you for being part of our community!
                    ''',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),

            const Divider(height: 1),

            // Checkbox + Continue
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _agreed,
                        activeColor: const Color(0xFFFF7949),
                        onChanged: (value) {
                          setState(() {
                            _agreed = value ?? false;
                          });
                        },
                      ),
                      const Expanded(
                        child: Text(
                          "I have read and agree to the Terms of Service",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _agreed
                          ? () => Navigator.pop(context, true)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF7949),
                        disabledBackgroundColor: Colors.grey[400],
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Continue",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
