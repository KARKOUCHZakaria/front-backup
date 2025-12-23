import 'package:flutter/material.dart';

/// Breakpoints for responsive design
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}

/// Device type enum
enum DeviceType {
  mobile,
  tablet,
  desktop,
}

/// Responsive builder widget that adapts to different screen sizes
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceType deviceType, BoxConstraints constraints) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  static DeviceType getDeviceType(double width) {
    if (width < Breakpoints.mobile) {
      return DeviceType.mobile;
    } else if (width < Breakpoints.tablet) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < Breakpoints.mobile;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= Breakpoints.mobile && width < Breakpoints.tablet;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= Breakpoints.tablet;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = getDeviceType(constraints.maxWidth);
        return builder(context, deviceType, constraints);
      },
    );
  }
}

/// Responsive value that returns different values based on device type
class ResponsiveValue<T> {
  final T mobile;
  final T? tablet;
  final T? desktop;

  const ResponsiveValue({
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  T getValue(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }

  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final width = MediaQuery.of(context).size.width;
    final deviceType = ResponsiveBuilder.getDeviceType(width);
    final responsiveValue = ResponsiveValue<T>(
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
    return responsiveValue.getValue(deviceType);
  }
}

/// Responsive Scaffold with adaptive layout
class ResponsiveScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? drawer;
  final Widget? endDrawer;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  final bool extendBodyBehindAppBar;
  final bool resizeToAvoidBottomInset;
  final EdgeInsetsGeometry? padding;

  const ResponsiveScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.drawer,
    this.endDrawer,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.extendBodyBehindAppBar = false,
    this.resizeToAvoidBottomInset = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType, constraints) {
        Widget bodyWidget = body;

        // Add responsive padding
        if (padding != null) {
          bodyWidget = Padding(padding: padding!, child: bodyWidget);
        } else {
          // Default responsive padding
          final horizontalPadding = ResponsiveValue<double>(
            mobile: 16.0,
            tablet: 32.0,
            desktop: 64.0,
          ).getValue(deviceType);

          bodyWidget = Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: bodyWidget,
          );
        }

        // Constrain max width for desktop
        if (deviceType == DeviceType.desktop) {
          bodyWidget = Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: bodyWidget,
            ),
          );
        }

        return Scaffold(
          appBar: appBar,
          body: bodyWidget,
          drawer: drawer,
          endDrawer: endDrawer,
          floatingActionButton: floatingActionButton,
          bottomNavigationBar: bottomNavigationBar,
          backgroundColor: backgroundColor,
          extendBodyBehindAppBar: extendBodyBehindAppBar,
          resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        );
      },
    );
  }
}

/// Responsive padding helper
class ResponsivePadding {
  static EdgeInsets all(BuildContext context, {double mobile = 16, double? tablet, double? desktop}) {
    return EdgeInsets.all(
      ResponsiveValue.value(
        context,
        mobile: mobile,
        tablet: tablet,
        desktop: desktop,
      ),
    );
  }

  static EdgeInsets symmetric(
    BuildContext context, {
    double mobileHorizontal = 16,
    double mobileVertical = 16,
    double? tabletHorizontal,
    double? tabletVertical,
    double? desktopHorizontal,
    double? desktopVertical,
  }) {
    return EdgeInsets.symmetric(
      horizontal: ResponsiveValue.value(
        context,
        mobile: mobileHorizontal,
        tablet: tabletHorizontal,
        desktop: desktopHorizontal,
      ),
      vertical: ResponsiveValue.value(
        context,
        mobile: mobileVertical,
        tablet: tabletVertical,
        desktop: desktopVertical,
      ),
    );
  }
}

/// Responsive text size helper
class ResponsiveText {
  static double fontSize(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    return ResponsiveValue.value(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }
}

/// Responsive grid helper
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final int mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
    this.mobileColumns = 1,
    this.tabletColumns,
    this.desktopColumns,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType, constraints) {
        final columns = ResponsiveValue<int>(
          mobile: mobileColumns,
          tablet: tabletColumns,
          desktop: desktopColumns,
        ).getValue(deviceType);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: spacing,
            mainAxisSpacing: runSpacing,
            childAspectRatio: 1.0,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }
}

/// Responsive row/column wrapper
class ResponsiveRowColumn extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final bool switchToColumnOnMobile;

  const ResponsiveRowColumn({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.switchToColumnOnMobile = true,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType, constraints) {
        if (switchToColumnOnMobile && deviceType == DeviceType.mobile) {
          return Column(
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: crossAxisAlignment,
            children: children,
          );
        }
        return Row(
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          children: children,
        );
      },
    );
  }
}

/// Responsive container with adaptive sizing
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double? mobileWidth;
  final double? tabletWidth;
  final double? desktopWidth;
  final double? mobileHeight;
  final double? tabletHeight;
  final double? desktopHeight;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.mobileWidth,
    this.tabletWidth,
    this.desktopWidth,
    this.mobileHeight,
    this.tabletHeight,
    this.desktopHeight,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType, constraints) {
        final width = mobileWidth != null || tabletWidth != null || desktopWidth != null
            ? ResponsiveValue<double?>(
                mobile: mobileWidth,
                tablet: tabletWidth,
                desktop: desktopWidth,
              ).getValue(deviceType)
            : null;

        final height = mobileHeight != null || tabletHeight != null || desktopHeight != null
            ? ResponsiveValue<double?>(
                mobile: mobileHeight,
                tablet: tabletHeight,
                desktop: desktopHeight,
              ).getValue(deviceType)
            : null;

        return Container(
          width: width,
          height: height,
          padding: padding,
          color: color,
          child: child,
        );
      },
    );
  }
}
