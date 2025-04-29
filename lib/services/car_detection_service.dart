import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class DetectionResult {
  final String? vehicleType;
  final List<double>? vehicleBox;
  final List<double>? plateBox;
  final String? plateText;

  DetectionResult({
    required this.vehicleType,
    required this.vehicleBox,
    required this.plateBox,
    required this.plateText,
  });
}

// Helper function to determine base URL based on platform
String getApiBaseUrl() {
  if (Platform.isAndroid) {
    return "http://10.0.2.2:8000"; // Android Emulator -> Host Machine
  } else {
    return "http://127.0.0.1:8000"; // iOS Simulator or real device
  }
}

Future<DetectionResult?> detectVehicleAndPlate(File imageFile) async {
  final uri = Uri.parse("${getApiBaseUrl()}/predict");
  final request = http.MultipartRequest('POST', uri)
    ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

  final response = await request.send();
  final responseData = await http.Response.fromStream(response);

  if (response.statusCode == 200) {
    final data = json.decode(responseData.body);

    final vehicleType = data["vehicle_predictions"] != null && data["vehicle_predictions"].isNotEmpty ? data["vehicle_predictions"][0]["class"] : "";
    final vehicleBox = data["vehicle_predictions"] != null && data["vehicle_predictions"].isNotEmpty
        ? List<double>.from(data["vehicle_predictions"][0]["coordinates"][0])
        : null;
    final plateBox = data["plate_predictions"] != null && data["plate_predictions"].isNotEmpty
        ? List<double>.from(data["plate_predictions"][0]["coordinates"][0])
        : null;
    final plateText = data["plate_text"] ?? "";
    debugPrint("Vehicle Type: $vehicleType");
    debugPrint("Vehicle Box: $vehicleBox");
    debugPrint("Plate Box: $plateBox");
    debugPrint("Plate Text: $plateText");
    // Return the detection result
    return DetectionResult(
        vehicleType: vehicleType,
        vehicleBox: vehicleBox,
        plateBox: plateBox,
        plateText: plateText
      );
  } else {
    throw Exception("Prediction failed: ${response.statusCode}");
  }
}