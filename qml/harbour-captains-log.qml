import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0
import Nemo.Notifications 1.0
import io.thp.pyotherside 1.5
import "pages"

ApplicationWindow
{
    id: appWindow

    // constants
    property string timeFormat: qsTr("hh':'mm")
    property string dateTimeFormat: qsTr("d MMM yyyy, hh':'mm")
    property string fullDateTimeFormat: qsTr("ddd d MMM yyyy, hh':'mm")
    property string fullDateFormat: qsTr("ddd d MMM yyyy")
    property string dbDateFormat: "dd.MM.yyyy | hh:mm"
    // ---------

    property int _lastNotificationId: 0
    property bool unlocked: useCodeProtection.value === 1 ? false : true

    ConfigurationValue {
        id: useCodeProtection
        key: "/useCodeProtection"
    }

    Component {
        id: pinPage
        PinPage {}
    }

    Component  {
        id: firstPage
        FirstPage {}
    }

    Notification {
        id: notification
        expireTimeout: 4000
    }

    function showMessage(msg)
    {
        notification.replacesId = _lastNotificationId
        notification.previewBody = msg
        notification.publish()
        _lastNotificationId = notification.replacesId
    }

    initialPage: useCodeProtection.value === 1 ? pinPage : firstPage
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations

    Python {
        id: py

        Component.onCompleted: {
            // Add the directory of this .qml file to the search path
            addImportPath(Qt.resolvedUrl('.'));
            importModule("diary", function() {console.log("diary.py loaded")})
        }
    }
}
