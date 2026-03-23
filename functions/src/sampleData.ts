// Seed data loader for moving the bundled JSON dataset into Firestore.
import { readFileSync } from 'node:fs';
import { join } from 'node:path';

export function loadSeedProducts(): Record<string, unknown>[] {
  const filePath = join(__dirname, '../../assets/seeds/products_seed.json');
  const raw = readFileSync(filePath, 'utf-8');
  return JSON.parse(raw) as Record<string, unknown>[];
}
