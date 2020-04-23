import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0
import "../components"

Page {
    id: firstPage

    Connections {
        target: appWindow
        onLoadingStarted: {
            hint.start()
            busy.running = true
            diaryList.visible = false
        }
        onLoadingFinished: {
            busy.running = false
            diaryList.visible = true
        }
    }

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    // don't allow navigation back to PinPage
    backNavigation: false

    // used to add the WritePage for a new entry
    forwardNavigation: true

    onStatusChanged: {
        // preload WritePage on PageStack
        if(status == PageStatus.Active) {
            pageStack.pushAttached(Qt.resolvedUrl("WritePage.qml"))
        }
    }

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaListView {
        id: diaryList
        VerticalScrollDecorator { flickable: diaryList }

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
            MenuItem {
                text: qsTr("Settings and Export")
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

        contentHeight: Theme.itemSizeHuge
        model: entriesModel
        delegate: EntryElement { }
        spacing: Theme.paddingMedium

        section {
            property: "day"
            delegate: Item {
                width: parent.width
                height: childrenRect.height + Theme.paddingSmall

                Label {
                    id: label
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    truncationMode: TruncationMode.Fade
                    color: Theme.highlightColor
                    text: parseDate(section + " | 0:0").toLocaleString(Qt.locale(), fullDateFormat)
                }
                Separator {
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        top: label.baseline
                        topMargin: 8
                    }
                    width: parent.width-2*Theme.horizontalPageMargin
                    horizontalAlignment: Qt.AlignHCenter
                    color: Theme.highlightColor
                }
            }
        }

        footer: Item { width: parent.width; height: Theme.horizontalPageMargin }
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
        running: false
    }
}
