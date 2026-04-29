const express = require('express');
const cors = require('cors');
const admin = require('firebase-admin');

// ============================================================
// 🔧 SETUP: Download your Firebase service account key from:
//    Firebase Console → Project Settings → Service Accounts
//    → Generate New Private Key
//    Save it as "serviceAccountKey.json" in this folder
// ============================================================

const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();
const app = express();
const PORT = 3000;

app.use(cors());
app.use(express.json());

// ============================================================
// 📌 GET /api/markets — Get all markets
// ============================================================
app.get('/api/markets', async (req, res) => {
  try {
    const snapshot = await db.collection('markets').get();
    const markets = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
    }));
    res.json({ success: true, data: markets });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// ============================================================
// 📌 GET /api/markets/:market/prices — Get prices for a market
// ============================================================
app.get('/api/markets/:market/prices', async (req, res) => {
  try {
    const { market } = req.params;
    const snapshot = await db
      .collection('markets')
      .doc(market)
      .collection('prices')
      .orderBy('vegetableName')
      .get();

    const prices = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
      updatedAt: doc.data().updatedAt?.toDate?.() || null,
    }));

    res.json({ success: true, market, data: prices });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// ============================================================
// 📌 POST /api/markets/:market/prices — Add/Update a vegetable price
//
// Body: {
//   "vegetableName": "වම්බටු",
//   "vegetableNameEn": "Brinjal",
//   "price": 120,
//   "unit": "kg"
// }
// ============================================================
app.post('/api/markets/:market/prices', async (req, res) => {
  try {
    const { market } = req.params;
    const { vegetableName, vegetableNameEn, price, unit } = req.body;

    if (!vegetableName || !vegetableNameEn || price === undefined) {
      return res.status(400).json({
        success: false,
        error: 'Missing required fields: vegetableName, vegetableNameEn, price',
      });
    }

    // Ensure market document exists
    const marketRef = db.collection('markets').doc(market);
    await marketRef.set({ name: market, updatedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });

    // Add/update the price
    const docId = vegetableNameEn.toLowerCase().replace(/\s+/g, '_');
    const priceRef = marketRef.collection('prices').doc(docId);

    await priceRef.set({
      vegetableName,
      vegetableNameEn,
      price: Number(price),
      market,
      unit: unit || 'kg',
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    res.json({
      success: true,
      message: `Price updated: ${vegetableNameEn} in ${market} = Rs.${price}/${unit || 'kg'}`,
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// ============================================================
// 📌 POST /api/markets/:market/prices/bulk — Add multiple prices at once
//
// Body: {
//   "prices": [
//     { "vegetableName": "වම්බටු", "vegetableNameEn": "Brinjal", "price": 120, "unit": "kg" },
//     { "vegetableName": "මිරිස්", "vegetableNameEn": "Chilli", "price": 350, "unit": "kg" }
//   ]
// }
// ============================================================
app.post('/api/markets/:market/prices/bulk', async (req, res) => {
  try {
    const { market } = req.params;
    const { prices } = req.body;

    if (!prices || !Array.isArray(prices) || prices.length === 0) {
      return res.status(400).json({
        success: false,
        error: 'Body must contain a "prices" array with at least one item',
      });
    }

    const batch = db.batch();

    // Ensure market document exists
    const marketRef = db.collection('markets').doc(market);
    batch.set(marketRef, { name: market, updatedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });

    for (const item of prices) {
      if (!item.vegetableName || !item.vegetableNameEn || item.price === undefined) {
        return res.status(400).json({
          success: false,
          error: `Invalid item: ${JSON.stringify(item)}. Required: vegetableName, vegetableNameEn, price`,
        });
      }

      const docId = item.vegetableNameEn.toLowerCase().replace(/\s+/g, '_');
      const priceRef = marketRef.collection('prices').doc(docId);

      batch.set(priceRef, {
        vegetableName: item.vegetableName,
        vegetableNameEn: item.vegetableNameEn,
        price: Number(item.price),
        market,
        unit: item.unit || 'kg',
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();

    res.json({
      success: true,
      message: `Added ${prices.length} prices to ${market}`,
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// ============================================================
// 📌 POST /api/seed — Seed all markets with sample data
// ============================================================
app.post('/api/seed', async (req, res) => {
  try {
    const markets = [
      'දඹුල්ල', 'පැල්ල', 'මීගොඩ', 'රත්මලාන', 'බෝකුන්දර',
      'නාරහෙන්පිට', 'තිස්ස', 'වේයන්ගොඩ', 'කැප්පෙටිපොල', 'තඹුත්තේගම',
    ];

    const vegetables = [
      { si: 'වම්බටු', en: 'Brinjal', basePrice: 120 },
      { si: 'මිරිස්', en: 'Chilli', basePrice: 350 },
      { si: 'වටක්කා', en: 'Pumpkin', basePrice: 150 },
      { si: 'කැරට්', en: 'Carrot', basePrice: 180 },
      { si: 'තක්කාලි', en: 'Tomato', basePrice: 200 },
      { si: 'බණ්ඩක්කා', en: 'Okra', basePrice: 160 },
      { si: 'බෝංචි', en: 'Beans', basePrice: 280 },
      { si: 'ලීක්ස්', en: 'Leeks', basePrice: 220 },
      { si: 'කොළ එළවළු', en: 'Green Vegetables', basePrice: 100 },
      { si: 'අල', en: 'Potato', basePrice: 250 },
      { si: 'සෝයාබෝංචි', en: 'Soybean', basePrice: 300 },
      { si: 'කරවිල', en: 'Bitter Gourd', basePrice: 190 },
      { si: 'පිපිඤ්ඤා', en: 'Cucumber', basePrice: 130 },
      { si: 'කැබැල්ලා', en: 'Snake Gourd', basePrice: 170 },
      { si: 'රාබු', en: 'Radish', basePrice: 140 },
      { si: 'බීට්රූට්', en: 'Beetroot', basePrice: 210 },
    ];

    const variations = {
      'දඹුල්ල': 0.85, 'පැල්ල': 1.0, 'මීගොඩ': 1.1, 'රත්මලාන': 1.15,
      'බෝකුන්දර': 1.05, 'නාරහෙන්පිට': 1.2, 'තිස්ස': 0.9,
      'වේයන්ගොඩ': 0.95, 'කැප්පෙටිපොල': 0.88, 'තඹුත්තේගම': 0.92,
    };

    const batch = db.batch();

    for (const market of markets) {
      const marketRef = db.collection('markets').doc(market);
      batch.set(marketRef, { name: market, createdAt: admin.firestore.FieldValue.serverTimestamp() });

      const variation = variations[market] || 1.0;

      for (const veg of vegetables) {
        const adjustedPrice = Math.round(veg.basePrice * variation);
        const docId = veg.en.toLowerCase().replace(/\s+/g, '_');
        const priceRef = marketRef.collection('prices').doc(docId);

        batch.set(priceRef, {
          vegetableName: veg.si,
          vegetableNameEn: veg.en,
          price: adjustedPrice,
          market,
          unit: 'kg',
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }
    }

    await batch.commit();

    res.json({
      success: true,
      message: `Seeded ${markets.length} markets with ${vegetables.length} vegetables each`,
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// ============================================================
// 📌 DELETE /api/markets/:market/prices/:vegetable — Delete a price
// ============================================================
app.delete('/api/markets/:market/prices/:vegetable', async (req, res) => {
  try {
    const { market, vegetable } = req.params;
    const docId = vegetable.toLowerCase().replace(/\s+/g, '_');

    await db
      .collection('markets')
      .doc(market)
      .collection('prices')
      .doc(docId)
      .delete();

    res.json({
      success: true,
      message: `Deleted ${vegetable} from ${market}`,
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// ============================================================
// 🚀 START SERVER
// ============================================================
app.listen(PORT, () => {
  console.log(`\n🌿 Govi Market API Server running at:`);
  console.log(`   http://localhost:${PORT}\n`);
  console.log(`📌 Available Endpoints:`);
  console.log(`   GET    /api/markets                        — List all markets`);
  console.log(`   GET    /api/markets/:market/prices          — Get prices for a market`);
  console.log(`   POST   /api/markets/:market/prices          — Add/update one price`);
  console.log(`   POST   /api/markets/:market/prices/bulk     — Add multiple prices`);
  console.log(`   POST   /api/seed                            — Seed sample data`);
  console.log(`   DELETE /api/markets/:market/prices/:vegName — Delete a price\n`);
});
