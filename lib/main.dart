import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Importamos las pantallas de tu proyecto
import 'package:calculori/presentation/screens/home_screen.dart';
import 'package:calculori/presentation/screens/history_screen.dart';
import 'package:calculori/presentation/screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  // We assume it's the first time if the key doesn't exist or is set to true
  final bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

  runApp(
    ProviderScope(
      child: CalculOriApp(isFirstTime: isFirstTime),
    ),
  );
}

class CalculOriApp extends StatelessWidget {
  final bool isFirstTime;
  
  const CalculOriApp({super.key, required this.isFirstTime});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CalculOri',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF7F9FB),
        fontFamily: 'Hanken Grotesk',
      ),
      home: isFirstTime ? const OnboardingScreen() : const MainNavigationPage(),
    );
  }
}

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0; // 0 = Calculadora, 1 = Historial

  // Lista de las pantallas principales asociadas a la barra de abajo
  List<Widget> get _screens => [
    const HomeScreen(),
    HistoryScreen(historial: globalHistorial),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Renderiza dinámicamente la pantalla seleccionada con animación
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: Container(
          key: ValueKey<int>(_selectedIndex),
          child: _screens[_selectedIndex],
        ),
      ),
      
      // La barra de navegación inferior unificada e interactiva de Figma
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(top: 10, bottom: 24, left: 24, right: 24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20), 
            topRight: Radius.circular(20)
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04), 
              blurRadius: 20, 
              offset: const Offset(0, -4)
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Botón Ítem: Calculadora
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = 0;
                });
              },
              child: _buildNavItem(
                icon: Icons.calculate,
                label: 'Calculadora',
                isActive: _selectedIndex == 0,
              ),
            ),
            
            // Botón Ítem: Historial
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = 1;
                });
              },
              child: _buildNavItem(
                icon: Icons.history,
                label: 'Historial',
                isActive: _selectedIndex == 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Generador dinámico para las pestañas (activo / inactivo) estilo Figma
  Widget _buildNavItem({required IconData icon, required String label, required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.symmetric(horizontal: isActive ? 24 : 12, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF27C275) : Colors.transparent,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon, 
            color: isActive ? const Color(0xFF004927) : const Color(0xFF5A665D),
          ),
          const SizedBox(width: 8),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            style: TextStyle(
              color: isActive ? const Color(0xFF004927) : const Color(0xFF5A665D),
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              fontSize: 12,
              fontFamily: 'Hanken Grotesk',
            ),
            child: Text(label),
          ),
        ],
      ),
    );
  }
}