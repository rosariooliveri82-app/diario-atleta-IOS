import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens_athletes.dart';
import 'screens_club.dart';
import 'screens_data.dart';
import 'screens_results.dart';
import 'screens_training.dart';
import 'store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await store.load();
  runApp(const DiarioApp());
}

class DiarioApp extends StatelessWidget {
  const DiarioApp({super.key});

  static const _trackOrange = Color(0xFFEA580C);
  static const _trackOrangeBright = Color(0xFFFF6D3F);
  static const _stadiumNavy = Color(0xFF0F172A);
  static const _slateDark = Color(0xFF1E293B);

  @override
  Widget build(BuildContext context) {
    final lightScheme = const ColorScheme.light(
      primary: _trackOrange,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFFFEDD5),
      onPrimaryContainer: Color(0xFF7C2D12),
      secondary: _stadiumNavy,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFE2E8F0),
      onSecondaryContainer: _stadiumNavy,
      surface: Colors.white,
      onSurface: _stadiumNavy,
      surfaceContainerHighest: Color(0xFFF1F5F9),
      outlineVariant: Color(0xFFE2E8F0),
    );

    final darkScheme = const ColorScheme.dark(
      primary: _trackOrangeBright,
      onPrimary: Color(0xFF0F172A),
      primaryContainer: Color(0xFF7C2D12),
      onPrimaryContainer: Color(0xFFFFEDD5),
      secondary: Color(0xFF38BDF8),
      onSecondary: _stadiumNavy,
      secondaryContainer: _slateDark,
      onSecondaryContainer: Color(0xFFE2E8F0),
      surface: _slateDark,
      onSurface: Color(0xFFF8FAFC),
      surfaceContainerHighest: Color(0xFF334155),
      outlineVariant: Color(0xFF334155),
    );

    return MaterialApp(
      title: 'Diario Atletica',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightScheme,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        appBarTheme: const AppBarTheme(
          backgroundColor: _stadiumNavy,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: _trackOrange,
          foregroundColor: Colors.white,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          indicatorColor: const Color(0xFFFFEDD5),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: _trackOrange);
            }
            return const IconThemeData(color: Color(0xFF64748B));
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                color: _trackOrange,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              );
            }
            return const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
            );
          }),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: darkScheme,
        scaffoldBackgroundColor: const Color(0xFF0B1120),
        appBarTheme: const AppBarTheme(
          backgroundColor: _stadiumNavy,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: _trackOrangeBright,
          foregroundColor: _stadiumNavy,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: _stadiumNavy,
          surfaceTintColor: Colors.transparent,
          indicatorColor: const Color(0xFF7C2D12),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: _trackOrangeBright);
            }
            return const IconThemeData(color: Color(0xFF94A3B8));
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                color: _trackOrangeBright,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              );
            }
            return const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 12,
            );
          }),
        ),
      ),
      locale: const Locale('it'),
      supportedLocales: const [Locale('it')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;

  static const pages = <Widget>[
    AthletesScreen(),
    ResultsScreen(),
    TrainingScreen(),
    ClubScreen(),
    DataScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Atleti',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events),
            label: 'Gare',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center),
            label: 'Allenam.',
          ),
          NavigationDestination(
            icon: Icon(Icons.flag_outlined),
            selectedIcon: Icon(Icons.flag),
            label: 'Società',
          ),
          NavigationDestination(
            icon: Icon(Icons.swap_horiz),
            label: 'Dati',
          ),
        ],
      ),
    );
  }
}
