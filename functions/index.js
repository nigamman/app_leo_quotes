const functions = require('firebase-functions');
const admin = require('firebase-admin');
const fetch = require('node-fetch');  // For HTTP requests

admin.initializeApp();

const onesignalAppId = "2baf62e7-967f-4a53-9412-e8c4df05f45c";
const onesignalApiKey = "MGFlMmYzMGUtNWMwZC00MGMzLWJkMjktNGY0YWYwNjVmM2Zh";

exports.sendDailyQuote = functions.pubsub.schedule('every 1 minute').onRun(async () => {
  try {
    // Get random quote from Firebase Realtime Database
    const quotesRef = admin.database().ref('/quotes');
    const snapshot = await quotesRef.once('value');
    const quotes = snapshot.val();

    if (!quotes) {
      console.log('No quotes available in the database.');
      return null;
    }

    const quoteArray = Object.values(quotes);
    const randomQuote = quoteArray[Math.floor(Math.random() * quoteArray.length)];

    const quoteText = randomQuote.text;

    // Prepare notification payload for OneSignal
    const notificationPayload = {
      app_id: onesignalAppId,
      included_segments: ["Subscribed Users"],  // Send to all subscribed users
      headings: { "en": "Daily Motivational Quote" },
      contents: { "en": `"${quoteText}"` },  // Ensure quote and author formatting
    };

    // Send notification via OneSignal API
    const response = await fetch('https://onesignal.com/api/v1/notifications', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': `Basic ${onesignalApiKey}`,
      },
      body: JSON.stringify(notificationPayload),
    });

    const responseBody = await response.json();
    console.log('OneSignal Response:', responseBody);

    return null;
  } catch (error) {
    console.error('Error sending notification:', error);
    return null;
  }
});
