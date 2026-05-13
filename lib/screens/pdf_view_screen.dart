import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../config/app_config.dart';
import '../l10n/app_localizations.dart';
import '../widgets/media_bottom_sheet.dart';

enum _PdfDownloadState { checking, needsDownload, downloading, ready, error }

/// Thrown when the download completed but the file's leading bytes are not
/// the PDF magic number (e.g., the URL served HTML, an LFS pointer, or got
/// truncated to empty). Surfaced via a localized message rather than the
/// raw exception toString.
class _NotAPdfException implements Exception {
  const _NotAPdfException();
  @override
  String toString() => '_NotAPdfException';
}

class PDFViewScreen extends StatefulWidget {
  const PDFViewScreen({super.key});

  @override
  State<PDFViewScreen> createState() => _PDFViewScreenState();
}

class _PDFViewScreenState extends State<PDFViewScreen> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  _PdfDownloadState _state = _PdfDownloadState.checking;
  File? _localFile;
  int _received = 0;
  int? _total;
  Object? _error;

  HttpClient? _httpClient;
  StreamSubscription<List<int>>? _subscription;
  IOSink? _sink;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/${AppConfig.bookPdfFileName}');
      if (await file.exists() && await file.length() > 0) {
        if (!mounted) return;
        setState(() {
          _localFile = file;
          _state = _PdfDownloadState.ready;
        });
        return;
      }
      if (!mounted) return;
      setState(() => _state = _PdfDownloadState.needsDownload);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _state = _PdfDownloadState.error;
      });
    }
  }

  Future<void> _startDownload() async {
    setState(() {
      _state = _PdfDownloadState.downloading;
      _received = 0;
      _total = null;
      _error = null;
    });

    final dir = await getApplicationDocumentsDirectory();
    final target = File('${dir.path}/${AppConfig.bookPdfFileName}');
    final part = File('${target.path}.part');

    // Use dart:io HttpClient — auto-follows redirects (GitHub raw URLs always
    // 302 to a CDN-signed objects.githubusercontent.com URL) and transparently
    // decompresses Content-Encoding: gzip responses. The package:http
    // Client.send(Request) flow exposes a raw stream so any gzipped response
    // would land on disk as compressed bytes and SfPdfViewer would see junk.
    final client = HttpClient();
    _httpClient = client;

    try {
      if (await part.exists()) {
        await part.delete();
      }
      final sink = part.openWrite();
      _sink = sink;

      final request = await client.getUrl(Uri.parse(AppConfig.bookPdfUrl));
      request.followRedirects = true;
      request.maxRedirects = 8;
      final response = await request.close();

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'HTTP ${response.statusCode}',
          uri: request.uri,
        );
      }

      if (mounted && response.contentLength > 0) {
        setState(() => _total = response.contentLength);
      }

      final completer = Completer<void>();
      _subscription = response.listen(
        (chunk) {
          sink.add(chunk);
          _received += chunk.length;
          if (mounted) setState(() {});
        },
        onDone: () => completer.complete(),
        onError: completer.completeError,
        cancelOnError: true,
      );

      await completer.future;
      await sink.flush();
      await sink.close();
      _sink = null;
      _subscription = null;

      // Sanity-check: a real PDF starts with the ASCII magic "%PDF". If the
      // download silently returned HTML (404 page, login wall, LFS pointer)
      // we'd otherwise rename it to book.pdf and SfPdfViewer would show a
      // blank page instead of erroring.
      final header = await part.openRead(0, 5).fold<List<int>>(
        <int>[],
        (acc, chunk) => acc..addAll(chunk),
      );
      final headerOk = header.length >= 4 &&
          header[0] == 0x25 && // %
          header[1] == 0x50 && // P
          header[2] == 0x44 && // D
          header[3] == 0x46;   // F
      if (!headerOk) {
        throw const _NotAPdfException();
      }

      await part.rename(target.path);
      client.close();
      _httpClient = null;

      if (!mounted) return;
      setState(() {
        _localFile = target;
        _state = _PdfDownloadState.ready;
      });
    } catch (e) {
      await _cleanupDownload();
      try {
        if (await part.exists()) {
          await part.delete();
        }
      } catch (_) {}
      if (!mounted) return;
      setState(() {
        _error = e;
        _state = _PdfDownloadState.error;
      });
    }
  }

  Future<void> _cleanupDownload() async {
    await _subscription?.cancel();
    _subscription = null;
    try {
      await _sink?.close();
    } catch (_) {}
    _sink = null;
    _httpClient?.close(force: true);
    _httpClient = null;
  }

  @override
  void dispose() {
    _cleanupDownload();
    super.dispose();
  }

  String _formatBytes(int bytes) {
    const mb = 1024 * 1024;
    return '${(bytes / mb).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
      body: _buildBody(context, l10n),
      floatingActionButton: _state == _PdfDownloadState.ready
          ? Column(
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
            )
          : null,
    );
  }

  Widget _buildBody(BuildContext context, AppLocalizations l10n) {
    switch (_state) {
      case _PdfDownloadState.checking:
        return const Center(child: CircularProgressIndicator());

      case _PdfDownloadState.needsDownload:
        return _PromptCard(
          icon: Icons.cloud_download_outlined,
          title: l10n.downloadBookTitle,
          message: l10n.downloadBookMessage,
          action: FilledButton.icon(
            onPressed: _startDownload,
            icon: const Icon(Icons.download),
            label: Text(l10n.downloadBookButton),
          ),
        );

      case _PdfDownloadState.downloading:
        final total = _total;
        final progress = (total != null && total > 0)
            ? _received / total
            : null;
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.downloadingBookTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(value: progress),
                    const SizedBox(height: 12),
                    Text(
                      total != null
                          ? l10n.downloadingBookSize(
                              _formatBytes(_received),
                              _formatBytes(total),
                            )
                          : l10n.downloadingBookSizeUnknown(
                              _formatBytes(_received),
                            ),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

      case _PdfDownloadState.error:
        final message = _error is _NotAPdfException
            ? l10n.downloadInvalidPdf
            : (_error?.toString() ?? '');
        return _PromptCard(
          icon: Icons.error_outline,
          title: l10n.downloadFailedTitle,
          message: message,
          action: FilledButton.tonalIcon(
            onPressed: _startDownload,
            icon: const Icon(Icons.refresh),
            label: Text(l10n.downloadRetryButton),
          ),
        );

      case _PdfDownloadState.ready:
        return SfPdfViewer.file(
          _localFile!,
          controller: _pdfViewerController,
          key: _pdfViewerKey,
          interactionMode: PdfInteractionMode.pan,
        );
    }
  }
}

class _PromptCard extends StatelessWidget {
  const _PromptCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(icon, size: 56, color: scheme.primary),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                action,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
