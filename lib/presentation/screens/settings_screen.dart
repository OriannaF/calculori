import 'package:flutter/material.dart';
import 'package:calculori/presentation/screens/home_screen.dart';

class SettingsScreen extends StatefulWidget {
  final double initialMultiplier;
  final String initialRounding;
  final List<Map<String, dynamic>> initialPaymentMethods;

  const SettingsScreen({
    super.key,
    required this.initialMultiplier,
    required this.initialRounding,
    this.initialPaymentMethods = const [],
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String _selectedRounding;
  String _selectedLogic = 'multiplicador'; // 'margen' or 'multiplicador'
<<<<<<< HEAD
  late List<Map<String, dynamic>> _paymentMethods;
  
  late TextEditingController _marginController;
  late TextEditingController _multiplierController;
=======
  late List<Map<String, dynamic>> _metodos;
>>>>>>> f9fd89b8d688ebb204181752cb3b6d442a4343f1

  @override
  void initState() {
    super.initState();
    _selectedRounding = widget.initialRounding;
<<<<<<< HEAD
    
    double mult = widget.initialMultiplier;
    double margin = (mult > 0 ? (mult - 1) * 100 : 0);
    
    _multiplierController = TextEditingController(text: mult.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '').replaceAll(RegExp(r'0$'), ''));
    _marginController = TextEditingController(text: margin.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), ''));

    // Deep copy for local edits
    _paymentMethods = widget.initialPaymentMethods.map((m) => Map<String, dynamic>.from(m)).toList();
  }

  @override
  void dispose() {
    _marginController.dispose();
    _multiplierController.dispose();
    super.dispose();
  }

  void _onNext() {
    double finalMultiplier = widget.initialMultiplier;
    if (_selectedLogic == 'multiplicador') {
      finalMultiplier = double.tryParse(_multiplierController.text.replaceAll(',', '.')) ?? widget.initialMultiplier;
    } else {
      double margin = double.tryParse(_marginController.text.replaceAll(',', '.')) ?? 0.0;
      finalMultiplier = 1 + (margin / 100);
    }

=======
    // Creamos una copia de los métodos globales para poder editarlos y descartar si salimos sin guardar
    _metodos = globalMetodosCobro.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  void _onGuardar() {
    // Al guardar, actualizamos la lista global
    globalMetodosCobro = _metodos;
>>>>>>> f9fd89b8d688ebb204181752cb3b6d442a4343f1
    Navigator.pop(context, {
      'multiplicador': finalMultiplier,
      'redondeo': _selectedRounding,
      'logicType': _selectedLogic,
      'metodosCobro': _paymentMethods,
    });
  }

<<<<<<< HEAD
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'billete': return Icons.money_rounded;
      case 'transferencia': return Icons.swap_horiz_rounded;
      case 'tarjeta': return Icons.credit_card_rounded;
      case 'bolsa': return Icons.shopping_bag_rounded;
      case 'etiqueta': return Icons.local_offer_rounded;
      default: return Icons.money_rounded;
    }
  }

  void _showEditMethodDialog(Map<String, dynamic>? method, int index) {
    String nombre = method?['nombre'] ?? '';
    double porcentaje = (method?['porcentaje'] as num?)?.toDouble() ?? 0.0;
    String icono = method?['icono'] ?? 'billete';
    
    bool isDescuento = porcentaje < 0;
    double valorAbsoluto = porcentaje.abs();
    
    TextEditingController nameController = TextEditingController(text: nombre);
    TextEditingController percentController = TextEditingController(text: valorAbsoluto == 0 ? '' : valorAbsoluto.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), ''));
