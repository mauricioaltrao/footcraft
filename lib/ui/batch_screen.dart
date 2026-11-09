import 'package:flutter/material.dart';

import '../fcb/batch.dart';
import '../fcb/fcb_document.dart';
import '../fcb/fcb_sysex.dart';
import '../l10n/app_localizations.dart';
import 'describe.dart';
import 'number_field.dart';
import 'theme.dart';

/// Programar vários pedais de uma vez: escolhe quais (bancos e pedais) e o
/// que fazer com cada item (manter, desligar, valor fixo ou em sequência).
class BatchScreen extends StatefulWidget {
  const BatchScreen({super.key});

  @override
  State<BatchScreen> createState() => _BatchScreenState();
}

class _BatchScreenState extends State<BatchScreen> {
  BatchPlan plan = const BatchPlan();
  RangeValues banks = const RangeValues(0, 9);
  RangeValues pedals = const RangeValues(1, 10);

  List<int> get indexes => [
    for (var b = banks.start.round(); b <= banks.end.round(); b++)
      for (var k = pedals.start.round(); k <= pedals.end.round(); k++)
        FcbSetup.indexOf(b, k - 1),
  ];

  void _apply() {
    final l = AppLocalizations.of(context);
    final targets = indexes;
    FcbDocument.instance.edit((s) => plan.apply(s, targets));
    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l.batchApplied(targets.length))));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final wide = MediaQuery.sizeOf(context).width >= 1000;
    final form = ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [
        _Recipes(onPick: (p) => setState(() => plan = p)),
        const SizedBox(height: 12),
        _ScopeCard(
          banks: banks,
          pedals: pedals,
          count: indexes.length,
          onBanks: (v) => setState(() => banks = v),
          onPedals: (v) => setState(() => pedals = v),
        ),
        const SizedBox(height: 12),
        _RuleCard(
          color: FcbColors.program,
          title: l.programChanges,
          children: [
            for (var k = 0; k < 5; k++)
              _NumberRule(
                label: 'PC${k + 1}',
                rule: plan.programs[k],
                onChanged: (r) => setState(
                  () => plan = plan.copyWith(
                    programs: [...plan.programs]..[k] = r,
                  ),
                ),
              ),
          ],
        ),
        _RuleCard(
          color: FcbColors.control,
          title: l.controlChanges,
          children: [
            _ControlRule(
              label: 'CC1',
              rule: plan.cc1,
              onChanged: (r) => setState(() => plan = plan.copyWith(cc1: r)),
            ),
            _ControlRule(
              label: 'CC2',
              rule: plan.cc2,
              onChanged: (r) => setState(() => plan = plan.copyWith(cc2: r)),
            ),
          ],
        ),
        _RuleCard(
          color: FcbColors.expression,
          title: l.expressionPedals,
          children: [
            _ExpressionRule(
              label: 'A',
              rule: plan.expA,
              onChanged: (r) => setState(() => plan = plan.copyWith(expA: r)),
            ),
            _ExpressionRule(
              label: 'B',
              rule: plan.expB,
              onChanged: (r) => setState(() => plan = plan.copyWith(expB: r)),
            ),
          ],
        ),
        _RuleCard(
          color: FcbColors.note,
          title: l.noteSection,
          children: [
            _NumberRule(
              label: l.note,
              rule: plan.note,
              display: noteName,
              onChanged: (r) => setState(() => plan = plan.copyWith(note: r)),
            ),
          ],
        ),
        _RuleCard(
          color: FcbColors.relay,
          title: l.relays,
          children: [
            _SwitchRule(
              label: l.relayN(1),
              rule: plan.relay1,
              onChanged: (r) => setState(() => plan = plan.copyWith(relay1: r)),
            ),
            _SwitchRule(
              label: l.relayN(2),
              rule: plan.relay2,
              onChanged: (r) => setState(() => plan = plan.copyWith(relay2: r)),
            ),
          ],
        ),
        if (!wide) _Preview(plan: plan, indexes: indexes),
      ],
    );
    return Scaffold(
      appBar: AppBar(title: Text(l.batchTitle)),
      body: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: form),
                SizedBox(
                  width: 380,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [_Preview(plan: plan, indexes: indexes)],
                  ),
                ),
              ],
            )
          : form,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: plan.changesSomething && indexes.isNotEmpty ? _apply : null,
        backgroundColor: plan.changesSomething ? null : Colors.grey.shade800,
        icon: const Icon(Icons.done_all),
        label: Text(l.batchApply(indexes.length)),
      ),
    );
  }
}

