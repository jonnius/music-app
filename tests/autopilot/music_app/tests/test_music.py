# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Music app autopilot tests."""

from __future__ import absolute_import

from autopilot.matchers import Eventually
from testtools.matchers import Equals, NotEquals

from music_app.tests import MusicTestCase


class TestMainWindow(MusicTestCase):

    def test_reads_music_library(self):
        """ tests if the music library is populated from our
        fake mediascanner database"""

        self.assertThat(self.main_view.get_main_view, Eventually(NotEquals(None)))
        mainView = self.main_view.get_main_view()
        title = lambda: mainView.currentTracktitle
        artist = lambda: mainView.currentArtist
        self.assertThat(title, Eventually(Equals("Foss Yeaaaah! (Radio Edit)")))
        self.assertThat(artist, Eventually(Equals("Benjamin Kerensa")))

    def test_play_pause(self):
        """ Test playing and pausing a track (Music Library must exist) """

        self.assertThat(self.main_view.get_play_button, Eventually(NotEquals(None)))
        playbutton = self.main_view.get_play_button()
        mainView = self.main_view.get_main_view()

        """ Track is not playing"""
        self.assertThat(mainView.isPlaying, Eventually(Equals(False)))
        self.pointing_device.click_object(playbutton)

        """ Track is playing"""
        self.assertThat(mainView.isPlaying, Eventually(Equals(True)))

        """ Track is not playing"""
        self.pointing_device.click_object(playbutton)
        self.assertThat(mainView.isPlaying, Eventually(Equals(False)))

    def test_next(self):
        """ Test going to next track (Music Library must exist) """

        self.assertThat(self.main_view.get_forward_button, Eventually(NotEquals(None)))
        forwardbutton = self.main_view.get_forward_button()
        mainView = self.main_view.get_main_view()
        title = lambda: mainView.currentTracktitle
        artist = lambda: mainView.currentArtist
        self.assertThat(title, Eventually(Equals("Foss Yeaaaah! (Radio Edit)")))
        self.assertThat(artist, Eventually(Equals("Benjamin Kerensa")))

        """ Track is not playing"""
        self.assertThat(mainView.isPlaying, Equals(False))
        self.pointing_device.click_object(forwardbutton)

        """ Track is playing"""
        self.assertThat(mainView.isPlaying, Eventually(Equals(True)))
        self.assertThat(title, Eventually(Equals("Swansong")))
        self.assertThat(artist, Eventually(Equals("Josh Woodward")))