=======
  void _showMethodModal([Map<String, dynamic>? methodToEdit, int? index]) {
    final TextEditingController nameController = TextEditingController(text: methodToEdit?['nombre'] ?? '');
    
    // Determinar si inicialmente es un recargo o un descuento
    double initialPercent = methodToEdit != null ? (methodToEdit['porcentaje'] as num).toDouble() : 0.0;
    bool isSurcharge = initialPercent >= 0;
    
    // Mostrar siempre el número en positivo en el TextField
    String initialText = methodToEdit != null ? initialPercent.abs().toString().replaceAll(RegExp(r'\.0$'), '') : '';
    final TextEditingController percentController = TextEditingController(text: initialText);
    String selectedIcon = methodToEdit?['icono'] ?? 'billete';
>>>>>>> f9fd89b8d688ebb204181752cb3b6d442a4343f1

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
<<<<<<< HEAD
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
=======
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24, right: 24, top: 24,
>>>>>>> f9fd89b8d688ebb204181752cb3b6d442a4343f1
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
<<<<<<< HEAD
                  Text(
                    method == null ? 'Nuevo Método de Pago' : 'Editar Método',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF191C1E)),
                  ),
                  const SizedBox(height: 24),
                  
                  const Text('Icono', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF3D4A3F))),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['billete', 'transferencia', 'tarjeta', 'bolsa', 'etiqueta'].map((iconName) {
                        bool isSelected = icono == iconName;
                        return GestureDetector(
                          onTap: () {
                            setModalState(() => icono = iconName);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF27C275).withOpacity(0.2) : const Color(0xFFF7F9FB),
                              shape: BoxShape.circle,
                              border: Border.all(color: isSelected ? const Color(0xFF27C275) : const Color(0xFFE0E3E5)),
                            ),
                            child: Icon(_getIconData(iconName), color: isSelected ? const Color(0xFF004927) : const Color(0xFF5A665D)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nombre del método',
                      labelStyle: const TextStyle(color: Color(0xFF5A665D)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF27C275), width: 2), borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
=======
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
>>>>>>> f9fd89b8d688ebb204181752cb3b6d442a4343f1
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
<<<<<<< HEAD
                          onTap: () => setModalState(() => isDescuento = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: !isDescuento ? const Color(0xFFFFEBEE) : const Color(0xFFF7F9FB),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: !isDescuento ? Colors.red : const Color(0xFFE0E3E5)),
                            ),
                            child: Text('Recargo (+)', style: TextStyle(color: !isDescuento ? Colors.red : const Color(0xFF5A665D), fontWeight: FontWeight.bold)),
=======
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
>>>>>>> f9fd89b8d688ebb204181752cb3b6d442a4343f1
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
<<<<<<< HEAD
                          onTap: () => setModalState(() => isDescuento = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isDescuento ? const Color(0xFFE8F5E9) : const Color(0xFFF7F9FB),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isDescuento ? Colors.green : const Color(0xFFE0E3E5)),
                            ),
                            child: Text('Descuento (-)', style: TextStyle(color: isDescuento ? Colors.green : const Color(0xFF5A665D), fontWeight: FontWeight.bold)),
=======
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
>>>>>>> f9fd89b8d688ebb204181752cb3b6d442a4343f1
                          ),
                        ),
                      ),
                    ],
                  ),
<<<<<<< HEAD
                  const SizedBox(height: 20),
                  
=======
                  const SizedBox(height: 16),
>>>>>>> f9fd89b8d688ebb204181752cb3b6d442a4343f1
                  TextField(
                    controller: percentController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
<<<<<<< HEAD
                      labelText: 'Porcentaje (%)',
                      labelStyle: const TextStyle(color: Color(0xFF5A665D)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF27C275), width: 2), borderRadius: BorderRadius.circular(12)),
                      suffixText: '%',
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (nameController.text.trim().isEmpty) return;
                        double val = double.tryParse(percentController.text.replaceAll(',', '.')) ?? 0.0;
                        if (isDescuento) {
                          val = -val.abs();
                        } else {
                          val = val.abs();
                        }
                        
                        Map<String, dynamic> newMethod = {
                          'id': method?['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
                          'nombre': nameController.text.trim(),
                          'porcentaje': val,
                          'icono': icono,
                        };
                        
                        setState(() {
                          if (index >= 0) {
                            _paymentMethods[index] = newMethod;
                          } else {
                            _paymentMethods.add(newMethod);
                          }
                        });
                        Navigator.pop(ctx);
                      },
=======
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
>>>>>>> f9fd89b8d688ebb204181752cb3b6d442a4343f1
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF27C275),
                        foregroundColor: const Color(0xFF004927),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
