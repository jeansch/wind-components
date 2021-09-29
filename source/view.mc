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
using Toybox.Timer;
using Toybox.Graphics;
using Toybox.Math;

class WindComponentsView extends WatchUi.View {

  var timer;
  var cx;
  var cy;
  var radius;
  var size;

  function initialize() {
    WatchUi.View.initialize();
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
    dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
    dc.setPenWidth(pw);
    dc.drawArc(cx, cy, radius, Graphics.ARC_CLOCKWISE, 250, 110);
    dc.drawArc(cx, cy, radius, Graphics.ARC_CLOCKWISE, 70, 290);
  }

  function draw_wind_arrow(dc, pw, color, wind_arrow, wind_force) {
    dc.setPenWidth(pw);
    dc.setColor(color, Graphics.COLOR_TRANSPARENT);
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


  function onShow() {
    timer = new Timer.Timer();
    timer.start(method(:timerCallback), 1000, true);
  }

  function timerCallback() {
    WatchUi.requestUpdate();
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
    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
    dc.clear();
    draw_arcs(dc, 2);
    // Runway background
    dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
    dc.fillRectangle(size / 2 - (size / 10), 0,  2 * (size / 10), size);
    // Heading
    var top = heading * 180 / Math.PI;
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    dc.drawText(cx, size / 16, Graphics.FONT_TINY,
                (top).format("%03d") + "°",
                Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
    // Runway current side
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    dc.drawText(cx, size - 2 * (size / 10),
                Graphics.FONT_MEDIUM, (top / 10).format("%02d"),
                Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
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
    dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
    dc.drawText(cx, size / 10 + 2 * (size / 10),
                Graphics.FONT_TINY,
                (bottom / 10).format("%02d"),
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    dc.fillRectangle(size / 2 - (size / 100) - 3 * (size / 100),
                     2 * (size / 10) - (size / 20),
                     2 * (size / 100), size / 10);
    dc.fillRectangle(size / 2 - (size / 100),
                     2 * (size / 10) - (size / 20),
                     2 * (size / 100), size / 10);
    dc.fillRectangle(size / 2 - (size / 100) + 3 * (size / 100),
                     2 * (size / 10) - (size / 20),
                     2 * (size / 100), size / 10);

    if (no_info_reason.length() > 0) {
      var message = WatchUi.loadResource(Rez.Strings.no_wind_information) +
        "\n (" + no_info_reason + ")";
      dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
      dc.fillRectangle(10, cy - 10, dc.getWidth() - 20, 20);
      dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_WHITE);
      dc.drawText(cx, cy, Graphics.FONT_SMALL, message,
                  Graphics.TEXT_JUSTIFY_CENTER |
                  Graphics.TEXT_JUSTIFY_VCENTER);
      return;
    }

    var wind_arrow = top - wind_dir;
    var hspd = (wind_force * (Math.cos(wind_arrow * Math.PI / 180)));
    wind_arrow = wind_arrow < 0 ? wind_arrow + 360 : wind_arrow;
    draw_wind_arrow(dc, 2, hspd < 0.02 ? Graphics.COLOR_RED: wind_color,
                    wind_arrow, wind_force);
    var xspd = (wind_force * (Math.sin(wind_arrow * Math.PI / 180)));
    xspd = xspd < 0.01 ? -xspd : xspd;
    dc.setColor(wind_color, Graphics.COLOR_TRANSPARENT);
    dc.drawText((wind_arrow > 180 ? 0 : cx + (size / 16)) + 1 * (size / 20),
                cy - (size / 20) ,
                Graphics.FONT_SMALL,
                "X: " + xspd.format("%0.1f") + "KT",
                Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER);

    if (hspd < 0.01) {
      dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
    }
    dc.drawText((wind_arrow > 180 ? 0 : cx + (size / 16)) + 1 * (size / 20),
                cy + (size / 20) ,
                Graphics.FONT_SMALL,
                "H: " + hspd.format("%0.1f") + "KT",
                Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER);
  }
}
