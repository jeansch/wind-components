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

using Toybox.Application;
using Toybox.Graphics;
using Toybox.Application.Storage;
using Toybox.Time;

var wind_dir = 0;
var wind_force = 0;
var wind_color = Graphics.COLOR_WHITE;
var position;
var no_info_reason = "";
var last_update = null;

class WindComponents extends Application.AppBase {

  function initialize() {
    AppBase.initialize();
    var v;
    v = Storage.getValue("wind_dir");
    if (v != null) {
      wind_dir = v >= 360 ? 0 : v;
    }
    v = Storage.getValue("wind_force");
    if (v != null) {
      wind_force = v;
    }
    v = Storage.getValue("wind_color");
    if (v != null) {
      wind_color = v;
    }
    v = Storage.getValue("last_update");
    if (v != null) {
      last_update = v;
    }
    if (last_update == null) {
      no_info_reason = WatchUi.loadResource(Rez.Strings.error_set_wind);
    }
    if (last_update != null) {
      var elapsed = Time.now().value() - last_update;
      // 3600 * 6
      if (elapsed > 21600) {
        no_info_reason = WatchUi.loadResource(Rez.Strings.error_too_old);
      }
    }
  }

  function getInitialView() {
    return [new WindComponentsView(), new WindComponentsDelegate()];
  }

}
