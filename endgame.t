#charset "us-ascii"

#include <tads.h>
#include "advlite.h"


/*
 * This file defines a few game-specific functions for the cave closing.
 * Don't read any of this unless you want to spoil the ending!
 */


/*
 * This function is called every turn to see if it's time to start
 * closing the cave.
 * BJS: In 550-point mode, it also awards a 20-point bonus (the value
 * of the award is stored in "global.closurepoints").
 */



//endGameCheck: InitObject
//    execute()
//    {
//        new PromptDaemon(self, &checkForClosing);
//    }
//     
//    
    
    
    
checkForClosing()
{
    if(global.closingtime > 0 && global.treasures <= 0)
    {
        // global.closure is now used only as a flag to indicate that
        // the closure countdown is in progress
        global.closure = true; 
        // a different property is used to test whether closure points have
        // been awarded (for collecting the last treasure)
        if (!global.closurePointsAwarded ) 
        {
            // only award points once, if at all - note that 
            // cancel_cave_closure no longer deducts these points once
            // they have been awarded.
            global.closurePointsAwarded = true;
            if(global.closurePoints) 
            {
                addToScore(global.closurepoints,'for collecting the last treasure');
            }
            else 
            {
                "<.p>*** You have collected the last treasure! ***<.p>";                    
            }
        }
        
        if(!gRoom.notfarin && gRoom != atY2)
        {
            // count down to zero only when the player is in a non-isolated,
            // non-Zarkalon room at Transindection level zero.
            if ((global.closingtime != 1) || ( (gRoom.analevel == 0) 
                                              && ! gRoom.isolated && ! gRoom.Zarkalonroom))
                global.closingtime--;
            if (global.closingtime < 1)
                startClosing(true);
        }
    }
    if (global.closingtime > 0) 
    {
        // set a flag if extra treasures have been found after the player has
        // apparently discovered them all
        if (global.closurePointsAwarded && (global.treasures > 0))
            global.extraTreasuresFound = true;
        // tell the player when the last treasure has been found
        if  (global.closurePointsAwarded && global.extraTreasuresFound &&
             (global.treasures <= 0)) 
        {
            global.extraTreasuresFound = nil;
            "<.p>*** I think you have collected the last available
            treasure - unless you can prove me wrong! ***<.p>";
            
        }
    }
}
;

/*
 * This function is called every turn to see if it's time to start
 * the final puzzle.
 */
checkForEndGame(parm)
{
    local toploc = gRoom;
    if (global.closed && global.bonustime > 0) 
    {
        // count down to zero only when the player is in a non-isolated,
        // non-Zarkalon room at Transindection level zero.
        if ((global.bonustime != 1) || ( (toploc.analevel == 0) 
        && ! toploc.isolated && ! toploc.Zarkalonroom))
            global.bonustime--;
        if (global.bonustime < 1) 
        {
            // set up some clocks
            if(global.newGame) 
            {
                global.endgameclock = 0;
                global.phonetime = 40;
                global.phonewake = 47;
            }
            // start the endgame
            startEndgame();
        }
    }

    // N.B. the combined game only has the cylindrical room endgame and
    // omits the repository scene.
    if (global.fully_closed && global.newGame && ! global.game701) 
    {
        global.endgameclock++;
        if(global.endgameclock == global.phonetime) {
            
            "<.p>The phone starts to ring. ";
//            Phone2.isringing = true; // add back when Phone2 is implemented
        }
        else if(global.endgameclock == global.phonewake) 
        {            
            "<.p>The constant ringing has awakened the dwarves! ";
//            end_dwarves(''); // add back when dwarves are implememted.
        } 
    }    
}


