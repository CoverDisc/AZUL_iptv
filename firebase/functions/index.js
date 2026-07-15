const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');

initializeApp();

const db = getFirestore();

exports.resolveServerProfile = onCall(
  {
    region: 'europe-west1',
    enforceAppCheck: true,
    timeoutSeconds: 15,
    memory: '256MiB',
  },
  async (request) => {
    const code = String(request.data?.code ?? '')
      .trim()
      .toUpperCase();

    if (!/^[A-Z0-9]{3,12}$/.test(code)) {
      throw new HttpsError('invalid-argument', 'Invalid service code.');
    }

    const snapshot = await db.collection('serverProfiles').doc(code).get();
    if (!snapshot.exists) {
      throw new HttpsError('not-found', 'Service code not found.');
    }

    const profile = snapshot.data() ?? {};
    if (profile.enabled !== true) {
      throw new HttpsError(
        'failed-precondition',
        'This service code is currently unavailable.',
      );
    }

    const servers = Array.isArray(profile.servers)
      ? profile.servers
          .filter((server) => server && server.enabled !== false)
          .map((server) => ({
            baseUrl: String(server.baseUrl ?? '').trim(),
            priority: Number.isFinite(Number(server.priority))
              ? Number(server.priority)
              : 100,
          }))
          .filter((server) => /^https?:\/\//i.test(server.baseUrl))
          .sort((a, b) => a.priority - b.priority)
      : [];

    if (servers.length === 0) {
      throw new HttpsError(
        'failed-precondition',
        'No server is available for this service code.',
      );
    }

    return {
      enabled: true,
      profileVersion: Number(profile.profileVersion ?? 1),
      servers,
    };
  },
);
