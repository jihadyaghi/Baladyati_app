import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/models/request_model.dart';
import 'package:frontend/pages/request/request_details_page.dart';
import 'package:frontend/services/request_service.dart';

class RequestsPage extends StatefulWidget {
  const RequestsPage({super.key});

  @override
  State<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> with SingleTickerProviderStateMixin {
  IconData statusIcon(RequestStatus s){
    switch (s) {
      case RequestStatus.pending:
      return Icons.schedule_rounded;
      case RequestStatus.inReview:
      return Icons.search_rounded;
      case RequestStatus.inProgress:
      return Icons.build_rounded;
      case RequestStatus.approved:
      return Icons.check_circle_rounded;
      case RequestStatus.done:
      return Icons.task_alt_rounded;
      case RequestStatus.cancelled:
      return Icons.cancel_rounded;
      default:
      return Icons.description_rounded;
    }
  }
  List<DocumentRequest> all = [];
  bool loading = true;
  String? error;
  late TabController tabContrller;
  static const Color bg = Color(0xFF070E09);
  static const Color surface = Color(0xFF111A13);
  static const Color surface2 = Color(0xFF162B1C);
  static const Color green = Color(0xFF2D9B5A);
  static const Color greenLight = Color(0xFF3DBD71);
  static const Color border = Color(0xFF1E3A24);
  static const Color text1 = Color(0xFFF0F0F0);
  static const Color text2 = Color(0xFFA8C4AF);
  static const Color text3 = Color(0xFF5A7A62);
  static const Color red = Color(0xFFE05252);
  @override
  void initState(){
    super.initState();
    tabContrller = TabController(length: 3, vsync: this);
    load();
  }
  @override
  void dispose(){
    tabContrller.dispose();
    super.dispose();
  }
  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });
    final result = await RequestService.getMyRequests();
    if(!mounted){
      return;
    }
    setState(() {
      loading = false;
      if(result.success){
        all = result.requests;
      }
      else{
        error = result.errorMessage;
      }
    });
  }
  List<DocumentRequest> get active => all.where((r) {
    return r.status == RequestStatus.pending ||r.status == RequestStatus.inReview ||  r.status == RequestStatus.inProgress;
  }).toList();
  List<DocumentRequest> get completed => all.where((r) {
    return r.status == RequestStatus.approved || r.status == RequestStatus.resolved || r.status == RequestStatus.done;
  }).toList();
  List<DocumentRequest> get cancelled => all.where((r) {
    return r.status == RequestStatus.cancelled;
  }).toList();
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light
      )
    );
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: buildBody()
        ),
        floatingActionButton: buildFAB(),
    );
  }
  Widget buildBody(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildHeader(),
        buildTabs(),
        Expanded(
          child: loading ? const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF2D9B5A),
              strokeWidth: 2.5,
            ),
          ) : error != null ? buildError() : TabBarView(
             controller: tabContrller,
            children: [
              buildList(all),
              buildList(active),
              buildList(completed)
            ]
            )
        )
      ],
    );
  }
  Widget buildHeader(){
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
                color: surface2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: border)
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: text2,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('My Requests',style: TextStyle(color: text1,fontSize: 20,fontWeight: FontWeight.w900)),
              Text('${all.length} total',style: TextStyle(color: text3,fontSize: 12.5))
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: load,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: surface2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: border)
              ),
              child: const Icon(
                Icons.refresh_rounded,
                color: text2,
                size: 20,
              ),
            ),
          )
        ],
      ),
      );
  }
  Widget buildTabs(){
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border)
        ),
        child: TabBar(
          controller: tabContrller,
          indicator: BoxDecoration(
            color: green,
            borderRadius: BorderRadius.circular(10)
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: Colors.white,
          unselectedLabelColor: text3,
          labelStyle: TextStyle(fontSize: 12.5,fontWeight: FontWeight.w700),
          dividerColor: Colors.transparent,
          tabs: [
            Tab(text: 'All (${all.length})'),
            Tab(text: 'Active (${active.length})'),
            Tab(text: 'Done (${completed.length})')
          ]
          ),
      ),
      );
  }
  Widget buildList(List<DocumentRequest> items){
    if(items.isEmpty){
      return buildEmpty();
    }
    return RefreshIndicator(
      color: green,
      backgroundColor: surface,
      onRefresh: load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 100),
        itemCount: items.length,
        itemBuilder: (_,i) => buildCard(items[i])
        ),
      
      );
  }
  Widget buildEmpty() => const Center(
    child: Padding(
      padding: EdgeInsets.all(40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('No Requests yet.' , style: TextStyle(color: text1,fontSize: 16,fontWeight: FontWeight.w700)),
          SizedBox(height: 8),
          Text('Tap the + button to submit your\n first document request.',style: TextStyle(color: text3,fontSize: 13.5,height: 1.5), textAlign: TextAlign.center)
        ],
      ),
      ),
  );
  Widget buildError() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.wifi_off_rounded, color: text3, size: 48),
        const SizedBox(height: 14),
        Text(
          error!,style: TextStyle(color: text2,fontSize: 14),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: load,
          style: ElevatedButton.styleFrom(
            backgroundColor: green,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
          ),
          child: const Text('Retry', style: TextStyle(color: Colors.white,fontWeight: FontWeight.w700))
          )
      ],
    ),
  );
  Widget buildCard(DocumentRequest r){
    return GestureDetector(
      onTap: () async {
        final updated = await Navigator.push<bool>(context,MaterialPageRoute(builder: (_) => RequestDetailsPage(requestid: r.id)));
        if (updated == true){
          load();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border)
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: r.status.bgColor,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Center(
                child: Icon(
                  statusIcon(r.status),
                  color: r.status.color,
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
                    r.documentType,
                    style: TextStyle(
                      color: text1,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    r.formattedDate,
                    style: TextStyle(
                      color: text3,
                      fontSize: 12
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    r.requestCode.isNotEmpty ? r.requestCode : 'Request #${r.id}',
                    style: TextStyle(color: text3,fontSize: 11.5),
                  ),
                  if (r.assignedToName != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Assigned to: ${r.assignedToName}',
                      style: const TextStyle(
                        color: text3,
                        fontSize: 11.5
                      ),
                    )
                  ]
                ],
              ) 
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                    decoration: BoxDecoration(
                      color: r.status.bgColor,
                      borderRadius: BorderRadius.circular(8)
                    ),
                    child: Text(
                      r.status.label,
                      style: TextStyle(
                        color: r.status.color,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF5A7A62),
                    size: 20,
                  )
                ],
              )
          ],
        ),
      )
    );
  }
  Widget buildFAB(){
    return FloatingActionButton.extended(
      onPressed: openSubmitSheet,
      backgroundColor: green,
      icon: const Icon(Icons.add_rounded,color: Colors.white),
      label: const Text(
        'New Request',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700
        ),
      )
      );
  }
  void openSubmitSheet(){
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SubmitRequestSheet(onSubmitted: (){
        load();
      })
      );
  }
}
class _SubmitRequestSheet extends StatefulWidget {
  final VoidCallback onSubmitted;
  const _SubmitRequestSheet({required this.onSubmitted});

