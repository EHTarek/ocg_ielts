import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_config.dart';
import '../l10n/app_localizations.dart';
import '../legal/legal_texts.dart';
import '../models/app_theme.dart';
import '../providers/theme_provider.dart';
import 'legal_document_screen.dart';

final packageInfoProvider = FutureProvider<PackageInfo>((ref) async {
  return PackageInfo.fromPlatform();
});

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(themeSettingsProvider);
    final notifier = ref.read(themeSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.settingsTitle,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          _SectionHeader(label: l10n.appearanceSection),
          const SizedBox(height: 12),
          _BrightnessSelector(
            current: settings.mode,
            onChanged: notifier.setMode,
            labels: (
              light: l10n.brightnessLight,
              dark: l10n.brightnessDark,
              system: l10n.brightnessSystem,
            ),
          ),
          const SizedBox(height: 28),
          _SectionHeader(label: l10n.accentLabel),
          const SizedBox(height: 12),
          _PaletteRow(
            current: settings.palette,
            onChanged: notifier.setPalette,
            labelFor: (p) => switch (p) {
              AppPalette.ieltsBlue => l10n.paletteIeltsBlue,
              AppPalette.emerald => l10n.paletteEmerald,
              AppPalette.crimson => l10n.paletteCrimson,
            },
          ),
          const SizedBox(height: 32),
          _SectionHeader(label: l10n.previewSection),
          const SizedBox(height: 12),
          _PreviewCard(
            body: l10n.previewBody,
            filledLabel: l10n.previewFilledButton,
            outlinedLabel: l10n.previewOutlinedButton,
          ),
          const SizedBox(height: 32),
          _SectionHeader(label: l10n.aboutSection),
          const SizedBox(height: 12),
          const _AboutLegalCard(),
          const SizedBox(height: 16),
          const _VersionFooter(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _BrightnessSelector extends StatelessWidget {
  const _BrightnessSelector({
    required this.current,
    required this.onChanged,
    required this.labels,
  });

  final ThemeMode current;
  final ValueChanged<ThemeMode> onChanged;
  final ({String light, String dark, String system}) labels;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ThemeMode>(
      showSelectedIcon: false,
      segments: [
        ButtonSegment(
          value: ThemeMode.light,
          label: Text(labels.light),
          icon: const Icon(Icons.light_mode_outlined),
        ),
        ButtonSegment(
          value: ThemeMode.dark,
          label: Text(labels.dark),
          icon: const Icon(Icons.dark_mode_outlined),
        ),
        ButtonSegment(
          value: ThemeMode.system,
          label: Text(labels.system),
          icon: const Icon(Icons.brightness_auto_outlined),
        ),
      ],
      selected: {current},
      onSelectionChanged: (set) => onChanged(set.first),
    );
  }
}

class _PaletteRow extends StatelessWidget {
  const _PaletteRow({
    required this.current,
    required this.onChanged,
    required this.labelFor,
  });

  final AppPalette current;
  final ValueChanged<AppPalette> onChanged;
  final String Function(AppPalette) labelFor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: AppPalette.values.map((p) {
        final selected = p == current;
        return _PaletteSwatch(
          color: p.seed,
          label: labelFor(p),
          selected: selected,
          onTap: () => onChanged(p),
        );
      }).toList(),
    );
  }
}

class _PaletteSwatch extends StatelessWidget {
  const _PaletteSwatch({
    required this.color,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ring = Theme.of(context).colorScheme.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: EdgeInsets.all(selected ? 4 : 0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? ring : Colors.transparent,
                  width: selected ? 2.5 : 0,
                ),
              ),
              child: CircleAvatar(radius: 24, backgroundColor: color),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.body,
    required this.filledLabel,
    required this.outlinedLabel,
  });

  final String body;
  final String filledLabel;
  final String outlinedLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: scheme.primary,
                  child: Icon(Icons.auto_stories, color: scheme.onPrimary),
                ),
                const SizedBox(width: 12),
                Text(
                  'OCG IELTS',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(body, style: GoogleFonts.poppins(fontSize: 14)),
            const SizedBox(height: 16),
            Row(
              children: [
                FilledButton(onPressed: () {}, child: Text(filledLabel)),
                const SizedBox(width: 12),
                OutlinedButton(onPressed: () {}, child: Text(outlinedLabel)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutLegalCard extends ConsumerWidget {
  const _AboutLegalCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final infoAsync = ref.watch(packageInfoProvider);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          _AboutTile(
            icon: Icons.privacy_tip_outlined,
            label: l10n.privacyPolicy,
            onTap: () => _openLegal(context, l10n.privacyPolicy, LegalTexts.privacyPolicy),
          ),
          const Divider(height: 0),
          _AboutTile(
            icon: Icons.description_outlined,
            label: l10n.termsOfService,
            onTap: () => _openLegal(context, l10n.termsOfService, LegalTexts.termsOfService),
          ),
          const Divider(height: 0),
          _AboutTile(
            icon: Icons.workspace_premium_outlined,
            label: l10n.openSourceLicenses,
            onTap: () => _showLicenses(context, infoAsync.value),
          ),
          const Divider(height: 0),
          _AboutTile(
            icon: Icons.mail_outline,
            label: l10n.contactSupport,
            onTap: () => _emailSupport(context, l10n),
          ),
          const Divider(height: 0),
          _AboutTile(
            icon: Icons.star_outline,
            label: l10n.rateApp,
            onTap: () => _openUrl(context, AppConfig.playStoreUrl, l10n),
          ),
          const Divider(height: 0),
          _AboutTile(
            icon: Icons.share_outlined,
            label: l10n.shareApp,
            onTap: () => _openUrl(context, AppConfig.playStoreUrl, l10n),
          ),
        ],
      ),
    );
  }

  void _openLegal(BuildContext context, String title, String body) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LegalDocumentScreen(title: title, body: body),
      ),
    );
  }

  Future<void> _openUrl(
    BuildContext context,
    String url,
    AppLocalizations l10n,
  ) async {
    final uri = Uri.parse(url);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      _snack(context, l10n.couldNotOpenLink);
    }
  }

  Future<void> _emailSupport(BuildContext context, AppLocalizations l10n) async {
    final uri = Uri(
      scheme: 'mailto',
      path: AppConfig.supportEmail,
      query: 'subject=${Uri.encodeComponent(l10n.supportEmailSubject)}',
    );
    final ok = await launchUrl(uri);
    if (!ok && context.mounted) {
      _snack(context, l10n.couldNotOpenLink);
    }
  }

  void _showLicenses(BuildContext context, PackageInfo? info) {
    showLicensePage(
      context: context,
      applicationName: info?.appName ?? 'OCG IELTS',
      applicationVersion: info == null
          ? ''
          : '${info.version} (${info.buildNumber})',
      applicationIcon: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(
          Icons.auto_stories,
          size: 48,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      applicationLegalese: AppConfig.appLegalName,
    );
  }

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _AboutTile extends StatelessWidget {
  const _AboutTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon, color: scheme.primary),
      title: Text(label, style: GoogleFonts.poppins(fontSize: 15)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}

class _VersionFooter extends ConsumerWidget {
  const _VersionFooter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final infoAsync = ref.watch(packageInfoProvider);
    final text = infoAsync.when(
      data: (i) => l10n.versionLabel(i.version, i.buildNumber),
      loading: () => '…',
      error: (_, _) => '—',
    );
    return Center(
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
