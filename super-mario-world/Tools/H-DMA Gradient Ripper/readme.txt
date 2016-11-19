  HDMA Gradient Ripper v1.2.2, made by Ersanio


=====What this tool does

       This tool creates two HDMA gradient tables from an image you supply.
       The tables are destined for register $2132 (direct color) and $2121 & $2122 (CGRAM).

=====REQUIREMENTS

       DEFINITELY SOME ASM EXPERIENCE!!!
       .NET FRAMEWORK 2.0
       Paint.NET or other image editor of your choice (to create gradients)
       LevelASM or some other code which runs every frame, to run the actual HDMA

=====What does the image need to contain?

       Colors obviously. 
       Just make a gradient using your image editor (Paint.NET for example) and save it as a .PNG.
       I have included four example images with gradients in it.

=====What size does the image need to be?

       Preferably any width, and the height of 224 pixels. 224 is the Y size of the SNES screen, 
       but it can be bigger or smaller if you want to do advanced stuff like vertical-scrolling HDMA.
       The width doesn't matter. Even 1x224 works. The source image gets stretched to the right so 
       everything's clear in both the previews!

=====There are a bunch of checkboxes and stuff. How do these work?

       There's a checkbox which turns the gradient into a grayscale gradient. It uses two
       algorithms: An "Average" and a "Luminosity" algorithm. Personally, I think
       Luminosity works the best when there's green present, but I added Average just in case.

       There's a checkbox which turns all the colors negative. It should be obvious of what this does.

       There's a checkbox which can turn colors into "sepia". Keep in mind that grayscale and sepia
       do not go well together so I disabled the grayscale button if one enables sepia mode.

       There's a checkbox which can join table values together. ALWAYS use it, UNLESS you want to make
       advanced effects and you'll need single scanlines for that. Thanks edit1754 for coding this.

       There's a textbox made for output related to CGRAM registers $2121 and $2122. It's the palette color
       destination. If you thought HDMA from $2121-$2122 was for backdrop only, you were wrong.
       You can give a -single- palette color a different color for each scanline using HDMA. For example, you could
       give Yoshi's house green color a rainbow gradient.

       Personally I think the color effect algorithms aren't that great, but I tried my best.

       Finally, there's a checkbox which enables 'hex mode' display for the mouse X and Y position.

       Each time you change the settings, the image and table reloads automatically so you don't have to worry about that.
       THe only option which doesn't do this is the textbox but I've added a reload button for that.

=====How do I use the output?

       Copy the table in the textbox in the right, then paste it in one of the 2 levelASM codes.
       If you want a backdrop HDMA, copy it from $2131. If you want a gradient for a specific gradient,
       copy it from $2121 and $2122. With a little bit of ASM experience everything should work almost instantly.

=====Another feature: scanline recoloring

       In the PC RGB preview, whenever you left-click a scanline, a color picker pops up.
       If you select a color and click OK, the scanline will be recolored. The table will be updated.
       The SNES preview image will be updated too with the appropriate color effects applied.
       This could be useful for fixing weirdly colored scanlines.

       If you right click in the PC RGB preview, you will paste the current selected color over a scanline.
       Of course, the color effect filters are applied if needed.

       If you middle-click a scanline, you will select the scanline color as the current color. This is
       efficient for quick color copying.

       In the bottom-right corner of the SNES preview image there's a small square which shows the current
       color selected. You can click it and customize the color to your needs using the color picker.

       However, to do these operations effectively you need accurate mouse movements, because scanlines are
       vertically pixel-by-pixel. This is why I coded a mouse X and Y position viewer.
       I didn't have the skills to code a zoom option so please bear with it.

       NOTE: There isn't a ctrl+z function.
       NOTE 2: This feature isn't really practical, but it can be useful at times.

=====How accurate is this tool when it comes to the color conversion?

       I'd say it's 99% accurate since I haven't found any flaws, but I also don't believe in perfection.

=====Something more technical

       The tool grabs the vertical array of pixels. Which pixels? The -very- left pixels.
       The PC and SNES preview 'stretches' the grabbed pixels to the right so a more clear gradient can be seen.

=====Changelog

       Version 1.2.2

       - Fixed Compress Output's unchecked state; It would crash on images smaller than *x224,
         and it wouldn't generate the entire table for images bigger than *x224.
       - Fixed file loading; if you loaded something else than an image, the application would crash.

       Version 1.2.1

       - Fixed minor glitch when you hit cancel in a color dialog of a scanline.
         (The color would unwantedly get updated with the scanline color you selected)

       Version 1.2.0

       - Added a new feature: Scanline recoloring.
       - Added a helper for the new feature which shows mouse X and Y positions.
       - Updated readme.

       Version 1.1.3.2

       - Fixed a bug where the palette destination didn't do any changes at all.
       - Fixed a bug when a vertically bigger image is loaded, a scrollbar wouldn't appear so you could scroll down.
       - Added version number to the form's title so people can identify the version of the tool.
       - (somewhat irrelevant) used proper versioning

       Version 1.1.3.1
       - Mixed up the images of PC preview and SNES preview; fixed that.

       Version 1.1.3.0
       - Added support for CGRAM registers $2121 and $2122 so you can have gradients on a single palette color.
       - Made the PC preview stretch the first pixels in the first vertical row of the preview to the right,
         so that the PC preview is a gradient entirely too, instead of a part of the image.
       - Gave the previews pictures a fixed width.


       - Made the two textboxes uneditable.
       - The tool width got reduced by approximately 13 pixels although it isn't that big of a change.
         I thought I should mention it regardless.
       - Changed tool name to HDMA gradient ripper. This thing didn't generate gradients, but ripped them from images.

       Version 1.0.3.0
       - Initial release

=====Disclaimer

       I, ERSANIO, AM IN NO WAY AFFILIATED WITH NINTENDO ETC ETC YOU KNOW THE DRILL.
