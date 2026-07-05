# OBS Video Configuration

## System Overview
- **Machine**: pyrite (Ubuntu 24.04, Wayland)
- **GPU**: NVIDIA GeForce GTX 1070 (NVENC hardware encoding)
- **OBS Version**: 30.0.2
- **Primary Use Case**: Virtual camera for Zoom/Meet teaching sessions

## Monitor Setup
```
0: DP-4     2560x1440 (landscape) - PRIMARY CAPTURE MONITOR
1: HDMI-0   1920x720  (landscape)
2: DP-2     1440x2560 (portrait)
```

## Video Settings

### Canvas & Output Resolution
**File**: `~/.config/obs-studio/basic/profiles/Untitled/basic.ini`

```ini
[Video]
BaseCX=2560          # Canvas matches DP-4 monitor (no capture scaling)
BaseCY=1440
OutputCX=1920        # 1080p output for virtual camera
OutputCY=1080
FPSType=0
FPSCommon=30         # 30 FPS for video calls (Zoom/Meet cap at 30fps)
ScaleType=lanczos    # High-quality downscaling algorithm
ColorFormat=NV12
ColorSpace=709
ColorRange=Partial
```

**Rationale**:
- Canvas = monitor resolution -> no scaling during screen capture (efficient)
- Output = 1920x1080 -> single GPU downscale at encode time
- 30 FPS -> cuts encoding load in half vs 60fps, still smooth for video calls
- Lanczos -> better quality than bilinear when downscaling

### Encoder Settings
**File**: `~/.config/obs-studio/basic/profiles/Untitled/basic.ini`

```ini
[SimpleOutput]
StreamEncoder=nvenc
RecEncoder=nvenc
NVENCPreset2=p1      # P1 = "Low Latency" preset
```

**NVENC Preset Comparison**:
- **P1 (Low Latency)**: Fastest, good quality for real-time streaming
- **P3-P4**: Balanced quality/performance (use for recordings if needed)
- **P7 (Max Quality)**: Slowest, causes frame drops in real-time

**Result**: < 0.5% frame drops at 30fps 1080p output

## Screen Capture Source

### PipeWire Desktop Capture
**Source Type**: `pipewire-desktop-capture-source`
**Monitor**: DP-4 (2560x1440)

**Configuration**:
- RestoreToken saved in scene file after first monitor selection
- To reset monitor choice: clear `RestoreToken` from scene JSON, OBS will re-prompt

**Scene file location**:
```
~/.config/obs-studio/basic/scenes/Untitled.json
```

**Manual reset command**:
```bash
jq '(.sources[] | select(.name == "Screen Capture (PipeWire)") | .settings) |= {}' \
  ~/.config/obs-studio/basic/scenes/Untitled.json > /tmp/temp.json && \
  mv /tmp/temp.json ~/.config/obs-studio/basic/scenes/Untitled.json
```

## Webcam Configuration

### Resolution Optimization
**For corner inset / picture-in-picture use:**
- Right-click webcam source -> Properties
- **Resolution/FPS Type**: Custom
- **Resolution**: 640x480 (1/6 the pixels of 1080p)
- **FPS**: 30

**Rationale**: Small inset doesn't need high resolution, and lower resolution dramatically improves background removal filter performance (6x fewer pixels to process).

## Plugins

### Background Removal
**Package**: `obs-backgroundremoval` (v1.3.7 - CPU-only build)
**Source**: https://github.com/royshil/obs-backgroundremoval

**Installation**:
```bash
cd /tmp
curl -LO https://github.com/royshil/obs-backgroundremoval/releases/download/1.3.7/obs-backgroundremoval-1.3.7-x86_64-linux-gnu.deb
sudo dpkg -i obs-backgroundremoval-1.3.7-x86_64-linux-gnu.deb
```

**Current Configuration** (CPU inference):

**Webcam source**: 640x480 @ 30fps (reduced from 1080p for performance)

**Filter Settings**:
- **Model**: MediaPipe (best balance of speed/quality on CPU)
- **Inference Device**: CPU (GPU requires building from source with CUDA)
- **Num Threads**: 8 (utilize Xeon cores)
- **Calculate every x frame**: 1 (process all frames)
- **Threshold**: 0.25 (lower = less aggressive cutout)
- **Contour Filter**: 0.05-0.08
- **Smooth Silhouette**: Enabled
- **Feather Blend Silhouette**: 18-20 (high value hides edge artifacts)
- **Mask Expansion**: 12-15 (prevents clipping during head movement)
- **Temporal Smooth Factor**: 0.75 (smooths frame-to-frame changes)
- **Skip images based on similarity**: Optional (saves CPU)

**Performance**: < 0.5% frame drops at 640x480 with MediaPipe

**Known Limitations (CPU inference)**:
- Trade-off between background halo and edge clipping during movement
- MediaPipe less accurate than GPU models (RVM, RMBG)
- Increasing mask expansion helps tracking but may show background edges
- High feather blend masks artifacts but creates soft edges

**Alternative Models Tested**:
- **Robust Video Matting (RVM)**: Best quality but 15% frame drops even at 640x480, calculate=4
- **RMBG**: Similar performance issues to RVM on CPU
- **Selfie Segmentation**: Similar to MediaPipe, slightly worse edges
- **MediaPipe**: **Best CPU option** - good speed, acceptable quality for corner inset

**GPU Build (future consideration)**:
- Requires building from source with CUDA support
- Would enable RVM at full quality with no frame drops
- Concern: System has production llama.cpp inference server on P100
- CUDA toolkit installation risk to production workloads

## OBS UI Configuration

### Stats Dock (Wayland Workaround)
**Issue**: Stats window won't dock in Wayland session due to Qt/GNOME compositor bug

**Solution**:
1. Log out of Wayland
2. Log into X11 session
3. Open OBS, dock Stats window
4. Log out, return to Wayland
5. Layout persists across sessions

**Stored in**: `~/.config/obs-studio/global.ini` (DockState, base64-encoded Qt geometry)

## Performance Monitoring

**Key Stats**:
- **Target FPS**: 30
- **Frame Drops**: < 0.5% acceptable for real-time
- **Encoding**: NVENC hardware encoder on GTX 1070
- **Render Lag**: < 5ms typical

**View Stats**: View -> Docks -> Stats

## Troubleshooting

### High Frame Drops
1. Check NVENC preset (should be P1 for real-time)
2. Verify canvas matches monitor resolution (no capture scaling)
3. Confirm 30 FPS, not 60
4. Check `nvidia-smi` for GPU utilization

### Wrong Monitor After Restart
- Clear RestoreToken in scene JSON (see command above)
- OBS will prompt for monitor selection on next start

### Background Removal Missing
- Verify plugin installed: `dpkg -l | grep obs-backgroundremoval`
- Restart OBS after plugin installation

## Related Documentation
- [OBS Audio Configuration](obs-audio.md) - Virtual microphone, filter chain, PipeWire routing
