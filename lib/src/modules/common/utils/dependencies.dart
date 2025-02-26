import 'package:github/github.dart';
import 'package:pub_api_client/pub_api_client.dart';

import '../../packages/package.dto.dart';

final client = PubClient();

final github = GitHub(
  auth: Authentication.anonymous(),
);

Map<String, PubPackage> mapPackages;

/// Fetches all packages info from pub.dev
Future<List<PackageDetail>> fetchPackages(
  Map<String, int> packagesCount,
) async {
  final pkgFutures = <Future<PubPackage>>[];

  // Get top packages

  for (var pkg in packagesCount.keys) {
    pkgFutures.add(client.packageInfo(pkg));
  }

  final packages = await Future.wait(pkgFutures, eagerError: true);

  final topPackages = _getTopValidPackages(packages, packagesCount);
  final results = await _complementPackageInfo(topPackages, packagesCount);

  return results;
}

List<PubPackage> _getTopValidPackages(
  List<PubPackage> packages,
  Map<String, int> packagesCount,
) {
  const max = 10;

  // Filter to only valid packages
  final validPackages = packages.where((dep) => dep.name != null).toList();

  // Sort descending based on count
  validPackages.sort(
    (p1, p2) => packagesCount[p2.name].compareTo(packagesCount[p1.name]),
  );

  // Limit number of results
  validPackages.length = max;

  return validPackages;
}

Future<List<PackageDetail>> _complementPackageInfo(
  List<PubPackage> packages,
  Map<String, int> packagesCount,
) async {
  final packagesDetail = <Future<PackageDetail>>[];

  for (var pkg in packages) {
    packagesDetail.add(_assignInfo(pkg, packagesCount[pkg.name]));
  }

  return await Future.wait(packagesDetail);
}

RepositorySlug _getRepoSlug(String homepage) {
  String author;
  String repo;

  if (homepage != null && homepage.contains('github.com')) {
    final uri = Uri.parse(homepage);
    final paths = uri.path.split('/');

    // Some edge cases there wont be a repo attached to the url
    if (paths.length < 3) {
      author = null;
      repo = null;
    } else {
      author = paths[1];
      repo = paths[2];
    }
  }

  if (author != null && repo != null) {
    return RepositorySlug(author, repo);
  } else {
    return null;
  }
}

Future<PackageDetail> _assignInfo(PubPackage package, int count) async {
  final score = await client.packageScore(package.name);
  final pubspec = package.latestPubspec;
  Repository repo;

  final repoSlug = _getRepoSlug(pubspec.homepage);
  try {
    if (repoSlug != null) {
      repo = await github.repositories.getRepository(repoSlug);
    } else {
      repo = null;
    }
  } on Exception {
    repo = null;
  }
  return PackageDetail(
    name: package.name,
    description: package.description,
    version: package.version,
    url: package.url,
    homepage: package.latestPubspec.homepage,
    changelogUrl: package.changelogUrl,
    score: score,
    projectsCount: count,
    repo: repo,
  );
}
