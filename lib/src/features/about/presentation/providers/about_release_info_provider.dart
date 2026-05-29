import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/about_release_info_repository.dart';

final aboutReleaseInfoRepositoryProvider = Provider<AboutReleaseInfoRepository>(
  (ref) {
    return AboutReleaseInfoRepository();
  },
);

final aboutReleaseInfoProvider = FutureProvider.autoDispose<AboutReleaseInfo>((
  ref,
) async {
  final repository = ref.watch(aboutReleaseInfoRepositoryProvider);
  return repository.fetchReleaseInfo();
});
