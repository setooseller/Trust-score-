// Trust Score and Suthara Score business logic used by Cloud Functions and admin workflows.
export interface PlatformRating {
  rating: number;
  reviewCount: number;
}

export interface ScoreInput {
  averageRating: number;
  sentimentScore: number;
  authenticityScore: number;
  brandReputationScore: number;
  ingredientsSafetyScore: number;
  hygienePerceptionScore: number;
  userFeedbackScore: number;
}

export function calculateTrustScore(input: ScoreInput): number {
  const normalizedRating = (input.averageRating / 5) * 100;
  const score =
    normalizedRating * 0.4 +
    input.sentimentScore * 0.2 +
    input.authenticityScore * 0.2 +
    input.brandReputationScore * 0.2;

  return Math.max(0, Math.min(100, Math.round(score * 10) / 10));
}

export function calculateSutharaScore(input: ScoreInput): number {
  const score =
    input.ingredientsSafetyScore * 0.4 +
    input.hygienePerceptionScore * 0.35 +
    input.userFeedbackScore * 0.25;

  return Math.max(0, Math.min(100, Math.round(score * 10) / 10));
}
