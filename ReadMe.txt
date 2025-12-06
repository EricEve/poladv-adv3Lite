README

This an attempt to port the TADS2 port of polyadv (a multi-version implementation of Colossal Cave)
to TADS 3/adv3Lite, based on the TADS 2 version by David M. Baggett, David J. Picton and J.
Standeven, which was itself based on the various versions of the classic Adventure game by Don
Woods and Willie Crowther, based on their sources. 

At the moment it is very much a work in progress.

Working on this TADS 3 port has prompted several tweaks to adv3Lite, so you will need to ensure you
have version 2.2.1.0.7 or higher (obtainable from the adv3Lite GitHub repo) to work with this port.
You might want to wait for the next stable adv3Lite release (which will probably be 2.2.2).

Strictly speaking, this a port to adv3Liter, which I take to be closer to the capabilities of TADS 2
(so that the port should not need the additional modules that the full adv3Lite module contains). It
may, however, incorporate some extensions (the collective extension is likely to prove useful for
the endgame, for example).

Even so, adv3Liter contains many features not present in TADS 2 or the TADS 2 port of polyadv. These
notably include the status line exit lister and pathfinding. Ar least for now I have chosen to
retain these in this port of ployadv rather that trying to disable features that most current
players would probably find convenient to have. 

In places the port from TADS 2 is fairly straightforward, simply translating the same code from TADS
2 to TADS 3 (mainly by replacing TADS 2 operators such as := and <> with their more C-like TADS 3
equivalents. In other places code has been more drastically rearranged to take advantage of classes
such as MultiLoc and TravelConnector that do not exist in TADS 2. Conversely, workarounds have had
to be found for code that works in TADS 2 but not TADS 3/adv3Lite, such as defining the location
property of a Thing as a method.

Some attempt has been made to follow the content and order of the TADS 2 source files, but the
correspondence is currently patchy and will need further tidying up.

The 350, 550, 551 and 580 point games have now been implemented, which means the 701 point game
should also be complete (since this effectively just combines the 550 and 551-point games). As yet, 
no start has been made on the 701p version beyond a few stub definitions in the "map2.t" file for
objects referred to but not otherwise used in the versions that have been implemented. Whether I
come back and implememnt the 701p version at a later date will depend partly on whether anyone
expresses any interest in them and partly on whether I feel like returning to the task. If anyone
else would like to take this on, do let me know.

The dwarves and pirates are yet to be implemented; these have been delegated to a collaborator.
