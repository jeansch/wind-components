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

using Toybox.WatchUi;


class WindComponentsDelegate extends WatchUi.BehaviorDelegate {

  function initialize() {
    BehaviorDelegate.initialize();
  }

  function onSelect() {
    WatchUi.pushView(new WindComponentsSetWindView(),
                     new WindComponentsSetWindDelegate(),
                     WatchUi.SLIDE_IMMEDIATE);
    return true;
  }
}


var set_wind_mode = 0;


class WindComponentsSetWindDelegate extends WatchUi.BehaviorDelegate {

  function initialize() {
    BehaviorDelegate.initialize();
  }

  function onSelect() {
    set_wind_mode = !set_wind_mode;
    WatchUi.requestUpdate();
    return true;
  }

  function onPreviousPage() {
    if (set_wind_mode) {
      wind_dir += 10;
      wind_dir = wind_dir == 370 ? 10: wind_dir;
    } else  {
      wind_force += 5;
    }
    WatchUi.requestUpdate();
    return true;
  }

  function onNextPage() {
    if (set_wind_mode) {
      wind_dir -= 10;
      wind_dir = wind_dir == -10 ? 350: wind_dir;
    } else  {
      wind_force -= 5;
      wind_force = wind_force < 0 ? 0: wind_force;
    }
    WatchUi.requestUpdate();
    return true;
  }
}

// round watches: grep round- bin/default.jungle | grep -v ^round | awk '{print $1}'
