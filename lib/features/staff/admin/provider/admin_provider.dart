import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelmanagement/features/staff/admin/provider/admin_repository.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository();
});

final getTotalTipsStreamProvider = StreamProvider<double>((ref) {
  return ref.watch(adminRepositoryProvider).getTotalTipsStream();
});

final getTotalFoodSaleStreamProvider = StreamProvider<double>((ref) {
  return ref.watch(adminRepositoryProvider).getTotalFoodSaleStream();
});

final getRevenueStreamProvider = StreamProvider<double>((ref) {
  return ref.watch(adminRepositoryProvider).getRevenueStream();
});

final getTaxStreamProvider = StreamProvider<double>((ref) {
  return ref.watch(adminRepositoryProvider).getTaxStream();
});

final getInventoryExpenditureStreamProvider = StreamProvider<double>((ref) {
  return ref.watch(adminRepositoryProvider).getInventoryExpenditureStream();
});

final getExpenditureStreamProvider = StreamProvider<double>((ref) {
  return ref.watch(adminRepositoryProvider).getExpenditureStream();
});

final getNetProfitStreamProvider = StreamProvider<double>((ref) {
  return ref.watch(adminRepositoryProvider).getNetProfitStream();
});

final saveHeroImageUrlProvider = FutureProvider.autoDispose.family<void, Map<String, String>>((ref, heroUrls) {
  final adminRepository = ref.watch(adminRepositoryProvider);
  return adminRepository.saveHeroImageUrl(
    hero1Url: heroUrls['h1'] ?? '',
    hero2Url: heroUrls['h2'] ?? '',
    hero3Url: heroUrls['h3'] ?? '',
  );
});

final getHeroImageUrlsProvider = FutureProvider<Map<String, String>>((ref) {
  final adminRepository = ref.watch(adminRepositoryProvider);
  return adminRepository.getHeroImageUrls();
});