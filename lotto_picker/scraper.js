const admin = require('firebase-admin');
const axios = require('axios');

// Initialize Firebase Admin gamit ang credentials mula sa GitHub Secrets
if (process.env.FIREBASE_SERVICE_ACCOUNT) {
  const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
} else {
  console.log("Warning: FIREBASE_SERVICE_ACCOUNT environment variable is not defined!");
}

const db = admin.firestore();

async function runScraper() {
  try {
    console.log("Starting PCSO Lotto Scraper...");
    
    // Halimbawang scraper logic mula sa API (Palitan ng iyong totoong API source kung kinakailangan)
    // Dito natin isinasave ang data sa paraang tugma sa iyong Firestore structure
    const sampleResults = {
      '2D': '24-11',
      '3D': '7-4-2',
      '4D': '5-9-1-3',
      '6-42': '12-25-31-09-42-15',
      '6-45': '04-18-22-35-40-11',
      '6-49': '02-15-24-39-44-48',
      '6-55': '07-18-23-31-49-52',
      '6-58': '05-12-29-33-41-58',
      '6D': '8-3-1-0-5-7'
    };

    for (const [game, result] of Object.entries(sampleResults)) {
      // Isinusulat sa collection 'pcso_data' at sa document name ng laro
      const docRef = db.collection('pcso_data').doc(game);
      
      await docRef.set({
        result: result,
        lastUpdated: admin.firestore.FieldValue.serverTimestamp()
      }, { merge: true });
      
      console.log(`Saved result for ${game}: ${result}`);
    }

    console.log("Scraper finished successfully!");
  } catch (error) {
    console.error("Error running scraper:", error);
  }
}

runScraper();
