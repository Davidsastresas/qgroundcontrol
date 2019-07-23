/*
This is a custom progress bar for governor values
*/



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

ProgressBar {

    id: qhprogressbar

    implicitHeight: 10
    implicitWidth: getProgressBarWidth()//Function defined in QHInstruments.qml

    property var valueType: ["normal", "warning", "critical"]
                
    //Values and conditions need to be added especifically
                

    //Comon style for the background of the progress bars
    style: ProgressBarStyle{

        background: Rectangle {
            radius: _radiusBars
            color: qgcPal.colorGrey
            implicitWidth: parent.Layout.preferredWidth
            implicitHeight: parent.Layout.preferredHeight
        }

        progress: Rectangle {

            radius: _radiusBars

            color: {
                if(qhprogressbar.valueType != null){
                    if(qhprogressbar.valueType == "normal")
                        return qgcPal.colorGreen
                    if(qhprogressbar.valueType == "warning")
                        return qgcPal.colorOrange
                }
                return qgcPal.colorRed
            }

            ColorAnimation on color {
                running: qhprogressbar.valueType == "critical"
                from: qgcPal.colorRed
                to: qgcPal.colorGrey
                duration: 1000
                loops: Animation.Infinite
            }
        }
    }
}