startClosing(clos)
{
    local i,o,l;

    // This should contain a list of all the external doors which are
    // to be locked at closing time, or during a Security Alert.

    local doorlist = [grate];
//        Small_door_1, Small_door_2, Iron_door_1, Iron_door_2]; // Add when implemented
    if(clos) 
    {
     
      "<.p>A sepulchral voice reverberating through the cave says,
      \"Cave closing soon.  ";
    

        if (global.game550) 
            "All adventurers please report to
            the treasure room via the alternate entrance to claim
            your treasure.\"";
        
        else 
            "All adventurers exit immediately through main office.\"";

      addToScore(global.closingpoints, 'surviving to closing time');

      global.closed = true;
    }
    
    else 
        global.security_alert = true;

//    CrystalBridge.vanish(parserGetMe());    // destroy the bridge
    // N.B. if the rod has been upgraded (possible in some versions),
    // it is possible to use it after cave closure.

    // Loop over all lockable external doors.
    // N.B. the closing-time condition is now handled by the new
    // CCR_lockableDoorway class; there is now no need to set the 
    // mykey property to nil.

    l = doorlist.length;
    for (i = 1; i <= l; i++) 
    {
        o = doorlist[i];
        // Save the state of the door.
        o.waslocked = o.isLocked;
        o.wasopen = o.isOpen;
//        o.wasAutoOpen := o.noAutoOpen;
        o.makeOpen(nil);            // close the door, then
        o.makeLocked(true);// lock it.
//        o.noAutoOpen := true;       // disable automatic opening.
    }

//    if(Elevator580.isopen && (pPlayerChar.isIn(S_Of_Center) || 
//    parserGetMe.isIn(N_Of_Center))) 
//        "With a >whooosh<, the elevator doors slide together. ";
//    Elevator580.isopen = nil;
    
    
//    if(gPlayerChar.isIn(S_Of_Center) || gPlayerChar.isIn(N_Of_Center))
//        "Out from around a corner at the far end of the computer center,
//         a disgruntled repair man walks over to the elevator and tapes
//         onto it a sign saying, \"OUT OF ORDER - Please use the stairs\",
//         and then walks away. ";
   
    if (clos) 
    {
//        Dwarves.closelist = Dwarves.loclist;
//        Dwarves.loclist = [];      // nuke dwarves...
//        Pirates.closelist : Pirates.loclist;
//        Pirates.loclist = [];      // ...and pirate(s)
        troll.closeloc = troll.location;
        troll.moveInto(nil);        // vaporize troll
        bear.closexists = bear.exists;
        bear.exists = nil;         // ditto for bear
//        Wumpus.closeloc := Wumpus.location;
        // fix for problem if the gold ring has been put back on the 
        // Wumpus' finger. It was still described as on the finger after
        // the Wumpus had gone.  Now it disappears with the Wumpus, but
        // reappears with the Wumpus if cave closure is cancelled. 
//        if((gold_ring.location = Wumpus.location) and not gold_ring.moved)
//            gold_ring.moveInto(Wumpus);
//        Wumpus.moveInto(nil);       // nuke the Wumpus (he must be
                                    // dead at this stage because we've
                                    // found the gold ring.)
//        Dog.closeloc = Dog.location;
//        Dog.moveInto(nil);          // likewise with the dog.

        // BJS: The creatures from the 550-point version must have disappeared
        // by now.

        // This was listed in the original as being too much trouble
        // to bother with.  (The old Fortran code allowed you to reach the
        // endgame without killing the dragon, and its removal at that point
        // would have required the duplication of complex code.)  But in this
        // version, all we need is:

        dragonCorpse.closeloc = dragonCorpse.location;
        dragonCorpse.moveInto(nil);     // nuke the dragon (which must be
                                        // dead - in the TADS port you must
                                        // take all the treasures, including
                                        // the rug, to reach the endgame.)
    }
    
}

cancelCaveClosure(a, b)
{
}


