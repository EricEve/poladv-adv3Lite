#charset "us-ascii"

#include <tads.h>
#include "advlite.h"

/* 
 *   This file contains code corresponding to the TADS 2 advmods.t file. The sections of the TADS 2
 *   file relating to the thing and item classes have been moved to thingext.t. Not everything in
 *   the TADS 2 file has been implemented here, as much of it may prove unnecessary in
 *   TADS3/adv3Lite or else may require a different approach. 
 */

property isbonus_addmax, version_NoNPCs;

/*
 *   The "global" object is the dumping ground for any data items that
 *   don't fit very well into any other objects.  The properties of this
 *   object that are particularly important to the objects and functions
 *   are defined here; if you replace this object, but keep other parts
 *   of this file, be sure to include the properties defined here.
 */
global: object
    vNumber = 0
    
    /* Version 0 is the 350-point version, Version 1 is the 551-point version,
   Version 2 is the 550-point version, Version 7 is the 580-point version,
   Version 15 is the combined game.
   We define some properties derived from vnumber:

   newgame - 551-point game and derivatives
   oldgame - Games without 551-point extensions (350, 550-points)
   game550 - 550-point game and derivatives (e.g. 701-point game)
   game580 - 580-point game (and derivatives)
   game701 - 701-point game (combining the 550 and 551-point versions)
   game701p - 701+ point game (extended version of 701-point)
 */
    newGame = ([1, 11, 15].find(vNumber) != nil)
    oldGame = ([0, 2, 7].find(vNumber) != nil)
    game350 = (vNumber is in (0, 2, 7))//? TADS2 version uses but does not define this property.
    game550 = ([2, 7, 11, 15].find(vNumber) != nil)
    game580 = (vNumber == 7)
    game701 = ([11, 15].find(vNumber) != nil)
    game701p = (vNumber == 11)
    game660 = nil
    
    listenAdd = nil
    vendingTreasures = 0
    nondeterministic = true
    randomized = nil
    specialstart = nil

    NPCstarted = nil    // have we initialized the pirates and dwarves?
    NPCrooms = []       // list of rooms NPCs can travel to (otherwise cannot)
    pirateCount = 1         // how many pirates do we put in.  original had 1
    dwarveCount = 5         // how many dwarves do we put in.  original had 5
	//
	// Where to start dwarves and pirate(s) out.  Dwarves are placed
	// in the locations given by drawfloc; if no locations remain when
	// we're placing a dwarf, we just put him in a random room selected
	// from NPCrooms.
	//
	// Note that the player gets the axe from the dwarf, so it's
	// fairly important to put at least dwarf early on (but only
	// in a room that's not off limits to NPC's!)
	//
	// Ditto for pirate(s).
	//
	dwarfloc = [ inHallOfMists ]
	pirateloc = []
    

    dspotfromadj = 10    // percentage chance that a dwarf will
                         // spot the player from an adjacent location
                         // and enter the player's room, instead of
                         // taking a random exit.

    dtenacity = 96       // percentage chance that a dwarf will
                         // follow the player once he's entered the
                         // player's room.  (Was 100 in original.  It might
                         // be desirable to change it to 100 in the
                         // 430-point game.)
    
	pspotfromadj = 50		// percentage chance that a pirate will
				// follow the player if in an adjacent
				// location.  Don't set this too high or
				// the game will get really bogus!

	dwarfattack = 75	// percentage chance that a dwarf will
				// throw a knife at the player if he's
				// in the same location.  (Was 100 in
				// the original.)
	dwarfhit = 66		// percentage chance the player will
				// hit a dwarf with his axe
				// (Was 1 in 3 chance in the original.)
	dwarfaccuracy = 7	// percentage chance that a dwarf will
				// hit the player with a thrown knife
				// (Was 9.5 in the original.)
    luckyhit = 90       // percentage chance the player will hit
                        // a dwarf when he carries a lucky 4-leafed
                        // clover.

    treasures = 0
    origTreasures = 0
    closure = nil
    closurePoints = 0
    closurePointsAwarded = nil
    closingPoints = 0
    treasurelist = []
    extraTreasuresFound = nil
    fullyClosed = true
    endpoints = 0
    maxscore = 0
    maxhiked = 0
    lamplist = []
    
    debug = nil
    
    travelActor = nil
    
    extendMoveInto = true
    nodwarves = nil     // when true, disables dwarves and pirates
    
    /* Maximum version number */
    vmax = 15
    
    /* List of valid gamevvv properties for vnumber=0,1,2 etc */
    gameflaglist = [&game350, &game551, &game550,
    &dum, &dum, &dum, &dum, &game580,
    &dum, &dum, &dum, &game701p, 
    &dum, &dum, &dum, &game701]

    /* List of version-specific location properties */
    locproplist = [&location350, &location551, &location550,
    &dum, &dum, &dum, &dum, &location580, 
    &dum, &dum, &dum, &location701p, 
    &dum, &dum, &dum, &location701]

    /* List of version-specific loclist properties */
    loclproplist = [&loclist350, &loclist551, &loclist550,
    &dum, &dum, &dum, &dum, &loclist580, 
    &dum, &dum, &dum, &loclist701p, 
    &dum, &dum, &dum, &loclist701]
    
    //
    // Other stuff
    //
    deaths = 0          // number of times the player has died
    closingtime = 30    // close this many turns after player takes
                        // the last treasure.  (was 30 in original)
    bonustime = 30      // start endgame this many turns after
                        // the cave closes.  In the original this
                        // was 50.  In CCR it was decreased to
                        // 20, because the timer started when the
                        // last treasure was deposited in the building.
                        // In the present implementation we start
                        // the timer once the last treasure has
                        // been taken, so bonustime has been bumped
                        // back up a little.
    panictime = 15      // set timer to this many turns when player
                        // panics at closing time

    closed = nil        // is the cave closed yet?
    
    // message when trying to enter or exit the cave at closing time.
    closingmess
    {
        local actor = gActor ?? gPlayerChar;
        "A mysterious recorded voice groans into life
        and announces, \"This ";
        if(actor.getOutermostRoom.isoutside) "entrance"; else "exit";
        " is closed.  ";

        if(global.game550) "Please report to the treasure room
        via the alternate entrance to claim your
        treasure.\"";
        else "Please leave via main office.\"";
    }
    
    saidThrow
    {
        return (gVerbWord == 'throw');
    }
    
    knowsgreenname = nil
    // game version selection
    removelist = []     // list of objects to be removed
    movelist = []       // list of objects to be moved to different
                // locations
    changeloc = []      // list of modified locations
    moveloclist = []    // floatingdecoration objects to be given
                        // a different loclist
    changeloclist = []  // list of modified loclists
    restoreList = [] // list of items to be restores to their initial location

//    noall = [Hands Heels Air Footsteps Walls Ceiling theFloor TheRoom
//         LeftCrack RightCrack MiddleCrack Chapter1 Chapter2 Chapter3 Chapter4
//         Foreboding available_keys CircularRoomLighting]
                        // objects which will be ignored by ALL. These 
                        // include objects which are always present (Hands),
                        // objects which form part of another object,
                        // and dummy objects which exist only to print messages
                        // in room descriptions.
    checklist = []      // treasures etc. whose locations should be
                        // checked.
    
    allpointlist = []

//    travelActor = gPlayerChar    // actor doing the travelling, for use by travel
//                        // methods.

    verbActor = nil     // actor executing the current verb.  This is set
                        // early in the parsing process, but is unset once
                        // the execution of the verb has finished.  

    currentActor = nil  // the current actor for the purpose of evaluating
                        // the location properties of multi-location objects

    extras = 0          // extra points for the extended 701-point game.

    wrongtreasloc = 0   // Number of incorrectly-deposited treasures (excluding
                        // discharged pendants held by the player).  Computed
                        // in the Cylindrical Room endgame only.

    trolltolls = 0      // Number of treasures paid to the troll and still in
                        // his treasure room.  Computed in the Cylindrical
                        // Room endgame only.
    
    vendingtreasures = 0 // Number of treasures used to buy batteries.
    
    dont_rescind = nil
    novicepoints = 0
    quitpoints = 0
    deathpoints = 0
    farinpoints = 0
    extenpoints = 0
    closurepoints = 0
    endkillpoints = 0
    klutzpoints = 0
    almostpoints = 0
    winpoints = 0
    escapepoints = 0
    finalepoints = 0
    treasuresToFind = 0
    bonusorig = 0
    closingorig = 0   
    endgameclock = 0
    phonetime = 0
    phonewake = 0
    noAskWave = nil
    novicemode = nil
    
    triggered_alert = nil
    
    fully_closed = nil
    
    startscore = 0
    
    view_artifact = nil
    onlyviewing = nil
    
    numactwords = 0
    numactwords580 = 0
    numactwords701 = 0
    numactwords701p = 0
    
    mazeskip = nil // have we enable the mazeskip comamand?

