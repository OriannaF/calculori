import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:calculori/presentation/screens/settings_screen.dart';
import 'package:calculori/presentation/screens/history_screen.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Top-level variable so both the home screen and main tab can access it for now
List<Map<String, dynamic>> globalHistorial = [];
List<Map<String, dynamic>> globalMetodosCobro = [
  { "id": "1", "nombre": "Efectivo", "porcentaje": 0.0, "icono": "billete" },
  { "id": "2", "nombre": "Transferencia", "porcentaje": 10.0, "icono": "transferencia" },
  { "id": "3", "nombre": "Mayorista", "porcentaje": -15.0, "icono": "etiqueta" },
];

IconData getIconFromString(String iconName) {
  switch (iconName) {
    case 'billete': return Icons.money_rounded;
    case 'transferencia': return Icons.swap_horiz_rounded;
    case 'tarjeta': return Icons.credit_card_rounded;
    case 'bolsa': return Icons.shopping_bag_rounded;
    case 'etiqueta': return Icons.local_offer_rounded;
    default: return Icons.money_rounded;
  }
}

String formatCurrency(num value) {
  bool isNegative = value < 0;
  String str = value.abs().toStringAsFixed(0);
  String result = '';
  for (int i = 0; i < str.length; i++) {
    if (i > 0 && (str.length - i) % 3 == 0) {
      result += '.';
    }
    result += str[i];
  }
  return '\$${isNegative ? '-' : ''}$result';
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ---- VALORES INICIALES (ESTADO DE LA APLICACIÓN) ----
  double costoOriginal = 1500.0;
  String nombreProducto = 'Nombre del Producto';
  double multiplicador = 2.0;
  String tipoRedondeo = 'Sin redondeo';

  late TextEditingController _costoController;
  late TextEditingController _nombreController;
  final FocusNode _costoFocusNode = FocusNode();
  final FocusNode _nombreFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _costoController = TextEditingController(text: costoOriginal.toStringAsFixed(0));
    _nombreController = TextEditingController(text: nombreProducto);
    
    _nombreFocusNode.addListener(() {
      if (_nombreFocusNode.hasFocus) {
        _nombreController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _nombreController.text.length,
        );
      } else if (_nombreController.text.trim().isEmpty) {
        _nombreController.text = 'Nombre del Producto';
      }
    });

    _costoFocusNode.addListener(() {
      if (_costoFocusNode.hasFocus) {
        _costoController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _costoController.text.length,
        );
      } else if (_costoController.text.trim().isEmpty) {
        _costoController.text = '0';
        setState(() {
          costoOriginal = 0.0;
        });
      }
    });

    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      multiplicador = prefs.getDouble('multiplicador') ?? 2.0;
      tipoRedondeo = prefs.getString('redondeo') ?? 'Sin redondeo';

      final String? metodosJson = prefs.getString('metodosCobro');
      if (metodosJson != null) {
        final List<dynamic> decoded = jsonDecode(metodosJson);
        globalMetodosCobro = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      }

      final String? historialJson = prefs.getString('historial');
      if (historialJson != null) {
        final List<dynamic> decoded = jsonDecode(historialJson);
        globalHistorial = decoded.map((e) {
          // Convert from JSON to Map<String, dynamic> and restore Colors
          final item = Map<String, dynamic>.from(e);
          item['methodColor'] = Color(item['methodColorValue'] ?? 0xFF3D4A3F);
          item['methodBg'] = Color(item['methodBgValue'] ?? 0xFFE6E8EA);
          item['icon'] = Icons.shopping_bag_outlined;
          return item;
        }).toList();
      }
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('multiplicador', multiplicador);
    await prefs.setString('redondeo', tipoRedondeo);
    await prefs.setString('metodosCobro', jsonEncode(globalMetodosCobro));
  }

  Future<void> _saveHistorial() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> jsonList = globalHistorial.map((item) {
      return {
        'title': item['title'],
        'time': item['time'],
        'price': item['price'],
        'method': item['method'],
        'methodColorValue': (item['methodColor'] as Color).toARGB32(),
        'methodBgValue': (item['methodBg'] as Color).toARGB32(),
        'cashPrice': item['cashPrice'],
        'transferPrice': item['transferPrice'],
        'cardPrice': item['cardPrice'],
      };
    }).toList();
    await prefs.setString('historial', jsonEncode(jsonList));
  }

  @override
  void dispose() {
    _costoController.dispose();
    _nombreController.dispose();
    super.dispose();
  }

  double _applyRounding(double value, String roundingType) {
    if (roundingType == '500') {
      return (value / 500).ceil() * 500.0;
    } else if (roundingType == '1000') {
      return (value / 1000).ceil() * 1000.0;
    } else if (roundingType == 'Cientos') {
      return (value / 100).ceil() * 100.0;
    }
    return value; // 'Sin redondeo'
  }

  @override
  Widget build(BuildContext context) {
    // FÓRMULAS MATEMÁTICAS EN TIEMPO REAL
    double baseMultiplicador = _applyRounding(costoOriginal * multiplicador, tipoRedondeo);
    List<Map<String, dynamic>> metodosCalculados = globalMetodosCobro.map((metodo) {
      double porcentaje = (metodo['porcentaje'] as num).toDouble();
      double total = _applyRounding(baseMultiplicador * (1 + porcentaje / 100), tipoRedondeo);
      return {
        'nombre': metodo['nombre'],
        'porcentaje': porcentaje,
        'total': total,
        'icono': metodo['icono'],
      };
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Gradient recibe el costo y el manejador de la navegación
            HeaderGradientSection(
              costoController: _costoController,
              nombreController: _nombreController,
              costoFocusNode: _costoFocusNode,
              nombreFocusNode: _nombreFocusNode,
              onCostoChanged: (value) {
                setState(() {
                  costoOriginal = double.tryParse(value) ?? 0.0;
                });
              },
              onSettingsPressed: () async {
                // Esperamos a que el usuario configure y toque "Guardar"
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen(
                    initialMultiplier: multiplicador,
                    initialRounding: tipoRedondeo,
                  )),
                );

                // Si volvió trayendo un mapa con nuevos datos, refrescamos la UI
                if (result != null && result is Map) {
                  setState(() {
                    multiplicador = (result['multiplicador'] as num?)?.toDouble() ?? multiplicador;
                    tipoRedondeo = result['redondeo'] as String? ?? tipoRedondeo;
                  });
                  _saveSettings();
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pasamos todos los precios calculados dinámicamente a la tarjeta
                  PaymentMethodsCard(
                    base: baseMultiplicador,
                    metodosCalculados: metodosCalculados,
                    multiplicador: multiplicador,
                    onSave: () {
                      setState(() {
                        globalHistorial.insert(0, {
                          'title': _nombreController.text.isNotEmpty ? _nombreController.text : 'Sin Nombre',
                          'time': 'Ahora',
                          'price': formatCurrency(baseMultiplicador),
                          'method': 'Calculado',
                          'methodColor': const Color(0xFF3D4A3F),
                          'methodBg': const Color(0xFFE6E8EA),
                          'icon': Icons.shopping_bag_outlined,
                          // For compatibility with history, just pass the first three if available
                          'cashPrice': metodosCalculados.isNotEmpty ? formatCurrency(metodosCalculados[0]['total'] as num) : '\$0',
                          'transferPrice': metodosCalculados.length > 1 ? formatCurrency(metodosCalculados[1]['total'] as num) : '\$0',
                          'cardPrice': metodosCalculados.length > 2 ? formatCurrency(metodosCalculados[2]['total'] as num) : '\$0',
                        });
                        _saveHistorial();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Guardado en historial')),
                        );
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  RecentHistoryHeader(
                    historial: globalHistorial, 
                    onReturn: () => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  HistoryList(historial: globalHistorial),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 1. SECCIÓN SUPERIOR: GRADIENTE, ORBES, LOGO Y PRECIO ---
class HeaderGradientSection extends StatelessWidget {
  final TextEditingController costoController;
  final TextEditingController nombreController;
  final FocusNode costoFocusNode;
  final FocusNode nombreFocusNode;
  final void Function(String) onCostoChanged;
  final VoidCallback onSettingsPressed;

  const HeaderGradientSection({
    super.key,
    required this.costoController,
    required this.nombreController,
    required this.costoFocusNode,
    required this.nombreFocusNode,
    required this.onCostoChanged,
    required this.onSettingsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
          // Capa de fondo: Luces ambientales (Orbes de Figma)
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

          // Capa de contenido
          Padding(
            padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 32),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.calculate_rounded, color: Colors.white, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'CalculOri',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.20),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.settings, color: Colors.white, size: 20),
                        onPressed: onSettingsPressed, // Ejecuta la función de navegación reactiva
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.20), width: 1),
                  ),
                  child: TextField(
                    controller: nombreController,
                    focusNode: nombreFocusNode,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white, 
                      fontSize: 16, 
                      fontWeight: FontWeight.w600
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Nombre del Producto',
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.60),
                        fontSize: 16,
                        fontWeight: FontWeight.w600
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        '\$', 
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.80), fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 6),
                    IntrinsicWidth(
                      child: TextField(
                        controller: costoController,
                        focusNode: costoFocusNode,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: onCostoChanged,
                        style: const TextStyle(color: Colors.white, fontSize: 54, fontWeight: FontWeight.bold, letterSpacing: -1),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'COSTO ORIGINAL',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.80), fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- 2. TARJETA CENTRAL: MÉTODOS DE PAGO ---
class PaymentMethodsCard extends StatelessWidget {
  final double base;
  final List<Map<String, dynamic>> metodosCalculados;
  final double multiplicador;
  final VoidCallback onSave;

  const PaymentMethodsCard({
    super.key,
    required this.base,
    required this.metodosCalculados,
    required this.multiplicador,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    String multiplierText = 'x${multiplicador.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '').replaceAll(RegExp(r'0$'), '')}';
    double margenDouble = multiplicador > 0 ? ((multiplicador - 1) / multiplicador) * 100 : 0;
    String margenText = '${margenDouble.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}%';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: const Color(0xFF006D3D).withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFF27C275).withValues(alpha: 0.15),
                    child: const Icon(Icons.trending_up, color: Color(0xFF006D3D), size: 18),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Multiplicador de precio ($multiplierText)', style: const TextStyle(color: Color(0xFF5A665D), fontSize: 12)),
                      Text(
                        formatCurrency(base), // Base multiplicador dinámica
                        style: const TextStyle(color: Color(0xFF191C1E), fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFF0F2F4), borderRadius: BorderRadius.circular(20)),
                child: Text('Margen $margenText', style: const TextStyle(color: Color(0xFF3D4A3F), fontSize: 12, fontWeight: FontWeight.w600)),
              )
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Divider(color: Color(0xFFE0E3E5)),
          ),
          if (metodosCalculados.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 8.0),
              child: Column(
                children: [
                  Icon(Icons.payment_rounded, color: const Color(0xFF5A665D).withValues(alpha: 0.5), size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'No tenes métodos de pago creados.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF191C1E), fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Agregalos en configuración > métodos de cobro > agregar método de cobro y guardalo.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF5A665D), fontSize: 14),
                  ),
                ],
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: metodosCalculados.map((metodo) {
                    String labelStr = '';
                    double porcentaje = (metodo['porcentaje'] as num).toDouble();
                    if (porcentaje > 0) {
                      labelStr = '+${porcentaje.toStringAsFixed(0)}%';
                    } else if (porcentaje < 0) {
                      labelStr = '${porcentaje.toStringAsFixed(0)}%';
                    }
                    
                    Color color = const Color(0xFF191C1E);
                    if (porcentaje > 0) color = const Color(0xFFBA1A1A);
                    if (porcentaje < 0) color = const Color(0xFF006D3D);
                    if (metodo['icono'] == 'transferencia') color = const Color(0xFF4648D4);

                    return Container(
                      width: 110,
                      margin: const EdgeInsets.only(right: 8),
                      child: PaymentMethodItem(
                        title: metodo['nombre'].toString().toUpperCase(), 
                        amount: formatCurrency(metodo['total'] as num), 
                        label: labelStr, 
                        textColor: color, 
                        icon: getIconFromString(metodo['icono']),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF27C275),
                foregroundColor: const Color(0xFF004927),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: onSave,
              icon: const Icon(Icons.save_rounded),
              label: const Text('Guardar en Historial', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }
}

class PaymentMethodItem extends StatelessWidget {
  final String title;
  final String amount;
  final String label;
  final Color textColor;
  final IconData icon;

  const PaymentMethodItem({
    super.key,
    required this.title,
    required this.amount,
    required this.label,
    required this.icon,
    this.textColor = const Color(0xFF191C1E),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E3E5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF5A665D), size: 20),
          const SizedBox(height: 6),
          Text(
            title, 
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF5A665D), fontSize: 10, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(amount, style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold)),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: textColor.withValues(alpha: 0.7), fontSize: 10, fontWeight: FontWeight.w500)),
          ]
        ],
      ),
    );
  }
}

