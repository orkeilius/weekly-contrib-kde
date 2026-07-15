import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami

KCM.SimpleKCM {

    property alias cfg_username: usernameField.text
    property alias cfg_refreshInterval: refreshSpin.value

    Kirigami.FormLayout {
        QQC2.TextField {
            id: usernameField
            Kirigami.FormData.label: "GitHub username:"
            placeholderText: "e.g. torvalds"
        }

        QQC2.SpinBox {
            id: refreshSpin
            Kirigami.FormData.label: "Refresh every (minutes):"
            from: 5
            to: 180
            stepSize: 5
        }

        QQC2.Label {
            Kirigami.FormData.isSection: true
            text: "Uses the public GitHub events API (unauthenticated, ~60 requests/hour limit). Counts are an approximation of the real contribution graph, since private contributions aren't visible without a token."
            wrapMode: Text.WordWrap
            Layout.preferredWidth: Kirigami.Units.gridUnit * 20
        }
    }
}
