pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications

QtObject {
    id: root

    property list<Notification> notifications: []

    readonly property NotificationServer server: NotificationServer {
        onNotification: (notification) => {
            notification.tracked = true;
            root.notifications = [notification, ...root.notifications];
            
            // Auto-dismiss after 5 seconds
            const timer = Qt.createQmlObject("import QtQuick; Timer { interval: 5000; running: true; onTriggered: destroy() }", root);
            timer.triggered.connect(() => {
                root.removeNotification(notification);
            });
        }
    }

    function removeNotification(notification) {
        let newNotifications = [];
        for (let i = 0; i < notifications.length; i++) {
            if (notifications[i] !== notification) {
                newNotifications.push(notifications[i]);
            }
        }
        root.notifications = newNotifications;
        notification.dismiss();
    }
}
