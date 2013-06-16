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
import org.nemomobile.folderlistmodel 1.0
import QtMultimedia 5.0
import QtQuick.LocalStorage 2.0
import "settings.js" as Settings
import "meta-database.js" as Library
import "playing-list.js" as PlayingList

MainView {
    objectName: i18n.tr("mainView")
    applicationName: i18n.tr("Music")

    width: units.gu(50)
    height: units.gu(75)
    Component.onCompleted: {
        libraryModel.populate()
    }


    // VARIABLES
    property string musicName: i18n.tr("Music")
    property string musicDir: ""
    property string appVersion: '0.3'
    property int playing: 0
    property int itemnum: 0
    property bool random: false
    property bool scrobble: false
    property string artist
    property string album
    property string song
    property string tracktitle
    property string lastfmusername
    property string lastfmpassword

    // FUNCTIONS
    function scrobbleSong () {
        lastfmusername = Settings.getSetting("lastfmusername") // get username
        lastfmpassword = Settings.getSetting("lastfmpassword") // get password

        var signature = Qt.md5("api_key07c14de06e622165b5b4d55deb85f4damethodauth.getMobileSession
                                 password"+lastfmpassword+"username"+lastfmusername+"mysecret")

        var scrobblefile = player.source // get the current playing track
        var scrobbleartist = Settings.getSetting(scrobblefile, "artist")
        var scrobbletrack = Settings.getSetting(scrobblefile, "title")
        var scrobblealbum = Settings.getSetting(scrobblefile, "album")

        // scrobble/send the track to last.fm
        var scrobble = new XMLHttpRequest();
            scrobble.open("POST", "http://ws.audioscrobbler.com/2.0/");
            scrobble.send();

        console.debug("Debug: Track is now scrobbled.")
    }

    function previousSong() {
        getSong(-1)
    }

    function nextSong() {
        getSong(1)
        //nowPlaying() // send "now playing" to last.fm
    }

    function getSong(direction) {
        if (random) {
            var now = new Date();
            var seed = now.getSeconds();
            do {
                var num = (Math.floor((PlayingList.size()) * Math.random(seed)));
                console.log(num)
                console.log(playing)
            } while (num == playing && PlayingList.size() > 0)
            player.source = Qt.resolvedUrl(PlayingList.getList()[num])
            musicTracksPage.filelistCurrentIndex = PlayingList.at(num)
            playing = num
            console.log("MediaPlayer statusChanged, currentIndex: " + musicTracksPage.filelistCurrentIndex)
        } else {
            if ((playing < PlayingList.size() - 1 && direction === 1 )
                    || (playing > 0 && direction === -1)) {
                console.log("playing: " + playing)
                console.log("filelistCount: " + musicTracksPage.filelistCount)
                console.log("PlayingList.size(): " + PlayingList.size())
                playing += direction
                if (playing === 0) {
                    musicTracksPage.filelistCurrentIndex = playing + (itemnum - PlayingList.size())
                } else {
                    musicTracksPage.filelistCurrentIndex += direction
                }
                player.source = Qt.resolvedUrl(PlayingList.getList()[playing])
            } else if(direction === 1) {
                console.log("playing: " + playing)
                console.log("filelistCount: " + musicTracksPage.filelistCount)
                console.log("PlayingList.size(): " + PlayingList.size())
                playing = 0
                musicTracksPage.filelistCurrentIndex = playing + (musicTracksPage.filelistCount - PlayingList.size())
                player.source = Qt.resolvedUrl(PlayingList.getList()[playing])
            } else if(direction === -1) {
                console.log("playing: " + playing)
                console.log("filelistCount: " + musicTracksPage.filelistCount)
                console.log("PlayingList.size(): " + PlayingList.size())
                playing = PlayingList.size() - 1
                musicTracksPage.filelistCurrentIndex = playing + (musicTracksPage.filelistCount - PlayingList.size())
                player.source = Qt.resolvedUrl(PlayingList.getList()[playing])
            }
            console.log("MediaPlayer statusChanged, currentIndex: " + musicTracksPage.filelistCurrentIndex)
        }
        console.log("Playing: "+player.source)
        player.play()
    }

    MediaPlayer {
        id: player
        muted: false
        onStatusChanged: {
            if (status == MediaPlayer.EndOfMedia) {
                // scrobble it
                //scrobbleSong()
                // next track
                nextSong()
            }
        }

        onPositionChanged: {
            musicTracksPage.needsUpdate = true
        }
    }

    LibraryListModel {
        id: libraryModel
    }

    FolderListModel {
        id: folderModel
        showDirectories: true
        filterDirectories: false
        nameFilters: ["*.mp3","*.ogg","*.flac","*.wav","*.oga"] // file types supported.
        path: Settings.getSetting("initialized") === "true" && Settings.getSetting("currentfolder") !== "" ? Settings.getSetting("currentfolder") : homePath() + "/Music"
        onPathChanged: {
            console.log("Path changed: " + folderModel.path)
        }
    }

    FolderListModel {
        id: folderScannerModel
        property int count: 0
        readsMediaMetadata: true
        isRecursive: true
        showDirectories: true
        filterDirectories: false
        nameFilters: ["*.mp3","*.ogg","*.flac","*.wav","*.oga"] // file types supported.
        onPathChanged: {
            console.log("Scanner Path changed: " + folderModel.path)
        }
    }

    /* this is how a queue looks like
    ListElement {
        title: "Dancing in the Moonlight"
        artist: "Thin Lizzy"
        file: "dancing"
    }*/

    // list of tracks on startup. This is just during development
    ListModel {
        id: trackQueue
    }

    // list of songs, which has been removed.
    ListModel {
        id: removedTrackQueue
    }

    // list of single tracks
    ListModel {
        id: singleTracks
    }

    Tabs {
        id: tabs
        anchors.fill: parent

        // First tab is all music
        Tab {
            id: musicTab
            objectName: "musictab"
            anchors.fill: parent
            title: i18n.tr("Music")

            // Tab content begins here
            page: MusicTracks {
                id: musicTracksPage
            }
        }

        // Second tab is arists
        Tab {
            id: artistTab
            objectName: "artisttab"
            anchors.fill: parent
            title: i18n.tr("Artist")

            // tab content
            page: Page {
                id: musicaArtistPage
            }
        }

        // third tab is albums
        Tab {
            id: albumTab
            objectName: "albumtab"
            anchors.fill: parent
            title: i18n.tr("Albums")

            // Tab content begins here
            page: Page {
                id: musicAlbumPage
            }
        }

        // fourth tab is the playlists
        Tab {
            id: playlistTab
            objectName: "playlisttab"
            anchors.fill: parent
            title: i18n.tr("Playlists")

            // Tab content begins here
            page: Page {
                id: musicPlaylistPage
            }
        }

        // Fifth is the settings
        /* FIX LATER
        Tab {
            id: settingsTab
            objectName: "settingstab"
            anchors.fill: parent
            title: i18n.tr("Settings")

            // Tab content begins here
            page: MusicSettings {
                id: musicSettings
            }
        } */
    }

    //MusicTracks { id: musicTracksPage }

} // main view