class _Recipes extends StatelessWidget {
  const _Recipes({required this.onPick});
  final ValueChanged<BatchPlan> onPick;

  Future<void> _oneCc(BuildContext context) async {
    final l = AppLocalizations.of(context);
    var cc = 102;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l.recipeOneCc),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.recipeOneCcHint),
              const SizedBox(height: 12),
              NumberField(
                label: l.controller,
                value: cc,
                onChanged: (v) => setState(() => cc = v),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l.use),
            ),
          ],
        ),
      ),
    );
    if (ok == true) onPick(BatchPlan.oneCcPerPedal(controller: cc));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.recipes, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ActionChip(
              avatar: const Icon(Icons.tune, size: 18),
              label: Text(l.recipeOneCc),
              onPressed: () => _oneCc(context),
            ),
            ActionChip(
              avatar: const Icon(Icons.swap_horiz, size: 18),
              label: Text(l.recipeProgram),
              tooltip: l.recipeProgramHint,
              onPressed: () => onPick(BatchPlan.programPerPedal()),
            ),
            ActionChip(
              avatar: const Icon(Icons.restart_alt, size: 18),
              label: Text(l.recipeClear),
              onPressed: () => onPick(const BatchPlan()),
            ),
          ],
        ),
      ],
    );
  }
}

class _ScopeCard extends StatelessWidget {
  const _ScopeCard({
    required this.banks,
    required this.pedals,
    required this.count,
    required this.onBanks,
    required this.onPedals,
  });
  final RangeValues banks;
  final RangeValues pedals;
  final int count;
  final ValueChanged<RangeValues> onBanks;
  final ValueChanged<RangeValues> onPedals;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(l.whichPedals, style: theme.textTheme.titleSmall),
                const Spacer(),
                Text(
                  l.pedalCount(count),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: FcbColors.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(l.banksRange(banks.start.round(), banks.end.round())),
            RangeSlider(
              values: banks,
              min: 0,
              max: 9,
              divisions: 9,
              labels: RangeLabels(
                '${banks.start.round()}',
                '${banks.end.round()}',
              ),
              onChanged: onBanks,
            ),
            Text(l.pedalsRange(pedals.start.round(), pedals.end.round())),
            RangeSlider(
              values: pedals,
              min: 1,
              max: 10,
              divisions: 9,
              labels: RangeLabels(
                '${pedals.start.round()}',
                '${pedals.end.round()}',
              ),
              onChanged: onPedals,
            ),
            Wrap(
              spacing: 8,
              children: [
                ActionChip(
                  label: Text(l.scopeAll),
                  onPressed: () {
                    onBanks(const RangeValues(0, 9));
                    onPedals(const RangeValues(1, 10));
                  },
                ),
                ActionChip(
                  label: Text(l.scopeCurrentBank(FcbDocument.instance.bank)),
                  onPressed: () {
                    final b = FcbDocument.instance.bank.toDouble();
                    onBanks(RangeValues(b, b));
                    onPedals(const RangeValues(1, 10));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RuleCard extends StatelessWidget {
  const _RuleCard({
    required this.color,
    required this.title,
    required this.children,
  });
  final Color color;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            ...children,
          ],
        ),
      ),
    ),
  );
}

/// Linha de regra: rótulo, modo e os campos do modo escolhido.
class _RuleRow extends StatelessWidget {
  const _RuleRow({
    required this.label,
    required this.mode,
    required this.fields,
  });
  final String label;
  final Widget mode;
  final List<Widget> fields;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Wrap(
      spacing: 12,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 44,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        mode,
        ...fields,
      ],
    ),
  );
}

