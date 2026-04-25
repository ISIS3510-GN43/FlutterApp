import 'dart:convert';
import 'package:app_flutter/models/dia.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config/constants.dart';
import '../models/materia.dart';
import '../models/usuario.dart';

class NrcScreen extends StatefulWidget {
  final String userId;
  final String horarioId;

  const NrcScreen({super.key, required this.userId, required this.horarioId});

  @override
  State<NrcScreen> createState() => _NrcScreenState();
}

class _NrcScreenState extends State<NrcScreen> {
  final TextEditingController _nrcController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';
  Materia? _materia;

  Future<void> _search() async {
    final nrc = _nrcController.text.trim();
    if (nrc.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _materia = null;
    });

    try {
      final uri = Uri.parse(
        '${Config.baseUrl}/horarios/clasesNRC/${widget.userId}/${widget.horarioId}/$nrc',
      );
      final body = jsonEncode({'color': '2C666E'});
      debugPrint('URL: $uri');
      debugPrint('HorarioId: ${widget.horarioId}');
      debugPrint('UserId: ${widget.userId}');
      debugPrint('Body: $body');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: body,
      );
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Response: ${response.body}');

      if (response.statusCode == 200) {
        final usuario = Usuario.fromJson(jsonDecode(response.body));
        final horario = usuario.horarios.firstWhere(
          (h) => h.id == widget.horarioId,
        );
        setState(() => _materia = horario.clases.last);
      } else {
        setState(() => _errorMessage = response.body);
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error de conexión: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatHour(int h) {
    final str = h.toString().padLeft(4, '0');
    return '${str.substring(0, 2)}:${str.substring(2)}';
  }

  @override
  void dispose() {
    _nrcController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0EDEE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0EDEE),
        elevation: 0,
        foregroundColor: const Color(0xFF0A090C),
        title: const Text(
          'Agregar por NRC',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nrcController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'Código NRC',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _search,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF07393C),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Search'),
            ),
            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            ],
            if (_materia != null) ...[
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              _InfoField(label: 'Materia', value: _materia!.nombre),
              const SizedBox(height: 12),
              ..._materia!.dias.asMap().entries.map((entry) {
                final i = entry.key;
                final dia = entry.value.name[0].toUpperCase() + entry.value.name.substring(1);
                final aula = _materia!.aula.length > i ? _materia!.aula[i] : '';
                final inicio = _materia!.horaInicio.length > i ? _formatHour(_materia!.horaInicio[i]) : '';
                final fin = _materia!.horaFin.length > i ? _formatHour(_materia!.horaFin[i]) : '';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _InfoField(
                    label: dia,
                    value: '$inicio – $fin  |  $aula',
                  ),
                );
              }),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF07393C),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Ir al horario'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoField extends StatelessWidget {
  final String label;
  final String value;

  const _InfoField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: true,
      controller: TextEditingController(text: value),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Color(0xFF07393C),
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.bold,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
