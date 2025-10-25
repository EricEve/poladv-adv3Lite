# poladv-adv3Lite
This project is for implementing a TADS3/adv3Lite (stictly speaking, adv3Liter) port of the TADS 2 polyadv port of Colossal Cave

This is very much a work in progress at an early stage. At this point it is possible to play through to a winning ending in the original 350 point game, but even this version is not yet complete and there may well be many bugs. The commands for a successful playthrough are in the file walk.cmd, but this walkthrough will work only in a game compiled for debugging (due to randomization issues).
In order to compile the code provided here you will need to obtain the latest version of adv3Lite (2.2.1.1.2 or later) from GitHub.

This repo is provided to let anyone interested see how work on this port is progressing and maybe contribute to it.

Much of the porting of Rooms and Things has been relatively straightforward, and much of the behind-the-scenes plumbing has simply been copied and pasted and then edited from TADS 2 to TADS 3 code (e.g., TADS 2 operators changed to TADS 3 c-like operators, or TADS 2 functions changed to their TADS 3 equivalents). Action-handling on Things has been adapted a bit more throughly by making use of preCond, check(), and report (none of which exists in TADS 2), replacing several loops with TADS 3 List methods, and, of course, use of the various illogical() macros in verify routines. Use of the custom floatinging class in the TADS 2 implmentation has been replaced by the use of the standard adv3Lite MultiLoc class. Extensive use has been made of TravelConnectors on room direction properties (often in junction with the new VarDest add-in class now added to adv3Lite to aid in reproducing some of the TADS 2 logic). This has largely been done even when the original TADS 2 implementation could have been followed more closely (adv3Lite, unlike adv3, allows methods to be defined on room direction properties and the latest changes to adv3Lite allow these to return a destination to be travlled just as in TADS 2).

I have largely (but not wholly consistently) changed object and class names to fit TADS 3 conventions, starting class names with a capital letter and object names with a lower case letter (with the exception of the Dwarves object, where dwarves would have clashed with a property name taken over from the TADS 2 code). I have also largely replace underscores with camel casing so that, for example, At_Witts_End becomes atWittsEnd. Many local variables and object properties, especially on the globals object, retain their TADS names, however, since changing them might prove too error-prone.

Some attempt has been made to make the adv3Lite source files correspond to the TADS 2 ones, but this has not yet been carried through consistently and there is more sorting out to be done.

If the game is compiled for debugging, you should be able to reach a winning ending by replaying the provided walk.cmd file. If you can't, some new bugs have crept in.
