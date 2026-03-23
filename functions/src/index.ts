// Firebase Cloud Functions powering ingestion, AI analysis, Trust/Suthara score recalculation, and admin upserts.
import * as admin from 'firebase-admin';
import { logger } from 'firebase-functions';
import { onCall } from 'firebase-functions/v2/https';
import { onDocumentWritten } from 'firebase-functions/v2/firestore';

import { generateReviewInsights } from './openai';
import { loadSeedProducts } from './sampleData';
import { calculateSutharaScore, calculateTrustScore } from './trustScore';

admin.initializeApp();
const db = admin.firestore();

export const analyzeProductReviews = onCall(async (request) => {
  const { productId, productName, reviews } = request.data as {
    productId: string;
    productName: string;
    reviews: string[];
  };

  if (!productId || !productName || !Array.isArray(reviews)) {
    throw new Error('productId, productName, and reviews are required.');
  }

  const insights = await generateReviewInsights({
    productName,
    languageHint: 'hi',
    reviews,
  });

  await db.collection('products').doc(productId).set(
    {
      aiSummaryHi: insights.summaryHi,
      aiSummaryEn: insights.summaryEn,
      pros: insights.pros,
      cons: insights.cons,
      sentimentScore: insights.sentimentScore,
      authenticityScore: insights.authenticityScore,
      fakeReviewRisk: insights.fakeReviewRisk,
      sutharaScore: insights.sutharaScore,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true },
  );

  return { success: true, insights };
});

export const upsertProductFromAdmin = onCall(async (request) => {
  const data = request.data as Record<string, unknown>;
  const productId = (data['id'] as string?)?.trim();

  if (productId == null || productId.isEmpty) {
    throw new Error('A non-empty product id is required.');
  }

  await db.collection('products').doc(productId).set(
    {
      ...data,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true },
  );

  return { success: true, productId };
});

export const syncSeedProducts = onCall(async () => {
  const seedProducts = loadSeedProducts();
  const batch = db.batch();

  for (const product of seedProducts) {
    const typed = product as Record<string, unknown>;
    const productId = typed['id'] as string;
    batch.set(
      db.collection('products').doc(productId),
      {
        ...typed,
        syncedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
  }

  await batch.commit();
  return { success: true, count: seedProducts.length };
});

export const recalculateScores = onDocumentWritten('products/{productId}', async (event) => {
  const after = event.data?.after?.data();
  if (!after) return;

  const trustScore = calculateTrustScore({
    averageRating: after.averageRating ?? 0,
    sentimentScore: after.sentimentScore ?? 0,
    authenticityScore: after.authenticityScore ?? 0,
    brandReputationScore: after.brandReputationScore ?? 0,
    ingredientsSafetyScore: after.ingredientsSafetyScore ?? 70,
    hygienePerceptionScore: after.hygienePerceptionScore ?? 70,
    userFeedbackScore: after.userFeedbackScore ?? 70,
  });

  const sutharaScore = calculateSutharaScore({
    averageRating: after.averageRating ?? 0,
    sentimentScore: after.sentimentScore ?? 0,
    authenticityScore: after.authenticityScore ?? 0,
    brandReputationScore: after.brandReputationScore ?? 0,
    ingredientsSafetyScore: after.ingredientsSafetyScore ?? 70,
    hygienePerceptionScore: after.hygienePerceptionScore ?? 70,
    userFeedbackScore: after.userFeedbackScore ?? 70,
  });

  await event.data?.after?.ref.set(
    {
      trustScore,
      sutharaScore,
      scoreUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true },
  );

  logger.info('Recalculated scores', {
    productId: event.params.productId,
    trustScore,
    sutharaScore,
  });
});
