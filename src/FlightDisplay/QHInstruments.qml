import QtQuick                  2.3
import QtQuick.Controls         1.2
import QtQuick.Controls.Styles  1.4
import QtQuick.Dialogs          1.2
import QtLocation               5.3
import QtPositioning            5.3
import QtQuick.Layouts          1.2
import QtQuick.Window           2.2
import QtQml.Models             2.1

import QGroundControl               1.0
import QGroundControl.Airspace      1.0
import QGroundControl.Controllers   1.0
import QGroundControl.Controls      1.0
import QGroundControl.FactSystem    1.0
import QGroundControl.FlightDisplay 1.0
import QGroundControl.FlightMap     1.0
import QGroundControl.Palette       1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Vehicle       1.0

// onUserPannedChanged: {
//     if (userPanned) {
//         console.log("user panned")
//         userPanned = false
//         _disableVehicleTracking = true
//         panRecenterTimer.restart()
//     }
// }


Item {

    property var    _activeVehicle:                 QGroundControl.multiVehicleManager.activeVehicle
    property bool   _communicationLost:             _activeVehicle ? _activeVehicle.connectionLost : false
    property var    _radiusBars:                    1

    readonly property real _margins:            ScreenTools.defaultFontPixelHeight * 0.5
    readonly property real _textSrinkFactor:    0.2

    // Don't allow governor bars panel to chew more than 1/5 of full window
    function getProgressBarWidth() {
        var defaultWidth = ScreenTools.defaultFontPixelWidth * 20
        var maxWidth = mainWindow.width * 0.2
        return Math.min(maxWidth, defaultWidth)
    }

    Rectangle {

        // Prevent all clicks from going through to lower layers
        DeadMouseArea {
            anchors.fill: parent
        }  

        id: qhgovernor

        height: qhinstrumentsgrid.height
        width:  qhinstrumentsgrid.width + 10
        radius: 1

        anchors.bottom: parent.bottom
        anchors.right:  parent.right

        color: qgcPal.window
        
        GridLayout {

            id:                     qhinstrumentsgrid
            columnSpacing:          ScreenTools.defaultFontPixelWidth
            columns:                3
            anchors.left:           parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin:     _margins * 0.5

            QGCLabel { 
                Layout.column: 1
                Layout.row: 1
                text: qsTr("Voltage:") 
            }

            QHProgressBar {
                
                id: progressbarvoltage
                
                //Position parameters
                Layout.column: 2
                Layout.row: 1

                //Values and conditions
                minimumValue: 42
                maximumValue: 51   
                indeterminate: (_activeVehicle && _activeVehicle.battery.voltage.value != -1) ? false : true
                value: (_activeVehicle && _activeVehicle.battery.voltage.value != -1) ? _activeVehicle.battery.voltage.value : 0

                //This logic should be in a Controller interface. For speed pourpouses it will be first implemented here
                valueType: {
                    if(_activeVehicle && _activeVehicle.battery.voltage.value != -1 ){
                        if (_activeVehicle.battery.voltage.value <= 48 && _activeVehicle.battery.voltage.value >= 46)
                        return "warning"
                        if (_activeVehicle.battery.voltage.value < 46)
                        return "critical"
                    }
                    return "normal"
                }
            }

            QGCLabel { 
                Layout.column: 3
                Layout.row: 1
                text: (_activeVehicle && _activeVehicle.battery.voltage.value != -1) ? (_activeVehicle.battery.voltage.valueString + " " + _activeVehicle.battery.voltage.units) : "N/A" 
            }

            QGCLabel { 
                Layout.column: 1
                Layout.row: 2
                text: qsTr("Battery current:") 
            }
            
            //ProgressBar for the negative side of Battery Current
            ProgressBar {

                Layout.column: 2
                Layout.row: 2

                Layout.preferredHeight: 10
                Layout.preferredWidth: getProgressBarWidth()*0.5

                minimumValue: 0
                maximumValue: 15 //Max current the battereis are supposed to charge to is 10A

                indeterminate: (_activeVehicle && _activeVehicle.battery.current.value !== -1.0) ? false : true //IF -1.0 doesnt work, use -1
                value: (_activeVehicle && _activeVehicle.battery.current.value !== -1.0 && _activeVehicle.battery.current.value < 0) ? (15 +_activeVehicle.battery.current.value) : 15
                
                style: ProgressBarStyle {

                    background: Rectangle{
                        radius: _radiusBars
                        color: qgcPal.colorRed
                        implicitWidth: parent.width
                        implicitHeight: parent.height
                    }

                    progress: Rectangle{
                        color: qgcPal.colorGrey
                        radius: _radiusBars
                    }
                }


                //ProgressBar for the positive side  of Battery Current
                ProgressBar {

                    implicitHeight:     10
                    implicitWidth:      getProgressBarWidth()*0.5

                    anchors.top:        parent.top
                    anchors.left:       parent.right

                    minimumValue: 0
                    maximumValue: 15 //Max current the battereis are supposed to charge to is 10A

                    indeterminate: (_activeVehicle && _activeVehicle.battery.current.value !== -1.0) ? false : true
                    value: (_activeVehicle && _activeVehicle.battery.current.value !== -1.0 && _activeVehicle.battery.current.value >= 0) ? (_activeVehicle.battery.current.value) : 0

                    style: ProgressBarStyle {

                        background: Rectangle{
                            radius: _radiusBars
                            color: qgcPal.colorGrey
                            implicitWidth: parent.width
                            implicitHeight: parent.height
                        }

                        progress: Rectangle{
                            color: qgcPal.colorGreen
                            radius: _radiusBars
                        }
                    }
                }
            }
            
            QGCLabel { 
                Layout.column: 3
                Layout.row: 2
                text: (_activeVehicle && _activeVehicle.battery.current.value != -1.0) ? (_activeVehicle.battery.current.valueString + " " + _activeVehicle.battery.current.units) : "N/A"
             }
            
            QGCLabel { 
                Layout.column: 1
                Layout.row: 3
                text: qsTr("Generator current:") 
            }
            
            QHProgressBar {

                id: progressbargenerator

                valueType: "normal"

                //Position parameters
                Layout.column: 2
                Layout.row: 3
                
                //Values and conditions
                maximumValue: 50    //Max current the generator produces is 50A
                indeterminate: (_activeVehicle && _activeVehicle.battery.current_generator.value != -1) ? false : true
                value: (_activeVehicle && _activeVehicle.battery.current_generator.value != -1) ? _activeVehicle.battery.current_generator.value : 0
            }

            QGCLabel { 
                Layout.column: 3
                Layout.row: 3
                text: (_activeVehicle && _activeVehicle.battery.current_generator.value != -1) ? (_activeVehicle.battery.current_generator.valueString + " " + _activeVehicle.battery.current_generator.units) : "N/A"
             }

            
            QGCLabel { 
                Layout.column: 1
                Layout.row: 5
                text: qsTr("Motors current:")
            }

            QHProgressBar {

                id: progressbarrotor

                valueType: "normal" //This progressBar will always be green

                //Position parameters
                Layout.column: 2
                Layout.row: 5
                
                //Values and conditions
                maximumValue: 55    //Max current consumed by the motors has been recorded to be 55A
                indeterminate: (_activeVehicle && _activeVehicle.battery.current_rotor.value != -1) ? false : true //Si la condicion no funciona, poner !== que es como estaba
                value: (_activeVehicle && _activeVehicle.battery.current_rotor.value != -1) ? _activeVehicle.battery.current_rotor.value : 0
            }

            QGCLabel { 
                Layout.column: 3
                Layout.row: 5
                text: (_activeVehicle && _activeVehicle.battery.current_rotor.value != -1) ? (_activeVehicle.battery.current_rotor.valueString + " " + _activeVehicle.battery.current_rotor.units) : "N/A" 
            }

            QGCLabel { 
                Layout.column: 1
                Layout.row: 6
                text: qsTr("Fuel level:") 
            }

            QHProgressBar {

                //Position parameters
                Layout.column: 2
                Layout.row: 6
                
                //Values and conditions
                maximumValue: 5000  //Max capacity of the fuel tank is 5000ml
                indeterminate: (_activeVehicle && _activeVehicle.battery.fuel_level.value != -1) ? false : true
                value: (_activeVehicle && _activeVehicle.battery.fuel_level.value != -1) ? _activeVehicle.battery.fuel_level.value : 0

                //This logic should be in a Controller interface. For speed pourpouses it will be first implemented here
                valueType: {
                    if(_activeVehicle && _activeVehicle.battery.fuel_level.value != -1 ){
                        if (_activeVehicle.battery.fuel_level.value < 500)
                        return "critical"
                        if (_activeVehicle.battery.fuel_level.value >= 500 && _activeVehicle.battery.fuel_level.value < 1000)
                        return "warning"
                    }
                    return "normal"
                }
                
            }
            
            QGCLabel { 
                Layout.column: 3
                Layout.row: 6
                text: (_activeVehicle && _activeVehicle.battery.fuel_level.value != -1) ? (_activeVehicle.battery.fuel_level.valueString + " " + _activeVehicle.battery.fuel_level.units) : "N/A" 
            }

            QGCLabel { 
                Layout.column: 1
                Layout.row: 7
                text: qsTr("Throttle percentage:") 
            }

            QHProgressBar {

                id: progressbarthrottle

                //Position parameters
                Layout.column: 2
                Layout.row: 7
                
                //Values and conditions
                maximumValue: 100
                indeterminate: (_activeVehicle && _activeVehicle.battery.throttle_percentage.value != -1) ? false : true
                value: (_activeVehicle && _activeVehicle.battery.throttle_percentage.value != -1) ? _activeVehicle.battery.throttle_percentage.value : 0
            
                //This logic should be in a Controller interface. For speed pourpouses it will be first implemented here
                valueType: {
                    if(_activeVehicle && _activeVehicle.battery.throttle_percentage.value != -1 ){
                        if (_activeVehicle.battery.throttle_percentage.value >= 90)
                        return "critical"
                        if (_activeVehicle.battery.throttle_percentage.value >= 85 && _activeVehicle.battery.throttle_percentage.value < 90)
                        return "warning"
                    }
                    return "normal"
                }
            }
            
            QGCLabel { 
                Layout.column: 3
                Layout.row: 7
                text: (_activeVehicle && _activeVehicle.battery.throttle_percentage.value != -1) ? (_activeVehicle.battery.throttle_percentage.valueString + " " + _activeVehicle.battery.throttle_percentage.units) : "N/A" 
            }
        }

        // Communication lost overlay
        Rectangle {
            anchors.fill:   parent
            color:          qgcPal.window
            opacity:        0.75
            visible:        _communicationLost

            QGCLabel {
                anchors.fill:           parent
                horizontalAlignment:    Text.AlignHCenter
                verticalAlignment:      Text.AlignVCenter
                text:                   qsTr("Communication lost")
            }
        }
    }
}
