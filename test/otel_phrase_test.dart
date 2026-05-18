// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_phrase/otel_phrase.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_phrase-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('keys.create records project + branch + product line', () async {
    await tracedPhrase<String>(
      operation: 'keys.create',
      invoke: () async => const PhraseCallResult(
        value: 'ok',
        result: PhraseResult(
          accountId: 'acc_1',
          productLine: 'strings',
          projectId: 'proj_1',
          keyId: 'key_1',
          branchName: 'release-2026-q2',
          localeCode: 'en-US',
          tmEnabled: true,
          statusCode: 201,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('phrase keys.create')!);
    expect(a['phrase.product_line'], 'strings');
    expect(a['phrase.branch.name'], 'release-2026-q2');
    expect(a['phrase.locale.code'], 'en-US');
    expect(a['phrase.tm.enabled'], true);
  });

  test('analyses.create records fuzzy match breakdown', () async {
    await tracedPhrase<String>(
      operation: 'analyses.create',
      invoke: () async => const PhraseCallResult(
        value: 'ok',
        result: PhraseResult(
          productLine: 'tms',
          jobId: 'job_1',
          fuzzyAnalysisWordsTotal: 12500,
          fuzzyAnalysisNewWords: 8400,
          fuzzyAnalysisMatch100: 3100,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('phrase analyses.create')!);
    expect(a['phrase.analysis.words_total'], 12500);
    expect(a['phrase.analysis.new_words'], 8400);
    expect(a['phrase.analysis.match_100'], 3100);
  });

  test('declined-by-linguist job sets span error', () async {
    await tracedPhrase<String>(
      operation: 'jobs.assign',
      invoke: () async => const PhraseCallResult(
        value: 'ok',
        result: PhraseResult(
          jobId: 'job_2',
          jobStatus: 'DECLINED_BY_LINGUIST',
        ),
      ),
    );
    expect(
      spans.findSpanByName('phrase jobs.assign')!.status,
      SpanStatusCode.Error,
    );
  });

  test('completed job does NOT set span error', () async {
    await tracedPhrase<String>(
      operation: 'jobs.complete',
      invoke: () async => const PhraseCallResult(
        value: 'ok',
        result: PhraseResult(jobStatus: 'COMPLETED'),
      ),
    );
    expect(
      spans.findSpanByName('phrase jobs.complete')!.status,
      isNot(SpanStatusCode.Error),
    );
  });

  test('suppression skips spans', () async {
    await runWithoutPhraseInstrumentationAsync(() async {
      await tracedPhrase<String>(
        operation: 'projects.list',
        invoke: () async => const PhraseCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('phrase '), isEmpty);
  });
}
