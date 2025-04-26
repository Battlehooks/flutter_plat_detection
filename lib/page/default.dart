import 'package:flutter/material.dart';
import 'package:plat_number_detection/database/mobil_db.dart';
import 'package:plat_number_detection/models/data_mobil.dart';
import 'package:plat_number_detection/page/add_edit_plate.dart';
import 'package:plat_number_detection/theme.dart';
import 'package:plat_number_detection/widgets/plate_preview.dart';
import 'package:image_picker/image_picker.dart';
class DefaultPage extends StatefulWidget {
  const DefaultPage({super.key});
  @override
  State<DefaultPage> createState() => _DefaultPageState();
}
class _DefaultPageState extends State<DefaultPage> {
  late List<DataMobil> _dataMobil = [];
  final ImagePicker _picker = ImagePicker();
  late String imagePath;
  bool _isLoading = false;
  Future<void> _pickImage(BuildContext context) async {
    final XFile? image = await showModalBottomSheet<XFile?>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera),
                title: const Text('Camera'),
                onTap: () async {
                  final XFile? cameraImage =
                      await _picker.pickImage(source: ImageSource.camera);
                  Navigator.pop(context, cameraImage);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () async {
                  final XFile? galleryImage =
                      await _picker.pickImage(source: ImageSource.gallery);
                  Navigator.pop(context, galleryImage);
                },
              ),
            ],
          ),
        );
      },
    );
    if (image != null) {
      imagePath = image.path;
      debugPrint("imagePath: $imagePath");
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddEditPlate(image: image),
        ),
      );
      if (result != null) {
        await _refreshDB();
      }
    } else {
      debugPrint('No image selected.');
    }
  }
  Future<void> _refreshDB() async {
    setState(() {
      _isLoading = true;
    });
    _dataMobil = await MobilDatabase.instance.getAllData();
    setState(() {
      _isLoading = false;
    });
  }
  @override
  void initState() {
    super.initState();
    _refreshDB();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Plat App',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryColor,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () => _pickImage(context),
        child: const Icon(Icons.camera_alt, color: Colors.white70),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _dataMobil.isEmpty
              ? const Center(child: Text("Data Kosong"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _dataMobil.length,
                  itemBuilder: (context, index) {
                    final plat = _dataMobil[index];
                    return GestureDetector(
                      onTap: () {},
                      child: PlatePreview(
                        dataMobil: plat,
                        callBackFunction: _refreshDB,
                      ),
                    );
                  },
                ),
    );
  }
}