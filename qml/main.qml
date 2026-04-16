import QtQuick 2.12
import MyPlugins.Terminal 1.0

Rectangle {
    id: root
    width: 320; height: 170
    color: "#000000"

    TerminalController { id: term }

    // --- 顶部输入栏 ---
    Rectangle {
        id: inputArea
        width: parent.width; height: 32
        color: "#0F0F0F"
        z: 10

        Rectangle { // 底部装饰线
            width: parent.width; height: 1; color: "#00FF00"
            opacity: 0.2; anchors.bottom: parent.bottom
        }

        Row {
            anchors.fill: parent; anchors.leftMargin: 8; spacing: 4
            Text {
                text: "#"; color: "#00FF00"; font.bold: true
                anchors.verticalCenter: parent.verticalCenter
            }
            TextInput {
                id: cmdInput
                width: 280; height: parent.height
                color: "#FFFFFF"
                font.family: "monospace"
                font.pixelSize: 15
                verticalAlignment: TextInput.AlignVCenter
                focus: true
                clip: true
                
                onAccepted: {
                    term.execute(text);
                    text = "";
                }
            }
        }
    }

    // --- 滚动输出区 ---
    Flickable {
        id: flick
        anchors.top: inputArea.bottom
        anchors.bottom: actionBar.top
        width: parent.width
        clip: true
        contentHeight: logText.height + 20

        // 自动滚动到最新输出
        onContentHeightChanged: flick.contentY = Math.max(0, contentHeight - height)

        Text {
            id: logText
            width: parent.width - 16
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top; anchors.topMargin: 5
            text: term.output
            color: "#00FF00"
            font.family: "monospace"
            font.pixelSize: 12
            wrapMode: Text.WrapAnywhere
            lineHeight: 1.1
        }
    }

    // --- 底部快捷键（手动实现按钮） ---
    Rectangle {
        id: actionBar
        width: parent.width; height: 32
        color: "#111111"
        anchors.bottom: parent.bottom

        Row {
            anchors.fill: parent
            Repeater {
                model: ["ls", "top", "df", "free", "clear"]
                delegate: Rectangle {
                    width: 320 / 5; height: 32
                    color: btnArea.pressed ? "#00FF00" : "transparent"
                    
                    Text {
                        text: modelData
                        anchors.centerIn: parent
                        color: btnArea.pressed ? "#000000" : "#888888"
                        font.pixelSize: 12
                    }

                    MouseArea {
                        id: btnArea
                        anchors.fill: parent
                        onClicked: {
                            if (modelData === "clear") term.clear();
                            else term.execute(modelData);
                        }
                    }
                }
            }
        }
    }
}
