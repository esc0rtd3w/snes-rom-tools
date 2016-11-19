================================================================================
 GradientTool v0.8.2.1 - HDMA Gradient Generator, by ExoticMatter
================================================================================

--------
Overview
--------
GradientTool is just that; a tool with which you can create gradients from
scratch. You can then generate code for HDMA to insert into your SMW hack.

Requires .NET Framework 3.5 or 4.0; make sure one or the other is installed
before trying to use GradientTool.

-----
Usage
-----
Initially, there will be two gradients on the right of the window. One will be a
smooth 24-bit gradient, and the other will be a 15-bit gradient. The one on the
left is how the gradient will (or should) appear in an emulator.

Between the gradients is a slider. Double-click anywhere on the slider to insert
a gradient point.

To move a gradient point, just drag it around.

To change the colour or position of a gradient point, double-click it; the
gradient stop editor will appear.

To remove a gradient point, right-click it. You will be prompted before the
gradient point is removed.

The gradient stop editor is similar to the Windows Color Dialog, but with more
features.
You can enter decimal numbers as HSL/RGB values; you can also manually specify
the gradient stop's offset here.
For the HSL/RGB units, you may choose degrees/percentage (degrees for hue,
percentage for everything else), 0 .. 240 (HSB values in the standard Windows
colour picker), and 0 .. 255 (standard 24-bit RGB values).

In addition, it has an eyedropper feature. Just click on the eyedropper, and
click anywhere on your desktop, and voila! you can now easily rip colours from
just about anything you can see on your screen.
Press CTRL to make the magnifier transparent, and press ESC to cancel.


On the toolbar, there are three drop-down menus.
Going from left to right, they are Gradient Interpolation, Gradient Colourspace,
and Gradient Channels.


There are five interpolation modes: Linear, Smooth, Cubic, Catmull-Rom, and
Hermite.

Linear is basic interpolation; the colours are distributed evenly (as evenly as
possible).

Smooth is smooth interpolation; the colours smoothly transition from one
gradient point to the next. Perhaps a sine wave would be a better visualization
of this type of interpolation.

Cubic is a more advanced type of interpolation; the way colours are distributed
depend on the neighbouring points. Note that if you have only 2 gradient points
that it will look exactly like Linear.

Catmull-Rom is derieved from Cubic, and generates a smoother gradient than
Cubic.

Hermite interpolation has bias and tension controls. Bias controls where the
center of the transition is, and tension controls how smooth or sharp the
transition is.
A Hermite gradient with a bias and tension of 0% looks like a Catmull-Rom
gradient.


There are three colourspaces: RGB, HSV, and HSL.

RGB (Red / Green / Blue) is the most commonly used colourspace. However, the
gradient may not have uniform intensity. For example, a gradient from red to
blue will appear dark in the middle.

RGB has two variations that correct this problem. It can be corrected based on
value or on lightness, which will produce different results depending on the
gradient. In a gradient between red and cyan, the middle of the gradient will
be white when using value correction, and it will be gray when using lightness
correction.

HSV (Hue / Saturation / Value) and HSL (Hue / Saturation / Lightness) correct
this problem. The same gradient above will fade from red to magenta and then to
blue. HSV and HSL will produce rainbows where intensity-corrected RGB gradients
do not.
The main difference between HSV and HSL is evident when blending from a dark
colour to white. With HSL the gradient will be more saturated than with HSV.


The different channel combinations control how the colour channels are mapped to
HDMA. The colour channels will automatically be combined or dropped.
Using this allows you to reduce the size of the generated HDMA code by combining
similar colour channels.
You can also use Brightness to generate a gradient which darkens the screen.

To use brightness gradients, you need a Mode 0 gradient. GradientTool will
automatically ask you if you want to switch.
When using a Mode 2 gradient, there must be at least two separate colour
channels.
When using CGRAM/Scrolling gradients, only Red, Green, Blue can be used.


To the right is a Zoom.
Within the Zoom menu is an option to enable/disable the grid which automatically
appears when you zoom in 6x or more. It is enabled by default; turn it off if it
lags or if you find it distracting.

To the right of Zoom is Configure HDMA and Generate HDMA Code.
Configure HDMA allows you to manipulate the channel numbers to use; the default
are 3, 4, and 5. Its menu has other features, like a name to prepend to the HDMA
tables.
You can also set the number of scanlines to write.

You also can choose whether to only generate Mode 0 tables, to generate a Mode 2
table and an extra Mode 0 table if necessary, to generate a compressed scrolling
HDMA table, or to generate a table that writes to a CGRAM address, aka. a
palette gradient.


Generate HDMA Code is self-explanatory.

To the right of the previously explained buttons are Export as Bitmap Code and
Save HDMA Code. They do exactly what their names say.

When exporting bitmaps, you can export either the 15-bit (4-bit for brightness)
gradient or the 24-bit gradient. The supported formats are PNG, BMP/DIB, JPEG,
and GIF. PNG is reccomended.

Even further right is the About button. Like the last two, this is
self-explanatory.

-----
Notes
-----
I have totally re-written the HDMA generation code, so it may be buggy.

If an unhandled exception occurs, an error message will appear descriping the
exception that was thrown. When reporting a bug, try to include the message, and
what you did when the error occured. (Try to include enough information for the
error to be reproduced. This helps a lot when debugging code.)

Report these unhandled exceptions (or any other bugs, for that matter) at:
http://www.smwcentral.net/?p=viewthread&t=56603


