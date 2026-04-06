// lib/screens/info/municipality_info_page.dart
//
// Baladiyati — Municipality Info Page
// Dark premium theme · Gold / Green accents · Fully scrollable
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MunicipalityInfoPage extends StatefulWidget {
  const MunicipalityInfoPage({super.key});

  @override
  State<MunicipalityInfoPage> createState() => _MunicipalityInfoPageState();
}

class _MunicipalityInfoPageState extends State<MunicipalityInfoPage>
    with SingleTickerProviderStateMixin {
  // ── Palette ────────────────────────────────────────────────────────────────
  static const Color _bg = Color(0xFF060E08);
  static const Color _surface = Color(0xFF0E1A10);
  static const Color _card = Color(0xFF111D13);
  static const Color _surf2 = Color(0xFF162B1C);
  static const Color _green = Color(0xFF2D9B5A);
  static const Color _greenL = Color(0xFF3DBD71);
  static const Color _gold = Color(0xFFC9A84C);
  static const Color _goldDim = Color(0xFF3A2E0A);
  static const Color _blue = Color(0xFF4A8FD9);
  static const Color _border = Color(0xFF1E3A24);
  static const Color _text1 = Color(0xFFF0F5F1);
  static const Color _text2 = Color(0xFFA8C4AF);
  static const Color _text3 = Color(0xFF5A7A62);

  // ── Animation ──────────────────────────────────────────────────────────────
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  final ScrollController _scrollCtrl = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();

    _scrollCtrl.addListener(() {
      setState(() => _scrollOffset = _scrollCtrl.offset);
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _gold,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _green,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: CustomScrollView(
                  controller: _scrollCtrl,
                  slivers: [
                    SliverToBoxAdapter(child: _buildHeader()),
                    SliverToBoxAdapter(child: _buildVillageImage()),
                    SliverToBoxAdapter(child: _buildStatsBanner()),
                    SliverToBoxAdapter(child: _buildAboutSection()),
                    SliverToBoxAdapter(child: _buildServicesSection()),
                    SliverToBoxAdapter(child: _buildContactSection()),
                    SliverToBoxAdapter(child: _buildVisionSection()),
                    const SliverToBoxAdapter(child: SizedBox(height: 48)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'About Btormaz',
                  style: TextStyle(
                    color: _text1,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Municipality of Btormaz — الضنية',
                  style: TextStyle(color: _text3, fontSize: 12.5),
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _goldDim,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: _gold),
            ),
            child: const Center(
              child: Icon(
                Icons.account_balance_rounded,
                color: _gold,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Village image ──────────────────────────────────────────────────────────
  Widget _buildVillageImage() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
      child: Container(
        height: 210,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _border),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0D2B16),
                    Color(0xFF1A4A28),
                    Color(0xFF0A3520),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Opacity(
              opacity: 0.06,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                ),
                itemCount: 80,
                itemBuilder: (_, __) => Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _greenL,
                  ),
                ),
              ),
            ),

            // لاحقاً استبدلها بصورة حقيقية:
            // Image.asset('assets/images/bterram.jpg', fit: BoxFit.cover)

            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            'بطرماز',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'Btormaz Village · الضنية',
                            style: TextStyle(
                              color: _text2,
                              fontSize: 12.5,
                            ),
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
                        color: _gold,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _gold,
                        ),
                      ),
                      child: const Text(
                        'North Lebanon',
                        style: TextStyle(
                          color: _gold,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.landscape_rounded,
                    color: _greenL,
                    size: 52,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Village Photo',
                    style: TextStyle(
                      color: _text3,
                      fontSize: 13,
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

  // ── Quick stats banner ─────────────────────────────────────────────────────
  Widget _buildStatsBanner() {
    final stats = [
      {
        'value': '~8,000',
        'label': 'Citizens',
        'icon': Icons.people_rounded,
        'color': _greenL,
      },
      {
        'value': '3',
        'label': 'Zones',
        'icon': Icons.map_rounded,
        'color': _gold,
      },
      {
        'value': '1962',
        'label': 'Est. Year',
        'icon': Icons.calendar_month_rounded,
        'color': _blue,
      },
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: stats.asMap().entries.map((e) {
          final i = e.key;
          final s = e.value;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i < stats.length - 1 ? 10 : 0),
              padding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 8,
              ),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _border),
              ),
              child: Column(
                children: [
                  Icon(
                    s['icon'] as IconData,
                    color: s['color'] as Color,
                    size: 18,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    s['value'] as String,
                    style: TextStyle(
                      color: s['color'] as Color,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    s['label'] as String,
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

  // ── About section ──────────────────────────────────────────────────────────
  Widget _buildAboutSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            icon: Icons.eco_rounded,
            title: 'About the Village',
            subtitle: 'History & Identity',
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoTag(
                  icon: Icons.location_on_rounded,
                  text: 'Dinniyeh District · North Lebanon',
                ),
                const SizedBox(height: 16),
                const Text(
                  'Btormaz (بطرماز) is a beautiful mountainous village located in the Dinniyeh District of North Lebanon. Nestled among the mountains at an elevation that offers breathtaking views, the village is known for its natural scenery, warm community spirit, and rich agricultural heritage.',
                  style: TextStyle(
                    color: _text2,
                    fontSize: 14,
                    height: 1.7,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'The village is home to a close-knit community of families who have maintained strong ties to their land and traditions across generations. Agriculture, particularly fruit orchards and olive groves, forms an important part of the local economy and way of life.',
                  style: TextStyle(
                    color: _text2,
                    fontSize: 14,
                    height: 1.7,
                  ),
                ),
                const SizedBox(height: 18),
                Container(height: 1, color: _border),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _locationChip(
                      Icons.landscape_rounded,
                      'Mountain Village',
                    ),
                    const SizedBox(width: 10),
                    _locationChip(
                      Icons.forest_rounded,
                      'Lush Nature',
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _locationChip(
                      Icons.groups_rounded,
                      'Tight-knit Community',
                    ),
                    const SizedBox(width: 10),
                    _locationChip(
                      Icons.agriculture_rounded,
                      'Agricultural Heritage',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTag({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _surf2,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _greenL, size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: _text2,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _locationChip(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: _surf2,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            Icon(icon, color: _greenL, size: 15),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _text2,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Services section ───────────────────────────────────────────────────────
  Widget _buildServicesSection() {
    final services = [
      {
        'icon': Icons.construction_rounded,
        'title': 'Road Maintenance',
        'desc':
            'Repair and upkeep of roads, pavements, and public pathways throughout the village.',
        'color': _gold,
      },
      {
        'icon': Icons.delete_rounded,
        'title': 'Waste Management',
        'desc':
            'Organized waste collection schedule across all zones with recycling initiatives.',
        'color': _greenL,
      },
      {
        'icon': Icons.light_rounded,
        'title': 'Public Lighting',
        'desc':
            'Installation and maintenance of street lighting to ensure safe public spaces.',
        'color': const Color(0xFFFFD166),
      },
      {
        'icon': Icons.water_drop_rounded,
        'title': 'Water Follow-Up',
        'desc':
            'Monitoring and coordination of water distribution and infrastructure issues.',
        'color': const Color(0xFF4A90D9),
      },
      {
        'icon': Icons.description_rounded,
        'title': 'Citizen Services',
        'desc':
            'Issuing official documents, residency certificates, and civil registration support.',
        'color': const Color(0xFF9B8EA8),
      },
      {
        'icon': Icons.handshake_rounded,
        'title': 'Community Support',
        'desc':
            'Social programs, community events, and support initiatives for residents.',
        'color': const Color(0xFFFF9F1C),
      },
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            icon: Icons.settings_rounded,
            title: 'Municipality Services',
            subtitle: 'What we provide for the community',
          ),
          const SizedBox(height: 14),
          ...services.map(
            (s) => _serviceCard(
              icon: s['icon'] as IconData,
              title: s['title'] as String,
              desc: s['desc'] as String,
              color: s['color'] as Color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _serviceCard({
    required IconData icon,
    required String title,
    required String desc,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _text1,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(
                    color: _text2,
                    fontSize: 12.5,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: _text3, size: 20),
        ],
      ),
    );
  }

  // ── Contact section ────────────────────────────────────────────────────────
  Widget _buildContactSection() {
    final details = [
      {
        'icon': Icons.access_time_rounded,
        'label': 'Working Hours',
        'value': 'Mon – Fri · 08:00 – 15:00',
        'color': _greenL,
      },
      {
        'icon': Icons.phone_rounded,
        'label': 'Phone Number',
        'value': '+961 6 123 456',
        'color': _blue,
      },
      {
        'icon': Icons.location_on_rounded,
        'label': 'Address',
        'value': 'Bterram Village, Dinniyeh, North Lebanon',
        'color': _gold,
      },
      {
        'icon': Icons.email_rounded,
        'label': 'Email',
        'value': 'info@bterram.gov.lb',
        'color': const Color(0xFFFF9F1C),
      },
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            icon: Icons.contact_phone_rounded,
            title: 'Contact & Details',
            subtitle: 'Reach us anytime during working hours',
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _border),
            ),
            child: Column(
              children: details.asMap().entries.map((e) {
                final i = e.key;
                final d = e.value;
                final isLast = i == details.length - 1;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: (d['color'] as Color),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              d['icon'] as IconData,
                              color: d['color'] as Color,
                              size: 19,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  d['label'] as String,
                                  style: const TextStyle(
                                    color: _text3,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  d['value'] as String,
                                  style: const TextStyle(
                                    color: _text1,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isLast)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Container(height: 1, color: _border),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Vision section ─────────────────────────────────────────────────────────
  Widget _buildVisionSection() {
    final pillars = [
      {
        'icon': Icons.eco_rounded,
        'label': 'Sustainability',
      },
      {
        'icon': Icons.groups_rounded,
        'label': 'Community',
      },
      {
        'icon': Icons.construction_rounded,
        'label': 'Development',
      },
      {
        'icon': Icons.lightbulb_rounded,
        'label': 'Innovation',
      },
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            icon: Icons.auto_awesome_rounded,
            title: 'Our Vision',
            subtitle: 'Building a better Bterram together',
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _goldDim,
                  _goldDim,
                  const Color(0xFF0E1A10),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: _gold),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '"',
                  style: TextStyle(
                    color: _gold,
                    fontSize: 52,
                    height: 0.6,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'We are committed to building a modern, connected, and thriving community for every resident of Bterram — where services are efficient, infrastructure is maintained, and every citizen\'s voice is heard and respected.',
                  style: TextStyle(
                    color: _text1,
                    fontSize: 14.5,
                    height: 1.75,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _gold,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _gold,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.account_balance_rounded,
                          color: _gold,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bterram Municipality',
                          style: TextStyle(
                            color: _gold,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Official Statement 2026',
                          style: TextStyle(
                            color: _text3,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: pillars.map((p) {
              final isLast = p == pillars.last;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: isLast ? 0 : 10),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _border),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        p['icon'] as IconData,
                        color: _greenL,
                        size: 22,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        p['label'] as String,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: _text2,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 20,
            ),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _border),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: _green,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _green),
                  ),
                  child: const Icon(
                    Icons.phone_iphone_rounded,
                    color: _greenL,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Baladiyati App',
                        style: TextStyle(
                          color: _text1,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Municipal digital services at your fingertips',
                        style: TextStyle(
                          color: _text3,
                          fontSize: 11.5,
                        ),
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
                    color: _green,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _green),
                  ),
                  child: const Text(
                    'v1.0',
                    style: TextStyle(
                      color: _greenL,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
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

  // ── Section header helper ──────────────────────────────────────────────────
  Widget _sectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: _surf2,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: _border),
          ),
          child: Center(
            child: Icon(
              icon,
              color: _greenL,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: _text1,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                color: _text3,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}