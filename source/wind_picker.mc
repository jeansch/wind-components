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

class WindPicker extends WatchUi.Picker {

  function initialize(mode) {
    var title = new WatchUi.Text({
        :text=>mode ? Rez.Strings.wind_dir : Rez.Strings.wind_force,
        :locX=>WatchUi.LAYOUT_HALIGN_CENTER,
        :locY=>WatchUi.LAYOUT_VALIGN_BOTTOM,
        :color=>Graphics.COLOR_WHITE});
    // hidden (default would be 'OK' white)
    var confirm = new WatchUi.Text({
        :text=>"OK",
        :locX=>WatchUi.LAYOUT_HALIGN_CENTER,
        :locY=>WatchUi.LAYOUT_VALIGN_TOP,
        :color=>Graphics.COLOR_GREEN});
    var factories = new [1];
    factories[0] = new NumberFactory(0, mode ? 359 : 100,
                                     1, {:font=>Graphics.FONT_MEDIUM});
    Picker.initialize({:title=>title, :pattern=>factories, :confirm=>confirm});
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
    if (_mode) {
      wind_dir = values[0];
    } else {
      wind_force = values[0];
    }
    WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
  }

}
