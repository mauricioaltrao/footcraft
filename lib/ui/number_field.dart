import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Número MIDI (0–127 por padrão) com botões − e + e digitação direta.
class NumberField extends StatefulWidget {
  const NumberField({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 127,
    this.enabled = true,
    this.width = 120,
    this.label,
    this.display,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final bool enabled;
  final double width;
  final String? label;

  /// Texto extra à direita do número (ex.: nome da nota).
  final String Function(int value)? display;

  @override
  State<NumberField> createState() => _NumberFieldState();
}

class _NumberFieldState extends State<NumberField> {
  late final _text = TextEditingController(text: '${widget.value}');
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (!_focus.hasFocus) _commit();
    });
  }

  @override
  void didUpdateWidget(NumberField old) {
    super.didUpdateWidget(old);
    if (!_focus.hasFocus && _text.text != '${widget.value}')
      _text.text = '${widget.value}';
  }

  @override
  void dispose() {
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _commit() {
    final v = int.tryParse(_text.text);
    if (v == null) {
      _text.text = '${widget.value}';
      return;
    }
    final c = v.clamp(widget.min, widget.max);
    _text.text = '$c';
    if (c != widget.value) widget.onChanged(c);
  }

  void _step(int d) {
    final c = (widget.value + d).clamp(widget.min, widget.max);
    if (c != widget.value) widget.onChanged(c);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extra = widget.display?.call(widget.value);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Text(widget.label!, style: theme.textTheme.labelMedium),
          ),
        _StepButton(
          icon: Icons.remove,
          onPressed: widget.enabled && widget.value > widget.min
              ? () => _step(-1)
              : null,
        ),
        SizedBox(
          width: 52,
          child: TextField(
            controller: _text,
            focusNode: _focus,
            enabled: widget.enabled,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(3),
            ],
            style: theme.textTheme.titleMedium?.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 8),
            ),
            onSubmitted: (_) => _commit(),
          ),
        ),
        _StepButton(
          icon: Icons.add,
          onPressed: widget.enabled && widget.value < widget.max
              ? () => _step(1)
              : null,
        ),
        if (extra != null)
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Text(
              extra,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onPressed});
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
    visualDensity: VisualDensity.compact,
    iconSize: 18,
    onPressed: onPressed,
    icon: Icon(icon),
  );
}
