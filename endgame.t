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
                addToScore(global.closurePoints,'for collecting the last treasure');
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
        if(global.endgameclock == global.phonetime) 
        {
            
            "<.p>The phone starts to ring. ";
            phone2.isringing = true; // add back when Phone2 is implemented
        }
        else if(global.endgameclock == global.phonewake) 
        {            
            "<.p>The constant ringing has awakened the dwarves! ";
            end_dwarves(''); 
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
        wumpus.moveInto(nil);       // nuke the Wumpus (he must be
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
    for(o = firstObj(Chaser); o != nil; o=nextObj(o, Chaser))
    {
        if (o.isChasing) 
        o.banish;
    }

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
        if(global.newgame) 
        {
            local newbook = rareBook.createClone();
            newbook.moveInto(atSWEnd);
        }
    }
    //
    // Move the player
    //
    if (global.game550) 
    {
        gPlayerChar.travelVia(cylindricalRoom);
        /* Construct the list of Magic Words in reverse alphabetical order. */
        cylindricalRoom.buildWordList();
        
    }

    else
        gPlayerChar.travelVia(atNEEnd);
      
    if(global.endpoints != 0)
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

    cond2 = (swcount > 0) && (boothcount == 0) && (necount == 0) && (mecount == 0);
    
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

        win(); 
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
   

/*
 * The player falls foul of the booby-trapped phone.
 */
end_phone()
{
    "Whoops!  The floor has opened out from under you!  It seems you
    have fallen into a bottomless pit.  As a matter of fact, you're
    still falling!  Well, I have better things to do than wait around
    for you to strike bottom, so let's just assume you're dead.
    Sorry about that, Chief.<.p>";

    addToScore(global.endkillpoints, 'falling foul of the booby-trapped phone'); 

    win();
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
end_dwarves(sentence = 'The resulting ruckus has awakened the dwarves.')
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
    
    checkDobjCount = "It would take {me} all day to count all
        <<dispensedClass.pluralNameFrom(dispensedClass.theName)>> {here}. "
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
atNEEnd: Room, NoNPC 'At NE End' 'the northeast end of the immense room; ne'
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
        snoring loudly.  A sign nearby reads: <q>Do not
        disturb the dwarves!</q><.p>";

        "An immense mirror is hanging against one wall,
        and stretches to the other end of the room, where
        various other sundry objects can be glimpsed dimly in
        the distance. ";

        if(global.newGame) {
            "An unoccupied telephone booth stands against the north wall. ";
        }
    }

    
    southwest = atSWEnd
    
;

+ Distant 'massive torches;smokey yellow;light;them'
    "The torches bathe the room in a smokey yellow light. "
;

+ Decoration 'sign; nearby'
    "The sign reads <q>Do not disturb the dwarves!</q> "
    decorationActions = [Examine, Read]
    readDesc = desc
;

+ Distant 'sundry objects; various other;; them'
    "If you want to exmaine them more closely, you'll need to go to the other end of the room. "
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
    
+ blackRodBundle: ObjPile 'bundle of rods; black another more; rod'
    "It's a bundle of black rods with stars on their ends, like
     the one you found in the Debris Room. "
    
    dispensedClass = blackRod
;

+ lampCollection: ObjPile 'collection of brass lanterns; more another; lamp lamps lantern'
    "It's a collection of brass lanterns like the one you
        used earlier. "
    dispensedClass = brassLantern
;

mirror2: MultiLoc, Fixture 'enormous mirror; immense vast'
    "It looks like an ordinary, albeit enormous, mirror. "
    
    locationList = [atNEEnd, atSWEnd]
;


/* 116 */
atSWEnd: Room, NoNPC 'At SW End' 'southwest end of the repository; sw'
   
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

+ repositoryGrate: Door 'steel grate; metal strong locked large ;lock gate grille'
    "It just looks like an ordinary steel grate. It is closed and locked. "
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

+ snakepit: Fixture 'pit of snakes; fierce green snake'
    "They're identical to the snake you saw in the Hall of the
     Mountain King -- and just as dangerous. "
    
    cannotTakeMsg = '{I} {can\'t} be serious. '
    cannotEnterMsg = cannotTakeMsg
    cannotBoardMsg = cannotTakeMsg
    lookInMsg = 'The pit is full of fierce green snakes. '
    checkDobjCount = "It would take you all day to count the snakes. ";
;

+ Decoration 'corner'
    "In one corner is a bundle of black rods with rusty marks on
        their ends.  In another corner is a large pile of velvet pillows. "
;

phonyBooth2: Distant 'phone booth; telephone' @atSWEnd
    "You can't examine it closely from here. "    
    newgame = true
    
    listenDesc()
    {
        if(phone2.isringing)
            "You can hear the phone ringing. ";
    }
;


phoneBooth2: Enterable 'phone booth' @atNEEnd
    "It contains a pay telephone like the one you found in
           the Rotunda. "
    
    game551 = true
    connector = phoneBooth2Door
    listenDesc()
    {
        if(phone2.isringing)
            "You can hear the phone ringing. ";
    }
;

phoneBooth2Door: DSDoor 'phone booth door' @phoneBooth2 @inPhoneBooth2
    
    isConnectorApparent = (phoneBooth2.isIn(room1))
    game551 = true
