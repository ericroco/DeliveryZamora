import 'package:flutter/material.dart';
import 'package:mobile_customer/core/constants/app_colors.dart';

class CategoryPill extends StatelessWidget {
  const CategoryPill({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.isCasero,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final bool isCasero;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = isCasero ? AppColors.caseroBg : AppColors.pillBg;
    final textColor = isCasero ? AppColors.caseroText : AppColors.pillText;
    final borderColor = isCasero ? AppColors.caseroBorder : AppColors.pillBorder;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? (isCasero ? AppColors.primary : AppColors.accent) : bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? Colors.transparent : borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : textColor,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : textColor,
              ),
            ),
            if (isCasero) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white24 : AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'ESPECIAL',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: isSelected ? Colors.white : Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
