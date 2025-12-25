// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'demo_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$getResultHash() => r'6058144be32b335d6920caf7a9e1d800cb113808';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [getResult].
@ProviderFor(getResult)
const getResultProvider = GetResultFamily();

/// See also [getResult].
class GetResultFamily extends Family<AsyncValue<void>> {
  /// See also [getResult].
  const GetResultFamily();

  /// See also [getResult].
  GetResultProvider call(
    String text,
    String currentList,
  ) {
    return GetResultProvider(
      text,
      currentList,
    );
  }

  @override
  GetResultProvider getProviderOverride(
    covariant GetResultProvider provider,
  ) {
    return call(
      provider.text,
      provider.currentList,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'getResultProvider';
}

/// See also [getResult].
class GetResultProvider extends AutoDisposeFutureProvider<void> {
  /// See also [getResult].
  GetResultProvider(
    String text,
    String currentList,
  ) : this._internal(
          (ref) => getResult(
            ref as GetResultRef,
            text,
            currentList,
          ),
          from: getResultProvider,
          name: r'getResultProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$getResultHash,
          dependencies: GetResultFamily._dependencies,
          allTransitiveDependencies: GetResultFamily._allTransitiveDependencies,
          text: text,
          currentList: currentList,
        );

  GetResultProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.text,
    required this.currentList,
  }) : super.internal();

  final String text;
  final String currentList;

  @override
  Override overrideWith(
    FutureOr<void> Function(GetResultRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GetResultProvider._internal(
        (ref) => create(ref as GetResultRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        text: text,
        currentList: currentList,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<void> createElement() {
    return _GetResultProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GetResultProvider &&
        other.text == text &&
        other.currentList == currentList;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, text.hashCode);
    hash = _SystemHash.combine(hash, currentList.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin GetResultRef on AutoDisposeFutureProviderRef<void> {
  /// The parameter `text` of this provider.
  String get text;

  /// The parameter `currentList` of this provider.
  String get currentList;
}

class _GetResultProviderElement extends AutoDisposeFutureProviderElement<void>
    with GetResultRef {
  _GetResultProviderElement(super.provider);

  @override
  String get text => (origin as GetResultProvider).text;
  @override
  String get currentList => (origin as GetResultProvider).currentList;
}

String _$currentListHash() => r'24386e5f881f4ec060b913e085843e4d7fdd5449';

/// See also [CurrentList].
@ProviderFor(CurrentList)
final currentListProvider = NotifierProvider<CurrentList, String>.internal(
  CurrentList.new,
  name: r'currentListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$currentListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CurrentList = Notifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
