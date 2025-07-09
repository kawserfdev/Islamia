// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:islamia/core/providers/quran/audio_provider.dart';
// import 'package:islamia/core/providers/quran/settings_provider.dart';
// import 'package:islamia/data/models/quran/reciter_model.dart';

// class QuranSettingsScreen extends ConsumerWidget {
//   const QuranSettingsScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final settings = ref.watch(quranSettingsProvider);
//     final settingsNotifier = ref.read(quranSettingsProvider.notifier);
//     final reciterListAsync = ref.watch(reciterListProvider);

//     return Scaffold(
//       backgroundColor: settings.nightMode ? Colors.black : Colors.white,
//       appBar: AppBar(
//         title: const Text('Quran Settings'),
//         backgroundColor: settings.nightMode ? Colors.grey[900] : Colors.green[700],
//         foregroundColor: Colors.white,
//         actions: [
//           TextButton(
//             onPressed: () => _showResetDialog(context, settingsNotifier),
//             child: const Text('Reset', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           // Display Settings
//           _buildSectionHeader('Display Settings', settings),
//           Card(
//             color: settings.nightMode ? Colors.grey[800] : Colors.white,
//             child: Column(
//               children: [
//                 SwitchListTile(
//                   title: Text(
//                     'Night Mode',
//                     style: TextStyle(
//                       color: settings.nightMode ? Colors.white : Colors.black,
//                     ),
//                   ),
//                   subtitle: Text(
//                     'Dark theme for comfortable reading',
//                     style: TextStyle(
//                       color: settings.nightMode ? Colors.grey[300] : Colors.grey[600],
//                     ),
//                   ),
//                   value: settings.nightMode,
//                   onChanged: (value) => settingsNotifier.setNightMode(value),
//                 ),
//                 const Divider(height: 1),
//                 SwitchListTile(
//                   title: Text(
//                     'Dual Column Layout',
//                     style: TextStyle(
//                       color: settings.nightMode ? Colors.white : Colors.black,
//                     ),
//                   ),
//                   subtitle: Text(
//                     'Show Arabic and translation side by side',
//                     style: TextStyle(
//                       color: settings.nightMode ? Colors.grey[300] : Colors.grey[600],
//                     ),
//                   ),
//                   value: settings.dualColumnLayout,
//                   onChanged: (value) => settingsNotifier.setDualColumnLayout(value),
//                 ),
//                 const Divider(height: 1),
//                 SwitchListTile(
//                   title: Text(
//                     'Show Transliteration',
//                     style: TextStyle(
//                       color: settings.nightMode ? Colors.white : Colors.black,
//                     ),
//                   ),
//                   subtitle: Text(
//                     'Display phonetic pronunciation',
//                     style: TextStyle(
//                       color: settings.nightMode ? Colors.grey[300] : Colors.grey[600],
//                     ),
//                   ),
//                   value: settings.showTransliteration,
//                   onChanged: (value) => settingsNotifier.setShowTransliteration(value),
//                 ),
//                 const Divider(height: 1),
//                 SwitchListTile(
//                   title: Text(
//                     'Show Tafsir',
//                     style: TextStyle(
//                       color: settings.nightMode ? Colors.white : Colors.black,
//                     ),
//                   ),
//                   subtitle: Text(
//                     'Display verse commentary',
//                     style: TextStyle(
//                       color: settings.nightMode ? Colors.grey[300] : Colors.grey[600],
//                     ),
//                   ),
//                   value: settings.showTafsir,
//                   onChanged: (value) => settingsNotifier.setShowTafsir(value),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 24),

