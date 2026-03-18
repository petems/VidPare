import { datadogRum } from '@datadog/browser-rum';
import { version } from '../../package.json';

datadogRum.init({
  applicationId: import.meta.env.PUBLIC_DATADOG_APPLICATION_ID,
  clientToken: import.meta.env.PUBLIC_DATADOG_CLIENT_TOKEN,
  site: 'datadoghq.com',
  service: 'vidpare-site',
  env: import.meta.env.MODE,
  version,
  sessionSampleRate: 100,
  sessionReplaySampleRate: 20,
  trackUserInteractions: true,
  trackResources: true,
  trackLongTasks: true,
  defaultPrivacyLevel: 'mask-user-input',
});
