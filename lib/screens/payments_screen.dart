import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pago_model.dart';
import '../services/pagos_service.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  List<PagoModel> listaPagos = [];
  bool isLoading = true;

  double costoTotal = 0.0;
  double totalPagado = 0.0;

  @override
  void initState() {
    super.initState();
    _cargarPagos();
  }

  Future<void> _cargarPagos() async {
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? "";

    if (token.isNotEmpty) {
      final data = await PagosService.obtenerEstadoCuenta(token);

      if (mounted) {
        setState(() {
          costoTotal =
              double.tryParse(data['total_cargos']?.toString() ?? '0') ?? 0.0;
          totalPagado =
              double.tryParse(data['total_abonado']?.toString() ?? '0') ?? 0.0;

          if (data['historial'] != null && data['historial'] is List) {
            listaPagos = (data['historial'] as List)
                .map((item) => PagoModel.fromJson(item))
                .toList();
          }
          isLoading = false;
        });
      }
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> _accionSubirComprobante(int idPago, String concepto) async {
    // Accesibilidad: El SnackBar es leído automáticamente por el lector de pantalla
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Seleccionando comprobante para: $concepto..."),
        duration: const Duration(seconds: 1),
      ),
    );
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Subiendo imagen al servidor..."),
        backgroundColor: Color(0xFF0277BD),
        duration: Duration(seconds: 2),
      ),
    );
    bool exito = await PagosService.subirComprobante(idPago);
    if (exito && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("¡Comprobante enviado a revisión!"),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        final index = listaPagos.indexWhere((p) => p.id == idPago);
        if (index != -1) {
          listaPagos[index] = PagoModel(
            id: listaPagos[index].id,
            concepto: "Abono en revisión",
            monto: listaPagos[index].monto,
            fecha: DateTime.now(),
            estado: "pagado",
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double saldoRestante = costoTotal - totalPagado;
    final double progreso = costoTotal > 0 ? (totalPagado / costoTotal) : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFE1F5FE),
      appBar: AppBar(
        // ACCESIBILIDAD: Título marcado como encabezado
        title: Semantics(
          header: true,
          child: const Text(
            "Estado de Cuenta",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        backgroundColor: const Color(0xFF0277BD),
        elevation: 0,
        centerTitle: true,
        // ACCESIBILIDAD: Etiqueta para el botón de regresar
        leading: Semantics(
          button: true,
          label: 'Regresar',
          child: IconButton(
            icon: const ExcludeSemantics(
              child: Icon(Icons.arrow_back, color: Colors.white),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: isLoading
          ? Semantics(
              label: 'Cargando tu estado de cuenta y abonos',
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF0277BD)),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- TARJETA PRINCIPAL ---
                  // ACCESIBILIDAD: Agrupamos toda la tarjeta para que se lea fluido
                  MergeSemantics(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: const Color(0xFF014F7E),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Saldo Restante",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 5),
                          // MONEDA: Se agregó MXN al saldo restante
                          Text(
                            "\$${saldoRestante.toStringAsFixed(0)} MXN",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize:
                                  40, // Ligeramente ajustado para que quepa bien el MXN
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 25),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Progreso de pago",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                "${(progreso * 100).toInt()}%",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: progreso,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF4FC3F7),
                              ),
                              minHeight: 8,
                              // ACCESIBILIDAD: Etiquetas semánticas de la barra de progreso
                              semanticsLabel: 'Barra de progreso de pagos',
                              semanticsValue:
                                  '${(progreso * 100).toInt()} por ciento',
                            ),
                          ),
                          const SizedBox(height: 25),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Costo Total",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                  // MONEDA: Se agregó MXN al costo total
                                  Text(
                                    "\$${costoTotal.toStringAsFixed(0)} MXN",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    "Pagado",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                  // MONEDA: Se agregó MXN al total pagado
                                  Text(
                                    "\$${totalPagado.toStringAsFixed(0)} MXN",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- HISTORIAL DE ABONOS ---
                  // ACCESIBILIDAD: Título marcado como Header
                  Semantics(
                    header: true,
                    child: const Text(
                      "Historial de Abonos",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF014F7E),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: listaPagos
                          .map((pago) => _buildAbonoItem(pago))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildAbonoItem(PagoModel pago) {
    bool isPendiente = pago.estado == 'pendiente';

    // ACCESIBILIDAD: Le decimos al usuario qué pasa si toca este elemento
    return Semantics(
      button: isPendiente,
      hint: isPendiente
          ? 'Toca para subir tu comprobante de pago'
          : 'Este abono ya fue procesado',
      child: MergeSemantics(
        child: InkWell(
          onTap: isPendiente
              ? () => _accionSubirComprobante(pago.id, pago.concepto)
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Row(
              children: [
                ExcludeSemantics(
                  child: CircleAvatar(
                    backgroundColor: isPendiente
                        ? Colors.orange.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                    child: Icon(
                      isPendiente ? Icons.access_time_filled : Icons.check,
                      color: isPendiente ? Colors.orange : Colors.green,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isPendiente ? "Pago Pendiente" : "Abono mensual",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        "${pago.fecha.day} de ${_obtenerMes(pago.fecha.month)} de ${pago.fecha.year}",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    // MONEDA: Se agregó MXN a cada pago individual
                    Text(
                      "\$${pago.monto.toStringAsFixed(0)} MXN",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isPendiente ? Colors.orange : Colors.black87,
                      ),
                    ),
                    if (isPendiente)
                      const ExcludeSemantics(
                        child: Icon(Icons.chevron_right, color: Colors.grey),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _obtenerMes(int mes) {
    // ACCESIBILIDAD: Meses completos para correcta lectura del sintetizador de voz
    const meses = [
      "Enero",
      "Febrero",
      "Marzo",
      "Abril",
      "Mayo",
      "Junio",
      "Julio",
      "Agosto",
      "Septiembre",
      "Octubre",
      "Noviembre",
      "Diciembre",
    ];
    return meses[mes - 1];
  }
}
