import QtQuick 2.12
import MyPlugins.Terminal 1.0
import "qrc:/qml/commons"

Rectangle {
    id: root
    width: 320; height: 170
    color: "#000000"

    TerminalController { id: term }

    // ═══════════════════════════════════════════════════════════
    // 虚拟键盘调用逻辑
    // ═══════════════════════════════════════════════════════════
    function requestKeyboard() {
        let component = qmlCreateComponent("YInputPage");
        if (Component.Ready === component.status) {
            var incubator = component.incubateObject(id_page_pop_helper.containerItem);
            if (incubator.status !== Component.Ready) {
                incubator.onStatusChanged = function(status) {
                    if (status === Component.Ready)
                        id_page_pop_helper.inputPageCreated(incubator.object);
                };
            } else {
                id_page_pop_helper.inputPageCreated(incubator.object);
            }
        }
    }

    YPagePopHelper {
        id: id_page_pop_helper
        z: 99

        function inputPageCreated(keyboardPage) {
            keyboardPage.backButtonClicked.connect(function() {
                if (typeof qmlGlobal !== "undefined") qmlGlobal.inputPageShowing = false;
                keyboardPage.todoDestroy();
            });

            keyboardPage.inputFinished.connect(function(content) {
                if (typeof qmlGlobal !== "undefined") qmlGlobal.inputPageShowing = false;
                keyboardPage.todoDestroy();
                
                // 执行输入的命令
                if (content.trim().length > 0) {
                    term.execute(content.trim());
                }
            });

            keyboardPage.enterText(""); // 每次打开键盘清空输入
            keyboardPage.show();
            if (typeof qmlGlobal !== "undefined") qmlGlobal.inputPageShowing = true;
        }

        isShowing: typeof qmlGlobal !== "undefined" ? qmlGlobal.inputPageShowing : false
        objectName: "from_Terminal.qml"
    }

    // ═══════════════════════════════════════════════════════════
    // 顶部终端提示符 (点击触发键盘)
    // ═══════════════════════════════════════════════════════════
    Rectangle {
        id: inputArea
        width: parent.width; height: 32
        color: "#0F0F0F"
        z: 10
        anchors.top: parent.top

        Rectangle {
            width: parent.width; height: 1; color: "#00FF00"
            opacity: 0.3; anchors.bottom: parent.bottom
        }

        Row {
            anchors.fill: parent; anchors.leftMargin: 8; spacing: 8
            Text {
                text: "root@pen:~#"
                color: "#00FF00"; font.bold: true
                font.family: "monospace"; font.pixelSize: 14
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                text: "Tap to type command..."
                color: "#666666"
                font.family: "monospace"; font.pixelSize: 13
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: requestKeyboard()
        }
    }

    // ═══════════════════════════════════════════════════════════
    // 滚动输出区 (占满剩余屏幕)
    // ═══════════════════════════════════════════════════════════
    Flickable {
        id: flick
        anchors.top: inputArea.bottom
        anchors.bottom: parent.bottom // 直接到底，因为去掉了快捷键
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
            lineHeight: 1.2
        }
    }
}