  @override
  State<_SubmitRequestSheet> createState() => _SubmitRequestSheetState();
}

class _SubmitRequestSheetState extends State<_SubmitRequestSheet> {
  static const Color _surface = Color(0xFF111A13);
  static const Color _surf2 = Color(0xFF162B1C);
  static const Color _green = Color(0xFF2D9B5A);
  static const Color _border = Color(0xFF1E3A24);
  static const Color _text1 = Color(0xFFF0F0F0);
  static const Color _text3 = Color(0xFF5A7A62);
  static const Color _red = Color(0xFFE05252);

  final _formKey = GlobalKey<FormState>();
  final _purposeCtrl = TextEditingController();

  DocumentTypeItem? _selectedType;
  List<DocumentTypeItem> _types = [];
  bool _loadingTypes = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadTypes();
  }

  @override
  void dispose() {
    _purposeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadTypes() async {
    final types = await RequestService.getDocumentTypes();
    if (!mounted) return;

    setState(() {
      _types = types;
      _loadingTypes = false;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    final result = await RequestService.createRequest(
      documentTypeId: _selectedType!.id,
      purpose: _purposeCtrl.text.trim().isEmpty
          ? null
          : _purposeCtrl.text.trim(),
    );

    if (!mounted) return;

    setState(() => _submitting = false);

    if (result.success) {
      Navigator.pop(context);
      widget.onSubmitted();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text(
                'Request submitted!',
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
          content: Text(
            result.message ?? 'Submission failed.',
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
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 0, 24, bottom + 24),
      decoration: const BoxDecoration(
        color: Color(0xFF0D1A10),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
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
                  color: const Color(0xFF1E3A24),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'New Document Request',
              style: TextStyle(
                color: _text1,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Your request will be reviewed by municipality staff.',
              style: TextStyle(
                color: _text3,
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'DOCUMENT TYPE',
              style: TextStyle(
                color: _green,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            _loadingTypes
                ? Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: _surf2,
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(color: _border),
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _green,
                        ),
                      ),
                    ),
                  )
                : DropdownButtonFormField<DocumentTypeItem>(
                    value: _selectedType,
                    dropdownColor: _surface,
                    style: const TextStyle(color: _text1, fontSize: 14.5),
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: _text3,
                    ),
                    hint: const Text(
                      'Select document type',
                      style: TextStyle(color: _text3, fontSize: 14),
                    ),
                    validator: (v) =>
                        v == null ? 'Please select a document type' : null,
                    items: _types
                        .map(
                          (t) => DropdownMenuItem<DocumentTypeItem>(
                            value: t,
                            child: Text(
                              t.name,
                              style: const TextStyle(color: _text1),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedType = v),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: _surf2,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13),
                        borderSide: const BorderSide(color: _border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13),
                        borderSide: const BorderSide(color: _border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13),
                        borderSide:
                            const BorderSide(color: _green, width: 1.6),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13),
                        borderSide: const BorderSide(color: _red),
                      ),
                      errorStyle:
                          const TextStyle(color: _red, fontSize: 12),
                    ),
                  ),
            const SizedBox(height: 18),
            const Text(
              'PURPOSE (optional)',
              style: TextStyle(
                color: _green,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _purposeCtrl,
              maxLines: 3,
              style: const TextStyle(color: _text1, fontSize: 14.5),
              decoration: InputDecoration(
                hintText:
                    'e.g. Needed for school enrollment, visa application…',
                hintStyle:
                    const TextStyle(color: _text3, fontSize: 13.5),
                filled: true,
                fillColor: _surf2,
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide: const BorderSide(color: _border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide: const BorderSide(color: _border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide: const BorderSide(color: _green, width: 1.6),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  disabledBackgroundColor: _green.withOpacity(0.45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Submit Request',
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
}