startEndgame()
{
    
    local i,o,l,savecont = gPlayerChar.contents;
    "<.p>The sepulchral voice intones, \"The cave is now
    closed.\" As the echoes fade, there is a blinding flash of
    light (and a small puff of orange smoke).\ .\ .\ .  As your
    eyes refocus, you look around and find that you're...\b";
    
    
    // Vaporize everything the player's carrying, except pendants which are
    // worn or carried in hand.
    //
    l = savecont.length;
    for (i = 1; i <= l; i++) 
    {
        o = savecont[i];
        if (!o.ofKind (PendantItem))
            o.moveInto(nil);               
    }
        
    //
    // Get rid of anything chasing the player.
    //
//    for(o = firstObj(Chaser); o != nil; o=nextObj(o, Chaser))
//        if (o.ischasing) 
//        o.banish;

    brassLantern.makeOn(nil);
    brassLantern.setLife(2500); // stop unwanted messages about the lamp
                                 // running out of power
    
    if (!global.game550) {    // update this statement if new versions are
                                 // added
        //
        // Stock the northeast end
        //
        bottle.setup;        // create method now makes empty container
        giantBivalve.setup;
//        blackRod.downgrade; // goes back to being rusty
        blackRod.setup;
        brassLantern.setup;
        //
        // Stock the southwest end
        //
        // Create 'clones' of various objects (which, being dynamically
        // created, will inherit all the vocab of the parent.  Statically
        // defined objects only inherit the vocab if the parent object is
        // a class.)
        //
        wickerCage.setup;
        blackMarkRod.setup;
        velvetPillow.setup;
//        if(global.newgame) 
//            global.newbook = new rare_book;
    }
    //
    // Move the player
    //
    if (global.game550) 
    {
        gPlayerChar.travelVia(cylindricalRoom);
        
    }

    else
        gPlayerChar.travelVia(atNEEnd);
      

    addToScore(global.endpoints, 'reaching the endgame');
}
 
endPuzzle()
{
    local meloc;
    local necount,swcount,boothcount,mecount;
    local cond1,cond2,oldcond1;

    meloc = atSWEnd;
    // count the rods in different places
//    bundcount = objCount(blackMarkRod, blackMarkRodBundle);
    necount = objCount(blackMarkRod, atNEEnd);
    swcount = objCount(blackMarkRod, atSWEnd);
    boothcount = objCount(blackMarkRod, inPhoneBooth2);
    
    mecount = objCount(blackMarkRod, gPlayerChar);
    
    // if no rods have been taken, explosion uses sw end bundle
    if((necount == 0) && (swcount == 0) && (boothcount == 0) && (mecount == 0)) 
        swcount = 1;
    
    cond1 = (necount > 0) && (mecount == 0);
    oldcond1 = cond1;
    if(global.newGame)
        cond1 = (boothcount > 0) && (necount == 0) && (mecount == 0) && (swcount == 0);

    cond2 = (swcount > 0) && (boothcount = 0) && (necount = 0) && (mecount = 0);
    
    if (cond1 && gPlayerChar.isIn(meloc)) 
    {
        "There is a loud explosion, and a twenty-foot
        hole appears in the far wall, burying the dwarves in
        the rubble.  You march through the hole and find
        yourself in the main office, where a cheering band of
        friendly elves carry the conquering adventurer off
        into the sunset.\b"; 

        addToScore(global.winpoints, 'winning');

        win();
    }
    
     else if (cond2 && gPlayerChar.isIn(atNEEnd)) 
    {
        "There is a loud explosion, and a twenty-foot
        hole appears in the far wall, burying the snakes in
        the rubble.  A river of molten lava pours in through
        the hole, destroying everything in its path,
        including you!\b"; 

        addToScore(global.almostpoints, 'almost winning');

        win(); // shouldn't that be die() ?
    }
    
    else  
    {
        "There is a loud explosion, and you are suddenly
        splashed across the walls of the room.";
        // if the adventurer tried the 350-point solution in the
        // 551-point puzzle, issue a hint.
        if (oldcond1 && gPlayerChar.isIn(meloc)) 
        {
            "<.p>That was a good try, but in the 551-point version
            you need to contain the explosion somewhat ... ";
        }
        addToScore(global.klutzpoints, 'almost winning'); 

        win(); // or die() ?
    }
    
}
   
objCount(obj, loc)
{   
    if(loc.ofKind(DispensingCollective))
        return obj == loc.dispensedClass ? loc.numLeft : 0;
       
    return loc.contents.countWhich({o: o.ofKind(obj)});
       
}

/*
 * The player resolves the endgame by disturbing the dwarves.
 */
