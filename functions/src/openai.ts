// OpenAI helper encapsulating summarization, fake-review analysis, and structured score extraction.
import OpenAI from 'openai';

export interface ReviewInsightResult {
  summaryHi: string;
  summaryEn: string;
  pros: string[];
  cons: string[];
  sentimentScore: number;
  authenticityScore: number;
  fakeReviewRisk: 'low' | 'medium' | 'high';
  sutharaScore: number;
}

const client = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

export async function generateReviewInsights(params: {
  productName: string;
  languageHint: 'hi' | 'en';
  reviews: string[];
}): Promise<ReviewInsightResult> {
  const prompt = `You are generating product trust insights for Indian FMCG shoppers.
Product: ${params.productName}
Target output: JSON with keys summaryHi, summaryEn, pros, cons, sentimentScore, authenticityScore, fakeReviewRisk, sutharaScore.
Rules:
- Summarize reviews in Hindi and English.
- Detect fake reviews using repetition, unnatural phrases, and suspicious bursts.
- sentimentScore/authenticityScore/sutharaScore must be integers from 0 to 100.
- Keep pros/cons to 3 bullets each.
Reviews:\n${params.reviews.slice(0, 80).join('\n- ')}`;

  const response = await client.responses.create({
    model: 'gpt-4.1-mini',
    input: prompt,
  });

  const outputText = response.output_text || '{}';
  return JSON.parse(outputText) as ReviewInsightResult;
}