;

inPhoneBooth2: NoNPC, Room 'Inside the Phone Booth'
    "{I} {am} standing in a telephone booth at the side of
     the Repository.  Hung on the wall is an old pay telephone of
      ancient design, like the one you found in the Rotunda but
      in much better condition. "
        
    game551 = true
    south = phoneBooth2Door
    out asExit(south)
    myphone = phone2
    floorObj = pb2Floor
    
    roomAfterAction()
    {
        if(gDobj.ofKind(blackMarkRod) && !depositPointsAwarded && gDobj.location == self)
        {
            depositPointsAwarded = true;
            addToScore(gDobj.depositpoints, 'other tasks');
        }
        
        if(gDobj.ofKind(blackMarkRod) && depositPointsAwarded && contents.countWhich({o:
            o.ofKind(blackMarkRod)}) < 1)
        {
            depositPointsAwarded = nil;
            addToScore(-gDobj.depositpoints, 'other tasks');
        }   
    }
    
    depositPointsAwarded = nil
;

+ phone2: Phone 'old payphone; ancient pay; phone telephone receiver handset'
    desc()
    {
        "It's an old payphone of the same design as the one you
        saw earlier in the Rotunda, but in much better condition.
        A telephone cable runs down from the phone to the floor. ";
        if(!boobyWire.isIn(location))
            boobyWire.moveInto(location);
    }
    
    isringing = nil
    takemethod(actor) {  end_phone(); }
    
    // Don't do anything more after lifting receiver.
    answermethod() {}
    dialtonemethod() {}
    
    // If we attack the phone, it wakes the dwarves.
    dobjFor(Attack)
    {
        verify() {}
        action()
        {            
            "You've hit the jackpot!!  Hundreds of coins and slugs cascade from
            the telephone's coin return slot and spill all over the floor of
            the booth. ";
            end_dwarves();
        }
    }
    dobjFor(Break) asDobjFor(Attack)
    
    iobjFor(TakeFrom)
    {
        action()
        {
            if(gDobj == boobyWire)
            {                
                "{I} yank{s/ed} the cable out of the phone, and ... <.p>"; 
                end_phone();}
            else
                inherited();
        }
    }
;

pb2Floor: Floor 'floor'
    desc()
    {
        "It isn't quite as solid as the floor elsewhere in the
        Repository. ";
        if(!boobyCatch.isIn(inPhoneBooth2)) 
        {
            "You notice an odd-looking mechanism
            on the floor. ";
            boobyCatch.moveInto(inPhoneBooth2);
        }
        if(! boobyWire.isIn(inPhoneBooth2)) 
        {
            "A cable runs down from the telephone to the
            mechanism, but something tells you that it isn't just an
            ordinary telephone cable.  Something isn't right here! ";
            boobyWire.moveInto(inPhoneBooth2);
        }
    }
;

boobyWire: Fixture 'odd-looking cable; strane unusual;wire' @inPhoneBooth2
    desc()
    {
        "It looks rather odd, and you're not sure it's just a normal
        telephone cable.  It runs down from the phone to a kind of
        catch mechanism on the floor. ";
        boobyCatch.moveInto(inPhoneBooth2);
    }
   
    dobjFor(Pull) 
    {
        verify() {}
        action()
        {
            "You <<gVerbWord>> the cable out of the phone, and ... <.p>"; 
            end_phone();
        }
    }
    
    dobjFor(Yank) asDobjFor(Pull)
    
    dobjFor(Break)
    {
        verify() {}
        action()
        {
            "You manage to break the cable, and ... <.p>"; 
            end_phone();            
        }        
    }
    
    dobjFor(YankFrom)
    {
        verify()
        {
            if(gVerifyIobj not in (phone2, boobyCatch))
               inherited();
        }
            
        action() 
        {
            "{I} yank{s/ed} {the dobj} out of {the iobj} and...<.p>";
            end_phone();
        }           
    }   
;


boobyCatch: Fixture 'mechanism;odd-looking strange ;catch'
    "It's hard to say, but it appears to be some sort of catch
        mechanism holding the floor in place!  You have a very
        bad feeling about this.  I'd be very careful what you
        do here, because it appears that the dwarves have booby-trapped
        the booth! "
    
    newgame = true
    
    dobjFor(Kick)
    {
        verify() {}
        action()
        {
            "You give the mechanism a mighty kick, and ...<.p>";
            end_phone();
        }        
    }
    
    dobjFor(Attack)
    {
        verify() {}
        action()
        {
            "You strike the mechanism with a resounding blow, and ...<.p>"; 
            end_phone();           
        }
    }
    
    dobjFor(Break) asDobjFor(Attack)
    
    iobjFor(YankFrom)
    {
        action()
        {
            if(gDobj == boobyWire)
            {
                "You yank the cable out of the mechanism, and ... <.p>";
                end_phone();
            }
            else
                inherited();
        }
    }    
;

win()
{
    finishGameMsg(ftVictory, [finishOptionUndo, finishOptionFullScore]);
}


