import 'package:flutter/material.dart';
import 'package:sistema_gestion/aplicacion/casos_uso/calcular_precio_kilo.dart';
import 'package:sistema_gestion/aplicacion/casos_uso/calcular_precio_unidad.dart';
import 'package:sistema_gestion/dominio/entidades/calculo_kilo.dart';
import 'package:sistema_gestion/dominio/entidades/calculo_unidad.dart';
import 'package:sistema_gestion/inyeccion_dependencias.dart';

class VistaCalculadora extends StatefulWidget {
  const VistaCalculadora({super.key});

  @override
  State<VistaCalculadora> createState() => _VistaCalculadoraState();
}

class _VistaCalculadoraState extends State<VistaCalculadora> {
  final _formKeyUnidad = GlobalKey<FormState>();
  final _formKeyKilo = GlobalKey<FormState>();

  final _costoTotalUnidadController = TextEditingController();
  final _margenUnidadController = TextEditingController();

  final _costoTotalKiloController = TextEditingController();
  final _pesoKilosController = TextEditingController();
  final _margenKiloController = TextEditingController();

  CalculoUnidad? _resultadoUnidad;
  CalculoKilo? _resultadoKilo;
  bool _isCalculando = false;

  int _modoSeleccionado = 0;

  @override
  void dispose() {
    _costoTotalUnidadController.dispose();
    _margenUnidadController.dispose();
    _costoTotalKiloController.dispose();
    _pesoKilosController.dispose();
    _margenKiloController.dispose();
    super.dispose();
  }

  String _formatearMonto(double valor) {
    return '\$${valor.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    )}';
  }

  String _formatearNumero(double valor) {
    return valor.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }

