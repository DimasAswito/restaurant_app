import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../provider/detail/review_provider.dart';

class ReviewDialog extends StatelessWidget {
  final Future<bool> Function(String name, String review) onSubmit;

  const ReviewDialog({super.key, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final reviewController = TextEditingController();

    return ChangeNotifierProvider(
      create: (_) => ReviewProvider(),
      child: Consumer<ReviewProvider>(
        builder: (context, reviewProvider, _) {
          return AlertDialog(
            title: const Text(
              "Tambah Review",
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Nama"),
                    validator: (value) =>
                        value!.isEmpty ? "Nama wajib diisi" : null,
                  ),
                  TextFormField(
                    controller: reviewController,
                    decoration: const InputDecoration(labelText: "Review"),
                    validator: (value) =>
                        value!.isEmpty ? "Review wajib diisi" : null,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Batal"),
              ),
              ElevatedButton(
                onPressed: reviewProvider.loading
                    ? null
                    : () async {
                        if (formKey.currentState!.validate()) {
                          reviewProvider.setLoading(true);
                          final success = await onSubmit(
                            nameController.text,
                            reviewController.text,
                          );
                          reviewProvider.setLoading(false);

                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success
                                      ? "Review berhasil dikirim"
                                      : "Gagal mengirim review",
                                ),
                                backgroundColor: success
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            );
                          }
                        }
                      },
                child: reviewProvider.loading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Kirim"),
              ),
            ],
          );
        },
      ),
    );
  }
}
