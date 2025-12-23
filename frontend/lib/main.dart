import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/app_router.dart';
import 'src/theme/app_theme.dart';
import 'src/providers.dart';

void main() {
  runApp(const ProviderScope(child: MainApp()));
}
class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Ethical AI Credit Scoring',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        if (child == null) return const SizedBox.shrink();
        return Builder(
          builder: (inner) => Stack(
            children: [
              child,
              // Debug-only hidden dev button: appears only in debug builds
              if (kDebugMode)
                const Positioned(top: 12, right: 12, child: DebugFab()),
            ],
          ),
        );
      },
    );
  }
}

class DebugFab extends ConsumerWidget {
  const DebugFab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: FloatingActionButton(
        mini: true,
        backgroundColor: Colors.black54,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (ctx) {
              final currentVariant = ref.watch(ctaVariantProvider);
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dev Controls',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('CTA Variant:'),
                        const SizedBox(width: 12),
                        ToggleButtons(
                          isSelected: [
                            currentVariant == 0,
                            currentVariant == 1,
                          ],
                          onPressed: (i) =>
                              ref.read(ctaVariantProvider.notifier).state = i,
                          children: const [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text('A'),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text('B'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('Theme:'),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () =>
                              ref.read(themeModeProvider.notifier).state =
                                  ThemeMode.light,
                          child: const Text('Light'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () =>
                              ref.read(themeModeProvider.notifier).state =
                                  ThemeMode.dark,
                          child: const Text('Dark'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () =>
                              ref.read(themeModeProvider.notifier).state =
                                  ThemeMode.system,
                          child: const Text('System'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            },
          );
        },
        child: const Icon(Icons.developer_mode, color: Colors.white, size: 18),
      ),
    );
  }
}