#if 0
    gendaemon() {
        local i,t,l,cl,c,tloc,cloc,cloc2,ccond;
        local addlist = [];
        local Medisqual;
        atY2.hollowVoice;    // plugh message
        if(global.game550)     fakeY2.hollowVoice;  // ditto
        if(global.newGame)     knoll.elfcurse;       // phuce message

        // do the expensive score checking only when the global.checklist
        // has at least one item.   This happens automatically whenever
        // a non-empty container or scoring object is moved, or
        // a container for liquids is moved, filled or emptied.

        if (self.checklist.length() == 0) goto set_score;

        // 'Takepoints' are applied when an object is first taken into
        // the player's possession, and 'depositpoints' are applied when
        // an object has been deposited in location 'targloc'.  Note
        // that 'takepoints' is never rescinded but 'depositpoints' is
        // deducted if an object is no longer correctly deposited.  (If an
        // object has dynamically-created copies, only one set of 
        // 'depositpoints' is awarded.  The points will be deducted only if
        // all objects are removed from their correct position)
        // If 'targloc' is a container rather than a room, 'contloc'
        // can define the location of the container.   If 'contloc'
        // is also a container, the 'outercontloc' property may be set
        // to define the location of this outer container.  Note that
        // these properties are normally ignored in a 350- or 550-point game,
        // unless the 'oldkeep' property is defined for the object.
        // Remember to set 'oldkeep' for non-treasure objects like the
        // magazines.
        //
        // 'undiscovered' is a special property for an object (the book
        // in the safe) which is in the right place to start with, but must
        // be discovered before points are awarded.  When the discovery takes
        // place, undiscovered should be set to nil and the item added to
        // global.checklist.
        //
        // 'objclass', if defined, is the class of a dynamically
        // created object.  The deposit score will be awarded if at least
        // one of the objects in class 'objclass' (or the parent object)
        // is in the desired location.
        //
        // This method requires the isInside function in ccr-thx.t (same
        // as isIn but without regard to visibility.)
        //
        // First loop: check for objects which are no longer in their
        // target locations (omitted at the end of the cylindrical room puzzle)

        self.checkpointlist = checklist.intersect(allpointlist);
        l = self.checkpointlist.length();
        if(!global.dont_rescind) {
            for (i = 0; ++i <= l; ) {
                t = self.checkpointlist[i];
                // for cloned objects, set cl to the class; otherwise set
                // cl to the object itself.
                if(t.objclass) {
                    cl = t.objclass; 
                    // add any equivalent objects to be checked in the
                    // second loop
                    addlist += cl.list + cl - t;
                }
                else {
                    // add any equivalent objects to be checked in the
                    // second loop
                    cl = t;
                    addlist += t.list;
                } 
                if(global.newGame || t.oldkeep) {
                    tloc = t.targloc; // required location
                    c = tloc;     // required container
                    cloc = t.contloc; // required location of container
                    cloc2 = t.outercontloc; // reqd. loc. of outer container
                }
                else {
                    tloc = insideBuilding;
                    c = tloc;
                    cloc = nil;
                    cloc2 = nil;
                }
                // Medisqual indicates that the object is disqualified
                // from the deposit score because the player has it.  We have
                // to make an exception if the target location actually is
                // the player!
                if (tloc == gPlayerChar || cloc == gPlayerChar || cloc2 == gPlayerChar)
                    Medisqual = nil;
                else
                    Medisqual = t.isIn(gPlayerChar);

                if (cl.awardedpointsfordepositing) {
                    if(cloc == nil) ccond = true;
                    else ccond = (c.isIn(cloc));
                    if(cloc2 != nil)
                        if (!cloc.isIn(cloc2)) ccond = nil;
                    if (Medisqual || !t.isIn(tloc) || !ccond) {
                        self.scoreinc = self.scoreinc - t.depositpoints;
                        cl.awardedpointsfordepositing = nil;
                    }
                }
            }
        }
        // Second loop: check for objects which have been taken, or
        // correctly deposited.
        self.checkpointlist += addlist;
        l = self.checkpointlist.length();
        for (i = 0; ++i <= l;) {
            t = self.checkpointlist[i];
            // for cloned objects, set cl to the class; otherwise set
            // cl to the object itself.
            if(t.objclass) cl = t.objclass; else cl = t;
            if(global.newGame || t.oldkeep) {
                tloc = t.targloc; // required location
                c = tloc;     // required container
                cloc = t.contloc; // required location of container
                cloc2 = t.outercontloc; // reqd. loc. of outer container
            }
            else {
                tloc = insideBuilding;
                c = tloc;
                cloc = nil;
                cloc2 = nil;
            }
            // Medisqual indicates that the object is disqualified
            // from the deposit score because the player has it.  We have
            // to make an exception if the target location actually is
            // the player!
            if (tloc == gPlayerChar || cloc == gPlayerChar || cloc2 == gPlayerChar)
                Medisqual = nil;
            else
                Medisqual = t.isIn(gPlayerChar);

            if (!cl.awardedpointsfordepositing && !t.undiscovered) {
                // Check for 'taking' points if object is being
                // carried.
                if (t.isIn(gPlayerChar) && !cl.awardedpointsfortaking) {
                    self.scoreinc = self.scoreinc + t.takepoints;
                    cl.awardedpointsfortaking = true;
                    // self.treasures now counts the items remaining
                    // to be taken (truer to the original Fortran
                    // versions).
                    if(t.ofKind(Treasure)) {
                        self.treasures = self.treasures - 1;
                        global.treasuresToFind -= t;
                    }
                }
                // Check for deposited object.
                if (t.isIn(tloc) && !Medisqual && !cl.awardedpointsfordepositing) {
                    // if contloc is nil, ignore location of container ...
                    if(cloc == nil) ccond = true;
                    // otherwise check location of the container
                    else ccond = (c.isIn(cloc));
                    // condition for second-level container
                    if(cloc2 != nil)
                        if (!cloc.isIn(cloc2)) ccond = nil;
                    if(ccond) {
                        // check that 'taking' points have been
                        // awarded (needed for book)
                        if (!cl.awardedpointsfortaking) {
                            self.scoreinc = self.scoreinc + t.takepoints;
                            cl.awardedpointsfortaking = true;
                            if(t.ofKind(Treasure)) {
                                self.treasures = self.treasures - 1;
                                global.treasuresToFind -= t;
                            }
                        }
                        // award points for depositing ...
                        self.scoreinc = self.scoreinc + t.depositpoints;
                        cl.awardedpointsfordepositing = true;
                    }
                }
            }
        }
        // adjust the score
        set_score: if(self.scoreinc != 0) silentIncscore(self.scoreinc);
        self.scoreinc = 0;
        self.checklist = [];
        // check for discovery of a bonus treasure
        if (global.maxhiked) {
             "\n Hmmm... You seem to have found an extra item I 
             didn't know about, so I've increased the maximum score
             to <<global.maxscore>> points!\n";
             global.maxhiked = nil;
        }
        // check for closing (now done after object scores have been
        // checked.)
        checkForClosing();
    }
#endif
;

  

