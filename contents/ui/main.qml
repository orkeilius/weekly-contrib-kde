import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    readonly property string username: plasmoid.configuration.username
    readonly property int refreshMinutes: plasmoid.configuration.refreshInterval
    property var days: []
    property bool loading: false
    property string errorMessage: ""

    // GitHub-like green scale. Index 0 = darker neutral for "no activity"
    // so it stays visible on both light and dark panels.
    readonly property var levelColors: [
        "#39424e",
        "#0e4429",
        "#006d32",
        "#26a641",
        "#39d353"
    ]

    Plasmoid.icon: "code-context"
    toolTipMainText: username.length ? ("GitHub: " + username) : "Weekly Commits KDE"
    toolTipSubText: errorMessage.length ? errorMessage : (days.length ? "Click a square for details, or open the widget for more." : "Set a username in the widget settings.")

    preferredRepresentation: fullRepresentation

    function colorForLevel(level) {
        return levelColors[Math.max(0, Math.min(4, level))];
    }

    function levelForCount(count) {
        if (count <= 0) return 0;
        if (count <= 2) return 1;
        if (count <= 5) return 2;
        if (count <= 9) return 3;
        return 4;
    }

    function dateKey(d) {
        return Qt.formatDate(d, "yyyy-MM-dd");
    }

    function buildEmptyDays() {
        var arr = [];
        var today = new Date();
        for (var i = 6; i >= 0; i--) {
            var d = new Date();
            d.setDate(today.getDate() - i);
            arr.push({
                date: dateKey(d),
                label: Qt.formatDate(d, "ddd"),
                count: 0,
                level: 0
            });
        }
        return arr;
    }

    function refresh() {
        if (!username.length) {
            errorMessage = "Set your GitHub username in settings";
            days = buildEmptyDays();
            return;
        }

        loading = true;
        errorMessage = "";

        var emptyDays = buildEmptyDays();
        var counts = {};
        emptyDays.forEach(function (d) { counts[d.date] = 0; });

        var xhr = new XMLHttpRequest();
        xhr.open("GET", "https://api.github.com/users/" + encodeURIComponent(username) + "/events/public?per_page=100");
        xhr.setRequestHeader("Accept", "application/vnd.github+json");
        xhr.onreadystatechange = function () {
            if (xhr.readyState !== XMLHttpRequest.DONE) {
                return;
            }
            loading = false;

            if (xhr.status !== 200) {
                errorMessage = xhr.status === 404
                    ? "GitHub user not found"
                    : xhr.status === 403
                        ? "Rate limited by GitHub, try again later"
                        : "GitHub API error (" + xhr.status + ")";
                days = emptyDays;
                return;
            }

            try {
                var events = JSON.parse(xhr.responseText);
                events.forEach(function (ev) {
                    var d = new Date(ev.created_at);
                    var key = dateKey(d);
                    if (!(key in counts)) {
                        return;
                    }
                    var add = 1;
                    if (ev.type === "PushEvent" && ev.payload && ev.payload.commits) {
                        add = ev.payload.commits.length || 1;
                    }
                    counts[key] += add;
                });
            } catch (e) {
                errorMessage = "Failed to parse GitHub response";
            }

            days = emptyDays.map(function (d) {
                var c = counts[d.date] || 0;
                return { date: d.date, label: d.label, count: c, level: levelForCount(c) };
            });
        };
        xhr.send();
    }

    Timer {
        id: refreshTimer
        interval: Math.max(5, root.refreshMinutes) * 60 * 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    fullRepresentation: RowLayout {
        spacing: 4

        Repeater {
            model: root.days
            delegate: Rectangle {
                required property var modelData
                width: Math.max(6, Kirigami.Units.iconSizes.small * 0.75)
                height: width
                radius: 3
                color: root.colorForLevel(modelData.level)


                QQC2.ToolTip.visible: squareMouse.containsMouse
                QQC2.ToolTip.text: root.errorMessage.length ? root.errorMessage : (modelData.date + ": " + modelData.count + " contribution" + (modelData.count === 1 ? "" : "s"))

                MouseArea {
                    id: squareMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        if (root.username.length) {
                            Qt.openUrlExternally("https://github.com/" + root.username);
                        }
                    }
                }
            }
        }
    }
}
