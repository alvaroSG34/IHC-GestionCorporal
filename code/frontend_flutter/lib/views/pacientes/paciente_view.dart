import 'package:flutter/material.dart';

import '../../consts/colors.dart';
import '../../consts/styles.dart';
import '../../models/paciente.dart';
import '../../services/paciente_service.dart';
import '../../widgets/top_app_bar.dart';
import 'paciente_detalle_view.dart';
import 'paciente_create_view.dart';

class PacienteView extends StatefulWidget {
  const PacienteView({super.key});

  @override
  State<PacienteView> createState() => _PacienteViewState();
}

class _PacienteViewState extends State<PacienteView> {
  final _controladorBusqueda = TextEditingController();
  Future<List<Paciente>>? _futuroPacientes;
  String _textoBusqueda = '';

  @override
  void initState() {
    super.initState();
    _cargarPacientes();
    _controladorBusqueda.addListener(() {
      setState(() {
        _textoBusqueda = _controladorBusqueda.text.trim().toLowerCase();
      });
    });
  }

  void _cargarPacientes() {
    _futuroPacientes = PacienteService().getPacientes();
  }

  Future<void> _crearPaciente() async {
    final pacienteCreado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const PacienteCreateView()),
    );

    if (pacienteCreado == true && mounted) {
      setState(_cargarPacientes);
    }
  }

  @override
  void dispose() {
    _controladorBusqueda.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFBFBFB),
      child: Column(
        children: [
          TopAppBar(titulo: 'Pacientes', alAccion: _crearPaciente),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  TextField(
                    controller: _controladorBusqueda,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF616161),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Buscar paciente',
                      hintStyle: const TextStyle(
                        color: Color(0xFF616161),
                        fontSize: 16,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF0F0F0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: FutureBuilder<List<Paciente>>(
                      future: _futuroPacientes,
                      builder: (contexto, estado) {
                        if (estado.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (estado.hasError) {
                          return Center(
                            child: Text(
                              'Error al cargar pacientes:\n${estado.error}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: plomo,
                                fontFamily: regular,
                              ),
                            ),
                          );
                        }

                        final pacientes = (estado.data ?? [])
                            .where(
                              (paciente) => paciente.nombre
                                  .toLowerCase()
                                  .contains(_textoBusqueda),
                            )
                            .toList();

                        if (pacientes.isEmpty) {
                          return Center(
                            child: Text(
                              _textoBusqueda.isEmpty
                                  ? '0 Pacientes'
                                  : 'No se encontraron pacientes',
                              style: TextStyle(
                                color: plomo,
                                fontFamily: regular,
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: pacientes.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 16),
                          itemBuilder: (contexto, indice) {
                            final paciente = pacientes[indice];
                            return _TarjetaPaciente(
                              paciente: paciente,
                              alTocar: () async {
                                final actualizado = await Navigator.push<bool>(
                                  contexto,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        PacienteDetalleView(paciente: paciente),
                                  ),
                                );
                                if (actualizado == true && mounted) {
                                  setState(_cargarPacientes);
                                }
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaPaciente extends StatelessWidget {
  const _TarjetaPaciente({required this.paciente, required this.alTocar});

  final Paciente paciente;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFE0E0E0),
      child: InkWell(
        onTap: alTocar,
        child: SizedBox(
          height: 72,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const SizedBox(
                  width: 40,
                  height: 40,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color(0xFFADADAD),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        paciente.nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF2E2E2E),
                          fontFamily: regular,
                          fontSize: 16,
                          height: 24 / 16,
                        ),
                      ),
                      /*
                      const SizedBox(height: 4),
                      Text(
                        '$sexo · $fecha',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF616161),
                          fontSize: 12,
                        ),
                      ),
                      */
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF616161),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
