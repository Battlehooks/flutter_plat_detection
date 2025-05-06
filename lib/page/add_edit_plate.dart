import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plat_number_detection/database/mobil_db.dart';
import 'package:plat_number_detection/models/data_mobil.dart';
import 'package:plat_number_detection/services/car_detection_service.dart';
import 'package:plat_number_detection/theme.dart';
import 'package:plat_number_detection/widgets/plate_form_widget.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
class AddEditPlate extends StatefulWidget {
  final DataMobil? mobil;
  final XFile? image;
  const AddEditPlate({super.key, this.mobil, this.image});
  
  @override
  _AddEditPlateState createState() => _AddEditPlateState();
}
class _AddEditPlateState extends State<AddEditPlate> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  File? _image;
  String _platDaerah = '';
  String _platNomor = '';
  String _platRegional = '';
  String _jenisKendaraan = '';
  List<double> _plateBox = [];
  bool _isUpdateForm = false;
  bool _isLoading = true;
  final _platDaerahController = TextEditingController();
  final _platNomorController = TextEditingController();
  final _platRegionalController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _initializeForm();
  }
  Future<void> _initializeForm() async {
    _name = widget.mobil?.name ?? '';
    _platDaerah = widget.mobil?.platDaerah ?? '';
    _platNomor = widget.mobil?.platNomor ?? '';
    _platRegional = widget.mobil?.platRegional ?? '';
    _jenisKendaraan = widget.mobil?.jenisKendaraan ?? '';
    _plateBox = widget.mobil?.plateBox ?? [];
    _isUpdateForm = widget.mobil != null;

    _platDaerahController.text = _platDaerah;
    _platNomorController.text = _platNomor;
    _platRegionalController.text = _platRegional;

    if (_isUpdateForm) {
      final imageFile = File(widget.mobil!.image);
      if (imageFile.existsSync()) {
        _image = imageFile;
      }
    } else if (widget.image != null) {
      _image = File(widget.image!.path);
      await _handleImagePredictionAndSave(widget.image!);
      await _saveImage(widget.image!);
    }

    setState(() {
      _isLoading = false;
    });
  }
  Future<void> _handleImagePredictionAndSave(XFile imageFile) async {
    try {
      final detection = await detectVehicleAndPlate(File(imageFile.path));
      if (detection != null) {
        setState(() {
          _jenisKendaraan = detection.vehicleType ?? "";
        });
        if (detection.plateText != null && detection.plateText!.isNotEmpty) {
          _prefillPlateFromText(detection.plateText!);
        }
        debugPrint('Detected vehicle type: ${detection.vehicleType}');
        debugPrint('Vehicle bounding box: ${detection.vehicleBox}');
        if (detection.plateBox != null) {
          debugPrint('Plate bounding box: ${detection.plateBox}');
        }
        debugPrint('Plate Prediction: ${detection.plateText}');
      } else {
        setState(() {
          _jenisKendaraan = "";
        });
      }
    } catch (e) {
      debugPrint('Error detecting vehicle: $e');
    }
    await _saveImage(imageFile);
  }
  void _prefillPlateFromText(String plateText) {
    debugPrint("Confirming plate text: $plateText");
    final parts = plateText.trim().split(' ');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (parts.length >= 2) {
        debugPrint("→ Assigned: ${parts[0]} ${parts.length > 1 ? parts[1] : ''}");  // 👈 Add this
        _platDaerahController.text = parts[0]; // First part -> Plat Daerah
      
        // Check if second part is purely number
        if (RegExp(r'^\d+$').hasMatch(parts[1])) {
          _platNomorController.text = parts[1]; // Second part (if number) -> Plat Nomor
        } else {
          _platNomorController.text = ''; // if not number, leave empty
        }
      
        if (parts.length > 2) {
          // Join the rest if there are more than 2 parts
          _platRegionalController.text = parts.sublist(2).join(' '); // Third part and beyond -> Plat Regional
        } else {
          _platRegionalController.text = '';
        }
      } else {
        debugPrint("Plate text format not recognized: $plateText");
      }
    });
  }
  Future<void> _saveImage(XFile imageFile) async {
    try {
      final sourceFile = File(imageFile.path);
      if (!await sourceFile.exists()) {
        debugPrint("File does not exist: ${sourceFile.path}");
        return;
      }
      final directory = await getApplicationDocumentsDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
      final filePath = join(directory.path, fileName);
      // Create a copy of the image file
      await sourceFile.copy(filePath).then((savedImage) {
        setState(() {
          _image = savedImage;
        });
      }).catchError((error) {
        debugPrint('Error copying image: $error');
      });
    } catch (e) {
      debugPrint('Error saving image: $e');
      // Handle the error appropriately, maybe show a user message
    }
  }
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('$_platDaerah $_platNomor $_platRegional'),
        ),
        body: Form(
          key: _formKey,
          child: Column(children: [
            DataFormEditWidget(
              name: _name,
              image: _image?.path ?? '',
              platDaerahController: _platDaerahController,
              platNomorController: _platNomorController,
              platRegionalController: _platRegionalController,
              jenisKendaraan: _jenisKendaraan,
              plateBox: _plateBox,
              onChangePlatDaerah: (value) {
                setState(() {
                  _platDaerah = value;
                });
              },
              onChangePlatNomor: (value) {
                setState(() {
                  _platNomor = value;
                });
              },
              onChangePlatRegional: (value) {
                setState(() {
                  _platRegional = value;
                });
              },
            ),
            _buildBtnSave(context),
            if (_isUpdateForm) _buildBtnDelete(context),
          ]),
        ),
      ),
    );
  }
  Widget _buildBtnSave(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      child: ElevatedButton(
        onPressed: () async {
          final isValid = _formKey.currentState!.validate();
          // ✅ sync values from controller before saving
          _platDaerah = _platDaerahController.text;
          _platNomor = _platNomorController.text;
          _platRegional = _platRegionalController.text;
          if (isValid) {
            if (_isUpdateForm) {
              await _updateNote();
            } else {
              await _addNote();
            }
            Navigator.pop(context, true);
          }
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(primaryColor),
          shape: MaterialStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          )),
        ),
        child: const Text('Save', style: TextStyle(color: Colors.white)),
      ),
    );
  }
  Widget _buildBtnDelete(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      child: ElevatedButton(
        onPressed: () async {
          if (_isUpdateForm) {
            // Show a confirmation dialog before deleting
            bool? confirm = await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Confirm Deletion'),
                  content: const Text('Are you sure you want to delete this item?'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                    ),
                    TextButton(
                      child: const Text('Delete'),
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                    ),
                  ],
                );
              },
            );
            // If the user confirmed, delete the data
            if (confirm == true) {
              await MobilDatabase.instance.deleteDataById(widget.mobil!.id!);
              Navigator.pop(context, true);
            }
          }
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
        child: const Text('Delete', style: TextStyle(color: Colors.white)),
      ),
    );
  }
  Future<void> _addNote() async {
    final note = DataMobil(
      name: _name,
      image: _image?.path ?? '',
      platDaerah: _platDaerah,
      platNomor: _platNomor,
      platRegional: _platRegional,
      jenisKendaraan: _jenisKendaraan,
      plateBox: _plateBox,
      timestamp: DateTime.now(),
    );
    await MobilDatabase.instance.create(note);
  }
  Future<void> _updateNote() async {
    final updateNote = DataMobil(
      id: widget.mobil?.id,
      name: _name,
      image: _image?.path ?? '',
      platDaerah: _platDaerah,
      platNomor: _platNomor,
      platRegional: _platRegional,
      jenisKendaraan: _jenisKendaraan,
      plateBox: _plateBox,
      timestamp: DateTime.now(),
    );
    await MobilDatabase.instance.updateNote(updateNote);
  }
}