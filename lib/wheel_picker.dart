import 'package:flutter/material.dart';
import 'package:flutter_wheel_picker/wheel_painter.dart';

/// A customizable wheel-style picker widget with inertia scrolling
/// and elastic bounds handling.
///
/// Supports overscroll elasticity, momentum-based deceleration,
/// and configurable scroll sensitivity.
class WheelPicker extends StatefulWidget {
  /// The minimum allowed value for the wheel.
  /// When the current value goes below this, it bounces back.
  final double minValue;

  /// The maximum allowed value for the wheel.
  /// When the current value goes above this, it bounces back.
  final double maxValue;

  /// Factor that controls how sensitive scrolling is.
  /// Higher values cause larger changes for the same drag distance.
  ///
  /// Example: `0.1` means 10px drag = 1.0 value change.
  final double scrollFactor;

  /// Factor that controls how much the wheel moves during overscroll.
  /// This creates a subtle elastic feel when going out of bounds.
  ///
  /// Example: `0.045` means each drag out of bounds only moves the wheel by 4.5% of normal speed.
  final double overscrollFactor;

  /// Friction factor applied during inertia scrolling.
  /// Lower values stop the wheel sooner, higher values let it spin longer.
  ///
  /// Example: `0.95` means velocity loses 5% per frame.
  final double inertiaFriction;

  /// Minimum velocity required to trigger inertia scrolling.
  /// If the drag is slower than this, it stops immediately.
  final double velocityThreshold;

  /// Radius of the wheel in logical pixels.
  final double radius;

  /// Child widget to display inside the wheel.
  final Widget? child;

  /// Callback function called when the selected value changes.
  final Function(double value)? onValueChanged;

  const WheelPicker({
    super.key,
    this.minValue = 0,
    this.maxValue = 100,
    this.scrollFactor = 0.1,
    this.overscrollFactor = 0.045,
    this.inertiaFriction = 0.95,
    this.velocityThreshold = 5.0,
    this.radius = 5.0,
    this.child,
    this.onValueChanged,
  });

  @override
  State<WheelPicker> createState() => _WheelPickerState();
}

class _WheelPickerState extends State<WheelPicker>
    with TickerProviderStateMixin {
  double currentValue = 0;
  double _velocity = 0;
  late AnimationController _inertiaCtrl;
  late AnimationController _boundsCtrl;
  Animation<double>? _boundsAnim;

  @override
  void initState() {
    super.initState();
    _inertiaCtrl = AnimationController.unbounded(vsync: this)
      ..addListener(_inertiaTick);
    _boundsCtrl = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _inertiaCtrl.dispose();
    _boundsCtrl.dispose();
    super.dispose();
  }

  /// Starts inertia scrolling if velocity is above the threshold.
  /// If the value is already out of bounds, animates back instead.
  void _startInertia() {
    if (currentValue < widget.minValue || currentValue > widget.maxValue) {
      _animateToBounds();
      return;
    }
    if (_velocity.abs() < widget.velocityThreshold) return;

    _inertiaCtrl.stop();
    _inertiaCtrl.value = 0;
    _inertiaCtrl.animateTo(
      1,
      duration: const Duration(seconds: 5),
      curve: Curves.linear,
    );
  }

  /// Called on each inertia frame to apply velocity and update value.
  void _inertiaTick() {
    _velocity *= widget.inertiaFriction;
    if (_velocity.abs() < 0.01) {
      _inertiaCtrl.stop();
      return;
    }

    final newValue = currentValue + _velocity * 0.016;

    if (newValue < widget.minValue || newValue > widget.maxValue) {
      _inertiaCtrl.stop();
      _animateToBounds();
    } else {
      setState(() {
        currentValue = newValue;
        _updateValue();
      });
    }
  }

  /// Animates the value back into the valid range with an elastic curve.
  void _animateToBounds() {
    double targetValue = currentValue;
    if (currentValue < widget.minValue) {
      targetValue = widget.minValue;
    } else if (currentValue > widget.maxValue) {
      targetValue = widget.maxValue;
    }

    _boundsAnim = Tween<double>(
      begin: currentValue,
      end: targetValue,
    ).animate(CurvedAnimation(parent: _boundsCtrl, curve: Curves.elasticOut));

    _boundsAnim!.removeListener(_boundsTick);
    _boundsAnim!.addListener(_boundsTick);

    _boundsCtrl
      ..stop()
      ..duration = const Duration(milliseconds: 750)
      ..reset()
      ..forward();
  }

  void _boundsTick() {
    setState(() {
      currentValue = _boundsAnim!.value;
      _updateValue();
    });
  }

  _updateValue() {
    if (currentValue < widget.minValue || currentValue > widget.maxValue) {
      return;
    }
    widget.onValueChanged?.call(currentValue);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (_) {
        _inertiaCtrl.stop();
        _boundsCtrl.stop();
        _velocity = 0;
      },
      onPanUpdate: (details) {
        final renderBox = context.findRenderObject() as RenderBox;
        final centerX = renderBox.size.width / 2;
        final globalX = details.globalPosition.dx;
        final deltaX = details.delta.dx;
        final deltaY = details.delta.dy;

        final xValueChange = -deltaX * widget.scrollFactor;
        final yValueChange =
            deltaY != 0
                ? (globalX < centerX ? deltaY : -deltaY) * widget.scrollFactor
                : 0.0;

        final valueChange =
            (deltaX != 0 && deltaY != 0)
                ? (xValueChange + yValueChange) / 2
                : xValueChange + yValueChange;

        final newValue = currentValue + valueChange;

        if (newValue < widget.minValue) {
          currentValue -= widget.overscrollFactor;
          currentValue = currentValue.clamp(
            widget.minValue - 5.0,
            widget.maxValue,
          );
          _updateValue();
        } else if (newValue > widget.maxValue) {
          currentValue += widget.overscrollFactor;
          currentValue = currentValue.clamp(
            widget.minValue,
            widget.maxValue + 5.0,
          );
          _updateValue();
        } else {
          currentValue = newValue.clamp(
            widget.minValue - 5.0,
            widget.maxValue + 5.0,
          );
          _updateValue();
        }

        _velocity = valueChange * 60;
        setState(() {});
      },
      onPanEnd: (_) => _startInertia(),
      child: CustomPaint(
        painter: WheelPickerPainter(
          minValue: widget.minValue,
          maxValue: widget.maxValue,
          currentValue: currentValue,
          radius: widget.radius,
        ),
        child: ClipOval(
          child: SizedBox(
            height: (widget.radius + 32) * 2,
            width: (widget.radius + 32) * 2,
            child: Center(
              child: SizedBox(
                height: (widget.radius - 32) * 2,
                width: (widget.radius - 32) * 2,
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
