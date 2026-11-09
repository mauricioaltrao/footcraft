import 'package:flutter/material.dart';

import '../fcb/fcb_document.dart';
import '../fcb/fcb_sysex.dart';
import '../l10n/app_localizations.dart';
import 'describe.dart';
import 'number_field.dart';
import 'theme.dart';

/// Tudo o que um pedal manda, para editar item por item.
class PedalEditor extends StatelessWidget {
  const PedalEditor({
    super.key,
    this.showHeader = true,
    this.scrollable = true,
  });
  final bool showHeader;

  /// Falso dentro de outra lista (celular: editor logo abaixo da pedaleira).
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final doc = FcbDocument.instance;
    return ListenableBuilder(
      listenable: doc,
      builder: (context, _) {
        final l = AppLocalizations.of(context);
        final index = doc.selected;
        final p = doc.setup.preset(index);
        void set(FcbPreset next) => doc.setPreset(index, next);
        final children = <Widget>[
          if (showHeader) _Header(index: index),
          _Section(
            color: FcbColors.program,
            icon: Icons.swap_horiz,
            title: l.programChanges,
            hint: l.programChangesHint,
            children: [
              for (var k = 0; k < 5; k++)
                _ToggleRow(
                  label: 'PC${k + 1}',
                  enabled: p.programs[k].enabled,
                  onToggle: (v) =>
                      set(p.withProgram(k, p.programs[k].copyWith(enabled: v))),
                  fields: [
                    NumberField(
                      label: l.program,
                      value: p.programs[k].program,
                      enabled: p.programs[k].enabled,
                      onChanged: (v) => set(
                        p.withProgram(k, p.programs[k].copyWith(program: v)),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          _Section(
            color: FcbColors.control,
            icon: Icons.tune,
            title: l.controlChanges,
            hint: l.controlChangesHint,
            children: [
              for (final (k, c) in [p.cc1, p.cc2].indexed)
                _ToggleRow(
                  label: 'CC${k + 1}',
                  enabled: c.enabled,
                  onToggle: (v) => set(
                    k == 0
                        ? p.copyWith(cc1: c.copyWith(enabled: v))
                        : p.copyWith(cc2: c.copyWith(enabled: v)),
                  ),
                  fields: [
                    NumberField(
                      label: l.controller,
                      value: c.controller,
                      enabled: c.enabled,
                      onChanged: (v) => set(
                        k == 0
                            ? p.copyWith(cc1: c.copyWith(controller: v))
                            : p.copyWith(cc2: c.copyWith(controller: v)),
                      ),
                    ),
                    NumberField(
                      label: l.value,
                      value: c.value,
                      enabled: c.enabled,
                      onChanged: (v) => set(
                        k == 0
                            ? p.copyWith(cc1: c.copyWith(value: v))
                            : p.copyWith(cc2: c.copyWith(value: v)),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          _Section(
            color: FcbColors.expression,
            icon: Icons.linear_scale,
            title: l.expressionPedals,
            hint: l.expressionPedalsHint,
            children: [
              for (final (k, e) in [p.expA, p.expB].indexed)
                _ToggleRow(
                  label: k == 0 ? 'A' : 'B',
                  enabled: e.enabled,
                  onToggle: (v) => set(
                    k == 0
                        ? p.copyWith(expA: e.copyWith(enabled: v))
                        : p.copyWith(expB: e.copyWith(enabled: v)),
                  ),
                  fields: [
                    // CC numa linha e a faixa (mín–máx) na outra.
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        NumberField(
                          label: l.controller,
                          value: e.controller,
                          enabled: e.enabled,
                          onChanged: (v) => set(
                            k == 0
                                ? p.copyWith(expA: e.copyWith(controller: v))
                                : p.copyWith(expB: e.copyWith(controller: v)),
                          ),
                        ),
                        Wrap(
                          spacing: 12,
                          children: [
                            NumberField(
                              label: l.minimum,
                              value: e.min,
                              enabled: e.enabled,
                              onChanged: (v) => set(
                                k == 0
                                    ? p.copyWith(expA: e.copyWith(min: v))
                                    : p.copyWith(expB: e.copyWith(min: v)),
                              ),
                            ),
                            NumberField(
                              label: l.maximum,
                              value: e.max,
                              enabled: e.enabled,
                              onChanged: (v) => set(
                                k == 0
                                    ? p.copyWith(expA: e.copyWith(max: v))
                                    : p.copyWith(expB: e.copyWith(max: v)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
          _Section(
            color: FcbColors.note,
            icon: Icons.music_note,
            title: l.noteSection,
            hint: l.noteHint,
            children: [
              _ToggleRow(
                label: l.note,
                enabled: p.note.enabled,
                onToggle: (v) =>
                    set(p.copyWith(note: p.note.copyWith(enabled: v))),
                fields: [
                  NumberField(
                    value: p.note.note,
                    enabled: p.note.enabled,
                    display: noteName,
                    onChanged: (v) =>
                        set(p.copyWith(note: p.note.copyWith(note: v))),
                  ),
                ],
              ),
            ],
          ),
          _Section(
            color: FcbColors.relay,
            icon: Icons.power,
            title: l.relays,
            hint: l.relaysHint,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l.relayN(1)),
                value: p.relay1,
                onChanged: (v) => set(p.copyWith(relay1: v)),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l.relayN(2)),
                value: p.relay2,
                onChanged: (v) => set(p.copyWith(relay2: v)),
              ),
            ],
          ),
        ];
        if (!scrollable)
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          );
        return ListView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
          children: children,
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final doc = FcbDocument.instance;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              pedalLabel(l, index),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          IconButton(
            tooltip: l.copyPedal,
            onPressed: () => doc.copyPreset(index),
            icon: const Icon(Icons.copy),
          ),
          IconButton(
            tooltip: l.pastePedal,
            onPressed: doc.clipboard == null
                ? null
                : () => doc.pastePreset(index),
            icon: const Icon(Icons.paste),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.color,
    required this.icon,
    required this.title,
    required this.hint,
    required this.children,
  });
  final Color color;
  final IconData icon;
  final String title;
  final String hint;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withValues(alpha: 0.35)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Tooltip(
                    message: hint,
                    triggerMode: TooltipTriggerMode.tap,
                    child: Icon(
                      Icons.info_outline,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

/// Liga/desliga à esquerda e os campos ao lado (quebram linha se não couberem).
class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.enabled,
    required this.onToggle,
    required this.fields,
  });
  final String label;
  final bool enabled;
  final ValueChanged<bool> onToggle;
  final List<Widget> fields;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 112,
            child: Row(
              children: [
                Switch(value: enabled, onChanged: onToggle),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Opacity(
              opacity: enabled ? 1 : 0.4,
              child: Wrap(
                spacing: 12,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: fields,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
