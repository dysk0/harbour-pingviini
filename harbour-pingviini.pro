# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-pingviini

i18n_files.files = translations
i18n_files.path = /usr/share/$$TARGET

INSTALLS += i18n_files

CONFIG += sailfishapp

SOURCES += src/harbour-pingviini.cpp \
    src/selector/exif/exif.cpp \
    src/selector/thumbnailprovider.cpp \
    src/selector/filesmodel.cpp \
    src/filedownloader.cpp \
    src/selector/imageuploader.cpp \
    src/selector/filesmodelworker.cpp

OTHER_FILES += qml/harbour-pingviini.qml \
    qml/cover/CoverPage.qml \
    lib/* \
    qml/pages/cmp/Stats.qml \
    qml/pages/TweetToolBar.qml \
    qml/lib/common.js \
    qml/lib/Worker.js \
    qml/lib/codebird.js \
    qml/lib/Logic.js \
    rpm/harbour-pingviini.spec \
    rpm/harbour-pingviini.yaml \
    translations/*.ts \
    harbour-pingviini.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 256x256

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

TRANSLATIONS += \
    translations/harbour-pingviini-de.ts \
    translations/harbour-pingviini-fr.ts \
    translations/harbour-pingviini-it.ts \
    translations/harbour-pingviini-nl.ts \
    translations/harbour-pingviini-oc.ts

DISTFILES += \
    Logic.js \
    oauth.js \
    sha1.js \
    qml/pages/AccountAdd.qml \
    qml/component/Tweet.qml \
    qml/pages/cmp/Navigation.qml \
    qml/pages/NewTweet.qml \
    qml/pages/TweetDetails.qml \
    qml/pages/Splash.qml \
    qml/pages/Browser.qml \
    qml/pages/Conversation.qml \
    qml/logo.svg \
    qml/pages/Profile.qml \
    qml/pages/cmp/ProfileHeader.qml \
    qml/pages/cmp/PingviiniiLogo.qml \
    qml/pages/cmp/MediaBlock.qml \
    qml/pages/cmp/MyImage.qml \
    qml/pages/ImageFullScreen.qml \
    qml/verified.svg \
    qml/pages/cmp/MyList.qml \
    qml/pages/Lists.qml \
    qml/pages/cmp/TweetVideo.qml \
    qml/pages/Settings.qml \
    qml/pages/CreditsTranslations.qml \
    qml/pages/DirectMessages.qml \
    qml/pages/MainPage.qml \
    qml/pages/UsersDebug.qml \
    qml/lib/Parser.js \
    rpm/harbour-pingviini.changes \
    qml/lib/twitter-text.js \
    qml/pages/cmp/CmpTweet.qml \
    qml/pages/cmp/CmpListItem.qml \
    qml/pages/Terms.qml

HEADERS += \
    src/filedownloader.h \
    src/selector/imageuploader.h \
    src/selector/exif/exif.h \
    src/selector/filesmodel.h \
    src/selector/filesmodelworker.h