<<<<<<< HEAD
=======
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
>>>>>>> f9fd89b8d688ebb204181752cb3b6d442a4343f1
                      child: const Text('Guardar Método', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
<<<<<<< HEAD
          },
        );
      },
    );
  }

  void _addPaymentMethod() => _showEditMethodDialog(null, -1);
  void _editPaymentMethod(Map<String, dynamic> method, int index) => _showEditMethodDialog(method, index);
  void _deletePaymentMethod(int index) {
    setState(() {
      _paymentMethods.removeAt(index);
    });
  }

  Widget _buildPaymentMethodCard(Map<String, dynamic> method, int index) {
    double porcentaje = (method['porcentaje'] as num).toDouble();
    bool isDescuento = porcentaje < 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E3E5)),
        boxShadow: [
          BoxShadow(color: const Color(0xFF00522D).withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFF7F9FB),
              shape: BoxShape.circle,
            ),
            child: Icon(_getIconData(method['icono'] ?? 'billete'), color: const Color(0xFF5A665D)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  method['nombre'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF191C1E)),
                ),
                const SizedBox(height: 4),
                Text(
                  isDescuento ? 'Descuento del ${porcentaje.abs().toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}%' : 'Recargo del ${porcentaje.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}%',
                  style: TextStyle(
                    fontSize: 14, 
                    color: isDescuento ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: Color(0xFF5A665D)),
            onPressed: () => _editPaymentMethod(method, index),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
            onPressed: () => _deletePaymentMethod(index),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Métodos de Cobro',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF191C1E),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Configurá los recargos o descuentos según el método de pago. Estos se calcularán sobre tu precio final.',
          style: TextStyle(fontSize: 14, color: Color(0xFF5A665D), height: 1.4),
        ),
        const SizedBox(height: 16),
        ..._paymentMethods.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> method = entry.value;
          return _buildPaymentMethodCard(method, index);
        }),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: _addPaymentMethod,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Agregar método de cobro', style: TextStyle(fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE8F5E9),
            foregroundColor: const Color(0xFF006D3D),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            minimumSize: const Size(double.infinity, 56),
          ),
        ),
      ],
=======
          }
        );
      }
>>>>>>> f9fd89b8d688ebb204181752cb3b6d442a4343f1
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

  Widget _buildInputField({
    required String label,
    required String suffix,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Divider(color: Color(0xFFE0E3E5)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF191C1E))),
            Container(
              width: 90,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F6),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE0E3E5)),
              ),
              child: Row(
                children: [
                  if (suffix == 'x') Padding(padding: const EdgeInsets.only(left: 12.0), child: Text(suffix, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5A665D)))),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.center,
                      textAlignVertical: TextAlignVertical.center,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  if (suffix == '%') Padding(padding: const EdgeInsets.only(right: 12.0), child: Text(suffix, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5A665D)))),
                ],
              ),
            )
          ],
        ),
      ],
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
              ? [BoxShadow(color: const Color(0xFF27C275).withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))]
              : [BoxShadow(color: const Color(0xFF00522D).withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
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
        title: const Text('Configuración', style: TextStyle(color: Color(0xFF191C1E), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
<<<<<<< HEAD
        centerTitle: false,
=======
        title: const Text('Configuración', style: TextStyle(color: Color(0xFF191C1E), fontWeight: FontWeight.bold)),
        centerTitle: true,
>>>>>>> f9fd89b8d688ebb204181752cb3b6d442a4343f1
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF191C1E), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
<<<<<<< HEAD
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      'Lógica Base',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF191C1E),
=======
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
>>>>>>> f9fd89b8d688ebb204181752cb3b6d442a4343f1
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
<<<<<<< HEAD
                    const SizedBox(height: 8),
                    const Text(
                      'Elegí la lógica base que usás para marcar tus productos.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF5A665D),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildLogicOption(
                      id: 'margen',
                      title: 'Por Margen (%)',
                      description: 'Le sumo un porcentaje de ganancia al costo.',
                      example: '(Ej: Mi costo + 200%)',
                      isSelected: _selectedLogic == 'margen',
                      extraContent: _buildInputField(
                        label: 'Margen de ganancia',
                        suffix: '%',
                        controller: _marginController,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildLogicOption(
                      id: 'multiplicador',
                      title: 'Por Multiplicador (x)',
                      description: 'Multiplico el costo por un número fijo.',
                      example: '(Ej: Mi costo x 3)',
                      isSelected: _selectedLogic == 'multiplicador',
                      extraContent: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInputField(
                            label: 'Multiplicador',
                            suffix: 'x',
                            controller: _multiplierController,
                          ),
                          _buildRoundingOptions(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Divider(color: Color(0xFFE0E3E5)),
                    const SizedBox(height: 24),
                    _buildPaymentMethodsSection(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9FB),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4)),
                ],
=======
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
>>>>>>> f9fd89b8d688ebb204181752cb3b6d442a4343f1
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
<<<<<<< HEAD
                  onPressed: _onNext,
                  child: const Text('Guardar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
=======
                  onPressed: _onGuardar,
                  child: const Text('Guardar Cambios', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
>>>>>>> f9fd89b8d688ebb204181752cb3b6d442a4343f1
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
