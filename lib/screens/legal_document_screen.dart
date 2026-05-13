import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LegalDocumentScreen extends StatelessWidget {
  final String title;
  final String body;

  const LegalDocumentScreen({
    super.key,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: SelectableText(
            body,
            style: GoogleFonts.poppins(
              fontSize: 14,
              height: 1.55,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
