#!/system/bin/sh

source check_data_mount.sh
log_to_data_partition=`is_ext4_f2fs_data_partition`
log_file="system.log"

ro_build_ab_update=`getprop ro.build.ab_update`
if [ "$ro_build_ab_update" = "true" ]; then
tmp_log_path="mnt/product/els"
else
tmp_log_path="cache"
fi

system_log_prop=`getprop persist.vendor.lge.service.system.enable`
log_size_prop=`getprop persist.product.lge.service.logsize.setting`
#vold_prop=`getprop vold.decrypt`
#vold_propress=`getprop vold.encrypt_progress`

touch /data/logger/${log_file}
chmod 0644 /data/logger/${log_file}

storage_low_prop=`getprop persist.product.lge.service.logger.low`

file_size_kb=8192
file_cnt=0

if [[ $log_size_prop > 0 ]]; then
   file_size_kb=$log_size_prop
fi


if [ "$storage_low_prop" = "1" ]; then
   file_size_kb=1024
fi

case "$system_log_prop" in
        #6)
        #    file_size_kb=1024
        #    file_cnt=4
        #    ;;
        5)
            file_cnt=99
            ;;
        4)
            file_cnt=49
            ;;
        3)
            file_cnt=19
            ;;
        2)
            file_cnt=9
            ;;
        1)
            file_cnt=4
            ;;
        0)
            file_cnt=0
            ;;
        *)
            file_cnt=0
            ;;
esac

if [[ $file_cnt > 0 ]]; then
    if [[ $log_to_data_partition == 1 ]]; then
        move_log "/data/logger/${log_file}" "/${tmp_log_path}/encryption_log/${log_file}"

        while true; do
            /system/bin/logcat -v threadtime -b system -b crash *:V -f /data/logger/${log_file} -n $file_cnt -r $file_size_kb
            # EOF will be restart logger_service
            if [[ $? != 2 ]]; then
                break;
            fi
        done
    else
        touch /${tmp_log_path}/encryption_log/${log_file}
        chmod 0644 /${tmp_log_path}/encryption_log/${log_file}
        /system/bin/logcat -v threadtime -b system -b crash *:V -f /${tmp_log_path}/encryption_log/${log_file} -n $file_cnt -r $file_size_kb
    fi
fi