cylindricalRoom: Room 'Cylindrical Room' 'cylindrical room; small'
    "You are in a small cylindrical room with very smooth
        walls and a flat floor and ceiling.  There are no
        exits visible anywhere." 
    
    noExits = 'absolutely none visible anywhere'
    
    wordcount = 0
    
    roomAfterAction()
    {
        if(gActionIs(SayAction))
        {
            "If you want to use a magic word, just type it in! ";
            exit;
        }
        
//        if((gAction.ofKind(MagicWord) 
//#ifdef DEBUG
//            || (gActionIs(GoOut))
//#endif
//            )
           if(wordtest(gAction))
            return;
        "Oops! That felt wrong! ";
        resetwords();
    }
    
    wordlist = []
    optwordlist = []
    
    /* Build a list of magic words for subsquent checking against. */
    buildWordList()
    {
        local numprop;
//            ,maxcount;
        // Decide which properties to use for the word count.
        // In the 701+ point mode, we use the 701+ numbering only if the
        // steel door was unlocked.
        if (defined(transRoomDoor) && global.game701p && transRoomDoor.isunlocked)     
        {
            numprop = &omegaps701p_order;
//            maxcount = &numactwords701p;
        }
        
        else if (global.game701) 
        {
            numprop = &omegaps701_order;
//            maxcount = &numactwords701;
        }
        else if (global.game580) 
        {
            numprop = &omegaps580_order;
//            maxcount = &numactwords580;
        }
        else {
            numprop = &omegapsical_order;
//            maxcount = &numactwords;
        }
        
        local mVec = new Vector(); // magic words
        local oVec = new Vector(); // optional magic words
        
        /* Run the garbage collector to ensure no spurious instances are left in memory. */
        t3RunGC();
        for(local mw = firstObj(MagicWord) ; mw; mw = nextObj(mw, MagicWord))
        {
            local ord = mw.(numprop);
            /* 
             *   Here we add an additional check, the third condition, to prevent spurious
             *   duplicates of magic words getting into the list, as was mysteriously happening with
             *   plugh.
             */
            if(ord && ord > 0 && mVec.indexWhich({x:x.(numprop) == ord}) == nil)
                mVec.append(mw);
            else if (ord && ord < 0)
                oVec.append(mw);
        }
        wordlist = mVec.sort(SortAsc, {a, b: a.(numprop) - b.(numprop)}).toList();
        optwordlist = oVec.sort(SortAsc, {a, b: a.(numprop) - b.(numprop)}).toList();
        
    }
    
    responseList: CyclicEventList
    {
        [
            '\n(You don\'t need to use that word here.)\n',
            '\n(That won\'t help -- there\'s no natural way out of here.)\n ',
            '\n(You\'ll have to use your wits better than that!)\n',
            '\n(You sense yourself floundering -- perhaps because this room has such a 
            speculiar vibe.)\n'       
        ]
    }
;

+ Decoration 'very smooth walls;;;them'
;

/* Resets words in the cylindrical room. */
resetwords()
{   
//    local i;
//    for(i = firstObj(MagicWord); i != nil; i = nextObj(i, MagicWord)) 
//    {
//        i.tused = -2;
//        i.endsaid = nil;
//    }
    cylindricalRoom.wordcount = 0;
}

/*
 *  wordtest(word);
 *  Whenever a magic word is said in the Cylindrical Room, the code
 *  checks the word's omegapsical_order.  If it is non-nil, it looks
 *  at the preceding word's endsaid and tused properties to see if the
 *  word was used in the proper sequence.  If so, it increments the
 *  wordcount value. Otherwise, it resets everything.  If the wordcount
 *  value is equal to the number of words in the game (global.numwords)
 *  then exit!  Otherwise, continue.  This will need alteration in some
 *  extensions of the 550-point version, such as the 580-point version.
 */
