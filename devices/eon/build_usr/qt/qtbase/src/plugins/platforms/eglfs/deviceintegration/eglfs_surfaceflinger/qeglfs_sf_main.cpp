#include "private/qeglfsdeviceintegration_p.h"
#include "qeglfs_sf_integration.h"

QT_BEGIN_NAMESPACE

class QEglFSSurfaceFlingerIntegrationPlugin : public QEglFSDeviceIntegrationPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID QEglFSDeviceIntegrationFactoryInterface_iid FILE "eglfs_surfaceflinger.json")

public:
    QEglFSDeviceIntegration *create() override { return new QEglFSSurfaceFlingerIntegration; }
};

QT_END_NAMESPACE

#include "qeglfs_sf_main.moc"