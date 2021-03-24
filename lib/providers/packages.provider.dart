import 'package:sidekick/providers/projects_provider.dart';
import 'package:sidekick/utils/dependencies.dart';

import 'package:pub_api_client/pub_api_client.dart';
import 'package:hooks_riverpod/all.dart';

// ignore: top_level_function_literal_block
final packagesProvider = FutureProvider((ref) async {
  final projects = ref.watch(projectsProvider.state);
  final packages = <String, int>{};

  for (var project in projects.list) {
    final pubspec = project.pubspec;
    final deps = pubspec.dependencies.toList();
    final devDeps = pubspec.devDependencies.toList();
    final allDeps = [...deps, ...devDeps];

    // Loop through all dependencies
    // ignore: avoid_function_literals_in_foreach_calls
    allDeps.forEach((dep) {
      // ignore: invalid_use_of_protected_member
      if (dep.hosted != null && !isGooglePubPackage(dep.package())) {
        packages.update(dep.package(), (val) => ++val, ifAbsent: () => 1);
      }
    });
  }

  return await fetchAllPackages(packages);
});
