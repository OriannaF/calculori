import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_screen.dart';
import 'package:calculori/presentation/screens/home_screen.dart';


class HistoryScreen extends StatefulWidget {
  final List<Map<String, dynamic>> historial;

  const HistoryScreen({super.key, required this.historial});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _searchQuery = '';
  late List<Map<String, dynamic>> _currentHistorial;

  @override
  void initState() {
    super.initState();
    _currentHistorial = List.from(widget.historial);
  }

  @override
  Widget build(BuildContext context) {
    final filteredHistorial = _currentHistorial.where((item) {
      final title = (item['title'] ?? '').toString().toLowerCase();
      return title.contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const HistoryHeaderSection(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: Column(
                children: [
                  SearchAndFilterSection(
                    onSearchChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  // Lista de tarjetas detalladas del historial
                  if (filteredHistorial.isEmpty)
                    const Text('No hay historial todavía', style: TextStyle(color: Colors.grey))
                  else
                    ...filteredHistorial.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: DetailedHistoryCard(
                          title: item['title'] ?? 'Sin Nombre',
                          time: item['time'] ?? '',
                          cashPrice: item['cashPrice'] ?? '',
                          transferPrice: item['transferPrice'] ?? '',
                          cardPrice: item['cardPrice'] ?? '',
                          iconBg: item['methodBg'] ?? const Color(0xFFE1E0FF),
                          onDelete: () {
                            setState(() {
                              _currentHistorial.remove(item);
                            });
                          },
                        ),
                      );
                    }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- HEADER DEL HISTORIAL ---
class HistoryHeaderSection extends StatelessWidget {
  const HistoryHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 36),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF006D3D), Color(0xFF4FDF8F)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Luces decorativas (Orbes ambientales)
          Positioned(
            left: -40,
            top: -50,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50, tileMode: TileMode.decal),
              child: Container(
                width: 234,
                height: 150,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF6FFDA9).withValues(alpha: 0.5),
                      const Color(0xFF4FDF8F).withValues(alpha: 0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Positioned(
            right: -50,
            top: 20,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50, tileMode: TileMode.decal),
              child: Container(
                width: 273,
                height: 174,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      const Color(0xFFE1E0FF).withValues(alpha: 0.3),
                      const Color(0xFFE1E0FF).withValues(alpha: 0.05),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          // Contenido del Header
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.calculate_rounded, color: Colors.white, size: 24),
                      SizedBox(width: 8),
                      Text('CalculOri', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.20), 
                      shape: BoxShape.circle
                    ),
                      child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.settings, color: Colors.white, size: 20),
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        final double multiplicador = prefs.getDouble('multiplicador') ?? 2.0;
                        final String tipoRedondeo = prefs.getString('redondeo') ?? 'Sin redondeo';

                        List<Map<String, dynamic>> metodos = [];
                        final String? metodosJson = prefs.getString('metodosCobro');
                        if (metodosJson != null) {
                          metodos = (jsonDecode(metodosJson) as List)
                              .map((e) => Map<String, dynamic>.from(e))
                              .toList();
                        }

                        if (!context.mounted) return;

                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SettingsScreen(
                              initialMultiplier: multiplicador,
                              initialRounding: tipoRedondeo,
                              initialPaymentMethods: metodos,
                            ),
                          ),
                        );

                        if (result != null && result is Map) {
                          await prefs.setDouble('multiplicador', (result['multiplicador'] as num?)?.toDouble() ?? multiplicador);
                          await prefs.setString('redondeo', result['redondeo'] as String? ?? tipoRedondeo);
                          if (result.containsKey('metodosCobro')) {
                            final newMethods = List<Map<String, dynamic>>.from(result['metodosCobro']);
                            await prefs.setString('metodosCobro', jsonEncode(newMethods));
                            globalMetodosCobro = newMethods;
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Historial',
                style: TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.bold, letterSpacing: -1),
              ),
              const SizedBox(height: 4),
              Text(
                'Tus cálculos recientes',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- BUSCADOR Y FILTROS PILARES ---
class SearchAndFilterSection extends StatelessWidget {
  final ValueChanged<String> onSearchChanged;

  const SearchAndFilterSection({super.key, required this.onSearchChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 4)),
        ],
      ),
      // Input de búsqueda funcional
      child: TextField(
        onChanged: onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Buscar producto...',
          hintStyle: const TextStyle(color: Color(0xFF6D7B6F)),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF6D7B6F)),
          filled: true,
          fillColor: const Color(0xFFF7F9FB),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

// --- TARJETA DE DETALLE POR PRODUCTO ---
class DetailedHistoryCard extends StatelessWidget {
  final String title;
  final String time;
  final String cashPrice;
  final String transferPrice;
  final String cardPrice;
  final Color iconBg;
  final VoidCallback onDelete;

  const DetailedHistoryCard({
    super.key,
    required this.title,
    required this.time,
    required this.cashPrice,
    required this.transferPrice,
    required this.cardPrice,
    required this.iconBg,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE0E3E5).withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        children: [
          // Fila superior: Título e ícono de bolsa
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: iconBg,
                    child: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF3D4A3F)),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(color: Color(0xFF191C1E), fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(time, style: const TextStyle(color: Color(0xFF6D7B6F), fontSize: 12)),
                    ],
                  ),
                ],
              ),
              IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFFBA1A1A), size: 22),
            onPressed: onDelete,
              )
            ],
          ),
          const SizedBox(height: 16),
          // Grilla de Precios de los tres métodos organizados en fila horizontal
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF7F9FB), borderRadius: BorderRadius.circular(16)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPriceColumn('Efectivo', cashPrice, const Color(0xFF006D3D)),
                _buildDivider(),
                _buildPriceColumn('Transfer', transferPrice, const Color(0xFF4648D4)),
                _buildDivider(),
                _buildPriceColumn('Tarjeta', cardPrice, const Color(0xFFBA1A1A)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPriceColumn(String label, String value, Color priceColor) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF6D7B6F), fontSize: 11, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: priceColor, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 28, color: const Color(0xFFE0E3E5));
  }
}