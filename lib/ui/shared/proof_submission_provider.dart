import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rahiq_driver/data/api/api_client.dart';
import 'package:rahiq_driver/data/api/driver/driver_orders_api.dart';

class SubOrderProof {
  final String subOrderId;
  String? mosqueFrontImage;
  String? mosqueInsideImage;
  String? packagesImage;
  String? proofVideo;

  SubOrderProof(this.subOrderId);
}

class ProofSubmissionProvider extends ChangeNotifier {
  final String orderId;
  final bool isAutoOrder;
  final List<String> subOrderIds;
  final DriverOrdersApi _api = DriverOrdersApi(ApiClient());
  
  bool _useSameImages = false;
  bool get useSameImages => _useSameImages;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? _globalMosqueFrontImage;
  String? _globalMosqueInsideImage;
  String? _globalPackagesImage;

  String? get globalMosqueFrontImage => _globalMosqueFrontImage;
  String? get globalMosqueInsideImage => _globalMosqueInsideImage;
  String? get globalPackagesImage => _globalPackagesImage;

  List<SubOrderProof> _proofs = [];
  List<SubOrderProof> get proofs => _proofs;

  final ImagePicker _picker = ImagePicker();

  ProofSubmissionProvider({
    required this.orderId,
    required this.isAutoOrder,
    required this.subOrderIds,
  }) {
    // If it's an auto order, default to use same images based on requirement
    if (isAutoOrder) {
      _useSameImages = true;
    }
    _proofs = subOrderIds.map((id) => SubOrderProof(id)).toList();
    if (_proofs.isEmpty) {
      _proofs.add(SubOrderProof(orderId)); // Fallback if no suborders exist
    }
  }

  void toggleUseSameImages(bool? value) {
    _useSameImages = value ?? false;
    notifyListeners();
  }

  Future<void> pickGlobalImage(String type, ImageSource source) async {
    final XFile? file = await _picker.pickImage(source: source);
    if (file != null) {
      if (type == 'front') _globalMosqueFrontImage = file.path;
      if (type == 'inside') _globalMosqueInsideImage = file.path;
      if (type == 'package') _globalPackagesImage = file.path;
      notifyListeners();
    }
  }

  Future<void> pickSubOrderImage(String subOrderId, String type, ImageSource source) async {
    final XFile? file = await _picker.pickImage(source: source);
    if (file != null) {
      final proof = _proofs.firstWhere((p) => p.subOrderId == subOrderId);
      if (type == 'front') proof.mosqueFrontImage = file.path;
      if (type == 'inside') proof.mosqueInsideImage = file.path;
      if (type == 'package') proof.packagesImage = file.path;
      notifyListeners();
    }
  }

  Future<void> pickSubOrderVideo(String subOrderId, ImageSource source) async {
    final XFile? file = await _picker.pickVideo(source: source);
    if (file != null) {
      final proof = _proofs.firstWhere((p) => p.subOrderId == subOrderId);
      proof.proofVideo = file.path;
      notifyListeners();
    }
  }

  Future<bool> submitProofs() async {
    _isSubmitting = true;
    notifyListeners();

    try {
      if (_useSameImages) {
        // Upload 1 request per sub-order with the global images and individual video
        for (var proof in _proofs) {
          if (_globalMosqueFrontImage == null || _globalMosqueInsideImage == null || _globalPackagesImage == null) {
            throw Exception('Please select all global images for the batch.');
          }
          if (proof.proofVideo == null) {
            throw Exception('Please select a video for suborder ${proof.subOrderId}.');
          }
          await _api.bulkUploadProof(
            orderId: orderId,
            subOrderIds: proof.subOrderId,
            mosqueFrontImagePath: _globalMosqueFrontImage!,
            mosqueInsideImagePath: _globalMosqueInsideImage!,
            packagesImagePath: _globalPackagesImage!,
            proofVideoPath: proof.proofVideo,
          );
        }
      } else {
        // Upload 1 request per sub-order with individual images and video
        for (var proof in _proofs) {
          if (proof.mosqueFrontImage == null || proof.mosqueInsideImage == null || proof.packagesImage == null) {
            throw Exception('Please select all 3 images for suborder ${proof.subOrderId}.');
          }
          if (proof.proofVideo == null) {
            throw Exception('Please select a video for suborder ${proof.subOrderId}.');
          }
          await _api.bulkUploadProof(
            orderId: orderId,
            subOrderIds: proof.subOrderId,
            mosqueFrontImagePath: proof.mosqueFrontImage!,
            mosqueInsideImagePath: proof.mosqueInsideImage!,
            packagesImagePath: proof.packagesImage!,
            proofVideoPath: proof.proofVideo,
          );
        }
      }
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isSubmitting = false;
      notifyListeners();
      rethrow;
    }
  }
}
