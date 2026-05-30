import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:calculori/presentation/screens/settings_screen.dart';
import 'package:calculori/presentation/screens/history_screen.dart';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screenshot/screenshot.dart';
import 'package:calculori/presentation/providers/calculator_provider.dart';
import 'package:calculori/presentation/widgets/share_button.dart';
import 'package:calculori/core/utils/price_calculator.dart';
import 'package:image_picker/image_picker.dart';

// Top-level variable so both the home screen and main tab can access it for now
List<Map<String, dynamic>> globalHistorial = [];
List<Map<String, dynamic>> globalMetodosCobro = [
  { "id": "1", "nombre": "Efectivo", "porcentaje": 0.0, "icono": "billete" },
  { "id": "2", "nombre": "Transferencia", "porcentaje": 10.0, "icono": "transferencia" },
  { "id": "3", "nombre": "Mayorista", "porcentaje": -15.0, "icono": "etiqueta" },
];

String globalCurrency = 'ARS';
String globalNumberFormat = 'arg';

Map<String, String> _currencySymbols = {
  'ARS': '\$', 'USD': 'USD', 'BRL': 'R\$', 'CLP': '\$',
  'MXN': '\$', 'COP': '\$', 'EUR': '€',
};

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
  String separator = globalNumberFormat == 'us' ? ',' : '.';
  String result = '';
  for (int i = 0; i < str.length; i++) {
    if (i > 0 && (str.length - i) % 3 == 0) {
      result += separator;
    }
    result += str[i];
  }
  String symbol = _currencySymbols[globalCurrency] ?? '\$';
  if (globalCurrency == 'USD') {
    return '${isNegative ? '-' : ''}USD $result';
  }
  return '${isNegative ? '-' : ''}$symbol$result';
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String storeName = '';
  String profileImagePath = '';
  late TextEditingController _costoController;
  late TextEditingController _nombreController;
  final FocusNode _costoFocusNode = FocusNode();
  final FocusNode _nombreFocusNode = FocusNode();
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with Riverpod default state
    final initialState = ref.read(calculatorProvider);
    _costoController = TextEditingController(text: initialState.cost.toStringAsFixed(0));
    _nombreController = TextEditingController(text: initialState.productName.isEmpty ? 'Nombre del Producto' : initialState.productName);
    
    _nombreFocusNode.addListener(() {
      if (_nombreFocusNode.hasFocus) {
        _nombreController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _nombreController.text.length,
        );
      } else if (_nombreController.text.trim().isEmpty) {
        _nombreController.text = 'Nombre del Producto';
        ref.read(calculatorProvider.notifier).updateProductName('');
      } else {
        ref.read(calculatorProvider.notifier).updateProductName(_nombreController.text);
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
        ref.read(calculatorProvider.notifier).updateCost(0.0);
      }
    });

    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    String savedStoreName = prefs.getString('storeName') ?? '';
    String savedProfileImage = prefs.getString('profileImagePath') ?? '';
    double savedMultiplier = prefs.getDouble('multiplicador') ?? 2.0;
    String savedRounding = prefs.getString('redondeo') ?? 'Sin redondeo';
    String savedLogicType = prefs.getString('calcMethod') ?? 'multiplicador';
    List<Map<String, dynamic>> savedMethods = List.from(globalMetodosCobro);

    final String? metodosJson = prefs.getString('metodosCobro');
    if (metodosJson != null) {
      final List<dynamic> decoded = jsonDecode(metodosJson);
      savedMethods = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      globalMetodosCobro = savedMethods;
    }

    final String? historialJson = prefs.getString('historial');
    if (historialJson != null) {
      final List<dynamic> decoded = jsonDecode(historialJson);
      setState(() {
        globalHistorial = decoded.map((e) {
          final item = Map<String, dynamic>.from(e);
          item['methodColor'] = Color(item['methodColorValue'] ?? 0xFF3D4A3F);
          item['methodBg'] = Color(item['methodBgValue'] ?? 0xFFE6E8EA);
          item['icon'] = Icons.shopping_bag_outlined;
          return item;
        }).toList();
      });
    }

    String savedCurrency = prefs.getString('currency') ?? 'ARS';
    String savedFormat = prefs.getString('numberFormat') ?? 'arg';
    String savedExampleProduct = prefs.getString('exampleProduct') ?? 'Remera';
    String savedExampleCost = prefs.getString('exampleCost') ?? '5000';

    globalCurrency = savedCurrency;
    globalNumberFormat = savedFormat;

    double costValue = double.tryParse(savedExampleCost) ?? 1500.0;
    _costoController.text = costValue.toStringAsFixed(0);
    _nombreController.text = savedExampleProduct;

    setState(() {
      storeName = savedStoreName;
      profileImagePath = savedProfileImage;
    });

    // Sync loaded settings to Riverpod state
    ref.read(calculatorProvider.notifier).updateSettings(savedMultiplier, savedRounding, savedLogicType, savedMethods);
    ref.read(calculatorProvider.notifier).updateCost(costValue);
    ref.read(calculatorProvider.notifier).updateProductName(savedExampleProduct);
  }

  Future<void> _saveSettings(double multiplicador, String tipoRedondeo, String logicType, List<Map<String, dynamic>> metodos) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('multiplicador', multiplicador);
    await prefs.setString('redondeo', tipoRedondeo);
    await prefs.setString('calcMethod', logicType);
    await prefs.setString('metodosCobro', jsonEncode(metodos));
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profileImagePath', image.path);
      setState(() {
        profileImagePath = image.path;
      });
    }
  }

  Future<void> _removeImage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('profileImagePath');
    setState(() {
      profileImagePath = '';
    });
  }

  Future<void> _saveStoreName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('storeName', name);
    setState(() {
      storeName = name;
    });
  }

  void _showEditProfileSheet() {
    final nameController = TextEditingController(text: storeName);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Editar perfil',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF191C1E)),
              ),
              const SizedBox(height: 24),
              const Text('Nombre del local', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF3D4A3F))),
              const SizedBox(height: 8),
              TextField(
                controller: nameController,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: 'Ej. Mi Tiendita',
                  filled: true,
                  fillColor: const Color(0xFFF2F4F6),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF27C275), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF006D3D),
                    side: const BorderSide(color: Color(0xFF27C275)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    _pickImage();
                    Navigator.pop(ctx);
                  },
                  icon: const Icon(Icons.camera_alt_rounded),
                  label: const Text('Cambiar foto', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              if (profileImagePath.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      _removeImage();
                      Navigator.pop(ctx);
                    },
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: const Text('Eliminar foto', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF27C275),
                    foregroundColor: const Color(0xFF004927),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    _saveStoreName(nameController.text.trim());
                    Navigator.pop(ctx);
                  },
                  child: const Text('Guardar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _costoController.dispose();
    _nombreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the Riverpod state
    final calcState = ref.watch(calculatorProvider);
    final baseMultiplicador = calcState.basePrice;
    
    List<Map<String, dynamic>> metodosCalculados = calcState.paymentMethods.map((metodo) {
      double porcentaje = (metodo['porcentaje'] as num).toDouble();
      // Price calculation logic uses the utils now
      double total = PriceCalculator.calculateMethodPrice(baseMultiplicador, porcentaje, calcState.roundingType);
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
            HeaderGradientSection(
              storeName: storeName,
              profileImagePath: profileImagePath,
              costoController: _costoController,
              nombreController: _nombreController,
              costoFocusNode: _costoFocusNode,
              nombreFocusNode: _nombreFocusNode,
              onCostoChanged: (value) {
                ref.read(calculatorProvider.notifier).updateCost(double.tryParse(value) ?? 0.0);
              },
              onProfileTap: _showEditProfileSheet,
              onSettingsPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen(
                    initialMultiplier: calcState.multiplier,
                    initialRounding: calcState.roundingType,
                    initialPaymentMethods: calcState.paymentMethods,
                  )),
                );

                if (result != null && result is Map) {
                  final newMult = (result['multiplicador'] as num?)?.toDouble() ?? calcState.multiplier;
                  final newRound = result['redondeo'] as String? ?? calcState.roundingType;
                  final newLogic = result['logicType'] as String? ?? calcState.logicType;
                  List<Map<String, dynamic>> newMethods = calcState.paymentMethods;
                  if (result.containsKey('metodosCobro')) {
                    newMethods = List<Map<String, dynamic>>.from(result['metodosCobro']);
                    globalMetodosCobro = newMethods; // Keep global in sync temporarily
                  }
                  
                  ref.read(calculatorProvider.notifier).updateSettings(newMult, newRound, newLogic, newMethods);
                  _saveSettings(newMult, newRound, newLogic, newMethods);
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Wrap the card in Screenshot widget
                  Screenshot(
                    controller: _screenshotController,
                    child: PaymentMethodsCard(
                      base: baseMultiplicador,
                      metodosCalculados: metodosCalculados,
                      multiplicador: calcState.multiplier,
                      logicType: calcState.logicType,
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
                  ),
                  const SizedBox(height: 16),
                  
                  // Share Button Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ShareResultButton(
                        screenshotController: _screenshotController,
                        productName: _nombreController.text.isNotEmpty ? _nombreController.text : 'Mi Producto',
                        basePrice: baseMultiplicador,
                      ),
                    ],
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
  final String storeName;
  final String profileImagePath;
  final TextEditingController costoController;
  final TextEditingController nombreController;
  final FocusNode costoFocusNode;
  final FocusNode nombreFocusNode;
  final void Function(String) onCostoChanged;
  final VoidCallback onProfileTap;
  final VoidCallback onSettingsPressed;

  const HeaderGradientSection({
    super.key,
    required this.storeName,
    required this.profileImagePath,
    required this.costoController,
    required this.nombreController,
    required this.costoFocusNode,
    required this.nombreFocusNode,
    required this.onCostoChanged,
    required this.onProfileTap,
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
                    GestureDetector(
                      onTap: onProfileTap,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.white.withValues(alpha: 0.20),
                            backgroundImage: profileImagePath.isNotEmpty
                                ? FileImage(File(profileImagePath))
                                : null,
                            child: profileImagePath.isEmpty
                                ? const Icon(Icons.person, color: Colors.white, size: 22)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Hola,',
                                style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                              Text(
                                storeName.isNotEmpty ? storeName : 'Mi Negocio',
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
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
                        onPressed: onSettingsPressed,
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
  final String logicType;
  final VoidCallback onSave;

  const PaymentMethodsCard({
    super.key,
    required this.base,
    required this.metodosCalculados,
    required this.multiplicador,
    required this.logicType,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    String label;
    if (logicType == 'margen') {
      double margenDouble = multiplicador > 0 ? ((multiplicador - 1) / multiplicador) * 100 : 0;
      String margenText = '${margenDouble.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}%';
      label = 'Margen ($margenText)';
    } else {
      String multiplierText = 'x${multiplicador.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '').replaceAll(RegExp(r'0$'), '')}';
      label = 'Multiplicador de precio ($multiplierText)';
    }

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
                  Text(label, style: const TextStyle(color: Color(0xFF5A665D), fontSize: 12)),
                  Text(
                    formatCurrency(base),
                    style: const TextStyle(color: Color(0xFF191C1E), fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
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
