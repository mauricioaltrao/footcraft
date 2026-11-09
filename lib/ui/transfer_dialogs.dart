import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../fcb/fcb_document.dart';
import '../fcb/fcb_sysex.dart';
import '../l10n/app_localizations.dart';
import '../midi/midi_link.dart';
import 'midi_panel.dart';
import 'theme.dart';

/// Passos na FCB para entrar na configuração global (iguais para receber e enviar).
List<String> _configSteps(AppLocalizations l) => [
  l.stepPowerDown,
  l.stepConfiguration,
];

/// Receber o dump da FCB: instruções, espera com progresso e abertura no editor.
Future<void> showReceiveDialog(BuildContext context) async {
  if (!await ensureConnected(context)) return;
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _ReceiveDialog(),
  );
}

class _ReceiveDialog extends StatefulWidget {
  const _ReceiveDialog();

  @override
  State<_ReceiveDialog> createState() => _ReceiveDialogState();
}

class _ReceiveDialogState extends State<_ReceiveDialog> {
  late final StreamSubscription<Uint8List> _sub;
  Uint8List? _received;
  String? _error;

  @override
  void initState() {
    super.initState();
    _sub = MidiLink.instance.sysex.stream.listen((data) {
      if (FcbSysex.isDump(data)) {
        setState(() => _received = data);
      } else if (data.length > 7 &&
          data[1] == 0x00 &&
          data[2] == 0x20 &&
          data[3] == 0x32) {
        setState(
          () => _error = AppLocalizations.of(
            context,
          ).receivedIncomplete(data.length),
        );
      }
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  Future<void> _open() async {
    final l = AppLocalizations.of(context);
    final data = _received!;
    final backup = await FcbDocument.saveDeviceBackup(data);
    final t = DateTime.now();
    FcbDocument.instance.loadSysex(
      data,
      SetupSource.device,
      l.receivedAt(
        '${t.day.toString().padLeft(2, '0')}/${t.month.toString().padLeft(2, '0')} '
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}',
      ),
    );
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l.receivedOk(backup.path))));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final link = MidiLink.instance;
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.download),
          const SizedBox(width: 8),
          Text(l.receiveTitle),
        ],
      ),
      content: SizedBox(
        width: 460,
        child: ListenableBuilder(
          listenable: link,
          builder: (context, _) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Steps(steps: [..._configSteps(l), l.stepSysexSend]),
              const SizedBox(height: 16),
              if (_received != null)
                _Status(
                  icon: Icons.check_circle,
                  color: Colors.greenAccent,
                  text: l.receivedDump,
                )
              else if (_error != null)
                _Status(
                  icon: Icons.error,
                  color: Colors.redAccent,
                  text: _error!,
                )
              else ...[
                _Status(
                  icon: Icons.hourglass_top,
                  color: FcbColors.accent,
                  text: link.incomingSysex > 0
                      ? l.receiving(link.incomingSysex, FcbSysex.length)
                      : l.waitingDump,
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: link.incomingSysex > 0
                      ? link.incomingSysex / FcbSysex.length
                      : null,
                ),
              ],
              const SizedBox(height: 12),
              Text(l.receiveNote, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.cancel),
        ),
        FilledButton.icon(
          onPressed: _received == null ? null : _open,
          icon: const Icon(Icons.edit),
          label: Text(l.openInEditor),
        ),
      ],
    );
  }
}

/// Enviar a configuração para a FCB.
Future<void> showSendDialog(BuildContext context) async {
  if (!await ensureConnected(context)) return;
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _SendDialog(),
  );
}

class _SendDialog extends StatefulWidget {
  const _SendDialog();

  @override
  State<_SendDialog> createState() => _SendDialogState();
}

enum _SendState { ready, sending, sent, failed }

class _SendDialogState extends State<_SendDialog> {
  _SendState state = _SendState.ready;
  String? error;

  Future<void> _send() async {
    setState(() => state = _SendState.sending);
    try {
      await MidiLink.instance.send(FcbDocument.instance.setup.toSysex());
      // O envio já vai devagar (~2 s); uma folga para o último pedaço sair do cabo.
      await Future<void>.delayed(const Duration(milliseconds: 300));
      FcbDocument.instance.markSaved();
      if (mounted) setState(() => state = _SendState.sent);
    } catch (e) {
      if (mounted) {
        setState(() {
          state = _SendState.failed;
          error = '$e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.upload),
          const SizedBox(width: 8),
          Text(l.sendTitle),
        ],
      ),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Steps(
              steps: [..._configSteps(l), l.stepSysexRcv, l.stepPressSend],
            ),
            const SizedBox(height: 16),
            switch (state) {
              _SendState.ready => Text(
                l.sendWarning,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              _SendState.sending => _Status(
                icon: Icons.upload,
                color: FcbColors.accent,
                text: l.sending,
              ),
              _SendState.sent => _Status(
                icon: Icons.check_circle,
                color: Colors.greenAccent,
                text: l.sentCheckLed,
              ),
              _SendState.failed => _Status(
                icon: Icons.error,
                color: Colors.redAccent,
                text: l.sendFailed(error ?? ''),
              ),
            },
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: state == _SendState.sending
              ? null
              : () => Navigator.pop(context),
          child: Text(state == _SendState.sent ? l.close : l.cancel),
        ),
        if (state != _SendState.sent)
          FilledButton.icon(
            onPressed: state == _SendState.sending ? null : _send,
            icon: const Icon(Icons.upload),
            label: Text(l.sendNow),
          ),
      ],
    );
  }
}

class _Steps extends StatelessWidget {
  const _Steps({required this.steps});
  final List<String> steps;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (final (i, s) in steps.indexed)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: FcbColors.led,
                child: Text(
                  '${i + 1}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(s)),
            ],
          ),
        ),
    ],
  );
}

class _Status extends StatelessWidget {
  const _Status({required this.icon, required this.color, required this.text});
  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: color),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
        ),
      ),
    ],
  );
}
