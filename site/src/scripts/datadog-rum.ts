import { datadogRum } from '@datadog/browser-rum';

datadogRum.init({
  applicationId: '9eb174c4-6be9-420d-9de7-8eadb6307cb3',
  clientToken: 'pub24a55c8b3ab3c1a324a107c0f4dfe1e1',
  site: 'datadoghq.com',
  service: 'vidpare-site',
  env: 'production',
  // Specify a version number to identify the deployed version of your application in Datadog
  // version: '1.0.0',
  version: '0.1.0',
  sessionSampleRate: 100,
  sessionReplaySampleRate: 20,
  trackUserInteractions: true,
  trackResources: true,
  trackLongTasks: true,
  defaultPrivacyLevel: 'mask-user-input',
});