  Future<void> _calcularUnidad() async {
    if (!_formKeyUnidad.currentState!.validate()) return;

    setState(() => _isCalculando = true);

    try {
      final casoUso = getIt<CalcularPrecioUnidad>();
      final resultado = casoUso.ejecutar(
        costoTotal: double.parse(_costoTotalUnidadController.text),
        porcentajeMargen: double.parse(_margenUnidadController.text),
      );
      setState(() => _resultadoUnidad = resultado);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al calcular: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isCalculando = false);
    }
  }

  Future<void> _calcularKilo() async {
    if (!_formKeyKilo.currentState!.validate()) return;

    setState(() => _isCalculando = true);

    try {
      final casoUso = getIt<CalcularPrecioKilo>();
      final resultado = casoUso.ejecutar(
        costoTotal: double.parse(_costoTotalKiloController.text),
        pesoKilos: double.parse(_pesoKilosController.text),
        porcentajeMargen: double.parse(_margenKiloController.text),
      );
      setState(() => _resultadoKilo = resultado);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al calcular: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isCalculando = false);
    }
  }

  Widget _buildModoUnidad() {
    return Form(
      key: _formKeyUnidad,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _costoTotalUnidadController,
            style: const TextStyle(fontSize: 18),
            decoration: const InputDecoration(
              labelText: 'Costo Total (\$)',
              labelStyle: TextStyle(fontSize: 16),
              prefixIcon: Icon(Icons.attach_money),
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingrese el costo total';
              }
              final n = double.tryParse(value);
              if (n == null || n <= 0) {
                return 'Ingrese un valor numérico positivo';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _margenUnidadController,
            style: const TextStyle(fontSize: 18),
            decoration: const InputDecoration(
              labelText: 'Margen de Ganancia (%)',
              labelStyle: TextStyle(fontSize: 16),
              prefixIcon: Icon(Icons.percent),
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingrese el margen';
              }
              final n = double.tryParse(value);
              if (n == null || n < 0) {
                return 'Ingrese un valor numérico válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: _isCalculando ? null : _calcularUnidad,
            icon: _isCalculando
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : const Icon(Icons.calculate, size: 22),
            label: const Text('Calcular', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 28),
          if (_resultadoUnidad != null) _buildResultadoUnidad(),
        ],
      ),
    );
  }

  Widget _buildResultadoUnidad() {
    final r = _resultadoUnidad!;
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resultado',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
            ),
            const Divider(height: 20, thickness: 1.2),
            _buildFilaResultado('Costo Total', _formatearMonto(r.costoTotal), fontSize: 17),
            _buildFilaResultado('Margen', '${_formatearNumero(r.porcentajeMargen)}%', fontSize: 17),
            const Divider(height: 20, thickness: 1.2),
            _buildFilaResultado(
              'Precio Venta Sugerido',
              _formatearMonto(r.precioVentaSugerido),
              esDestacado: true,
              fontSize: 20,
            ),
            _buildFilaResultado(
              'Ganancia Unitaria',
              _formatearMonto(r.gananciaUnitaria),
              esDestacado: true,
              fontSize: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModoKilo() {
    return Form(
      key: _formKeyKilo,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _costoTotalKiloController,
            style: const TextStyle(fontSize: 18),
            decoration: const InputDecoration(
              labelText: 'Costo Total (\$)',
              labelStyle: TextStyle(fontSize: 16),
              prefixIcon: Icon(Icons.attach_money),
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingrese el costo total';
              }
              final n = double.tryParse(value);
              if (n == null || n <= 0) {
                return 'Ingrese un valor numérico positivo';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _pesoKilosController,
            style: const TextStyle(fontSize: 18),
            decoration: const InputDecoration(
              labelText: 'Peso Total (Kg)',
              labelStyle: TextStyle(fontSize: 16),
              prefixIcon: Icon(Icons.monitor_weight),
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingrese el peso';
              }
              final n = double.tryParse(value);
              if (n == null || n <= 0) {
                return 'Ingrese un valor numérico positivo';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _margenKiloController,
            style: const TextStyle(fontSize: 18),
            decoration: const InputDecoration(
              labelText: 'Margen de Ganancia (%)',
              labelStyle: TextStyle(fontSize: 16),
              prefixIcon: Icon(Icons.percent),
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingrese el margen';
              }
              final n = double.tryParse(value);
              if (n == null || n < 0) {
                return 'Ingrese un valor numérico válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: _isCalculando ? null : _calcularKilo,
            icon: _isCalculando
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : const Icon(Icons.calculate, size: 22),
            label: const Text('Calcular', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 28),
          if (_resultadoKilo != null) _buildResultadoKilo(),
        ],
      ),
    );
  }

  Widget _buildResultadoKilo() {
    final r = _resultadoKilo!;
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resultado',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
            ),
            const Divider(height: 20, thickness: 1.2),
            _buildFilaResultado('Costo Total', _formatearMonto(r.costoTotal), fontSize: 17),
            _buildFilaResultado('Peso Total', '${_formatearNumero(r.pesoKilos)} Kg', fontSize: 17),
            _buildFilaResultado('Margen', '${_formatearNumero(r.porcentajeMargen)}%', fontSize: 17),
            const Divider(height: 20, thickness: 1.2),
            _buildFilaResultado(
              'Costo por Kilo',
              _formatearMonto(r.costoPorKilo),
              fontSize: 18,
            ),
            _buildFilaResultado(
              'Precio Venta Sugerido por Kilo',
              _formatearMonto(r.precioVentaSugeridoKilo),
              esDestacado: true,
              fontSize: 20,
            ),
            _buildFilaResultado(
              'Ganancia por Kilo',
              _formatearMonto(r.gananciaKilo),
              esDestacado: true,
              fontSize: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilaResultado(String etiqueta, String valor, {bool esDestacado = false, double fontSize = 16}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            etiqueta,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: esDestacado ? Theme.of(context).colorScheme.primary : null,
                  fontWeight: esDestacado ? FontWeight.w600 : FontWeight.normal,
                  fontSize: fontSize,
                ),
          ),
          Text(
            valor,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: esDestacado ? Theme.of(context).colorScheme.primary : null,
                  fontSize: fontSize,
                ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Calculadora de Precios',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Calcule precios de venta y ganancias según el modo seleccionado',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 15,
                ),
          ),
          const SizedBox(height: 28),
          SegmentedButton<int>(
            style: ButtonStyle(
              padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
              textStyle: WidgetStateProperty.all(const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            ),
            segments: const [
              ButtonSegment(
                value: 0,
                label: Text('Por Unidad'),
                icon: Icon(Icons.format_list_numbered, size: 20),
              ),
              ButtonSegment(
                value: 1,
                label: Text('Por Kilo'),
                icon: Icon(Icons.monitor_weight, size: 20),
              ),
            ],
            selected: {_modoSeleccionado},
            onSelectionChanged: (Set<int> selection) {
              setState(() {
                _modoSeleccionado = selection.first;
                _resultadoUnidad = null;
                _resultadoKilo = null;
              });
            },
          ),
          const SizedBox(height: 28),
          Expanded(
            child: SingleChildScrollView(
              child: _modoSeleccionado == 0 ? _buildModoUnidad() : _buildModoKilo(),
            ),
          ),
        ],
      ),
    );
  }
}