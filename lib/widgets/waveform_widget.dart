import 'package:flutter/material.dart';
import 'dart:math';
import '../theme/app_colors.dart';

class WaveformWidget extends StatefulWidget {
  final bool isActive;
  final Color? color;
  final int barCount;
  final double height;

  const WaveformWidget({
    super.key,
    required this.isActive,
    this.color,
    this.barCount = 20,
    this.height = 40,
  });

  @override
  State<WaveformWidget> createState() => _WaveformWidgetState();
}

class _WaveformWidgetState extends State<WaveformWidget>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _controllers = List.generate(widget.barCount, (i) {
      return AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 400 + _random.nextInt(400)),
      );
    });

    _animations = _controllers.map((c) {
      return Tween<double>(
        begin: 0.15,
        end: 1.0,
      ).animate(CurvedAnimation(parent: c, curve: Curves.easeInOut));
    }).toList();

    if (widget.isActive) _startAnimations();
  }

  void _startAnimations() {
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 30), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  void _stopAnimations() {
    for (final c in _controllers) {
      c.animateTo(0.15);
    }
  }

  @override
  void didUpdateWidget(WaveformWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _startAnimations();
      } else {
        _stopAnimations();
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.primary;

    return SizedBox(
      height: widget.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(widget.barCount, (i) {
          return AnimatedBuilder(
            animation: _animations[i],
            builder: (context, _) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 3,
                height: widget.height * _animations[i].value,
                decoration: BoxDecoration(
                  color: widget.isActive
                      ? color.withOpacity(0.6 + 0.4 * _animations[i].value)
                      : color.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

// Mic button with waveform
class MicButton extends StatelessWidget {
  final bool isListening;
  final VoidCallback? onTap;

  const MicButton({super.key, required this.isListening, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isListening
              ? AppColors.error.withOpacity(0.1)
              : AppColors.primary.withOpacity(0.1),
          border: Border.all(
            color: isListening ? AppColors.error : AppColors.primary,
            width: 2,
          ),
          boxShadow: isListening
              ? [
                  BoxShadow(
                    color: AppColors.error.withOpacity(0.3),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Icon(
          isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
          color: isListening ? AppColors.error : AppColors.primary,
          size: 28,
        ),
      ),
    );
  }
}
