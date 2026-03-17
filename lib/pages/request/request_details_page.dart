import 'package:flutter/material.dart';
import 'package:frontend/models/request_model.dart';
import 'package:frontend/services/request_service.dart';

class RequestDetailsPage extends StatefulWidget {
  final int requestid;
  const RequestDetailsPage({super.key, required this.requestid});

  @override
  State<RequestDetailsPage> createState() => _RequestDetailsPageState();
}

class _RequestDetailsPageState extends State<RequestDetailsPage> {
  DocumentRequest? request;
  bool loading = true;
  String? error;
  bool cancelling = false;
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
    load();
  }
  Future<void> load() async{
    setState(() {
      loading = true;
      error = null;
    });
    final result = await RequestService.getRequestById(widget.requestid);
    if(!mounted){
      return;
    }
    setState(() {
      loading = false;
      if(result.success){
        request = result.request;
      }
      else{
        error = result.errorMessage;
      }
    });
  }
  Future<void> cancel() async {
    final confirm = await showDialog<bool>(
    context: context,
     builder: (_)=> AlertDialog(
      backgroundColor: surface,
      shape: RoundedRectangleBorder(
       borderRadius: BorderRadiusGeometry.circular(18),
      ),
      title: const Text('Cancel Request', style: TextStyle(color: text1,fontWeight: FontWeight.w800)),
      content: const Text('Are you sure you want to cancel this request? this cannot be undone.',style: TextStyle(color: text2,height: 1.5)),
      actions: [
        TextButton(
        onPressed: ()=>Navigator.pop(context,false),
        child: const Text('Keep', style: TextStyle(color: greenLight,fontWeight: FontWeight.w700)),
        ),
        TextButton(
        onPressed: ()=>Navigator.pop(context,true),
        child: const Text('Cancel Request',style: TextStyle(color: red,fontWeight: FontWeight.w700),)
        )
      ],
     )
     );
     if(confirm !=true || !mounted){
      return;
     }
     setState(()=> cancelling = true);
     final result = await RequestService.cancelRequest(widget.requestid);
     if(!mounted){
      return;
     }
     setState(() => cancelling = false);
     if(result.success){
      Navigator.pop(context,true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request cancelled.',style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFF5A7A62),
          behavior: SnackBarBehavior.floating,
          )
      );
     }
     else{
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message ?? 'Could not cancel.',style: TextStyle(color: Colors.white)),
          backgroundColor: red,
          behavior: SnackBarBehavior.floating,
          )
      );
     }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: loading ? const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF2D9B5A),
            strokeWidth: 2.5,
          ),
        ) : error != null ? buildError() : buildContent()
        ),
    );
  }
  Widget buildError() => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded,color: text3,size: 48,),
          const SizedBox(height: 14),
          Text(error!,style: TextStyle(color: text2,fontSize: 14)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed:load ,
            style: ElevatedButton.styleFrom(backgroundColor: green,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child:const Text('Retry',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w700))
            )
        ],
      ), 
      ),
  );
  Widget buildContent(){
    final r = request!;
    return Column(
      children: [
        Padding(
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
              const Text('Request Details',style: TextStyle(color: text1,fontSize: 19,fontWeight: FontWeight.w900))
            ],
          ), 
          ),
          Expanded(
            child:ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: border)
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r.documentType,style: TextStyle(color: text1,fontSize: 17,fontWeight: FontWeight.w800)),
                            Text(r.requestCode.isNotEmpty ? r.requestCode : 'Request #${r.id}',style: TextStyle(color: text3,fontSize: 12.5))
                          ],
                        ) 
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 6),
                          decoration: BoxDecoration(
                            color: r.status.bgColor,
                            borderRadius: BorderRadius.circular(10)
                          ),
                          child: Text(
                            r.status.label,style: TextStyle(color: r.status.color,fontSize: 13,fontWeight: FontWeight.w700),
                          ),
                        )
                    ],
                  ),
                  
                ),
                const SizedBox(height: 16),
                const Divider(
                  color: Color(0xFF1E3A24),
                  height: 1,
                ),
                const SizedBox(height: 14),
                detailRow('Submitted', r.formattedDate),
                if(r.purpose != null && r.purpose!.isNotEmpty)
                detailRow('Purpose', r.purpose!),
                if(r.assignedToName != null)
                detailRow('Assigned to', r.assignedToName!)
              ],
            ) 
            ),
            const SizedBox(height: 20),
            buildTimeLine(r.status),
            const SizedBox(height: 20),
            if(r.notes.isNotEmpty) ...[
              const Text(
                'Updates From staff',
                style: TextStyle(color: text3,fontSize: 10.5,fontWeight: FontWeight.w800,letterSpacing: 1.3),
              ),
              const SizedBox(height: 10),
              ...r.notes.map((n)=> buildNoteCard(n)).toList(),
              const SizedBox(height: 10)
            ],
            if(r.status == RequestStatus.pending || r.status == RequestStatus.inReview)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: cancelling ? null : cancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: red,
                  side: const BorderSide(color: Color(0xFFE05252)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(14)
                  )
                ),
                child: cancelling ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: red,
                  ),
                ) : const Text(
                  'Cancel Request',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15
                  ),
                )
                )
            )
      ],
    );
  }
  Widget detailRow(String label, String value){
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label, style: TextStyle(color: text3,fontSize: 12.5),
            ),
          ),
          Expanded(
            child: Text(
              value,style: TextStyle(color: text2,fontSize: 13,fontWeight: FontWeight.w600),
            ) 
            )
        ],
      ), 
      );
  }
  Widget buildTimeLine(RequestStatus current){
    final steps = [
      {'label': 'Submitted', 'status': RequestStatus.pending},
      {'label': 'In Review', 'status': RequestStatus.inReview},
      {'label': 'Appeoved', 'status': RequestStatus.approved},
      {'label': 'Done', 'status': RequestStatus.done}
    ];
    final currentIdx = steps.indexWhere((s)=> s['status'] == current);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Request Progress',style: TextStyle(color: text3,fontSize: 10.5,fontWeight: FontWeight.w800,letterSpacing: 1.3),),
          const SizedBox(height: 16),
          Row(
            children: List.generate(steps.length*2-1, (i) {
              if(i.isOdd){
                final stepIdx = i~/2;
                final passed = stepIdx < currentIdx || (current == RequestStatus.cancelled && stepIdx == 0);
                return Expanded(
                  child:Container(
                    height: 2,
                    color: passed ? green : border,
                  )
                  );
              }
              final idx = i~/2;
              final step = steps[idx];
              final passed = idx <= currentIdx && current != RequestStatus.cancelled;
              final isNow = idx == currentIdx;
              return Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: passed ? green : surface2,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isNow ? greenLight : border,
                        width: isNow ? 2 : 1
                      )
                    ),
                    child: Center(
                      child: passed ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 16,
                      ) : Text(
                        '${idx + 1}',
                        style: TextStyle(
                          color: isNow ? greenLight : text3,
                          fontSize: 12,
                          fontWeight: FontWeight.w700
                        ),
                      )
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    step['label'] as String,
                    style: TextStyle(
                      color: passed ? greenLight : text3,
                      fontSize: 10,
                      fontWeight: passed ? FontWeight.w700 : FontWeight.w500
                    ),
                  )
                ],
              );
            }),
          ),
          if (current == RequestStatus.cancelled) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: red,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: red)
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFFE05252),
                    size: 18,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text('This request was cancelled',style: TextStyle(color: Color(0xFFE05252),fontSize: 12.5)) 
                    )
                ],
              ),
            )
          ]
        ],
      ),
    );
  }
  Widget buildNoteCard(RequestNote note){
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.person_rounded,
                color: Color(0xFF5A7A62),
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                note.staffName,
                style: TextStyle(color: greenLight,fontSize: 12.5,fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Text(
                note.formattedDate,
                style: TextStyle(color: text3,fontSize: 11.5),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            note.text,
            style: TextStyle(color: text2,fontSize: 13.5,height: 1.5),
          )
        ],
      ),
    );
  }
}