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

import org.kde.plasma.core as Plasmacore
import org.kde.plasma.wallpapers.image as Wallpaper
import org.kde.plasma.plasmoid
import QtMultimedia

WallpaperItem {
    anchors.fill: parent
    id: main
    property string videoWallpaperBackgroundVideo: wallpaper.configuration.VideoWallpaperBackgroundVideo
    property bool playing: windowModel.playVideoWallpaper
    property bool isLoading: true
    onPlayingChanged: playing && !isLoading ? main.play() : main.pause()
    onVideoWallpaperBackgroundVideoChanged: {
        if (isLoading) return
        updateState()

    }

    WindowModel {
        id: windowModel
        screenGeometry: main.parent.screenGeometry
    }

    Rectangle {
        id: background
        anchors.fill: parent
        color: wallpaper.configuration.BackgroundColor

        Video {
            id: player
            source: wallpaper.configuration.VideoWallpaperBackgroundVideo
            loops: MediaPlayer.Infinite
            fillMode: wallpaper.configuration.FillMode
            anchors.fill: parent
            volume: wallpaper.configuration.MuteAudio ? 0.0 : 1
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
        running: true
        repeat: false
        interval: 3000
        onTriggered: {
            console.log(main.parent.screenGeometry);
            isLoading = false
            updateState()
        }
    }

    Component.onCompleted: {
        startTimer.start()
    }
}
