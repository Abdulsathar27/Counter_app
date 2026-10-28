import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../bloc/counter_bloc.dart';
import '../viewmodels/counter_view_model.dart';
import '../widgets/brand_header.dart';
import '../widgets/count_button.dart';
import '../widgets/counter_control_button.dart';
import '../widgets/goal_dialog.dart';
import '../widgets/goal_ring.dart';
import '../widgets/line_icons.dart';

/// The single MUSMILES screen: brand, progress ring, count button, controls.
class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<CounterBloc, CounterState>(
      listenWhen:
          (previous, current) => current.failure != null && previous.failure != current.failure,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(state.failure!.message)));
      },
      child: const Scaffold(
        backgroundColor: AppColors.canvas,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: AppDimensions.screenTopPadding),
              BrandHeader(),
              Expanded(child: _Stage()),
              _Controls(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stage extends StatelessWidget {
  const _Stage();

  @override
  Widget build(BuildContext context) {
    // Only the fingerprint button counts. The ring is display-only and the
    // rest of the stage does not respond to taps.
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.stageVerticalPadding,
        horizontal: AppDimensions.stageHorizontalPadding,
      ),
      // Keeps the reference dimensions where they fit and scales the stage
      // down uniformly on very small screens instead of overflowing.
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: BlocSelector<CounterBloc, CounterState, CounterViewModel>(
            selector: CounterViewModel.fromState,
            builder:
                (context, vm) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GoalRing(
                      value: vm.displayValue,
                      label: vm.ringLabel,
                      progress: vm.progress,
                      semanticLabel: vm.countLabel,
                    ),
                    const SizedBox(height: AppDimensions.countButtonTopGap),
                    CountButton(
                      semanticLabel: vm.semanticLabel,
                      onPressed: () => context.read<CounterBloc>().add(const CounterIncremented()),
                    ),
                  ],
                ),
          ),
        ),
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls();

  @override
  Widget build(BuildContext context) {
    // The reference's 58px bottom padding includes the home-indicator area;
    // SafeArea already accounts for that, so only the remainder is added.
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final bottomPadding = math.max(
      AppDimensions.controlsBottomPadding - bottomInset,
      AppDimensions.controlsMinBottomPadding,
    );

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: 'Counter controls',
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppDimensions.controlsHorizontalPadding,
          AppDimensions.controlsTopPadding,
          AppDimensions.controlsHorizontalPadding,
          bottomPadding,
        ),
        child: BlocSelector<CounterBloc, CounterState, CounterControlsViewModel>(
          selector: CounterControlsViewModel.fromState,
          builder: (context, vm) {
            final bloc = context.read<CounterBloc>();
            // Scales down on narrow screens instead of overflowing.
            return FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CounterControlButton(
                    glyph: LineIconGlyph.undo,
                    semanticLabel: CounterControlsViewModel.undoLabel,
                    onPressed: vm.canUndo ? () => bloc.add(const CounterUndoRequested()) : null,
                  ),
                  const SizedBox(width: AppDimensions.controlGap),
                  CounterControlButton(
                    glyph: LineIconGlyph.reset,
                    semanticLabel: CounterControlsViewModel.resetLabel,
                    onPressed: () => bloc.add(const CounterResetRequested()),
                  ),
                  const SizedBox(width: AppDimensions.controlGap),
                  CounterControlButton(
                    glyph: vm.vibrationEnabled ? LineIconGlyph.vibrate : LineIconGlyph.vibrateOff,
                    semanticLabel: vm.vibrationLabel,
                    toggled: vm.vibrationEnabled,
                    iconColor: vm.vibrationEnabled ? AppColors.foreground : AppColors.secondary,
                    onPressed: () => bloc.add(const CounterVibrationToggled()),
                  ),
                  const SizedBox(width: AppDimensions.controlGap),
                  CounterControlButton(
                    glyph: LineIconGlyph.target,
                    semanticLabel: vm.goalLabel,
                    onPressed: () async {
                      final goal = await showGoalDialog(context, current: vm.goal);
                      if (goal != null) bloc.add(CounterGoalChanged(goal));
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
