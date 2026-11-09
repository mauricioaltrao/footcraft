import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../midi/midi_link.dart';
import 'theme.dart';

/// Indicador de conexão para a barra superior; tocar abre a escolha das portas.
class ConnectionChip extends StatelessWidget {
  const ConnectionChip({super.key});

  @override
  Widget build(BuildContext context) {
    final link = MidiLink.instance;
    return ListenableBuilder(
      listenable: link,
      builder: (context, _) {
        final l = AppLocalizations.of(context);
        final on = link.connected;
        return ActionChip(
          avatar: Icon(
            Icons.circle,
            size: 12,
            color: on ? Colors.greenAccent : FcbColors.led,
          ),
          label: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: Text(
              on ? _short(link.input!) : l.notConnected,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          onPressed: () => showPortsDialog(context),
        );
      },
    );
  }

  static String _short(String name) =>
      name.replaceFirst(RegExp(r'\s+\d+:\d+$'), '').split(':').last;
}

/// Só o LED de conexão (barra do celular); tocar abre a escolha das portas.
class ConnectionLed extends StatelessWidget {
  const ConnectionLed({super.key});

  @override
  Widget build(BuildContext context) {
    final link = MidiLink.instance;
    return ListenableBuilder(
      listenable: link,
      builder: (context, _) {
        final l = AppLocalizations.of(context);
        final on = link.connected;
        return IconButton(
          tooltip: on ? link.input! : l.notConnected,
          onPressed: () => showPortsDialog(context),
          icon: Icon(
            Icons.cable,
            color: on ? Colors.greenAccent : FcbColors.led,
          ),
        );
      },
    );
  }
}

/// Garante portas abertas antes de receber/enviar; pergunta se faltar.
Future<bool> ensureConnected(BuildContext context) async {
  if (MidiLink.instance.connected) return true;
  await showPortsDialog(context);
  return MidiLink.instance.connected;
}

Future<void> showPortsDialog(BuildContext context) =>
    showDialog<void>(context: context, builder: (_) => const _PortsDialog());

class _PortsDialog extends StatefulWidget {
  const _PortsDialog();

  @override
  State<_PortsDialog> createState() => _PortsDialogState();
}

class _PortsDialogState extends State<_PortsDialog> {
  final link = MidiLink.instance;
  String? input;
  String? output;

  @override
  void initState() {
    super.initState();
    input = link.input;
    output = link.output;
    link.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: link,
      builder: (context, _) {
        final ins = link.inputs, outs = link.outputs;
        if (input != null && !ins.contains(input)) input = null;
        if (output != null && !outs.contains(output)) output = null;
        return AlertDialog(
          title: Text(l.midiPorts),
          content: SizedBox(
            width: 460,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l.midiPortsHint,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: input,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: l.inputFromFcb),
                  items: [
                    for (final p in ins)
                      DropdownMenuItem(
                        value: p,
                        child: Text(p, overflow: TextOverflow.ellipsis),
                      ),
                  ],
                  onChanged: (v) => setState(() => input = v),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: output,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: l.outputToFcb),
                  items: [
                    for (final p in outs)
                      DropdownMenuItem(
                        value: p,
                        child: Text(p, overflow: TextOverflow.ellipsis),
                      ),
                  ],
                  onChanged: (v) => setState(() => output = v),
                ),
                if (ins.isEmpty && outs.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(l.noPorts),
                  ),
                if (link.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      link.error!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: link.refresh,
              icon: const Icon(Icons.refresh),
              label: Text(l.refresh),
            ),
            if (link.connected)
              TextButton(
                onPressed: () async {
                  await link.close();
                  if (context.mounted) Navigator.pop(context);
                },
                child: Text(l.disconnect),
              ),
            FilledButton(
              onPressed: input == null || output == null
                  ? null
                  : () async {
                      if (await link.open(input!, output!) && context.mounted)
                        Navigator.pop(context);
                    },
              child: Text(l.connect),
            ),
          ],
        );
      },
    );
  }
}

/// Monitor: o que a FCB está mandando agora (útil para testar os pedais).
class MidiMonitorSheet extends StatelessWidget {
  const MidiMonitorSheet({super.key});

  static String describe(AppLocalizations l, MidiEvent e) {
    final b = e.bytes;
    if (b.isEmpty) return '';
    if (b[0] == 0xF0) return l.monitorSysex(b.length);
    final type = b[0] & 0xF0;
    return switch (type) {
      0xB0 when b.length >= 3 => 'CH ${e.channel}  CC ${b[1]} = ${b[2]}',
      0xC0 when b.length >= 2 => 'CH ${e.channel}  PC ${b[1]}',
      0x90 when b.length >= 3 => 'CH ${e.channel}  Note On ${b[1]} (${b[2]})',
      0x80 when b.length >= 3 => 'CH ${e.channel}  Note Off ${b[1]}',
      _ =>
        b
            .map((x) => x.toRadixString(16).padLeft(2, '0').toUpperCase())
            .join(' '),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final link = MidiLink.instance;
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.6,
        child: ListenableBuilder(
          listenable: link,
          builder: (context, _) {
            final events = link.recent.reversed.toList();
            return Column(
              children: [
                ListTile(
                  title: Text(l.midiMonitor),
                  subtitle: Text(l.midiMonitorHint),
                  trailing: IconButton(
                    tooltip: l.clear,
                    onPressed: link.clearRecent,
                    icon: const Icon(Icons.delete_sweep),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: events.isEmpty
                      ? Center(child: Text(l.monitorEmpty))
                      : ListView.builder(
                          itemCount: events.length,
                          itemBuilder: (context, i) {
                            final e = events[i];
                            final t = e.time;
                            String two(int v) => v.toString().padLeft(2, '0');
                            return ListTile(
                              dense: true,
                              leading: Text(
                                '${two(t.hour)}:${two(t.minute)}:${two(t.second)}',
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  color: Colors.white54,
                                ),
                              ),
                              title: Text(
                                describe(l, e),
                                style: const TextStyle(fontFamily: 'monospace'),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
