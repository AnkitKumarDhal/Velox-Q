pragma Singleton
import QtQuick
import Quickshell

QtObject {
    id: root

    // Pill geometry
    readonly property int borderWidth: borderStrong
    readonly property int barHeight: 36
    readonly property int pillHeight: 30
    readonly property int pillRadius: 15
    readonly property int pillPadding: 32   // added to content width
    readonly property int barSpacing: 8  // spacing between pills
    readonly property int barMargin: 8    // outer margin inside bar

    // Popup geometry
    readonly property int popupRadius: 14
    readonly property int popupBorder: borderThin

    // Spacing
    readonly property int spacingXs: 4
    readonly property int spacingSm: 6
    readonly property int spacingMd: 8
    readonly property int spacingLg: 10
    readonly property int spacingXl: 12
    readonly property int spacingXxl: 16

    // Typography
    readonly property int fontSizeCaption: 10
    readonly property int fontSizeLabel: 12
    readonly property int fontSizeBody: 14
    readonly property int fontSizeTitle: 16
    readonly property int fontSizeHeadline: 18
    readonly property int fontSizeDisplay: 30

    readonly property int fontWeightRegular: 400
    readonly property int fontWeightMedium: 500
    readonly property int fontWeightBold: 700

    // Borders
    readonly property int borderNone: 0
    readonly property int borderThin: 1
    readonly property int borderMedium: 2
    readonly property int borderStrong: 3

    // Corner radii
    readonly property int radiusXs: 6
    readonly property int radiusSm: 8
    readonly property int radiusMd: 10
    readonly property int radiusLg: 14
    readonly property int radiusXl: 16

    // Control sizes
    readonly property int controlHeightSmall: 28
    readonly property int controlHeightMedium: 32
    readonly property int controlHeightLarge: 40
    readonly property int controlIconSmall: 14
    readonly property int controlIconMedium: 16
    readonly property int controlIconLarge: 20

    // Opacity
    readonly property real opacityFaint: 0.4
    readonly property real opacitySubtle: 0.5
    readonly property real opacityMuted: 0.6
    readonly property real opacitySecondary: 0.7
    readonly property real opacityStrong: 0.75
    readonly property real opacityEmphasis: 0.8

    // UI states
    readonly property real stateHoverOpacity: 0.08
    readonly property real statePressedOpacity: 0.16
    readonly property real stateSelectedOpacity: 0.18
    readonly property real stateFocusedOpacity: 0.12
    readonly property real stateDisabledOpacity: 0.38
    readonly property real stateLoadingOpacity: 0.65

    // Animation
    readonly property int motionInstant: 80
    readonly property int motionQuick: 100
    readonly property int motionFast: 120
    readonly property int motionCompact: 140
    readonly property int motionHover: 150
    readonly property int motionSmooth: 180
    readonly property int motionNormal: 250
    readonly property int motionMedium: 300
    readonly property int motionSlow: 400
    readonly property int motionEmphasis: 600
    readonly property int motionAmbient: 900
    readonly property int motionLoop: 1000

    readonly property int animDuration: motionNormal
    readonly property int hoverFadeDuration: motionHover
    readonly property int slideInDuration: motionSlow
    readonly property int hoverCloseDelay: 300

    // Bezier curve used on popup open/close (matches your SystemPopup)
    readonly property var slideCurve: [0.05, 0, 0.133, 0.06, 0.166, 0.4, 0.208, 0.82, 0.25, 1, 1, 1]

    // Hover
    readonly property real hoverOpacity: 0.15  // primary at 15% for pill hover bg
    readonly property int hoverWidthGain: 10    // pill expands by this on hover
}
