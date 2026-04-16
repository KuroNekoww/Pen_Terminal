#include "TerminalController.h"
#include <QProcess>
#include <QtQml>

TerminalController::TerminalController(QObject *parent) : QObject(parent) {
    m_output = "PenTerminal v1.0\nType command and press Enter...";
}

void TerminalController::execute(const QString &cmd) {
    if (cmd.isEmpty()) return;

    QProcess proc;
    // 使用 sh -c 兼容复合命令和管道
    proc.start("sh", QStringList() << "-c" << cmd);
    
    // 单词笔性能有限，设置 3 秒超时防止卡死
    if (!proc.waitForFinished(3000)) {
        proc.kill();
        m_output += "\n> " + cmd + "\n[Error: Command Timeout]";
    } else {
        QString res = proc.readAllStandardOutput();
        QString err = proc.readAllStandardError();
        m_output += "\n> " + cmd + "\n" + (res.isEmpty() ? err : res);
    }
    
    // 简单限长，防止内存溢出
    if (m_output.length() > 5000) {
        m_output = m_output.right(4000);
    }
    
    emit outputChanged();
}

void TerminalController::clear() {
    m_output = "Terminal cleared.";
    emit outputChanged();
}

extern "C" {
    void init_plugin() {
        qmlRegisterType<TerminalController>("MyPlugins.Terminal", 1, 0, "TerminalController");
    }
}
