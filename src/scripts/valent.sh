#!/usr/bin/env bash
# Prints the devices of Valent, the KDE Connect app, as one JSON array. The
# phone module of the bar reads it, see quickshell/singletons/system/Phone.qml.
# Each device has its D-Bus path, name, icon, state flags (1 connected,
# 2 paired), battery, mobile signal and the names of its enabled actions.
# When Valent does not run, the array is empty.
dest=ca.andyholmes.Valent

objs=$(busctl --user --json=short call "$dest" /ca/andyholmes/Valent \
    org.freedesktop.DBus.ObjectManager GetManagedObjects 2>/dev/null) || { echo '[]'; exit 0; }

jq -r '.data[0] | keys[]' <<<"$objs" | while read -r path; do
    actions=$(busctl --user --json=short call "$dest" "$path" org.gtk.Actions DescribeAll 2>/dev/null) \
        || actions='{"data":[{}]}'
    jq -c --arg path "$path" --argjson objs "$objs" '
        def unv: if type == "object" and has("type") and has("data") then .data | unv
                 elif type == "object" then map_values(unv)
                 elif type == "array" then map(unv)
                 else . end;
        .data[0] as $a
        | ($objs.data[0][$path]["ca.andyholmes.Valent.Device"] | unv) as $d
        | ($a["battery.state"][2][0] // null | unv) as $bat
        | ($a["connectivity_report.state"][2][0] // null | unv) as $net
        | {
            path: $path,
            id: $d.Id,
            name: $d.Name,
            icon: $d.IconName,
            state: $d.State,
            battery: (if $bat and $bat["is-present"] then
                        {percentage: ($bat.percentage | floor), charging: $bat.charging}
                      else null end),
            signal: (if $net then
                       ($net["signal-strengths"] // {} | to_entries | map(.value) | first // null
                        | if . then {type: .["network-type"], strength: .["signal-strength"]} else null end)
                     else null end),
            actions: [$a | to_entries[] | select(.value[0]) | .key]
          }' <<<"$actions"
done | jq -sc '.'
