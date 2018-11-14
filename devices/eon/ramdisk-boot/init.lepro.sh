lepro_files=""
lepro_files="$lepro_files etc/sensors/sensor_def_qcomdev.conf"
lepro_files="$lepro_files lib64/hw/sensors.msm8996.so"
lepro_files="$lepro_files lib64/libsensorservice.so"
lepro_files="$lepro_files vendor/lib64/hw/activity_recognition.msm8996.so"
lepro_files="$lepro_files vendor/lib64/libsensor1.so"
lepro_files="$lepro_files vendor/lib64/libsensor_reg.so"
lepro_files="$lepro_files vendor/lib64/sensors.ssc.so"

lepro_exec_files=""
lepro_exec_files="$lepro_exec_files bin/sensors.qcom"

if ! grep -q letv /proc/cmdline; then
    exit 1
fi

mount -o remount,rw /system
for file in $lepro_exec_files; do
    chmod a+x /system/lepro/$file
done
mount -o remount,ro /system

for file in $lepro_exec_files; do
    mount --bind /system/lepro/$file /system/$file
done

for file in $lepro_files; do
    mount --bind /system/lepro/$file /system/$file
done
