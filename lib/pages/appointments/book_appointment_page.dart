import 'package:flutter/material.dart';
import '../../models/appointment_model.dart';
import '../../services/appointment_service.dart';
class BookAppointmentPage extends StatefulWidget {
  const BookAppointmentPage({super.key});
  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}
class _BookAppointmentPageState extends State<BookAppointmentPage> {
  List<Department> _departments = [];
  List<WorkingDay> _workingDays = [];
  List<TimeSlot> _slots = [];
  Department? _selDept;
  WorkingDay? _selDay;
  TimeSlot? _selSlot;
  bool _initLoading = true;
  bool _slotsLoading = false;
  bool _submitting = false;
  static const Color _bg = Color(0xFF070E09);
  static const Color _card = Color(0xFF111D13);
  static const Color _surf2 = Color(0xFF162B1C);
  static const Color _green = Color(0xFF2D9B5A);
  static const Color _greenL = Color(0xFF3DBD71);
  static const Color _greenDim = Color(0xFF1A5C34);
  static const Color _gold = Color(0xFFC9A84C);
  static const Color _goldDim = Color(0xFF3D3010);
  static const Color _border = Color(0xFF1E3A24);
  static const Color _text1 = Color(0xFFF0F0F0);
  static const Color _text2 = Color(0xFFA8C4AF);
  static const Color _text3 = Color(0xFF5A7A62);
  static const Color _red = Color(0xFFE05252);
  @override
  void initState() {
    super.initState();
    _loadInitial();
  }
  Future<void> _loadInitial() async {
    final depts = await AppointmentService.getDepartments();
    final days = await AppointmentService.getWorkingDays();
    if (!mounted) return;
    setState(() {
      _departments = depts;
      _workingDays = days;
      _initLoading = false;
    });
  }
  Future<void> _loadSlots() async {
    if (_selDept == null || _selDay == null) return;
    setState(() {
      _slotsLoading = true;
      _slots = [];
      _selSlot = null;
    });
    final result = await AppointmentService.getAvailableSlots(
      departmentId: _selDept!.id,
      date: _selDay!.date,
    );
    if (!mounted) return;
    setState(() {
      _slotsLoading = false;
      if (result.success) {
        _slots = result.slots;
      }
    });
  }
  Future<void> _submit() async {
    if (_selDept == null || _selDay == null || _selSlot == null) return;
    setState(() => _submitting = true);
    final result = await AppointmentService.bookAppointment(
      departmentId: _selDept!.id,
      date: _selDay!.date,
      timeSlot: _selSlot!.time,
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (result.success && result.appointment != null) {
      _showSuccessDialog(result.appointment!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.message ?? 'Booking failed.',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: _red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: _initLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF2D9B5A),
                  strokeWidth: 2.5,
                ),
              )
            : Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          _buildLiveSummary(),
                          const SizedBox(height: 24),
                          _sectionTitle('1-Department'),
                          const SizedBox(height: 12),
                          _buildDepartments(),
                          const SizedBox(height: 24),
                          _sectionTitle('2-Date'),
                          const SizedBox(height: 12),
                          _buildDateRow(),
                          const SizedBox(height: 24),
                          _sectionTitle('3-Time Slot'),
                          const SizedBox(height: 12),
                          _buildTimeSlots(),
                          const SizedBox(height: 32),
                          _buildConfirmButton(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
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
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _surf2,
                borderRadius: BorderRadius.circular(13),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Book Appointment',
                style: TextStyle(
                  color: _text1,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                'Btormaz Municipality',
                style: TextStyle(
                  color: _text3,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _sectionTitle(String t) {
    return Text(
      t,
      style: const TextStyle(
        color: _text3,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
      ),
    );
  }
  Widget _buildLiveSummary() {
    final ready = _selDept != null && _selDay != null && _selSlot != null;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ready ? _greenDim : _surf2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ready ? _green : _border,
          width: ready ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'BOOKING SUMMARY',
                  style: TextStyle(
                    color: _greenL,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const Spacer(),
              if (ready)
                const Icon(
                  Icons.check_circle_rounded,
                  color: _greenL,
                  size: 18,
                ),
            ],
          ),
          const SizedBox(height: 14),
          _summaryRow(
            icon: _selDept?.icon ?? Icons.account_balance_rounded,
            label: 'Department',
            value: _selDept?.name ?? '—',
          ),
          _summaryRow(
            icon: Icons.calendar_month_rounded,
            label: 'Date',
            value: _selDay?.label ?? '—',
          ),
          _summaryRow(
            icon: Icons.schedule_rounded,
            label: 'Time',
            value: _selSlot?.displayTime ?? '—',
          ),
          if (!ready) ...[
            const SizedBox(height: 10),
            Text(
              _selDept == null
                  ? 'Select a department to get started'
                  : _selDay == null
                      ? 'Now pick a date'
                      : 'Choose an available time slot',
              style: const TextStyle(
                color: _text3,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
  Widget _summaryRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final hasVal = value != '—';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: hasVal ? _greenL : _text3,
            size: 16,
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 86,
            child: Text(
              label,
              style: const TextStyle(
                color: _text3,
                fontSize: 12.5,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: hasVal ? _text1 : _text3,
                fontSize: 13,
                fontWeight: hasVal ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildDepartments() {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _departments.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final d = _departments[i];
          final active = _selDept?.id == d.id;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selDept = d;
                _selSlot = null;
              });
              if (_selDay != null) _loadSlots();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 100,
              padding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 8,
              ),
              decoration: BoxDecoration(
                color: active ? _green : _card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: active ? _green : _border,
                  width: active ? 1.6 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    d.icon,
                    color: active ? _greenL : _text2,
                    size: 22,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    d.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: active ? _greenL : _text2,
                      fontSize: 10.5,
                      fontWeight:
                          active ? FontWeight.w700 : FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  Widget _buildDateRow() {
    return SizedBox(
      height: 74,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _workingDays.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final day = _workingDays[i];
          final active = _selDay?.date == day.date;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selDay = day;
                _selSlot = null;
              });
              if (_selDept != null) _loadSlots();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 62,
              decoration: BoxDecoration(
                color: active ? _green : _card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: active ? _green : _border,
                  width: active ? 1.6 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    day.shortDay,
                    style: TextStyle(
                      color: active ? _greenL : _text3,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    day.dayNum,
                    style: TextStyle(
                      color: active ? _text1 : _text2,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    day.monthShort,
                    style: TextStyle(
                      color: active ? _greenL : _text3,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  Widget _buildTimeSlots() {
    if (_selDept == null || _selDay == null) {
      return Container(
        height: 100,
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
        ),
        child: const Center(
          child: Text(
            'Select a department and date\nto see available slots.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _text3,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ),
      );
    }
    if (_slotsLoading) {
      return Container(
        height: 100,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(
          color: Color(0xFF2D9B5A),
          strokeWidth: 2,
        ),
      );
    }
    if (_slots.isEmpty) {
      return Container(
        height: 80,
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
        ),
        child: const Center(
          child: Text(
            'No slots available for this selection.',
            style: TextStyle(
              color: _text3,
              fontSize: 13,
            ),
          ),
        ),
      );
    }
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _slots.map((s) {
        final active = _selSlot?.time == s.time;
        final full = !s.available;
        return GestureDetector(
          onTap: full ? null : () => setState(() => _selSlot = s),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: (MediaQuery.of(context).size.width - 60) / 3,
            height: 52,
            decoration: BoxDecoration(
              color: full
                  ? _surf2
                  : active
                      ? _green
                      : _card,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: full
                    ? _border
                    : active
                        ? _green
                        : _border,
                width: active ? 1.6 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  s.displayTime,
                  style: TextStyle(
                    color: full
                        ? _text3
                        : active
                            ? _greenL
                            : _text1,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (active)
                      const Icon(
                        Icons.check_rounded,
                        color: _greenL,
                        size: 12,
                      ),
                    if (!active && !full)
                      ...List.generate(
                        s.capacity,
                        (i) => Container(
                          width: 5,
                          height: 5,
                          margin:
                              const EdgeInsets.symmetric(horizontal: 1.5),
                          decoration: BoxDecoration(
                            color: i < s.booked
                                ? _red
                                : _green,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    if (full)
                      Text(
                        'Full',
                        style: TextStyle(
                          color: _red,
                          fontSize: 10,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
  Widget _buildConfirmButton() {
    final ready = _selDept != null && _selDay != null && _selSlot != null;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: ready && !_submitting ? _submit : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _green,
          disabledBackgroundColor: _surf2,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _submitting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    ready
                        ? Icons.check_circle_outline_rounded
                        : Icons.lock_outline_rounded,
                    color: ready ? Colors.white : _text3,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    ready ? 'Confirm Booking' : 'Complete all selections',
                    style: TextStyle(
                      color: ready ? Colors.white : _text3,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
  void _showSuccessDialog(Appointment a) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: _greenDim,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _green,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: _greenL,
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Booked!',
                style: TextStyle(
                  color: _text1,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Your appointment is confirmed.',
                style: TextStyle(
                  color: _text3,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                decoration: BoxDecoration(
                  color: _goldDim,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _gold,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.confirmation_number_rounded,
                      color: _gold,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Queue Number',
                          style: TextStyle(
                            color: _gold,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          '#${a.queueNumber}',
                          style: const TextStyle(
                            color: _gold,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _dialogRow(
                icon: Icons.account_balance_rounded,
                value: a.departmentName,
              ),
              _dialogRow(
                icon: Icons.calendar_month_rounded,
                value: a.formattedDate,
              ),
              _dialogRow(
                icon: Icons.schedule_rounded,
                value: a.displayTime,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _dialogRow({
    required IconData icon,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: _surf2,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: _greenL,
              size: 16,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  color: _text1,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}