/* Customize various library messages to match those used in the TADS 2 implementation. */
CustomMessages
    messages =
    [
        Msg(nothing special, ['{He dobj} look{s/ed} like {1} {name dobj} to me. ', 
            {: gDobj.ordinary}]),
        Msg(onset of darkness, '\nIt is now pitch black.  If you proceed you
            will likely fall into a pit. '),
        Msg(show score rank, '{1} '),        
        Msg(showHintWarning, '<.notification>Warning: Some people
                 don&rsquo;t like built-in hints, since the temptation to ask
                 for help prematurely can become overwhelming when hints are so
                 close at hand.  Moreover, in this game you\'ll lose one point
            from your score for every hint you view. If you&rsquo;re worried that your willpower
                 won&rsquo;t hold up, you can disable hints for the rest of this
                 session by typing <<aHref('hints off', 'HINTS OFF')
       >>.  If you still want to see the hints now, type
            <<aHref('hint', 'HINT')>>.<./notification> ')
    ]
;

class QContainer: Container
    contentsListed = nil
;


class Chair: Platform
    canLieOnMe = nil
    sitOnScore = 120
;

/* Preinit setup of data structures needed in the game. */
gamePreinit: PreinitObject
    execute()
    {
        local i,j,o, vnumsav,gameprop,locprop,loclprop, condit;
        
        global.lamplist = [];
        o = firstObj(LightSource);
        while (o != nil) {
            global.lamplist = global.lamplist + o;
            o = nextObj(o, LightSource);
        }
        o = firstObj(Flashlight);
        while (o != nil) {
            global.lamplist = global.lamplist + o;
            o = nextObj(o, Flashlight);
        }
        

        
        global.numactwords = 0;
        for(o = firstObj(MagicWord); o; o = nextObj(o, MagicWord)) {
            if(o.omegapsical_order) 
                if(o.omegapsical_order > 0) global.numactwords++;
        }
        global.numactwords580 = 0;
        for(o =firstObj(MagicWord); o; o = nextObj(o, MagicWord)) {
            if(o.omegaps580_order) 
                if(o.omegaps580_order > 0)global.numactwords580++;
        }
        global.numactwords701 = 0;
        for(o = firstObj(MagicWord); o; o = nextObj(o, MagicWord)) {
            if(o.omegaps701_order) 
                if(o.omegaps701_order > 0)global.numactwords701++;
        }
        global.numactwords701p = 0;
        for(o = firstObj(MagicWord); o; o = nextObj(o, MagicWord)) {
            if(o.omegaps701p_order) 
                if(o.omegaps701p_order > 0) global.numactwords701p++;
    }
        
        
        
        /* 
         *   Set an 'allversions' property on all rooms/objects for which no gamevvv properties are
         *   true
         */
        for (i = firstObj(Thing); i; i = nextObj(i, Thing)) 
        {
            i.allversions = true;
            for (j = 0; j <= global.vmax; j++) 
            {
                gameprop = global.gameflaglist[j+1];
                if(i.(gameprop) == true) 
                    i.allversions = nil;
            }
        }
        
        
        /* Loop over all defined versions */
        vnumsav = global.vnumber;
        
        for (i = firstObj(VerGlob); i; i = nextObj(i, VerGlob)) 
        {   
            
            /* Number of coin sets */
            i.coinsets = 0;
            /* 
             *   Temporarily set global.vnumber to the appropriate value so we see the correct
             *   values of object scores
             */
            global.vnumber = i.vnumber;
            
            // Count treasures in each version to get initial number
            // of treasures left to find.
            //
            i.treasures = 0;
            /* version-specific property */
            
            gameprop = global.gameflaglist[i.vnumber + 1];
            locprop = global.locproplist[i.vnumber + 1];
            loclprop = global.loclproplist[i.vnumber + 1];
            
            /* count the treasures */
            o = firstObj(Treasure);
            
            while(o != nil)
            {
                condit = (o.allversions || o.(gameprop));
                if(condit)
                {
                    if(!o.bonusTreasure)
                    {
                        i.treasurelist = i.treasurelist + o;
                        i.treasures ++;
                    }
                    else
                         i.bonustreasures += o;
                    
                }
                o = nextObj(o, Treasure);
            }
            
            /* 
             *   count coins (whether valuable or not) and all non-treasure objects which score
             *   points
             */
            o = firstObj(Thing);
            while (o != nil) {
                condit = (o.allversions || o.(gameprop));
                if(condit) {
                    if(o.ofKind(Coin)) i.coinsets++;
                }
                if( ((o.takepoints != nil) || (o.depositpoints != nil))
                   && (!o.ofKind(Treasure)) && condit) {
                    if(!o.bonustreasure) {
                        i.pointobjlist = i.pointobjlist + o;
                        i.pointobjs = i.pointobjs + 1;
                    }
                    else
                        i.bonuspointobjs += o;
                }
                o = nextObj(o, Thing);
            }
            
            
            // List of treasures still to find (for debugging)
            i.treasuresToFind = i.treasurelist;
            i.allpointlist = i.treasurelist + i.pointobjlist;
            i.allpoints = i.treasures + i.pointobjs;
            // save the number of treasures (which is reduced by one each
            // time a treasure is taken)
            i.origtreasures = i.treasures;           
            
        
        
            /* list objects to be removed from each game version. */
            i.removelist = [];
            
            o = firstObj(Thing);
            while (o != nil) 
            {
                condit = (o.allversions || o.(gameprop));
                if(!condit) 
                {
                    i.removelist += o;                      
                }
//                else if(o.(gameprop))
//                    i.restoreList += o;
                
                o = nextObj(o, Thing);
            };
            
        /* list objects with different locations in each version. */
        i.movelist = [];
        o = firstObj(Thing);
        while (o != nil) 
        {
            condit = o.propDefined(locprop) && (o.(locprop) != o.location);
            if(condit) 
            {
                i.movelist += o;
                i.changeloc += o.(locprop);
            }
            o = nextObj(o,Thing);
        }
        
        /* 
         *   list floatingdecoration objects with a version-dependent loclist - adapted for MultiLoc
         */
        o = firstObj(MultiLoc);
            while (o != nil) 
            {
                condit = ((o.(loclprop) != nil) && (o.(loclprop) != o.locationList));
                if(condit) 
                {
                    i.moveloclist += o;
                    // Note the syntax to add a list as a single element.
                    i.changeloclist += [o.(loclprop)];
                    // Flag to indicate that the initial loclist is
                    // version-dependent (contents lists will be filled in
                    // at the init stage)
                    o.versionloc = true;
                }
                // objects which exist only in some versions are also
                // version-dependent
                if (!o.allversions) 
                    o.versionloc = true;
                o = nextObj(o, MultiLoc);
            }
        }
        
        /* Reset global.vnumber to its default value */
        global.vnumber = vnumsav;
        
        // initialize the NPC rooms
        initNPC();
       
    }
;

/* 
 *   Setup the dats (objects, rooms, connections, scoring, etc.) related to the current version of
 *   the game.
 */
versionSetup: InitObject
    execute()
    {
        /* 
         *   If we want a special restart, e.g. for sitting on the throne, do that first          
         */
        if(specialRestart.isActive)
        {
            specialRestart.execute();
        }
        
        local o, copied, l, i, p;
        // adjust global variables for the game version (and do any
        // extra setup needed.)
        global.vNumber = versionNum.vNumber;
        
        for (o = firstObj(VerGlob); o; o = nextObj(o, VerGlob)) 
        {
            if(global.vNumber == o.vnumber) 
            {
                o.copy;
                copied = true;
                break;
            }
        }
        
        if(!copied)
        {
            "Internal error -- no verglob object found for version
            number <<global.vnumber>>. Reverting to 350-point version. ";
            global.vnumber = 0;
            glob0.copy;
            copied = true;
        }
        
        // save initial score for later use
        global.startscore = libScore.totalScore;        
    
    
    
    // move player -> 1st location
    {
        if(!gPlayerChar.isIn(atEndOfRoad))
            gPlayerChar.moveInto(atEndOfRoad);
        
    }
    
    /* 
     *   The introductory text that comes here in the TADS 2 version should be implemented
     *   elsewhere, perhaps as part of an ABOUT or HELP commmand.
     */
    
    // Remove any objects and rooms which belong only to
    // this version of the game, and move any which have different
    // locations.
    //
    // Only objects with simple locations, and floatingdecoration objects,
    // are moved into nil.  In other cases the location method may
    // need to be hand-coded to ensure that the object can only be seen
    // in the appropriate game versions.
        
        
        
        l = global.removelist.length;
        for (i = 1; i <= l; i++) 
        {
            o = global.removelist[i];
            p = o.propType(&location);
            if(p == TypeObject) 
            {
                // "\nmoving ";o.sdesc;" into nil\n";
                o.moveInto(nil);
            }
            
            /* The following line makes no sense in adv3Lite, which uses the MultiLoc class. */
            //        if(isclass(o,floatingdecoration)) o.loclist := [];
            
            /* The adv3Lite equivalent may be the following, but that needs further investigation: */
            //        if(o.ofKind(MultiLoc))
            //            o.moveInto(nil);
            
            // Objects and rooms which are not in this version are all flagged
            // as deleted, and game routines can check for this (including
            // the place and move routines for NPC's, which are never moved into
            // deleted rooms.)
            
            //"\nflagging room as deleted: ";o.sdesc;"\n";
            o.deleted = true;
        }
       
        
        // Objects in the movelist are assumed to have simple locations.
        l = global.movelist.length;
        for (i = 1; i <= l; i++) 
        {
            o = global.movelist[i];
            // "\nmoving ";o.sdesc;" into ";global.changeloc[i].sdesc;"\n";
            o.moveInto(global.changeloc[i]);
            //no longer needed in init, due to global.extend_moveInto flag
            /* o.moved := nil; */
        }
        // Objects in the moveloclist have a version-dependent loclist.
        l = global.moveloclist.length;
        
        /* This needs rethinking for MultiLocs: */
        for (i = 1; i <= l; i++) 
        {
            o = global.moveloclist[i];
            //            // "\nchanging loclist for ";o.sdesc;"\n";
            //            o.loclist =(global.changeloclist[i]);
            o.moveInto(changeloclist[i]); // this may be the correct equivalent
        }
        
        if(global.oldGame)         
            brassLantern.fuelLevel = 350;        
        else 
            brassLantern.fuelLevel = 650;
        
     // Handle a special restart
        if(global.specialstart) 
        {
            // special restart
            
            gPlayerChar.moveInto(inHallOfMists);             
            silentIncscore(global.farinpoints, 'getting well into the caves');
            if (global.novicemode) silentIncscore(global.novicepoints, 'using novice mode');
            if (global.nodwarves) silentIncscore(-5, 'turning off the dwarves');
            gPlayerChar.awardedpointsforgettingfarin = true;
            /* Give me the lamp and turn it on */
            brassLantern.moveInto(gPlayerChar);
            
            /* Note that this also starts the fuel daemon */
            brassLantern.makeLit(true);

            /* move certain objects into the rainbow room */
            littleBird.moveInto(rainbowRoom);
            
            blackRod.moveInto(rainbowRoom);
            
            slippers.moveInto(rainbowRoom);
            
        }   
        
    }
;

/* Housekeeping routines needing to be run each turh. */
turnProcessing: InitObject
    /* Setup the daemon */
    execute()
    {
        new Daemon(self, &processTurn, 1);
        
        /* 
         *   Give the player a few turns grace to use the NORANDOM command. The TADS 2
         *   implementation only allowa this to be used on the first turn, but it seems reasonable
         *   to allow a little longer.
         */
        new Fuse(self, &makeRandom, 5);
    }
    
    
    makeRandom()
    {
        /* 
         *   We don't want to disturb the randomization at all in DEBUG modes, since doing so breaks
         *   the walkthrough.
         */
#ifndef __DEBUG
        if(global.nondeterministic)
        {
            global.randomized = true;
            randomize();
        }
        else
            /* Ensure we get the same sequence of pseudo-random numbers every time. */
            randomize(RNG_ISAAC, 4);
#endif
    }
    
    /* Run the game-specific turn ending handling. */
    processTurn()
    {   
        gPlayerChar.healthdaemon();
        updateScore();
        checkForClosing();
        checkForEndGame(true);
    }
    
    /* 
     *   Update the score according to whether various scored itema have been taken and/or correctly
     *   deposited.
     */
    updateScore()    
    {
        local i,t,l,cl,c,tloc,cloc,cloc2,ccond, scoredesc = '';
        local addlist = [];
        local Medisqual;
        
        if(global.checklist == [])
            goto set_score;
        
        
        checkpointlist = global.checklist.intersect(global.allpointlist);
        l = checkpointlist.length;
        if(!global.dont_rescind) 
        {
            for(i = 1; i <= l ; i++)
            {
                t = checkpointlist[i];
                // for cloned objects, set cl to the class; otherwise set
                // cl to the object itself.
                if(t.objclass) 
                {
                    cl = t.objclass; 
                    // add any equivalent objects to be checked in the
                    // second loop
                    addlist += cl.list + cl - t;
                }
                else {
                    // add any equivalent objects to be checked in the
                    // second loop
                    cl = t;
                    addlist = t.list;
                }
                
                if(global.newGame || t.oldkeep) 
                {
                    tloc = t.targloc; // required location
                    c = tloc;     // required container
                    cloc = t.contloc; // required location of container
                    cloc2 = t.outercontloc; // reqd. loc. of outer container
                }
                else 
                {
                    tloc = insideBuilding;
                    c = tloc;
                    cloc = nil;
                    cloc2 = nil;
                }
                
                // Medisqual indicates that the object is disqualified
                // from the deposit score because the player has it.  We have
                // to make an exception if the target location actually is
                // the player!
                if (tloc == gPlayerChar || cloc == gPlayerChar || cloc2 == gPlayerChar)
                    Medisqual = nil;
                else
                    Medisqual = t.isIn(gPlayerChar);
                
                if (cl.awardedpointsfordepositing) 
                {
                    if(cloc == nil)
                        ccond = true;
                    else 
                        ccond = (c.isIn(cloc));
                    if(cloc2 != nil)
                    {
                        if (!cloc.isIn(cloc2))
                            ccond = nil;
                    }
                    if (Medisqual || t.isIn(tloc) || !ccond) 
                    {
                        scoreinc = scoreinc - t.depositpoints;
                        cl.awardedpointsfordepositing = nil;
                    }
                }
            }
        }
        // Second loop: check for objects which have been taken, or
        // correctly deposited.
        checkpointlist += addlist;
        l = checkpointlist.length;
        
        for (i = 1; i <= l; i++) 
        {
            t = self.checkpointlist[i];
            // for cloned objects, set cl to the class; otherwise set
            // cl to the object itself.
            
            // for cloned objects, set cl to the class; otherwise set
            // cl to the object itself.
            if(t.objclass) 
                cl = t.objclass; 
            else 
                cl = t;
            
            if(global.newGame || t.oldkeep) 
            {
                tloc = t.targloc; // required location
                c = tloc;     // required container
                cloc = t.contloc; // required location of container
                cloc2 = t.outercontloc; // reqd. loc. of outer container
            }
            else 
            {
                tloc = insideBuilding;
                c = tloc;
                cloc = nil;
                cloc2 = nil;
            }
            
            // Medisqual indicates that the object is disqualified
            // from the deposit score because the player has it.  We have
            // to make an exception if the target location actually is
            // the player!
            if (tloc == gPlayerChar || cloc == gPlayerChar || cloc2 == gPlayerChar)
                Medisqual = nil;
            else
                Medisqual = t.isIn(gPlayerChar);
            
            if (!cl.awardedpointsfordepositing && !t.undiscovered) 
            {
                // Check for 'taking' points if object is being
                // carried.
                if (t.isIn(gPlayerChar) && !cl.awardedpointsfortaking)  
                {
                    scoreinc = scoreinc + t.takepoints;
                    scoredesc = 'collecting treausres';
                    cl.awardedpointsfortaking = true;
                    // self.treasures now counts the items remaining
                    // to be taken (truer to the original Fortran
                    // versions).
                    if(t.ofKind(Treasure)) 
                    {
                        global.treasures = global.treasures - 1;
                        global.treasuresToFind -= t;
                    }
                }
                // Check for deposited object.
                if (t.isIn(tloc) && !Medisqual && !cl.awardedpointsfordepositing) 
                {
                    // if contloc is nil, ignore location of container ...
                    if(cloc == nil)
                        ccond = true;
                    // otherwise check location of the container
                    else 
                        ccond = (c.isOrIsIn(cloc));
                    // condition for second-level container
                    if(cloc2 != nil)
                    {
                        if (!cloc.isIn(cloc2))
                            ccond = nil;
                    }
                    if(ccond) 
                    {
                        // check that 'taking' points have been
                        // awarded (needed for book)
                        if (!cl.awardedpointsfortaking) 
                        {
                            scoreinc = scoreinc + t.takepoints;
                            scoredesc = 'collecting treasures';
                            cl.awardedpointsfortaking = true;
                            if(t.ofKind(Treasure)) 
                            {
                                global.treasures -= 1;
                                global.treasuresToFind -= t;
                            }
                        }
                        // award points for depositing ...
                        scoreinc = scoreinc + t.depositpoints;
                        scoredesc = 'depositing treasures';
                        cl.awardedpointsfordepositing = true;
                    }
                }
            }
            
            
            if (!cl.awardedpointsfordepositing && !t.undiscovered) 
            {
                // Check for 'taking' points if object is being
                // carried.
                if (t.isIn(gPlayerChar) && !cl.awardedpointsfortaking) 
                {
                    scoreinc = self.scoreinc + t.takepoints;
                    scoredesc = 'collecting treasures';
                    cl.awardedpointsfortaking = true;
                    // self.treasures now counts the items remaining
                    // to be taken (truer to the original Fortran
                    // versions).
                    if(t.ofKind(Treasure)) 
                    {
                        treasures = treasures - 1;
                        global.treasuresToFind -= t;
                    }
                }
                // Check for deposited object.
                if (t.isIn(tloc) && !Medisqual && !cl.awardedpointsfordepositing) 
                {
                    // if contloc is nil, ignore location of container ...
                    if(cloc == nil)
                        ccond = true;
                    // otherwise check location of the container
                    else
                        ccond = (c.isIn(cloc));
                    // condition for second-level container
                    if(cloc2 != nil)
                    {
                        if (!cloc.isIn(cloc2))
                            ccond = nil;
                    }
                    if(ccond) 
                    {
                        // check that 'taking' points have been
                        // awarded (needed for book)
                        if (!cl.awardedpointsfortaking) 
                        {
                            scoreinc = scoreinc + t.takepoints;
                            scoredesc = 'collecting treasures';
                            cl.awardedpointsfortaking = true;
                            if(t.ofKind(Treasure))
                            {
                                treasures = treasures - 1;
                                global.treasuresToFind -= t;
                            }
                        }
                        // award points for depositing ...
                        scoreinc = scoreinc + t.depositpoints;
                        cl.awardedpointsfordepositing = true;
                        scoredesc = 'depositing treasures';
                    }
                }
            }
        }
        
        
    
        
    set_score: 
        if(scoreinc != 0)
            addToScore(scoreinc, scoredesc);
        
        scoreinc = 0;
        checklist = [];
        
                   
    }
    
    checkpointlist = [] 
    allpointlist = []
    checklist = []
    
    scoreinc = 0
;

/* The VerbGlob class defines various values needed by different versions of the game. */
class VerGlob: object
    // quantities to be filled in by preinit()
    score = 0
    treasures = 0           // treasures left to deposit;
                            // filled in by preinit
    origtreasures = 0       // original number of treasures; set by
                            // preinit
    treasurelist = []       // list of all treasures in the game;
                            // filled in by preinit
    bonustreasures = []     // list of all bonus treasure objects (e.g.
                            // pendants in 701+ point game)
    pointobjs = 0           // number of objects which score points
                            //
    pointobjlist = []       // objects which score points
    bonuspointobjs = []     // list of bonus non-treasure objects.

    allpoints = 0           // combined list of point-scoring
                            // objects
    allpointlist = []


    // game version selection
    removelist = []         // list of objects to be removed
    restoreList = []        // list of objects to be restored
             
    movelist = []           // list of objects to be moved to different
                            // locations
    changeloc = []          // list of modified locations
    moveloclist = []        // floatingDecoration objects to be given
                            // a different loclist
    changeloclist = []      // list of modified loclists

    sacklist = []           // containers for automatic inventory
                            // management
    dwarves = 0
    coinsets = 0
    treasuresToFind = []
    scoreRankTable = nil // the score rank table to be copied to gameMain
    closurePoints = 0
    
    

    // copy verglobal settings to global.  This method can be overridden
    // if extra copying or setup is to be done.
    copy {
        global.maxresurrect  = self.maxresurrect;
        silentIncscore(score, 'starting out');        
//        libScore.totalScore  = self.score;
        global.maxscore      = self.maxscore;
        gameMain.maxScore = maxscore; // Added for adv3Lite sooring system
        global.novicepoints  = self.novicepoints;
        global.quitpoints    = self.quitpoints;
        global.deathpoints   = self.deathpoints;
        global.farinpoints   = self.farinpoints;
        global.extenpoints   = self.extenpoints;
        global.closurePoints = self.closurePoints;
        global.closingpoints = self.closingpoints;
        global.endpoints     = self.endpoints;
        global.endkillpoints = self.endkillpoints;
        global.klutzpoints   = self.klutzpoints;
        global.almostpoints  = self.almostpoints;
        global.winpoints     = self.winpoints;
        global.escapepoints  = self.escapepoints;
        global.finalepoints  = self.finalepoints;
        global.treasures     = self.treasures;
        global.origtreasures = self.origtreasures;
        global.treasurelist  = self.treasurelist;
        global.pointobjs     = self.pointobjs;
        global.pointobjlist  = self.pointobjlist;
        global.allpoints     = self.allpoints;
        global.allpointlist  = self.allpointlist;
        global.dwarves       = self.dwarves;
        global.removelist    = self.removelist;
        global.movelist      = self.movelist;
        global.changeloc     = self.changeloc;
        global.moveloclist   = self.moveloclist;
        global.changeloclist = self.changeloclist;
        global.sacklist      = self.sacklist;
        global.treasuresToFind = self.treasuresToFind;
        global.bonustreasures = self.bonustreasures;
        global.bonuspointobjs = self.bonuspointobjs;
        FreshBatteries.available = self.coinsets;
        // save the bonus time.
        global.bonusorig     = global.bonustime;
        global.closingorig   = global.closingtime;
        gameMain.scoreRanks  = self.scoreRanks;
        global.restoreList = self.restoreList;
    }
;

/*   The glob0 object holds lists and values which are copied over to
     the global object when a 350-point game is selected.  */
    
glob0: VerGlob
    vnumber = 0

    maxresurrect = 2        // number of resurrections allowed

    //
    // Scoring values
    // Points for treasures are kept in the treasures themselves (as
    // oldtakepoints, olddepositpoints, defaults 2 and 12)
    score = 36              // start out with 36 points:
                            // (2 + (-1 * quitpoints) +
                            // (-1 * deathpoints) * 3)
    maxscore = 350          // maximum possible score
    novicepoints = -5       // points for playing in easy mode (neg.)
    quitpoints = -4         // points for quitting (neg.)
    deathpoints = -10       // points gained each time player dies (neg.)
    farinpoints = 25        // points for getting well into the cave
    extenpoints = 0         // points for entering extended regions

    closure = nil           // Has the endgame timer started yet?
    closurePoints = 0       // point award when it does.
    closingpoints = 25      // points for surviving until cave closing time
    endpoints = 10          // points for getting to final puzzle
    endkillpoints = 10      // points for getting killed in endgame
    klutzpoints = 15        // points for getting klutzed (blown up)
    almostpoints = 20       // points for *almost* getting final puzzle
                            // (wrong part of room blown up)
    winpoints = 35          // points for winning the final puzzle
    escapepoints = 0        // These two properties are not applicable
    finalepoints = 0        // in this version.

    security_alert = nil
    //
    // NPC stuff
    //
    dwarves = 5             // number of dwarves wandering about the cave
                            // (Was 5 in original.)

    sacklist = []           // containers for automatic inventory
                                // management
    
    scoreRanks = [0, 35, 100, 130, 200, 250, 300, 330, 349, 350]       
    
;

glob1: VerGlob
 /*
 * The following comments are adapted from the source of the scoring
 * routine in the 551-point game.   In the original Fortran version,
 * the non-treasure-related part of the score was not given in full until
 * 300 turns had been played.  This has not been implemented in the TADS
 * port.
 *
 * The scoring totals are as follows:
 *
 *    Objective:          Points:           Total possible:
 * Getting well into cave   25                    25
 * Total possible for treasures (+objects)       428
 * Surviving             (max-num)*10             30
 * Not quitting              4                     4
 * Reaching "closing"       20                    20
 * "closed": quit/killed    10
 *           klutzed        20
 *           wrong way      25
 *           success        30                    30
 * Round out the total      14                    14
 *                                      total:   551
 * (points can also be deducted for using hints.)
 * For full credit treasures must be in building, not broken, and in
 * the correct containers.  Scores depend on the basis property (default 1).
 * Optionally we can test that the container is in the
 * right place (contloc) and also the container-of-the-container
 * (outercontloc).
 *
 * Non-treasure objects: (points given for correct depositing)
 * Object       Score
 * magazine     1
 * marked rod   2
 * total        3
 *
 * Treasure scores are multiplied by 2 (range 4-10) when
 * discovered or 5 (range 5-25) when deposited correctly:
 * i.e. takepoints = 2 x basis
 *   depositpoints = 3 x basis
 *           total = 5 x basis
 * Treasure     Basis
 * book         2
 * wine         3 (in cask only - must enter via Styx to fill cask)
 * chain        4 (must enter via Styx to obtain this)
 * chest        5
 * cloak        3
 * clover       1
 * coins        5
 * crown        2
 * crystal-ball 2
 * diamonds     2
 * eggs         3
 * emerald      3
 * chalice      2
 * horn         2
 * jewels       1
 * lyre         1
 * nugget       2
 * pearl        4
 * pyramid      4
 * radium       4
 * ring         4
 * rug          3
 * sapphire     1
 * shoes        3
 * spices       1
 * sword        4
 * trident      2
 * vase         2
 * droplet      5
 * tree         5
 *      TOTAL: 85 * 5 = 425 + 3 ==> 428
 */
    vnumber = 1

    maxresurrect = 2        // number of resurrections allowed

    //
    // Scoring values
    // Points for treasures are kept in the treasures themselves (as
    // oldtakepoints, olddepositpoints, defaults 2 and 12)
   
    score = 48              // start out with 48 points:
                            // (14 + (-1 * quitpoints) +
                            // (-1 * deathpoints) * 3)
    maxscore = 551          // maximum possible score
    novicepoints = -5       // points for playing in easy mode (neg.)
    quitpoints = -4         // points for quitting (neg.)
    deathpoints = -10       // points gained each time player dies (neg.)
    farinpoints = 25        // points for getting well into the cave
    extenpoints = 0         // points for getting well into the cave

    closure = nil           // Has the endgame timer started yet?
    closurePoints = 0       // point award when it does.
    closingpoints = 20      // points for surviving until cave closing time
    endpoints = 0           // points for getting to final puzzle
    endkillpoints = 10      // points for getting killed in endgame
    klutzpoints = 20        // points for getting klutzed (blown up)
    almostpoints = 25       // points for *almost* getting final puzzle
                            // (wrong part of room blown up)
    winpoints = 30          // points for winning the final puzzle
    escapepoints = 0        // These two properties are not applicable
    finalepoints = 0        // in this version.score = 48              // start out with 48 points:
                            // (14 + (-1 * quitpoints) +
                            // (-1 * deathpoints) * 3)
    
    

    security_alert = nil
    //
    // NPC stuff
    //
    dwarves = 5             // number of dwarves wandering about the cave
                            // (Was 5 in original.)

    sacklist = []           // containers for automatic inventory
                                // management
    
    scoreRanks = [0, 72, 130, 200, 250, 350, 450, 500, 550, 551]       
    
;

/*   The glob2 and glob7 objects hold lists and values which are copied over to
     the global object when a 550-point or 580-poing game is selected.  */

class glob_550: VerGlob
    maxresurrect = 3        // number of resurrections allowed
    //
    // Scoring values
    //
    // 9 points initially, 1 point for magazines, 390 (420) points for
    // treasures, 20 points for getting far in, 30 points for reaching
    // extended areas, 100 points for endgame.
    // Total = 550 (580).
    //
    // Points for treasures are set to:
    // takepoints = 2, depositpoints = 13.
    //
    score = 9               // start out with 9 points: (-1*quitpoints)
                            // Thus, score can be negative in this version.
    novicepoints = -5       // points for playing in easy mode (neg.)
    quitpoints = -4         // points for quitting (neg.)
    deathpoints = -10       // points gained each time player dies (neg.)
    farinpoints = 20        // points for getting well into the cave
    extenpoints = 10        // points for reaching extended areas.

    closure = nil           // Has the endgame timer started yet?
    closurePoints = 20      // point award when it does.
    closingpoints = 20      // points for surviving until cave closing time
    endpoints = 20          // points for getting to final puzzle
    endkillpoints = 0       // points for getting killed in endgame
    klutzpoints = 0         // points for getting klutzed (blown up)
    almostpoints = 0        // points for *almost* getting final puzzle
                            // (wrong part of room blown up)
    winpoints = 0           // points for winning the final puzzle
    escapepoints = 20       // points for leaving the cylindrical room
    finalepoints = 20       // points for entering the treasure room in
                            // the endgame.

    sacklist = []           // containers for automatic inventory
                            // management
    //
    // NPC stuff
    //
    dwarves = 5             // number of dwarves wandering about the cave
                                // (Was 5 in original.)
;
glob2: glob_550
    maxscore = 550
    vnumber = 2
    
    scoreRanks = [0, 20, 130, 240, 350, 470, 510, 530, 549, 550]  
;
glob7: glob_550
    maxscore = 580
    vnumber = 7
    
    scoreRanks = [0, 20, 135, 250, 365, 485, 525, 545, 565, 580]  
;


/*   The glob15 and glob11 objects inherit the same set of values, and are
     used in the 701 and 701+ point games.  The difference is that the
     701+ game scores bonus points when the new extended area is reached. */

class glob_701: VerGlob
    maxresurrect = 3        // number of resurrections allowed
    //
    // Scoring values
    //
    // 44 points initially, 1 point for magazines, 504 points for
    // treasures, 20 points for getting far in, 30 points for reaching
    // extended areas from the 550-point game, 100 points for endgame.
    // Total = 701
    //
    // Points for all treasures are set to:
    // takepoints = 2, depositpoints = 10.
    //
    score = 46              // to round out the score
    maxscore = 701          // maximum possible score
    novicepoints = -5       // points for playing in easy mode (neg.)
    quitpoints = -4         // points for quitting (neg.)
    deathpoints = -10       // points gained each time player dies (neg.)
    farinpoints = 20        // points for getting well into the cave
    extenpoints = 10        // points for reaching extended areas.

    closure = nil           // Has the endgame timer started yet?
    closurepoints = 20      // point award when it does.
    closingpoints = 20      // points for surviving until cave closing time
    endpoints = 20          // points for getting to final puzzle
    endkillpoints = 0       // points for getting killed in endgame
    klutzpoints = 0         // points for getting klutzed (blown up)
    almostpoints = 0        // points for *almost* getting final puzzle
                            // (wrong part of room blown up)
    winpoints = 0           // points for winning the final puzzle
    escapepoints = 20       // points for leaving the cylindrical room
    finalepoints = 20       // points for entering the treasure room in
                            // the endgame.

    sacklist = [sack,treasureChest] // containers for automatic inventory
                                     // management
    //
    // NPC stuff
    //
    dwarves = 5             // number of dwarves wandering about the cave
                            // (Was 5 in original.)
    scoreRanks = [0, 20, 130, 350, 475, 601, 661, 681, {:700 + global.extras}, {:701 +
        global.extras}]  

//    copy {
//        inherited glob1;
//    }
;

glob15: glob_701
    vnumber = 15
     
;

glob11: glob_701
    vnumber = 11     
;




 die()
{
    
    
    addToScore(global.deathpoints, 'for getting killed');
    finishGameMsg(ftDeath, [finishOptionUndo, finishOptionResurrect, finishOptionFullScore]);
}

// In some cases, both sides of a door (e.g. the grate or rusty door) are
// represented as a single floatingdecoration object, and the doordest
// depends on the location of an actor.  The actor won't always be Me, and
// in Polyadv the convention is to check the location of a 'current
// actor' (global.currentActor), either directly or through the door's location
// method.
//
// An optional argument (loc) to the NPCdest method specifies the location
// of an actor who wishes to pass through the door.  If the doordest
// property is a method, NPCdest will place a dummy actor in this location
// and temporarily make it the current actor.

modify Door
    wasopen = nil
    waslocked = nil
;

modify DSDoor
    NPCdest(...) {
        local loc = nil, actorsave, value;
        local ptype = self.propType(&otherSide);
        if (argcount > 0) loc = getArg(1);
//        if ((isOpen || !isLocked || autoUnlock) && ptype == 2) {
        if (isOpen || !isLocked || autoUnlock) {
            // If a location is given and the doordest property is a method,
            // we place a dummy actor object in the room and make it the
            // current actor.
            if(loc && (ptype == TypeCode || ptype == TypeFuncPtr)) {
                actorsave = global.currentActor;
//                dummysave = DummyActor.location;
//                DummyActor.location = loc; 
                global.currentActor = gPlayerChar;
            }
            value = otherSide;
            // reset the global actor and dummy actor location
            if(loc && (ptype == TypeCode || ptype == TypeFuncPtr)) {
                global.currentActor = actorsave;
//                DummyActor.location = dummysave;
            }
        }
        else
            value = nil;
        return value;
    }
;

/* Modify lookLister to get same prefix as in the TADS 2 port */
modify lookLister
    showListPrefix(lst, pl, paraCnt)
    {
        "{I} {see} ";
    }
;

silentIncscore(num, txt = 'sundry adjustments')    
{
    scoreNotifier.silentScore = true;
    addToScore(num, txt);
    
}
    
modify scoreNotifier
    silentScore = nil
    checkNotification()
    {
        if(silentScore)
        {
            /* Turn off the silentScore flag so it doesn't affect future score changes. */
            silentScore = nil;
            
            /* Update lastScore so we done't generate a score notifactoion on a subsequent turn */
            lastScore = libScore.totalScore;
            return;
        }
        
        inherited();
    }
    
;
    

/* Function to move portable objects from one room to another */
roomMove(oldroom,newroom) 
{
    local l, cur, i, tot;
    l = oldroom.contents;
    tot = l.length;
    for (i = 1; i <= tot; i++) 
    {
        cur = l[i];
        /* Move all the non-fixed objects from oldroom to newroom */
        if (!cur.isFixed)
            cur.moveInto(newroom);
    }
}

modify Room
    hasPassage = nil
    hasCanyon = nil
    isolated = nil
    Zarkalonroom = nil
    analevel = 0
    brassKey = nil
    smashdrop = nil
    nothingHappens = "Nothing happens. "
    
    NPCvalid = (!(noNPCs || deleted || version_NoNPCs))
;
    
modify Actor
    roomMoveTravel(moveprop,dest,...)
    {
        // Similar to vehicleTravel, but all portable objects are moved
        // to the new room.  (The contents of non-portable containers are
        // not moved.)
        local prop;
        //        local travelsave = global.travelActor;
        local currentsave = gActor;
        try
        {
            if(argcount > 3) 
                prop = getArg(3);
            //        global.travelActor = self;
            gActor = self;
            if (prop != nil) 
                dest = dest.(prop);
            
            roomMove(getOutermostRoom, dest.getOutermostRoom);
            //        travelVia(dest);
            self.(moveprop)(dest);
            //        global.travelActor = travelsave;
        }
        finally
        {
            gActor = currentsave;
        }  
    }
    
    /* 
     *   The TADS 2 implementation defines a transmove method which may be redundant in TADS
     *   3/adv3Lite. Fow now we keep it just in case but make it do the samea ss travelVia.
     */
    transmove(dest)
    {
        travelVia(dest);
    }

    
    kaleid = nil

    blueberriesEaten = 0
;

/* 
 *   Although the player can always UNDO, this may not help if they've died in a hopeless situation,
 *   in which case the resurrection option may be more use to them.
 */

finishOptionResurrect: FinishOption
    desc = '''<<aHrefAlt('resurrect', 'RESURRECT', '>R<b>E</b>SURRECT',
            'Resurrect the player')>> the player'''
    responseKeyword = 'resurrect'
    responseChar = 'e'
    
    listOrder = 50
    
    doOption()
    {
        local resurrect = nil;
        if(global.deaths == 0)
        { 
            "Oh dear, you seem to have gotten yourself killed.  I
            might be able to help you out, but I've never really
            done this before.  Do you want me to try to
            reincarnate you?\b>";
            
            if (yesOrNo()) 
            {
                "\bAll right.  But don't blame me if something
                goes wr...... \b \ \ \ \ \ \ \ \ \ \ \ \ \ \
                \ \ \ \ \ \ --- <b>POOF!!</b> --- \bYou are engulfed
                in a cloud of orange smoke.  Coughing and
                gasping, you emerge from the smoke and
                find that you're....";
                
                resurrect = true;
            }
            else
                "\bVery well. ";
            
        }   
        // extra message issued in 550-point game ...
        else if (global.deaths == 1 && global.maxresurrect >= 3)
        {
            "Tsk, tsk -- you did it again!  Remember -- you're only human,
            and you don't have as many lives as a cat!  (at least, I don't
            think so...) That's twice you've ended up dead -- want to try
            for three?\b>";
            
            if (yesOrNo()) 
            {
                "\bOkay, now where did I put my orange
                smoke?....  <b>POOF!</b>\bEverything disappears in
                a dense cloud of orange smoke. ";
                
                resurrect = true;
            }
            else
                "\bProbably a wise choice.";
        }
        else if (global.deaths < global.maxresurrect) 
        {
            "You clumsy oaf, you've done it again!  I don't know
            how long I can keep this up.  Do you want me to try
            reincarnating you again?\b>";
            
            if (yesOrNo()) {
                "\bOkay, now where did I put my orange
                smoke?....  <b>POOF!</b>\bEverything disappears in
                a dense cloud of orange smoke.";
                
                resurrect = true;
            }
            else
                "\bProbably a wise choice.";
        }
        // resurrections used up,
        else 
        {
            "Now you've really done it!  I'm out of orange smoke!
            You don't expect me to do a decent reincarnation
            without any orange smoke, do you?\b>";
            
            if (yesOrNo())                 
                "\bOkay, if you're so smart, do it yourself!
                I'm leaving!";            
            else
                "\bI thought not!";
        }
        
        global.deaths += 1;
        
        
        if(resurrect)
        {
            local i,o,l,pcount = 0,savecont = gPlayerChar.contents;
            //            local doorlist = [grate];
            
            //        local doorlist = [Grate, Small_door_1, Small_door_2, Iron_door_1, 
            //        Iron_door_2]; 
            //            
            l = savecont.length;
            for (i = 1; i <= l; i++) {
                o = savecont[i];
                if (!o.wornBy == gPlayerChar || !o.ofKind(PendantItem) || (o == brokenPendant))
                    o.moveInto(gRoom);
                else
                    pcount++;
            }
            roomMove(ledgeByDoor, topOfSteps);
            roomMove(undergroundSea, grottoWest);
            roomMove(denseJungle, knoll);
            roomMove(vastChamber, throneRoomEast);
            if(!brassLantern.destroyed) 
            {
                brassLantern.makeLit(nil);
                brassLantern.moveInto(atEndOfRoad);
            }
            
            if(wumpus.isChasing && wumpus.upset && ! transRoomDoor.isunlocked) 
            {
                wumpus.upset = nil;
                transRoomDoor.moveInto(nil);
                octagonalRoom.east = nil;
                octagonalRoom.NPCexits -= transRoomDoor;
                rockfalls.ismoved = nil;
            }            
            
            for(o = firstObj(Chaser); o != nil; o = nextObj(o, Chaser))
                // DJP: banish chasers only if they're actually chasing.
                if (o.isChasing) o.banish();
            // Check for an in-between state, when the blob has been notified
            // for summoning but this hasn't yet taken place.
            if(global.triggered_alert && !global.security_alert)
                eventManager.removeEvent(blob,&summon);
            
            // Nore stuff to be done here.
            
            "\b";
            gPlayerChar.health = 100;
            
            
            
            // There's a whole more here that can't be included
            // until the relevant items have been implemented.
            
            gPlayerChar.moveInto(insideBuilding);
            gRoom.lookAroundWithin();     
            gPlayerChar.prevloc = nil; // DJP - destroy info about previous location
            
            if(pcount >= 1) 
            {
                
                "<.p>For a moment, you feel as if something is missing.  Then the
                air starts to shimmer, and you feel a strange sensation on the
                back of your neck.  You glance down, and notice that ";
                if (pcount == 1)
                    "the pendant has reappeared! ";
                else  
                    "the pendants have reappeared! ";
            }
            
            abort;
            
            /* tell finishGame not to ask for another option */
            //            return nil;
        }
              
        
        /* tell finishGame() to ask for another option */
        return true;
    }
;

modify Player
    panicked = nil  // has the player panicked after closing time?
    
    // The original 350-point code only allowed the player to carry
    // seven objects at a time.  Weight wasn't taken into
    // consideration.   This has now been changed.  In the 551-point
    // version, weight as well as bulk are taken into consideration.
    // (In the Fortran version only weight was considered).  You can
    // still carry only 7 objects in your hands (unless you have very
    // bulky items like the clam) , but the sack allows
    // you to carry more, up to your weight limit.  Items which are
    // worn don't count towards the total weight.
    
    bulkCapacity = 7
    weightCapacity = 20
        
    health = 100
    
    // This counts how many portions of blueberries have been eaten
    blueberriesEaten = 0

    //
    // Give the player points for getting a fair ways into
    // the cave.
    //
    awardedpointsforgettingfarin = nil
    
    /* Here we do much of the stuff that the TADS 2 version does in BasicMe.travelTo */
    actionMoveInto(loc)
    {
        local toproom;
        local oldloc, newloc = getOutermostRoom;
        
        if(lastmoveloc == nil) 
        {
            lastmoveloc = location;
            lasttoploc = lastmoveloc.getOutermostRoom;
        }
        oldloc = lasttoploc;
 #ifndef __DEBUG       
        if(loc.deleted)
        {
            "{I} {can't} go that way in this version of the game. ";
            return;
        }
 #endif    
        
        if (global.closed && loc.isoutside && !gRoom.isoutside) 
        {   
            global.closingmess;
            
            if (!panicked) 
            {
                panicked = true;
                
                //
                // We have reverted to the original behavior of the
                // Fortran code which set the endgame timer to 15
                // (rather than incrementing it by 15 which seems
                // unkind to the player).  However a check has now
                // been added to stop global.bonustime from being changed
                // after full closure.
                
                if (!global.fully_closed) 
                { 
                    global.bonustime = global.panictime;  // DJP
                }
            }
            
            exit;     // no travel 
        }
        
        // Save the travel route and previous travel route
        // (currently used only for the purpose of backtracking detection when
        // the Wumpus is chasing the player).
        if(oldloc != newloc) 
        {
            prevloc = oldloc;
            if(nextRoute != nil) 
            {
                previousRoute = travelRoute;
                travelRoute = nextRoute;
            }
        }
        
        // DJP - save previous topmost location.
        // Moves within the same topmost room (e.g. when sitting on the
        // Y2 rock) are ignored, but a move from a top-level room to the
        // same top-level room (through a looping passage) is acknowledged.
        if(lastmoveloc == loc && newloc == loc) 
        {
            prevloc = oldloc;
            if(nextRoute == nil || nextRoute == 0) 
            {
                previousRoute = travelRoute;
                travelRoute = 11;
            }
            else travelRoute = self.nextRoute;
            // for use by Wumpus-chasing code, to detect that reflexive
            // travel has just happened.  (The property is cleared by
            // the code).
            reflexmove = true;
        }
        
        inherited(loc);
        
        toproom = getOutermostRoom;
        
        lastmoveloc = location;
        lasttoploc = getOutermostRoom;
        
        if(!toproom.notfarin && !awardedpointsforgettingfarin)
        {
            addToScore(global.farinpoints, 'getting well into the cave');
            awardedpointsforgettingfarin = true;
        }
        
        if(toproom.isbonus && !toproom.bonusawarded)
        {
            addToScore(global.extenpoints,
            'for entering a room with bonus points');
            toproom.bonusawarded = true;
            if(toproom.isbonus_addmax)
            {
                global.maxscore += global.extenpoints;
                global.extras += global.extenpoints;
               gameMain.maxScore = global.maxscore;
            }            
        }
        
        // DJP - Warn if the lamp is left on when wandering outside
        // in lit rooms, except in certain rooms near entrances, or
        // when the message has already been issued.
        if (!lamplitwarn && gRoom.isoutside &&!toproom.nolampwarn && !toproom.isLit) 
        {
            if (brassLantern.isIn(self) && brassLantern.isLit) 
            {                
                "<.p>You know, you are wasting your batteries by
                wandering around out here with your light on.";
                lamplitwarn = true;
            }
        }
        // Allow the warning message to appear again once the
        // player enters a dark room.
        if (!toproom.isLit)
            lamplitwarn = nil;
        
    }
    
    lastmoveloc = nil
    lasttoploc = nil

    lamplitwarn = nil
    closerestrict = true // check travel destination at closing time.
    
    // Enhanced travelTo method:
    // The argument list is:
    // room, propptr, refloc, nocheck   
    // All arguments after the first are optional and default to nil.
    // propptr  - pointer to a travel property e.g. &north.  If this is non-nil
    //            the destination will be room.(propptr) instead of 
    //            room. 
    // refloc   - if non-nil, put a dummy reference actor in this room for
    //            the purpose of evaluating location methods.
    // nocheck  - if true, allow the actor to go anywhere at closing time.
    //            This is forced to true unless the actor has the 
    //            closerestrict method set to true.
 
    // The advantage of the propptr argument is that it allows travelTo to
    // set global variables before the travel property is evaluated.  If the
    // property is a method, it may then use the global variables e.g. to
    // issue different messages, depending on which actor is being moved.

    // The following properties are set in the global object:

    // currentActor - the actor for the purpose of evaluating location methods.
    // travelActor - the actor doing the travelling.
 
    
    // I'm not sure about this since adv3Lite travel actions don't call travelTo
    // maybe this needs to be implemented as actionMoveInto()?
    // or at least some of it does?
    travelTo(obj, ...)
    {
        local room;
        local propptr = nil, refloc = nil; 
//        local nocheck = nil;
//        local travelsave, currentsave, dummylocsave;
        
        if (argcount > 1) propptr = getArg(2);
        if (argcount > 2) refloc = getArg(3);
//        if (argcount > 3) nocheck = getArg(4);
//        if (!closerestrict) nocheck = true;  
        
//        travelsave = global.travelActor;
//        currentsave = gActor;
//        dummylocsave = dummyActor.location;
        
        global.travelActor = self;

        if (refloc)        
        {            
             gActor = dummyActor;
             dummyActor.location = refloc;
        }
        else 
             gActor = self;
        
        if (propptr) 
        {
            if(dataType(propptr) != TypeProp) 
            {
                "Error: second argument to travelTo is not a property 
                pointer. ";
                abort;
            }
            room = obj.(propptr);
        }
        else
            room = obj;
        
        /* do nothing if going nowhere */
        if (room == nil)
            return;
        
//        toproom = room.getDestination(gRoom);
        
         
        
        /* Carry out the travel */
        travelVia(room);
    }
    
    shielded = (glowingStone.isIn(canister) && !canister.isOpen)
    
    healthdaemon() 
    {
        local i, toproom = getOutermostRoom, msg = nil;
        if (toproom.isoutside && !toproom.isindoor)
            health += 3;
        else health += 1;
        if(health > 100) health = 100;
        if (glowingStone.isIn(self) && !shielded) 
        {
            health -= 7; msg = true;
        }
        else if(glowingStone.isIn(toproom) && !shielded) 
        {
            health -= 5; msg = true;
        }
        if (msg) 
        {
            if (health < 60) 
            {
                i = 1 + (60 - self.health) / 10;
                say(healthmess[i]);
            }
        }
        if (health < 0) die();
    }
    
    healthmess = [
        'Is it hot in here?  You are flushed and sweating.',
        'You are feeling definitely peculiar, weak....',
        'You\'re dizzy, nauseous.  You can barely stand.',
        'You are really ill.  If you don\'t find an antidote soon, it\'s curtains.',
        'You are a walking wound.  You are very weak.  You\'d better find out 
           what\'s wrong before it\'s too late.',
        'Sheeesh!  What a mess!  Your hair has fallen out and your skin is
        covered with blisters.  And not an aspirin in sight!',
        'Well, you tried, but your strength is gone.  The agony is finally
        over.'
    ]
    
    reflexmove = nil
    previousRoute = 0
    travelRoute = 0
;

dummyActor: Actor 'dummy actor'
;


transient specialRestart: object
    isActive = nil
    restartProp = nil
    execute()
    {
        if(restartProp)
            self.(restartProp);
        
        isActive = nil;
        global.specialstart = true;
        restartProp = nil;
    }
    
    throneRestart()
    {        
        gTurns = turncount;
        global.vNumber = vNumber;
        global.novicemode = novicemode;
        global.randomized = randomized;
        global.nodwarves = nodwarves;    
        gameMain.verbose = verbose;    
        scoreNotifySettingsItem.isOn = notifyScore;
                        
        // Restore variables to do with the safe.  If the player knows
       // it's there, flag it as being hidden behind the poster.
        safe.moveInto(safeloc);
        if(safe.location)
            safe.hidden = true;
        safe.isHidden = isHidden;
        safeCombination.seen = safecombseen;
        safeDial.comboSet = comboSet;
        safe.hasOpened = safeopened;
        safeDial.combo = combination;
        
        // Restore variables to do with the player's memory.  For example,
        // if the throne room has been seen, the player won't crawl around
        // in little passages when trying to find it.
        throneRoom.seen = throneRoomSeen;
        throneRoom.visited = throneRoomSeen;
        riverStyxE.seen = riverStyxESeen;
        riverStyxE.visited = riverStyxESeen;
        pantry.seen = pantrySeen;
        pantry.visited = pantrySeen;
        
        // If these variables are set to true, the player already knows the
        // correct pronunciation of the relevant Elvish magic words
        knoll.seenit = knollSeenit;
        riseOverBay.seenit = knollSeenit;
        outerCourtyard.seenit = OCseenit;
        if(blue1.location != blue1loc)
            blue1.moveInto(blue1loc);   
       
    }
    
    turncount = 0
    newscore = 0
    vNumber = 0
    notifyScore = true
    novicemode = nil
    randomized = nil
    nodwarves = nil
    verbose = true
    safeloc = nil
    comboSet = nil
    safeopened = nil
    combination = [0,0,0]
    safehidden = nil
    safeisHidden = nil
    safecombseen = nil
    throneRoomSeen = true
    riverStyxESeen = nil
    pantrySeen = nil
    knollSeenit = nil
    ROBseenit = nil
    OCseenit = nil
    blue1loc = nil   
;  

P() { "<.p>";}
I() {"\t"; }

class VarLoc: PreinitObject
    execute()
    {
        varlocMonitor.valLocItems += self;      
    }
    updateLocation()
    {
        local newLoc = calcLocation();
        if(newLoc != location)
            actionMoveInto(newLoc);
    }
    
    calcLocation = location   
;

varlocMonitor: InitObject
    valLocItems = []
    execute()
    {
        local vardaemon = new Daemon(self, &updateLocations, 1);           
        vardaemon.eventOrder = 50;
    }
    updateLocations()
    {
        foreach(local o in valLocItems)
            o.updateLocation();
    } 
;