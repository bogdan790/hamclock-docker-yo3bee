#!/bin/sh
let OFFSET=$UTC_OFFSET*3600
perl hceeprom.pl NV_CALLSIGN $CALLSIGN || true
perl hceeprom.pl NV_DE_GRID $LOCATOR || true
perl hceeprom.pl NV_DE_LAT $LAT || true
perl hceeprom.pl NV_DE_LNG $LONG || true
perl hceeprom.pl NV_DE_TZ $OFFSET || true
perl hceeprom.pl NV_BCMODE $VOACAP_MODE || true
perl hceeprom.pl NV_BCPOWER $VOACAP_POWER || true
perl hceeprom.pl NV_CALL_BG_COLOR $CALLSIGN_BACKGROUND_COLOR || true
perl hceeprom.pl NV_CALL_BG_RAINBOW $CALLSIGN_BACKGROUND_RAINBOW || true
perl hceeprom.pl NV_CALL_FG_COLOR $CALLSIGN_COLOR || true
perl hceeprom.pl NV_FLRIGHOST $FLRIG_HOST || true
perl hceeprom.pl NV_FLRIGPORT $FLRIG_PORT || true
perl hceeprom.pl NV_FLRIGUSE $USE_FLRIG || true
perl hceeprom.pl NV_METRIC_ON $USE_METRIC || true

/usr/local/bin/hamclock -t 20