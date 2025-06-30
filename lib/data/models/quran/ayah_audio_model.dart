// To parse this JSON data, do
//
//     final ayahAudioModel = ayahAudioModelFromJson(jsonString);

import 'dart:convert';

AyahAudioModel ayahAudioModelFromJson(String str) => AyahAudioModel.fromJson(json.decode(str));

String ayahAudioModelToJson(AyahAudioModel data) => json.encode(data.toJson());

class AyahAudioModel {
    int? code;
    String? status;
    Data? data;

    AyahAudioModel({
        this.code,
        this.status,
        this.data,
    });

    factory AyahAudioModel.fromJson(Map<String, dynamic> json) => AyahAudioModel(
        code: json["code"],
        status: json["status"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "code": code,
        "status": status,
        "data": data?.toJson(),
    };
}

class Data {
    int? number;
    String? audio;
    List<String>? audioSecondary;
    String? text;
    Edition? edition;
    Surah? surah;
    int? numberInSurah;
    int? juz;
    int? manzil;
    int? page;
    int? ruku;
    int? hizbQuarter;
    bool? sajda;

    Data({
        this.number,
        this.audio,
        this.audioSecondary,
        this.text,
        this.edition,
        this.surah,
        this.numberInSurah,
        this.juz,
        this.manzil,
        this.page,
        this.ruku,
        this.hizbQuarter,
        this.sajda,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        number: json["number"],
        audio: json["audio"],
        audioSecondary: json["audioSecondary"] == null ? [] : List<String>.from(json["audioSecondary"]!.map((x) => x)),
        text: json["text"],
        edition: json["edition"] == null ? null : Edition.fromJson(json["edition"]),
        surah: json["surah"] == null ? null : Surah.fromJson(json["surah"]),
        numberInSurah: json["numberInSurah"],
        juz: json["juz"],
        manzil: json["manzil"],
        page: json["page"],
        ruku: json["ruku"],
        hizbQuarter: json["hizbQuarter"],
        sajda: json["sajda"],
    );

    Map<String, dynamic> toJson() => {
        "number": number,
        "audio": audio,
        "audioSecondary": audioSecondary == null ? [] : List<dynamic>.from(audioSecondary!.map((x) => x)),
        "text": text,
        "edition": edition?.toJson(),
        "surah": surah?.toJson(),
        "numberInSurah": numberInSurah,
        "juz": juz,
        "manzil": manzil,
        "page": page,
        "ruku": ruku,
        "hizbQuarter": hizbQuarter,
        "sajda": sajda,
    };
}

class Edition {
    String? identifier;
    String? language;
    String? name;
    String? englishName;
    String? format;
    String? type;
    dynamic direction;

    Edition({
        this.identifier,
        this.language,
        this.name,
        this.englishName,
        this.format,
        this.type,
        this.direction,
    });

    factory Edition.fromJson(Map<String, dynamic> json) => Edition(
        identifier: json["identifier"],
        language: json["language"],
        name: json["name"],
        englishName: json["englishName"],
        format: json["format"],
        type: json["type"],
        direction: json["direction"],
    );

    Map<String, dynamic> toJson() => {
        "identifier": identifier,
        "language": language,
        "name": name,
        "englishName": englishName,
        "format": format,
        "type": type,
        "direction": direction,
    };
}

class Surah {
    int? number;
    String? name;
    String? englishName;
    String? englishNameTranslation;
    int? numberOfAyahs;
    String? revelationType;

    Surah({
        this.number,
        this.name,
        this.englishName,
        this.englishNameTranslation,
        this.numberOfAyahs,
        this.revelationType,
    });

    factory Surah.fromJson(Map<String, dynamic> json) => Surah(
        number: json["number"],
        name: json["name"],
        englishName: json["englishName"],
        englishNameTranslation: json["englishNameTranslation"],
        numberOfAyahs: json["numberOfAyahs"],
        revelationType: json["revelationType"],
    );

    Map<String, dynamic> toJson() => {
        "number": number,
        "name": name,
        "englishName": englishName,
        "englishNameTranslation": englishNameTranslation,
        "numberOfAyahs": numberOfAyahs,
        "revelationType": revelationType,
    };
}
