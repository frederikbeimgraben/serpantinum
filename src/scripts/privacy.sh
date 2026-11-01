#!/usr/bin/env bash
# Prints the apps that use the microphone or the camera as one JSON object:
# {"mic": [names], "cam": [names]}. The privacy module of the bar reads it,
# see quickshell/singletons/system/Privacy.qml.
# The microphone users are the running PipeWire capture streams. A stream that
# records the output of a sink, such as an audio visualizer, is not counted.
# The camera users are the running PipeWire video capture streams. With
# --scan, the processes that hold /dev/video* open also count, which finds
# apps that open the camera without PipeWire. That scan reads all processes,
# so the shell asks for it only while a stream is active.
pw=$(pw-dump 2>/dev/null) || pw='[]'
cam_procs='[]'
if [ "$1" = "--scan" ]; then
    cam_procs=$(for pid in $(fuser /dev/video* 2>/dev/null); do
        cat "/proc/$pid/comm" 2>/dev/null
    done | grep -v -x -e pipewire -e wireplumber | sort -u | jq -R . | jq -sc .)
fi
jq -c --argjson camProcs "${cam_procs:-[]}" '
    [.[] | select(.type == "PipeWire:Interface:Node") | .info] as $nodes
    | def name: .props["application.name"] // .props["application.process.binary"] // .props["node.name"];
    ($nodes | map(select(.props["media.class"] == "Stream/Input/Audio" and .state == "running"
                         and (.props["stream.capture.sink"] | not))) | map(name) | unique) as $mic
    | ($nodes | map(select(.props["media.class"] == "Stream/Input/Video" and .state == "running")) | map(name)) as $camStreams
    | ($nodes | any(.props["media.class"] == "Video/Source" and .state == "running")) as $camRunning
    | ($camStreams + $camProcs | unique) as $cam
    | {mic: $mic, cam: (if ($cam | length) > 0 then $cam elif $camRunning then ["Camera"] else [] end)}
' <<<"$pw"
