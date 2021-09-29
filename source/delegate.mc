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
using Toybox.System;
using Toybox.Application.Properties;
using Toybox.Timer;
using Toybox.Graphics;
using Toybox.Communications;
using Toybox.Application.Storage;
using Toybox.Time;

class WindComponentsDelegate extends WatchUi.BehaviorDelegate {

  function initialize() {
    BehaviorDelegate.initialize();
  }

  function onSelect() {
    onMenu();
  }

  function onMenu() {
    var menu = new WatchUi.Menu2({:title=>Rez.Strings.menu_title});
    menu.addItem(new WatchUi.MenuItem(Rez.Strings.manual_label, Rez.Strings.manual_sublabel, "manual", {}));
    menu.addItem(new WatchUi.MenuItem(Rez.Strings.auto_label, Rez.Strings.auto_sublabel, "auto", {}));
    WatchUi.pushView(menu, new MenuDelegate(), WatchUi.SLIDE_IMMEDIATE );
    return true;
  }

}


class ProgressDelegate extends WatchUi.BehaviorDelegate
{
    var mCallback;
    function initialize(callback) {
        mCallback = callback;
        BehaviorDelegate.initialize();
    }

    function onBack() {
        mCallback.invoke();
        return true;
    }
}



class MenuDelegate extends WatchUi.Menu2InputDelegate {

  var progress_bar;
  var timer;
  var apikey;
  var count = 0;

  function initialize() {
    Menu2InputDelegate.initialize();
  }

  function onPosition(info) {
    Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));
    timer.stop();
    count = 0;
    if (info.accuracy < 2) {
      no_info_reason = WatchUi.loadResource(Rez.Strings.error_position);
      WatchUi.popView(WatchUi.SLIDE_DOWN);
      return;
    }
    var lat = info.position.toDegrees()[0];
    var lon = info.position.toDegrees()[1];
    progress_bar = new WatchUi.ProgressBar(WatchUi.loadResource(Rez.Strings.waiting_weather), null);
    WatchUi.popView(WatchUi.SLIDE_DOWN);
    WatchUi.pushView(progress_bar,
                         new ProgressDelegate(method(:stopTimer)),
                         WatchUi.SLIDE_DOWN);
    //WatchUi.switchToView(progress_bar,
    //                    new ProgressDelegate(method(:stopTimer)),
    //                    WatchUi.SLIDE_DOWN);

    timer.start(method(:timerCallbackWeather), 1000, true );
    Communications.makeJsonRequest("https://api.openweathermap.org/data/2.5/weather",
                                   {"lat"=>lat, "lon"=>lon, "appid"=>apikey}, {}, method(:onReceive));
  }

  function onReceive(code, data) {
    if (code == 200) {
      wind_force = (data.get("wind").get("speed") * 1.95652173913).toNumber();
      // wind_force = (((data.get("wind").get("speed") *
      // 3600 / 1000) / 1.6) / 1.15) ;
      Storage.setValue("wind_force", wind_force);
      wind_dir = data.get("wind").get("deg");
      Storage.setValue("wind_dir", wind_dir);
      wind_color = Graphics.COLOR_BLUE;
      Storage.setValue("wind_color", wind_color);
      last_update = Time.now().value();
      Storage.setValue("last_update", last_update);
    } else {
      no_info_reason = "API request failed";
    }
    timer.stop();
    WatchUi.popView(WatchUi.SLIDE_DOWN);
  }

  function onSelect(item) {
    if( item.getId().equals("manual") ) {
      WatchUi.popView(WatchUi.SLIDE_DOWN);
      WatchUi.pushView(new WindPicker("force"),
                       new WindPickerDelegate("force"),
                       WatchUi.SLIDE_IMMEDIATE);
      //WatchUi.switchToView(new WindPicker("force"),
      //                     new WindPickerDelegate("force"),
      //                     WatchUi.SLIDE_IMMEDIATE);
    } else if ( item.getId().equals("auto") ) {
      no_info_reason = "";
      apikey = Properties.getValue("apikey");
      if (apikey.length() == 0) {
        no_info_reason = WatchUi.loadResource(Rez.Strings.error_apikey);
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return;
      }
      Position.enableLocationEvents(Position.LOCATION_ONE_SHOT, method(:onPosition));
      if (timer == null) {
        timer = new Timer.Timer();
      }
      progress_bar = new WatchUi.ProgressBar(WatchUi.loadResource(Rez.Strings.waiting_position), null);
      //WatchUi.switchToView(progress_bar, new ProgressDelegate(method(:stopTimer)), WatchUi.SLIDE_DOWN);
      WatchUi.popView(WatchUi.SLIDE_DOWN);
      WatchUi.pushView(progress_bar, new ProgressDelegate(method(:stopTimer)), WatchUi.SLIDE_DOWN);
      timer.start(method(:timerCallbackPos), 1000, true);
    } else {
      WatchUi.requestUpdate();
    }
  }

  function stopTimer() {
    if (timer != null) {
      timer.stop();
    }
  }

  function timerCallbackPos() {
    count += 1;
    if (count > 30) {
      timer.stop();
      Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));
      no_info_reason = WatchUi.loadResource(Rez.Strings.error_position);
      WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
  }

  function timerCallbackWeather() {
    count += 1;
    if (count > 10) {
      timer.stop();
      no_info_reason = WatchUi.loadResource(Rez.Strings.error_weather);
      WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
  }

  function onBack() {
    WatchUi.popView(WatchUi.SLIDE_DOWN);
  }
}
