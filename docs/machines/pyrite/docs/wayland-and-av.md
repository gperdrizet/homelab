# Wayland and AV

Operational guide for Wayland desktop behavior, browser/editor rendering, and screen capture.

## Session model

- GDM greeter: X11
- User desktop session: GNOME Wayland

Confirm session type after login:
- echo $XDG_SESSION_TYPE

## VS Code setup

Use native Wayland flags in ~/.config/code-flags.conf:
- --enable-features=UseOzonePlatform,WaylandWindowDecorations
- --ozone-platform=wayland

Fallback if VS Code fails to launch:
- Remove ~/.config/code-flags.conf

## OBS screen capture

- Use Screen Capture (PipeWire) sources.
- Remove legacy Screen Capture (XSHM) sources.

Verify audio/video portal stack:
- systemctl --user status pipewire pipewire-pulse

## Chrome setup on NVIDIA

Use ~/.config/chrome-flags.conf:
- --enable-features=UseOzonePlatform,WaylandWindowDecorations
- --ozone-platform=wayland

Do not enable VaapiVideoDecodeLinuxGL on this host profile.
Do not enable Vulkan-related flags with Wayland on NVIDIA.

## Zoom notes

Known behavior:
- Zoom may black-screen on second screen share attempt in Wayland portal flow.

Practical workaround:
- Launch Zoom via XWayland:
  - env QT_QPA_PLATFORM=xcb /usr/bin/zoom %U

Desktop integration fix:
- Use a valid full desktop entry in ~/.local/share/applications/Zoom.desktop.
- Never create a one-line or empty override file.

## App validation checklist

- Firefox:
  - sign in and validate sync restore.
- Thunderbird:
  - complete account setup and send/receive check.
- Steam:
  - first launch and game render test.
- Zoom:
  - repeat stop/start screen share test.
