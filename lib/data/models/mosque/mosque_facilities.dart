class MosqueFacilities {
  final bool hasParking;
  final bool hasWuduArea;
  final bool hasWomenSection;
  final bool hasWheelchairAccess;
  final bool hasAirConditioning;
  final bool hasLibrary;
  final bool hasKitchen;
  final bool hasChildrenArea;
  final bool hasEducationCenter;
  final bool hasGiftShop;
  final bool hasRestroom;
  final bool hasSoundSystem;
  final bool hasLiveStreaming;
  final bool hasQuranClasses;
  final bool hasArabicClasses;
  final bool hasCommunityEvents;
  final List<String> additionalFacilities;

  const MosqueFacilities({
    this.hasParking = false,
    this.hasWuduArea = true,
    this.hasWomenSection = false,
    this.hasWheelchairAccess = false,
    this.hasAirConditioning = false,
    this.hasLibrary = false,
    this.hasKitchen = false,
    this.hasChildrenArea = false,
    this.hasEducationCenter = false,
    this.hasGiftShop = false,
    this.hasRestroom = true,
    this.hasSoundSystem = false,
    this.hasLiveStreaming = false,
    this.hasQuranClasses = false,
    this.hasArabicClasses = false,
    this.hasCommunityEvents = false,
    this.additionalFacilities = const [],
  });

  factory MosqueFacilities.fromJson(Map<String, dynamic> json) {
    return MosqueFacilities(
      hasParking: json['hasParking'] ?? false,
      hasWuduArea: json['hasWuduArea'] ?? true,
      hasWomenSection: json['hasWomenSection'] ?? false,
      hasWheelchairAccess: json['hasWheelchairAccess'] ?? false,
      hasAirConditioning: json['hasAirConditioning'] ?? false,
      hasLibrary: json['hasLibrary'] ?? false,
      hasKitchen: json['hasKitchen'] ?? false,
      hasChildrenArea: json['hasChildrenArea'] ?? false,
      hasEducationCenter: json['hasEducationCenter'] ?? false,
      hasGiftShop: json['hasGiftShop'] ?? false,
      hasRestroom: json['hasRestroom'] ?? true,
      hasSoundSystem: json['hasSoundSystem'] ?? false,
      hasLiveStreaming: json['hasLiveStreaming'] ?? false,
      hasQuranClasses: json['hasQuranClasses'] ?? false,
      hasArabicClasses: json['hasArabicClasses'] ?? false,
      hasCommunityEvents: json['hasCommunityEvents'] ?? false,
      additionalFacilities: List<String>.from(json['additionalFacilities'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hasParking': hasParking,
      'hasWuduArea': hasWuduArea,
      'hasWomenSection': hasWomenSection,
      'hasWheelchairAccess': hasWheelchairAccess,
      'hasAirConditioning': hasAirConditioning,
      'hasLibrary': hasLibrary,
      'hasKitchen': hasKitchen,
      'hasChildrenArea': hasChildrenArea,
      'hasEducationCenter': hasEducationCenter,
      'hasGiftShop': hasGiftShop,
      'hasRestroom': hasRestroom,
      'hasSoundSystem': hasSoundSystem,
      'hasLiveStreaming': hasLiveStreaming,
      'hasQuranClasses': hasQuranClasses,
      'hasArabicClasses': hasArabicClasses,
      'hasCommunityEvents': hasCommunityEvents,
      'additionalFacilities': additionalFacilities,
    };
  }

  // Get list of available facilities
  List<String> getAvailableFacilities() {
    final facilities = <String>[];
    
    if (hasParking) facilities.add('Parking');
    if (hasWuduArea) facilities.add('Wudu Area');
    if (hasWomenSection) facilities.add('Women\'s Section');
    if (hasWheelchairAccess) facilities.add('Wheelchair Access');
    if (hasAirConditioning) facilities.add('Air Conditioning');
    if (hasLibrary) facilities.add('Library');
    if (hasKitchen) facilities.add('Kitchen');
    if (hasChildrenArea) facilities.add('Children Area');
    if (hasEducationCenter) facilities.add('Education Center');
    if (hasGiftShop) facilities.add('Gift Shop');
    if (hasRestroom) facilities.add('Restroom');
    if (hasSoundSystem) facilities.add('Sound System');
    if (hasLiveStreaming) facilities.add('Live Streaming');
    if (hasQuranClasses) facilities.add('Quran Classes');
    if (hasArabicClasses) facilities.add('Arabic Classes');
    if (hasCommunityEvents) facilities.add('Community Events');
    
    facilities.addAll(additionalFacilities);
    
    return facilities;
  }
}
