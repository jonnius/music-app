/*
 * Copyright (C) 2013, 2014
 *      Andrew Hayzen <ahayzen@gmail.com>
 *      Nekhelesh Ramananthan <krnekhelesh@gmail.com>
 *      Victor Thompson <victor.thompson@gmail.com>
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


Row {
    anchors {
        left: parent.left
        leftMargin: units.gu(1)
    }

    property alias covers: coverRow.covers
    property alias column: columnComponent.sourceComponent

    spacing: units.gu(1)

    CoverRow {
        id: coverRow
        anchors {
            top: parent.top
            topMargin: units.gu(1)
        }
        count: covers.length
        covers: []
        size: styleMusic.common.albumSize
    }

    Loader {
        id: columnComponent
        anchors {
            top: parent.top
            topMargin: units.gu(2)
        }
    }
}