/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


/// @file
///     @author Don Gagne <don@thegagnes.com>

#include "QGCPalette.h"
#include "QGCApplication.h"
#include "QGCCorePlugin.h"

#include <QApplication>
#include <QPalette>

QList<QGCPalette*>   QGCPalette::_paletteObjects;

QGCPalette::Theme QGCPalette::_theme = QGCPalette::Dark;

QMap<int, QMap<int, QMap<QString, QColor>>> QGCPalette::_colorInfoMap;

QStringList QGCPalette::_colors;

QGCPalette::QGCPalette(QObject* parent) :
    QObject(parent),
    _colorGroupEnabled(true)
{
    if (_colorInfoMap.isEmpty()) {
        _buildMap();
    }

    // We have to keep track of all QGCPalette objects in the system so we can signal theme change to all of them
    _paletteObjects += this;
}

QGCPalette::~QGCPalette()
{
    bool fSuccess = _paletteObjects.removeOne(this);
    if (!fSuccess) {
        qWarning() << "Internal error";
    }
}

void QGCPalette::_buildMap()
{
    //                                      Light                 Dark
    //                                      Disabled   Enabled    Disabled   Enabled
    DECLARE_QGC_COLOR(window,               "#ffffff", "#ffffff", "#1a1e26", "#1a1e26")
    DECLARE_QGC_COLOR(windowShadeLight,     "#909090", "#d9e4f5", "#707070", "#626262")
    DECLARE_QGC_COLOR(windowShade,          "#c1c1c1", "#c3cddc", "#333333", "#292c33")
    DECLARE_QGC_COLOR(windowShadeDark,      "#a0a0a0", "#aab6c8", "#282828", "#282828")
    DECLARE_QGC_COLOR(text,                 "#878787", "#262a32", "#707580", "#cfe5e5")
    DECLARE_QGC_COLOR(warningText,          "#cc0808", "#cc0808", "#f85761", "#f85761")
    DECLARE_QGC_COLOR(button,               "#ffffff", "#dee3eb", "#707580", "#40454b")
    DECLARE_QGC_COLOR(buttonText,           "#878787", "#000000", "#a6a6a6", "#cfe5e5")
    DECLARE_QGC_COLOR(buttonHighlight,      "#e4e4e4", "#00aaa8", "#3a3a3a", "#00aaa8")
    DECLARE_QGC_COLOR(buttonHighlightText,  "#2c2c2c", "#ffffff", "#2c2c2c", "#000000")
    DECLARE_QGC_COLOR(primaryButton,        "#585858", "#8cb3be", "#5a5e66", "#86bfbe")
    DECLARE_QGC_COLOR(primaryButtonText,    "#2c2c2c", "#262a32", "#2c2c2c", "#000000")
    DECLARE_QGC_COLOR(textField,            "#ffffff", "#ffffff", "#707580", "#ffffff")
    DECLARE_QGC_COLOR(textFieldText,        "#808080", "#262a32", "#000000", "#000000")
    DECLARE_QGC_COLOR(mapButton,            "#585858", "#000000", "#585858", "#000000")
    DECLARE_QGC_COLOR(mapButtonHighlight,   "#585858", "#be781c", "#585858", "#be781c")
    DECLARE_QGC_COLOR(mapIndicator,         "#585858", "#be781c", "#585858", "#be781c")
    DECLARE_QGC_COLOR(mapIndicatorChild,    "#585858", "#766043", "#585858", "#766043")
    DECLARE_QGC_COLOR(colorGreen,           "#009431", "#009431", "#00e04b", "#00e04b")
    DECLARE_QGC_COLOR(colorOrange,          "#b95604", "#b95604", "#dcc64d", "#dcc64d")
    DECLARE_QGC_COLOR(colorRed,             "#ed3939", "#ed3939", "#f32836", "#f32836")
    DECLARE_QGC_COLOR(colorGrey,            "#808080", "#808080", "#bfbfbf", "#bfbfbf")
    DECLARE_QGC_COLOR(colorBlue,            "#00aaa8", "#00aaa8", "#00aaa8", "#00aaa8")
    DECLARE_QGC_COLOR(alertBackground,      "#eecc44", "#eecc44", "#eecc44", "#eecc44")
    DECLARE_QGC_COLOR(alertBorder,          "#808080", "#808080", "#808080", "#808080")
    DECLARE_QGC_COLOR(alertText,            "#000000", "#000000", "#000000", "#000000")
    DECLARE_QGC_COLOR(missionItemEditor,    "#585858", "#00aaa8", "#585858", "#007371")
    DECLARE_QGC_COLOR(toolStripHoverColor,  "#585858", "#00aaa8", "#585858", "#00aaa8")
    DECLARE_QGC_COLOR(statusFailedText,     "#9d9d9d", "#000000", "#707070", "#ffffff")
    DECLARE_QGC_COLOR(statusPassedText,     "#9d9d9d", "#000000", "#707070", "#ffffff")
    DECLARE_QGC_COLOR(statusPendingText,    "#9d9d9d", "#000000", "#707070", "#ffffff")
    DECLARE_QGC_COLOR(toolbarBackground,    "#ffffff", "#dee3eb", "#222222", "#252929")

    // Colors not affecting by theming
    //                                              Disabled    Enabled
    DECLARE_QGC_NONTHEMED_COLOR(brandingPurple,     "#006664", "#006664")
    DECLARE_QGC_NONTHEMED_COLOR(brandingBlue,       "#48D6FF", "#6045c5")
    DECLARE_QGC_NONTHEMED_COLOR(toolStripFGColor,   "#707070", "#ffffff")

    // Colors not affecting by theming or enable/disable
    DECLARE_QGC_SINGLE_COLOR(mapWidgetBorderLight,          "#ffffff")
    DECLARE_QGC_SINGLE_COLOR(mapWidgetBorderDark,           "#000000")
    DECLARE_QGC_SINGLE_COLOR(mapMissionTrajectory,          "#be781c")
    DECLARE_QGC_SINGLE_COLOR(surveyPolygonInterior,         "green")
    DECLARE_QGC_SINGLE_COLOR(surveyPolygonTerrainCollision, "red")
}

void QGCPalette::setColorGroupEnabled(bool enabled)
{
    _colorGroupEnabled = enabled;
    emit paletteChanged();
}

void QGCPalette::setGlobalTheme(Theme newTheme)
{
    // Mobile build does not have themes
    if (_theme != newTheme) {
        _theme = newTheme;
        _signalPaletteChangeToAll();
    }
}

void QGCPalette::_signalPaletteChangeToAll()
{
    // Notify all objects of the new theme
    foreach (QGCPalette* palette, _paletteObjects) {
        palette->_signalPaletteChanged();
    }
}

void QGCPalette::_signalPaletteChanged()
{
    emit paletteChanged();
}