class _ModeButtons extends StatelessWidget {
  const _ModeButtons({
    required this.mode,
    required this.modes,
    required this.onChanged,
  });
  final BatchMode mode;
  final List<BatchMode> modes;
  final ValueChanged<BatchMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    String label(BatchMode m) => switch (m) {
      BatchMode.keep => l.modeKeep,
      BatchMode.off => l.modeOff,
      BatchMode.fixed =>
        modes.contains(BatchMode.sequence) ? l.modeFixed : l.modeOn,
      BatchMode.sequence => l.modeSequence,
    };
    return _choice(
      context,
      values: modes,
      label: label,
      selected: mode,
      onChanged: onChanged,
    );
  }
}

/// Valor fixo ou em sequência (trocas de programa, nota, valor do CC).
List<Widget> _numberFields(
  BuildContext context,
  BatchNumber rule,
  ValueChanged<BatchNumber> onChanged, {
  String Function(int)? display,
}) {
  final l = AppLocalizations.of(context);
  return [
    if (rule.mode == BatchMode.fixed)
      NumberField(
        label: l.value,
        value: rule.value,
        display: display,
        onChanged: (v) => onChanged(rule.copyWith(value: v)),
      ),
    if (rule.mode == BatchMode.sequence) ...[
      NumberField(
        label: l.startAt,
        value: rule.value,
        display: display,
        onChanged: (v) => onChanged(rule.copyWith(value: v)),
      ),
      NumberField(
        label: l.step,
        value: rule.step,
        min: -127,
        max: 127,
        onChanged: (v) => onChanged(rule.copyWith(step: v)),
      ),
    ],
  ];
}

class _NumberRule extends StatelessWidget {
  const _NumberRule({
    required this.label,
    required this.rule,
    required this.onChanged,
    this.display,
  });
  final String label;
  final BatchNumber rule;
  final ValueChanged<BatchNumber> onChanged;
  final String Function(int)? display;

  @override
  Widget build(BuildContext context) => _RuleRow(
    label: label,
    mode: _ModeButtons(
      mode: rule.mode,
      modes: BatchMode.values,
      onChanged: (m) => onChanged(rule.copyWith(mode: m)),
    ),
    fields: _numberFields(context, rule, onChanged, display: display),
  );
}

class _ControlRule extends StatelessWidget {
  const _ControlRule({
    required this.label,
    required this.rule,
    required this.onChanged,
  });
  final String label;
  final BatchControl rule;
  final ValueChanged<BatchControl> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final on = rule.mode == BatchMode.fixed;
    return _RuleRow(
      label: label,
      mode: _ModeButtons(
        mode: rule.mode,
        modes: const [BatchMode.keep, BatchMode.off, BatchMode.fixed],
        onChanged: (m) => onChanged(rule.copyWith(mode: m)),
      ),
      fields: [
        if (on) ...[
          NumberField(
            label: l.controller,
            value: rule.controller,
            onChanged: (v) => onChanged(rule.copyWith(controller: v)),
          ),
          _choice(
            context,
            values: const [BatchMode.fixed, BatchMode.sequence],
            label: (m) => m == BatchMode.fixed ? l.valueFixed : l.valueSequence,
            selected: rule.value.mode,
            onChanged: (m) =>
                onChanged(rule.copyWith(value: rule.value.copyWith(mode: m))),
          ),
          ..._numberFields(
            context,
            rule.value,
            (v) => onChanged(rule.copyWith(value: v)),
          ),
        ],
      ],
    );
  }
}

