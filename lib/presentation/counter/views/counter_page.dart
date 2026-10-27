import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../bloc/counter_bloc.dart';
import '../viewmodels/counter_view_model.dart';
import '../widgets/brand_header.dart';
import '../widgets/counter_bezel.dart';
import '../widgets/counter_caption.dart';
import '../widgets/counter_control_button.dart';
import '../widgets/flip_counter.dart';
import '../widgets/line_icons.dart';

/// The single MUSMILES screen: brand, flip counter stage, and controls.
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
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.stageVerticalPadding,
        horizontal: AppDimensions.stageHorizontalPadding,
      ),
      // Keeps the reference dimensions where they fit and scales the stage down
      // uniformly on very small screens instead of overflowing.
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CounterBezel(
                child: BlocSelector<CounterBloc, CounterState, CounterViewModel>(
                  selector: CounterViewModel.fromState,
                  builder:
                      (context, vm) => FlipCounter(
                        value: vm.displayValue,
                        semanticLabel: vm.semanticLabel,
                        animate: vm.isReady,
                        onTap: () => context.read<CounterBloc>().add(const CounterIncremented()),
                      ),
                ),
              ),
              const SizedBox(height: AppDimensions.captionTopGap),
              const CounterCaption(),
            ],
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
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
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
              ],
            );
          },
        ),
      ),
    );
  }
}
