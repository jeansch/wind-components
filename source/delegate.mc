/* This file is part of wind-components */
/* Copyright (C) 2021  Jean Schurger */

/* This program is free software; you can redistribute it and/or modify */
/* it under the terms of the GNU General Public License as published by */
/* the Free Software Foundation; either version 3 of the License, or */
/* (at your option) any later version. */

/* This program is distributed in the hope that it will be useful, */
/* but WITHOUT ANY WARRANTY; without even the implied warranty of */
/* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the */
/* GNU General Public License for more details. */

/* You should have received a copy of the GNU General Public License */
/* along with this program; if not, write to the Free Software Foundation, */
/* Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA */


// round watches: grep round- bin/default.jungle | grep -v ^round | awk '{print $1}'

using Toybox.WatchUi;

class WindComponentsDelegate extends WatchUi.BehaviorDelegate {

  function initialize() {
    BehaviorDelegate.initialize();
  }

  function onSelect() {
    onMenu();
  }

  function onMenu() {
    WatchUi.pushView(new WindPicker(0), new WindPickerDelegate(0), WatchUi.SLIDE_IMMEDIATE);
    WatchUi.pushView(new WindPicker(1), new WindPickerDelegate(1), WatchUi.SLIDE_IMMEDIATE);
    return true;
  }

}
