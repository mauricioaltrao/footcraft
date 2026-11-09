import 'package:flutter/material.dart';

import '../fcb/test_mode.dart';
import '../l10n/app_localizations.dart';
import 'describe.dart';
import 'theme.dart';

/// Faixa do modo de teste: o que foi reconhecido e os pedais de expressão.
class TestBanner extends StatelessWidget {
  const TestBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final test = TestMode.instance;
    return ListenableBuilder(
      listenable: test,
      builder: (context, _) {
        if (!test.active) return const SizedBox.shrink();
        final l = AppLocalizations.of(context);
        final theme = Theme.of(context);
        final (icon, color, text) = switch (test) {
          TestMode(unmatched: final u?) => (
            Icons.help_outline,
            Colors.orangeAccent,
            l.testUnmatched(u.join('  ')),
          ),
          TestMode(pressed: final p?) => (
            Icons.check_circle,
            Colors.greenAccent,
            test.ambiguous > 0
                ? '${l.testPressed(pedalLabel(l, p))} ${l.testAmbiguous(test.ambiguous)}'
                : l.testPressed(pedalLabel(l, p)),
          ),
          _ => (Icons.touch_app, FcbColors.accent, l.testWaiting),
        };
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Colors.greenAccent, width: 1.5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.science, color: Colors.greenAccent),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l.testMode,
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: test.stop,
                        icon: const Icon(Icons.stop),
                        label: Text(l.testModeStop),
                      ),
                    ],
                  ),
                  Text(l.testModeHint, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(icon, color: color, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          text,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _ExpressionBar(label: l.expressionN('A'), value: test.expA),
                  const SizedBox(height: 6),
                  _ExpressionBar(label: l.expressionN('B'), value: test.expB),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ExpressionBar extends StatelessWidget {
  const _ExpressionBar({required this.label, required this.value});
  final String label;
  final int? value;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      SizedBox(
        width: 110,
        child: Text(label, style: Theme.of(context).textTheme.labelMedium),
      ),
      Expanded(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            minHeight: 10,
            value: (value ?? 0) / 127,
            color: FcbColors.expression,
            backgroundColor: Colors.white10,
          ),
        ),
      ),
      SizedBox(
        width: 40,
        child: Text(
          value == null ? '–' : '$value',
          textAlign: TextAlign.end,
          style: const TextStyle(fontFamily: 'monospace'),
        ),
      ),
    ],
  );
}
