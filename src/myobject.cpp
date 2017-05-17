#include "myobject.h"

#include <QtCore/QFile>
#include <QtCore/QFileInfo>


MyObject::~MyObject() {

}

void MyObject::setFile(const QString &fileName) {
    m_fileName = fileName;
}


void MyObject::upload() {


    QFileInfo fileInfo(QUrl(m_fileName).toLocalFile());
    qDebug("fileName: %s", qPrintable(m_fileName));

    QFile file(fileInfo.absoluteFilePath());
    bool opened = file.open(QIODevice::ReadOnly);

    if (!opened) {
        qDebug("can't read file: %s", qPrintable(m_fileName));
        emit failure(-1, tr("Unable to open the file %1").arg(file.fileName()));
        data.clear();
        return;
    }

    QByteArray data = file.readAll().toBase64();
    file.close();
}

