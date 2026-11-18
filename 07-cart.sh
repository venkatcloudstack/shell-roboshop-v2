app_name=cart
source ./common.sh

check_root
systemd_setup
app_setup
nodejs_setup
app_restart
print_total_time
