# /etc/conf.d/cpufrequtils: config file for /etc/init.d/cpufrequtils

# Which governor to use. Must be one of the governors listed in:
#   cat /sys/devices/system/cpu/cpu?/cpufreq/scaling_available_governors
#
GOVERNOR="ondemand"
