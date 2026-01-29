import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'Navigation_controller.dart'; // your accent, etc.

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final navCtrl = Get.find<NavController>();

    return Obx(() {
      final currentIndex = navCtrl.currentIndex.value;

      return Container(
        height: 80,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border(
            top: BorderSide(
              color: Colors.grey.withOpacity(0.15),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(5, (index) {
            final bool isActive = currentIndex == index;

            return _NavItem(
              index: index,
              isActive: isActive,
              onTap: () => navCtrl.changeIndex(index),
            );
          }),
        ),
      );
    });
  }
}

class _NavItem extends StatelessWidget {
  final int index;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.index,
    required this.isActive,
    required this.onTap,
  });

  IconData _getIcon() {
    switch (index) {
      case 0: return Icons.home_rounded;
      case 1: return Icons.calendar_today_rounded;
      case 2: return Icons.library_music_rounded;
      case 3: return Icons.support_agent_rounded;
      case 4: return Icons.person_rounded;
      default: return Icons.circle;
    }
  }

  String _getLabel() {
    switch (index) {
      case 0: return 'Home';
      case 1: return 'Calendar';
      case 2: return 'Media';
      case 3: return 'Contact';
      case 4: return 'Account';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // Better color choices that work in both modes
    final iconColor = isActive
        ? colors.primary               // your accent blue in light & dark
        : colors.onSurface.withOpacity(0.65);   // softer gray/black or light gray

    final labelColor = isActive
        ? colors.primary
        : colors.onSurface.withOpacity(0.80);

    final backgroundColor = isActive
        ? colors.primary.withOpacity(0.12)
        : Colors.transparent;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getIcon(),
                size: 26,
                color: iconColor,
              ),
              const SizedBox(height: 4),
              Text(
                _getLabel(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: labelColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
/*

class _NavItem extends StatelessWidget {
  final int index;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.index,
    required this.isActive,
    required this.onTap,
  });

  IconData _getIcon() {
    switch (index) {
      case 0:
        return Icons.home_rounded;
      case 1:
        return Icons.calendar_today_rounded;
      case 2:
        return Icons.library_music_rounded;
      case 3:
        return Icons.support_agent_rounded;
      case 4:
        return Icons.person_rounded;
      default:
        return Icons.circle;
    }
  }

  String _getLabel() {
    switch (index) {
      case 0:
        return 'Home';
      case 1:
        return 'Calendar';
      case 2:
        return 'Media';
      case 3:
        return 'Contact';
      case 4:
        return 'Account';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? primary.withOpacity(0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getIcon(),
                size: 26,
               color: isActive ? Colors.black : Colors.white,
               // color: isActive ? primary : Colors.white,
              ),
              const SizedBox(height: 4),
              Text(
                _getLabel(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? Colors.black : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}*/
