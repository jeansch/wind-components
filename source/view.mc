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

using Toybox.WatchUi as Ui;
using Toybox.Timer;
using Toybox.Graphics as Gfx;
using Toybox.System;
using Toybox.Math;


class WindComponentsLib extends Ui.View {
  var cx;
  var cy;
  var radius;
  var size;

  function initialize() {
    Ui.View.initialize();
  }

  function onLayout(dc) {
    size = dc.getWidth() > dc.getHeight() ? dc.getHeight() : dc.getWidth();
    cx = dc.getWidth() / 2;
    cy = dc.getHeight() / 2;
    radius = size / 2 - 4;
  }

  function p2c(x, y, angle, length) {
    return [Math.ceil(x - length * Math.sin(angle)),
            Math.ceil(y - length * Math.cos(angle))];
  }

  function draw_arcs(dc, pw) {
    dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
    dc.setPenWidth(pw);
    dc.drawArc(cx, cy, radius, Gfx.ARC_CLOCKWISE, 250, 110);
    dc.drawArc(cx, cy, radius, Gfx.ARC_CLOCKWISE, 70, 290);
  }

  function draw_wind_arrow(dc, pw, wind_arrow, wind_force) {
    dc.setPenWidth(pw);
    dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
    var arrow_end = p2c(cx, cy, wind_arrow * (Math.PI / 180),
                        radius - 2 * (radius / 10));
    var arrow_start = p2c(cx, cy, wind_arrow * (Math.PI / 180),
                          radius - 3 * (radius / 4));
    dc.drawLine(arrow_end[0], arrow_end[1], arrow_start[0], arrow_start[1]);
    var barb_force = wind_force > 70 ? 70 : wind_force;
    var nbarbs = (barb_force / 10).toNumber();
    for (var nb = 1; barb_force > 0; nb++) {
      var barb_start = p2c(cx, cy, wind_arrow * (Math.PI / 180),
                           radius - (nb + 1) * (radius / 10));
      var barb_end = p2c(barb_start[0], barb_start[1],
                         (wind_arrow * (Math.PI/180)) - (45 * (Math.PI/180)),
                         radius / (barb_force > 5 ? 5 : 10));
      dc.drawLine(barb_start[0], barb_start[1], barb_end[0], barb_end[1]);
      barb_force -= 10;
    }
  }
}


class WindComponentsView extends WindComponentsLib {

  var timer;

  function initialize() {
    WindComponentsLib.initialize();
  }

  function onShow() {
    timer = new Timer.Timer();
    timer.start(method(:timerCallback), 1000, true);
  }

  function timerCallback() {
    Ui.requestUpdate();
  }

  function onHide() {
    timer.stop();
  }

  function onUpdate(dc) {
    var heading = Sensor.getInfo().heading;
    heading = heading == null ? 0 : heading;
    heading = heading >= 0 ? heading : 2 * Math.PI + heading;
    components(dc, heading);
  }

  function components(dc, heading) {
    dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_WHITE);
    dc.clear();
    draw_arcs(dc, 2);
    // Runway background
    dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT);
    dc.fillRectangle(size / 2 - (size / 10), 0,  2 * (size / 10), size);
    // Heading
    var top = heading * 180 / Math.PI;
    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    dc.drawText(cx, size / 16, Gfx.FONT_TINY,
                (top).format("%03d") + "°",
                Gfx.TEXT_JUSTIFY_CENTER|Gfx.TEXT_JUSTIFY_VCENTER);
    // Runway current side
    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    dc.drawText(cx, size - 2 * (size / 10),
                Gfx.FONT_MEDIUM, (top / 10).format("%02d"),
                Gfx.TEXT_JUSTIFY_CENTER|Gfx.TEXT_JUSTIFY_VCENTER);
    dc.fillRectangle(size / 2 - (size / 100) - 3 * (size / 100),
                     2 * (size / 100) + size - (size / 10) - (size / 20),
                     2 * (size / 100), size / 10);
    dc.fillRectangle(size / 2 - (size / 100),
                     2 * (size / 100) + size - (size / 10) - (size / 20),
                     2 * (size / 100), size / 10);
    dc.fillRectangle(size / 2 - (size / 100) + 3 * (size / 100),
                     2 * (size / 100) + size - (size / 10) - (size / 20),
                     2 * (size / 100), size / 10);
    // Runway opposite side
    var bottom = top + 180;
    if (bottom > 359) {
      bottom = top - 180;
    }
    dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
    dc.drawText(cx, size / 10 + 2 * (size / 10),
                Gfx.FONT_TINY,
                (bottom / 10).format("%02d"),
                Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
    dc.fillRectangle(size / 2 - (size / 100) - 3 * (size / 100),
                     2 * (size / 10) - (size / 20),
                     2 * (size / 100), size / 10);
    dc.fillRectangle(size / 2 - (size / 100),
                     2 * (size / 10) - (size / 20),
                     2 * (size / 100), size / 10);
    dc.fillRectangle(size / 2 - (size / 100) + 3 * (size / 100),
                     2 * (size / 10) - (size / 20),
                     2 * (size / 100), size / 10);
    var wind_arrow = top - wind_dir;
    wind_arrow = wind_arrow < 0 ? wind_arrow + 360 : wind_arrow;
    draw_wind_arrow(dc, 2, wind_arrow, wind_force);
    var xspd = (wind_force * (Math.sin(wind_arrow * Math.PI / 180)));
    xspd = xspd < 0 ? -xspd : xspd;
    dc.drawText((wind_arrow > 180 ? 0 : cx + (size / 16)) + 1 * (size / 20),
                cy - (size / 20) ,
                Gfx.FONT_SMALL,
                "X: " + xspd.format("%0.1f"),
                Gfx.TEXT_JUSTIFY_LEFT|Gfx.TEXT_JUSTIFY_VCENTER);
    var hspd = (wind_force * (Math.cos(wind_arrow * Math.PI / 180)));
    if (hspd < 0) {
      dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
    }
    dc.drawText((wind_arrow > 180 ? 0 : cx + (size / 16)) + 1 * (size / 20),
                cy + (size / 20) ,
                Gfx.FONT_SMALL,
                "H: " + hspd.format("%0.1f"),
                Gfx.TEXT_JUSTIFY_LEFT|Gfx.TEXT_JUSTIFY_VCENTER);
  }
}

class WindComponentsSetWindView extends WindComponentsLib {

  var wind_dir_str = null;
  var wind_force_str = null;

  function initialize() {
    WindComponentsLib.initialize();
  }

  function onLayout(dc) {
    WindComponentsLib.onLayout(dc);
    wind_dir_str = WatchUi.loadResource(Rez.Strings.wind_dir);
    wind_force_str = WatchUi.loadResource(Rez.Strings.wind_force);
  }

  function onUpdate(dc) {
    dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_WHITE);
    dc.clear();
    draw_arcs(dc, 2);
    var wind_arrow = -wind_dir;
    wind_arrow = wind_arrow < 0 ? wind_arrow + 360 : wind_arrow;
    draw_wind_arrow(dc, 2, wind_arrow, wind_force);
    dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT);
    dc.drawText(cx, cy, Gfx.FONT_LARGE,
                (set_wind_mode ? wind_dir_str : wind_force_str) + " " +
                (set_wind_mode ? wind_dir : wind_force).format("%d"),
                Gfx.TEXT_JUSTIFY_CENTER|Gfx.TEXT_JUSTIFY_VCENTER);
  }
}
