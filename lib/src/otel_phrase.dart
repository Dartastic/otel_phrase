// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_phrase_suppression.dart';

const _tracerName = 'dartastic_otel_libs_phrase';

APITracer _tracer() => OTelAPI.tracerProvider().getTracer(_tracerName);

class PhraseResult {
  /// Creates a result.
  const PhraseResult({
    this.accountId,
    this.productLine,
    this.projectId,
    this.entityKind,
    this.entityId,
    this.keyId,
    this.branchName,
    this.localeId,
    this.localeCode,
    this.jobId,
    this.jobStatus,
    this.workflowStep,
    this.fuzzyAnalysisWordsTotal,
    this.fuzzyAnalysisNewWords,
    this.fuzzyAnalysisMatch100,
    this.tmEnabled,
    this.statusCode,
  });

  /// Phrase Strings + Phrase TMS share an account.
  final String? accountId;

  /// `strings` (formerly PhraseApp) / `tms` (formerly Memsource) /
  /// `orchestrator` — which Phrase product the call hit.
  final String? productLine;

  final String? projectId;

  /// `project` / `key` / `translation` / `locale` / `branch` /
  /// `job` / `workflow_step` / `provider` / `glossary` /
  /// `translation_memory` / `style_guide` / `screenshot` / `tag` /
  /// `comment` / `webhook`.
  final String? entityKind;

  final String? entityId;

  final String? keyId;

  /// Branch (Phrase Strings supports git-like branching for
  /// translation work).
  final String? branchName;

  final String? localeId;
  final String? localeCode;

  /// TMS job id.
  final String? jobId;

  /// `NEW` / `ASSIGNED` / `ACCEPTED` / `DECLINED_BY_LINGUIST` /
  /// `COMPLETED_BY_LINGUIST` / `COMPLETED` / `CANCELLED` /
  /// `EMAILED`.
  final String? jobStatus;

  /// Active workflow step (TRANSLATE/REVISE/PROOFREAD/...).
  final String? workflowStep;

  /// TMS fuzzy analysis output — these directly map to vendor billing
  /// since linguists charge by leverage.
  final int? fuzzyAnalysisWordsTotal;
  final int? fuzzyAnalysisNewWords;
  final int? fuzzyAnalysisMatch100;

  /// `true` when TM (translation memory) is enabled for the project.
  final bool? tmEnabled;

  final int? statusCode;
}

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class PhraseCallResult<T> {
  /// Creates a call result.
  const PhraseCallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final PhraseResult? result;
}

/// Wraps a Phrase API call in a CLIENT span. [operation] is one of
/// `projects.list`, `projects.create`, `keys.list`, `keys.create`,
/// `translations.create`, `translations.search`, `branches.create`,
/// `branches.merge`, `locales.create`, `jobs.create`,
/// `jobs.assign`, `jobs.complete`, `analyses.create`,
/// `tm.match`, `glossary.search`, `webhooks.create`.
Future<T> tracedPhrase<T>({
  required String operation,
  required Future<PhraseCallResult<T>> Function() invoke,
}) async {
  if (phraseInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'phrase',
    'rpc.method': operation,
    'phrase.operation': operation,
  };

  final span = _tracer().startSpan(
    'phrase $operation',
    kind: SpanKind.client,
    attributes: OTelAPI.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final extras = <Attribute<Object>>[];
      if (r.result!.accountId != null) {
        extras.add(OTelAPI.attributeString(
          'phrase.account.id',
          r.result!.accountId!,
        ));
      }
      if (r.result!.productLine != null) {
        extras.add(OTelAPI.attributeString(
          'phrase.product_line',
          r.result!.productLine!,
        ));
      }
      if (r.result!.projectId != null) {
        extras.add(OTelAPI.attributeString(
          'phrase.project.id',
          r.result!.projectId!,
        ));
      }
      if (r.result!.entityKind != null) {
        extras.add(OTelAPI.attributeString(
          'phrase.entity.kind',
          r.result!.entityKind!,
        ));
      }
      if (r.result!.entityId != null) {
        extras.add(OTelAPI.attributeString(
          'phrase.entity.id',
          r.result!.entityId!,
        ));
      }
      if (r.result!.keyId != null) {
        extras.add(OTelAPI.attributeString(
          'phrase.key.id',
          r.result!.keyId!,
        ));
      }
      if (r.result!.branchName != null) {
        extras.add(OTelAPI.attributeString(
          'phrase.branch.name',
          r.result!.branchName!,
        ));
      }
      if (r.result!.localeId != null) {
        extras.add(OTelAPI.attributeString(
          'phrase.locale.id',
          r.result!.localeId!,
        ));
      }
      if (r.result!.localeCode != null) {
        extras.add(OTelAPI.attributeString(
          'phrase.locale.code',
          r.result!.localeCode!,
        ));
      }
      if (r.result!.jobId != null) {
        extras.add(OTelAPI.attributeString(
          'phrase.job.id',
          r.result!.jobId!,
        ));
      }
      if (r.result!.jobStatus != null) {
        extras.add(OTelAPI.attributeString(
          'phrase.job.status',
          r.result!.jobStatus!,
        ));
        if (r.result!.jobStatus == 'DECLINED_BY_LINGUIST') {
          span.setStatus(
            SpanStatusCode.Error,
            'Phrase job DECLINED_BY_LINGUIST',
          );
        }
      }
      if (r.result!.workflowStep != null) {
        extras.add(OTelAPI.attributeString(
          'phrase.workflow_step',
          r.result!.workflowStep!,
        ));
      }
      if (r.result!.fuzzyAnalysisWordsTotal != null) {
        extras.add(OTelAPI.attributeInt(
          'phrase.analysis.words_total',
          r.result!.fuzzyAnalysisWordsTotal!,
        ));
      }
      if (r.result!.fuzzyAnalysisNewWords != null) {
        extras.add(OTelAPI.attributeInt(
          'phrase.analysis.new_words',
          r.result!.fuzzyAnalysisNewWords!,
        ));
      }
      if (r.result!.fuzzyAnalysisMatch100 != null) {
        extras.add(OTelAPI.attributeInt(
          'phrase.analysis.match_100',
          r.result!.fuzzyAnalysisMatch100!,
        ));
      }
      if (r.result!.tmEnabled != null) {
        extras.add(OTelAPI.attributeBool(
          'phrase.tm.enabled',
          r.result!.tmEnabled!,
        ));
      }
      if (r.result!.statusCode != null) {
        extras.add(OTelAPI.attributeInt(
          'http.response.status_code',
          r.result!.statusCode!,
        ));
        if (r.result!.statusCode! >= 400) {
          span.setStatus(
            SpanStatusCode.Error,
            'Phrase HTTP ${r.result!.statusCode}',
          );
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTelAPI.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTelAPI.attributes([
      OTelAPI.attributeString(
        ErrorAttributes.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
