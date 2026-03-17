import 'package:flutter/material.dart';
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

  // Variables para la tarjeta principal (Estado de cuenta general)
  final double costoTotal = 15000.0;
  final double totalPagado = 10000.0;

  @override
  void initState() {
    super.initState();
    _cargarPagos();
  }

  Future<void> _cargarPagos() async {
    final pagos = await PagosService.obtenerHistorialPagos(1);
    if (mounted) {
      setState(() {
        listaPagos = pagos;
        isLoading = false;
      });
    }
  }

  Future<void> _accionSubirComprobante(int idPago, String concepto) async {
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
    final double progreso = totalPagado / costoTotal;

    return Scaffold(
      backgroundColor: const Color(
        0xFFE1F5FE,
      ), // Fondo celeste claro de tu diseño
      appBar: AppBar(
        title: const Text(
          "Estado de Cuenta",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0277BD),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0277BD)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- TARJETA PRINCIPAL (DISEÑO ORIGINAL) ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: const Color(0xFF014F7E), // Tu color azul marino
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Saldo Restante",
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "\$${saldoRestante.toStringAsFixed(0)}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 45,
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
                                Text(
                                  "\$${costoTotal.toStringAsFixed(0)}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
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
                                Text(
                                  "\$${totalPagado.toStringAsFixed(0)}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
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

                  const SizedBox(height: 30),

                  // --- HISTORIAL DE ABONOS ---
                  const Text(
                    "Historial de Abonos",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF014F7E),
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

    return InkWell(
      // Si está pendiente, al tocarlo pide el comprobante
      onTap: isPendiente
          ? () => _accionSubirComprobante(pago.id, pago.concepto)
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: isPendiente
                  ? Colors.orange.withOpacity(0.1)
                  : Colors.green.withOpacity(0.1),
              child: Icon(
                isPendiente ? Icons.access_time_filled : Icons.check,
                color: isPendiente ? Colors.orange : Colors.green,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isPendiente
                        ? "Pago Pendiente"
                        : "Abono mensual", // Manteniendo tus textos del diseño
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    "${pago.fecha.day} ${_obtenerMes(pago.fecha.month)} ${pago.fecha.year}",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Text(
                  "\$${pago.monto.toStringAsFixed(0)}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isPendiente ? Colors.orange : Colors.black87,
                  ),
                ),
                if (isPendiente)
                  const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _obtenerMes(int mes) {
    const meses = [
      "Ene",
      "Feb",
      "Mar",
      "Abr",
      "May",
      "Jun",
      "Jul",
      "Ago",
      "Sep",
      "Oct",
      "Nov",
      "Dic",
    ];
    return meses[mes - 1];
  }
}
