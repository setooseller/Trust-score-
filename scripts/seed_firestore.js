// Node script for seeding bundled starter products into Firestore.
const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

if (!process.env.GOOGLE_APPLICATION_CREDENTIALS) {
  throw new Error('Set GOOGLE_APPLICATION_CREDENTIALS before seeding Firestore.');
}

admin.initializeApp();
const db = admin.firestore();

async function seed() {
  const file = path.join(__dirname, '..', 'assets', 'seeds', 'products_seed.json');
  const products = JSON.parse(fs.readFileSync(file, 'utf8'));
  const batch = db.batch();

  for (const product of products) {
    const ref = db.collection('products').doc(product.id);
    batch.set(ref, {
      ...product,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });
  }

  await batch.commit();
  console.log(`Seeded ${products.length} products.`);
}

seed().catch((error) => {
  console.error(error);
  process.exit(1);
});
