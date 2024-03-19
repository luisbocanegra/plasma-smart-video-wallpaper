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

//import QtQuick 2.1
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import org.kde.plasma.core as PlasmaCore
import org.kde.kitemmodels 1.0 as KItemModels

import org.kde.taskmanager 0.1 as TaskManager

Item {

    id: wModel
    property var screenGeometry
    property bool playVideoWallpaper: true
    property bool currentWindowMaximized: false
    property bool isActiveWindowPinned: false
    property int pauseMode: wallpaper.configuration.PauseMode

    TaskManager.VirtualDesktopInfo { id: virtualDesktopInfo }
    TaskManager.ActivityInfo { id: activityInfo }
    TaskManager.TasksModel {
        id: tasksModel
        sortMode: TaskManager.TasksModel.SortVirtualDesktop
        groupMode: TaskManager.TasksModel.GroupDisabled

        activity: activityInfo.currentActivity
        virtualDesktop: virtualDesktopInfo.currentDesktop
        screenGeometry: wModel.screenGeometry

        filterByActivity: true
        filterByVirtualDesktop: true
        filterByScreen: true

        onActiveTaskChanged: updateWindowsinfo(wModel.pauseMode)
        onDataChanged: updateWindowsinfo(wModel.pauseMode)
        Component.onCompleted: {
            maximizedWindowModel.sourceModel = tasksModel
            fullScreenWindowModel.sourceModel = tasksModel
            minimizedWindowModel.sourceModel = tasksModel
            onlyWindowsModel.sourceModel = tasksModel
        }
    }

    KItemModels.KSortFilterProxyModel {
        id: onlyWindowsModel
        filterRole: TaskManager.AbstractTasksModel.IsWindow
        filterString: 'true'
        onDataChanged: updateWindowsinfo(wModel.pauseMode)
        onCountChanged: updateWindowsinfo(wModel.pauseMode)
    }

    KItemModels.KSortFilterProxyModel {
        id: maximizedWindowModel
        filterRole: TaskManager.AbstractTasksModel.IsMaximized
        filterString: 'true'
        onDataChanged: updateWindowsinfo(wModel.pauseMode)
        onCountChanged: updateWindowsinfo(wModel.pauseMode)
    }
    KItemModels.KSortFilterProxyModel {
        id: fullScreenWindowModel
        filterRole: TaskManager.AbstractTasksModel.IsFullScreen
        filterString: 'true'
        onDataChanged: updateWindowsinfo(wModel.pauseMode)
        onCountChanged: updateWindowsinfo(wModel.pauseMode)
    }

    KItemModels.KSortFilterProxyModel {
        id: minimizedWindowModel
        filterRole: TaskManager.AbstractTasksModel.IsMinimized
        filterString: 'true'
        onDataChanged: updateWindowsinfo(wModel.pauseMode)
        onCountChanged: updateWindowsinfo(wModel.pauseMode)
    }


    function dumpProps(obj) {
        console.error("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
        for (var k of Object.keys(obj)) {
            print(k + "=" + obj[k]+"\n")
        }
    }

    function updateWindowsinfo(pauseMode) {
        var abstractTasksModel = TaskManager.AbstractTasksModel
        var IsMaximized = abstractTasksModel.IsMaximized
        var IsFullScreen = abstractTasksModel.IsFullScreen
        var IsActive = abstractTasksModel.IsActive
        var AppPid = abstractTasksModel.AppPid

        switch(pauseMode) {
            case 0:
                // maximized/fullscreen
                var joinApps  = [];
                var minApps  = [];
                var aObj;
                var i;
                var j;
                // add fullscreen apps
                for (i = 0 ; i < fullScreenWindowModel.count ; i++){
                    let pid = fullScreenWindowModel.data(fullScreenWindowModel.index(i, 0), AppPid);
                    joinApps.push(pid)
                }
                // add maximized apps
                for (i = 0 ; i < maximizedWindowModel.count ; i++){
                    let pid = maximizedWindowModel.data(maximizedWindowModel.index(i, 0), AppPid);
                    joinApps.push(pid)                
                }

                // add minimized apps
                for (i = 0 ; i < minimizedWindowModel.count ; i++){
                    let pid = minimizedWindowModel.data(minimizedWindowModel.index(i, 0), AppPid);
                    minApps.push(pid)
                }

                joinApps = removeDuplicates(joinApps) // for qml Kubuntu 18.04
                joinApps.sort();
                minApps.sort();

                var twoStates = 0
                j = 0;
                for(i = 0 ; i < minApps.length ; i++){
                    if(minApps[i] === joinApps[j]){
                        twoStates = twoStates + 1;
                        j = j + 1;
                    }
                }
                playVideoWallpaper = (fullScreenWindowModel.count + maximizedWindowModel.count - twoStates) == 0 ? true : false
                break
            case 1:
                // at least one window is shown (busy)
                playVideoWallpaper = (onlyWindowsModel.count === minimizedWindowModel.count) ? true : false
                break
            case 2:
                // never pause
                playVideoWallpaper = true;
                break
        }
    }
    
    function removeDuplicates(arrArg){
        return arrArg.filter(function(elem, pos,arr) {
            return arr.indexOf(elem) == pos;
        });
    }
}

