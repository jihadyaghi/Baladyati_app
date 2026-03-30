import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:frontend/models/issue_model.dart';
import 'package:frontend/services/issue_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';

class ReportIssuePage extends StatefulWidget {
  const ReportIssuePage({super.key});

  @override
  State<ReportIssuePage> createState() => _ReportIssuePageState();
}

class _ReportIssuePageState extends State<ReportIssuePage>
    with SingleTickerProviderStateMixin {
  static const Color _bg = Color(0xFF06110A);
  static const Color _surface = Color(0xFF0B1710);
  static const Color _card = Color(0xFF112016);
  static const Color _card2 = Color(0xFF16281C);
  static const Color _green = Color(0xFF1E5F3A);
  static const Color _greenL = Color(0xFF3DBD71);
  static const Color _red = Color(0xFFE05252);
  static const Color _border = Color(0xFF21402A);
  static const Color _text1 = Color(0xFFF0F5F1);
  static const Color _text2 = Color(0xFFA8C4AF);
  static const Color _text3 = Color(0xFF6B8A72);

  final MapController mapCtrl = MapController();

  LatLng pinLoc = const LatLng(34.4667, 35.8833);
  String address = 'Locating...';
  bool gpsLoading = false;

  final formKey = GlobalKey<FormState>();
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  IssueCategory? selectedCategory;
  IssueSeverity severity = IssueSeverity.medium;

  final List<XFile> photos = [];
  final ImagePicker picker = ImagePicker();

  bool submitting = false;

  late AnimationController fadeCtrl;
  late Animation<double> fadeAnim;

  @override
  void initState() {
    super.initState();
    fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    fadeAnim = CurvedAnimation(
      parent: fadeCtrl,
      curve: Curves.easeOut,
    );
    fadeCtrl.forward();
    getCurrentLocation();
  }

  @override
  void dispose() {
    fadeCtrl.dispose();
    titleCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }

  Future<void> getCurrentLocation() async {
    setState(() => gpsLoading = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          address = 'Location services disabled';
          gpsLoading = false;
        });
        return;
      }

      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.denied) {
          setState(() {
            address = 'Location permission denied';
            gpsLoading = false;
          });
          return;
        }
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final loc = LatLng(pos.latitude, pos.longitude);

      if (!mounted) return;

      setState(() {
        pinLoc = loc;
        address =
            '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}';
        gpsLoading = false;
      });

      mapCtrl.move(loc, 16);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        address = 'Could not get location';
        gpsLoading = false;
      });
    }
  }

  Future<void> pickPhoto() async {
    if (photos.length >= 2) {
      showError('Maximum 2 photos allowed');
      return;
    }

    final img = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );

    if (img != null && mounted) {
      setState(() => photos.add(img));
    }
  }

  Future<void> submit() async {
    FocusScope.of(context).unfocus();

    if (selectedCategory == null) {
      showError('Please select a category');
      return;
    }

    if (!formKey.currentState!.validate()) return;

    setState(() => submitting = true);

    final result = await IssueService.submitIssue(
      categoryId: selectedCategory!.index + 1,
      title: titleCtrl.text.trim(),
      description: descCtrl.text.trim(),
      severity: severity,
      latitude: pinLoc.latitude,
      longitude: pinLoc.longitude,
      photoUrl1: photos.isNotEmpty ? photos[0].path : null,
      photoUrl2: photos.length > 1 ? photos[1].path : null,
      adrressText: address
    );

    if (!mounted) return;

    setState(() => submitting = false);

    if (result.success) {
      showSuccess();
    } else {
      showError(result.errorMessage ?? 'Submission failed');
    }
  }

  void showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: _red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void showSuccess() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: _card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Issue Submitted',
            style: TextStyle(
              color: _text1,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            'Municipality staff will review it shortly.',
            style: TextStyle(color: _text2),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, true);
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  color: _greenL,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: _greenL,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
      ),
    );
  }

  InputDecoration inputDecoration({
    required String hint,
    IconData? icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: _text3,
        fontSize: 13.5,
      ),
      prefixIcon: icon != null
          ? Icon(icon, color: _text3, size: 18)
          : null,
      filled: true,
      fillColor: _card,
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _greenL, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _red, width: 1.4),
      ),
      errorStyle: const TextStyle(
        color: _red,
        fontSize: 12,
      ),
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
      body: Stack(
        children: [
          Positioned(
            top: -80,
            left: -70,
            child: Container(
              width: 240,
              height: 240,
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
          Positioned(
            top: 180,
            right: -80,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _greenL,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          FadeTransition(
            opacity: fadeAnim,
            child: Column(
              children: [
                SafeArea(child: header()),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          mapSection(),
                          const SizedBox(height: 24),
                          sectionTitle('CATEGORY'),
                          const SizedBox(height: 10),
                          categoryGrid(),
                          const SizedBox(height: 24),
                          sectionTitle('ISSUE TITLE'),
                          const SizedBox(height: 10),
                          titleField(),
                          const SizedBox(height: 24),
                          sectionTitle('DESCRIPTION'),
                          const SizedBox(height: 10),
                          descField(),
                          const SizedBox(height: 24),
                          sectionTitle('PHOTOS'),
                          const SizedBox(height: 10),
                          photoSection(),
                          const SizedBox(height: 24),
                          sectionTitle('SEVERITY'),
                          const SizedBox(height: 10),
                          severityRow(),
                          const SizedBox(height: 30),
                          submitButton(),
                        ],
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

  Widget header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _border),
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: _text1,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Report Issue',
                  style: TextStyle(
                    color: _text1,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Report municipal problems quickly',
                  style: TextStyle(
                    color: _text3,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget mapSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              height: 240,
              child: FlutterMap(
                mapController: mapCtrl,
                options: MapOptions(
                  initialCenter: pinLoc,
                  initialZoom: 15,
                  onTap: (_, latlng) {
                    setState(() {
                      pinLoc = latlng;
                      address =
                          '${latlng.latitude.toStringAsFixed(5)}, ${latlng.longitude.toStringAsFixed(5)}';
                    });
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: pinLoc,
                        width: 60,
                        height: 60,
                        child: const Icon(
                          Icons.location_pin,
                          color: _red,
                          size: 42,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _border),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.place_rounded,
                  color: _red,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    address,
                    style: const TextStyle(
                      color: _text2,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: getCurrentLocation,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: _card2,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _border),
                    ),
                    child: gpsLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: _greenL,
                            ),
                          )
                        : const Text(
                            'Locate',
                            style: TextStyle(
                              color: _greenL,
                              fontSize: 11.5,
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

  Widget categoryGrid() {
    final cats = IssueCategory.values;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.18,
      ),
      itemBuilder: (_, i) {
        final c = cats[i];
        final active = selectedCategory == c;

        return GestureDetector(
          onTap: () => setState(() => selectedCategory = c),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: active ? c.color : _card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: active ? c.color : _border,
                width: active ? 1.5 : 1,
              ),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: c.color,
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : [],
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    c.icon,
                    color: active ? c.color : _text2,
                    size: 24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    c.label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: active ? c.color : _text2,
                      fontSize: 11.5,
                      fontWeight:
                          active ? FontWeight.w700 : FontWeight.w500,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget titleField() {
    return TextFormField(
      controller: titleCtrl,
      style: const TextStyle(color: _text1),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Title required';
        if (v.trim().length < 3) return 'At least 3 characters';
        return null;
      },
      decoration: inputDecoration(
        hint: 'e.g. Broken street light',
        icon: Icons.title_rounded,
      ),
    );
  }

  Widget descField() {
    return TextFormField(
      controller: descCtrl,
      maxLines: 4,
      style: const TextStyle(color: _text1),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Description required';
        if (v.trim().length < 10) return 'At least 10 characters';
        return null;
      },
      decoration: inputDecoration(
        hint: 'Describe the issue clearly...',
        icon: Icons.notes_rounded,
      ),
    );
  }

  Widget photoSection() {
    return SizedBox(
      height: 92,
      child: Row(
        children: [
          ...photos.asMap().entries.map((entry) {
            final index = entry.key;
            final file = entry.value;

            return Stack(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _border),
                    image: DecorationImage(
                      image: FileImage(File(file.path)),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 16,
                  child: GestureDetector(
                    onTap: () => setState(() => photos.removeAt(index)),
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: _red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
          if (photos.length < 2)
            GestureDetector(
              onTap: pickPhoto,
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _border),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_a_photo_rounded,
                      color: _greenL,
                      size: 24,
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Add Photo',
                      style: TextStyle(
                        color: _text3,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
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

  Widget severityRow() {
    return Row(
      children: IssueSeverity.values.map((s) {
        final active = severity == s;

        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => severity = s),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: EdgeInsets.only(right: s != IssueSeverity.high ? 10 : 0),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: active ? s.color: _card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: active ? s.color : _border,
                  width: active ? 1.5 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    s.icon,
                    color: active ? s.color : _text2,
                    size: 22,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    s.label,
                    style: TextStyle(
                      color: active ? s.color : _text2,
                      fontSize: 12.5,
                      fontWeight:
                          active ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget submitButton() {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD44343), Color(0xFFB92D2D)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _red,
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: submitting ? null : submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: submitting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.4,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Submit Report',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}