wordtest(word)
{
    local maxcount = cylindricalRoom.wordlist.length();    
    local numprop, ok = nil;
    // Decide which properties to use for the word count.
    // In the 701+ point mode, we use the 701+ numbering only if the
    // steel door was unlocked.
    if (defined(transRoomDoor) && global.game701p && transRoomDoor.isunlocked)     
    {
        numprop = &omegaps701p_order;
//        maxcount = &numactwords701p;
    }
    
    else if (global.game701) 
    {
        numprop = &omegaps701_order;
//        maxcount = &numactwords701;
    }
    else if (global.game580) 
    {
        numprop = &omegaps580_order;
//        maxcount = &numactwords580;
    }
    else {
        numprop = &omegapsical_order;
//        maxcount = &numactwords;
    }
    
    if((word.(numprop) == nil)) 
    {
        /* 
         *   The TADS 2 port has this undo() here, with out even checking for a SystemAction, which
         *   seems like a very bad idea. Also, the player is given no in-game clue what they're
         *   meant to do here - it's a classic "Read my mind" puzzle, which is surely unacceptable.
         *   So instead actions other than magic words should be carried out but met with responses
         *   that might give some kind of clue to the player.
         */
           
//        if (undo())
//        {
//            gRoom.lookAroundWithin();
//            //            scoreStatus(global.score, global.turnsofar);
//        }
//        else
//            "No more undo information is available. ";
        
        if(word.ofKind(SystemAction) || word == Look)
            return true;
      
        // Allow OUT to escape the chamber in debugging mode. */        
#ifdef __DEBUG
        if(word == GoOut)
        {
            cylindricalRoom.wordcount = maxcount; 
            return true;            
        }
#endif 
        else cylindricalRoom.responseList.doScript();       
        return true;
    }
    else if(word.(numprop) == 1) 
    {
        resetwords();  // Starting over.
        cylindricalRoom.wordcount = 1;
        ok = true;
        "Ok.\n";
    }
    // prevent optional words from being used more than once. 
//    else if(word.endsaid) 
//    {
//        "You've already used that word. You'd best start over. ";
//    }       
    else if (word == GoOut)
//        cylindricalRoom.wordcount = global.(maxcount); 
          cylindricalRoom.wordcount = maxcount; 
    /* 
     *   The logic here is different from that of the TADS 2 port, which iterates over all the magic
     *   words in the game each time to check that the one just used is in right omegascipal order.
     *   In this TADS 3 port we pre-build a sorted list of magic workds and check against that
     *   instead.
     */
    else 
    { 
        if(word.(numprop) == -(cylindricalRoom.wordcount + 1))
            ok = true;
        else
        {            
            cylindricalRoom.wordcount++;
            if(word == cylindricalRoom.wordlist[cylindricalRoom.wordcount])
                ok = true;
        }
        if(ok)
            "Okay\n";
        else
            resetwords();
    }
  
    if(cylindricalRoom.wordcount == maxcount) 
    { 
        local i;
        global.dont_rescind = true; // don't rescind deposit points.
        // suppress all the extra moveInto code for efficiency
        global.extendMoveInto = nil;
        
        /* 
         *   move every wrongly-deposited treasure into the Troll's treasure room, and move all
         *   other items in the surface areas to the treasury (which is not a game location).
         */
        global.wrongtreasloc = 0;
        global.trolltolls = 0;
        for(i = firstObj(Thing); i != nil; i = nextObj(i, Thing)) {
            /* look for treasure items which aren't correctly deposited
               (plus discharged pendants in non-nil locations other than
               the player) 
            */
            if ((i.ofKind(Treasure) && !i.awardedpointsfordepositing) 
                || (i == tarnishedPendant) || (i == dullPendant)) 
            {
                // exclude the charged pendants if the discharged pendants
                // exist
                if ((i == pendant) && (tarnishedPendant.location != nil))
                    continue;
                if ((i == pendant2) && (dullPendant.location != nil))
                    continue; 
                // exclude the discharged pendants if they don't exist,
                // or if they're in the player's possession
                if ((i == tarnishedPendant) || (i == dullPendant)) {
                    if ((i.location == nil) || i.isIn(gPlayerChar))
                        continue;
                }

                // exclude deleted treasures, or not-yet-found treasures
                // in the 701+ point extensions.
                if (i.deleted || (i.bonustreasure && !i.bonusFound))
                    continue;
                if (i.isIn(trollTreasure))
                    global.trolltolls++;
                else {
                    i.moveInto(trollTreasure);
                }
                global.wrongtreasloc++; 
            }
            if (i.isFixed) continue;
            if((i.location && i.location.ofKind(Outside)) || (i.location == safe)) 
                i.moveInto(nil);
        }
        // turn on the moveInto extensions in case we still need them
        global.extendMoveInto = true;
        /* In 701-point game, move keys into pantry (red herring) */
        if(global.game701) {
            smallKey.moveInto(pantry);
            setOfKeys.moveInto(pantry);
        }
        P(); I(); "<i>Foof!</i><.reveal exitcylinder>"; P();
        gPlayerChar.moveInto(atEndOfRoad);
        gRoom.lookAroundWithin();
        global.dont_rescind = nil; // in case pendants are dropped

        addToScore(global.escapepoints, 'escaping from the cylinder room');
    }
    else if (cylindricalRoom.wordcount == 0) "Nothing happens.\n";
    // This should only happen if something resets the count.

    return true; // Don't finish the normal action routine, since it
                 // will probably print "Nothing happens" again,
                 // or do something even more inappropriate.
}

edgeOfPool: Room 'Edge of Pool'
    desc()
    {
        "You find yourself sitting on the edge of a pool of water in
         a vast chamber lit by dozens of flaring torches. ";
        
        if(wumpi.phase > 0 && greenUpperTransRoom.isdotroom)
            horror();
        else
            hurrah();          
        
        win();
    }
    
    noExits = 'None needed'
;

