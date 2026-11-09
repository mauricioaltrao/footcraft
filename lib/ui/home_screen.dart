import 'package:flutter/material.dart';

import '../fcb/fcb_document.dart';
import '../fcb/fcb_sysex.dart';
import '../fcb/test_mode.dart';
import '../l10n/app_localizations.dart';
import 'batch_screen.dart';
import 'describe.dart';
import 'files.dart';
import 'globals_screen.dart';
import 'midi_panel.dart';
import 'pedal_editor.dart';
import 'pedalboard.dart';
import 'test_banner.dart';
import 'theme.dart';
import 'transfer_dialogs.dart';

/// Tela principal: a pedaleira desenhada e o editor do pedal escolhido, ao
/// lado em telas largas e logo abaixo no celular.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();

  static String _sourceLabel(AppLocalizations l, FcbDocument doc) =>
      switch (doc.source) {
        SetupSource.factory => l.factoryNamed(_factoryName(l, doc.sourceName)),
        _ => doc.sourceName,
      };

  static String _factoryName(AppLocalizations l, String name) => switch (name) {
    'vAmp' => l.factoryVAmp,
    'guitarAmps' => l.factoryGuitarAmps,
    'bassVAmp' => l.factoryBassVAmp,
    _ => name,
  };
}

class _HomeScreenState extends State<HomeScreen> {
  static const _wideLayout = 1000.0;
  final _editorKey = GlobalKey();

  /// No celular, tocar num pedal rola até o editor dele.
  void _showEditor() {
    final ctx = _editorKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final doc = FcbDocument.instance;
    return LayoutBuilder(
      builder: (context, box) {
        final wide = box.maxWidth >= _wideLayout;
        final narrow = box.maxWidth < 600;
        final source = ListenableBuilder(
          listenable: doc,
          builder: (context, _) => Text(
            '${HomeScreen._sourceLabel(l, doc)}${doc.dirty ? ' • ${l.modified}' : ''}',
            style: Theme.of(context).textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        );
        final board = ListView(
          padding: EdgeInsets.all(narrow ? 10 : 16),
          children: [
            if (narrow)
              Padding(padding: const EdgeInsets.only(bottom: 8), child: source),
            _Actions(compact: narrow),
            SizedBox(height: narrow ? 10 : 16),
            const TestBanner(),
            Pedalboard(onOpenPedal: (_) => wide ? null : _showEditor()),
            const SizedBox(height: 12),
            if (wide)
              Text(l.boardHint, style: Theme.of(context).textTheme.bodySmall)
            else ...[
              // Celular/tablet em pé: o editor do pedal escolhido fica aqui embaixo.
              ListenableBuilder(
                listenable: doc,
                builder: (context, _) => Container(
                  key: _editorKey,
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          pedalLabel(l, doc.selected),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      IconButton(
                        tooltip: l.copyPedal,
                        onPressed: () => doc.copyPreset(doc.selected),
                        icon: const Icon(Icons.copy),
                      ),
                      IconButton(
                        tooltip: l.pastePedal,
                        onPressed: doc.clipboard == null
                            ? null
                            : () => doc.pastePreset(doc.selected),
                        icon: const Icon(Icons.paste),
                      ),
                    ],
                  ),
                ),
              ),
              const PedalEditor(showHeader: false, scrollable: false),
              const SizedBox(height: 24),
            ],
          ],
        );
        return Scaffold(
          appBar: AppBar(
            titleSpacing: narrow ? 12 : null,
            title: narrow
                ? const Text('FootCraft')
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [const Text('FootCraft'), source],
                  ),
            actions: [
              narrow ? const ConnectionLed() : const ConnectionChip(),
              const SizedBox(width: 4),
              ListenableBuilder(
                listenable: doc,
                builder: (context, _) => Row(
                  children: [
                    IconButton(
                      tooltip: l.undo,
                      onPressed: doc.canUndo ? doc.undo : null,
                      icon: const Icon(Icons.undo),
                    ),
                    IconButton(
                      tooltip: l.redo,
                      onPressed: doc.canRedo ? doc.redo : null,
                      icon: const Icon(Icons.redo),
                    ),
                  ],
                ),
              ),
              const _Menu(),
            ],
          ),
          body: wide
              ? Row(
                  children: [
                    Expanded(child: board),
                    const VerticalDivider(width: 1),
                    const SizedBox(width: 480, child: PedalEditor()),
                  ],
                )
              : board,
        );
      },
    );
  }
}

/// Os três botões principais: receber, enviar e programar vários.
class _Actions extends StatelessWidget {
  const _Actions({this.compact = false});

