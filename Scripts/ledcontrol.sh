#!/bin/sh

LED_STATUS="/sys/class/leds/blue:status/trigger"
LED_BRIGHTNESS="/sys/class/leds/blue:status/brightness"

# Time format HHMM
ON_TIME=700
OFF_TIME=2300

log() {
        logger -t ledcontrol "$1"
}

led_on() {
        current_trigger=$(cat "$LED_STATUS" 2>/dev/null)

        if echo "$current_trigger" | grep -q "\[default-on\]"; then
                log "LED already on"
        else
                echo default-on > "$LED_STATUS" 2>/dev/null
                log "Set LED: default-on"
        fi
}

led_off() {
        current_trigger=$(cat "$LED_STATUS" 2>/dev/null)
        current_brightness=$(cat "$LED_BRIGHTNESS" 2>/dev/null)
        changed=0

        if ! echo "$current_trigger" | grep -q "\[none\]"; then
                echo none > "$LED_STATUS" 2>/dev/null
                changed=1
        fi

        if [ "$current_brightness" != "0" ]; then
                echo 0 > "$LED_BRIGHTNESS" 2>/dev/null
                changed=1
        fi

        if [ "$changed" -eq 1 ]; then
                log "Set LED: none (brightness=$(cat "$LED_BRIGHTNESS"))"
        else
                log "LED already off"
        fi
}

get_time_value() {
        date +%H%M | sed 's/^0*//'
}

case "$1" in
        on)
                led_on
                ;;
                
        off)
                led_off
                ;;

        auto)
                time_now=$(get_time_value)

                if [ "$time_now" -ge "$ON_TIME" ] && [ "$time_now" -lt "$OFF_TIME" ]; then
                        led_on
                else
                        led_off
                fi
                ;;

        *)
                echo "Usage: $0 {on|off|auto}"
                exit 1
                ;;
esac