----------
Change log
--------------------------
- v0.8.2.1, July 7, 2015 -
--------------------------
New feature:
- Gamma corrected RGB gradients, i.e. RGB gradients with uniform brightness
Changes:
- Value-corrected RGB gradients are now the default.
- The default gradient has been changed to red -> cyan to demonstrate RGB value
  correction.
- The tab pages in the HDMA configuration dialog can now be used without HDMA
  code generation.

--------------------------
- v0.8.1.7, May 22, 2012 -
--------------------------
Bugfixes:
- Fixed an old bug where if two gradient stops were placed at 100%, then the last
  scanline of the gradient would be black instead of the colour it was supposed
  to be.

-------------------------
- v0.8.1.6, May 9, 2012 -
-------------------------
Bugfixes:
- Fixed a bug where changing the units used in the colour selector and changing
  the RGB values would cause the HSL values to be displayed using the default
  degrees, percentage units.
- Fixed a bug where GradientTool would crash due to rounding errors that cause
  the HSL and/or RGB values to go beyond the maximum range; this primarily
  affected the eyedropper tool.

-------------------------
- v0.8.1.5, May 8, 2012 -
-------------------------
Bugfixes:
- Fixed the zoom bug that existed since v0.7.6.13--zooming in so the scrollbar
  appears and then zooming out will cause a gap to appear above the gradient
  editor.

-------------------------
- v0.8.1.4, May 7, 2012 -
-------------------------
Changes:
- The grid does not appear until the zoom is 6x or more.

Bugfixes:
- Fixed a bug concerning hue wrap-around in the colour selector.
- Fixed some incorrect text.

-------------------------
- v0.8.1.1, May 7, 2012 -
-------------------------
New Features:
- Hermite and Catmull-Rom gradient interpolation
- In the colour selector, you may change the range of colour values to
  0 .. 100/360, 0 .. 240 and 0 .. 255.
- A grid automatically appears when the zoom is 4x or more. This uses quite a
  bit of CPU, so you may disable it from the Zoom menu.

Bugfixes:
- Fixed an issue where the scrolling gradient generator generates rows in the
  table that span more than $80 scanlines, which doesn't seem to work with
  imamelia's scrolling gradient code.

------------------------------
- v0.8.0.1, January 14, 2012 -
------------------------------
New Features:
- Support for Transfer Mode 2
- Support for scrollable gradients
- Support for writing to CGRAM
- The title bar will contain an asterisk (*) if the gradient has been modified
  since the last time HDMA code was generated.
- If the gradient has been modified, then when saving an ASM file, you will be
  asked if you want to re-generate the HDMA code.

Changes:
- Can run on both .NET Framework 3.5 Client Profile and .NET Framework 4 Client
  Profile.
- Added info about exporting bitmaps to the code box's initial text.
- Removed the unimplemented "Ready" label from the status bar.
- When adding gradient stops, the colour dialog's title changes to "Add Gradient
  Stop".
- Double-click the track to insert a gradient stop, rather than single-clicking
  it.
- By default, HDMA initialization code will NOT be generated.
- Made a new HDMA configuration dialog.

Bugfixes:
- Fixed a potential bug where the application could crash when setting the
  scanline count too high on a computer with insufficient memory, or not enough
  continuous memory.
- There was a wierd issue where changing the zoom to anything but Fit to Window
  would cause the gradient editor to disappear off the top of the window. Fixed,
  I think?
  - Nope. Fixed in v0.8.1.5.

------------------------------
- v0.7.6.13, January 4, 2012 -
------------------------------
New Features:
- Brightness gradients can now be generated.
- Number of scanlines can be modified.
- Generate HDMA initialization code.
- Cubic interpolated gradients.
- Zooming.

Changes:
- Moved gradient name text box to HDMA Configuration menu.
- Increased the framerate of the eyedropper's magnifier to 1,000 fps.
- When re-generating HDMA tables, the caret will retain its old position, if
  possible.
- Exported bitmap is now 24 pixels wide for your viewing pleasure.

Bugfixes:
- When using the eyedropper, the magnification window will stay focused when
  using Alt+Tab.
- Fixed a bug where when adding a gradient stop, the wrong part of the control
  was redrawn.
- HDMA tables no longer incorrectly prepends '.' to top-level labels.

-------------------------------
- v0.7.0.1, December 30, 2011 -
-------------------------------
New Features:
- Export gradient as PNG.
- Names can be appended to the gradient tables.
- New colour selection dialog featuring an eyedropper tool.

Changes:
- Gradient stop colours are stored as floating-point numbers; you are no longer
  limited to 16,777,215 shades of colour.
- When adding a new gradient stop, the default colour is the colour at the point
  on the gradient that it was added to. Previously, a completely random colour
  would be selected.

Bugfix:
- When two gradient stops are at the same position, they no longer flicker when
  moving other gradient stops.

-------------------------------
- v0.6.5.9, December 14, 2011 -
-------------------------------
Change:
- Generates 224 scanlines instead of 222.

-------------------------------
- v0.6.4.8, December 13, 2011 -
-------------------------------
- Initial release.

----------------------------
Ownership / Disclaimer stuff
----------------------------
GradientTool was made by me, ExoticMatter.

Toolbar icons were made by Yusuke Kamiyamane.
(http://http://p.yusukekamiyamane.com/)

As the author, I am not liable for any damage that may be caused (Hm? What
damage? I don’t know either.), blah blah blah... You know, that disclaimer
stuff. Make sure you back up your hack. But I’m sure you already know enough to
do that, so this entire discussion is meaningless.
