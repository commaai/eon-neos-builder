TARGET = qeglfs-surfaceflinger-integration

QT += core-private gui-private eglfsdeviceintegration-private

DEFINES += QT_EGL_NO_X11

QMAKE_CFLAGS = $$replace(QMAKE_CFLAGS, "-I/data/data/com.termux/files/usr/include", "")
QMAKE_CXXFLAGS = $$replace(QMAKE_CFLAGS, "-I/data/data/com.termux/files/usr/include", "")

INCLUDEPATH += $$PWD/../../api \
               $${ANDROID_BUILD_TOP}/frameworks/native/include \
               $${ANDROID_BUILD_TOP}/hardware/libhardware/include \
               $${ANDROID_BUILD_TOP}/system/core/include

CONFIG += egl

SOURCES += $$PWD/qeglfs_sf_main.cpp \
           $$PWD/qeglfs_sf_integration.cpp

HEADERS += $$PWD/qeglfs_sf_integration.h

LIBS += -lui -lgui -lutils -lcutils -lEGL

OTHER_FILES += $$PWD/eglfs_surfaceflinger.json

PLUGIN_TYPE = egldeviceintegrations
PLUGIN_CLASS_NAME = QEglFSSurfaceFlingerIntegrationPlugin
load(qt_plugin)