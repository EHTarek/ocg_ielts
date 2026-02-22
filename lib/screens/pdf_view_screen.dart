import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

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
        // title: Text(
        //   'Study Book',
        //   style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        // ),
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_out),
            onPressed: () {
              _pdfViewerController.zoomLevel--;
            },
          ),
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: () {
              _pdfViewerController.zoomLevel++;
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
