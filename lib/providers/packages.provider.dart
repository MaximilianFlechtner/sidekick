import 'package:github_trending/github_trending.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pub_api_client/pub_api_client.dart';
import 'package:sidekick/dto/package_detail.dto.dart';
import 'package:sidekick/providers/projects_provider.dart';
import 'package:sidekick/utils/dependencies.dart';

// ignore: top_level_function_literal_block
final trendingPackagesProvider = FutureProvider<List<GithubTrendingRepository>>(
  (ref) async {
    final client = GithubTrending();
    return await client.getTrendingRepositories(
      since: 'daily',
      language: 'dart',
    );
  },
);

// ignore: top_level_function_literal_block
final packagesProvider = FutureProvider<List<PackageDetail>>((ref) async {
  final projects = ref.watch(projectsProvider.state);
  final packages = <String, int>{};

  if (projects.list.isEmpty) {
    return [];
  }

  for (var project in projects.list) {
    final pubspec = project.pubspec;
    final deps = pubspec.dependencies.toList();

    // Loop through all dependencies
    // ignore: avoid_function_literals_in_foreach_calls
    deps.forEach((dep) {
      // ignore: invalid_use_of_protected_member
      if (dep.hosted != null && !isGooglePubPackage(dep.package())) {
        packages.update(dep.package(), (val) => ++val, ifAbsent: () => 1);
      }
    });
  }

  return await fetchAllDependencies(packages);
});