// --- 3. SECCIÓN HISTORIAL RECIENTE ---

class RecentHistoryHeader extends StatelessWidget {
  final List<Map<String, dynamic>> historial;
  final VoidCallback onReturn;
  
  const RecentHistoryHeader({super.key, required this.historial, required this.onReturn});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Historial Reciente', style: TextStyle(color: Color(0xFF191C1E), fontSize: 18, fontWeight: FontWeight.bold)),
        TextButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HistoryScreen(historial: historial),
              ),
            );
            onReturn();
          },
          child: const Text('Ver Todo', style: TextStyle(color: Color(0xFF006D3D), fontWeight: FontWeight.bold)),
        )
      ],
    );
  }
}

class HistoryList extends StatelessWidget {
  final List<Map<String, dynamic>> historial;

  const HistoryList({super.key, required this.historial});

  @override
  Widget build(BuildContext context) {
    if (historial.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: const Color(0xFF006D3D).withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: historial.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Column(
            children: [
              HistoryTile(
                title: item['title'],
                time: item['time'],
                price: item['price'],
                method: item['method'],
                methodColor: item['methodColor'],
                methodBg: item['methodBg'],
                icon: item['icon'],
              ),
              if (index < historial.length - 1)
                const Divider(height: 1, color: Color(0xFFECEEF0), indent: 16, endIndent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class HistoryTile extends StatelessWidget {
  final String title;
  final String time;
  final String price;
  final String method;
  final Color methodColor;
  final Color methodBg;
  final IconData icon;

  const HistoryTile({
    super.key,
    required this.title,
    required this.time,
    required this.price,
    required this.method,
    required this.methodColor,
    required this.methodBg,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFECEEF0),
            child: Icon(icon, color: const Color(0xFF5A665D)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Color(0xFF191C1E), fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(time, style: const TextStyle(color: Color(0xFF5A665D), fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price, style: const TextStyle(color: Color(0xFF191C1E), fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: methodBg, borderRadius: BorderRadius.circular(4)),
                child: Text(method, style: TextStyle(color: methodColor, fontSize: 10, fontWeight: FontWeight.w600)),
              )
            ],
          )
        ],
      ),
    );
  }
}
