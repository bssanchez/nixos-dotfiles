// @ pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Quickshell
import Quickshell.Wayland
import Quickshell.Io

import "../components"
import "../providers"

Item {
    id: root
    width: 180
    height: 34

    property bool popoverHovered: false
    property bool popoverVisible: false
    readonly property string holidayApiKey: "fs_56izqmS6ozrJq38slQG3wI5W82ZBzjR6"
    readonly property string holidayApiUrl: "https://www.festivos.com.co/api/v1/festivos"
    property var holidays: []
    property var holidayMonthCache: ({})
    property bool holidayLoading: false
    property string holidayError: ""
    property string requestedHolidayMonthKey: ""
    property int requestedHolidayYear: 0
    property int requestedHolidayMonth: 0

    onPopoverVisibleChanged: {
        if (popoverVisible) {
            calendar.resetToToday();
        }
    }

    function monthKey(date) {
        return date.getFullYear() + "-" + String(date.getMonth() + 1).padStart(2, "0")
    }

    function fetchHolidaysForMonth(date, forceReload) {
        const key = monthKey(date)

        requestedHolidayMonthKey = key
        requestedHolidayYear = date.getFullYear()
        requestedHolidayMonth = date.getMonth() + 1

        if (!forceReload && holidayMonthCache[key]) {
            holidays = holidayMonthCache[key]
            holidayError = ""
            holidayLoading = false
            return
        }

        holidays = []
        holidayError = ""
        holidayLoading = true
        holidayFetchProc.command = [
            "curl",
            "-fsS",
            "--header",
            "Authorization: Bearer " + holidayApiKey,
            holidayApiUrl + "?year=" + requestedHolidayYear + "&month=" + requestedHolidayMonth
        ]
        holidayFetchProc.running = true
    }

    function setMonthHolidays(monthKeyValue, entries) {
        holidayMonthCache[monthKeyValue] = entries

        if (requestedHolidayMonthKey === monthKeyValue) {
            holidays = entries
            holidayError = ""
        }
    }

    Process {
        id: holidayFetchProc

        stdout: StdioCollector {
            onStreamFinished: {
                root.holidayLoading = false

                const text = this.text.trim()
                if (text === "") {
                    root.holidayError = "No fue posible obtener los festivos"
                    root.holidays = []
                    return
                }

                try {
                    const payload = JSON.parse(text)
                    const data = Array.isArray(payload.data) ? payload.data : []
                    const normalized = data.map(function(entry) {
                        return {
                            date: entry.date,
                            name_es: entry.name_es || "",
                            name_en: entry.name_en || ""
                        }
                    })

                    root.setMonthHolidays(root.requestedHolidayMonthKey, normalized)
                } catch (error) {
                    root.holidayError = "Respuesta invalida del API de festivos"
                    root.holidays = []
                }
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                const text = this.text.trim()

                if (text !== "") {
                    root.holidayLoading = false
                    root.holidayError = text
                    root.holidays = []
                }
            }
        }
    }

    function showPopover() {
        hidePopoverTimer.stop();
        popoverVisible = true;
    }

    function schedulePopoverHide() {
        if (!hoverArea.containsMouse && !popoverHovered) {
            hidePopoverTimer.restart();
        }
    }

    Timer {
        id: hidePopoverTimer
        interval: 120
        repeat: false
        onTriggered: {
            if (!hoverArea.containsMouse && !root.popoverHovered) {
                root.popoverVisible = false;
            }
        }
    }

    Rectangle {
        id: triggerPopup
        anchors.fill: parent
        color: theme.colors.crust
        radius: height / 2

        Row {
            anchors.centerIn: parent
            spacing: 8

            Text {
                color: theme.colors.peach
                text: "󰃰"
                font.pixelSize: 14
            }

            Text {
                text: Time.format("d MMM • hh:mm AP")
                font.pixelSize: 14
                color: theme.colors.text
            }
        }

        MouseArea {
            id: hoverArea
            anchors.fill: parent
            hoverEnabled: true
            onEntered: root.showPopover()
            onExited: root.schedulePopoverHide()
        }
    }

    PanelWindow {
        anchors {
            top: true
            right: true
        }

        margins {
            right: 20
        }

        WlrLayershell.layer: WlrLayer.Overlay

        visible: root.popoverVisible
        implicitWidth: 390
        implicitHeight: root.popoverVisible ? calendar.popoverHeight : 0
        color: "transparent"

        Behavior on implicitHeight {
            NumberAnimation {
                duration: 80
                easing.type: Easing.OutCubic
            }
        }

        Popout {
            id: popoverContent
            anchors.fill: parent
            alignment: 0
            asyncShapeLoad: false
            color: theme.colors.background
            radius: 20

            HoverHandler {
                onHoveredChanged: {
                    root.popoverHovered = hovered;

                    if (hovered) {
                        root.showPopover();
                    } else {
                        root.schedulePopoverHide();
                    }
                }
            }

            Item {
                id: calendar

                property date currentDate: new Date()
                readonly property int holidayRowHeight: 24
                readonly property bool showHolidaySection:
                root.holidayLoading ||
                root.holidayError !== "" ||
                root.holidays.length > 0
                readonly property int holidayRowsVisible: root.holidays.length > 0 ? root.holidays.length : 1
                readonly property int holidaySectionHeight:
                showHolidaySection ? (62 + (holidayRowsVisible * holidayRowHeight)) : 0
                readonly property int popoverHeight: 370 + holidaySectionHeight

                implicitWidth: 340
                implicitHeight: popoverHeight - 20

                onCurrentDateChanged: root.fetchHolidaysForMonth(currentDate, false)

                function resetToToday() {
                    currentDate = new Date()
                    root.fetchHolidaysForMonth(currentDate, false)
                }

                function dateKey(y, m, d) {
                    const month = String(m + 1).padStart(2, "0")
                    const day = String(d).padStart(2, "0")
                    return y + "-" + month + "-" + day
                }

                function holidayTitle(entry) {
                    return entry.name_es || entry.name_en || entry.date || "Festivo"
                }

                function holidayDateLabel(entry) {
                    if (!entry || !entry.date) {
                        return ""
                    }

                    const parts = entry.date.split("-")
                    if (parts.length !== 3) {
                        return entry.date
                    }

                    const months = ["ene", "feb", "mar", "abr", "may", "jun", "jul", "ago", "sep", "oct", "nov", "dic"]
                    return Number(parts[2]) + " " + months[Number(parts[1]) - 1]
                }

                function daysInMonth(y, m) {
                    return new Date(y, m + 1, 0).getDate()
                }

                function firstDayOffset(y, m) {
                    return (new Date(y, m, 1).getDay() + 6) % 7
                }

                function isToday(y, m, d) {
                    const t = new Date()
                    return t.getFullYear() === y &&
                    t.getMonth() === m &&
                    t.getDate() === d
                }

                function isHoliday(y, m, d) {
                    const targetDate = dateKey(y, m, d)

                    return root.holidays.some(function(entry) {
                        if (typeof entry === "string") {
                            return entry === targetDate
                        }

                        return entry && entry.date === targetDate
                    })
                }

                function monthModel() {
                    const y = currentDate.getFullYear()
                    const m = currentDate.getMonth()

                    const offset = firstDayOffset(y, m)
                    const total = daysInMonth(y, m)

                    let arr = []

                    for (let i = 0; i < offset; i++)
                    arr.push({ day: 0 })

                    for (let d = 1; d <= total; d++)
                    arr.push({ day: d })

                    return arr
                }

                Rectangle {
                    anchors.fill: parent
                    radius: 20
                    color: theme.colors.background

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 18
                        spacing: 14

                        RowLayout {
                            Layout.fillWidth: true

                            ToolButton {
                                text: " "
                                contentItem: Text {
                                    text: parent.text
                                    color: theme.colors.red
                                }
                                background: Rectangle {
                                    color: "transparent"
                                }
                                onClicked: {
                                    calendar.currentDate =
                                    new Date(calendar.currentDate.getFullYear(),
                                    calendar.currentDate.getMonth()-1, 1)
                                }
                            }

                            Text {
                                font.family: theme.fontFamily
                                font.bold: true
                                font.pixelSize: 15
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignHCenter
                                text: Qt.formatDate(calendar.currentDate, "MMMM yyyy")
                                color: theme.colors.red
                            }

                            ToolButton {
                                text: " "
                                contentItem: Text {
                                    text: parent.text
                                    color: theme.colors.red
                                }
                                background: Rectangle {
                                    color: "transparent"
                                }
                                onClicked: {
                                    calendar.currentDate =
                                    new Date(calendar.currentDate.getFullYear(),
                                    calendar.currentDate.getMonth()+1, 1)
                                }
                            }
                        }

                        GridLayout {
                            columns: 7
                            Layout.fillWidth: true

                            Repeater {
                                model: ["M","T","W","T","F","S","S"]

                                Text {
                                    font.family: theme.fontFamily
                                    text: modelData
                                    horizontalAlignment: Text.AlignHCenter
                                    font.pixelSize: 11
                                    color: theme.colors.maroon
                                    opacity: 0.7
                                    Layout.fillWidth: true
                                }
                            }
                        }

                        GridLayout {
                            columns: 7
                            columnSpacing: 6
                            rowSpacing: 6
                            Layout.fillWidth: true

                            Repeater {
                                model: calendar.monthModel()

                                delegate: Rectangle {
                                    width: 40
                                    height: 36
                                    radius: 10

                                    property bool valid: modelData.day > 0
                                    property bool today:
                                    valid &&
                                    calendar.isToday(
                                    calendar.currentDate.getFullYear(),
                                    calendar.currentDate.getMonth(),
                                    modelData.day
                                    )
                                    property bool holiday:
                                    valid &&
                                    calendar.isHoliday(
                                    calendar.currentDate.getFullYear(),
                                    calendar.currentDate.getMonth(),
                                    modelData.day
                                    )

                                    color:
                                    today ? theme.colors.peach :
                                    "transparent"

                                    Rectangle {
                                        visible: parent.holiday
                                        width: 5
                                        height: 5
                                        radius: width / 2
                                        color: theme.colors.sky
                                        anchors.top: parent.top
                                        anchors.right: parent.right
                                        anchors.topMargin: 6
                                        anchors.rightMargin: 6
                                    }

                                    Text {
                                        font.family: theme.fontFamily
                                        anchors.centerIn: parent
                                        text: valid ? modelData.day : ""
                                        font.pixelSize: 12

                                        color:
                                        today ? theme.colors.crust :
                                        theme.colors.text
                                    }
                                }
                            }
                        }

                        ColumnLayout {
                            visible: calendar.showHolidaySection
                            Layout.fillWidth: true
                            spacing: 10

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 1
                                color: theme.colors.surface0
                            }

                            Text {
                                visible: root.holidays.length > 0 || root.holidayLoading
                                text: "Holidays"
                                color: theme.colors.sky
                                font.family: theme.fontFamily
                                font.bold: true
                                font.pixelSize: 13
                            }

                            Text {
                                visible: root.holidayLoading
                                text: "Fetching..."
                                color: theme.colors.subtext0
                                font.family: theme.fontFamily
                                font.pixelSize: 12
                            }

                            Text {
                                visible: !root.holidayLoading && root.holidayError !== ""
                                text: root.holidayError
                                color: theme.colors.red
                                font.family: theme.fontFamily
                                font.pixelSize: 12
                                wrapMode: Text.Wrap
                                Layout.fillWidth: true
                            }

                            Column {
                                Layout.fillWidth: true
                                spacing: 6
                                visible: !root.holidayLoading && root.holidayError === "" && root.holidays.length > 0

                                Repeater {
                                    model: root.holidays

                                    delegate: Row {
                                        width: parent ? parent.width : 0
                                        spacing: 8

                                        Rectangle {
                                            width: 7
                                            height: 7
                                            radius: width / 2
                                            color: theme.colors.sky
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                        Text {
                                            width: 48
                                            text: calendar.holidayDateLabel(modelData)
                                            color: theme.colors.subtext1
                                            font.family: theme.fontFamily
                                            font.pixelSize: 12
                                        }

                                        Text {
                                            width: parent ? Math.max(0, parent.width - 63) : 0
                                            text: calendar.holidayTitle(modelData)
                                            color: theme.colors.text
                                            font.family: theme.fontFamily
                                            font.pixelSize: 12
                                            wrapMode: Text.Wrap
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
