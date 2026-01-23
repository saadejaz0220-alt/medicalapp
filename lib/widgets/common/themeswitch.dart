// presentation/widgets/common/theme_switch.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/theme_controller.dart';

class ThemeSwitch extends StatelessWidget {
  const ThemeSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();

    return Obx(() {
      final isLight = !themeCtrl.isDark.value;

      return GestureDetector(
        onTap: () => themeCtrl.toggleTheme(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: isLight
                ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                : Colors.grey.shade800.withOpacity(0.3),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isLight ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: isLight
                    ? Theme.of(context).colorScheme.primary
                    : Colors.amber,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isLight ? 'Light' : 'Dark',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isLight
                      ? Theme.of(context).colorScheme.primary
                      : Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}