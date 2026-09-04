import 'package:flutter/material.dart';
import 'package:sistema_gestion/aplicacion/casos_uso/consultar_arqueo_diario.dart';
import 'package:sistema_gestion/dominio/entidades/enumerados/medio_pago.dart';
import 'package:sistema_gestion/dominio/entidades/enumerados/tipo_movimiento.dart';
import 'package:sistema_gestion/dominio/entidades/transaccion.dart';
import 'package:sistema_gestion/inyeccion_dependencias.dart';

class VistaArqueoDiario extends StatefulWidget {
  const VistaArqueoDiario({super.key});

  @override
  State<VistaArqueoDiario> createState() => _VistaArqueoDiarioState();
}

class _VistaArqueoDiarioState extends State<VistaArqueoDiario> {
  DateTime _fechaSeleccionada = DateTime.now();
  List<Transaccion> _transacciones = [];
  bool _isCargando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarTransacciones();
  }

  Future<void> _cargarTransacciones() async {
    setState(() {
      _isCargando = true;
      _error = null;
    });

    try {
      final casoUso = getIt<ConsultarArqueoDiario>();
      final resultado = await casoUso.ejecutar(_fechaSeleccionada);
      if (mounted) {
        setState(() {
          _transacciones = resultado;
          _isCargando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error al cargar arqueo: $e';
          _isCargando = false;
        });
      }
    }
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (fecha != null && fecha != _fechaSeleccionada) {
      setState(() => _fechaSeleccionada = fecha);
      _cargarTransacciones();
    }
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

  String _formatearHora(DateTime fecha) {
    return '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
  }

  String _formatearMonto(double monto) {
    return '\$${monto.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    )}';
  }

  double _calcularTotalIngresos() {
    return _transacciones
        .where((t) => t.tipoMovimiento == TipoMovimiento.ingreso)
        .fold(0.0, (sum, t) => sum + t.monto);
  }

  double _calcularTotalEgresos() {
    return _transacciones
        .where((t) => t.tipoMovimiento == TipoMovimiento.egreso)
        .fold(0.0, (sum, t) => sum + t.monto);
  }

  double _calcularSaldoEfectivo() {
    return _transacciones
        .where((t) => t.medioPago == MedioPago.efectivo)
        .fold(0.0, (sum, t) => sum + t.monto);
  }

  double _calcularSaldoTransferencia() {
    return _transacciones
        .where((t) => t.medioPago == MedioPago.transferencia)
        .fold(0.0, (sum, t) => sum + t.monto);
  }

  double _calcularBalance() {
    return _calcularTotalIngresos() - _calcularTotalEgresos();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Arqueo Diario',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: _seleccionarFecha,
                icon: const Icon(Icons.calendar_today),
                label: Text(_formatearFecha(_fechaSeleccionada)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_isCargando)
            const Center(child: CircularProgressIndicator())
          else if (_error != null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: TextStyle(color: colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _cargarTransacciones,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            )
          else ...[
            _buildResumenCards(),
            const SizedBox(height: 24),
            _buildListaTransacciones(),
          ],
        ],
      ),
    );
  }

  Widget _buildResumenCards() {
    final totalIngresos = _calcularTotalIngresos();
    final totalEgresos = _calcularTotalEgresos();
    final saldoEfectivo = _calcularSaldoEfectivo();
    final saldoTransferencia = _calcularSaldoTransferencia();
    final balance = _calcularBalance();

    return Row(
      children: [
        Expanded(child: _buildResumenCard('Total Ingresos', _formatearMonto(totalIngresos), Colors.green, Icons.arrow_downward)),
        const SizedBox(width: 16),
        Expanded(child: _buildResumenCard('Total Egresos', _formatearMonto(totalEgresos), Colors.red, Icons.arrow_upward)),
        const SizedBox(width: 16),
        Expanded(child: _buildResumenCard('Saldo Efectivo', _formatearMonto(saldoEfectivo), Colors.blue, Icons.money)),
        const SizedBox(width: 16),
        Expanded(child: _buildResumenCard('Saldo Transferencia', _formatearMonto(saldoTransferencia), Colors.purple, Icons.account_balance)),
        const SizedBox(width: 16),
        Expanded(child: _buildResumenCard('Balance Total', _formatearMonto(balance), balance >= 0 ? Colors.green : Colors.red, Icons.balance)),
      ],
    );
  }

  Widget _buildResumenCard(String titulo, String valor, Color color, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    titulo,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              valor,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListaTransacciones() {
    if (_transacciones.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              'Sin movimientos registrados en esta fecha',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Column(
        children: [
          DataTable(
            columnSpacing: 16,
            headingRowColor: WidgetStatePropertyAll(Colors.grey),
            columns: [
              DataColumn(label: Text('Hora', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Tipo', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Medio Pago', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Monto', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right), numeric: true),
              DataColumn(label: Text('Descripción', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: [],
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: _transacciones.length,
              itemBuilder: (context, index) {
                final t = _transacciones[index];
                final esIngreso = t.tipoMovimiento == TipoMovimiento.ingreso;
                return ListTile(
                  leading: Icon(
                    esIngreso ? Icons.arrow_downward : Icons.arrow_upward,
                    color: esIngreso ? Colors.green : Colors.red,
                  ),
                  title: Text(_formatearHora(t.fechaHora)),
                  subtitle: Text(
                    t.descripcion ?? 'Sin descripción',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    _formatearMonto(t.monto),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: esIngreso ? Colors.green : Colors.red,
                    ),
                  ),
                  onTap: () => _mostrarDetalle(t),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarDetalle(Transaccion t) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.tipoMovimiento == TipoMovimiento.ingreso ? 'Detalle Ingreso' : 'Detalle Egreso'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetalleFila('Monto', _formatearMonto(t.monto)),
            _buildDetalleFila('Medio de Pago', t.medioPago == MedioPago.efectivo ? 'Efectivo' : 'Transferencia'),
            _buildDetalleFila('Fecha y Hora', '${_formatearFecha(t.fechaHora)} ${_formatearHora(t.fechaHora)}'),
            if (t.descripcion != null) _buildDetalleFila('Descripción', t.descripcion!),
            if (t.id != null) _buildDetalleFila('ID', t.id.toString()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetalleFila(String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$etiqueta:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(valor)),
        ],
      ),
    );
  }
}