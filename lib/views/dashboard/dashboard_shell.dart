import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/sidebar_navigation.dart';
import 'overview_screen.dart';
import '../products/products_screen.dart';
import '../categories/categories_screen.dart';
import '../offers/offers_screen.dart';
import '../settings/settings_screen.dart';

class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  int _selectedIndex = 0;

  final List<String> _titles = [
    'الرئيسية',
    'المنتجات',
    'التصنيفات',
    'العروض',
    'الإعدادات',
  ];

  void _onNavigate(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return OverviewScreen(onNavigateToTab: _onNavigate);
      case 1:
        return const ProductsScreen();
      case 2:
        return const CategoriesScreen();
      case 3:
        return const OffersScreen();
      case 4:
        return const SettingsScreen();
      default:
        return OverviewScreen(onNavigateToTab: _onNavigate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isDesktop = mediaQuery.size.width >= 900;

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: isDesktop ? 24 : 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(color: AppColors.lines, height: 1),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                _titles[_selectedIndex],
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.ink,
                child: const Text(
                  'A',
                  style: TextStyle(
                    color: AppColors.bronze,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      drawer: isDesktop
          ? null
          : Drawer(
              child: SidebarNavigation(
                selectedIndex: _selectedIndex,
                onItemSelected: _onNavigate,
                isMobile: true,
              ),
            ),
      body: Row(
        children: [
          if (isDesktop)
            SidebarNavigation(
              selectedIndex: _selectedIndex,
              onItemSelected: _onNavigate,
            ),
          Expanded(
            child: SelectionArea(
              child: _buildBody(),
            ),
          ),
        ],
      ),
    );
  }
}
