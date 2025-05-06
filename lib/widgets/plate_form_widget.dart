import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DataFormEditWidget extends StatefulWidget {
  const DataFormEditWidget(
      {super.key,
      required this.name,
      required this.image,
      required this.platDaerahController,
      required this.platNomorController,
      required this.platRegionalController,
      required this.jenisKendaraan,
      required this.plateBox,
      required this.onChangePlatDaerah,
      required this.onChangePlatNomor,
      required this.onChangePlatRegional,
      });
  final String name;
  final String image;
  final TextEditingController platDaerahController;
  final TextEditingController platNomorController;
  final TextEditingController platRegionalController;
  final String jenisKendaraan;
  final List<double> plateBox;
  final ValueChanged<String> onChangePlatDaerah;
  final ValueChanged<String> onChangePlatNomor;
  final ValueChanged<String> onChangePlatRegional;

  @override
  _DataFormEditWidgetState createState() => _DataFormEditWidgetState();
}

const double _displayW = 347;
const double _displayH = 195;
const double _inputW   = 640;   // size fed to the detector – adjust if different
const double _inputH   = 640;

class _DataFormEditWidgetState extends State<DataFormEditWidget> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildImageWithBox(),
            const SizedBox(height: 48),
            Row(children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Plat Daerah',
                        style:
                            TextStyle(fontSize: 12, fontWeight: FontWeight.w300)),
                    const SizedBox(height: 8.0),
                    _buildPlatDaerah()
                  ],
                ),
              ),
              const SizedBox(width: 64.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Plat Nomor',
                        style:
                            TextStyle(fontSize: 12, fontWeight: FontWeight.w300)),
                    const SizedBox(height: 8.0),
                    _buildPlatNomor()
                  ],
                ),
              ),
              const SizedBox(width: 64.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Plat Regional',
                        style:
                            TextStyle(fontSize: 12, fontWeight: FontWeight.w300)),
                    const SizedBox(height: 8.0),
                    _buildPlatRegional()
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 24.0),
            if (widget.jenisKendaraan.isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Jenis Kendaraan: ${widget.jenisKendaraan}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 24.0)
          ],
        ),
      ),
    );
  }

  Widget _buildImageWithBox() {
    final baseImage = ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: widget.image.startsWith('http')
          ? Image.network(widget.image, width: _displayW, height: _displayH, fit: BoxFit.cover)
          : Image.file(File(widget.image), width: _displayW, height: _displayH, fit: BoxFit.cover),
    );

    if (widget.plateBox.length != 4) return baseImage;

    final scaleX = _displayW / _inputW;
    final scaleY = _displayH / _inputH;
    final left   = widget.plateBox[0] * scaleX;
    final top    = widget.plateBox[1] * scaleY;
    final boxW   = widget.plateBox[2] * scaleX;
    final boxH   = widget.plateBox[3] * scaleY;

    return Stack(
      children: [
        baseImage,
        Positioned(
          left: left,
          top:  top,
          child: Container(
            width:  boxW,
            height: boxH,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlatDaerah() {
    return TextFormField(
      maxLines: 1,
      controller: widget.platDaerahController,
      inputFormatters: [CapitalizedTextFormatter()],
      maxLength: 2,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
      decoration: const InputDecoration(
          hintText: 'Daerah', 
          hintStyle: TextStyle(color: Colors.grey),
          counterText: ''
          ),
      onChanged: widget.onChangePlatDaerah,
      validator: (platDaerah) {
        return platDaerah != null && platDaerah.isEmpty
            ? 'Plat Daerah tidak bisa kosong'
            : null;
      },
    );
  }

  Widget _buildPlatNomor() {
    return TextFormField(
      maxLines: 1,
      controller: widget.platNomorController,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
      ],
      maxLength: 4,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
      decoration: const InputDecoration(
          hintText: '1234',
          hintStyle: TextStyle(color: Colors.grey),
          counterText: ''
          ),
      onChanged: widget.onChangePlatNomor,
      validator: (platNomor) {
        return platNomor != null && platNomor.isEmpty
            ? 'Plat Nomor tidak bisa kosong'
            : null;
      },
    );
  }

  Widget _buildPlatRegional() {
    return TextFormField(
      maxLines: 1,
      controller: widget.platRegionalController,
      inputFormatters: [CapitalizedTextFormatter()],
      maxLength: 3,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
      decoration: const InputDecoration(
          hintText: 'BR',
          hintStyle: TextStyle(color: Colors.grey),
          counterText: ''
          ),
      onChanged: widget.onChangePlatRegional,
    );
  }
}

class CapitalizedTextFormatter extends TextInputFormatter {
  @override 
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}