import 'package:flutter/material.dart';
import '../models/dia.dart';
import '../models/repositories/search_availability_repository.dart';
import '../viewmodels/search_availability_viewmodel.dart';
 
class SearchAvailabilityScreen extends StatefulWidget {
  final String userId;
  final bool isOffline;
 
  const SearchAvailabilityScreen({
    super.key,
    required this.userId,
    required this.isOffline,
  });
 
  @override
  State<SearchAvailabilityScreen> createState() =>
      _SearchAvailabilityScreenState();
}
 
class _SearchAvailabilityScreenState extends State<SearchAvailabilityScreen> {
  final SearchAvailabilityViewModel _viewModel = SearchAvailabilityViewModel();
 
  static const night = Color(0xFF0A090C);
  static const white = Color(0xFFF0EDEE);
  static const currant = Color(0xFF2C666E);
 
  static const _days = [
    Dia.lunes,
    Dia.martes,
    Dia.miercoles,
    Dia.jueves,
    Dia.viernes,
  ];
 
  static const _dayLabels = {
    Dia.lunes: 'Mon',
    Dia.martes: 'Tue',
    Dia.miercoles: 'Wed',
    Dia.jueves: 'Thu',
    Dia.viernes: 'Fri',
  };
 
  Future<void> _pickTime({required bool isStart}) async {
    final initial = isStart
        ? (_viewModel.horaInicio ?? const TimeOfDay(hour: 8, minute: 0))
        : (_viewModel.horaFin ?? const TimeOfDay(hour: 10, minute: 0));
 
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      initialEntryMode: TimePickerEntryMode.inputOnly,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: currant,
              onPrimary: white,
              onSurface: night,
            ),
          ),
          child: child!,
        );
      },
    );
 
    if (picked != null) {
      if (isStart) {
        _viewModel.setHoraInicio(picked);
      } else {
        _viewModel.setHoraFin(picked);
      }
    }
  }
 
  void _onSearchPressed() {
    if (widget.isOffline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No internet connection'),
          backgroundColor: Colors.black,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    _viewModel.buscar(widget.userId);
  }
 
  String _formatTime(TimeOfDay? time) {
    if (time == null) return 'Select';
    final h = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final m = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
  }
 
  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: night, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: AnimatedBuilder(
        animation: _viewModel,
        builder: (context, _) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Search availability',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: night,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Find out which friends are available when you need them.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const _SectionLabel(label: 'Time range'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _TimePickerTile(
                          label: 'Start',
                          value: _formatTime(_viewModel.horaInicio),
                          onTap: () => _pickTime(isStart: true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _TimePickerTile(
                          label: 'End',
                          value: _formatTime(_viewModel.horaFin),
                          onTap: () => _pickTime(isStart: false),
                          hasError: _viewModel.horaError != null,
                        ),
                      ),
                    ],
                  ),
                  if (_viewModel.horaError != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            size: 14, color: Colors.redAccent),
                        const SizedBox(width: 4),
                        Text(
                          _viewModel.horaError!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 28),
                  const _SectionLabel(label: 'Day'),
                  const SizedBox(height: 12),
                  _DaySelector(
                    days: _days,
                    labels: _dayLabels,
                    selected: _viewModel.diaSeleccionado,
                    onSelect: _viewModel.setDia,
                  ),
                  const SizedBox(height: 32),
                  _SearchButton(
                    canSearch: _viewModel.canSearch && _viewModel.isHoraValida,
                    isLoading: _viewModel.isLoading,
                    onPressed: _onSearchPressed,
                  ),
                  if (_viewModel.errorMessage.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              size: 18, color: Colors.redAccent),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _viewModel.errorMessage,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.redAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (_viewModel.hasSearched && _viewModel.resultados != null) ...[
                    const SizedBox(height: 32),
                    _ResultsSection(resultados: _viewModel.resultados!),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
 
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});
 
  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF888888),
        letterSpacing: 0.5,
      ),
    );
  }
}
 
class _TimePickerTile extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  final bool hasError;
 
  const _TimePickerTile({
    required this.label,
    required this.value,
    required this.onTap,
    this.hasError = false,
  });
 
  static const night = Color(0xFF0A090C);
  static const currant = Color(0xFF2C666E);
 
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasError
                ? Colors.redAccent
                : value == 'Select'
                    ? const Color(0xFFDDDDDD)
                    : currant,
            width: hasError || value != 'Select' ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.access_time_rounded,
              size: 18,
              color: hasError ? Colors.redAccent : currant,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF888888),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: value == 'Select' ? const Color(0xFFBBBBBB) : night,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
 
class _DaySelector extends StatelessWidget {
  final List<Dia> days;
  final Map<Dia, String> labels;
  final Dia? selected;
  final ValueChanged<Dia> onSelect;
 
  const _DaySelector({
    required this.days,
    required this.labels,
    required this.selected,
    required this.onSelect,
  });
 
  static const currant = Color(0xFF2C666E);
  static const night = Color(0xFF0A090C);
 
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: days.map((dia) {
        final isSelected = selected == dia;
        return GestureDetector(
          onTap: () => onSelect(dia),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.only(right: 10),
            width: 52,
            height: 48,
            decoration: BoxDecoration(
              color: isSelected ? currant : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? currant : const Color(0xFFDDDDDD),
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: currant.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [],
            ),
            child: Center(
              child: Text(
                labels[dia]!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : night,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
 
class _SearchButton extends StatelessWidget {
  final bool canSearch;
  final bool isLoading;
  final VoidCallback onPressed;
 
  const _SearchButton({
    required this.canSearch,
    required this.isLoading,
    required this.onPressed,
  });
 
  static const currant = Color(0xFF2C666E);
  static const white = Color(0xFFF0EDEE);
 
  @override
  Widget build(BuildContext context) {
    final enabled = canSearch && !isLoading;
 
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: enabled ? 1.0 : 0.5,
        child: ElevatedButton(
          onPressed: enabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: currant,
            foregroundColor: white,
            disabledBackgroundColor: currant,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(white),
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_rounded, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Search',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
 
class _ResultsSection extends StatelessWidget {
  final List<AmigoDisponibilidad> resultados;
 
  const _ResultsSection({required this.resultados});
 
  static const night = Color(0xFF0A090C);
  static const currant = Color(0xFF2C666E);
 
  @override
  Widget build(BuildContext context) {
    final sorted = [
      ...resultados.where((a) => a.isLibre),
      ...resultados.where((a) => !a.isLibre),
    ];
    final disponibles = resultados.where((a) => a.isLibre).length;
 
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Results',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: night,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$disponibles available',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (sorted.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'No friends found for this time range.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          )
        else
          ...sorted.map((amigo) => _AmigoCard(amigo: amigo)),
      ],
    );
  }
}
 
class _AmigoCard extends StatelessWidget {
  final AmigoDisponibilidad amigo;
 
  const _AmigoCard({required this.amigo});
 
  static const night = Color(0xFF0A090C);
  static const currant = Color(0xFF2C666E);
 
  @override
  Widget build(BuildContext context) {
    final statusColor = amigo.isLibre ? Colors.green : Colors.redAccent;
 
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF0EDEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              amigo.username,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: night,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, size: 8, color: statusColor),
                const SizedBox(width: 5),
                Text(
                  amigo.isLibre ? 'Available' : 'Busy',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}