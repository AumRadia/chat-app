const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { getMessaging } = require("firebase-admin/messaging");
const admin = require("firebase-admin");

admin.initializeApp();

// Firestore trigger for new messages
exports.myFunction = onDocumentCreated("chat/{messageId}", async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
        console.log("No data found.");
        return;
    }

    const data = snapshot.data();
    if (!data || !data.username || !data.text) {
        console.log("Invalid message data:", data);
        return;
    }

    try {
        await getMessaging().send({
            notification: {
                title: data.username,
                body: data.text,
            },
            data: {
                click_action: "FLUTTER_NOTIFICATION_CLICK",
            },
            topic: "chat",
        });

        console.log("Notification sent successfully.");
    } catch (error) {
        console.error("Error sending notification:", error);
    }
});
