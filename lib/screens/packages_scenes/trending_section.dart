import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sidekick/components/atoms/loading_indicator.dart';
import 'package:sidekick/components/molecules/empty_data_set/empty_packages.dart';
import 'package:sidekick/providers/packages.provider.dart';

class TrendingSection extends HookWidget {
  const TrendingSection({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final packages = useProvider(trendingPackagesProvider);
    return packages.when(
      data: (data) {
        if (data.isEmpty) {
          return const EmptyPackages();
        }
        return Container(
          child: Scrollbar(
            child: ListView.builder(
              // separatorBuilder: (_, __) => const Divider(),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final package = data[index];
                final position = ++index;
                return ListTile(
                  title: Text(package.name),
                );
              },
            ),
          ),
        );
      },
      loading: () => const LoadingIndicator(),
      error: (_, __) => Container(
        child: const Text("There was an issue loading your packages."),
      ),
    );
  }
}
