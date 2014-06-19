/*
 * Copyright (C) 2013 Andrew Hayzen <ahayzen@gmail.com>
 *                    Daniel Holm <d.holmen@gmail.com>
 *                    Victor Thompson <victor.thompson@gmail.com>
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
import Ubuntu.Components.Popups 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import Ubuntu.MediaScanner 0.1
import Ubuntu.Thumbnailer 0.1
import QtQuick.LocalStorage 2.0
import "../meta-database.js" as Library

Page {
    id: albumStackPage
    anchors.bottomMargin: units.gu(.5)
    tools: null
    visible: false

    property string artist: ""
    property var covers: []

    onVisibleChanged: {
        if (visible) {
            musicToolbar.setPage(albumStackPage, null, mainPageStack)
        }
    }

    ListView {
        id: albumtrackslist
        anchors {
            bottomMargin: wideAspect ? musicToolbar.fullHeight : musicToolbar.mouseAreaOffset + musicToolbar.minimizedHeight
            fill: parent
        }
        delegate: albumTracksDelegate
        header: artistHeaderDelegate
        model: AlbumsModel {
            id: artistsModel
            albumArtist: albumStackPage.artist
            store: musicStore
        }
        width: parent.width

        Component {
            id: artistHeaderDelegate
            ListItem.Standard {
                height: units.gu(30)
                CoverRow {
                    id: artistImage
                    anchors {
                        left: parent.left
                        top: parent.top
                    }

                    count: albumtrackslist.count
                    size: parent.height
                    covers: albumStackPage.covers;
                    spacing: units.gu(4)
                }
                UbuntuShape {  // Background so can see text in current state
                    id: albumBg2
                    anchors.bottom: parent.bottom
                    color: styleMusic.common.black
                    height: units.gu(10)
                    width: parent.height
                    radius: "medium"
                }
                Rectangle {  // Background so can see text in current state
                    id: albumBg
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: units.gu(8)
                    color: styleMusic.common.black
                    height: units.gu(3)
                    width: parent.height
                }
                Label {
                    id: albumCount
                    anchors {
                        bottom: parent.bottom
                        bottomMargin: units.gu(8)
                        left: parent.left
                        leftMargin: units.gu(1)
                        right: parent.right
                        rightMargin: units.gu(1)
                    }
                    color: styleMusic.nowPlaying.labelSecondaryColor
                    elide: Text.ElideRight
                    text: i18n.tr("%1 album", "%1 albums", albumtrackslist.count).arg(albumtrackslist.count)
                    fontSize: "small"
                }
                Label {
                    id: artistLabel
                    anchors {
                        left: parent.left
                        leftMargin: units.gu(1)
                        bottom: parent.bottom
                        bottomMargin: units.gu(5)
                        right: parent.right
                        rightMargin: units.gu(1)
                    }
                    color: styleMusic.common.white
                    elide: Text.ElideRight
                    text: albumStackPage.artist
                    fontSize: "large"
                }

                SongsModel {
                    id: songArtistModel
                    albumArtist: albumStackPage.artist
                    // HACK: Temporarily setting limit to 500 to ensure model
                    //       is populated. See lp:1326753
                    limit: 500
                    store: musicStore
                }

                // Play
                Rectangle {
                    id: playRow
                    anchors {
                        left: parent.left
                        leftMargin: units.gu(1)
                        bottom: parent.bottom
                        //bottomMargin: units.gu(0)
                    }
                    color: "transparent"
                    height: units.gu(4)
                    width: units.gu(10)
                    Image {
                        id: playTrack
                        anchors.verticalCenter: parent.verticalCenter
                        source: "../images/add-to-playback.png"
                        height: styleMusic.common.expandedItem
                        width: styleMusic.common.expandedItem
                    }
                    Label {
                        anchors {
                            left: playTrack.right
                            leftMargin: units.gu(0.5)
                            verticalCenter: parent.verticalCenter
                        }
                        fontSize: "small"
                        color: styleMusic.nowPlaying.labelSecondaryColor
                        width: parent.width - playTrack.width - units.gu(1)
                        text: i18n.tr("Play all")
                        wrapMode: Text.WordWrap
                        maximumLineCount: 3
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            trackClicked(songArtistModel, 0, true)

                            // TODO: add links to recent
                        }
                    }
                }

                // Queue
                Rectangle {
                    id: queueAllRow
                    anchors {
                        left: playRow.right
                        leftMargin: units.gu(1)
                        bottom: parent.bottom
                        //bottomMargin: units.gu(1)
                    }
                    color: "transparent"
                    height: units.gu(4)
                    width: units.gu(15)
                    Image {
                        id: queueAll
                        objectName: "albumsheet-queue-all"
                        anchors.verticalCenter: parent.verticalCenter
                        source: "../images/add.svg"
                        height: styleMusic.common.expandedItem
                        width: styleMusic.common.expandedItem
                    }
                    Label {
                        anchors {
                            left: queueAll.right
                            leftMargin: units.gu(0.5)
                            verticalCenter: parent.verticalCenter
                        }
                        fontSize: "small"
                        color: styleMusic.nowPlaying.labelSecondaryColor
                        width: parent.width - queueAll.width - units.gu(1)
                        text: i18n.tr("Add to queue")
                        wrapMode: Text.WordWrap
                        maximumLineCount: 3
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            addQueueFromModel(songArtistModel)
                        }
                    }
                }
            }
        }

        Component {
            id: albumTracksDelegate


            ListItem.Standard {
                id: albumInfo
                width: parent.width
                height: units.gu(20)

                SongsModel {
                    id: songAlbumArtistModel
                    albumArtist: model.artist
                    album: model.title
                    // HACK: Temporarily setting limit to 500 to ensure model
                    //       is populated. See lp:1326753
                    limit: 500
                    store: musicStore
                }
                Repeater {
                    id: songAlbumArtistModelRepeater
                    model: songAlbumArtistModel
                    delegate: Text { text: new Date(model.date).toLocaleString(Qt.locale(),'yyyy'); visible: false }
                    property string year: ""
                    onItemAdded: year = item.text
                }

                CoverRow {
                    id: albumImage
                    anchors {
                        top: parent.top
                        left: parent.left
                        margins: units.gu(1)
                        verticalCenter: parent.verticalCenter
                    }
                    count: 1
                    size: parent.height
                    covers: [{author: model.artist, album: model.title}]
                    objectName: "artistsheet-albumcover"
                    spacing: units.gu(2)

                    MouseArea {
                        anchors.fill: parent
                        onDoubleClicked: {
                        }
                        onClicked: {
                            if (focus == false) {
                                focus = true
                            }

                            songsPage.album = model.title;

                            songsPage.line1 = model.artist
                            songsPage.line2 = model.title
                            songsPage.isAlbum = true
                            songsPage.covers = [{author: model.artist, album: model.title}]
                            songsPage.title = i18n.tr("Album")

                            mainPageStack.push(songsPage)
                        }
                    }
                }

                Label {
                    id: albumArtist
                    objectName: "artistsheet-albumartist"
                    wrapMode: Text.NoWrap
                    maximumLineCount: 1
                    fontSize: "small"
                    color: styleMusic.common.subtitle
                    anchors.left: albumImage.right
                    anchors.leftMargin: units.gu(1)
                    anchors.top: parent.top
                    anchors.topMargin: units.gu(1.5)
                    anchors.right: parent.right
                    anchors.rightMargin: units.gu(1.5)
                    elide: Text.ElideRight
                    text: model.artist
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
                    text: model.title
                }
                Label {
                    id: albumYear
                    wrapMode: Text.NoWrap
                    maximumLineCount: 1
                    fontSize: "x-small"
                    color: styleMusic.common.subtitle
                    anchors.left: albumImage.right
                    anchors.leftMargin: units.gu(1)
                    anchors.top: albumLabel.bottom
                    anchors.topMargin: units.gu(2)
                    anchors.right: parent.right
                    anchors.rightMargin: units.gu(1.5)
                    elide: Text.ElideRight
                    text: i18n.tr(songAlbumArtistModelRepeater.year + " | %1 song",
                                  songAlbumArtistModelRepeater.year + " | %1 songs",
                                  songAlbumArtistModelRepeater.count).arg(songAlbumArtistModelRepeater.count)
                }

                // Play
                Rectangle {
                    id: playRow
                    anchors.top: albumYear.bottom
                    anchors.topMargin: units.gu(1)
                    anchors.left: albumImage.right
                    anchors.leftMargin: units.gu(1)
                    color: "transparent"
                    height: units.gu(3)
                    width: units.gu(15)
                    Image {
                        id: playTrack
                        objectName: "albumsheet-playtrack"
                        anchors.verticalCenter: parent.verticalCenter
                        source: "../images/add-to-playback.png"
                        height: styleMusic.common.expandedItem
                        width: styleMusic.common.expandedItem
                    }
                    Label {
                        anchors.left: playTrack.right
                        anchors.leftMargin: units.gu(0.5)
                        anchors.verticalCenter: parent.verticalCenter
                        fontSize: "small"
                        color: styleMusic.common.subtitle
                        width: parent.width - playTrack.width - units.gu(1)
                        text: i18n.tr("Play all")
                        wrapMode: Text.WordWrap
                        maximumLineCount: 3
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            Library.addRecent(model.title, artist, "", model.title, "album")
                            mainView.hasRecent = true
                            recentModel.filterRecent()
                            trackClicked(songAlbumArtistModel, 0, true)
                        }
                    }
                }

                // Queue
                Rectangle {
                    id: queueRow
                    anchors.top: playRow.bottom
                    anchors.topMargin: units.gu(1)
                    anchors.left: albumImage.right
                    anchors.leftMargin: units.gu(1)
                    color: "transparent"
                    height: units.gu(3)
                    width: units.gu(15)
                    Image {
                        id: queueTrack
                        objectName: "albumsheet-queuetrack"
                        anchors.verticalCenter: parent.verticalCenter
                        source: "../images/add.svg"
                        height: styleMusic.common.expandedItem
                        width: styleMusic.common.expandedItem
                    }
                    Label {
                        anchors.left: queueTrack.right
                        anchors.leftMargin: units.gu(0.5)
                        anchors.verticalCenter: parent.verticalCenter
                        fontSize: "small"
                        color: styleMusic.common.subtitle
                        width: parent.width - queueTrack.width - units.gu(1)
                        text: i18n.tr("Add to queue")
                        wrapMode: Text.WordWrap
                        maximumLineCount: 3
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            addQueueFromModel(songAlbumArtistModel)
                        }
                    }
                }
            }
        }
    }
}

