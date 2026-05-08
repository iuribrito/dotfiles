pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications

QtObject {
    id: root

    property list<Notification> notifications: []
    property var history: []
    property bool doNotDisturb: false

    function toggleDND() {
        root.doNotDisturb = !root.doNotDisturb;
    }

    readonly property NotificationServer server: NotificationServer {
        onNotification: (notification) => {
            notification.tracked = true;

            if (!root.doNotDisturb) {
                root.notifications = [notification, ...root.notifications];
            }

            root.history = [{
                appName: notification.appName || "",
                summary: notification.summary || "",
                body: notification.body || "",
                appIcon: notification.appIcon || "",
                time: Qt.formatTime(new Date(), "hh:mm")
            }, ...root.history];

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
        notification.tracked = false;
    }

    function clearHistory() {
        root.history = [];
    }
}
