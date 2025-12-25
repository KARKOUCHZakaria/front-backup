import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers.dart';
import '../providers/auth_provider.dart';
import '../models/application.dart';
import '../theme/app_theme.dart';
import '../widgets/responsive_builder.dart';
import '../widgets/app_drawer.dart';
import 'dart:math' as math;

/// Fully responsive user home dashboard with adaptive layout for mobile, tablet, and desktop
class UserHomeDashboardScreen extends ConsumerWidget {
  const UserHomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final userId = user?.id;

    // Debug: Log user info
    print('🔍 Dashboard - User: ${user?.username}, ID: $userId');

    // Fetch applications and credit score if user is logged in
    final applicationsAsync = userId != null
        ? ref.watch(userApplicationsProvider(userId))
        : const AsyncValue.data(<Application>[]);

    final creditScoreAsync = userId != null
        ? ref.watch(userCreditScoreProvider(userId))
        : const AsyncValue.data(null);

    // Debug: Log async states
    print(
      '🔍 Applications loading: ${applicationsAsync.isLoading}, hasValue: ${applicationsAsync.hasValue}',
    );
    print(
      '🔍 CreditScore loading: ${creditScoreAsync.isLoading}, hasValue: ${creditScoreAsync.hasValue}',
    );

    applicationsAsync.whenData(
      (apps) => print('✅ Applications loaded: ${apps.length} items'),
    );
    if (applicationsAsync.hasError) {
      print('❌ Applications error: ${applicationsAsync.error}');
    }