plungeToPond()
{
    local i;
    // Look for any more treasures which should go to the Troll.
    for(i = firstObj(Thing); i != nil; i = nextObj(i, Thing)) 
    {
        if ((i.ofKind(Treasure) && !i.awardedpointsfordepositing) ||         
            (i is in (tarnishedPendant, dullPendant))) 
        {
            // exclude treasures already in the possession of the
            // Troll
            if (i.isIn(trollTreasure)) 
                continue;
            // exclude the charged pendants if the discharged pendants
            // exist
            if ((i == pendant) && (tarnishedPendant.location != nil))
                continue;
            if ((i == pendant2) && (dullPendant.location != nil))
                continue; 
            // exclude the discharged pendants if they don't exist,
            // or if they're in the player's possession
            if ((i == tarnishedPendant) || (i == dullPendant)) {
                if ((i.location == nil) || i.isIn(gPlayerChar))
                    continue;
            }
            // exclude deleted treasures, or not-yet-found treasures
            // in the 701+ point game.
            if (i.deleted || (i.bonustreasure && !i.bonusFound))
                continue;
            // special handling for discharged pendants
            if (i == pendant) {
                if (tarnishedPendant.isIn(gPlayerChar))
                    continue;
            }
            else if (i == pendant2) {
                if (dullPendant.isIn(gPlayerChar))
                    continue;
            }
            else { 
                global.wrongtreasloc++; 
                i.moveInto(trollTreasure);
            }
        }
    }
    
    
    "You plunge into the stream and are carried down into total blackness.\n";
    P();
    "Deeper";
    "\n    \tand";
    "\n    \t\tdeeper";
    "\n    \t\t\tyou";
    "\n    \t\t\t\tgo,";
    "\n    \t\t\t\t\ \ down";
    "\n    \t\t\t\t\ \ \ into";
    "\n    \t\t\t\t\ \ \ the";
    "\n    \t\t\t\t\ \ very";
    "\n    \t\t\t\tbowels";
    "\n    \t\t\tof";
    "\n    \t\tthe";
    "\n    \tearth,";
    "\n until";
    "\n your";
    "\n     \tlungs";
    "\n     \t\tare";
    "\n     \t\t\taching";
    "\n     \t\t\t\twith";
    "\n     \t\t\t\t\ \ the";
    "\n     \t\t\t\t\tneed";
    "\n     \t\t\t\t\t\ \ for";
    "\n     \t\t\t\t\t\ \ \ fresh";
    "\n     \t\t\t\t\t\ \ \ air.";
    "\n     \t\t\t\t\t\ \ \ Suddenly,";
    "\n     \t\t\t\t\t\ \ with";
    "\n     \t\t\t\t\t\ a";
    "\n     \t\t\t\t\t\ \ violent";
    "\n     \t\t\t\t\t<i>splash!!</i>";
    P();
    
}