end_dwarve(sentence = 'The resulting ruckus has awakened the dwarves.')
{
    "<.p><<sentence>> There are now several threatening little dwarves in 
    the room with you! Most of them throw knives at you!  All of them get
    you!\b";

    addToScore(global.endkillpoints, 'getting killed by dwarves'); 

    win();
}

   
/* 
 *   The DispensingCollective class defined in the adv3Lite Collective extension should do most of
 *   the work for us here.
 */
class ObjPile: DispensingCollective
    
    cannotDispenseMsg = 'Don\'t be greedy. You\'ve already taken <<dispensedCount>> 
        <<dispensedClass.pluralNameFrom(dispensedClass.name)>>. Pleass leave some for 
          future adventurers. '
    
    maxToDispense = 4
    
    iobjFor(PutIn)
    {
        verify() {}
        check()
        {
            if(!gDobj.ofKind(dispensedClass))
                "Only <<dispensedClass.pluralNameFrom(dispensedClass.name)>> should go
                on {the iobj}. ";
        }
        action()
        {
            gDobj.moveInto(nil);
            dispensedCount--;
            
            "{I} place(s/d} {the dobj} in {the iobj}. ";
        }
    }
    
    iobjFor(PutOn) asIobjFor(PutIn)
;
  

/*
 * Endgame locations
 *
 * We make these NoNPC rooms so that dwarves and pirate don't get
 * teleported here when (if) they get stuck trying to move around
 * the cave.  (The dwarves in here aren't real actors because they
 * kill the player immediately if they're awake.)
 *
 * The major innovation in Polyadv is to allow users to take more than
 * one object - we are told of a 'bundle' of rods or a 'row' of lamps, so
 * we ought to be able to take more than one.   But the game puts a limit
 * on the number.
 *
 */
/* 115 */
atNEEnd: Room, NoNPC 'At NE End'
    desc()
    {
        "You are at the northeast end of an immense
        room, even larger than the giant room.  It appears to
        be a repository for the \"Adventure\" program.
        Massive torches far overhead bathe the room with
        smoky yellow light.  Scattered about you can be seen
        a pile of bottles (all of them empty), a nursery of
        young beanstalks murmuring quietly, a bed of oysters,
        a bundle of black rods with rusty stars on their
        ends, and a collection of brass lanterns.  Off to one
        side a great many dwarves are sleeping on the floor,
        snoring loudly.  A sign nearby reads: \"Do not
        disturb the dwarves!\"<.p>";

        "An immense mirror is hanging against one wall,
        and stretches to the other end of the room, where
        various other sundry objects can be glimpsed dimly in
        the distance. ";

        if(global.newGame) {
            "An unoccupied telephone booth stands against the north wall. ";
        }
    }

    hasfloor = true // DJP
//    
//    
//    {
//        if(global.newgame) {
//            Phone_Booth2.doEnter(global.travelActor);
//            return nil;
//        }
//        else pass in;
//    }
//    north =  {
//        if(global.newgame) {
//            Phone_Booth2.doEnter(global.travelActor);
//            return nil;
//        }
//        else pass north;
//    }
    southwest = atSWEnd
    
;


+ bottlePile: ObjPile 'pile of empty bottles; another more ;bottle'
    "It's a pile of empty bottles like the one you found in the building. "
    
    dispensedClass = bottle
;
  
+ oysterPile: ObjPile 'bed of oysters;another more large;oyster'
    "It's a bed of large oysters, similar to the one you found in the Shell Room.  "

   dispensedClass = giantBivalve
   maxToDispense = 2
    
;
    
+ blackRodBundle: ObjPile 'bundle of rods, black another more; rod'
    "It's a bundle of black rods with stars on their ends, like
     the one you found in the Debris Room. "
    
    dispensedClass = blackRod
;

+ lampCollection: ObjPile 'collection of brass lanterns; more another; lamp lamps lantern'
    "It's a collection of brass lanterns like the one you
        used earlier. "
    dispensedClass = brassLantern
;

mirror2: MultiLoc, Fixture 'enormous mirror'
    "It looks like an ordinary, albeit enormous, mirror. "
    
    loclationList = [atNEEnd, atSWEnd]
;


