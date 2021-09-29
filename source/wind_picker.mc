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


using Toybox.Graphics;
using Toybox.WatchUi;
using Toybox.Application.Storage;
using Toybox.Application.Properties;
using Toybox.Time;

class WindPicker extends WatchUi.Picker {

  function initialize(mode) {
    var title = new WatchUi.Text({
        :text=>mode.equals("dir") ? Rez.Strings.wind_dir : Rez.Strings.wind_force,
        :locX=>WatchUi.LAYOUT_HALIGN_CENTER,
        :locY=>WatchUi.LAYOUT_VALIGN_BOTTOM,
        :color=>Graphics.COLOR_WHITE});
    var confirm = new WatchUi.Text({
        :text=>"OK",
        :locX=>WatchUi.LAYOUT_HALIGN_CENTER,
        :locY=>WatchUi.LAYOUT_VALIGN_TOP,
        :color=>Graphics.COLOR_GREEN});
    var factories = new [1];
    factories[0] = new NumberFactory(0, mode.equals("dir") ? 359 : 100,
                                     mode.equals("dir") ? 1 : 1, {:font=>Graphics.FONT_MEDIUM});
    Picker.initialize({:title=>title, :pattern=>factories,
        :defaults=>[mode.equals("dir") ? wind_dir : wind_force], :confirm=>confirm});
  }

  function onUpdate(dc) {
    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
    dc.clear();
    Picker.onUpdate(dc);
  }
}

class WindPickerDelegate extends WatchUi.PickerDelegate {

  var _mode;

  function initialize(mode) {
    _mode = mode;
    PickerDelegate.initialize();
  }

  function onCancel() {
    WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
  }

  function onAccept(values) {
    if (_mode.equals("dir")) {
      wind_dir = values[0];
      Storage.setValue("wind_dir", wind_dir);
      last_update = Time.now().value();
      Storage.setValue("last_update", last_update);
      WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
      wind_color = Graphics.COLOR_BLACK;
      no_info_reason = "";

    } else {
      wind_force = values[0];
      Storage.setValue("wind_force", wind_force);
      last_update = Time.now().value();
      Storage.setValue("last_update", last_update);
      WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
      WatchUi.pushView(new WindPicker("dir"), new WindPickerDelegate("dir"), WatchUi.SLIDE_IMMEDIATE);
      //WatchUi.switchToView(new WindPicker("dir"), new WindPickerDelegate("dir"), WatchUi.SLIDE_IMMEDIATE);
    }

  }

}
