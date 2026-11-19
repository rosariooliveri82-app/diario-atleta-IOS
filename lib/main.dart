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

  static const _azzurroItalia = Color(0xFF0052B4);
  static const _azzurroChiaro = Color(0xFF60A5FA);
  static const _bluNotte = Color(0xFF0A1628);
  static const _bluScuro = Color(0xFF132238);
  static const _oroMedaglia = Color(0xFFD4AF37);
  static const _oroBrillante = Color(0xFFF5C518);

  @override
  Widget build(BuildContext context) {
    final lightScheme = const ColorScheme.light(
      primary: _azzurroItalia,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFDBEAFE),
      onPrimaryContainer: Color(0xFF002B66),
      secondary: _oroMedaglia,
      onSecondary: _bluNotte,
      secondaryContainer: Color(0xFFFEF3C7),
      onSecondaryContainer: Color(0xFF713F12),
      surface: Colors.white,
      onSurface: _bluNotte,
      surfaceContainerHighest: Color(0xFFEFF4FA),
      outlineVariant: Color(0xFFCBD5E1),
    );

    final darkScheme = const ColorScheme.dark(
      primary: _azzurroChiaro,
      onPrimary: _bluNotte,
      primaryContainer: Color(0xFF003B82),
      onPrimaryContainer: Color(0xFFDBEAFE),
      secondary: _oroBrillante,
      onSecondary: _bluNotte,
      secondaryContainer: Color(0xFF422006),
      onSecondaryContainer: Color(0xFFFEF3C7),
      surface: _bluScuro,
      onSurface: Color(0xFFF8FAFC),
      surfaceContainerHighest: Color(0xFF1E3A5F),
      outlineVariant: Color(0xFF2B466B),
    );

    return MaterialApp(
      title: 'Diario Atletica',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightScheme,
        scaffoldBackgroundColor: const Color(0xFFF4F7FB),
        appBarTheme: const AppBarTheme(
          backgroundColor: _azzurroItalia,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: _oroMedaglia,
          foregroundColor: _bluNotte,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          indicatorColor: const Color(0xFFDBEAFE),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: _azzurroItalia);
            }
            return const IconThemeData(color: Color(0xFF64748B));
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                color: _azzurroItalia,
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
        scaffoldBackgroundColor: _bluNotte,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF003B82),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: _oroBrillante,
          foregroundColor: _bluNotte,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: _bluScuro,
          surfaceTintColor: Colors.transparent,
          indicatorColor: const Color(0xFF003B82),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: _oroBrillante);
            }
            return const IconThemeData(color: Color(0xFF94A3B8));
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                color: _oroBrillante,
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