class _ExpressionRule extends StatelessWidget {
  const _ExpressionRule({
    required this.label,
    required this.rule,
    required this.onChanged,
  });
  final String label;
  final BatchExpression rule;
  final ValueChanged<BatchExpression> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return _RuleRow(
      label: label,
      mode: _ModeButtons(
        mode: rule.mode,
        modes: const [BatchMode.keep, BatchMode.off, BatchMode.fixed],
        onChanged: (m) => onChanged(rule.copyWith(mode: m)),
      ),
      fields: [
        if (rule.mode == BatchMode.fixed) ...[
          NumberField(
            label: l.controller,
            value: rule.controller,
            onChanged: (v) => onChanged(rule.copyWith(controller: v)),
          ),
          NumberField(
            label: l.minimum,
            value: rule.min,
            onChanged: (v) => onChanged(rule.copyWith(min: v)),
          ),
          NumberField(
            label: l.maximum,
            value: rule.max,
            onChanged: (v) => onChanged(rule.copyWith(max: v)),
          ),
        ],
      ],
    );
  }
}

class _SwitchRule extends StatelessWidget {
  const _SwitchRule({
    required this.label,
    required this.rule,
    required this.onChanged,
  });
  final String label;
  final BatchSwitch rule;
  final ValueChanged<BatchSwitch> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return _RuleRow(
      label: label,
      mode: _choice(
        context,
        values: const [BatchSwitch.keep, BatchSwitch.off, BatchSwitch.on],
        label: (v) => switch (v) {
          BatchSwitch.keep => l.modeKeep,
          BatchSwitch.off => l.modeOff,
          BatchSwitch.on => l.modeOn,
        },
        selected: rule,
        onChanged: onChanged,
      ),
      fields: const [],
    );
  }
}

/// Como ficam os primeiros e o último pedal escolhidos.
class _Preview extends StatelessWidget {
  const _Preview({required this.plan, required this.indexes});
  final BatchPlan plan;
  final List<int> indexes;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final setup = FcbDocument.instance.setup;
    final shown = indexes.length <= 4
        ? indexes
        : [...indexes.take(3), indexes.last];
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.preview, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            if (indexes.isEmpty) Text(l.noPedalsChosen),
            for (final (n, i) in shown.indexed) ...[
              if (n == 3 && indexes.length > 4)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text('⋮', style: theme.textTheme.titleMedium),
                ),
              Text(pedalLabel(l, i), style: theme.textTheme.labelLarge),
              Builder(
                builder: (context) {
                  final after = plan.applyTo(
                    setup.preset(i),
                    indexes.indexOf(i),
                  );
                  final lines = summarize(after).map((e) => e.$2).toList();
                  final exp = [
                    if (after.expA.enabled) 'EXP A CC ${after.expA.controller}',
                    if (after.expB.enabled) 'EXP B CC ${after.expB.controller}',
                  ];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      [...lines, ...exp].isEmpty
                          ? l.sendsNothing
                          : [...lines, ...exp].join(' · '),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        color: FcbColors.accent,
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Escolha entre poucas opções: botões lado a lado em telas largas e uma
/// lista suspensa no celular (os botões não cabem e quebram as palavras).
Widget _choice<T>(
  BuildContext context, {
  required List<T> values,
  required String Function(T) label,
  required T selected,
  required ValueChanged<T> onChanged,
}) {
  if (MediaQuery.sizeOf(context).width < 600) {
    return DropdownButton<T>(
      value: selected,
      isDense: true,
      items: [
        for (final v in values)
          DropdownMenuItem(value: v, child: Text(label(v))),
      ],
      onChanged: (v) => onChanged(v as T),
    );
  }
  return SegmentedButton<T>(
    showSelectedIcon: false,
    style: const ButtonStyle(visualDensity: VisualDensity.compact),
    segments: [
      for (final v in values) ButtonSegment(value: v, label: Text(label(v))),
    ],
    selected: {selected},
    onSelectionChanged: (s) => onChanged(s.first),
  );
}
