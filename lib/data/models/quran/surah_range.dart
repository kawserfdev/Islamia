// class SurahRange {
//   final int surahNumber;
//   final String surahName;
//   final int startAyah;
//   final int endAyah;

//   const SurahRange({
//     required this.surahNumber,
//     required this.surahName,
//     required this.startAyah,
//     required this.endAyah,
//   });

//   factory SurahRange.fromJson(Map<String, dynamic> json) {
//     return SurahRange(
//       surahNumber: json['surahNumber'],
//       surahName: json['surahName'],
//       startAyah: json['startAyah'],
//       endAyah: json['endAyah'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'surahNumber': surahNumber,
//       'surahName': surahName,
//       'startAyah': startAyah,
//       'endAyah': endAyah,
//     };
//   }
// }