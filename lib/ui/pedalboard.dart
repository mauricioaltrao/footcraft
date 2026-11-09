import 'package:flutter/material.dart';

import '../fcb/fcb_document.dart';
import '../fcb/fcb_sysex.dart';
import '../l10n/app_localizations.dart';
import 'describe.dart';
import 'theme.dart';

/// A FCB1010 desenhada: visor com o banco, seletor de bancos e os 10 pedais
/// na mesma posição do aparelho (6–10 em cima, 1–5 embaixo).
class Pedalboard extends StatelessWidget {
  const Pedalboard({super.key, required this.onOpenPedal});

  /// Pedal tocado (no celular abre o editor).
  final ValueChanged<int> onOpenPedal;

  @override
  Widget build(BuildContext context) {
    final doc = FcbDocument.instance;
    return ListenableBuilder(
      listenable: doc,
      builder: (context, _) => Container(
        decoration: BoxDecoration(
          color: FcbColors.body,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _BankBar(bank: doc.bank),
            const SizedBox(height: 12),
            for (final row in const [
              [5, 6, 7, 8, 9],
              [0, 1, 2, 3, 4],
            ])
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    for (final k in row)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: _PedalTile(
                            index: FcbSetup.indexOf(doc.bank, k),
                            selected: doc.pedal == k,
                            onTap: () {
                              doc.select(doc.bank, k);
                              onOpenPedal(FcbSetup.indexOf(doc.bank, k));
                            },
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

/// Visor vermelho com o banco e botões ◀ ▶, mais os números 0–9 para pular.
class _BankBar extends StatelessWidget {
  const _BankBar({required this.bank});
  final int bank;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final doc = FcbDocument.instance;
    final narrow = MediaQuery.sizeOf(context).width < 600;
    final display = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: FcbColors.displayBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.black),
      ),
      child: Text(
        '${l.bank.toUpperCase()} $bank',
        style: const TextStyle(
          color: FcbColors.display,
          fontFamily: 'monospace',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
          shadows: [Shadow(color: FcbColors.led, blurRadius: 8)],
        ),
      ),
    );
    final chips = Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (var b = 0; b < FcbSetup.banks; b++)
          ChoiceChip(
            label: Text('$b'),
            selected: b == bank,
            showCheckmark: false,
            visualDensity: VisualDensity.compact,
            onSelected: (_) => doc.selectBank(b),
          ),
      ],
    );
    final arrows = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filledTonal(
          tooltip: l.previousBank,
          onPressed: () => doc.selectBank((bank + 9) % 10),
          icon: const Icon(Icons.keyboard_arrow_down),
        ),
        const SizedBox(width: 8),
        display,
        const SizedBox(width: 8),
        IconButton.filledTonal(
          tooltip: l.nextBank,
          onPressed: () => doc.selectBank((bank + 1) % 10),
          icon: const Icon(Icons.keyboard_arrow_up),
        ),
      ],
    );
    if (narrow) {
      return Column(
        children: [
          arrows,
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var b = 0; b < FcbSetup.banks; b++)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: ChoiceChip(
                      label: Text('$b'),
                      selected: b == bank,
                      showCheckmark: false,
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onSelected: (_) => doc.selectBank(b),
                    ),
                  ),
              ],
            ),
          ),
        ],
      );
    }
    return Row(
      children: [
        arrows,
        const SizedBox(width: 16),
        Expanded(child: chips),
      ],
    );
  }
}

class _PedalTile extends StatelessWidget {
  const _PedalTile({
    required this.index,
    required this.selected,
    required this.onTap,
  });
  final int index;
  final bool selected;
  final VoidCallback onTap;

  static Color _color(PedalPart part) => switch (part) {
    PedalPart.program => FcbColors.program,
    PedalPart.control => FcbColors.control,
    PedalPart.note => FcbColors.note,
    PedalPart.relay => FcbColors.relay,
    PedalPart.expression => FcbColors.expression,
  };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final doc = FcbDocument.instance;
    final preset = doc.setup.preset(index);
    final number = index % FcbSetup.pedalsPerBank + 1;
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, box) {
        final compact = box.maxWidth < 120;
        final lines = summarize(preset, compact: compact);
        return Tooltip(
          message: pedalLabel(l, index),
          waitDuration: const Duration(milliseconds: 600),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onTap,
              onLongPress: () => _menu(context),
              onSecondaryTap: () => _menu(context),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                constraints: BoxConstraints(minHeight: compact ? 96 : 120),
                padding: compact
                    ? const EdgeInsets.fromLTRB(6, 6, 4, 8)
                    : const EdgeInsets.fromLTRB(8, 8, 8, 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [FcbColors.pedalTop, FcbColors.pedal],
                  ),
                  border: Border.all(
                    color: selected ? FcbColors.accent : Colors.black54,
                    width: selected ? 2.5 : 1,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _Led(on: selected),
                        const Spacer(),
                        Text(
                          '$number',
                          style:
                              (compact
                                      ? theme.textTheme.titleMedium
                                      : theme.textTheme.titleLarge)
                                  ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (lines.isEmpty)
                      Text(
                        compact ? '—' : l.sendsNothing,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white38,
                        ),
                      )
                    else
                      for (final (part, text) in lines.take(4))
                        Text(
                          text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: _color(part),
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w600,
                            fontSize: compact ? 11 : null,
                            letterSpacing: compact ? -0.3 : null,
                          ),
                        ),
                    if (lines.length > 4)
                      Text(
                        '+${lines.length - 4}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white54,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _menu(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final doc = FcbDocument.instance;
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                pedalLabel(l, index),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: Text(l.copyPedal),
              onTap: () => Navigator.pop(context, 'copy'),
            ),
            ListTile(
              leading: const Icon(Icons.paste),
              title: Text(l.pastePedal),
              enabled: doc.clipboard != null,
              onTap: () => Navigator.pop(context, 'paste'),
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: Text(l.silencePedal),
              subtitle: Text(l.silencePedalHint),
              onTap: () => Navigator.pop(context, 'silence'),
            ),
          ],
        ),
      ),
    );
    switch (action) {
      case 'copy':
        doc.copyPreset(index);
      case 'paste':
        doc.pastePreset(index);
      case 'silence':
        final p = doc.setup.preset(index);
        doc.setPreset(
          index,
          p.copyWith(
            programs: [for (final x in p.programs) x.copyWith(enabled: false)],
            cc1: p.cc1.copyWith(enabled: false),
            cc2: p.cc2.copyWith(enabled: false),
            note: p.note.copyWith(enabled: false),
            relay1: false,
            relay2: false,
          ),
        );
    }
  }
}

class _Led extends StatelessWidget {
  const _Led({required this.on});
  final bool on;

  @override
  Widget build(BuildContext context) => Container(
    width: 10,
    height: 10,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: on ? FcbColors.led : FcbColors.ledOff,
      boxShadow: on
          ? const [BoxShadow(color: FcbColors.led, blurRadius: 8)]
          : null,
    ),
  );
}
