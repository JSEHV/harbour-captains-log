import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0
import "../components"

Page {
    id: firstPage

    ConfigurationValue {
        id: useCodeProtection
        key: "/useCodeProtection"
    }

    function loadModel() {
        console.log("loadModel() function was called")

        hint.start()
        busy.running = true

        py.call("diary.read_all_entries", [], function(result) {
                entriesModel.clear()
                for(var i=0; i<result.length; i++) {
                    entriesModel.append(result[i])
                }
                diaryList.model = entriesModel
                busy.running = false
            }
        )
    }

    // when code is entered on PinPage, it will set to true
    property bool unlooked: useCodeProtection.value === 1 ? false : true

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    // don't allow navigation back to PinPage
    backNavigation: false

    // used to add the WritePage for a new entry
    forwardNavigation: true

    onStatusChanged: {
        // loadModel when the page is shown
        if(status === PageStatus.Activating) {
            loadModel()
        }
        // preload WritePage on PageStack
        if(status == PageStatus.Active) {
            pageStack.pushAttached(Qt.resolvedUrl("WritePage.qml"))
        }
    }

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaListView {
        id: diaryList

        Component.onCompleted: {
            // fill with model loading data
        }

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
            MenuItem {
                text: qsTr("Settings & Export")
                onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
            }
            MenuItem {
                text: qsTr("Search")
                onClicked: pageStack.push(Qt.resolvedUrl("SearchPage.qml"))
            }
        }

        anchors.fill: parent

        header: PageHeader {
            id: header
            title: qsTr("Add new entry")
        }
        clip: true
        contentHeight: Theme.itemSizeHuge
        model: entriesModel
        delegate: EntryElement {}
    }
    ListModel {
        id: entriesModel
    }
    Label {
        id: addEntryLabel

        anchors.centerIn: firstPage

        font.pixelSize: Theme.fontSizeLarge
        text: qsTr("Swipe right to add new entry")
        visible: entriesModel.count === 0 && busy.running === false ? true : false
    }
    TouchInteractionHint {
        id: hint

        direction: TouchInteraction.Left
        interactionMode: TouchInteraction.Swipe
        loops: Animation.Infinite
        visible: addEntryLabel.visible

    }
    BusyIndicator {
        id: busy
        anchors.centerIn: parent
        size: BusyIndicatorSize.Large
        running: true
    }
}