//           // Font Settings
//           _buildSectionHeader('Font Settings', settings),
//           Card(
//             color: settings.nightMode ? Colors.grey[800] : Colors.white,
//             child: Column(
//               children: [
//                 ListTile(
//                   title: Text(
//                     'Arabic Font Size',
//                     style: TextStyle(
//                       color: settings.nightMode ? Colors.white : Colors.black,
//                     ),
//                   ),
//                   subtitle: Slider(
//                     value: settings.arabicFontSize,
//                     min: 14,
//                     max: 40,
//                     divisions: 26,
//                     label: '${settings.arabicFontSize.round()}',
//                     onChanged: (value) => settingsNotifier.setArabicFontSize(value),
//                   ),
//                   trailing: Text(
//                     '${settings.arabicFontSize.round()}',
//                     style: TextStyle(
//                       color: settings.nightMode ? Colors.white : Colors.black,
//                     ),
//                   ),
//                 ),
//                 const Divider(height: 1),
//                 ListTile(
//                   title: Text(
//                     'Translation Font Size',
//                     style: TextStyle(
//                       color: settings.nightMode ? Colors.white : Colors.black,
//                     ),
//                   ),
//                   subtitle: Slider(
//                     value: settings.translationFontSize,
//                     min: 12,
//                     max: 24,
//                     divisions: 12,
//                     label: '${settings.translationFontSize.round()}',
//                     onChanged: (value) => settingsNotifier.setTranslationFontSize(value),
//                   ),
//                   trailing: Text(
//                     '${settings.translationFontSize.round()}',
//                     style: TextStyle(
//                       color: settings.nightMode ? Colors.white : Colors.black,
//                     ),
//                   ),
//                 ),
//                 const Divider(height: 1),
//                 ListTile(
//                   title: Text(
//                     'Arabic Font Family',
//                     style: TextStyle(
//                       color: settings.nightMode ? Colors.white : Colors.black,
//                     ),
//                   ),
//                   subtitle: Text(
//                     settings.fontFamily,
//                     style: TextStyle(
//                       color: settings.nightMode ? Colors.grey[300] : Colors.grey[600],
//                     ),
//                   ),
//                   trailing: Icon(
//                     Icons.arrow_forward_ios,
//                     size: 16,
//                     color: settings.nightMode ? Colors.white : Colors.black,
//                   ),
//                   onTap: () => _showFontFamilyDialog(context, settingsNotifier, settings),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 24),

//           // Translation Settings
//           _buildSectionHeader('Translation Settings', settings),
//           Card(
//             color: settings.nightMode ? Colors.grey[800] : Colors.white,
//             child: Column(
//               children: [
//                 ListTile(
//                   title: Text(
//                     'Primary Translation',
//                     style: TextStyle(
//                       color: settings.nightMode ? Colors.white : Colors.black,
//                     ),
//                   ),
//                   subtitle: Text(
//                     _getTranslationName(settings.selectedTranslation),
//                     style: TextStyle(
//                       color: settings.nightMode ? Colors.grey[300] : Colors.grey[600],
//                     ),
//                   ),
//                   trailing: Icon(
//                     Icons.arrow_forward_ios,
//                     size: 16,
//                     color: settings.nightMode ? Colors.white : Colors.black,
//                   ),
//                   onTap: () => _showTranslationDialog(context, settingsNotifier, settings),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 24),

