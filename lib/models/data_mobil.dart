const String tableDB = 'platNomor';

class DataMobilFields {
  static const String id = 'id';
  static const String name = 'name';
  static const String image = 'image';
  static const String platDaerah = 'platDaerah';
  static const String platNomor = 'platNomor';
  static const String platRegional = 'platRegional';
  static const String jenisKendaraan = 'jenisKendaraan';
  static const String timestamp = 'timestamp';
}

class DataMobil {
  final int? id;
  final String name;
  final String image;
  final String platDaerah;
  final String platNomor;
  final String platRegional;
  final String jenisKendaraan;
  final DateTime timestamp;

  DataMobil(
      {this.id,
      required this.name,
      required this.image,
      required this.platDaerah,
      required this.platNomor,
      required this.platRegional,
      required this.jenisKendaraan,
      required this.timestamp});

  DataMobil copy(
      {int? id,
      String? name,
      String? image,
      String? platDaerah,
      String? platNomor,
      String? platRegional,
      String? jenisKendaraan,
      DateTime? timestamp}) {
    return DataMobil(
        id: id,
        name: name ?? this.name,
        image: image ?? this.image,
        platDaerah: platDaerah ?? this.platDaerah,
        platNomor: platNomor ?? this.platNomor,
        platRegional: platRegional ?? this.platRegional,
        jenisKendaraan: jenisKendaraan ?? this.jenisKendaraan,
        timestamp: timestamp ?? this.timestamp);
  }

  static DataMobil fromJSON(Map<String, Object?> json) => DataMobil(
        id: json[DataMobilFields.id] as int?,
        name: json[DataMobilFields.name].toString(),
        image: json[DataMobilFields.image].toString(),
        platDaerah: json[DataMobilFields.platDaerah].toString(),
        platNomor: json[DataMobilFields.platNomor].toString(),
        platRegional: json[DataMobilFields.platRegional].toString(),
        jenisKendaraan: json[DataMobilFields.jenisKendaraan]?.toString() ?? '',
        timestamp: DateTime.parse(json[DataMobilFields.timestamp] as String),
      );

  Map<String, Object?> toJson() {
    return {
      DataMobilFields.id: id,
      DataMobilFields.name: name,
      DataMobilFields.image: image,
      DataMobilFields.platDaerah: platDaerah,
      DataMobilFields.platNomor: platNomor,
      DataMobilFields.platRegional: platRegional,
      DataMobilFields.jenisKendaraan: jenisKendaraan,
      DataMobilFields.timestamp: timestamp.toIso8601String()
    };
  }

  String jointString() {
    return DataMobilFields.platDaerah +
        DataMobilFields.platNomor +
        DataMobilFields.platRegional;
  }
}
