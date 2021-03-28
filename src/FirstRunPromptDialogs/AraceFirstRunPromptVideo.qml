import QtQuick          2.12
import QtQuick.Layouts  1.12

import QGroundControl                   1.0
import QGroundControl.FactSystem        1.0
import QGroundControl.FactControls      1.0
import QGroundControl.ScreenTools       1.0
import QGroundControl.SettingsManager   1.0
import QGroundControl.Controls          1.0

FirstRunPrompt {
    title:      qsTr("Arace default video presets")
    promptId:   QGroundControl.corePlugin.araceFirstRunVideoPromptId

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

    // Here starts the general settings
    property string _mapProvider:               QGroundControl.settingsManager.flightMapSettings.mapProvider.value
    property string _mapType:                   QGroundControl.settingsManager.flightMapSettings.mapType.value

    Component.onCompleted: {
        QGroundControl.settingsManager.videoSettings.videoSource.value = "RTSP Video Stream"
    }

    ColumnLayout {
        id:         generalSettingsColumn
        spacing:    ScreenTools.defaultFontPixelHeight
        anchors.top: parent.top
        anchors.margins: _margins

        QGCLabel {
            id:         generalSettingsLabel
            text:       qsTr("Video settings")

            Layout.preferredWidth: videoGrid.width
            wrapMode: Text.WordWrap
        }

        Rectangle {
            Layout.preferredHeight: videoGrid.height + (_margins * 2)
            Layout.preferredWidth:  videoGrid.width + (_margins * 2)
            color:                  qgcPal.windowShade
            Layout.fillWidth:       true

            GridLayout {
                id:         videoGrid
                columns:    2
                visible:    _videoSettings.visible
                QGCLabel {
                    text:               qsTr("Video Settings")
                    Layout.columnSpan:  2
                    Layout.alignment:   Qt.AlignHCenter
                }
                QGCLabel {
                    id:         videoSourceLabel
                    text:       qsTr("Source")
                    visible:    !_videoAutoStreamConfig && _videoSettings.videoSource.visible
                }
                FactComboBox {
                    id:                     videoSource
                    Layout.preferredWidth:  _comboFieldWidth
                    indexModel:             false
                    fact:                   _videoSettings.videoSource
                    visible:                videoSourceLabel.visible
                }
                QGCLabel {
                    id:         udpPortLabel
                    text:       qsTr("UDP Port")
                    visible:    !_videoAutoStreamConfig && (_isUDP264 || _isUDP265 || _isMPEGTS) && _videoSettings.udpPort.visible
                }
                FactTextField {
                    Layout.preferredWidth:  _comboFieldWidth
                    fact:                   _videoSettings.udpPort
                    visible:                udpPortLabel.visible
                }
                QGCLabel {
                    id:         rtspUrlLabel
                    text:       qsTr("RTSP URL")
                    visible:    !_videoAutoStreamConfig && _isRTSP && _videoSettings.rtspUrl.visible
                }
                FactTextField {
                    Layout.preferredWidth:  _comboFieldWidth
                    fact:                   _videoSettings.rtspUrl
                    visible:                rtspUrlLabel.visible
                }
                QGCLabel {
                    id:         tcpUrlLabel
                    text:       qsTr("TCP URL")
                    visible:    !_videoAutoStreamConfig && _isTCP && _videoSettings.tcpUrl.visible
                }
                FactTextField {
                    Layout.preferredWidth:  _comboFieldWidth
                    fact:                   _videoSettings.tcpUrl
                    visible:                tcpUrlLabel.visible
                }
                QGCLabel {
                    text:                   qsTr("Aspect Ratio")
                    visible:                !_videoAutoStreamConfig && _isGst && _videoSettings.aspectRatio.visible
                }
                FactTextField {
                    Layout.preferredWidth:  _comboFieldWidth
                    fact:                   _videoSettings.aspectRatio
                    visible:                !_videoAutoStreamConfig && _isGst && _videoSettings.aspectRatio.visible
                }
                QGCLabel {
                    id:         videoFileFormatLabel
                    text:       qsTr("File Format")
                    visible:    _showSaveVideoSettings && _videoSettings.recordingFormat.visible
                }
                FactComboBox {
                    Layout.preferredWidth:  _comboFieldWidth
                    fact:                   _videoSettings.recordingFormat
                    visible:                videoFileFormatLabel.visible
                }
                QGCLabel {
                    id:         maxSavedVideoStorageLabel
                    text:       qsTr("Max Storage Usage")
                    visible:    _showSaveVideoSettings && _videoSettings.maxVideoSize.visible && _videoSettings.enableStorageLimit.value
                }
                FactTextField {
                    Layout.preferredWidth:  _comboFieldWidth
                    fact:                   _videoSettings.maxVideoSize
                    visible:                _showSaveVideoSettings && _videoSettings.enableStorageLimit.value && maxSavedVideoStorageLabel.visible
                }
                QGCLabel {
                    id:         videoDecodeLabel
                    text:       qsTr("Video decode priority")
                    visible:    forceVideoDecoderComboBox.visible
                }
                FactComboBox {
                    id:                     forceVideoDecoderComboBox
                    Layout.preferredWidth:  _comboFieldWidth
                    fact:                   _videoSettings.forceVideoDecoder
                    visible:                fact.visible
                    indexModel:             false
                }
                Item { width: 1; height: 1}
                FactCheckBox {
                    text:       qsTr("Disable When Disarmed")
                    fact:       _videoSettings.disableWhenDisarmed
                    visible:    !_videoAutoStreamConfig && _isGst && fact.visible
                }
                Item { width: 1; height: 1}
                FactCheckBox {
                    text:       qsTr("Low Latency Mode")
                    fact:       _videoSettings.lowLatencyMode
                    visible:    !_videoAutoStreamConfig && _isGst && fact.visible
                }
                Item { width: 1; height: 1}
                FactCheckBox {
                    text:       qsTr("Auto-Delete Saved Recordings")
                    fact:       _videoSettings.enableStorageLimit
                    visible:    _showSaveVideoSettings && fact.visible
                }
            }
        }
    }
}