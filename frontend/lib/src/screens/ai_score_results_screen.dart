import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../providers.dart';
import 'dart:math' as math;

class AIScoreResultsScreen extends ConsumerWidget {
  const AIScoreResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the real score from provider
    final scoreResult = ref.watch(latestScoreProvider);
    final score = scoreResult?.score ?? 750;
    final status = scoreResult?.status ?? 'Approved';
    final shapValues = scoreResult?.shapValues ?? [];

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: AppColors.darkBg,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {},
        ),
        title: const Text('Your AI Score', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildScoreGauge(context, score),
              const SizedBox(height: 32),
              _buildApprovalStatus(context, status),
              const SizedBox(height: 32),
              _buildExplanationSection(context),
              const SizedBox(height: 24),
              _buildFactorsChart(context, shapValues),
              const SizedBox(height: 32),
              _buildNextSteps(context, status),
              const SizedBox(height: 24),
              _buildViewReportButton(context),
            ],
          ),
        ),
      ),
    );
  }

  String _getScoreLabel(int score) {
    if (score >= 750) return 'Excellent';
    if (score >= 600) return 'Good';
    if (score >= 450) return 'Fair';
    return 'Poor';
  }

  Widget _buildScoreGauge(BuildContext context, int score) {
    return Center(
      child: SizedBox(
        width: 240,
        height: 240,
        child: CustomPaint(
          painter: ScoreGaugePainter(
            score: score.toDouble(),
            maxScore: 900,
            strokeWidth: 18,
            activeColor: AppColors.primaryCyan,
            inactiveColor: AppColors.mediumTeal,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$score',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 64,
                  ),
                ),
                Text(
                  _getScoreLabel(score),
                  style: TextStyle(
                    color: AppColors.primaryCyan,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildApprovalStatus(BuildContext context, String status) {
    final isApproved = status.toLowerCase() == 'approved';
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: (isApproved ? AppColors.success : AppColors.error).withOpacity(0.15),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: (isApproved ? AppColors.success : AppColors.error).withOpacity(0.4), width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isApproved ? Icons.check_circle : Icons.cancel,
              color: isApproved ? AppColors.success : AppColors.error,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              status.toUpperCase(),
              style: TextStyle(
                color: isApproved ? AppColors.success : AppColors.error,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExplanationSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How Your Score Was Calculated',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Your score is based on several key factors. Your consistent on-time payments had the most significant positive impact.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildFactorsChart(BuildContext context, List<ShapValue> shapValues) {
    // Use real SHAP values if available, otherwise use defaults
    final List<Map<String, dynamic>> factors;
    
    if (shapValues.isNotEmpty) {
      // Convert SHAP values to display format
      factors = shapValues.take(6).map((shap) {
        final feature = shap.feature;
        final value = shap.value;
        // Format feature name for display
        final label = feature
            .replaceAll('_', ' ')
            .split(' ')
            .map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}' : '')
            .join(' ');
        return {
          'label': label,
          'value': value.abs().clamp(0.0, 1.0),
          'positive': value >= 0,
        };
      }).toList();
    } else {
      // Default factors if no SHAP values
      factors = [
        {'label': 'Payment History', 'value': 0.85, 'positive': true},
        {'label': 'Credit Utilization', 'value': 0.65, 'positive': true},
        {'label': 'Credit Age', 'value': 0.25, 'positive': false},
        {'label': 'Recent Inquiries', 'value': 0.15, 'positive': false},
      ];
    }

    return Column(
      children: factors.map((factor) {
        final isPositive = factor['positive'] as bool;
        final value = (factor['value'] as double).abs();
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      factor['label'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                    color: isPositive ? AppColors.success : AppColors.error,
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Stack(
                children: [
                  Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.mediumTeal,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: value,
                    child: Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: isPositive ? AppColors.success : AppColors.error,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNextSteps(BuildContext context, String status) {
    final isApproved = status.toLowerCase() == 'approved';
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkTeal,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isApproved ? 'Congratulations!' : 'How to Improve',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          if (isApproved) ...[
            _buildNextStepItem(
              icon: Icons.check_circle,
              text: 'Your application has been pre-approved! A specialist will contact you shortly.',
            ),
            const SizedBox(height: 12),
            _buildNextStepItem(
              icon: Icons.trending_up,
              text: 'Keep your credit card balance low to maintain a strong score.',
            ),
          ] else ...[
            _buildNextStepItem(
              icon: Icons.schedule,
              text: 'Consider waiting 3-6 months and building your credit history before reapplying.',
            ),
            const SizedBox(height: 12),
            _buildNextStepItem(
              icon: Icons.payment,
              text: 'Make sure all existing debts are paid on time to improve your score.',
            ),
            const SizedBox(height: 12),
            _buildNextStepItem(
              icon: Icons.account_balance,
              text: 'Consider reducing your credit utilization below 30%.',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNextStepItem({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryCyan.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primaryCyan, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildViewReportButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text(
          'View Full Report',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class ScoreGaugePainter extends CustomPainter {
  final double score;
  final double maxScore;
  final double strokeWidth;
  final Color activeColor;
  final Color inactiveColor;

  ScoreGaugePainter({
    required this.score,
    required this.maxScore,
    required this.strokeWidth,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final progress = (score / maxScore).clamp(0.0, 1.0);
    
    // Background arc
    final bgPaint = Paint()
      ..color = inactiveColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 0.75,
      math.pi * 1.5,
      false,
      bgPaint,
    );
    
    // Progress arc
    final progressPaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 0.75,
      math.pi * 1.5 * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant ScoreGaugePainter oldDelegate) {
    return oldDelegate.score != score;
  }
}