hurrah()
{
    addToScore(global.finalepoints, 'winning');
    if (global.game701)
        "Despite your dramatic entrance, your presence is not immediately
        noticed - as if everyone is too preoccupied with what they are
        doing.  You take advantage of this to have a good look round. ";
    P();
    "The floor is covered with thick layers of precious Persian rugs!";
    P();
    if(global.game701)
        "Rare coins, bars of silver, lumps of gold and platinum and gold
        rings are strewn carelessly about!";
    else
        "Rare coins, bars of silver, and lumps of gold and platinum are
        strewn carelessly about!";
    P();
    "There are diamonds, rubies, sapphires, emeralds, opals, pearls, and
    fabulous sculptures and ornaments carved out of jade and imperishable
    crystal resting on display shelves, along with rare Ming vases and
    ancient Indian turquoise beads!";
    if(global.game580) {
        P();
        "Sitting on one display shelf are a collection of rare stamps, and 
         a disk labelled \"Adventure Source Code\"!";
    }
    if (global.game701) {
        P();
        "A large pile of crystal balls is stacked against one wall.  You
        look into a few of them, fascinated by the scenes they show.  In
        one, you see the Troll's treasure chamber, lit by an orange glow
        and stacked with priceless items of all descriptions";
        if (global.wrongtreasloc > 0) {
            ": "; P();
            
            P();
        }
        else
           ". ";
        if (global.wrongtreasloc == 1)
            "(You notice that the treasure which
            you failed to deposit correctly has gone there instead of
            here, losing you points.";
        else if (global.wrongtreasloc > 1)
            "(You notice that the <<global.wrongtreasloc>> treasures which
            you failed to deposit correctly have all gone there instead of
            here, losing you points.";
        if (global.wrongtreasloc > 0) {
            local totalspend = global.trolltolls + global.vendingtreasures;
            if (totalspend == 1) {
                if(global.trolltolls)
                    " This includes the treasure you paid to the Troll.) ";
                else
                    " This includes the coins you used in the Vending 
                    Machine.) ";
            }
            else if (totalspend > 1) {
                " This includes the <<totalspend>> treasures which were used
                for payments. ";
            }
            else
                ") ";
        }
        "Another ball shows a strange ruined city, illuminated
        by three moons and the golden glow of an aurora which fills the 
        entire sky!  A third ball shows a large circular room, lit by a
        dim glow - and full of sleeping Wumpi. ";
    }
    P();
    "A flotilla of ruby-encrusted toy boats is floating in the pool of
    water beside you!";
    P();
    "A network of golden chains supports a fantastic Iridium crown!";
    P();
    "There is a display case on the wall filled with a fantastic selection
    of magical swords, which are singing \"Hail to the Chief\" in perfect
    pitch and rhythm!";
    if (global.game701) {
        P();
        "A second case contains a collection of about ten elven swords, all
        gleaming like the one you took from the anvil!
        A third, much larger case holds over 130 elven crowns, all
        made of gold or mithril silver and encrusted with valuable 
        stones of all descriptions!  ";
        if (global.game701p) {
            "A plaque, affixed to the front of the cabinet, states that 114
            of the crowns were found in a recently-discovered burial vault.
            A further two vaults are believed to exist, but have not yet
            been excavated. ";
            P();
        }
        "The Mountain King is searching the case, muttering
        to himself.  You hear him say: \"I hope he realizes that the
        treasures go to the Troll when they're not left in a 'safe' 
        place.\"  He then grabs one of the crystal balls and looks into it. ";
        if (crown.awardedpointsfordepositing)
            "\"Hmmm.  I can't see it in the Troll's treasure chamber.\"  He
            looks in the case again and says: \"Ah yes! Here it is! \" He 
            retrieves his rightful property from the case, puts it on and 
            starts adjusting it in front of a mirror.  \"Hmmm.  A little 
            further to the left, perhaps ... \" ";
        else
            "\"Oh no! The Troll has it.  No use asking for it - he'd want
            ten crowns in return.\"  He then starts trying on different 
            crowns.  \"Hmmm.  Too small.  No, too large ... \"  ";

        P();
        "Off to one side there is a large closet containing silken cloaks,
        ruby slippers, and many other priceless articles of clothing! ";
    }
    P();
    "There are a dozen friendly little dwarves in the room, displaying
    their talents by deftly juggling hundreds of golden eggs!";
    P();
    "A large troll, a gigantic ogre, and a bearded pirate are tossing
    knives, axes, and clubs back and forth in a friendly demonstration
    of martial skill!";
    P();
    "A horde of cheerful little gooseberry goblins are performing
    talented acrobatics to an appreciative audience composed of a dragon,
    a large green snake, a cute little bird (which is sitting, unmolested,
    on the snake's head), a peaceful basilisk, and a large Arabian Djinn.";
    if(global.game701) {
        // Deleted reference to the Wumpus - they don't belong at Red level.
        P();
        "A Gnome is playing ancient and valuable musical
        instruments, filling the air with beautiful music.  Nearby a large
        black dog is sleeping peacefully. ";
    }
    P();
    "Everyone turns and sees you, and lets out a heart-warming cheer
    of welcome! ";
    if(PendantItem.classcount(gPlayerChar) > 0) {
        local pendantword;
        if(PendantItem.classcount(gPlayerChar) == 1) {
            pendantword = 'pendant';
//            pendantpronoun = 'it';
        }
        else {
            pendantword = 'pendants';
//            pendantpronoun = 'them';
        }
        "Then the Mountain King spots your Transindection <<pendantword>>,
        and shouts <q>Where did you find the <<pendantword>>?</q>  You stutter
        and stammer, but then manage to regain your composure and tell the King
        what you found. ";
    }
    else if ((global.game701p && transRoomDoor.isunlocked) && 
    (PendantItem.classcount(gPlayerChar) == 0)) {
        "You see a flicker of consternation on the face of the Mountain
        King, and once again he looks into the crystal ball to spy upon the
        Troll's treasure chamber.  He turns to the Troll and shouts <q>How did 
        you come by the Transindection pendants?</q>  The Troll points to 
        you, and the King seems to know exactly what he means.  He asks you, 
        more quietly this time:  <q>Where did you find the pendants?</q>  You 
        tell him everything. ";
    }
    if (global.game701p && transRoomDoor.isunlocked) {
        "When he learns that the Upper Transindection 
        Chambers were working, he looks very worried indeed";
        if(greenUpperTransRoom.isdotroom)
            if(greenMaintenanceRoom.seen)
                ", but when you tell him how you used the Topaz to enter the
                Maintenance Rooms, he congratulates you and says
                <q>Well done - Eldrand may have failed, but we can now complete
                his mission in complete safety!</q> ";
            // added because it is now possible to get here without
            // entering the Maintenance Room.  However, the means to do so
            // has been obtained...
            else
                ", but when you tell him how you got hold of the 
                Eldrand-Fitzgerald Topaz, he congratulates you and says
                <q>Well done!  I'm almost certain that we can get into the
                Maintenance rooms now.  We'll be able to complete
                Eldrand's mission in complete safety!</q> ";
        else
            ", but when you 
            reassure him that you have disabled the Chambers, he congratulates 
            you! ";
        "Everyone lets out a loud <q>Hurrah!</q> ";

        P();

        "The rest of your day is occupied with discreet Transindection
        tours, conducted with the aid of your pendants and gold rings
        worn by your companions.  Rods are spun near various plaques,
        the Zarkalon tower is visited and the transmutation of lead to 
        platinum is demonstrated.  Blue-level display boards are read, and
        plans are made for the excavation of the remaining burial chambers at 
        Red level. But that's the start of a much longer story ... ";
    }
    P();if (global.game701)
        "Despite your dramatic entrance, your presence is not immediately
        noticed - as if everyone is too preoccupied with what they are
        doing.  You take advantage of this to have a good look round. ";
    P();
    "The floor is covered with thick layers of precious Persian rugs!";
    P();
    if(global.game701)
        "Rare coins, bars of silver, lumps of gold and platinum and gold
        rings are strewn carelessly about!";
    else
        "Rare coins, bars of silver, and lumps of gold and platinum are
        strewn carelessly about!";
    P();
    "There are diamonds, rubies, sapphires, emeralds, opals, pearls, and
    fabulous sculptures and ornaments carved out of jade and imperishable
    crystal resting on display shelves, along with rare Ming vases and
    ancient Indian turquoise beads!";
    if(global.game580) {
        P();
        "Sitting on one display shelf are a collection of rare stamps, and 
         a disk labelled <q>Adventure Source Code</q>!";
    }
    if (global.game701) {
        P();
        "A large pile of crystal balls is stacked against one wall.  You
        look into a few of them, fascinated by the scenes they show.  In
        one, you see the Troll's treasure chamber, lit by an orange glow
        and stacked with priceless items of all descriptions";
        if (global.wrongtreasloc > 0) {
            trollTreasure.lookAroundWithin();            
            P();
        }
        else
           ". ";
        if (global.wrongtreasloc == 1)
            "(You notice that the treasure which
            you failed to deposit correctly has gone there instead of
            here, losing you points.";
        else if (global.wrongtreasloc > 1)
            "(You notice that the <<global.wrongtreasloc>> treasures which
            you failed to deposit correctly have all gone there instead of
            here, losing you points.";
        if (global.wrongtreasloc > 0) {
            local totalspend = global.trolltolls + global.vendingtreasures;
            if (totalspend == 1) {
                if(global.trolltolls)
                    " This includes the treasure you paid to the Troll.) ";
                else
                    " This includes the coins you used in the Vending 
                    Machine.) ";
            }
            else if (totalspend > 1) {
                " This includes the <<totalspend>> treasures which were used
                for payments. ";
            }
            else
                ") ";
        }
        "Another ball shows a strange ruined city, illuminated
        by three moons and the golden glow of an aurora which fills the 
        entire sky!  A third ball shows a large circular room, lit by a
        dim glow - and full of sleeping Wumpi. ";
    }
    P();
    "A flotilla of ruby-encrusted toy boats is floating in the pool of
    water beside you!";
    P();
    "A network of golden chains supports a fantastic Iridium crown!";
    P();
    "There is a display case on the wall filled with a fantastic selection
    of magical swords, which are singing \"Hail to the Chief\" in perfect
    pitch and rhythm!";
    if (global.game701) {
        P();
        "A second case contains a collection of about ten elven swords, all
        gleaming like the one you took from the anvil!
        A third, much larger case holds over 130 elven crowns, all
        made of gold or mithril silver and encrusted with valuable 
        stones of all descriptions!  ";
        if (global.game701p) {
            "A plaque, affixed to the front of the cabinet, states that 114
            of the crowns were found in a recently-discovered burial vault.
            A further two vaults are believed to exist, but have not yet
            been excavated. ";
            P();
        }
        "The Mountain King is searching the case, muttering
        to himself.  You hear him say: \"I hope he realizes that the
        treasures go to the Troll when they're not left in a 'safe' 
        place.\"  He then grabs one of the crystal balls and looks into it. ";
        if (crown.awardedpointsfordepositing)
            "\"Hmmm.  I can't see it in the Troll's treasure chamber.\"  He
            looks in the case again and says: \"Ah yes! Here it is! \" He 
            retrieves his rightful property from the case, puts it on and 
            starts adjusting it in front of a mirror.  \"Hmmm.  A little 
            further to the left, perhaps ... \" ";
        else
            "\"Oh no! The Troll has it.  No use asking for it - he'd want
            ten crowns in return.\"  He then starts trying on different 
            crowns.  \"Hmmm.  Too small.  No, too large ... \"  ";

        P();
        "Off to one side there is a large closet containing silken cloaks,
        ruby slippers, and many other priceless articles of clothing! ";
    }
    P();
    "There are a dozen friendly little dwarves in the room, displaying
    their talents by deftly juggling hundreds of golden eggs!";
    P();
    "A large troll, a gigantic ogre, and a bearded pirate are tossing
    knives, axes, and clubs back and forth in a friendly demonstration
    of martial skill!";
    P();
    "A horde of cheerful little gooseberry goblins are performing
    talented acrobatics to an appreciative audience composed of a dragon,
    a large green snake, a cute little bird (which is sitting, unmolested,
    on the snake's head), a peaceful basilisk, and a large Arabian Djinn.";
    if(global.game701) {
        // Deleted reference to the Wumpus - they don't belong at Red level.
        P();
        "A Gnome is playing ancient and valuable musical
        instruments, filling the air with beautiful music.  Nearby a large
        black dog is sleeping peacefully. ";
    }
    P();
    "Everyone turns and sees you, and lets out a heart-warming cheer
    of welcome! ";
    if(PendantItem.classcount(gPlayerChar) > 0) {
        local pendantword;
        if(PendantItem.classcount(gPlayerChar) == 1) {
            pendantword = 'pendant';
//            pendantpronoun = 'it';
        }
        else {
            pendantword = 'pendants';
//            pendantpronoun = 'them';
        }
        "Then the Mountain King spots your Transindection <<pendantword>>,
        and shouts <q>Where did you find the <<pendantword>>?</q>  You stutter
        and stammer, but then manage to regain your composure and tell the King
        what you found. ";
    }
    else if ((global.game701p && transRoomDoor.isunlocked) && 
    (PendantItem.classcount(gPlayerChar) == 0)) {
        "You see a flicker of consternation on the face of the Mountain
        King, and once again he looks into the crystal ball to spy upon the
        Troll's treasure chamber.  He turns to the Troll and shouts <q>How did 
        you come by the Transindection pendants?</q>  The Troll points to 
        you, and the King seems to know exactly what he means.  He asks you, 
        more quietly this time:  <q>Where did you find the pendants?</q>  You 
        tell him everything. ";
    }
    if (global.game701p && transRoomDoor.isunlocked) {
        "When he learns that the Upper Transindection 
        Chambers were working, he looks very worried indeed";
        if(greenUpperTransRoom.isdotroom)
            if(greenMaintenanceRoom.seen)
                ", but when you tell him how you used the Topaz to enter the
                Maintenance Rooms, he congratulates you and says
                <q>Well done - Eldrand may have failed, but we can now complete
                his mission in complete safety!</q> ";
            // added because it is now possible to get here without
            // entering the Maintenance Room.  However, the means to do so
            // has been obtained...
            else
                ", but when you tell him how you got hold of the 
                Eldrand-Fitzgerald Topaz, he congratulates you and says
                <q>Well done!  I'm almost certain that we can get into the
                Maintenance rooms now.  We'll be able to complete
                Eldrand's mission in complete safety!</q> ";
        else
            ", but when you 
            reassure him that you have disabled the Chambers, he congratulates 
            you! ";
        "Everyone lets out a loud <q>Hurrah!</q> ";

        P();

        "The rest of your day is occupied with discreet Transindection
        tours, conducted with the aid of your pendants and gold rings
        worn by your companions.  Rods are spun near various plaques,
        the Zarkalon tower is visited and the transmutation of lead to 
        platinum is demonstrated.  Blue-level display boards are read, and
        plans are made for the excavation of the remaining burial chambers at 
        Red level. But that's the start of a much longer story ... ";
    }
    P();
}

