import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DataFormEditWidget extends StatelessWidget {
  const DataFormEditWidget(
      {super.key,
      required this.name,
      required this.image,
      required this.platDaerah,
      required this.platNomor,
      required this.platRegional,
      required this.onChangePlatDaerah,
      required this.onChangePlatNomor,
      required this.onChangePlatRegional,
      });
  final String name;
  final String image;
  final String platDaerah;
  final String platNomor;
  final String platRegional;
  final ValueChanged<String> onChangePlatDaerah;
  final ValueChanged<String> onChangePlatNomor;
  final ValueChanged<String> onChangePlatRegional;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: image.startsWith('http') ?
                Image.network('https://picsum.photos/500', width: 347, height: 195, fit: BoxFit.cover) :
                Image.file(File(image), width: 347, height: 195, fit: BoxFit.cover)
            ),
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
            ])
          ],
        ),
      ),
    );
  }

  Widget _buildPlatDaerah() {
    return TextFormField(
      maxLines: 1,
      initialValue: platDaerah,
      inputFormatters: [CapitalizedTextFormatter()],
      maxLength: 2,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
      decoration: const InputDecoration(
          hintText: 'Daerah', 
          hintStyle: TextStyle(color: Colors.grey),
          counterText: ''
          ),
      onChanged: onChangePlatDaerah,
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
      initialValue: platNomor,
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
      onChanged: onChangePlatNomor,
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
      initialValue: platRegional,
      inputFormatters: [CapitalizedTextFormatter()],
      maxLength: 2,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
      decoration: const InputDecoration(
          hintText: 'BR',
          hintStyle: TextStyle(color: Colors.grey),
          counterText: ''
          ),
      onChanged: onChangePlatRegional,
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