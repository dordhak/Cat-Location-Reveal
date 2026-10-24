// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'submission_form_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SubmissionFormController)
final submissionFormControllerProvider = SubmissionFormControllerProvider._();

final class SubmissionFormControllerProvider
    extends $NotifierProvider<SubmissionFormController, SubmissionFormState> {
  SubmissionFormControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'submissionFormControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$submissionFormControllerHash();

  @$internal
  @override
  SubmissionFormController create() => SubmissionFormController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SubmissionFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SubmissionFormState>(value),
    );
  }
}

String _$submissionFormControllerHash() =>
    r'5f3528bdeb9cfc3849734898030307403c823b36';

abstract class _$SubmissionFormController
    extends $Notifier<SubmissionFormState> {
  SubmissionFormState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SubmissionFormState, SubmissionFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SubmissionFormState, SubmissionFormState>,
              SubmissionFormState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