    creditScoreAsync.whenData((score) => print('✅ Credit score: $score'));
    if (creditScoreAsync.hasError) {
      print('❌ Credit score error: ${creditScoreAsync.error}');
    }

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: AppColors.darkBg,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: ResponsiveBuilder(
          builder: (context, deviceType, constraints) {
            final padding = ResponsiveValue<double>(
              mobile: 20.0,
              tablet: 32.0,
              desktop: 48.0,
            ).getValue(deviceType);

            final spacing = ResponsiveValue<double>(
              mobile: 32.0,
              tablet: 40.0,
              desktop: 48.0,
            ).getValue(deviceType);

            // Show loading state
            if (applicationsAsync.isLoading || creditScoreAsync.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // Get applications and credit score from AsyncValue
            final applications = applicationsAsync.value ?? [];
            final creditScore =
                creditScoreAsync.value ?? 785; // Default to 785 if no data

            // For desktop and tablet, use a two-column layout
            if (deviceType == DeviceType.desktop ||
                deviceType == DeviceType.tablet) {
              return SingleChildScrollView(
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: deviceType == DeviceType.desktop ? 1400 : 1000,
                    ),
                    padding: EdgeInsets.all(padding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context, deviceType, ref),
                        SizedBox(height: spacing),
                        // Two-column layout for desktop/tablet
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildScoreCard(
                                    context,
                                    deviceType,
                                    creditScore,
                                  ),
                                  SizedBox(height: spacing),
                                  _buildQuickActions(context, deviceType),
                                ],
                              ),
                            ),
                            SizedBox(width: spacing),
                            Expanded(
                              flex: 3,
                              child: _buildRecentActivity(
                                context,
                                applications,
                                deviceType,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            // Mobile layout - single column
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, deviceType, ref),
                    SizedBox(height: spacing),
                    _buildScoreCard(context, deviceType, creditScore),
                    SizedBox(height: spacing),
                    _buildQuickActions(context, deviceType),
                    SizedBox(height: spacing),
                    _buildRecentActivity(context, applications, deviceType),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    DeviceType deviceType,
    WidgetRef ref,
  ) {
    final avatarRadius = ResponsiveValue<double>(
      mobile: 24,
      tablet: 28,
      desktop: 32,
    ).getValue(deviceType);

    final titleSize = ResponsiveValue<double>(
      mobile: 22,
      tablet: 26,
      desktop: 30,
    ).getValue(deviceType);

    final user = ref.watch(currentUserProvider);
    final userName = user?.username ?? 'User';

    // Get time-based greeting
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 18
        ? 'Good Afternoon'
        : 'Good Evening';

    return Row(
      children: [
        CircleAvatar(
          radius: avatarRadius,
          backgroundColor: AppColors.primaryCyan.withOpacity(0.2),
          child: Icon(
            Icons.person,
            color: AppColors.primaryCyan,
            size: avatarRadius * 0.8,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting, $userName',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: titleSize,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () => context.push('/notifications'),
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.white),
          onPressed: () => context.push('/settings'),
        ),
      ],
    );
  }

  Widget _buildScoreCard(
    BuildContext context,
    DeviceType deviceType,
    int creditScore,
  ) {
    final cardPadding = ResponsiveValue<double>(
      mobile: 28,
      tablet: 36,
      desktop: 44,
    ).getValue(deviceType);

    final gaugeSize = ResponsiveValue<double>(
      mobile: 200,
      tablet: 240,
      desktop: 280,
    ).getValue(deviceType);

    final scoreSize = ResponsiveValue<double>(
      mobile: 56,
      tablet: 64,
      desktop: 72,
    ).getValue(deviceType);

    // Determine score status
    final scoreStatus = creditScore >= 750
        ? 'Excellent'
        : creditScore >= 700
        ? 'Very Good'
        : creditScore >= 650
        ? 'Good'
        : creditScore >= 600
        ? 'Fair'
        : 'Poor';

    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: AppColors.darkTeal,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
      ),
      child: Column(
        children: [
          SizedBox(
            width: gaugeSize,
            height: gaugeSize,
            child: CustomPaint(
              painter: ScoreGaugePainter(
                score: creditScore.toDouble(),
                maxScore: 900,
                strokeWidth: 16,
                activeColor: AppColors.primaryCyan,
                inactiveColor: AppColors.mediumTeal,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$creditScore',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: scoreSize,
                      ),
                    ),
                    Text(
                      'credit score',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color:
                  (creditScore >= 700
                          ? AppColors.success
                          : creditScore >= 600
                          ? AppColors.warning
                          : AppColors.error)
                      .withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color:
                    (creditScore >= 700
                            ? AppColors.success
                            : creditScore >= 600
                            ? AppColors.warning
                            : AppColors.error)
                        .withOpacity(0.3),
              ),
            ),
            child: Text(
              scoreStatus,
              style: TextStyle(
                color: creditScore >= 700
                    ? AppColors.success
                    : creditScore >= 600
                    ? AppColors.warning
                    : AppColors.error,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, DeviceType deviceType) {
    // For desktop/tablet, show buttons in a column
    if (deviceType == DeviceType.desktop || deviceType == DeviceType.tablet) {
      return Column(
        children: [
          _buildActionButton(
            context,
            deviceType,
            icon: Icons.add_circle_outline,
            label: 'New Application',
            onTap: () => context.go('/user/documents'),
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            context,
            deviceType,
            icon: Icons.history,
            label: 'History',
            onTap: () => context.go('/user/history'),
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            context,
            deviceType,
            icon: Icons.person_outline,
            label: 'Profile',
            onTap: () => context.go('/user/profile'),
          ),
        ],
      );
    }

    // Mobile - keep row layout
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            context,
            deviceType,
            icon: Icons.add_circle_outline,
            label: 'New Application',
            onTap: () => context.go('/user/documents'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            context,
            deviceType,
            icon: Icons.history,
            label: 'History',
            onTap: () => context.go('/user/history'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            context,
            deviceType,
            icon: Icons.person_outline,
            label: 'Profile',
            onTap: () => context.go('/user/profile'),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    DeviceType deviceType, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isNewApp = label == 'New Application';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          gradient: isNewApp
              ? LinearGradient(
                  colors: [
                    AppColors.primaryCyan.withOpacity(0.3),
                    AppColors.primaryCyan.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isNewApp ? null : AppColors.darkTeal,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isNewApp
                ? AppColors.primaryCyan.withOpacity(0.5)
                : Colors.white.withOpacity(0.08),
            width: isNewApp ? 1.5 : 1,
          ),
          boxShadow: isNewApp
              ? [
                  BoxShadow(
                    color: AppColors.primaryCyan.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isNewApp
                    ? AppColors.primaryCyan.withOpacity(0.25)
                    : AppColors.primaryCyan.withOpacity(0.15),
                shape: BoxShape.circle,
                border: isNewApp
                    ? Border.all(
                        color: AppColors.primaryCyan.withOpacity(0.4),
                        width: 2,
                      )
                    : null,
              ),
              child: Icon(
                icon,
                color: AppColors.primaryCyan,
                size: isNewApp ? 28 : 24,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                color: isNewApp ? AppColors.primaryCyan : Colors.white,
                fontSize: 13,
                fontWeight: isNewApp ? FontWeight.w700 : FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(
    BuildContext context,
    List<Application> applications,
    DeviceType deviceType,
  ) {
    final titleSize = ResponsiveValue<double>(
      mobile: 22,
      tablet: 26,
      desktop: 30,
    ).getValue(deviceType);

    // Sort applications by creation date (newest first) and take first 3
    final recentApps = applications.isNotEmpty
        ? (applications.toList()
                ..sort((a, b) => b.createdAt.compareTo(a.createdAt)))
              .take(3)
              .toList()
        : <Application>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: titleSize,
              ),
            ),
            if (applications.isNotEmpty)
              TextButton(
                onPressed: () => context.go('/user/applications'),
                child: Text(
                  'View All',
                  style: TextStyle(
                    color: AppColors.primaryCyan,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (recentApps.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No applications yet',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => context.go('/user/documents'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryCyan,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Start New Application'),
                  ),
                ],
              ),
            ),
          )
        else
          ...recentApps.asMap().entries.map((entry) {
            final app = entry.value;
            final isLast = entry.key == recentApps.length - 1;

            // Format date
            final now = DateTime.now();
            final createdAt = app.createdAt;
            final difference = now.difference(createdAt);
            final dateStr = difference.inDays == 0
                ? 'Today'
                : difference.inDays == 1
                ? 'Yesterday'
                : '${createdAt.month}/${createdAt.day}';

            // Determine status color
            final statusColor = app.status.toUpperCase() == 'APPROVED'
                ? AppColors.success
                : app.status.toUpperCase() == 'REJECTED'
                ? AppColors.error
                : app.status.toUpperCase() == 'PENDING'
                ? AppColors.warning
                : AppColors.primaryCyan;

            // Get organization/bank name (use organization type or default)
            final bankName = app.organizationType ?? 'Credit Application';

            return Column(
              children: [
                _buildActivityItem(
                  context,
                  bank: bankName,
                  amount: app.loanAmountDisplay,
                  type: app.nameContractType ?? 'Loan',
                  date: dateStr,
                  status: app.statusDisplay,
                  statusColor: statusColor,
                ),
                if (!isLast) const SizedBox(height: 12),
              ],
            );
          }),
      ],
    );
  }

  Widget _buildActivityItem(
    BuildContext context, {
    required String bank,
    required String amount,
    required String type,
    required String date,
    required String status,
    required Color statusColor,
  }) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkTeal,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bank,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$amount • $type',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  date,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.mediumTeal,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward,
                    color: AppColors.textSecondary,
                    size: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Commented out unused method
  /*
  Widget _buildRecentApplications(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Applications',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () => context.go('/user/history'),
              child: Text(
                'View All',
                style: TextStyle(color: AppColors.primaryCyan),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildApplicationItem(
          date: 'Dec 13, 2025',
          score: 820,
          status: 'Approved',
          statusColor: Colors.green,
        ),
        const SizedBox(height: 12),
        _buildApplicationItem(
          date: 'Nov 28, 2025',
          score: 785,
          status: 'Approved',
          statusColor: Colors.green,
        ),
        const SizedBox(height: 12),
        _buildApplicationItem(
          date: 'Oct 15, 2025',
          score: 720,
          status: 'Under Review',
          statusColor: Colors.orange,
        ),
      ],
    );
  }
  */

  /*
  Widget _buildApplicationItem({
    required String date,
    required int score,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primaryCyan.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '$score',
                style: TextStyle(
                  color: AppColors.primaryCyan,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Credit Score Application',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),    );
  }
  */
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
