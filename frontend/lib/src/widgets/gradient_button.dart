import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';

class GradientButton extends ConsumerWidget {
  final String label;
  final VoidCallback? onPressed;
  final double borderRadius;
  final List<Color>? colors;
  final bool isLoading;

  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.borderRadius = 14,
    this.colors,
    this.isLoading = false,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Default color palettes for A/B variants
    const variantA = [Color(0xFF23F6D9), Color(0xFF00C6A6)]; // neon-cyan
    const variantB = [Color(0xFFFF7A00), Color(0xFFFFC857)]; // warm-orange

    final selectedVariant = ref.watch(ctaVariantProvider);
    final gradientColors =
        colors ?? (selectedVariant == 0 ? variantA : variantB);
    final isDisabled = onPressed == null || isLoading;

    return Semantics(
      button: true,
      enabled: !isDisabled,
      label: label,
      child: GestureDetector(
        onTap: isDisabled ? null : onPressed,
        child: Opacity(
          opacity: isDisabled ? 0.5 : 1.0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: isDisabled
                  ? null
                  : [
                      BoxShadow(
                        color: gradientColors.last.withAlpha(
                          (0.24 * 255).round(),
                        ),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