//           // Audio Settings
//           _buildSectionHeader('Audio Settings', settings),
//           Card(
//             color: settings.nightMode ? Colors.grey[800] : Colors.white,
//             child: Column(
//               children: [
//                 reciterListAsync.when(
//                   data: (reciters) => ListTile(
//                     title: Text(
//                       'Default Reciter',
//                       style: TextStyle(
//                         color: settings.nightMode ? Colors.white : Colors.black,
//                       ),
//                     ),
//                     subtitle: Text(
//                       _getReciterName(reciters, settings.selectedReciter),
//                       style: TextStyle(
//                         color: settings.nightMode ? Colors.grey[300] : Colors.grey[600],
//                       ),
//                     ),
//                     trailing: Icon(
//                       Icons.arrow_forward_ios,
//                       size: 16,
//                       color: settings.nightMode ? Colors.white : Colors.black,
//                     ),
//                     onTap: () => _showReciterDialog(context, settingsNotifier, reciters, settings),
//                   ),
//                   loading: () => ListTile(
//                     title: Text(
//                       'Default Reciter',
//                       style: TextStyle(
//                         color: settings.nightMode ? Colors.white : Colors.black,
//                       ),
//                     ),
//                     subtitle: Text(
//                       'Loading...',
//                       style: TextStyle(
//                         color: settings.nightMode ? Colors.grey[300] : Colors.grey[600],
//                       ),
//                     ),
//                     trailing: const CircularProgressIndicator(),
//                   ),
//                   error: (error, stack) => ListTile(
//                     title: Text(
//                       'Default Reciter',
//                       style: TextStyle(
//                         color: settings.nightMode ? Colors.white : Colors.black,
//                       ),
//                     ),
//                     subtitle: Text(
//                       'Error: ${error.toString()}',
//                       style: TextStyle(color: Colors.red),
//                     ),
//                     trailing: const Icon(Icons.error, color: Colors.red),
//                   ),
//                 ),
//                 const Divider(height: 1),
//                 SwitchListTile(
//                   title: Text(
//                     'Auto Scroll',
//                     style: TextStyle(
//                       color: settings.nightMode ? Colors.white : Colors.black,
//                     ),
//                   ),
//                   subtitle: Text(
//                     'Automatically scroll to playing verse',
//                     style: TextStyle(
//                       color: settings.nightMode ? Colors.grey[300] : Colors.grey[600],
//                     ),
//                   ),
//                   value: settings.autoScroll,
//                   onChanged: (value) => settingsNotifier.setAutoScroll(value),
//                 ),
//                 const Divider(height: 1),
//                 SwitchListTile(
//                   title: Text(
//                     'Highlight Current Ayah',
//                     style: TextStyle(
//                       color: settings.nightMode ? Colors.white : Colors.black,
//                     ),
//                   ),
//                   subtitle: Text(
//                     'Highlight the currently playing verse',
//                     style: TextStyle(
//                       color: settings.nightMode ? Colors.grey[300] : Colors.grey[600],
//                     ),
//                   ),
//                   value: settings.highlightCurrentAyah,
//                   onChanged: (value) => settingsNotifier.setHighlightCurrentAyah(value),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 24),

//           // Preview Section
//           _buildSectionHeader('Preview', settings),
//           Card(
//             color: settings.nightMode ? Colors.grey[800] : Colors.white,
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Arabic Text Preview',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: settings.nightMode ? Colors.white : Colors.black,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
//                     style: TextStyle(
//                       fontSize: settings.arabicFontSize,
//                       fontFamily: settings.fontFamily,
//                       color: settings.nightMode ? Colors.white : Colors.black,
//                       height: 1.8,
//                     ),
//                     textAlign: TextAlign.right,
//                     textDirection: TextDirection.rtl,
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     'Translation Preview',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: settings.nightMode ? Colors.white : Colors.black,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
//                     style: TextStyle(
//                       fontSize: settings.translationFontSize,
//                       color: settings.nightMode ? Colors.grey[300] : Colors.grey[700],
//                       height: 1.5,
//                     ),
//                   ),
//                   if (settings.showTransliteration) ...[
//                     const SizedBox(height: 8),
//                     Text(
//                       'Bismillahi ar-rahmani ar-raheem',
//                       style: TextStyle(
//                         fontSize: settings.translationFontSize - 2,
//                         color: settings.nightMode ? Colors.blue[300] : Colors.blue[600],
//                         fontStyle: FontStyle.italic,
//                         height: 1.4,
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//           ),

//           const SizedBox(height: 32),
//         ],
//       ),
//     );
//   }

//   Widget _buildSectionHeader(String title, QuranSettings settings) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Text(
//         title,
//         style: TextStyle(
//           fontSize: 18,
//           fontWeight: FontWeight.bold,
//           color: settings.nightMode ? Colors.white : Colors.black87,
//         ),
//       ),
//     );
//   }

