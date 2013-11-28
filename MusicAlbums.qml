/*
 * Copyright (C) 2013 Victor Thompson <victor.thompson@gmail.com>
 *                    Daniel Holm <d.holmen@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1
import Ubuntu.Components.Popups 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import QtMultimedia 5.0
import QtQuick.LocalStorage 2.0
import QtGraphicalEffects 1.0
import "settings.js" as Settings
import "meta-database.js" as Library
import "playlists.js" as Playlists
import "common"

Page {
    id: mainpage
    title: i18n.tr("Albums")

    property string artist: ""
    property string album: ""
    property string songtitle: ""
    property string cover: ""
    property string length: ""
    property string file: ""
    property string year: ""

    onVisibleChanged: {
        if (visible === true)
        {
            musicToolbar.setPage(mainpage);
        }
    }

    MusicSettings {
        id: musicSettings
    }

    GridView {
        id: albumlist
        anchors.fill: parent
        anchors.leftMargin: units.gu(1)
        anchors.topMargin: units.gu(1)
        anchors.bottomMargin: units.gu(1)
        cellHeight: (parent.height - units.gu(2))/3
        cellWidth: (parent.height - units.gu(2))/3
        model: albumModel.model
        delegate: albumDelegate
        flow: GridView.TopToBottom

        Component {
            id: albumDelegate
            Item {
                id: albumItem
                height: albumlist.cellHeight - units.gu(1)
                width: albumlist.cellHeight - units.gu(1)
                anchors.margins: units.gu(1)
                UbuntuShape {
                    id: albumShape
                    height: albumItem.width
                    width: albumItem.width
                    image: Image {
                        id: icon
                        fillMode: Image.Stretch
                        property string artist: model.artist
                        property string album: model.album
                        property string title: model.title
                        property string cover: model.cover
                        property string length: model.length
                        property string file: model.file
                        property string year: model.year
                        source: cover !== "" ? cover : "images/cover_default.png"
                    }
                    UbuntuShape {  // Background so can see text in current state
                        id: albumBg2
                        anchors.bottom: parent.bottom
                        color: styleMusic.common.black
                        height: units.gu(4)
                        width: parent.width
                    }
                    Rectangle {  // Background so can see text in current state
                        id: albumBg
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: units.gu(2)
                        color: styleMusic.common.black
                        height: units.gu(3)
                        width: parent.width
                    }
                    Label {
                        id: albumArtist
                        objectName: "albums-albumartist"
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: units.gu(1)
                        anchors.left: parent.left
                        anchors.leftMargin: units.gu(.25)
                        anchors.right: parent.right
                        anchors.rightMargin: units.gu(.25)
                        horizontalAlignment: Text.AlignHCenter
                        color: styleMusic.nowPlaying.labelSecondaryColor
                        elide: Text.ElideRight
                        text: artist
                        fontSize: "x-small"
                    }
                    Label {
                        id: albumLabel
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: units.gu(3)
                        anchors.left: parent.left
                        anchors.leftMargin: units.gu(.25)
                        anchors.right: parent.right
                        anchors.rightMargin: units.gu(.25)
                        horizontalAlignment: Text.AlignHCenter
                        color: styleMusic.common.white
                        elide: Text.ElideRight
                        text: album
                        fontSize: "small"
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onDoubleClicked: {
                    }
                    onPressAndHold: {
                    }
                    onClicked: {
                        albumTracksModel.filterAlbumTracks(album)
                        mainpage.artist = artist
                        mainpage.album = album
                        mainpage.file = file
                        mainpage.year = year
                        mainpage.cover = cover
                        PopupUtils.open(albumSheet)
                    }
                }
            }
        }
    }

    Component {
        id: albumSheet
        DefaultSheet {
            id: sheet
            anchors.bottomMargin: units.gu(.5)
            doneButton: false
            contentsHeight: parent.height
            contentsWidth: parent.width

            ListView {
                clip: true
                id: albumtrackslist
                width: parent.width
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                model: albumTracksModel.model
                delegate: albumTracksDelegate
                header: ListItem.Standard {
                    id: albumInfo
                    width: parent.width
                    height: units.gu(20)

                    UbuntuShape {
                        id: albumImage
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.margins: units.gu(1)
                        height: parent.height
                        width: height
                        image: Image {
                            source: Library.hasCover(mainpage.file) ? mainpage.cover : Qt.resolvedUrl("images/cover_default.png")
                        }
                    }
                    Label {
                        id: albumArtist
                        objectName: "albumsheet-albumartist"
                        wrapMode: Text.NoWrap
                        maximumLineCount: 1
                        fontSize: "small"
                        anchors.left: albumImage.right
                        anchors.leftMargin: units.gu(1)
                        anchors.top: parent.top
                        anchors.topMargin: units.gu(1.5)
                        anchors.right: parent.right
                        anchors.rightMargin: units.gu(1.5)
                        elide: Text.ElideRight
                        text: mainpage.artist
                    }
                    Label {
                        id: albumLabel
                        wrapMode: Text.NoWrap
                        maximumLineCount: 2
                        fontSize: "medium"
                        color: styleMusic.common.music
                        anchors.left: albumImage.right
                        anchors.leftMargin: units.gu(1)
                        anchors.top: albumArtist.bottom
                        anchors.topMargin: units.gu(0.8)
                        anchors.right: parent.right
                        anchors.rightMargin: units.gu(1.5)
                        elide: Text.ElideRight
                        text: mainpage.album
                    }
                    Label {
                        id: albumYear
                        wrapMode: Text.NoWrap
                        maximumLineCount: 1
                        fontSize: "x-small"
                        anchors.left: albumImage.right
                        anchors.leftMargin: units.gu(1)
                        anchors.top: albumLabel.bottom
                        anchors.topMargin: units.gu(2)
                        anchors.right: parent.right
                        anchors.rightMargin: units.gu(1.5)
                        elide: Text.ElideRight
                        text: i18n.tr("%1 | %2 song", "%1 | %2 songs", albumTracksModel.model.count).arg(mainpage.year, albumTracksModel.model.count)
                    }
                }

                onCountChanged: {
                    albumtrackslist.currentIndex = albumTracksModel.indexOf(currentFile)
                }

                Component {
                    id: albumTracksDelegate

                    ListItem.Standard {
                        id: track
                        iconFrame: false
                        progression: false
                        height: styleMusic.albums.itemHeight

                        MouseArea {
                            anchors.fill: parent
                            onDoubleClicked: {
                            }
                            onClicked: {
                                if (focus == false) {
                                    focus = true
                                }
                                trackClicked(albumTracksModel, index)  // play track
                                Library.addRecent(album, artist, cover, album, "album")
                                mainView.hasRecent = true
                                recentModel.filterRecent()

                                // TODO: This closes the SDK defined sheet
                                //       component. It should be able to close
                                //       albumSheet.
                                PopupUtils.close(sheet)
                            }
                        }

                        Label {
                            id: trackTitle
                            wrapMode: Text.NoWrap
                            maximumLineCount: 1
                            fontSize: "medium"
                            anchors.left: parent.left
                            anchors.leftMargin: units.gu(2)
                            anchors.top: parent.top
                            anchors.topMargin: units.gu(1)
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: units.gu(1)
                            anchors.right: expandItem.left
                            anchors.rightMargin: units.gu(1.5)
                            elide: Text.ElideRight
                            text: model.title == "" ? model.file : model.title
                        }

                        Image {
                            id: expandItem
                            anchors.right: parent.right
                            anchors.rightMargin: units.gu(2)
                            source: expandable.visible ? "images/dropdown-menu-up.svg" : "images/dropdown-menu.svg"
                            height: styleMusic.common.expandedItem
                            width: styleMusic.common.expandedItem
                            y: parent.y + (styleMusic.albums.itemHeight / 2) - (height / 2)
                        }

                        MouseArea {
                            anchors.bottom: parent.bottom
                            anchors.right: parent.right
                            anchors.top: parent.top
                            width: styleMusic.common.expandedItem * 3
                            onClicked: {
                               if(expandable.visible) {
                                   customdebug("clicked collapse")
                                   expandable.visible = false
                                   track.height = styleMusic.albums.itemHeight
                               }
                               else {
                                   customdebug("clicked expand")
                                   collapseExpand(-1);  // collapse all others
                                   expandable.visible = true
                                   track.height = styleMusic.albums.expandedHeight
                               }
                           }
                       }

                        Rectangle {
                            id: expandable
                            color: "transparent"
                            height: styleMusic.albums.expandHeight
                            visible: false
                            MouseArea {
                               anchors.fill: parent
                               onClicked: {
                                   customdebug("User pressed outside the playlist item and expanded items.")
                               }
                            }

                            Component.onCompleted: {
                                collapseExpand.connect(onCollapseExpand);
                            }

                            function onCollapseExpand(indexCol)
                            {
                                if ((indexCol === index || indexCol === -1) && expandable !== undefined && expandable.visible === true)
                                {
                                    customdebug("auto collapse")
                                    expandable.visible = false
                                    track.height = styleMusic.albums.itemHeight
                                }
                            }

                            // background for expander
                            Rectangle {
                                anchors.top: parent.top
                                anchors.topMargin: styleMusic.albums.itemHeight
                                color: styleMusic.common.black
                                height: styleMusic.albums.expandedHeight - styleMusic.albums.itemHeight
                                width: track.width
                                opacity: 0.4
                            }

                            // add to playlist
                            Rectangle {
                                id: playlistRow
                                anchors.top: parent.top
                                anchors.topMargin: ((styleMusic.albums.expandedHeight - styleMusic.albums.itemHeight) / 2)
                                                   + styleMusic.albums.itemHeight
                                                   - height

                                anchors.left: parent.left
                                anchors.leftMargin: styleMusic.albums.expandedLeftMargin
                                color: "transparent"
                                height: styleMusic.common.expandedItem
                                width: units.gu(15)
                                Icon {
                                    id: playlistTrack
                                    anchors.top: parent.top
                                    anchors.topMargin: height/2
                                    color: styleMusic.common.white
                                    name: "add"
                                    height: styleMusic.common.expandedItem
                                    width: styleMusic.common.expandedItem
                                }
                                Label {
                                    anchors.left: playlistTrack.right
                                    anchors.leftMargin: units.gu(0.5)
                                    anchors.top: parent.top
                                    color: styleMusic.common.white
                                    fontSize: "small"
                                    width: units.gu(5)
                                    text: i18n.tr("Add to playlist")
                                    wrapMode: Text.WordWrap
                                }
                                MouseArea {
                                   anchors.fill: parent
                                   onClicked: {
                                       expandable.visible = false
                                       track.height = styleMusic.albums.itemHeight
                                       chosenArtist = artist
                                       chosenTitle = title
                                       chosenTrack = file
                                       chosenAlbum = album
                                       chosenCover = cover
                                       chosenGenre = genre
                                       chosenIndex = index
                                       console.debug("Debug: Add track to playlist")
                                       PopupUtils.open(Qt.resolvedUrl("MusicaddtoPlaylist.qml"), mainView,
                                       {
                                           title: i18n.tr("Select playlist")
                                       } )
                                 }
                               }
                            }
                            // Queue
                            Rectangle {
                                id: queueRow
                                anchors.top: parent.top
                                anchors.topMargin: ((styleMusic.albums.expandedHeight - styleMusic.albums.itemHeight) / 2)
                                                   + styleMusic.albums.itemHeight
                                                   - height
                                anchors.left: playlistRow.left
                                anchors.leftMargin: units.gu(15)
                                color: "transparent"
                                height: styleMusic.common.expandedItem
                                width: units.gu(15)
                                Image {
                                    id: queueTrack
                                    anchors.top: parent.top
                                    anchors.topMargin: height/2
                                    source: "images/queue.png"
                                    height: styleMusic.common.expandedItem
                                    width: styleMusic.common.expandedItem
                                }
                                Label {
                                    anchors.left: queueTrack.right
                                    anchors.leftMargin: units.gu(0.5)
                                    anchors.top: parent.top
                                    color: styleMusic.common.white
                                    fontSize: "small"
                                    width: units.gu(5)
                                    text: i18n.tr("Add to queue")
                                    wrapMode: Text.WordWrap
                                }
                                MouseArea {
                                   anchors.fill: parent
                                   onClicked: {
                                       expandable.visible = false
                                       track.height = styleMusic.albums.itemHeight
                                       console.debug("Debug: Add track to queue: " + title)
                                       trackQueue.model.append({"title": title, "artist": artist, "file": file, "album": album, "cover": cover, "genre": genre})
                                 }
                               }
                            }
                        }

                        onFocusChanged: {
                        }
                        Component.onCompleted: {
                        }
                    }
                }
            }
        }
    }
}


