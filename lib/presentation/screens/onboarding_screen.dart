import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:calculori/main.dart'; // To navigate to MainNavigationPage

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // State Step 1
  final TextEditingController _storeNameController = TextEditingController();

  // State Step 2
  String _calcMethod = 'multiplicador'; // 'margen' or 'multiplicador'
  final TextEditingController _marginController = TextEditingController(text: '200');
  final TextEditingController _multiplierController = TextEditingController(text: '3');
  String _selectedRounding = 'Sin redondeo';

  // State Step 3
  bool _useCash = true;
  final TextEditingController _cashPercentController = TextEditingController(text: '0');
  
  bool _useTransfer = true;
  final TextEditingController _transferPercentController = TextEditingController(text: '10');
  
  bool _useCard = true;
  final TextEditingController _cardPercentController = TextEditingController(text: '35');

  @override
  void dispose() {
    _pageController.dispose();
    _storeNameController.dispose();
    _marginController.dispose();
    _multiplierController.dispose();
    _cashPercentController.dispose();
    _transferPercentController.dispose();
    _cardPercentController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _finishOnboarding();
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  Future<void> _finishOnboarding() async {
    // Determine the actual multiplier to save based on the selected method
    double finalMultiplier = 3.0;
    if (_calcMethod == 'multiplicador') {
      finalMultiplier = double.tryParse(_multiplierController.text.replaceAll(',', '.')) ?? 3.0;
    } else {
      double margin = double.tryParse(_marginController.text.replaceAll(',', '.')) ?? 200.0;
      finalMultiplier = 1 + (margin / 100);
    }

    // Collect initial methods
    List<Map<String, dynamic>> initialMethods = [];
    if (_useCash) {
      initialMethods.add({
        "id": "${DateTime.now().millisecondsSinceEpoch}_1",
        "nombre": "Efectivo",
        "porcentaje": double.tryParse(_cashPercentController.text) ?? 0.0,
        "icono": "billete"
      });
    }
    if (_useTransfer) {
      initialMethods.add({
        "id": "${DateTime.now().millisecondsSinceEpoch}_2",
        "nombre": "Transferencia",
        "porcentaje": double.tryParse(_transferPercentController.text) ?? 10.0,
        "icono": "transferencia"
      });
    }
    if (_useCard) {
      initialMethods.add({
        "id": "${DateTime.now().millisecondsSinceEpoch}_3",
        "nombre": "Tarjeta",
        "porcentaje": double.tryParse(_cardPercentController.text) ?? 35.0,
        "icono": "tarjeta"
      });
    }

    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);
    await prefs.setString('storeName', _storeNameController.text.trim());
    await prefs.setDouble('multiplicador', finalMultiplier);
    await prefs.setString('redondeo', _selectedRounding);
    await prefs.setString('metodosCobro', jsonEncode(initialMethods));

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigationPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFDAE2FD).withValues(alpha: 0.5),
              const Color(0xFF27C275).withValues(alpha: 0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(16),
              constraints: const BoxConstraints(maxWidth: 450, maxHeight: 800),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFBCCABC).withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  // HEADER / PROGRESS
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Color(0xFFECEEF0))),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Paso ${_currentPage + 1} de 3', style: const TextStyle(color: Color(0xFF5A665D), fontWeight: FontWeight.w600)),
                        Row(
                          children: [
                            _buildProgressDot(0),
                            const SizedBox(width: 8),
                            _buildProgressDot(1),
                            const SizedBox(width: 8),
                            _buildProgressDot(2),
                          ],
                        )
                      ],
                    ),
                  ),

                  // MAIN CONTENT CANVAS (PageView)
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (idx) => setState(() => _currentPage = idx),
                      children: [
                        _buildStep1(),
                        _buildStep2(),
                        _buildStep3(),
                      ],
                    ),
                  ),

                  // FOOTER ACTIONS
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: Color(0xFFECEEF0))),
                    ),
                    child: Row(
                      children: [
                        if (_currentPage > 0) ...[
                          Expanded(
                            flex: 1,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: const Color(0xFFF2F4F6),
                                foregroundColor: const Color(0xFF191C1E),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                              ),
                              onPressed: _prevPage,
                              child: const Text('Atrás', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF27C275),
                              foregroundColor: const Color(0xFF004927),
                              elevation: 4,
                              shadowColor: const Color(0xFF27C275).withValues(alpha: 0.4),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                            ),
                            onPressed: _nextPage,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(_currentPage == 2 ? 'Finalizar' : 'Siguiente', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                if (_currentPage == 2) ...[
                                  const SizedBox(width: 8),
                                  const Icon(Icons.check_circle_outline, size: 20),
                                ]
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 8,
      width: 32,
      decoration: BoxDecoration(
        color: _currentPage >= index ? const Color(0xFF006D3D) : const Color(0xFFE0E3E5),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  // --- STEPS ---

  Widget _buildStep1() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('¡Hola!', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF191C1E), letterSpacing: -0.5)),
          const SizedBox(height: 8),
          const Text('¿Cómo se llama tu local o emprendimiento?', style: TextStyle(fontSize: 16, color: Color(0xFF3D4A3F))),
          const SizedBox(height: 32),
          TextField(
            controller: _storeNameController,
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
        ],
      ),
    );
  }

  Widget _buildStep2() {
    double mult = 0.0;
    if (_calcMethod == 'multiplicador') {
      mult = double.tryParse(_multiplierController.text.replaceAll(',', '.')) ?? 0.0;
    } else {
      double margin = double.tryParse(_marginController.text.replaceAll(',', '.')) ?? 0.0;
      mult = 1 + (margin / 100);
    }
    double examplePrice = 10000 * mult;
    
    double roundedExample = _selectedRounding == '500' ? (45560.78 / 500).ceil() * 500.0 :
                            _selectedRounding == '1000' ? (45560.78 / 1000).ceil() * 1000.0 :
                            _selectedRounding == '100' ? (45560.78 / 100).ceil() * 100.0 :
                            45560.78;

    String formatVal(double v) => v.toStringAsFixed(v.truncateToDouble() == v ? 0 : 2);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('¿Cómo solés calcular tus precios?', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF191C1E), letterSpacing: -0.5, height: 1.1)),
          const SizedBox(height: 8),
          const Text('Elegí la lógica base que usás para marcar tus productos.', style: TextStyle(fontSize: 15, color: Color(0xFF3D4A3F))),
          const SizedBox(height: 32),
          
          // Card Margen
          _buildCalcCard(
            id: 'margen',
            title: 'Por Margen (%)',
            supportText: 'Le sumo un porcentaje de ganancia al costo.',
            exampleText: '(Ej: Mi costo + 200%)',
            inputLabel: 'Margen de ganancia',
            prefixOrSuffix: '%',
            isPrefix: false,
            controller: _marginController,
            examplePrice: examplePrice,
            formatVal: formatVal,
          ),
          const SizedBox(height: 12),
          
          // Card Multiplicador
          _buildCalcCard(
            id: 'multiplicador',
            title: 'Por Multiplicador (x)',
            supportText: 'Multiplico el costo por un número fijo.',
            exampleText: '(Ej: Mi costo x 3)',
            inputLabel: 'Multiplicador',
            prefixOrSuffix: 'x',
            isPrefix: true,
            controller: _multiplierController,
            examplePrice: examplePrice,
            formatVal: formatVal,
          ),

          const SizedBox(height: 32),
          const Text('Redondeo automático:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF191C1E))),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildRoundingPill('Sin redondeo'),
              _buildRoundingPill('100'),
              _buildRoundingPill('500'),
              _buildRoundingPill('1000'),
            ],
          ),
          const SizedBox(height: 12),
          Text('Si tu precio queda en \$45.560,78\nlo redondeará a \$${formatVal(roundedExample)}', style: const TextStyle(fontSize: 13, color: Color(0xFF5A665D), fontStyle: FontStyle.italic)),
          
          const SizedBox(height: 32),
          // Mensaje Tranqui
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('💡', style: TextStyle(fontSize: 20)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tranqui, elegí la que te resulte más cómoda ahora. Más adelante vas a poder cambiar esta opción o editar el precio final de cada producto a mano.',
                    style: TextStyle(color: Color(0xFF5A665D), fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalcCard({
    required String id,
    required String title,
    required String supportText,
    required String exampleText,
    required String inputLabel,
    required String prefixOrSuffix,
    required bool isPrefix,
    required TextEditingController controller,
    required double examplePrice,
    required String Function(double) formatVal,
  }) {
    bool isSel = _calcMethod == id;
    return GestureDetector(
      onTap: () => setState(() => _calcMethod = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSel ? Colors.white : const Color(0xFFF7F9FB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSel ? const Color(0xFF27C275) : const Color(0xFFE0E3E5), width: isSel ? 2 : 1),
          boxShadow: isSel ? [BoxShadow(color: const Color(0xFF27C275).withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))] : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(isSel ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: isSel ? const Color(0xFF27C275) : const Color(0xFFA2AAC3)),
                const SizedBox(width: 12),
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF191C1E))),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 36.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(supportText, style: const TextStyle(fontSize: 14, color: Color(0xFF3D4A3F))),
                  const SizedBox(height: 2),
                  Text(exampleText, style: const TextStyle(fontSize: 13, color: Color(0xFF5A665D), fontStyle: FontStyle.italic)),
                ],
              ),
            ),
            if (isSel) ...[
              const SizedBox(height: 16),
              const Divider(color: Color(0xFFECEEF0)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(inputLabel, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF191C1E))),
                  Container(
                    width: 90,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F4F6),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE0E3E5)),
                    ),
                    child: Row(
                      children: [
                        if (isPrefix) Padding(padding: const EdgeInsets.only(left: 12.0), child: Text(prefixOrSuffix, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5A665D)))),
                        Expanded(
                          child: TextField(
                            controller: controller,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            textAlign: TextAlign.center,
                            textAlignVertical: TextAlignVertical.center,
                            onChanged: (val) => setState(() {}),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                        if (!isPrefix) Padding(padding: const EdgeInsets.only(right: 12.0), child: Text(prefixOrSuffix, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5A665D)))),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFF2F4F6), borderRadius: BorderRadius.circular(8)),
                child: Text('Si tu producto sale \$10.000 de costo,\nel precio será de \$${formatVal(examplePrice)}', style: const TextStyle(fontSize: 13, color: Color(0xFF5A665D), fontStyle: FontStyle.italic)),
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildRoundingPill(String label) {
    bool isSel = _selectedRounding == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedRounding = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSel ? const Color(0xFF27C275) : Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: isSel ? const Color(0xFF27C275) : const Color(0xFFE0E3E5)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSel ? const Color(0xFF004927) : const Color(0xFF3D4A3F),
            fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildStep3() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Métodos de cobro', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF191C1E), letterSpacing: -0.5)),
          const SizedBox(height: 8),
          const Text('Decide qué formas de pago vas a aceptar en tu negocio y sumale un interés o comisión a cada una.', style: TextStyle(fontSize: 15, color: Color(0xFF3D4A3F))),
          const SizedBox(height: 24),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildPaymentToggleCard('Efectivo', Icons.money_rounded, _useCash, (v) => setState(() => _useCash = v), _cashPercentController),
                  const SizedBox(height: 12),
                  _buildPaymentToggleCard('Transferencia', Icons.swap_horiz_rounded, _useTransfer, (v) => setState(() => _useTransfer = v), _transferPercentController),
                  const SizedBox(height: 12),
                  _buildPaymentToggleCard('Tarjeta', Icons.credit_card_rounded, _useCard, (v) => setState(() => _useCard = v), _cardPercentController),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPaymentToggleCard(String title, IconData icon, bool isEnabled, ValueChanged<bool> onChanged, TextEditingController pctController) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isEnabled ? Colors.white : const Color(0xFFF7F9FB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isEnabled ? const Color(0xFF27C275).withValues(alpha: 0.5) : const Color(0xFFE0E3E5)),
        boxShadow: isEnabled ? [BoxShadow(color: const Color(0xFF27C275).withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))] : [],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: isEnabled ? const Color(0xFFE1E0FF) : const Color(0xFFECEEF0),
                    child: Icon(icon, color: isEnabled ? const Color(0xFF4648D4) : const Color(0xFF5A665D)),
                  ),
                  const SizedBox(width: 12),
                  Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isEnabled ? const Color(0xFF191C1E) : const Color(0xFF6D7B6F))),
                ],
              ),
              Switch(
                value: isEnabled,
                onChanged: onChanged,
                activeThumbColor: const Color(0xFF004927),
                activeTrackColor: const Color(0xFF27C275),
              ),
            ],
          ),
          if (isEnabled) ...[
            const SizedBox(height: 16),
            const Divider(color: Color(0xFFECEEF0), height: 1),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recargo (%)', style: TextStyle(fontSize: 14, color: Color(0xFF5A665D))),
                Container(
                  width: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: pctController,
                          keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                          textAlign: TextAlign.center,
                          textAlignVertical: TextAlignVertical.center,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 10)
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: Text('%', style: TextStyle(color: Color(0xFF6D7B6F), fontWeight: FontWeight.bold, fontSize: 12)),
                      )
                    ],
                  ),
                )
              ],
            )
          ]
        ],
      ),
    );
  }
}