//   void _showResetDialog(
//     BuildContext context,
//     QuranSettingsNotifier settingsNotifier,
//   ) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Reset Settings'),
//         content: const Text(
//           'Are you sure you want to reset all settings to default values?',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               settingsNotifier.resetToDefaults();
//               Navigator.of(context).pop();
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Settings reset to defaults')),
//               );
//             },
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             child: const Text('Reset'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showFontFamilyDialog(
//     BuildContext context,
//     QuranSettingsNotifier settingsNotifier,
//     QuranSettings settings,
//   ) {
//     final fontFamilies = [
//       'UthmanicHafs',
//       'Noto Naskh Arabic',
//       'Amiri',
//       'Scheherazade New',
//       'Lateef',
//       'Markazi Text',
//       'Cairo',
//     ];

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Select Arabic Font'),
//         content: SizedBox(
//           width: double.maxFinite,
//           child: ListView.builder(
//             shrinkWrap: true,
//             itemCount: fontFamilies.length,
//             itemBuilder: (context, index) {
//               final fontFamily = fontFamilies[index];
//               final isSelected = settings.fontFamily == fontFamily;
              
//               return ListTile(
//                 title: Text(
//                   fontFamily,
//                   style: TextStyle(
//                     fontFamily: fontFamily,
//                     fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                   ),
//                 ),
//                 subtitle: Text(
//                   'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
//                   style: TextStyle(
//                     fontFamily: fontFamily,
//                     fontSize: 16,
//                   ),
//                   textDirection: TextDirection.rtl,
//                 ),
//                 leading: Radio<String>(
//                   value: fontFamily,
//                   groupValue: settings.fontFamily,
//                   onChanged: (value) {
//                     if (value != null) {
//                       settingsNotifier.setFontFamily(value);
//                       Navigator.of(context).pop();
//                     }
//                   },
//                 ),
//                 onTap: () {
//                   settingsNotifier.setFontFamily(fontFamily);
//                   Navigator.of(context).pop();
//                 },
//               );
//             },
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Cancel'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showTranslationDialog(
//     BuildContext context,
//     QuranSettingsNotifier settingsNotifier,
//     QuranSettings settings,
//   ) {
//     final translations = [
//       {'id': 'en.sahih', 'name': 'Sahih International (English)'},
//       {'id': 'en.pickthall', 'name': 'Pickthall (English)'},
//       {'id': 'en.yusufali', 'name': 'Yusuf Ali (English)'},
//       {'id': 'bn.bengali', 'name': 'Bengali Translation'},
//       {'id': 'ur.jalandhry', 'name': 'Urdu (Jalandhry)'},
//       {'id': 'fr.hamidullah', 'name': 'French (Hamidullah)'},
//       {'id': 'es.cortes', 'name': 'Spanish (Cortes)'},
//       {'id': 'de.bubenheim', 'name': 'German (Bubenheim)'},
//       {'id': 'tr.diyanet', 'name': 'Turkish (Diyanet)'},
//       {'id': 'id.indonesian', 'name': 'Indonesian'},
//     ];

//     showDialog(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: const Text('Select Translation'),
//             content: SizedBox(
//               width: double.maxFinite,
//               child: ListView.builder(
//                 shrinkWrap: true,
//                 itemCount: translations.length,
//                 itemBuilder: (context, index) {
//                   final translation = translations[index];
//                   final isSelected =
//                       settings.selectedTranslation == translation['id'];

//                   return ListTile(
//                     title: Text(
//                       translation['name']!,
//                       style: TextStyle(
//                         fontWeight:
//                             isSelected ? FontWeight.bold : FontWeight.normal,
//                       ),
//                     ),
//                     leading: Radio<String>(
//                       value: translation['id']!,
//                       groupValue: settings.selectedTranslation,
//                       onChanged: (value) {
//                         if (value != null) {
//                           settingsNotifier.setSelectedTranslation(value);
//                           Navigator.of(context).pop();
//                         }
//                       },
//                     ),
//                     onTap: () {
//                       settingsNotifier.setSelectedTranslation(
//                         translation['id']!,
//                       );
//                       Navigator.of(context).pop();
//                     },
//                   );
//                 },
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(),
//                 child: const Text('Cancel'),
//               ),
//             ],
//           ),
//     );
//   }

//   void _showReciterDialog(
//     BuildContext context,
//     QuranSettingsNotifier settingsNotifier,
//     List<ReciterModel> reciters,
//     QuranSettings settings,
//   ) {
//     showDialog(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: const Text('Select Reciter'),
//             content: SizedBox(
//               width: double.maxFinite,
//               height: 400,
//               child: ListView.builder(
//                 itemCount: reciters.length,
//                 itemBuilder: (context, index) {
//                   final reciter = reciters[index];
//                   final isSelected =
//                       settings.selectedReciter == reciter.identifier;

//                   return ListTile(
//                     title: Text(
//                       reciter.englishName,
//                       style: TextStyle(
//                         fontWeight:
//                             isSelected ? FontWeight.bold : FontWeight.normal,
//                       ),
//                     ),
//                     subtitle: Text(reciter.name),
//                     leading: Radio<String>(
//                       value: reciter.identifier,
//                       groupValue: settings.selectedReciter,
//                       onChanged: (value) {
//                         if (value != null) {
//                           settingsNotifier.setSelectedReciter(value);
//                           Navigator.of(context).pop();
//                         }
//                       },
//                     ),
//                     trailing:
//                         reciter.isPopular
//                             ? const Icon(
//                               Icons.star,
//                               color: Colors.amber,
//                               size: 16,
//                             )
//                             : null,
//                     onTap: () {
//                       settingsNotifier.setSelectedReciter(reciter.identifier);
//                       Navigator.of(context).pop();
//                     },
//                   );
//                 },
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(),
//                 child: const Text('Cancel'),
//               ),
//             ],
//           ),
//     );
//   }

//   String _getTranslationName(String translationId) {
//     final translations = {
//       'en.sahih': 'Sahih International (English)',
//       'en.pickthall': 'Pickthall (English)',
//       'en.yusufali': 'Yusuf Ali (English)',
//       'bn.bengali': 'Bengali Translation',
//       'ur.jalandhry': 'Urdu (Jalandhry)',
//       'fr.hamidullah': 'French (Hamidullah)',
//       'es.cortes': 'Spanish (Cortes)',
//       'de.bubenheim': 'German (Bubenheim)',
//       'tr.diyanet': 'Turkish (Diyanet)',
//       'id.indonesian': 'Indonesian',
//     };
//     return translations[translationId] ?? translationId;
//   }

//   String _getReciterName(List<ReciterModel> reciters, String reciterId) {
//     try {
//       final reciter = reciters.firstWhere((r) => r.identifier == reciterId);
//       return reciter.englishName;
//     } catch (e) {
//       return reciterId;
//     }
//   }
// }

// // QuranSettingsState model
// // class QuranSettingsState {
// //   final bool nightMode;
// //   final double arabicFontSize;
// //   final double translationFontSize;
// //   final String fontFamily;
// //   final String selectedTranslation;
// //   final String selectedReciter;
// //   final bool showTransliteration;
// //   final bool showTafsir;
// //   final bool dualColumnLayout;
// //   final bool autoScroll;
// //   final bool highlightCurrentAyah;

// //   const QuranSettingsState({
// //     this.nightMode = false,
// //     this.arabicFontSize = 24.0,
// //     this.translationFontSize = 16.0,
// //     this.fontFamily = 'Noto Naskh Arabic',
// //     this.selectedTranslation = 'en.sahih',
// //     this.selectedReciter = 'ar.alafasy',
// //     this.showTransliteration = false,
// //     this.showTafsir = false,
// //     this.dualColumnLayout = false,
// //     this.autoScroll = true,
// //     this.highlightCurrentAyah = true,
// //   });

// //   QuranSettingsState copyWith({
// //     bool? nightMode,
// //     double? arabicFontSize,
// //     double? translationFontSize,
// //     String? fontFamily,
// //     String? selectedTranslation,
// //     String? selectedReciter,
// //     bool? showTransliteration,
// //     bool? showTafsir,
// //     bool? dualColumnLayout,
// //     bool? autoScroll,
// //     bool? highlightCurrentAyah,
// //   }) {
// //     return QuranSettingsState(
// //       nightMode: nightMode ?? this.nightMode,
// //       arabicFontSize: arabicFontSize ?? this.arabicFontSize,
// //       translationFontSize: translationFontSize ?? this.translationFontSize,
// //       fontFamily: fontFamily ?? this.fontFamily,
// //       selectedTranslation: selectedTranslation ?? this.selectedTranslation,
// //       selectedReciter: selectedReciter ?? this.selectedReciter,
// //       showTransliteration: showTransliteration ?? this.showTransliteration,
// //       showTafsir: showTafsir ?? this.showTafsir,
// //       dualColumnLayout: dualColumnLayout ?? this.dualColumnLayout,
// //       autoScroll: autoScroll ?? this.autoScroll,
// //       highlightCurrentAyah: highlightCurrentAyah ?? this.highlightCurrentAyah,
// //     );
// //   }

// //   Map<String, dynamic> toJson() {
// //     return {
// //       'nightMode': nightMode,
// //       'arabicFontSize': arabicFontSize,
// //       'translationFontSize': translationFontSize,
// //       'fontFamily': fontFamily,
// //       'selectedTranslation': selectedTranslation,
// //       'selectedReciter': selectedReciter,
// //       'showTransliteration': showTransliteration,
// //       'showTafsir': showTafsir,
// //       'dualColumnLayout': dualColumnLayout,
// //       'autoScroll': autoScroll,
// //       'highlightCurrentAyah': highlightCurrentAyah,
// //     };
// //   }

// //   factory QuranSettingsState.fromJson(Map<String, dynamic> json) {
// //     return QuranSettingsState(
// //       nightMode: json['nightMode'] ?? false,
// //       arabicFontSize: (json['arabicFontSize'] ?? 24.0).toDouble(),
// //       translationFontSize: (json['translationFontSize'] ?? 16.0).toDouble(),
// //       fontFamily: json['fontFamily'] ?? 'Noto Naskh Arabic',
// //       selectedTranslation: json['selectedTranslation'] ?? 'en.sahih',
// //       selectedReciter: json['selectedReciter'] ?? 'ar.alafasy',
// //       showTransliteration: json['showTransliteration'] ?? false,
// //       showTafsir: json['showTafsir'] ?? false,
// //       dualColumnLayout: json['dualColumnLayout'] ?? false,
// //       autoScroll: json['autoScroll'] ?? true,
// //       highlightCurrentAyah: json['highlightCurrentAyah'] ?? true,
// //     );
// //   }
// // }

// // // QuranSettingsNotifier
// // class QuranSettingsNotifier extends StateNotifier<QuranSettingsState> {
// //   static const String _settingsKey = 'quran_settings';

// //   QuranSettingsNotifier() : super(const QuranSettingsState()) {
// //     _loadSettings();
// //   }

// //   Future<void> _loadSettings() async {
// //     try {
// //       final prefs = await SharedPreferences.getInstance();
// //       final settingsJson = prefs.getString(_settingsKey);

// //       if (settingsJson != null) {
// //         final settingsMap = jsonDecode(settingsJson) as Map<String, dynamic>;
// //         state = QuranSettingsState.fromJson(settingsMap);
// //       }
// //     } catch (e) {
// //       print('Error loading settings: $e');
// //     }
// //   }

// //   Future<void> _saveSettings() async {
// //     try {
// //       final prefs = await SharedPreferences.getInstance();
// //       final settingsJson = jsonEncode(state.toJson());
// //       await prefs.setString(_settingsKey, settingsJson);
// //     } catch (e) {
// //       print('Error saving settings: $e');
// //     }
// //   }

// //   void setNightMode(bool value) {
// //     state = state.copyWith(nightMode: value);
// //     _saveSettings();
// //   }

// //   void setArabicFontSize(double value) {
// //     state = state.copyWith(arabicFontSize: value);
// //     _saveSettings();
// //   }

// //   void setTranslationFontSize(double value) {
// //     state = state.copyWith(translationFontSize: value);
// //     _saveSettings();
// //   }

// //   void setFontFamily(String value) {
// //     state = state.copyWith(fontFamily: value);
// //     _saveSettings();
// //   }

// //   void setSelectedTranslation(String value) {
// //     state = state.copyWith(selectedTranslation: value);
// //     _saveSettings();
// //   }

// //   void setSelectedReciter(String value) {
// //     state = state.copyWith(selectedReciter: value);
// //     _saveSettings();
// //   }

// //   void setShowTransliteration(bool value) {
// //     state = state.copyWith(showTransliteration: value);
// //     _saveSettings();
// //   }

// //   void setShowTafsir(bool value) {
// //     state = state.copyWith(showTafsir: value);
// //     _saveSettings();
// //   }

// //   void setDualColumnLayout(bool value) {
// //     state = state.copyWith(dualColumnLayout: value);
// //     _saveSettings();
// //   }

// //   void setAutoScroll(bool value) {
// //     state = state.copyWith(autoScroll: value);
// //     _saveSettings();
// //   }

// //   void setHighlightCurrentAyah(bool value) {
// //     state = state.copyWith(highlightCurrentAyah: value);
// //     _saveSettings();
// //   }
// // }









import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamia/core/providers/quran/audio_provider.dart';
import 'package:islamia/core/providers/quran/settings_provider.dart';
import 'package:islamia/data/models/quran/reciter_model.dart';
class QuranSettingsScreen extends ConsumerWidget {
  const QuranSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(quranSettingsProvider);
    final settingsNotifier = ref.read(quranSettingsProvider.notifier);
    final reciterListAsync = ref.watch(reciterListProvider);

    return Scaffold(
      backgroundColor: settings.nightMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: const Text('Quran Settings'),
        backgroundColor: settings.nightMode ? Colors.grey[900] : Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () => _showResetDialog(context, settingsNotifier),
            child: const Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Display Settings
          _buildSectionHeader('Display Settings', settings),
          Card(
            color: settings.nightMode ? Colors.grey[800] : Colors.white,
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Night Mode'),
                  subtitle: const Text('Dark theme for comfortable reading'),
                  value: settings.nightMode,
                  onChanged: (value) => settingsNotifier.setNightMode(value),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Dual Column Layout'),
                  subtitle: const Text('Show Arabic and translation side by side'),
                  value: settings.dualColumnLayout,
                  onChanged: (value) => settingsNotifier.setDualColumnLayout(value),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Show Transliteration'),
                  subtitle: const Text('Display phonetic pronunciation'),
                  value: settings.showTransliteration,
                  onChanged: (value) => settingsNotifier.setShowTransliteration(value),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Show Tafsir'),
                  subtitle: const Text('Display verse commentary'),
                  value: settings.showTafsir,
                  onChanged: (value) => settingsNotifier.setShowTafsir(value),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Font Settings
          _buildSectionHeader('Font Settings', settings),
          Card(
            color: settings.nightMode ? Colors.grey[800] : Colors.white,
            child: Column(
              children: [
                ListTile(
                  title: const Text('Arabic Font Size'),
                  subtitle: Slider(
                    value: settings.arabicFontSize,
                    min: 14,
                    max: 40,
                    divisions: 26,
                    label: '${settings.arabicFontSize.round()}',
                    onChanged: (value) => settingsNotifier.setArabicFontSize(value),
                  ),
                  trailing: Text('${settings.arabicFontSize.round()}'),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Translation Font Size'),
                  subtitle: Slider(
                    value: settings.translationFontSize,
                    min: 12,
                    max: 24,
                    divisions: 12,
                    label: '${settings.translationFontSize.round()}',
                    onChanged: (value) => settingsNotifier.setTranslationFontSize(value),
                  ),
                  trailing: Text('${settings.translationFontSize.round()}'),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Arabic Font Family'),
                  subtitle: Text(settings.fontFamily),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showFontFamilyDialog(context, settingsNotifier, settings),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Translation Settings
          _buildSectionHeader('Translation Settings', settings),
          Card(
            color: settings.nightMode ? Colors.grey[800] : Colors.white,
            child: Column(
              children: [
                ListTile(
                  title: const Text('Primary Translation'),
                  subtitle: Text(_getTranslationName(settings.selectedTranslation)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showTranslationDialog(context, settingsNotifier, settings),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Audio Settings
          _buildSectionHeader('Audio Settings', settings),
          Card(
            color: settings.nightMode ? Colors.grey[800] : Colors.white,
            child: Column(
              children: [
                reciterListAsync.when(
                  data: (reciters) => ListTile(
                    title: const Text('Default Reciter'),
                    subtitle: Text(_getReciterName(reciters, settings.selectedReciter)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _showReciterDialog(context, settingsNotifier, reciters, settings),
                  ),
                  loading: () => const ListTile(
                    title: Text('Default Reciter'),
                    subtitle: Text('Loading...'),
                    trailing: CircularProgressIndicator(),
                  ),
                  error: (error, stack) => ListTile(
                    title: const Text('Default Reciter'),
                    subtitle: Text('Error: ${error.toString()}'),
                    trailing: const Icon(Icons.error),
                  ),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Auto Scroll'),
                  subtitle: const Text('Automatically scroll to playing verse'),
                  value: settings.autoScroll,
                  onChanged: (value) => settingsNotifier.setAutoScroll(value),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Highlight Current Ayah'),
                  subtitle: const Text('Highlight the currently playing verse'),
                  value: settings.highlightCurrentAyah,
                  onChanged: (value) => settingsNotifier.setHighlightCurrentAyah(value),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Preview Section
          _buildSectionHeader('Preview', settings),
          Card(
            color: settings.nightMode ? Colors.grey[800] : Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Arabic Text Preview',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: settings.nightMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
                    style: TextStyle(
                      fontSize: settings.arabicFontSize,
                      fontFamily: settings.fontFamily,
                      color: settings.nightMode ? Colors.white : Colors.black,
                      height: 1.8,
                    ),
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Translation Preview',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: settings.nightMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
                    style: TextStyle(
                      fontSize: settings.translationFontSize,
                      color: settings.nightMode ? Colors.grey[300] : Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  if (settings.showTransliteration) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Bismillahi r-rahmani r-rahim',
                      style: TextStyle(
                        fontSize: settings.translationFontSize - 2,
                        color: settings.nightMode ? Colors.amber[200] : Colors.orange[700],
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, QuranSettings settings) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: settings.nightMode ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context, QuranSettingsNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text('Are you sure you want to reset all Quran settings to default?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              notifier.resetToDefaults();
              Navigator.pop(context);
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showFontFamilyDialog(BuildContext context, QuranSettingsNotifier notifier, QuranSettings settings) {
    final fonts = [
      'Noto Naskh Arabic',
      'Amiri',
      'Scheherazade New',
      'Cairo',
      'Reem Kufi',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Arabic Font'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: fonts.length,
            itemBuilder: (context, index) {
              final font = fonts[index];
              return RadioListTile<String>(
                title: Text(font),
                subtitle: Text(
                  'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
                  style: TextStyle(fontFamily: font),
                  textDirection: TextDirection.rtl,
                ),
                value: font,
                groupValue: settings.fontFamily,
                onChanged: (value) {
                  if (value != null) {
                    notifier.setFontFamily(value);
                    Navigator.pop(context);
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showTranslationDialog(BuildContext context, QuranSettingsNotifier notifier, QuranSettings settings) {
    final translations = {
      'en.sahih': 'Sahih International',
      'en.pickthall': 'Pickthall',
      'en.yusufali': 'Yusuf Ali',
      'en.hilali': 'Hilali & Khan',
      'bn.bengali': 'Bengali Translation',
      'ur.urdu': 'Urdu Translation',
      'id.indonesian': 'Indonesian',
      'tr.turkish': 'Turkish',
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Translation'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: translations.length,
            itemBuilder: (context, index) {
              final entry = translations.entries.elementAt(index);
              return RadioListTile<String>(
                title: Text(entry.value),
                value: entry.key,
                groupValue: settings.selectedTranslation,
                onChanged: (value) {
                  if (value != null) {
                    notifier.setSelectedTranslation(value);
                    Navigator.pop(context);
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showReciterDialog(BuildContext context, QuranSettingsNotifier notifier, 
      List<ReciterModel> reciters, QuranSettings settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Reciter'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: reciters.length,
            itemBuilder: (context, index) {
              final reciter = reciters[index];
              return RadioListTile<String>(
                title: Text(reciter.name),
                subtitle: Text('${reciter.language} • ${reciter.style}'),
                value: reciter.identifier,
                groupValue: settings.selectedReciter,
                onChanged: (value) {
                  if (value != null) {
                    notifier.setSelectedReciter(value);
                    Navigator.pop(context);
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  String _getTranslationName(String key) {
    final translations = {
      'en.sahih': 'Sahih International',
      'en.pickthall': 'Pickthall',
      'en.yusufali': 'Yusuf Ali',
      'en.hilali': 'Hilali & Khan',
      'bn.bengali': 'Bengali Translation',
      'ur.urdu': 'Urdu Translation',
      'id.indonesian': 'Indonesian',
      'tr.turkish': 'Turkish',
    };
    return translations[key] ?? key;
  }

  String _getReciterName(List<ReciterModel> reciters, String identifier) {
    try {
      return reciters.firstWhere((r) => r.identifier == identifier).name;
    } catch (e) {
      return identifier;
    }
  }
}