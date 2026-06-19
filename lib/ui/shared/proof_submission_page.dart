import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rahiq_driver/ui/shared/proof_submission_provider.dart';
import 'package:rahiq_driver/utils/colors.dart';
import 'dart:io';

class ProofSubmissionPage extends StatelessWidget {
  final String orderId;
  final bool isAutoOrder;
  final List<String> subOrders;

  const ProofSubmissionPage({
    super.key,
    required this.orderId,
    required this.isAutoOrder,
    required this.subOrders,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProofSubmissionProvider(
        orderId: orderId,
        isAutoOrder: isAutoOrder,
        subOrderIds: subOrders,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Submit Delivery Proof'),
        ),
        body: Consumer<ProofSubmissionProvider>(
          builder: (context, provider, child) {
            if (provider.isSubmitting) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Uploading proof, please wait...'),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isAutoOrder && subOrders.length > 1) ...[
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: CheckboxListTile(
                        title: const Text(
                          'Use same images for all sub-orders',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text('Video must still be selected individually'),
                        value: provider.useSameImages,
                        onChanged: provider.toggleUseSameImages,
                        activeColor: AppColors.buttonBlue,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (provider.useSameImages) ...[
                    _buildSectionTitle('Global Images (Applies to all)'),
                    _buildGlobalImagesPicker(context, provider),
                    const Divider(height: 32),
                  ],

                  _buildSectionTitle('Sub-orders Proof'),
                  ...provider.proofs.map((proof) {
                    return _buildSubOrderSection(context, provider, proof);
                  }).toList(),

                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          await provider.submitProofs();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Proofs uploaded successfully!')),
                            );
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Submit Proofs', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.buttonBlue),
      ),
    );
  }

  Widget _buildGlobalImagesPicker(BuildContext context, ProofSubmissionProvider provider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildMediaPickerRow(
              context,
              label: 'Mosque Front',
              path: provider.globalMosqueFrontImage,
              onPick: (source) => provider.pickGlobalImage('front', source),
            ),
            const Divider(),
            _buildMediaPickerRow(
              context,
              label: 'Mosque Inside Image',
              path: provider.globalMosqueInsideImage,
              onPick: (source) => provider.pickGlobalImage('inside', source),
            ),
            const Divider(),
            _buildMediaPickerRow(
              context,
              label: 'Product',
              path: provider.globalPackagesImage,
              onPick: (source) => provider.pickGlobalImage('package', source),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubOrderSection(BuildContext context, ProofSubmissionProvider provider, SubOrderProof proof) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sub-order: ${proof.subOrderId}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            if (!provider.useSameImages) ...[
              _buildMediaPickerRow(
                context,
                label: 'Mosque Front',
                path: proof.mosqueFrontImage,
                onPick: (source) => provider.pickSubOrderImage(proof.subOrderId, 'front', source),
              ),
              const Divider(),
              _buildMediaPickerRow(
                context,
                label: 'Mosque Inside Image',
                path: proof.mosqueInsideImage,
                onPick: (source) => provider.pickSubOrderImage(proof.subOrderId, 'inside', source),
              ),
              const Divider(),
              _buildMediaPickerRow(
                context,
                label: 'Product',
                path: proof.packagesImage,
                onPick: (source) => provider.pickSubOrderImage(proof.subOrderId, 'package', source),
              ),
              const Divider(),
            ],
            _buildMediaPickerRow(
              context,
              label: 'Video',
              path: proof.proofVideo,
              isVideo: true,
              onPick: (source) => provider.pickSubOrderVideo(proof.subOrderId, source),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaPickerRow(
    BuildContext context, {
    required String label,
    required String? path,
    required Function(ImageSource) onPick,
    bool isVideo = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
              if (path != null)
                const Text('Selected', style: TextStyle(color: Colors.green, fontSize: 12))
              else
                const Text('Not selected', style: TextStyle(color: Colors.red, fontSize: 12)),
            ],
          ),
        ),
        if (path != null && !isVideo)
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(path),
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
          )
        else if (path != null && isVideo)
          const Padding(
            padding: EdgeInsets.only(right: 12.0),
            child: Icon(Icons.videocam, color: Colors.green),
          ),
        ElevatedButton(
          onPressed: () => _showSourceBottomSheet(context, onPick, isVideo: isVideo),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[200],
            foregroundColor: Colors.black87,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          child: Text(path == null ? 'Select' : 'Change'),
        ),
      ],
    );
  }

  void _showSourceBottomSheet(BuildContext context, Function(ImageSource) onPick, {bool isVideo = false}) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text('Take a ${isVideo ? 'Video' : 'Photo'}'),
              onTap: () {
                Navigator.pop(context);
                onPick(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                onPick(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}
