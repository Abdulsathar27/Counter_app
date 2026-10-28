import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_constants.dart';

/// Asks for a new goal. Returns the entered goal, or null when cancelled.
Future<int?> showGoalDialog(BuildContext context, {required int current}) {
  return showDialog<int>(context: context, builder: (_) => _GoalDialog(current: current));
}

class _GoalDialog extends StatefulWidget {
  const _GoalDialog({required this.current});

  final int current;

  @override
  State<_GoalDialog> createState() => _GoalDialogState();
}

class _GoalDialogState extends State<_GoalDialog> {
  late final TextEditingController _controller = TextEditingController(text: '${widget.current}')
    ..selection = TextSelection(baseOffset: 0, extentOffset: '${widget.current}'.length);

  int? get _goal {
    final value = int.tryParse(_controller.text);
    if (value == null || value < AppConstants.minGoal || value > AppConstants.maxGoal) return null;
    return value;
  }

  void _submit() {
    final goal = _goal;
    if (goal != null) Navigator.of(context).pop(goal);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set goal'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter('${AppConstants.maxGoal}'.length),
        ],
        textInputAction: TextInputAction.done,
        onChanged: (_) => setState(() {}),
        onSubmitted: (_) => _submit(),
        decoration: const InputDecoration(hintText: 'e.g. 33'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        TextButton(onPressed: _goal == null ? null : _submit, child: const Text('Save')),
      ],
    );
  }
}
