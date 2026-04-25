import 'package:flutter/material.dart';
import '../models/dia.dart';
import '../viewmodels/schedule_viewmodel.dart';
import 'app_nav.dart';

class CalendarView extends StatefulWidget {
  final ScheduleViewModel viewModel;
  final Widget? floatingActionButton;
  final String userId;
  final String title;
  final bool showBottomNav;
  final int navCurrentIndex;
  final ValueChanged<int>? onNavTap;

  const CalendarView({
    super.key,
    required this.viewModel,
    this.floatingActionButton,
    required this.userId,
    this.title = 'My Schedule',
    this.showBottomNav = true,
    this.navCurrentIndex = 0,
    this.onNavTap,
  });

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  static const List<Dia> _dias = [
    Dia.lunes, Dia.martes, Dia.miercoles, Dia.jueves, Dia.viernes,
  ];
  static const List<String> _diasLabels = [
    'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THRUSDAY', 'FRIDAY',
  ];
  static const int _startHour = 6;
  static const int _endHour = 18;
  static const double _hourHeight = 60.0;
  static const double _timeColumnWidth = 55.0;

  @override
  void initState() {
    super.initState();
    widget.viewModel.loadSchedule();
  }

  @override
  Widget build(BuildContext context) {
    const night = Color(0xFF0A090C);
    const white = Color(0xFFF0EDEE);

    return AnimatedBuilder(
      animation: widget.viewModel,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: white,
          appBar: AppBar(
            backgroundColor: white,
            elevation: 0,
            centerTitle: false,
            title: Text(
              widget.title,
              style: const TextStyle(
                color: night,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: widget.viewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : widget.viewModel.errorMessage.isNotEmpty
                  ? Center(child: Text(widget.viewModel.errorMessage))
                  : Column(
                      children: [
                        if (widget.viewModel.isOffline)
                          Container(
                            width: double.infinity,
                            color: const Color(0xFF2C666E),
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: const Text(
                              'Sin conexión — mostrando datos guardados',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFFF0EDEE),
                                fontSize: 12,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          ),
                        Expanded(child: _buildCalendar()),
                      ],
                    ),
          floatingActionButton: widget.floatingActionButton,
          bottomNavigationBar: widget.showBottomNav
            ? AppBottomNav(
                currentIndex: widget.navCurrentIndex,
                onTap: widget.onNavTap,
              )
            : null,
        );
      },
    );
  }

  Widget _buildCalendar() {
    return Column(
      children: [
        if (widget.viewModel.isUsingCachedData) _buildCachedDataBanner(),
        if (widget.viewModel.insightMessage.isNotEmpty) _buildInsightCard(),
        _buildDayHeaders(),
        Expanded(
          child: SingleChildScrollView(
            child: _buildGrid(),
          ),
        ),
      ],
    );
  }
  Widget _buildBody() {
    if (widget.viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.viewModel.errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                size: 44,
                color: Color(0xFF2C666E),
              ),
              const SizedBox(height: 12),
              Text(
                widget.viewModel.errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF0A090C),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => widget.viewModel.loadSchedule(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

  return _buildCalendar();
}

Widget _buildCachedDataBanner() {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFF90DDF0).withValues(alpha: 0.25),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: const Color(0xFF2C666E).withValues(alpha: 0.35),
      ),
    ),
    child: const Row(
      children: [
        Icon(
          Icons.cloud_off_rounded,
          color: Color(0xFF2C666E),
          size: 18,
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            'Showing saved data. Remote refresh was not available.',
            style: TextStyle(
              color: Color(0xFF07393C),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildInsightCard() {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.lightbulb_outline_rounded,
          color: Color(0xFF2C666E),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            widget.viewModel.insightMessage,
            style: const TextStyle(
              color: Color(0xFF0A090C),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}
  Widget _buildDayHeaders() {
    const night = Color(0xFF0A090C);
    return Row(
      children: [
        SizedBox(width: _timeColumnWidth),
        ...List.generate(_dias.length, (i) {
          return Expanded(
            child: Center(
              child: Text(
                _diasLabels[i],
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: night,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildGrid() {
    int dynamicEndHour = _endHour;
    for (final materia in widget.viewModel.materias) {
      for (final horaFin in materia.horaFin) {
        final hour = (horaFin ~/ 100) + 1;
        if (hour > dynamicEndHour) dynamicEndHour = hour;
      }
    }
    final totalHours = dynamicEndHour - _startHour;
    const night = Color(0xFF0A090C);

    return SizedBox(
      height: totalHours * _hourHeight,
      child: Stack(
        children: [
          ...List.generate(totalHours, (i) {
            final hour = _startHour + i;
            return Positioned(
              top: i * _hourHeight,
              left: 0,
              right: 0,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: _timeColumnWidth,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Text(
                        '${hour.toString().padLeft(2, '0')}:00',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 11,
                          color: night.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: night.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            );
          }),

          ..._buildMateriaBlocks(),
        ],
      ),
    );
  }

  List<Widget> _buildMateriaBlocks() {
    final blocks = <Widget>[];
    final columnWidth =
        (MediaQuery.of(context).size.width - _timeColumnWidth) / _dias.length;

    for (final materia in widget.viewModel.materias) {
      for (int i = 0; i < materia.dias.length; i++) {
        final diaIndex = _dias.indexOf(materia.dias[i]);
        if (diaIndex == -1) continue;

        final startHHMM = materia.horaInicio[i];
        final endHHMM = materia.horaFin[i];

        final startHour = startHHMM ~/ 100;
        final startMin = startHHMM % 100;
        final endHour = endHHMM ~/ 100;
        final endMin = endHHMM % 100;

        final topOffset =
            ((startHour - _startHour) + startMin / 60.0) * _hourHeight;
        final blockHeight =
            ((endHour - startHour) + (endMin - startMin) / 60.0) * _hourHeight;

        final leftOffset = _timeColumnWidth + diaIndex * columnWidth;

        Color blockColor;
        try {
          blockColor = Color(
            int.parse(materia.color.replaceFirst('#', '0xFF')),
          );
        } catch (_) {
          blockColor = const Color(0xFF2C666E);
        }

        blocks.add(
          Positioned(
            top: topOffset,
            left: leftOffset + 1,
            width: columnWidth - 2,
            height: blockHeight,
            child: Container(
              decoration: BoxDecoration(
                color: blockColor.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.all(4),
              child: Text(
                materia.nombre,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
              ),
            ),
          ),
        );
      }
    }

    return blocks;
  }
}