import 'package:flutter/material.dart';
import 'package:calculori/presentation/screens/home_screen.dart';

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
  late List<Map<String, dynamic>> _metodos;

  @override
  void initState() {
    super.initState();
    _selectedRounding = widget.initialRounding;
    // Creamos una copia de los métodos globales para poder editarlos y descartar si salimos sin guardar
    _metodos = globalMetodosCobro.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  void _onGuardar() {
    // Al guardar, actualizamos la lista global
    globalMetodosCobro = _metodos;
    Navigator.pop(context, {
      'multiplicador': widget.initialMultiplier,
      'redondeo': _selectedRounding,
      'logicType': _selectedLogic,
    });
  }

  void _showMethodModal([Map<String, dynamic>? methodToEdit, int? index]) {
    final TextEditingController nameController = TextEditingController(text: methodToEdit?['nombre'] ?? '');
    
    // Determinar si inicialmente es un recargo o un descuento
    double initialPercent = methodToEdit != null ? (methodToEdit['porcentaje'] as num).toDouble() : 0.0;
    bool isSurcharge = initialPercent >= 0;
    
    // Mostrar siempre el número en positivo en el TextField
    String initialText = methodToEdit != null ? initialPercent.abs().toString().replaceAll(RegExp(r'\.0$'), '') : '';
    final TextEditingController percentController = TextEditingController(text: initialText);
    String selectedIcon = methodToEdit?['icono'] ?? 'billete';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24, right: 24, top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(methodToEdit == null ? 'Nuevo método' : 'Editar método', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF191C1E))),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nombre (Ej. MercadoPago)', 
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Tipo de ajuste', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF191C1E))),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setModalState(() => isSurcharge = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSurcharge ? const Color(0xFF27C275) : const Color(0xFFF7F9FB),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isSurcharge ? const Color(0xFF27C275) : const Color(0xFFE0E3E5)),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Recargo (+)',
                              style: TextStyle(
                                color: isSurcharge ? const Color(0xFF004927) : const Color(0xFF3D4A3F),
                                fontWeight: isSurcharge ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setModalState(() => isSurcharge = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !isSurcharge ? const Color(0xFF27C275) : const Color(0xFFF7F9FB),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: !isSurcharge ? const Color(0xFF27C275) : const Color(0xFFE0E3E5)),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Descuento (-)',
                              style: TextStyle(
                                color: !isSurcharge ? const Color(0xFF004927) : const Color(0xFF3D4A3F),
                                fontWeight: !isSurcharge ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: percentController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Porcentaje (%)', 
                      hintText: 'Ej. 10', 
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Icono', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF191C1E))),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    children: ['billete', 'transferencia', 'tarjeta', 'bolsa', 'etiqueta'].map((iconName) {
                      final isSel = selectedIcon == iconName;
                      return GestureDetector(
                        onTap: () => setModalState(() => selectedIcon = iconName),
                        child: CircleAvatar(
                          backgroundColor: isSel ? const Color(0xFF27C275) : const Color(0xFFECEEF0),
                          child: Icon(getIconFromString(iconName), color: isSel ? const Color(0xFF004927) : const Color(0xFF5A665D)),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
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
                        if (nameController.text.trim().isEmpty) return;
                        final double? rawVal = double.tryParse(percentController.text.replaceAll(',', '.'));
                        if (rawVal == null) return;
                        
                        // Aplicar lógica según lo seleccionado
                        final double finalPercent = isSurcharge ? rawVal.abs() : -rawVal.abs();

                        final newMethod = {
                          "id": methodToEdit?['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
                          "nombre": nameController.text.trim(),
                          "porcentaje": finalPercent,
                          "icono": selectedIcon,
                        };

                        setState(() {
                          if (index != null) {
                            _metodos[index] = newMethod;
                          } else {
                            _metodos.add(newMethod);
                          }
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Guardar Método', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          }
        );
      }
    );
  }

  Widget _buildRoundingOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Divider(color: Color(0xFFE0E3E5)),
        const SizedBox(height: 12),
        const Text(
          'Redondeo automático:',
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
        title: const Text('Configuración', style: TextStyle(color: Color(0xFF191C1E), fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF191C1E), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
                children: [
                  const Text('Lógica de cálculo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF191C1E))),
                  const SizedBox(height: 12),
                  _buildLogicOption(
                    id: 'margen',
                    title: 'Por Margen (%)',
                    description: 'Le sumo un porcentaje de ganancia al costo.',
                    example: '(Ej: Mi costo + 200%)',
                    isSelected: _selectedLogic == 'margen',
                  ),
                  const SizedBox(height: 12),
                  _buildLogicOption(
                    id: 'multiplicador',
                    title: 'Por Multiplicador (x)',
                    description: 'Multiplico el costo por un número fijo.',
                    example: '(Ej: Mi costo x 3)',
                    isSelected: _selectedLogic == 'multiplicador',
                    extraContent: _buildRoundingOptions(),
                  ),
                  const SizedBox(height: 32),
                  const Text('Métodos de cobro', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF191C1E))),
                  const SizedBox(height: 8),
                  const Text('Agrega o edita los recargos y descuentos para cada medio de pago.', style: TextStyle(fontSize: 14, color: Color(0xFF5A665D))),
                  const SizedBox(height: 16),
                  ..._metodos.asMap().entries.map((entry) {
                    int idx = entry.key;
                    var method = entry.value;
                    double porcentaje = (method['porcentaje'] as num).toDouble();
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE0E3E5)),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFECEEF0),
                          child: Icon(getIconFromString(method['icono']), color: const Color(0xFF5A665D)),
                        ),
                        title: Text(method['nombre'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${porcentaje > 0 ? '+' : ''}${porcentaje.toStringAsFixed(0)}%', style: TextStyle(fontWeight: FontWeight.w600, color: porcentaje > 0 ? const Color(0xFFBA1A1A) : (porcentaje < 0 ? const Color(0xFF006D3D) : const Color(0xFF5A665D)))),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_rounded, color: Color(0xFF5A665D), size: 20),
                              onPressed: () => _showMethodModal(method, idx),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_rounded, color: Color(0xFFBA1A1A), size: 20),
                              onPressed: () {
                                setState(() {
                                  _metodos.removeAt(idx);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF006D3D),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFF006D3D), style: BorderStyle.solid)),
                    ),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Agregar Método', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () => _showMethodModal(),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFECEEF0))),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF27C275),
                    foregroundColor: const Color(0xFF004927),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _onGuardar,
                  child: const Text('Guardar Cambios', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
