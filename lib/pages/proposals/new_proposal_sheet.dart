import 'package:flutter/material.dart';
import 'package:frontend/models/proposal_model.dart';
import 'package:frontend/services/proposal_service.dart';

class NewProposalSheet extends StatefulWidget {
  final void Function(Proposal proposal)? onCreated;

  const NewProposalSheet({super.key, this.onCreated});

  @override
  State<NewProposalSheet> createState() => _NewProposalSheetState();
}

class _NewProposalSheetState extends State<NewProposalSheet> {
  final formKey = GlobalKey<FormState>();
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  bool submitting = false;

  static const Color surface2 = Color(0xFF162B1C);
  static const Color green = Color(0xFF2D9B5A);
  static const Color greenLight = Color(0xFF3DBD71);
  static const Color border = Color(0xFF1E3A24);
  static const Color text1 = Color(0xFFF0F5F1);
  static const Color text3 = Color(0xFF5A7A62);
  static const Color red = Color(0xFFE05252);

  @override
  void dispose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => submitting = true);

    final result = await ProposalService.createProposal(
      title: titleCtrl.text.trim(),
      description: descCtrl.text.trim(),
    );

    if (!mounted) return;

    setState(() => submitting = false);

    if (result.success && result.proposal != null) {
      widget.onCreated?.call(result.proposal!);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 18,
              ),
              SizedBox(width: 10),
              Text(
                'Proposal submitted!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          backgroundColor: green,
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
            result.message ?? 'Could not submit proposal.',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: red,
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
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(26),
        ),
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
                  color: border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: green.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.lightbulb_rounded,
                    color: greenLight,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'New Proposal',
                      style: TextStyle(
                        color: text1,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Share your idea with the community',
                      style: TextStyle(
                        color: text3,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            fieldLabel('Proposal Title'),
            const SizedBox(height: 8),
            TextFormField(
              controller: titleCtrl,
              textInputAction: TextInputAction.next,
              style: const TextStyle(
                color: text1,
                fontSize: 15,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Title is required';
                }
                if (v.trim().length < 5) {
                  return 'At least 5 characters';
                }
                return null;
              },
              decoration: inputDeco(
                hint: 'e.g Add solar panels to community center',
              ),
            ),
            const SizedBox(height: 18),
            fieldLabel('Description'),
            const SizedBox(height: 8),
            TextFormField(
              controller: descCtrl,
              maxLines: 4,
              style: const TextStyle(
                color: text1,
                fontSize: 14.5,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Description is required.';
                }
                if (v.trim().length < 20) {
                  return 'At least 20 characters';
                }
                return null;
              },
              decoration: inputDeco(
                hint:
                    'Explain your idea, why it matters, and how it would benefit the community...',
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: surface2,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: border),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.tips_and_updates_rounded,
                    color: greenLight,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Proposal with strong community support can be reviewed by the municipality.',
                      style: TextStyle(
                        color: text3,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: submitting ? null : submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: green,
                  disabledBackgroundColor: green.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
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
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Submit Proposal',
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
          ],
        ),
      ),
    );
  }

  Widget fieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: green,
        fontSize: 10.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.3,
      ),
    );
  }

  InputDecoration inputDeco({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: text3,
        fontSize: 13.5,
      ),
      filled: true,
      fillColor: surface2,
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: green, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: red, width: 1.6),
      ),
      errorStyle: const TextStyle(
        color: red,
        fontSize: 12,
      ),
    );
  }
}