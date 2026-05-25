import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final double initialMultiplier;
  final String initialRounding;

  const SettingsScreen({
    super.key,
    required this.initialMultiplier,
    required this.initialRounding,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String _selectedRounding;
  String _selectedLogic = 'multiplicador'; // 'margen' or 'multiplicador'

  @override
  void initState() {
    super.initState();
    _selectedRounding = widget.initialRounding;
  }

  void _onNext() {
    Navigator.pop(context, {
      'multiplicador': widget.initialMultiplier,
      'redondeo': _selectedRounding,
      'logicType': _selectedLogic,
    });
  }

  Widget _buildRoundingOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Divider(color: Color(0xFFE0E3E5)),
        const SizedBox(height: 12),
        const Text(
          'Redondeo (hacia arriba a):',
          style: TextStyle(color: Color(0xFF3D4A3F), fontSize: 13, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildRoundingOption('500'),
            _buildRoundingOption('1000'),
            _buildRoundingOption('Sin redondeo'),
            _buildRoundingOption('Cientos'),
          ],
        ),
      ],
    );
  }

  Widget _buildRoundingOption(String label) {
    final bool isSelected = _selectedRounding == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedRounding = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF27C275) : const Color(0xFFF7F9FB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? const Color(0xFF27C275) : const Color(0xFFE0E3E5)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF004927) : const Color(0xFF3D4A3F),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildLogicOption({
    required String id,
    required String title,
    required String description,
    required String example,
    required bool isSelected,
    Widget? extraContent,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLogic = id;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0FDF4) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? const Color(0xFF27C275) : const Color(0xFFE0E3E5),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: const Color(0xFF27C275).withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))]
              : [BoxShadow(color: const Color(0xFF00522D).withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: isSelected ? const Color(0xFF27C275) : const Color(0xFF5A665D),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF191C1E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: const TextStyle(fontSize: 15, color: Color(0xFF3D4A3F)),
            ),
            const SizedBox(height: 6),
            Text(
              example,
              style: const TextStyle(fontSize: 14, color: Color(0xFF8C968F), fontStyle: FontStyle.italic),
            ),
            if (extraContent != null && isSelected) extraContent,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF191C1E), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text(
                '¿Cómo solés calcular tus precios?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF191C1E),
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Elegí la lógica base que usás para marcar tus productos.',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF5A665D),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildLogicOption(
                        id: 'margen',
                        title: 'Por Margen (%)',
                        description: 'Le sumo un porcentaje de ganancia al costo.',
                        example: '(Ej: Mi costo + 200%)',
                        isSelected: _selectedLogic == 'margen',
                      ),
                      const SizedBox(height: 16),
                      _buildLogicOption(
                        id: 'multiplicador',
                        title: 'Por Multiplicador (x)',
                        description: 'Multiplico el costo por un número fijo.',
                        example: '(Ej: Mi costo x 3)',
                        isSelected: _selectedLogic == 'multiplicador',
                        extraContent: _buildRoundingOptions(),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9E6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFFE082)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('💡', style: TextStyle(fontSize: 20)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tranqui, elegí la que te resulte más cómoda ahora. Más adelante vas a poder cambiar esta opción o editar el precio final de cada producto a mano.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF5C4D1F),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
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
                  onPressed: _onNext,
                  child: const Text('Siguiente', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