  /// Celular: três botões lado a lado, com o ícone em cima do texto.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (compact) {
      Widget button(
        IconData icon,
        String label,
        VoidCallback onTap, {
        Color? bg,
        Color? fg,
        bool outlined = false,
      }) => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Material(
            color: outlined ? Colors.transparent : bg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: outlined
                  ? const BorderSide(color: Colors.white24)
                  : BorderSide.none,
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 4,
                ),
                child: Column(
                  children: [
                    Icon(icon, color: fg),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: TextStyle(
                        color: fg,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          button(
            Icons.download,
            l.receiveFromFcb,
            () => showReceiveDialog(context),
            bg: FcbColors.accent,
            fg: Colors.black,
          ),
          button(
            Icons.upload,
            l.sendToFcb,
            () => showSendDialog(context),
            bg: FcbColors.led,
            fg: Colors.white,
          ),
          button(
            Icons.auto_fix_high,
            l.batchTitle,
            () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const BatchScreen()),
            ),
            fg: FcbColors.accent,
            outlined: true,
          ),
          button(
            Icons.science,
            l.testMode,
            () => _toggleTest(context),
            fg: Colors.greenAccent,
            outlined: true,
          ),
        ],
      );
    }
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        FilledButton.icon(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
          onPressed: () => showReceiveDialog(context),
          icon: const Icon(Icons.download),
          label: Text(l.receiveFromFcb),
        ),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: FcbColors.led,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
          onPressed: () => showSendDialog(context),
          icon: const Icon(Icons.upload),
          label: Text(l.sendToFcb),
        ),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
          onPressed: () => Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: (_) => const BatchScreen())),
          icon: const Icon(Icons.auto_fix_high),
          label: Text(l.batchTitle),
        ),
        ListenableBuilder(
          listenable: TestMode.instance,
          builder: (context, _) => OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.greenAccent,
              backgroundColor: TestMode.instance.active
                  ? Colors.greenAccent.withValues(alpha: 0.12)
                  : null,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
            onPressed: () => _toggleTest(context),
            icon: Icon(TestMode.instance.active ? Icons.stop : Icons.science),
            label: Text(TestMode.instance.active ? l.testModeStop : l.testMode),
          ),
        ),
      ],
    );
  }

  /// Liga/desliga o modo de teste (pede as portas MIDI se faltarem).
  static Future<void> _toggleTest(BuildContext context) async {
    final test = TestMode.instance;
    if (test.active) return test.stop();
    if (await ensureConnected(context)) test.start();
  }
}

class _Menu extends StatelessWidget {
  const _Menu();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final doc = FcbDocument.instance;
    Future<void> newFrom(FactorySetup f) async {
      if (doc.dirty && !await _confirmReplace(context)) return;
      await doc.loadFactory(f);
    }

    return PopupMenuButton<String>(
      onSelected: (v) async {
        switch (v) {
          case 'open':
            if (!doc.dirty || await _confirmReplace(context)) {
              if (context.mounted) await openSysexFile(context);
            }
          case 'save':
            await saveSysexFile(context);
          case 'globals':
            await Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const GlobalsScreen()),
            );
          case 'monitor':
            await showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              builder: (_) => const MidiMonitorSheet(),
            );
          case 'ports':
            await showPortsDialog(context);
          case 'copyBank':
            await _copyBank(context);
          case 'vAmp':
            await newFrom(FactorySetup.vAmp);
          case 'guitarAmps':
            await newFrom(FactorySetup.guitarAmps);
          case 'bassVAmp':
            await newFrom(FactorySetup.bassVAmp);
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'open',
          child: ListTile(
            leading: const Icon(Icons.folder_open),
            title: Text(l.openFile),
          ),
        ),
        PopupMenuItem(
          value: 'save',
          child: ListTile(
            leading: const Icon(Icons.save),
            title: Text(l.saveFile),
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'globals',
          child: ListTile(
            leading: const Icon(Icons.settings),
            title: Text(l.globalSettings),
          ),
        ),
        PopupMenuItem(
          value: 'copyBank',
          child: ListTile(
            leading: const Icon(Icons.content_copy),
            title: Text(l.copyBank),
          ),
        ),
        PopupMenuItem(
          value: 'monitor',
          child: ListTile(
            leading: const Icon(Icons.monitor_heart),
            title: Text(l.midiMonitor),
          ),
        ),
        PopupMenuItem(
          value: 'ports',
          child: ListTile(
            leading: const Icon(Icons.cable),
            title: Text(l.midiPorts),
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(enabled: false, child: Text(l.newFromFactory)),
        PopupMenuItem(
          value: 'vAmp',
          child: ListTile(
            leading: const Icon(Icons.restore),
            title: Text(l.factoryVAmp),
          ),
        ),
        PopupMenuItem(
          value: 'guitarAmps',
          child: ListTile(
            leading: const Icon(Icons.restore),
            title: Text(l.factoryGuitarAmps),
          ),
        ),
        PopupMenuItem(
          value: 'bassVAmp',
          child: ListTile(
            leading: const Icon(Icons.restore),
            title: Text(l.factoryBassVAmp),
          ),
        ),
      ],
    );
  }

  static Future<bool> _confirmReplace(BuildContext context) async {
    final l = AppLocalizations.of(context);
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l.replaceTitle),
            content: Text(l.replaceBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l.replace),
              ),
            ],
          ),
        ) ==
        true;
  }

  static Future<void> _copyBank(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final doc = FcbDocument.instance;
    var from = doc.bank, to = (doc.bank + 1) % FcbSetup.banks;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          DropdownButton<int> pick(int value, ValueChanged<int> onChanged) =>
              DropdownButton<int>(
                value: value,
                items: [
                  for (var b = 0; b < FcbSetup.banks; b++)
                    DropdownMenuItem(value: b, child: Text('${l.bank} $b')),
                ],
                onChanged: (v) => setState(() => onChanged(v!)),
              );
          return AlertDialog(
            title: Text(l.copyBank),
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                pick(from, (v) => from = v),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(Icons.arrow_forward),
                ),
                pick(to, (v) => to = v),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l.cancel),
              ),
              FilledButton(
                onPressed: from == to
                    ? null
                    : () => Navigator.pop(context, true),
                child: Text(l.copy),
              ),
            ],
          );
        },
      ),
    );
    if (ok == true) doc.copyBank(from, to);
  }
}
