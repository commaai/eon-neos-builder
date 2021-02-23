#include "qeglfs_sf_integration.h"

#include <cstdio>
#include <cstdlib>
#include <cassert>

#include <ui/DisplayInfo.h>

#include <gui/ISurfaceComposer.h>
#include <gui/Surface.h>
#include <gui/SurfaceComposerClient.h>

QT_BEGIN_NAMESPACE

using namespace android;

void QEglFSSurfaceFlingerIntegration::platformInit() {
    status_t ret;

    session = new SurfaceComposerClient;
    assert(session->initCheck());

    dtoken = SurfaceComposerClient::getBuiltInDisplay(
                ISurfaceComposer::eDisplayIdMain);
    assert(dtoken != NULL);

    ret = SurfaceComposerClient::getDisplayInfo(dtoken, &dinfo);
    assert(ret == 0);

    int orientation = 1;
    if (orientation == 1 || orientation == 3) {
        int temp = dinfo.h;
        dinfo.h = dinfo.w;
        dinfo.w = temp;
    }

    Rect destRect(dinfo.w, dinfo.h);
    session->setDisplayProjection(dtoken, orientation, destRect, destRect);

    mSize.setWidth(dinfo.w);
    mSize.setHeight(dinfo.h);

    control = session->createSurface(String8("qeglfs-surface"),
                mSize.width(), mSize.height(), PIXEL_FORMAT_RGBA_8888);
    assert(control != NULL);

    SurfaceComposerClient::openGlobalTransaction();
    ret = control->setLayer(0x400); // below apps and above onroad
    SurfaceComposerClient::closeGlobalTransaction(true);
    assert(ret == 0);
}

void QEglFSSurfaceFlingerIntegration::platformDestroy() {
    control = 0;
    session->dispose();
    session = 0;
}

QSize QEglFSSurfaceFlingerIntegration::screenSize() const {
    return mSize;
}

EGLNativeWindowType QEglFSSurfaceFlingerIntegration::createNativeWindow(QPlatformWindow *window, const QSize &size, const QSurfaceFormat &format) {
    Q_UNUSED(window);
    Q_UNUSED(format);
    status_t ret;

    surface = control->getSurface();
    assert(surface != NULL);

    return (EGLNativeWindowType)surface.get();
}

QSurfaceFormat QEglFSSurfaceFlingerIntegration::surfaceFormatFor(const QSurfaceFormat &inputFormat) const {
    QSurfaceFormat format = inputFormat;
    // PIXEL_FORMAT_RGBA_8888
    format.setRedBufferSize(8);
    format.setGreenBufferSize(8);
    format.setBlueBufferSize(8);
    format.setAlphaBufferSize(8);
    return format;
}

QT_END_NAMESPACE