// dim.qml — standalone reproduction of Noctalia v4's idle fade overlay
// (Modules/Background/FadeOverlay.qml). Draws a per-monitor black layer-shell
// surface and fades it in, then just holds black. It does nothing else — the
// wrapper script (lock-and-off.sh) handles lock + DPMS off + teardown so the
// timing stays in one obvious place and the overlay is always cleaned up.

import QtQuick
import Quickshell
import Quickshell.Wayland

ShellRoot {
  id: root

  // Fade duration in seconds. Keep in sync with FADE in lock-and-off.sh.
  property real fadeSeconds: 1.0

  Variants {
    model: Quickshell.screens
    delegate: PanelWindow {
      required property var modelData
      screen: modelData
      color: Qt.rgba(0, 0, 0, 0)

      // Overlay layer = above the bar and all normal windows, exactly as Noctalia does.
      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.namespace: "dim-lock-off"
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
      WlrLayershell.exclusionMode: ExclusionMode.Ignore
      WlrLayershell.anchors {
        top: true
        bottom: true
        left: true
        right: true
      }

      // Same animation Noctalia uses: transparent -> opaque black, ease-in.
      ColorAnimation on color {
        running: true
        from: Qt.rgba(0, 0, 0, 0)
        to: Qt.rgba(0, 0, 0, 1)
        duration: root.fadeSeconds * 1000
        easing.type: Easing.InQuad
      }
    }
  }
}