/* 116 */
atSWEnd: Room, NoNPC 'At SW End'
   
        // the wording re the pillows was changed slightly here to
        // fit in with the implementation which expects the objects
        // to be in piles, bundles etc.
        "You are at the southwest end of the repository.
        To one side is a pit full of fierce green snakes. On
        the other side is a row of small wicker cages, each
        of which contains a little sulking bird.  In one
        corner is a bundle of black rods with rusty marks on
        their ends.  In another corner is a large pile of
        velvet pillows. 
        A vast mirror stretches
        off to the northeast. At {my} feet is a large steel
        grate, next to which is a sign which reads,
        \"TREASURE VAULT. Keys in main office.\""
    

    hasfloor = true // DJP

    northeast = atNEEnd
    down = repositoryGrate

;

+ Fixture 'sign'
    "The sign reads, \"TREASURE VAULT. Keys in main office. \""
    readDesc = desc
;

+ wickerCageRow: ObjPile 'row of wicker cages;more another; cage'
    "It's a row of wicker cages, similar to the one you found
        earlier.  Each one contains a little sulking bird. "
    
    
    dispensedClass = wickerCage

    // Only a bird with a cage can be returned to the row.
    
    iobjFor(PutIn)
    {
        verify() {}
        
        check()
        {               
            if(gDobj.ofKind(dispensedClass) && gDobj.contents.length == 0)
                "I like to keep this area tidy.  That row is for
                birds in cages - not empty cages. ";
            else
                inherited();
        }
        
    }   
    
    sayDispensed(obj)
    {
        local bird = new littleBird;        
        bird.moveInto(obj);
        obj.updateVocab();
        
        inherited(obj);
    }
    
    
    
;

+ blackMarkRodBundle: ObjPile 'bundle of rods; another more dynamite marked; rod'
    "It's a bundle of black rods, similar to the one you found
        in the Debris Room but without a star on the end.  I'll now
        refer to these rods as \"marked rods\" and to the other type
        as \"star rods\". "

    dispensedClass = blackMarkRod
;

+ velvetPillowPile: ObjPile 'pile of velvet pillows;more another;pillow'
    "It's a pile of velvet pillows, identical to the one you
        found in the Soft Room. "
    
    dispensedClass = velvetPillow    
;

+ repositoryGrate: Door 'steel grate; metal strong locked ;lock gate grille'
    "It just looks like an ordinary steel grate. It is cloed and locked. "
    isLocked = true
    lockabilility = lockableWithKey
    otherSide = self
    
    dobjFor(LookThrough)
    {        
        action()
        {
            if(gPlayerChar.contents.countWhich({o: o.ofKind(brassLantern) == 0}))
                "You peer through the grate.  A ladder leads down into
                a dark room which appears to contain rows of cabinets. "; 
            else
                "You shine a lamp through the grate.  A ladder leads down to
                a dark room containing rows of locked steel cabinets, bearing
                labels like \"Diamonds\" or \"Rare Coins\". "; 
            
            "Unfortunately the keys are in the Main Office, so you can't get
            hold of any of the treasures right now.  ";
        }
        
    }
;

snakepit: Fixture 'pit of snakes; fierce green snake'
    "They're identical to the snake you saw in the Hall of the
     Mountain King -- and just as dangerous. "
    
    cannotTakeMsg = '{I} {can\'t} be serious. '
    cannotEnterMsg = cannotTakeMsg
    cannotBoardMsg = cannotTakeMsg
    lookInMsg = 'The pit is full of fierce green snakes. '
;

cylindricalRoom: Room 'Cylindrical Room'
    "You are in a small cylindrical room with very smooth
        walls and a flat floor and ceiling.  There are no
        exits visible anywhere." 
    
//    noExits = 'none visible'
;

phoneBooth2: Enterable 'phone booth'
    
    
    game551 = true
    connector = phoneBooth2Door
;

phoneBooth2Door: DSDoor 'phone booth door' @atSWEnd @inPhoneBooth2
    
    isConnectorApparent = (phoneBooth2.isIn(room1))
    game551 = true
;

inPhoneBooth2: NoNPC, Room 'Inside the Phone Booth'
    south = phoneBooth2Door
    out asExit(south)
;

win()
{
    finishGameMsg(ftVictory, [finishOptionUndo, finishOptionFullScore]);
}