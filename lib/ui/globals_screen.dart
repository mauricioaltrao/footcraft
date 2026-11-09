import 'package:flutter/material.dart';

import '../fcb/fcb_document.dart';
import '../fcb/fcb_sysex.dart';
import '../l10n/app_localizations.dart';

/// Configurações globais: canal MIDI de cada tipo de mensagem e as opções de
/// funcionamento (seleção direta, running status, merge, relés pelas teclas).
class GlobalsScreen extends StatelessWidget {
  const GlobalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final doc = FcbDocument.instance;
    String channelName(FcbChannel c) => switch (c) {
      FcbChannel.program1 => 'PC1',
      FcbChannel.program2 => 'PC2',
      FcbChannel.program3 => 'PC3',
      FcbChannel.program4 => 'PC4',
      FcbChannel.program5 => 'PC5',
      FcbChannel.control1 => 'CC1',
      FcbChannel.control2 => 'CC2',
      FcbChannel.expressionA => l.expressionN('A'),
      FcbChannel.expressionB => l.expressionN('B'),
      FcbChannel.note => l.note,
    };
    return Scaffold(
      appBar: AppBar(title: Text(l.globalSettings)),
      body: ListenableBuilder(
        listenable: doc,
        builder: (context, _) {
          final g = doc.setup.globals;
          void set(FcbGlobals next) => doc.edit((s) => s.globals = next);
          final theme = Theme.of(context);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(l.midiChannels, style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(l.midiChannelsHint, style: theme.textTheme.bodySmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final c in FcbChannel.values)
                    SizedBox(
                      width: 150,
                      child: DropdownButtonFormField<int>(
                        initialValue: g.channels[c.index],
                        decoration: InputDecoration(labelText: channelName(c)),
                        items: [
                          for (var ch = 0; ch < 16; ch++)
                            DropdownMenuItem(
                              value: ch,
                              child: Text(l.channelN(ch + 1)),
                            ),
                        ],
                        onChanged: (v) => set(
                          g.copyWith(channels: [...g.channels]..[c.index] = v!),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: PopupMenuButton<int>(
                  onSelected: (ch) => set(
                    g.copyWith(
                      channels: List.filled(FcbChannel.values.length, ch),
                    ),
                  ),
                  itemBuilder: (_) => [
                    for (var ch = 0; ch < 16; ch++)
                      PopupMenuItem(value: ch, child: Text(l.channelN(ch + 1))),
                  ],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.select_all, size: 18),
                        const SizedBox(width: 6),
                        Text(l.sameChannelForAll),
                      ],
                    ),
                  ),
                ),
              ),
              const Divider(height: 32),
              Text(l.operation, style: theme.textTheme.titleMedium),
              SwitchListTile(
                title: Text(l.directSelect),
                subtitle: Text(l.directSelectHint),
                value: g.directSelect,
                onChanged: (v) => set(g.copyWith(directSelect: v)),
              ),
              SwitchListTile(
                title: Text(l.runningStatus),
                subtitle: Text(l.runningStatusHint),
                value: g.runningStatus,
                onChanged: (v) => set(g.copyWith(runningStatus: v)),
              ),
              SwitchListTile(
                title: Text(l.merge),
                subtitle: Text(l.mergeHint),
                value: g.merge,
                onChanged: (v) => set(g.copyWith(merge: v)),
              ),
              SwitchListTile(
                title: Text(l.upTogglesRelay1),
                subtitle: Text(l.relayKeysHint),
                value: g.upTogglesRelay1,
                onChanged: (v) => set(g.copyWith(upTogglesRelay1: v)),
              ),
              SwitchListTile(
                title: Text(l.downTogglesRelay2),
                subtitle: Text(l.relayKeysHint),
                value: g.downTogglesRelay2,
                onChanged: (v) => set(g.copyWith(downTogglesRelay2: v)),
              ),
              const SizedBox(height: 8),
              Text(l.calibrationNote, style: theme.textTheme.bodySmall),
            ],
          );
        },
      ),
    );
  }
}
