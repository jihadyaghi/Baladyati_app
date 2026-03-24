// lib/screens/appointments/appointments_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/appointment_model.dart';
import '../../services/appointment_service.dart';
import 'book_appointment_page.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage>
    with SingleTickerProviderStateMixin {
  List<Appointment> _all = [];
  bool _loading = true;
  String? _error;
  late TabController _tabCtrl;

  static const Color _bg = Color(0xFF070E09);
  static const Color _surface = Color(0xFF111A13);
  static const Color _surf2 = Color(0xFF162B1C);
  static const Color _green = Color(0xFF2D9B5A);
  static const Color _greenL = Color(0xFF3DBD71);
  static const Color _gold = Color(0xFFC9A84C);
  static const Color _border = Color(0xFF1E3A24);
  static const Color _text1 = Color(0xFFF0F0F0);
  static const Color _text2 = Color(0xFFA8C4AF);
  static const Color _text3 = Color(0xFF5A7A62);
  static const Color _red = Color(0xFFE05252);

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await AppointmentService.getMyAppointments();
    if (!mounted) return;

    setState(() {
      _loading = false;
      if (result.success) {
        _all = result.appointments;
      } else {
        _error = result.errorMessage;
      }
    });
  }
  List<Appointment> get _upcoming =>
      _all.where((a) => a.status == AppointmentStatus.pending).toList();
  List<Appointment> get _past => _all.where((a) {
        return a.status == AppointmentStatus.served ||
            a.status == AppointmentStatus.cancelled;
      }).toList();
  Future<void> _cancel(Appointment a) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: const Text(
          'Cancel Appointment',
          style: TextStyle(
            color: _text1,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          'Cancel your appointment at ${a.departmentName} on ${a.formattedDate} at ${a.displayTime}?',
          style: const TextStyle(
            color: _text2,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Keep',
              style: TextStyle(
                color: _greenL,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: _red,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final result = await AppointmentService.cancelAppointment(a.id);
    if (!mounted) return;

    if (result.success) {
      await _load();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Appointment cancelled.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFF5A7A62),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.message ?? 'Could not cancel.',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: _red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            if (!_loading && _error == null) _buildTabs(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _surf2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _border),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: _text2,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Appointments',
                  style: TextStyle(
                    color: _text1,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '${_upcoming.length} upcoming',
                  style: const TextStyle(
                    color: _text3,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _load,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _surf2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _border),
              ),
              child: const Icon(
                Icons.refresh_rounded,
                color: _text2,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border),
        ),
        child: TabBar(
          controller: _tabCtrl,
          indicator: BoxDecoration(
            color: _green,
            borderRadius: BorderRadius.circular(10),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: Colors.white,
          unselectedLabelColor: _text3,
          labelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
          dividerColor: Colors.transparent,
          tabs: [
            Tab(text: 'Upcoming (${_upcoming.length})'),
            Tab(text: 'Past (${_past.length})'),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF2D9B5A),
          strokeWidth: 2.5,
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              color: _text3,
              size: 48,
            ),
            const SizedBox(height: 14),
            Text(
              _error!,
              style: const TextStyle(
                color: _text2,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _load,
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return TabBarView(
      controller: _tabCtrl,
      children: [
        _buildList(_upcoming, upcoming: true),
        _buildList(_past, upcoming: false),
      ],
    );
  }

  Widget _buildList(List<Appointment> items, {required bool upcoming}) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                upcoming
                    ? Icons.calendar_month_rounded
                    : Icons.event_note_rounded,
                color: _text3,
                size: 52,
              ),
              const SizedBox(height: 16),
              Text(
                upcoming
                    ? 'No upcoming appointments'
                    : 'No past appointments',
                style: const TextStyle(
                  color: _text1,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                upcoming
                    ? 'Tap the + button to book an appointment.'
                    : 'Completed and cancelled appointments appear here.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _text3,
                  fontSize: 13.5,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: _green,
      backgroundColor: _surface,
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 100),
        itemCount: items.length,
        itemBuilder: (_, i) => _buildCard(items[i]),
      ),
    );
  }

  Widget _buildCard(Appointment a) {
    final canCancel = a.status == AppointmentStatus.pending;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: canCancel ? _green.withOpacity(0.35) : _border,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: a.status.bgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Icon(
                      _deptIcon(a.departmentName),
                      color: a.status.color,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a.departmentName,
                        style: const TextStyle(
                          color: _text1,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            color: _text3,
                            size: 13,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            a.formattedDate,
                            style: const TextStyle(
                              color: _text2,
                              fontSize: 12.5,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.access_time_rounded,
                            color: _text3,
                            size: 13,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            a.displayTime,
                            style: const TextStyle(
                              color: _text2,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: a.status.bgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    a.status.label,
                    style: TextStyle(
                      color: a.status.color,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            decoration: BoxDecoration(
              color: _surf2,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(17),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _gold.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _gold.withOpacity(0.35),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.confirmation_number_rounded,
                        color: _gold,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Queue #${a.queueNumber}',
                        style: const TextStyle(
                          color: _gold,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (canCancel)
                  GestureDetector(
                    onTap: () => _cancel(a),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: _red.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(
                          color: _red.withOpacity(0.35),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: _red,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _deptIcon(String name) {
    final n = name.toLowerCase();

    if (n.contains('civil')) return Icons.badge_rounded;
    if (n.contains('permit')) return Icons.description_rounded;
    if (n.contains('finance')) return Icons.account_balance_wallet_rounded;
    if (n.contains('health')) return Icons.local_hospital_rounded;
    if (n.contains('plan')) return Icons.map_rounded;
    if (n.contains('social')) return Icons.groups_rounded;
    if (n.contains('building')) return Icons.apartment_rounded;
    if (n.contains('engineering')) return Icons.engineering_rounded;

    return Icons.account_balance_rounded;
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () async {
        final booked = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => const BookAppointmentPage(),
          ),
        );

        if (booked == true) {
          _tabCtrl.animateTo(0);
          await _load();
        }
      },
      backgroundColor: _green,
      icon: const Icon(
        Icons.add_rounded,
        color: Colors.white,
      ),
      label: const Text(
        'Book',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}