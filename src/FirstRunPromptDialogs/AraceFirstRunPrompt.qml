import QtQuick          2.12
import QtQuick.Layouts  1.12

import QGroundControl                   1.0
import QGroundControl.FactSystem        1.0
import QGroundControl.FactControls      1.0
import QGroundControl.ScreenTools       1.0
import QGroundControl.SettingsManager   1.0
import QGroundControl.Controls          1.0

FirstRunPrompt {
    title:      qsTr("Arace default presets")
    promptId:   QGroundControl.corePlugin.araceFirstRunPromptId

    property real   _margins:               ScreenTools.defaultFontPixelWidth
    property var    _appSettings:           QGroundControl.settingsManager.appSettings
    property real   _fieldWidth:            ScreenTools.defaultFontPixelWidth * 16
    property real   _comboFieldWidth:       ScreenTools.defaultFontPixelWidth * 30
    property real   _labelWidth:            ScreenTools.defaultFontPixelWidth * 20
    property Fact   _appFontPointSize:      QGroundControl.settingsManager.appSettings.appFontPointSize
    property var    _videoSettings:         QGroundControl.settingsManager.videoSettings
    property bool   _videoAutoStreamConfig: QGroundControl.videoManager.autoStreamConfigured
    property bool   _showSaveVideoSettings: _isGst || _videoAutoStreamConfig
    property bool   _isGst:                 QGroundControl.videoManager.isGStreamer
    property bool   _isUDP264:              _isGst && _videoSource === _videoSettings.udp264VideoSource
    property bool   _isUDP265:              _isGst && _videoSource === _videoSettings.udp265VideoSource
    property bool   _isRTSP:                _isGst && _videoSource === _videoSettings.rtspVideoSource
    property bool   _isTCP:                 _isGst && _videoSource === _videoSettings.tcpVideoSource
    property bool   _isMPEGTS:              _isGst && _videoSource === _videoSettings.mpegtsVideoSource
    property string _videoSource:           _videoSettings.videoSource.value

    // Here starts the vehicle and firmware settings
    property bool   _multipleFirmware:      !QGroundControl.singleFirmwareSupport
    property bool   _multipleVehicleTypes:  !QGroundControl.singleVehicleSupport

    ColumnLayout {
        id: vehicleFirmwareColumn
        spacing: ScreenTools.defaultFontPixelHeight
        anchors.top: parent.top
        anchors.margins: _margins

        QGCLabel {
            id:                     vehicleFirmwareSectionLabel
            Layout.preferredWidth:  valueRect.width
            text:                   qsTr("Offline vehicle type and firmware")
            wrapMode:               Text.WordWrap
        }

        Rectangle {
            id:                     valueRect
            Layout.preferredHeight: valueGrid.height + (_margins * 2)
            Layout.preferredWidth:  valueGrid.width + (_margins * 2)
            color:                  qgcPal.windowShade
            Layout.fillWidth:       true

            GridLayout {
                id:                 valueGrid
                anchors.margins:    _margins
                anchors.top:        parent.top
                anchors.left:       parent.left
                columns:            2

                QGCLabel {
                    Layout.fillWidth:   true
                    text:               qsTr("Firmware")
                    visible:            _multipleFirmware
                }
                FactComboBox {
                    Layout.preferredWidth:  _fieldWidth
                    fact:                   QGroundControl.settingsManager.appSettings.offlineEditingFirmwareClass
                    indexModel:             false
                    visible:                _multipleFirmware
                }

                QGCLabel {
                    Layout.fillWidth:   true
                    text:               qsTr("Vehicle")
                    visible:            _multipleVehicleTypes
                }
                FactComboBox {
                    Layout.preferredWidth:  _fieldWidth
                    fact:                   QGroundControl.settingsManager.appSettings.offlineEditingVehicleClass
                    indexModel:             false
                    visible:                _multipleVehicleTypes
                }
            }
        }
    }

    // Here starts the units settings
    property var    _unitsSettings:     QGroundControl.settingsManager.unitsSettings
    property var    _rgFacts:           [ _unitsSettings.horizontalDistanceUnits, _unitsSettings.verticalDistanceUnits, _unitsSettings.areaUnits, _unitsSettings.speedUnits, _unitsSettings.temperatureUnits ]
    property var    _rgLabels:          [ qsTr("Horizontal Distance"), qsTr("Vertical Distance"), qsTr("Area"), qsTr("Speed"), qsTr("Temperature") ]
    property int    _cVisibleFacts:     0

    Component.onCompleted: {
        var cVisibleFacts = 0
        for (var i=0; i<_rgFacts.length; i++) {
            if (_rgFacts[i].visible) {
                cVisibleFacts++
            }
        }
        _cVisibleFacts = cVisibleFacts
    }

    function changeSystemOfUnits(metric) {
        if (_unitsSettings.horizontalDistanceUnits.visible) {
            _unitsSettings.horizontalDistanceUnits.value = metric ? UnitsSettings.HorizontalDistanceUnitsMeters : UnitsSettings.HorizontalDistanceUnitsFeet
        }
        if (_unitsSettings.verticalDistanceUnits.visible) {
            _unitsSettings.verticalDistanceUnits.value = metric ? UnitsSettings.VerticalDistanceUnitsMeters : UnitsSettings.VerticalDistanceUnitsFeet
        }
        if (_unitsSettings.areaUnits.visible) {
            _unitsSettings.areaUnits.value = metric ? UnitsSettings.AreaUnitsSquareMeters : UnitsSettings.AreaUnitsSquareFeet
        }
        if (_unitsSettings.speedUnits.visible) {
            _unitsSettings.speedUnits.value = metric ? UnitsSettings.SpeedUnitsMetersPerSecond : UnitsSettings.SpeedUnitsFeetPerSecond
        }
        if (_unitsSettings.temperatureUnits.visible) {
            _unitsSettings.temperatureUnits.value = metric ? UnitsSettings.TemperatureUnitsCelsius : UnitsSettings.TemperatureUnitsFarenheit
        }
    }

    ColumnLayout {
        id:         settingsColumn
        spacing:    ScreenTools.defaultFontPixelHeight
        anchors.top: vehicleFirmwareColumn.bottom
        anchors.margins: _margins

        QGCLabel {
            id:         unitsSectionLabel
            text:       qsTr("Choose the measurement units you want to use. You can also change it later in General Settings.")

            Layout.preferredWidth: unitsGrid.width
            wrapMode: Text.WordWrap
        }

        Rectangle {
            Layout.preferredHeight: unitsGrid.height + (_margins * 2)
            Layout.preferredWidth:  unitsGrid.width + (_margins * 2)
            color:                  qgcPal.windowShade
            Layout.fillWidth:       true

            GridLayout {
                id:                 unitsGrid
                anchors.margins:    _margins
                anchors.top:        parent.top
                anchors.left:       parent.left
                rows:               _cVisibleFacts + 1
                flow:               GridLayout.TopToBottom

                QGCLabel { text: qsTr("System of units") }

                Repeater {
                    model: _rgFacts.length
                    QGCLabel {
                        text:       _rgLabels[index]
                        visible:    _rgFacts[index].visible
                    }
                }

                QGCComboBox {
                    Layout.fillWidth:   true
                    sizeToContents:     true
                    model:              [ qsTr("Metric System"), qsTr("Imperial System") ]
                    currentIndex:       _unitsSettings.horizontalDistanceUnits.value === UnitsSettings.HorizontalDistanceUnitsMeters ? 0 : 1
                    onActivated:        changeSystemOfUnits(currentIndex === 0 /* metric */)
                }

                Repeater {
                    model: _rgFacts.length
                    FactComboBox {
                        Layout.fillWidth:   true
                        sizeToContents:     true
                        fact:               _rgFacts[index]
                        indexModel:         false
                        visible:            _rgFacts[index].visible
                    }
                }
            }
        }
    }

    // Here starts the general settings
    property string _mapProvider:               QGroundControl.settingsManager.flightMapSettings.mapProvider.value
    property string _mapType:                   QGroundControl.settingsManager.flightMapSettings.mapType.value

    ColumnLayout {
        id:         generalSettingsColumn
        spacing:    ScreenTools.defaultFontPixelHeight
        anchors.top: settingsColumn.bottom
        anchors.margins: _margins

        QGCLabel {
            id:         generalSettingsLabel
            text:       qsTr("General settings")

            Layout.preferredWidth: generalSettingsGrid.width
            wrapMode: Text.WordWrap
        }

        Rectangle {
            Layout.preferredHeight: generalSettingsGrid.height + (_margins * 2)
            Layout.preferredWidth:  generalSettingsGrid.width + (_margins * 2)
            color:                  qgcPal.windowShade
            Layout.fillWidth:       true

            GridLayout {
                id:                 generalSettingsGrid
                anchors.margins:    _margins
                anchors.top:        parent.top
                anchors.left:       parent.left
                columns:            2
                flow:               GridLayout.TopToBottom

                QGCLabel {
                    text:           qsTr("Language")
                    visible: QGroundControl.settingsManager.appSettings.language.visible
                }
                FactComboBox {
                    Layout.preferredWidth:  _comboFieldWidth
                    fact:                   QGroundControl.settingsManager.appSettings.language
                    indexModel:             false
                    visible:                QGroundControl.settingsManager.appSettings.language.visible
                }

                QGCLabel {
                    text:           qsTr("Color Scheme")
                    visible: QGroundControl.settingsManager.appSettings.indoorPalette.visible
                }
                FactComboBox {
                    Layout.preferredWidth:  _comboFieldWidth
                    fact:                   QGroundControl.settingsManager.appSettings.indoorPalette
                    indexModel:             false
                    visible:                QGroundControl.settingsManager.appSettings.indoorPalette.visible
                }

                QGCLabel {
                    text:       qsTr("Map Provider")
                    width:      _labelWidth
                }
                QGCComboBox {
                    id:             mapCombo
                    model:          QGroundControl.mapEngineManager.mapProviderList
                    Layout.preferredWidth:  _comboFieldWidth
                    onActivated: {
                        _mapProvider = textAt(index)
                        QGroundControl.settingsManager.flightMapSettings.mapProvider.value=textAt(index)
                        QGroundControl.settingsManager.flightMapSettings.mapType.value=QGroundControl.mapEngineManager.mapTypeList(textAt(index))[0]
                    }
                    Component.onCompleted: {
                        var index = mapCombo.find(_mapProvider)
                        if(index < 0) index = 0
                        mapCombo.currentIndex = index
                    }
                }
                QGCLabel {
                    text:       qsTr("Map Type")
                    width:      _labelWidth
                }
                QGCComboBox {
                    id:             mapTypeCombo
                    model:          QGroundControl.mapEngineManager.mapTypeList(_mapProvider)
                    Layout.preferredWidth:  _comboFieldWidth
                    onActivated: {
                        _mapType = textAt(index)
                        QGroundControl.settingsManager.flightMapSettings.mapType.value=textAt(index)
                    }
                    Component.onCompleted: {
                        var index = mapTypeCombo.find(_mapType)
                        if(index < 0) index = 0
                        mapTypeCombo.currentIndex = index
                    }
                }

                QGCLabel {
                    text:                           qsTr("UI Scaling")
                    visible:                        _appFontPointSize.visible
                    Layout.alignment:               Qt.AlignVCenter
                }
                Item {
                    width:                          _comboFieldWidth
                    height:                         baseFontEdit.height * 1.5
                    visible:                        _appFontPointSize.visible
                    Layout.alignment:               Qt.AlignVCenter
                    Row {
                        spacing:                    ScreenTools.defaultFontPixelWidth
                        anchors.verticalCenter:     parent.verticalCenter
                        QGCButton {
                            width:                  height
                            height:                 baseFontEdit.height * 1.5
                            text:                   "-"
                            anchors.verticalCenter: parent.verticalCenter
                            onClicked: {
                                if (_appFontPointSize.value > _appFontPointSize.min) {
                                    _appFontPointSize.value = _appFontPointSize.value - 1
                                }
                            }
                        }
                        QGCLabel {
                            id:                     baseFontEdit
                            width:                  ScreenTools.defaultFontPixelWidth * 6
                            text:                   (QGroundControl.settingsManager.appSettings.appFontPointSize.value / ScreenTools.platformFontPointSize * 100).toFixed(0) + "%"
                            horizontalAlignment:    Text.AlignHCenter
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                        }
                        QGCButton {
                            width:                  height
                            height:                 baseFontEdit.height * 1.5
                            text:                   "+"
                            anchors.verticalCenter: parent.verticalCenter
                            onClicked: {
                                if (_appFontPointSize.value < _appFontPointSize.max) {
                                    _appFontPointSize.value = _appFontPointSize.value + 1
                                }
                            }
                        }
                    }
                }

                FactCheckBox {
                    text:       qsTr("Hide fly view Panels")
                    visible:    true
                    fact:       _hideFlyViewPanels
                    property Fact _hideFlyViewPanels: QGroundControl.settingsManager.appSettings.hideFlyViewPanels
                }
                FactCheckBox {
                    text:       qsTr("Use Vertical Instrument Panel")
                    visible:    _alternateInstrumentPanel.visible
                    fact:       _alternateInstrumentPanel
                    property Fact _alternateInstrumentPanel: QGroundControl.settingsManager.flyViewSettings.alternateInstrumentPanel
                }
            }
        }
    }
}