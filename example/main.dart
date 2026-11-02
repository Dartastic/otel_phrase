// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_phrase/otel_phrase.dart';

/// Traces Phrase calls with OpenTelemetry.
///
/// `otel_phrase` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Phrase call in
/// [tracedPhrase]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'phrase-example');

  // Wraps a Phrase API call in a CLIENT span.
  final phraseId = await tracedPhrase<String>(
    operation: 'projects.create',
    invoke: () async {
      // Make the Phrase call here, then report what it returned.
      const id = 'phrase_8f3a2c';
      return const PhraseCallResult(
          value: id,
          result: PhraseResult(
              accountId: 'account_8f3a2c',
              productLine: 'strings',
              projectId: 'project_8f3a2c',
              entityKind: 'project',
              entityId: 'entity_8f3a2c',
              keyId: 'key_8f3a2c',
              branchName: 'example',
              localeId: 'locale_8f3a2c',
              localeCode: 'en-US',
              jobId: 'job_8f3a2c',
              jobStatus: 'NEW',
              workflowStep: 'example',
              fuzzyAnalysisWordsTotal: 1,
              fuzzyAnalysisNewWords: 1,
              fuzzyAnalysisMatch100: 1,
              tmEnabled: true,
              statusCode: 201));
    },
  );
  OTelLog.info('tracedPhrase projects.create returned $phraseId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutPhraseInstrumentationAsync.
  await runWithoutPhraseInstrumentationAsync(
    () => tracedPhrase<String>(
      operation: 'projects.create',
      invoke: () async {
        const id = 'phrase_8f3a2c';
        return const PhraseCallResult(
            value: id,
            result: PhraseResult(
                accountId: 'account_8f3a2c',
                productLine: 'strings',
                projectId: 'project_8f3a2c',
                entityKind: 'project',
                entityId: 'entity_8f3a2c',
                keyId: 'key_8f3a2c',
                branchName: 'example',
                localeId: 'locale_8f3a2c',
                localeCode: 'en-US',
                jobId: 'job_8f3a2c',
                jobStatus: 'NEW',
                workflowStep: 'example',
                fuzzyAnalysisWordsTotal: 1,
                fuzzyAnalysisNewWords: 1,
                fuzzyAnalysisMatch100: 1,
                tmEnabled: true,
                statusCode: 201));
      },
    ),
  );

  await OTel.shutdown();
}
