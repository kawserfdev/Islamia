import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamia/core/services/mosque/mosque_service.dart';
import 'package:islamia/data/models/location/location.dart';
import 'package:islamia/data/models/mosque/mosque_model.dart';
import 'package:islamia/data/models/mosque/mosque_review.dart';

// Service provider
final mosqueServiceProvider = Provider<MosqueService>((ref) {
  return MosqueService();
});

// Current location provider
final currentLocationProvider = FutureProvider<Location>((ref) async {
  final service = ref.read(mosqueServiceProvider);
  return await service.getCurrentLocation();
});

// Mosque search provider
final nearbyMosquesProvider = FutureProvider.family<MosqueSearchResult, MosqueSearchRequest>((ref, request) async {
  final service = ref.read(mosqueServiceProvider);
  
  final location = request.location ?? await service.getCurrentLocation();
  
  return await service.searchNearbyMosques(
    location: location,
    radius: request.radius * 1000, // Convert km to meters
    query: request.query,
    filters: request.filters,
    sortBy: request.sortBy,
    limit: request.limit,
    offset: request.offset,
  );
});

// Mosque details provider
final mosqueDetailsProvider = FutureProvider.family<MosqueModel?, String>((ref, mosqueId) async {
  final service = ref.read(mosqueServiceProvider);
  return await service.getMosqueDetails(mosqueId);
});

// Favorite mosques provider
final favoriteMosquesProvider = FutureProvider.family<List<MosqueModel>, String>((ref, userId) async {
  final service = ref.read(mosqueServiceProvider);
  return await service.getFavoriteMosques(userId);
});

// Mosque reviews provider
final mosqueReviewsProvider = FutureProvider.family<List<MosqueReview>, String>((ref, mosqueId) async {
  final service = ref.read(mosqueServiceProvider);
  return await service.getReviews(mosqueId);
});

// Search history provider
final searchHistoryProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.read(mosqueServiceProvider);
  return await service.getSearchHistory();
});

// Mosque search state notifier
final mosqueSearchStateProvider = StateNotifierProvider<MosqueSearchNotifier, MosqueSearchState>((ref) {
  return MosqueSearchNotifier(ref.read(mosqueServiceProvider));
});

class MosqueSearchState {
  final List<MosqueModel> mosques;
  final bool isLoading;
  final bool hasMore;
  final String? error;
  final MosqueSearchRequest? lastRequest;

  const MosqueSearchState({
    this.mosques = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.error,
    this.lastRequest,
  });

  MosqueSearchState copyWith({
    List<MosqueModel>? mosques,
    bool? isLoading,
    bool? hasMore,
    String? error,
    MosqueSearchRequest? lastRequest,
  }) {
    return MosqueSearchState(
      mosques: mosques ?? this.mosques,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error,
      lastRequest: lastRequest ?? this.lastRequest,
    );
  }
}

class MosqueSearchNotifier extends StateNotifier<MosqueSearchState> {
  final MosqueService _service;

  MosqueSearchNotifier(this._service) : super(const MosqueSearchState());

  Future<void> searchMosques(MosqueSearchRequest request) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _service.searchNearbyMosques(
        location: request.location ?? await _service.getCurrentLocation(),
        radius: request.radius * 1000,
        query: request.query,
        filters: request.filters,
        sortBy: request.sortBy,
        limit: request.limit,
        offset: request.offset,
      );

      state = state.copyWith(
        mosques: request.offset == 0 
            ? result.mosques 
            : [...state.mosques, ...result.mosques],
        isLoading: false,
        hasMore: result.hasMore,
        lastRequest: request,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading || state.lastRequest == null) return;

    final nextRequest = MosqueSearchRequest(
      location: state.lastRequest!.location,
      radius: state.lastRequest!.radius,
      query: state.lastRequest!.query,
      filters: state.lastRequest!.filters,
      sortBy: state.lastRequest!.sortBy,
      limit: state.lastRequest!.limit,
      offset: state.mosques.length,
    );

    await searchMosques(nextRequest);
  }

  void clearResults() {
    state = const MosqueSearchState();
  }
}

// Favorite toggle notifier
final favoriteToggleProvider = StateNotifierProvider.family<FavoriteToggleNotifier, AsyncValue<bool>, String>((ref, mosqueId) {
  return FavoriteToggleNotifier(ref.read(mosqueServiceProvider), mosqueId);
});

class FavoriteToggleNotifier extends StateNotifier<AsyncValue<bool>> {
  final MosqueService _service;
  final String _mosqueId;

  FavoriteToggleNotifier(this._service, this._mosqueId) : super(const AsyncValue.loading()) {
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    try {
      // You'll need to get the current user ID from your auth system
      const userId = 'current_user_id'; // Replace with actual user ID
      final isFavorite = await _service.isFavorite(_mosqueId, userId);
      state = AsyncValue.data(isFavorite);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> toggle() async {
    if (state.isLoading) return;

    const userId = 'current_user_id'; // Replace with actual user ID
    
    try {
      final currentValue = state.value ?? false;
      
      if (currentValue) {
        await _service.removeFromFavorites(_mosqueId, userId);
      } else {
        await _service.addToFavorites(_mosqueId, userId);
      }
      
      state = AsyncValue.data(!currentValue);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}