	Cluster Spritetool
	    version 1.0
	     by Alcaro

    User manual
1. Put xkas and my version of cluster.asm in the same folder as the tool.
2. Do not add a file called tmpasm.asm in the folder of the tool.
3. Add the sprites you want to csprites.txt. Roy's Spike Hell is already included.
4. Doubleclick on the tool and it'll prompt you for the filenames; or you can give the names on the command line (rom name first, then the name of the sprite list). The extensions are obligatory.

    Spriting instructions
1. Your sprite must not use namespaces.
2. Your sprite must not contain "header", "lorom", "org".
3. Your sprite must contain a "Main:" label (case sensitive). The code will start running here.
4. All cluster sprite codes runs in the same rom bank, so please don't put any giant tables there.
5. Labels ("Graphics:"), sublabels (".loop"), and +/-labels ("++") are allowed.
6. Do not use the print command, the tool will think it's an error.