import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/models/profile_modal.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/services/profile_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  static const Color _bg = Color(0xFF060E08);
  static const Color _card = Color(0xFF111D13);
  static const Color _surf2 = Color(0xFF162B1C);
  static const Color _green = Color(0xFF2D9B5A);
  static const Color _greenL = Color(0xFF3DBD71);
  static const Color _greenDim = Color(0xFF0F2E18);
  static const Color _gold = Color(0xFFC9A84C);
  static const Color _blue = Color(0xFF4A8FD9);
  static const Color _red = Color(0xFFE05252);
  static const Color _border = Color(0xFF1E3A24);
  static const Color _text1 = Color(0xFFF0F5F1);
  static const Color _text2 = Color(0xFFA8C4AF);
  static const Color _text3 = Color(0xFF5A7A62);

  CitizenProfile? profile;
  CitizenStats? stats;
  bool loading = true;
  String? error;

  late AnimationController animCtrl;
  late Animation<double> fadeAnim;
  late Animation<Offset> slideAnim;

  @override
  void initState() {
    super.initState();
    animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    fadeAnim = CurvedAnimation(parent: animCtrl, curve: Curves.easeOut);
    slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: animCtrl, curve: Curves.easeOut),
    );
    load();
  }

  @override
  void dispose() {
    animCtrl.dispose();
    super.dispose();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });

    final result = await ProfileService.getProfile();

    if (!mounted) return;

    setState(() {
      loading = false;
      if (result.success) {
        profile = result.profile;
        stats = result.stats;
        animCtrl.forward(from: 0);
      } else {
        error = result.error ?? 'Failed to load profile';
      }
    });
  }

  Future<void> logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: _border),
        ),
        title: const Text(
          'Sign out',
          style: TextStyle(color: _text1, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: _text2, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: _green, fontWeight: FontWeight.w700),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Sign out',
              style: TextStyle(color: _red, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    await AuthService.logout();
    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  void openChangePassword() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ChangePasswordSheet(),
    );
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
      body: loading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF2D9B5A),
                strokeWidth: 2.5,
              ),
            )
          : error != null
              ? buildError()
              : SafeArea(
                  child: FadeTransition(
                    opacity: fadeAnim,
                    child: SlideTransition(
                      position: slideAnim,
                      child: RefreshIndicator(
                        color: _green,
                        backgroundColor: _card,
                        onRefresh: load,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            children: [
                              buildHeader(),
                              buildAvatarSection(),
                              buildStatsRow(),
                              buildInfoSection(),
                              buildActivitySection(),
                              buildSettingSection(),
                              buildLogoutButton(),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget buildHeader() {
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
          const Expanded(
            child: Text(
              'Profile',
              style: TextStyle(
                color: _text1,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          GestureDetector(
            onTap: load,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _surf2,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: _border),
              ),
              child: const Icon(
                Icons.refresh_rounded,
                color: _text2,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAvatarSection() {
    final p = profile!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_greenDim, _card],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _green),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 20,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF2D9B5A), Color(0xFF1A5C34)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 18,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      p.initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
                if (p.isVerified)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: _greenL,
                        shape: BoxShape.circle,
                        border: Border.all(color: _green, width: 2),
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.fullName,
                    style: const TextStyle(
                      color: _text1,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.phone_rounded,
                        color: _text3,
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        p.phone,
                        style: const TextStyle(
                          color: _text2,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  if ((p.zone ?? '').isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _green,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _green),
                      ),
                      child: Text(
                        p.zone!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    'Member since ${p.memberSince}',
                    style: const TextStyle(
                      color: _text3,
                      fontSize: 11.5,
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

  Widget buildStatsRow() {
    final s = stats!;
    final items = [
      {'value': '${s.totalRequests}', 'label': 'Requests', 'color': _blue},
      {'value': '${s.totalIssues}', 'label': 'Issues', 'color': _gold},
      {'value': '${s.totalProposals}', 'label': 'Proposals', 'color': _greenL},
      {'value': '${s.totalVotes}', 'label': 'Votes', 'color': _text2},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: items.asMap().entries.map((e) {
          final i = e.key;
          final d = e.value;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i < items.length - 1 ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _border),
              ),
              child: Column(
                children: [
                  Text(
                    d['value'] as String,
                    style: TextStyle(
                      color: d['color'] as Color,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    d['label'] as String,
                    style: const TextStyle(
                      color: _text3,
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget buildInfoSection() {
    final p = profile!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            infoTile(
              icon: Icons.person_rounded,
              label: 'Full Name',
              value: p.fullName,
              color: _greenL,
            ),
            divider(),
            infoTile(
              icon: Icons.phone_rounded,
              label: 'Phone Number',
              value: p.phone,
              color: _blue,
            ),
            if ((p.dateOfBirth ?? '').isNotEmpty) ...[
              divider(),
              infoTile(
                icon: Icons.cake_rounded,
                label: 'Date of Birth',
                value: formatDate(p.dateOfBirth!),
                color: _gold,
              ),
            ],
            divider(),
            infoTile(
              icon: Icons.location_on_rounded,
              label: 'Residential Zone',
              value: (p.zone ?? '').isNotEmpty ? p.zone! : '-',
              value2: (p.zoneDesc ?? '').isNotEmpty ? p.zoneDesc : null,
              color: _greenL,
            ),
            divider(),
            infoTile(
              icon: Icons.verified_rounded,
              label: 'Account Status',
              value: p.isVerified ? 'Verified' : 'Not Verified',
              color: p.isVerified ? _greenL : _gold,
              valueColor: p.isVerified ? _greenL : _gold,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildActivitySection() {
    final s = stats!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sectionLabel('Activity Overview'),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _border),
            ),
            child: Column(
              children: [
                activityTile(
                  icon: Icons.description_rounded,
                  label: 'Document Requests',
                  total: s.totalRequests,
                  done: s.resolvedRequests,
                  color: _blue,
                ),
                divider(),
                activityTile(
                  icon: Icons.warning_amber_rounded,
                  label: 'Issues Reported',
                  total: s.totalIssues,
                  done: s.resolvedIssues,
                  color: _gold,
                ),
                divider(),
                activityTile(
                  icon: Icons.calendar_today_rounded,
                  label: 'Appointments',
                  total: s.totalAppointments,
                  done: s.totalAppointments,
                  color: _greenL,
                  showBar: false,
                ),
                divider(),
                activityTile(
                  icon: Icons.lightbulb_rounded,
                  label: 'Proposals Submitted',
                  total: s.totalProposals,
                  done: s.totalProposals,
                  color: const Color(0xFF9B8EA8),
                  showBar: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSettingSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sectionLabel('Account Settings'),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _border),
            ),
            child: Column(
              children: [
                settingsTile(
                  icon: Icons.lock_rounded,
                  label: 'Change Password',
                  color: _greenL,
                  onTap: openChangePassword,
                ),
                divider(),
                settingsTile(
                  icon: Icons.notifications_rounded,
                  label: 'Notifications',
                  color: _gold,
                  onTap: () => Navigator.pushNamed(context, '/notifications'),
                ),
                divider(),
                settingsTile(
                  icon: Icons.info_outline_rounded,
                  label: 'About Btormaz',
                  color: _blue,
                  onTap: () => Navigator.pushNamed(context, '/info'),
                ),
                divider(),
                settingsTile(
                  icon: Icons.smart_toy_rounded,
                  label: 'AI Assistant',
                  color: const Color(0xFF9B8EA8),
                  onTap: () => Navigator.pushNamed(context, '/chat'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: GestureDetector(
        onTap: logout,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: _red,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _red),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.logout_rounded,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 10),
              Text(
                'Sign Out',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              color: _text3,
              size: 52,
            ),
            const SizedBox(height: 16),
            Text(
              error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _text2,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: load,
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
      ),
    );
  }

  Widget sectionLabel(String t) => Text(
        t,
        style: const TextStyle(
          color: _text3,
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.3,
        ),
      );

  Widget divider() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(height: 1, color: _border),
      );

  Widget infoTile({
    required IconData icon,
    required String label,
    required String value,
    String? value2,
    required Color color,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: _text3,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(
                    color: valueColor ?? _text1,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (value2 != null && value2.isNotEmpty)
                  Text(
                    value2,
                    style: const TextStyle(
                      color: _text3,
                      fontSize: 11.5,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      const m = [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${m[dt.month]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  Widget activityTile({
    required IconData icon,
    required String label,
    required int total,
    required int done,
    required Color color,
    bool showBar = true,
  }) {
    final pct = total == 0 ? 0.0 : done / total;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: color, size: 19),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: _text1,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      showBar ? '$done of $total completed' : '$total total',
                      style: const TextStyle(
                        color: _text3,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (showBar && total > 0) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 5,
                backgroundColor: _surf2,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget settingsTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: color, size: 19),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: _text1,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: _text3,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class ChangePasswordSheet extends StatefulWidget {
  const ChangePasswordSheet({super.key});

  @override
  State<ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<ChangePasswordSheet> {
  static const Color _surf2 = Color(0xFF162B1C);
  static const Color _green = Color(0xFF2D9B5A);
  static const Color _greenL = Color(0xFF3DBD71);
  static const Color _border = Color(0xFF1E3A24);
  static const Color _text1 = Color(0xFFF0F5F1);
  static const Color _text3 = Color(0xFF5A7A62);
  static const Color _red = Color(0xFFE05252);

  final formKey = GlobalKey<FormState>();
  final currentCtrl = TextEditingController();
  final newCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  bool obscureCurrent = true;
  bool obscureNew = true;
  bool obscureConfirm = true;
  bool submitting = false;
  double strength = 0;

  @override
  void initState() {
    super.initState();
    newCtrl.addListener(calcStrength);
  }

  @override
  void dispose() {
    currentCtrl.dispose();
    newCtrl.dispose();
    confirmCtrl.dispose();
    super.dispose();
  }

  void calcStrength() {
    final n = newCtrl.text;
    double s = 0;
    if (n.length >= 6) s += 0.25;
    if (n.length >= 10) s += 0.15;
    if (RegExp(r'[A-Z]').hasMatch(n)) s += 0.2;
    if (RegExp(r'[0-9]').hasMatch(n)) s += 0.2;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(n)) s += 0.2;
    setState(() => strength = s.clamp(0.0, 1.0));
  }

  Color get strengthColor {
    if (strength < 0.35) return _red;
    if (strength < 0.65) return const Color(0xFFC9A84C);
    return _greenL;
  }

  String get strengthLabel {
    if (strength == 0) return '';
    if (strength < 0.35) return 'Weak';
    if (strength < 0.65) return 'Fair';
    if (strength < 0.85) return 'Good';
    return 'Strong';
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => submitting = true);

    final result = await ProfileService.changePassword(
      current: currentCtrl.text,
      newPassword: newCtrl.text,
      confirmPassword: confirmCtrl.text,
    );

    if (!mounted) return;

    setState(() => submitting = false);

    if (result.success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white),
              SizedBox(width: 10),
              Text(
                'Password changed successfully!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          backgroundColor: _green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  result.message ?? 'Failed to change password',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
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
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 0, 24, bottom + 24),
      decoration: const BoxDecoration(
        color: Color(0xFF0E1A10),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: _border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: _green,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.lock_outline,
                    color: _greenL,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Change Password',
                      style: TextStyle(
                        color: _text1,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Keep your account secure',
                      style: TextStyle(
                        color: _text3,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            passField(
              'Current Password',
              currentCtrl,
              obscureCurrent,
              () => setState(() => obscureCurrent = !obscureCurrent),
              (v) {
                if (v == null || v.isEmpty) {
                  return 'Enter current password';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            passField(
              'New Password',
              newCtrl,
              obscureNew,
              () => setState(() => obscureNew = !obscureNew),
              (v) {
                if (v == null || v.isEmpty) return 'Enter new password';
                if (v.length < 6) return 'At least 6 characters';
                return null;
              },
            ),
            if (strength > 0) ...[
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: strength,
                  backgroundColor: _surf2,
                  minHeight: 4,
                  valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                strengthLabel,
                style: TextStyle(
                  color: strengthColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 14),
            passField(
              'Confirm New Password',
              confirmCtrl,
              obscureConfirm,
              () => setState(() => obscureConfirm = !obscureConfirm),
              (v) {
                if (v == null || v.isEmpty) {
                  return 'Confirm your new password';
                }
                if (v != newCtrl.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: submitting ? null : submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  disabledBackgroundColor: _green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: submitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Update Password',
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
    );
  }

  Widget passField(
    String label,
    TextEditingController ctrl,
    bool obscure,
    VoidCallback toggle,
    String? Function(String?)? validator,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: _green,
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          obscureText: obscure,
          style: const TextStyle(color: _text1, fontSize: 15),
          validator: validator,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle: const TextStyle(color: _text3),
            prefixIcon: const Icon(
              Icons.lock_outline_rounded,
              color: _text3,
              size: 18,
            ),
            suffixIcon: GestureDetector(
              onTap: toggle,
              child: Icon(
                obscure
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: _text3,
                size: 18,
              ),
            ),
            filled: true,
            fillColor: _surf2,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: _green, width: 1.6),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: _red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: _red, width: 1.6),
            ),
            errorStyle: const TextStyle(color: _red, fontSize: 12),
          ),
        ),
      ],
    );
  }
}