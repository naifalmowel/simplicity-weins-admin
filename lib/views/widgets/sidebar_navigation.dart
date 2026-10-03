import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import 'confirm_dialog.dart';

class SidebarNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int index) onItemSelected;
  final bool isMobile;

  const SidebarNavigation({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.ink,
        border: Border(
          left: BorderSide(color: AppColors.lines, width: 0.5),
        ),
      ),
      child: Column(
        children: [
          // Brand Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            alignment: Alignment.centerRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  AppConstants.storeNameEn,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Text(
                      AppConstants.storeNameAr,
                      style: TextStyle(
                        color: AppColors.bronze,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.olive.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'ADMIN',
                        style: TextStyle(
                          color: AppColors.paper,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  AppConstants.sloganEn,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 9,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: Color(0xFF2E2E2A), height: 1),
          const SizedBox(height: 16),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildNavItem(
                  context,
                  index: 0,
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard,
                  title: 'لوحة التحكم Analytics',
                ),
                _buildNavItem(
                  context,
                  index: 1,
                  icon: Icons.checkroom_outlined,
                  activeIcon: Icons.checkroom,
                  title: 'المنتجات Products',
                ),
                _buildNavItem(
                  context,
                  index: 2,
                  icon: Icons.category_outlined,
                  activeIcon: Icons.category,
                  title: 'التصنيفات Categories',
                ),
                _buildNavItem(
                  context,
                  index: 3,
                  icon: Icons.local_offer_outlined,
                  activeIcon: Icons.local_offer,
                  title: 'العروض والبقشيش Offers',
                ),
                _buildNavItem(
                  context,
                  index: 4,
                  icon: Icons.store_outlined,
                  activeIcon: Icons.store,
                  title: 'إعدادات المتجر Settings',
                ),
              ],
            ),
          ),

          // Footer / User & Logout
          const Divider(color: Color(0xFF2E2E2A), height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                ConfirmDialog.show(
                  context,
                  title: 'تسجيل الخروج',
                  message: 'هل أنت تأكد من أنك تريد تسجيل الخروج من لوحة الإدارة؟',
                  confirmText: 'خروج',
                  cancelText: 'إلغاء',
                  onConfirm: () {
                    Provider.of<AuthProvider>(context, listen: false).logout();
                  },
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF222220),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF333330)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.logout, color: AppColors.danger, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'تسجيل الخروج',
                        style: TextStyle(
                          color: AppColors.paper,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String title,
  }) {
    final isSelected = selectedIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            onItemSelected(index);
            if (isMobile) {
              Navigator.pop(context);
            }
          },
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.bronze : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected ? AppColors.white : AppColors.textMuted,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? AppColors.white : AppColors.paper.withValues(alpha: 0.8),
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
