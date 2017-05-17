#ifndef MYOBJECT_H
#define MYOBJECT_H

#include <QtCore/QObject>

class QNetworkAccessManager;
class QNetworkReply;
#include <QObject>
#include <QFile>

class MyObject : public QObject
{
    Q_OBJECT
    Q_PROPERTY(qreal progress READ progress NOTIFY progressChanged)

public:
    explicit MyObject(QObject *parent = 0);
    ~MyObject();

    Q_INVOKABLE void setFile(const QString &fileName);

    qreal progress() const;
    Q_INVOKABLE void upload();
    QByteArray data;

signals:
    void success(const QString &replyData);
    void failure(const int status, const QString &statusText);
    void progressChanged();

private slots:
    void uploadProgress(qint64 bytesSent, qint64 bytesTotal);
    void replyFinished();

private:
    QString m_fileName;

};
#endif
