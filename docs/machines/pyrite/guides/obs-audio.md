# OBS Audio Setup

System: pyrite (Ubuntu 24.04), OBS 30.0.2, PipeWire 1.0.5

---

## Goal

Route all audio through OBS before it reaches Zoom/Meet, enabling:
- Noise suppression and processing on the mic
- Control over what Zoom hears (mic only, or mic + system audio)
- Same workflow as OBS virtual camera but for audio

---

## Virtual Microphone

A PipeWire null sink is created at boot via a systemd user service. This gives OBS a device to monitor audio *to*, and gives Zoom a device to capture audio *from*.

**Service:** `~/.config/systemd/user/pipewire-obs-virtual-mic.service`

Creates two PipeWire nodes:
- `OBS_Virtual_Mic` - a sink (OBS monitors to this)
- `OBS_Virtual_Mic_Source` - a source (Zoom captures from this)

**Important:** OBS must be running for Zoom to receive audio. The virtual device exists at all times, but signal only flows through it when OBS is open and monitoring.

To check the service is running:
```bash
systemctl --user status pipewire-obs-virtual-mic.service
```

---

## OBS Configuration

### Global Audio Devices (Settings -> Audio)

| Slot | Device | Notes |
|---|---|---|
| Desktop Audio | default | Tracks system default output; monitoring off by default |
| Mic/Aux | fifine Microphone Digital Stereo | The boom mic |
| Mic/Aux 2 | Disabled | C920 webcam mic - not used |

**Monitoring Device:** `OBS_Virtual_Mic`

### Advanced Audio Settings (gear icon in mixer)

| Source | Audio Monitoring |
|---|---|
| Desktop Audio | Monitor Off |
| Mic/Aux (Fifine) | Monitor and Output |

To send desktop audio to Zoom temporarily: flip Desktop Audio to **Monitor and Output**.

---

## Mic Filter Chain (Fifine)

Applied via: Audio Mixer -> Fifine gear -> Filters

Order matters - filters run top to bottom:

### 1. Noise Suppression
- Method: **RNNoise**
- No settings to tune

### 2. Expander
- Detector: RMS
- Ratio: 2:1
- Threshold: -40 dB *(tune: room noise should be well below, voice well above)*
- Attack: 10ms
- Release: 100ms
- Output gain: 0 dB

### 3. Compressor
- Ratio: 3:1
- Threshold: -18 dB
- Attack: 5ms
- Release: 60ms
- Output gain: +3 dB

### 4. Limiter
- Threshold: -1 dB
- Release: 60ms

---

## Zoom Configuration

- **Microphone:** OBS_Virtual_Mic_Source
- **Speaker:** whatever headphones/speakers are in use

---

## Hardware Notes

- **Fifine microphone** is physically mono - "Digital Stereo" in the device name refers to the USB interface, not dual capsules. The L<->R balance slider is grayed out in OBS, which is correct.
- **C920 webcam** has genuine stereo mics but adds comb filtering if mixed with the boom mic (same source, different distances). Not used.
- Do not mix both mics simultaneously - the time-offset between them causes phase cancellation on the voice.

---

## Troubleshooting

**OBS shows "[Device not connected or not available]" in Global Audio Devices:**
OBS lost its PipeWire connection - restart OBS (File -> Exit, reopen).

**Zoom hears silence:**
1. Confirm OBS is running
2. Confirm Fifine monitoring is set to "Monitor and Output" (not "Monitor Off")
3. Confirm OBS Settings -> Audio -> Monitoring Device is set to `OBS_Virtual_Mic`
4. Check virtual mic service: `systemctl --user status pipewire-obs-virtual-mic.service`

**Virtual mic devices missing after reboot:**
```bash
systemctl --user restart pipewire-obs-virtual-mic.service
```
