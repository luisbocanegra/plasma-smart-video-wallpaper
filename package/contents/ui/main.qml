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
import QtMultimedia
import org.kde.plasma.plasma5support as P5Support
import org.kde.plasma.plasmoid
import Qt5Compat.GraphicalEffects

WallpaperItem {
    anchors.fill: parent
    id: main
    property bool isLoading: true
    property string videoUrls: wallpaper.configuration.VideoUrls
    property var videos: []
    property int currentVideoIndex: 0
    property int pauseBatteryLevel: wallpaper.configuration.PauseBatteryLevel
    property bool playing: windowModel.playVideoWallpaper && !batteryPausesVideo && !screenLocked && !screenIsOff
    property bool showBlur: windowModel.showBlur && !batteryDisablesBlur
    property bool screenLocked: screenModel.screenIsLocked
    property bool batteryPausesVideo: pauseBattery && wallpaper.configuration.BatteryPausesVideo
    property bool batteryDisablesBlur: pauseBattery && wallpaper.configuration.BatteryDisablesBlur

    property bool screenIsOff: screenModel.screenIsOff
    property bool screenLockedPausesVideo: wallpaper.configuration.ScreenLockedPausesVideo
    property bool screenOffPausesVideo: wallpaper.configuration.ScreenOffPausesVideo

    onPlayingChanged: {
        playing && !isLoading ? main.play() : main.pause()
    }
    onVideoUrlsChanged: {
        videos = videoUrls.trim().split("\n")
        currentVideoIndex = 0
        if (isLoading) return
        // console.error(videoUrls);
        player.position = player.duration
        updateState()
    }

    property QtObject pmSource: P5Support.DataSource {
        id: pmSource
        engine: "powermanagement"
        connectedSources: sources
        onSourceAdded: source => {
            disconnectSource(source);
            connectSource(source);
        }
        onSourceRemoved: source => {
            disconnectSource(source);
        }
    }

    property bool pauseBattery: {
        let result = false
        if (pmSource.data.Battery["Has Cumulative"] && pmSource.data["Battery"]["State"] === "Discharging") {
            result = pauseBatteryLevel > pmSource.data.Battery.Percent
        }
        return result
    }

    WindowModel {
        id: windowModel
        screenGeometry: main.parent.screenGeometry
        videoIsPlaying: main.playing
    }

    ScreenModel {
        id: screenModel
        checkScreenLock: screenLockedPausesVideo
        checkScreenState: screenOffPausesVideo
    }

    Rectangle {
        id: background
        anchors.fill: parent
        color: wallpaper.configuration.BackgroundColor

        VideoOutput {
            id: videoOutput
            fillMode: VideoOutput.PreserveAspectCrop
            anchors.fill: parent
        }

        AudioOutput {
            id: audioOutput
            muted: wallpaper.configuration.MuteAudio
        }

        MediaPlayer {
            id: player
            source: videos[currentVideoIndex]
            videoOutput: videoOutput
            audioOutput: audioOutput
            loops: (videos.length > 1) ? 1 : MediaPlayer.Infinite
            // onPositionChanged: (position) => {
            //     if (position == duration) {
            onMediaStatusChanged: (status) => {
                if (status == MediaPlayer.EndOfMedia) {
                    console.log("video ended");
                    currentVideoIndex = (currentVideoIndex + 1) % videos.length
                    // console.error("Video next:",source);
                    play()
                }
            }

            onSourceChanged: {
                // play()
                console.log("current video source", source);
            }
        }
    }

    FastBlur {
        source: player
        radius: showBlur ? wallpaper.configuration.BlurRadius : 0
        anchors.fill: parent
        Behavior on radius {
            NumberAnimation {
                duration: 300
            }
        }
    }

    function play(){
        pauseTimer.stop();
        player.play();
    }
    function pause(){
        pauseTimer.start();
    }

    function updateState() {
        if (playing) {
            main.pause()
            main.play()
        } else {
            main.play()
            main.pause()
        }
    }

    Timer {
        id: pauseTimer
        interval: 300
        onTriggered: {
            player.pause()
        }
    }

    Timer {
        id: startTimer
        interval: 100
        onTriggered: {
            isLoading = false
            updateState()
        }
    }

    Component.onCompleted: {
        videos = videoUrls.trim().split("\n")
        startTimer.start()
    }
}
