#charset "us-ascii"

#include <tads.h>
#include "advlite.h"

/* 
 *   This file contains code corresponding to the TADS 2 advmods.t file. The sections of the TADS 2
 *   file relating to the thing and item classes have been moved to thingext.t. Not everything in
 *   the TADS 2 file has been implemented here, as much of it may prove unnecessary in
 *   TADS3/adv3Lite or else may require a different approach. 
 */


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
    game350 = (vNumber == 0)//? TADS2 version uses but does not define this property.
    game550 = ([2, 7, 11, 15].find(vNumber) != nil)
    game580 = (vNumber == 7)
    game701 = ([11, 15].find(vNumber) != nil)
    game701p = (vNumber == 11)
    
    listenAdd = nil
    vendingTreasures = 0
    nondeterministic = true
    randomized = nil
    specialstart = nil
    NPCstarted = nil
    NPCrooms = []
  
    treasures = 0
    origTreasures = 0
    closure = nil
    closurePoints = 0
    closurePointsAwarded = nil
    treasurelist = []
    extraTreasuresFound = nil
    fullyClosed = true
    endpoints = 0
    maxscore = 0
    maxhiked = 0
    
    debug = nil
    
    extendMoveInto = true
    nodwarves = nil
    
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
    
    
    // game version selection
    removelist = []     // list of objects to be removed
    movelist = []       // list of objects to be moved to different
                // locations
    changeloc = []      // list of modified locations
    moveloclist = []    // floatingdecoration objects to be given
                        // a different loclist
    changeloclist = []  // list of modified loclists

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
    
    allpointslist = []

    travelActor = gPlayerChar    // actor doing the travelling, for use by travel
                        // methods.

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
    closingpoints = 0
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
    
    fully_closed = nil
    
    startscore = 0
;


/* Customize various library messages to match those used in the TADS 2 implementation. */
CustomMessages
    messages =
    [
        Msg(nothing special, 'It looks like an ordinary {name dobj} to me. '),
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
        
        // Code for list of light sources goes here.
        
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
        while (o != nil) {
            condit = (o.allversions || o.(gameprop));
            if(!condit) 
            {
                i.removelist += o;
            }
            o = nextObj(o, Thing);
        }
        
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
        
        
       
    }
;

/* 
 *   Setup the dats (objects, rooms, connections, scoring, etc.) related to the current version of
 *   the game.
 */
versionSetup: InitObject
    execute()
    {
        local o, copied, l, i, p;
        // adjust global variables for the game version (and do any
        // extra setup needed.)
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
        global.startscore = global.score;        
    
    
    
    // move player -> 1st location
    {
        if(!gPlayerChar.isIn(atEndOfRoad))
            gPlayerChar.moveInto(atEndOfRoad);
        /* 
         *   Note that the TADS2 code below would not work in TADS 3. In both Adv3 and Adv3Lite you
         *   can't move objects around by changing their location property. In adv3Lite you must use
         *   moveInto(loc) or actionMoveInto(loc), the latter being more appropriate if used in
         *   response to player input.
         */
//    parserGetMe().location := At_End_Of_Road;
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
    
    

    // copy verglobal settings to global.  This method can be overridden
    // if extra copying or setup is to be done.
    copy {
        global.maxresurrect  = self.maxresurrect;
        libScore.totalScore  = self.score;
        global.maxscore      = self.maxscore;
        gameMain.maxScore = maxscore; // Added for adv3Lite sooring system
        global.novicepoints  = self.novicepoints;
        global.quitpoints    = self.quitpoints;
        global.deathpoints   = self.deathpoints;
        global.farinpoints   = self.farinpoints;
        global.extenpoints   = self.extenpoints;
        global.closurepoints = self.closurepoints;
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
    closurepoints = 0       // point award when it does.
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


 die()
{
    finishGameMsg(ftDeath, [finishOptionUndo, finishOptionFullScore]);
}

modify Door
    wasopen = nil
    waslocked = nil
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
    local wasNotifying = scoreNotifySettingsItem.isOn;
    scoreNotifySettingsItem.isOn = nil;
    addToScore(num, txt);
    scoreNotifySettingsItem.isOn = wasNotifying;
}
    
