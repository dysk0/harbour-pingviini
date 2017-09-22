/*
  Copyright (C) 2017
  Contact: Dusko Angirevic <dysko@me.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif

#include <sailfishapp.h>
#include <QQuickView>
#include <QtQml>
#include <QtGui/QGuiApplication>
#include "selector/imageuploader.h"
#include "selector/thumbnailprovider.h"
#include "selector/filesmodel.h"


int main(int argc, char *argv[])
{
    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    QScopedPointer<QQuickView> view(SailfishApp::createView());
    //QQmlContext *context = view.data()->rootContext();


    //FilesModel::registerMetaTypes();
    //qmlRegisterType<FilesModel>("harbour.pingviini.FilesModel", 1, 0, "FilesModel");
    //qmlRegisterType<ImageUploader>("harbour.pingviini.Uploader", 1, 0, "ImageUploader");
    qmlRegisterType<ImageUploader>("harbour.pingviini.Uploader", 1, 0, "ImageUploader");


    QQmlEngine* engine = view->engine();
    QObject::connect(engine, SIGNAL(quit()), app.data(), SLOT(quit()));
    //engine->addImageProvider(QStringLiteral("thumbnail"), new ThumbnailProvider);



    view->setSource(SailfishApp::pathTo("qml/harbour-pingviini.qml"));
    view->show();
    return app->exec();
}
