#ifndef TERMINALCONTROLLER_H
#define TERMINALCONTROLLER_H

#include <QObject>
#include <QString>

class TerminalController : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString output READ output NOTIFY outputChanged)

public:
    explicit TerminalController(QObject *parent = nullptr);

    QString output() const { return m_output; }

    // 执行命令
    Q_INVOKABLE void execute(const QString &cmd);
    // 清除屏幕
    Q_INVOKABLE void clear();

signals:
    void outputChanged();

private:
    QString m_output;
};

#endif
