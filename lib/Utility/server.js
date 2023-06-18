const express = require('express');
const admin = require('firebase-admin');

// Initialize the Firebase Admin SDK
admin.initializeApp({
  credential: admin.credential.applicationDefault(),
  // Add any other configuration options if needed
});

const app = express();

app.use(express.json());

// Define an API endpoint to receive notification requests
app.post('/send-notification', async (req, res) => {
  try {
    const { friendName, message } = req.body;
    
    // Retrieve the friend's FCM token from your Firestore database
    const friendSnapshot = await admin.firestore()
      .collection('users')
      .where('username', '==', friendName)
      .get();

    if (friendSnapshot.empty) {
      throw new Error('Friend not found.');
    }

    const friendDoc = friendSnapshot.docs[0];
    const friendData = friendDoc.data();
    const fcmToken = friendData.fcmToken;

    // Send the notification using the retrieved FCM token
    await admin.messaging().send({
      token: fcmToken,
      notification: {
        title: 'Notification',
        body: message,
      },
    });

    res.status(200).send('Notification sent successfully');
  } catch (error) {
    console.error('Error sending notification:', error);
    res.status(500).send('Error sending notification');
  }
});

// Start the server
const port = 3000;
app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
