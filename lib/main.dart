import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants/app_constants.dart';
import 'core/constants/supabase_config.dart';
import 'core/theme/app_theme.dart';

import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/storage_service.dart';

import 'providers/auth_provider.dart';
import 'providers/products_provider.dart';
import 'providers/categories_provider.dart';
import 'providers/offers_provider.dart';
import 'providers/settings_provider.dart';

import 'views/auth/login_screen.dart';
import 'views/dashboard/dashboard_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = true;

  // Safe Firebase Initialization
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDTiaEJKBs42uijM5f7Mfw58RKJXs1guZY",
        authDomain: "simplicity-wins-76c7a.firebaseapp.com",
        projectId: "simplicity-wins-76c7a",
        storageBucket: "simplicity-wins-76c7a.firebasestorage.app",
        messagingSenderId: "810221326447",
        appId: "1:810221326447:web:7c2b5f99f0e6aa7c443d9a",
        measurementId: "G-HRZZFZ1NYQ",
      ),
    );
  } catch (e) {
    debugPrint("Firebase initialization note: $e");
  }

  // Safe Supabase Initialization
  try {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.publish,
    );
  } catch (e) {
    debugPrint("Supabase initialization note: $e");
  }

  runApp(const SimplicityAdminApp());
}

class SimplicityAdminApp extends StatelessWidget {
  const SimplicityAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Services
    final authService = AuthService();
    final firestoreService = FirestoreService();
    final storageService = StorageService();

    return MultiProvider(
      providers: [
        Provider<AuthService>.value(value: authService),
        Provider<FirestoreService>.value(value: firestoreService),
        Provider<StorageService>.value(value: storageService),

        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(authService),
        ),
        ChangeNotifierProvider<ProductsProvider>(
          create: (_) => ProductsProvider(firestoreService, storageService),
        ),
        ChangeNotifierProvider<CategoriesProvider>(
          create: (_) => CategoriesProvider(firestoreService, storageService),
        ),
        ChangeNotifierProvider<OffersProvider>(
          create: (_) => OffersProvider(firestoreService, storageService),
        ),
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => SettingsProvider(firestoreService),
        ),
      ],
      child: MaterialApp(
        title: '${AppConstants.storeNameEn} - Admin Dashboard',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        locale: const Locale('ar', 'SY'),
        supportedLocales: const [Locale('ar', 'SY'), Locale('en', 'US')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Consumer<AuthProvider>(
          builder: (context, auth, child) {
            if (auth.isAuthenticated) {
              return const DashboardShell();
            }
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
