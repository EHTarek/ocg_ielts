import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../widgets/media_bottom_sheet.dart';

class PDFViewScreen extends StatefulWidget {
  final String assetPath;

  const PDFViewScreen({super.key, required this.assetPath});

  @override
  State<PDFViewScreen> createState() => _PDFViewScreenState();
}

class _PDFViewScreenState extends State<PDFViewScreen> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const MediaBottomSheet(),
              );
            },
          ),
        ],
      ),
      body: SfPdfViewer.asset(
        widget.assetPath,
        controller: _pdfViewerController,
        key: _pdfViewerKey,
        interactionMode: PdfInteractionMode.pan,
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        spacing: 8,
        children: [
          FloatingActionButton(
            heroTag: 'prev',
            onPressed: () => _pdfViewerController.previousPage(),
            mini: true,
            child: const Icon(Icons.keyboard_arrow_up),
          ),
          FloatingActionButton(
            heroTag: 'next',
            onPressed: () => _pdfViewerController.nextPage(),
            mini: true,
            child: const Icon(Icons.keyboard_arrow_down),
          ),
        ],
      ),
    );
  }
}