horror()
{
   P();
    "But something is wrong!  A battle is raging around you.  On one 
    side you see a poorly armed band of dwarves, elves and Gnomes.  On the 
    other side there is a large army of elves, all wearing uniforms made from a
    silvery fabric.  Your attention is also drawn to the gleaming swords which 
    they are all wielding, to the crowns atop their heads, and to the gold 
    rings which many of them are wearing on their fingers.  It is also clear 
    that all of them are winning easily - apparently without any 
    casualties on their side!  Axes, knives and swords either bounce 
    harmlessly off the uniforms, or veer away from the elves as if repelled
    by a powerful force-field. ";

    P();
    "You try to hide, but it is to no avail.  A large elf strikes you down
    with his sword, and you fall to the ground, mortally wounded. ";

    P();
    "As you lie dying, the remnants of the poorly armed band flee in terror.
    The elf comes up to you, and 
    exclaims, <q>A Cavernizer!  Well, the cave is now outbounded 
    from ... </q>  He frowns, mutters something about language drift, then puts 
    a red ring on his finger. ";
    
    P();
    "<q>A Spelunker!  Well, the cave is now out of bounds for humans like you.
    But it seems that we have to thank someone like you for showing us the
    way in.</q> He observes your reaction";
    if(PendantItem.classcount(gPlayerChar) == 1)
    " and notices your pendant. ";
    else if(PendantItem.classcount(gPlayerChar) > 1)
    " and notices your pendants. ";
    else ". ";
    "<q>I do believe that <i>you</i> were our intruder!  Well, you caused us all a 
    lot of trouble, but we were very interested to find out how the Wumpi
    managed to come back from Red level.  So interested, in fact, that we
    paid them to clear a path to the Upper Transindection Chamber.  And the 
    rest is history.  Welcome to the New Order!</q> ";
    P();
    "Before you lose consciousness, your mind is full of \"if only\"s. ";
    P();
    "If only ... I'd managed to complete at least part of Eldrand's mission. 
    Disabling the Upper Transindection Chambers would have been enough to 
    thwart the Elves. ";
    //N.B. the following code sections are now accessible again, due to the
    //provision of a second battery pack at White level.  It is no longer
    //necessary for the maintenance rooms to be visited for this purpose.
    if(!manual.moved) {
        P();
        "If only ... I'd searched the Control Room more thoroughly.  I'm sure 
        I could have found something useful there. ";
    }
    else if(!manual.isread) {
        P();
        "If only ... I'd read the Control Room manual. ";
    }
    else if(!blueMaintenanceRoom.seen) {
        P();
        "If only ... I'd found a way to use that Topaz to get into the
        Maintenance Rooms.  The damage looked very slight. ";
    }
    P();
    "But \"if only\"s won't do.  Your foolish meddling has completely wrecked 
    the balance of Colossal Cave.  The glass ball at Green level tried to warn
    you, but you did nothing about it.  Now the Green-level elves have taken 
    over one Level already, and others will likely fall in due course!   
    There's nothing we can do about it now, and no hope that Adventurers will 
    ever again be allowed into the cave.  So I'm rescinding all your game 
    points!  Get out! Out!!!!!  OUT!!!!!!!!!!!  
    OUT!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!";
    P();
    local penalty = -libScore.totalPoints;
    addToScore(penalty, 'for causing a total disaster');
    
    
}