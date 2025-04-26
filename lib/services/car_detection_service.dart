import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<String> detectVehicleClass(File imageFile) async {
  final uri = Uri.parse("http://127.0.0.1:8000/predict"); // e.g., 192.168.1.100
  final request = http.MultipartRequest('POST', uri)
    ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

  final response = await request.send();
  final responseData = await http.Response.fromStream(response);

  if (response.statusCode == 200) {
    final data = json.decode(responseData.body);
    if (data["predictions"] != null && data["predictions"].isNotEmpty) {
      final classId = data["predictions"][0]["class"];
      return classId.toString(); // or convert to label later
    } else {
      return "No object detected";
    }
  } else {
    throw Exception("Prediction failed: ${response.statusCode}");
  }
}
