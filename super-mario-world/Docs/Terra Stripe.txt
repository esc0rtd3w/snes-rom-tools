    Terra Stripe
                 Version 1.1.1
    
    Programmed by Smallhacker
    
    
----------------------------
 INTRODUCTION
----------------------------
    
    Terra Stripe is an editor for Stripe images found in Super Mario World. To put
    it simpler, at the expense of accuracy, it's a layer 3 editor.
    
    It's capable of editing any Stripe image containing layer 3 data, including the
    tileset images (fog, castle background, water, etc.) and the $12 images (title
    screen, overworld border, various menus, etc.).
    
----------------------------
 VERSION HISTORY
----------------------------

    ----------------------------
     Version 1.1.1 (2010-02-24)
    ----------------------------
        Major changes:
            * Fixed a huge bug in the save routine that made it forget to check if
              there's enough room for the RAT, thus corrupting data in rare cases.
        
        Minor/internal changes:
            * Fixed a minor bug in "Load Image at SNES Address" that allowed one
              to trick it into accepting some invalid addresses.
    
    ----------------------------
     Version 1.1.0 (2009-11-23)
    ----------------------------
        Major changes:
            * Added a compression routine to reduce image sizes.
            * Added Select/Move/Cut/Copy/Paste/Delete feature.
        
        Minor/internal changes:
            * Coordinates and tile number are now shown in the status bar.
            * Removed Clear Image, Clone and Shift as they are now obsolete.
    
    ----------------------------
     Version 1.0.0 (2009-09-27)
    ----------------------------
        Major changes:
            * .NET 2.0 compatible.
            * Added Save to ROM feature.
            * Added Change Priority feature.
            * Added Fill feature.
            * Added Undo and Redo features with a depth of 10.
            * Added Image Deleter feature.
            * Added an optional warning about overwriting status bar space.
        
        Minor/internal changes:
            * Internal palette system rewritten to support possible future features.
            * Fixed a huge bug in the PC to SNES address conversion function.
            * Added separators in menus because it looks better.
            * New menu icons.
            * File>Quit renamed to File>Exit to match most other programs.
            * Status bar added to confirm actions like loading and saving.
            * (Omitted)
    
    ----------------------------
     Version 0.5.0 (2009-06-21)
    ----------------------------
        * First release.
    
----------------------------
 WORDS TO AVOID LAWSUITS
----------------------------
    
    Terra Stripe (from now on referred to as the "Program") is in no way supported
    by Nintendo, nor by any other company.
    
    The Program is provided AS IS without any warranties of any kind and should be
    used at your own risk. Neither Smallhacker nor anyone else takes any
    responsibility whatsoever for any damages or losses directly or indirectly
    caused by the Program or the use of it, nor shall Smallhacker or anyone else
    be held liable for any such damage or loss.
    
    The Program can be freely distributed if (and only if) the following conditions
    are met:
    * The Program must be distributed together with this document, and without any
      modification whatsoever to either.
    * The Program may not be distributed along with any form of ROM image.
    * The Program may not be distributed with any commercial, financial or
      economic intents whatsoever. As such, the Program may not be traded in return
      for money, goods or services of any kind, or be distributed along with
      anything that was distributed in such a way.
    
----------------------------
 CONTACT
----------------------------
    
    Smallhacker
    Email: thesmallhacker@gmail.com