/*
 *  Copyright 2018 Rog131 <samrog131@hotmail.com>
 *  Copyright 2019 adhe   <adhemarks2@gmail.com>
 *  Copyright 2024 Luis Bocanegra <luisbocanegra17b@gmail.com>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
 */

import QtQuick
import QtQuick.Controls
import org.kde.kquickcontrols as KQuickControls
import QtQuick.Dialogs
import QtQuick.Layouts
import QtMultimedia
import org.kde.kirigami as Kirigami
import org.kde.kquickcontrols 2.0 as KQuickControls
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM


Kirigami.FormLayout {
    id: root
    twinFormLayouts: parentLayout
    property alias formLayout: root

    property alias cfg_VideoWallpaperBackgroundVideo: videoPathLine.text
    property int  cfg_FillMode: 2
    property bool cfg_MuteAudio: true
    property bool cfg_DoublePlayer: true

    property int cfg_PauseMode: wallpaper.configuration.PauseMode
    property alias cfg_BackgroundColor: colorButton.color

    RowLayout {
        Layout.fillWidth:true
        Kirigami.FormData.label: i18nd("@label:video_file", "Video path:")
        TextField {
            id: videoPathLine
            Layout.fillWidth:true
            placeholderText: i18nd("@text:placeholder_video_file", "/media/videos/waves.mp4")
            text: cfg_VideoWallpaperBackgroundVideo
            // readOnly : true
        }
        Button {
            id: imageButton
            Kirigami.Icon {
                anchors.fill: parent
                source: "folder-videos-symbolic"
                PlasmaCore.ToolTipArea {
                    anchors.fill: parent
                    subText: i18nd("@tooltip","Pick video")
                }
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {fileDialog.open() }
            }
        }
    }

    ComboBox {
        Kirigami.FormData.label: i18nd("@option:video_fill_mode", "Fill mode:")
        id: videoFillMode
        model: [
            {
                'label': i18nd("@option:video_stretch", "Stretch"),
                'fillMode': VideoOutput.Stretch
            },
            {
                'label': i18nd("@option:video_scaled", "Scaled, Keep Proportions"),
                'fillMode': VideoOutput.PreserveAspectFit
            },
            {
                'label': i18nd("@option:video_scaled_cropped", "Scaled and Cropped"),
                'fillMode': VideoOutput.PreserveAspectCrop
            }
        ]
        textRole: "label"
        onCurrentIndexChanged: cfg_FillMode = model[currentIndex]["fillMode"]
        Component.onCompleted: setMethod();

        function setMethod() {
            for (var i = 0; i < model.length; i++) {
                if (model[i]["fillMode"] == wallpaper.configuration.FillMode) {
                    videoFillMode.currentIndex = i;
                }
            }
        }
    }

    KQuickControls.ColorButton {
        id: colorButton
        Kirigami.FormData.label: i18nd("@button:background_color", "Background:")
        visible: cfg_FillMode === VideoOutput.PreserveAspectFit
        dialogTitle: i18nd("@dialog:background_color_title", "Select Background Color")
    }


    RadioButton {
        id: maximizedPauseRadioButtton
        Kirigami.FormData.label: i18nd("@buttonGroup:pause_mode", "Pause video:")
        text: i18n("When there are maximized or full-screen windows.")
        ButtonGroup.group: pauseModeGroup
        property int index: 0
        checked: wallpaper.configuration.PauseMode === index
    }
    RadioButton {
        id: busyPauseRadioButton
        text: i18n("When the desktop is busy.")
        ButtonGroup.group: pauseModeGroup
        property int index: 1
        checked: wallpaper.configuration.PauseMode === index
    }
    RadioButton {
        id: neverPauseRadioButton
        text: i18n("Never")
        ButtonGroup.group: pauseModeGroup
        property int index: 2
        checked: wallpaper.configuration.PauseMode === index
    }
    ButtonGroup {
        id: pauseModeGroup
        onCheckedButtonChanged: {
            if (checkedButton) {
                cfg_PauseMode = checkedButton.index
            }
        }
    }

    CheckBox {
        id: muteRadio
        Kirigami.FormData.label: i18nd("@checkbox:mute_audio", "Mute audio:")
        checked: cfg_MuteAudio
        onCheckedChanged: {
            if (checked) {
                cfg_MuteAudio = true
            } else {
                cfg_MuteAudio = false
            }
        }
    }

    FileDialog {
        id: fileDialog
        fileMode : FileDialog.OpenFile
        title: i18nd("@dialog_title:pick_video", "Pick a video file")
        nameFilters: [ "Video files (*.mp4 *.mpg *.ogg *.mov *.webm *.flv *.matroska *.avi *wmv)", "All files (*)" ]
        onAccepted: {
            cfg_VideoWallpaperBackgroundVideo = fileDialog.selectedFile
        }
    }
}
