#charset "us-ascii"

#include <tads.h>
#include "advlite.h"



/* 9 */
pole: Thing 'wooden pole' @saltMarshEdge
    "It's just a simple wooden pole<<if !moved>>, stuck in the mud. {I} {can} probably take
    it<<end>>. "
        
    game551 = true
    mass = 2
    
    
    islong = true
    initSpecialDesc = "A wooden pole has been stuck in the mud here. "
    
    fromloc = saltmud
    
//    verDoSpinOver(actor,io) = {} // attempt to spin over fissure
;

/* 46 */
flowers: CanPick, Thing 'beautiful flowers; yellow blue wild attractive;;them' @oceanVista
    desc()
    {
        if (! bees.arefed)
            "I don't really know what species they are, but they are
            attractive blue and yellow flowers.  ";
        else
            "The bees are swarming around the flowers, and {i} {can't} get
            close to them now! ";
    }
    game551 = true
    mass = 1
    
    isFixed = bees.arefed
    
    smellDesc = "The fresh flowers have a fragrant scent. "
    
    specialDesc = "The bees are eagerly swarming over the fresh flowers, collecting
        nectar to take back to the hive. "
    
    useSpecialDesc = bees.arefed            
    
    //    verDoCount(actor) = {self.verDoSmell(actor);}
    //    doCount(actor) = {
    //        "You have roughly 20 flowers. ";
    //    }
    
    checkReach(actor)
    {
        if(bees.arefed)
            "The hum of the bees rises to an angry buzz as {i}
            move{s/d} towards the flowers. ";
    }    
    
    actionDobjCount = "You have roughly 20 flowers. "
    
    canFeedWithMe = true
;


/* 71 */
// Not a treasure in this implementation - the wine
              // in the cask is now the treasure.
cask: LiquidContainer 'oaken cask; oak wooden wood' @ledgeAbovePinnacles      
    game551 = true
    mass = 3
    

    islarge = true  // too large to go into the safe
    contName = "cask" 

    
/* if the plant is small, water it twice */
    dobjFor(PourOnto)
    {
        action()
        {
            if(hasWater && gIobj == plant && plant.size == 0)
            {
                inherited();
                hasWater = true;
                inherited();                    
            }
            else
                inherited();
        }
    }
    
    // Code for drinking wine from the container.  The adventurer
    // ends up somewhere, with only the lamp and axe; other stuff is
    // dropped in the top location.  Embellishments added in the TADS
    // port are:  the lucky clover also ends up with the adventurer, and
    // having the clover stops you from ending up in a maze.  All pendants
    // stay on if worn.
    //
    // Note that the general liquidcont.verDoDrink method prevents this code
    // from being called in some circumstances (e.g. during the player's
    // encounters with Wumpi.)

    winocode
    {
        local toploc = gRoom;
        local newloc,inv,o,i,l,newturns;
        "The wine goes right to your head.  You reel around in a
        drunken stupor and finally pass out.  You awaken with a
        splitting headache, and try to focus your eyes.... <.p>";
        gPlayerChar.health = (gPlayerChar.health*80)/100;
        if(gPlayerChar.health < 20) gPlayerChar.health = 20;
        
        if(toploc.ofKind(OutsideRoom))
            newloc = inForest1;
        
        else if (toploc.wino_trollstop && !(troll.location == nil))
            newloc = atForkInPath; // player blocked by troll
                           // N.B a drunken player loses the slippers and is
                           // incapable of using the boat, so
                           // this condition applies in the areas of the
                           // Winery, Crystal Palace and Lost River.
        else if (clover.isIn(gPlayerChar)) 
        {
            newloc = cloakPits;
        }
        else 
        {
            if(rand(100) < 15) 
                newloc = alikeMaze9;
            else if(rand(100) < 25) 
                newloc = differentMaze4;
            else newloc = cloakPits;
        }
        if (brassLantern.isIn(gPlayerChar) && (brassLantern.fuelLevel > 0))
            brassLantern.makeLit(true);
        // shorten the lamp life
        if (brassLantern.fuelLevel > 25 && brassLantern.isLit) 
        {
            newturns = brassLantern.fuelLevel -
            rand(brassLantern.fuelLevel)/ 10;
            if (newturns < 25) newturns = 25;
            brassLantern.setLife(newturns);
        }
        
        inv = gPlayerChar.contents;
        l = inv.length;
        for (i = 1; i <= l; i++) {
            o = inv[i];
            if (o.ofKind(PendantItem) && o.wornBy == gPlayerChar) 
            continue;
            if (o is in (brassLantern, axe, clover))
                o.moveInto(newloc);
            else
                o.moveInto(toploc);
        }
        // close the 550-point safe
        // TO DO Add once this object has been implemented
//        InSafe.makeOpen(nil);
//        InSafe.out = nil;
        // move the player
        gPlayerChar.travelVia(newloc);
    }
;



/* 80 */
// This item was stolen from Funadv.  Its use is somewhat surprising, but
    // it is in keeping with the original 350-point game.
coal: Thing 'bag of coal;;coals' @hallOfIce
    "It's just a small bag of coal.  I expect it will be useful for something, though. "
    game551 = true
    
    dobjFor(TakeFrom)
    {
        verify()
        {
            if(gVerifyIobj == self)
                illogical('{I}\'d better leave the coal in the bag. ');
            else
                inherited;                         
        }
    }
    
    cannotPutInMsg = 'The bag is full of coal and there\'s no room for anything else. '
    
    lookInMsg = '{I} {see} coal in the bag. '  
;

/* The following are contliquids for the 551-point version. */

/* 82 */
waterInTheCask: ContLiquid 'water in the cask; in-cask'
    "It looks like ordinary water to me. "
    game551 = true
    mycont = cask
    myflag = &hasWater    
    aName = 'water'    
    theName = "the in-cask water"   
;

/* 84 */
oilInTheCask: ContLiquid 'oil in the cask; in-cask'
    "It looks like ordinary oil to me. "
    
    game551 = true
    mycont = cask
    myflag = &hasOil    
    aName = 'oil'   
    theName = "the in-cask oil"    
;

/* 86 (wine_in_the_cask) is a treasure item */


/* 90 */
/* Most possessions shrink or expand with the player, but the tiny key
   must stay the same size. */

/* seen when large */
tinyKey: Key 'tiny brass key; minute'
    "It's a minute brass key, for a tiny lock."    
    game551 = true
    mass = 1    
    getFacets = [smallKey, largeKey]
;

/* seen when normal size */
smallKey: Key 'small brass key' @shelf
    "It's a small brass key. It looks larger than when
    you took it.  You realize that you've shrunk (together
    with your possessions), but the key has stayed the same
    size!"
    
    game551 = true
    mass = 1    
    getFacets = [tinyKey, largeKey]
//    actualLockList = [smallDoor]
;

/* seen when small */
largeKey: Key 'large brass key'
    "It's a large brass key. It looks far larger than when
    you took it.  You realize that you've shrunk (together
    with your possessions), but the key has stayed the same
    size! "
    
    game551 = true
    mass = 2
    getFacets = [tinyKey, smallKey]
;

/* 95 */
slugs: Coin 'lead slugs;;;them'
    "They look similar to coins, and have a crude design stamped
        on them.  Maybe they are actually used as a form of currency 
        within the cave. "
    
    game551 = true
    mass = 3    
    initSpecialDesc = "There are some lead slugs here! "    
;


/* 96 */
honeycomb: Food 'sweet honeycomb; honey; comb'
    "It looks delicious, but something in the back of your mind
    cautions you against eating it -- you may need it for something else. "
    game551 = true
    mass = 2
    
    /* moved into hive when bees are fed */
;

/* 106 */
mushrooms: CanPick, Food 'colored mushrooms; coloured magic; pyote;them' @inForest3
    "They're just normal-looking colored mushrooms.  They
    appear to be edible, but something in the back of your
    mind advises caution.  You probably shouldn't try them
    until you have a reason to do so. "
    
    game551 = true
    mass = 1
        
    growtime = 20
    regrow 
    {
        moveInto(inForest3);
        if(gPlayerChar.isIn(getOutermostRoom))
            "</p>There are some colored mushrooms here. ";
        
    }
    
    dobjFor(Eat)
    {
        action()
        {
            // make mushrooms effective in ledgeByDoor, which is really the
            // same place as topOfSteps
            if (gActor.getOutermostRoom not in (topOfSteps, ledgeByDoor)) 
            {
                moveInto(nil);
                "You thought maybe these were peyote??  You feel a little
                dizzy, but nothing else happens. ";
                new Fuse(self, &regrow, growtime);                    
            }
            else if(cakes.isIn(archedSteps))
                "You'd best take the cake off the steps first. ";
            else if(!cakes.isIn(gActor.getOutermostRoom) && !cakes.isIn(crampedChamber)) 
            {
                "That's not a good idea.  You'd be trapped in here until the 
                effects of the mushroom have worn off, and I don't know how 
                long that would take. ";
                if (cakes.getOutermostRoom == nil) 
                {
                    "Maybe one of the cakes ";
                    if (cakes.knowdrop)
                        "you dropped ";
                    "is around here somewhere. ";
                    archedSteps.cakefind = true;
                }
                else 
                    "You'd better go back for that cake. ";
            }
            else 
            {
                moveInto( nil );
                eat_messages.larger;
                new Fuse(self, &regrow, growtime);             
                
                gActor.roomMoveTravel(&transmove,crampedChamber);
            }
            
        }
    }
;
    
    
    

/* 107 */
cakes: Food 'tiny cakes; (cup);cupcakes cake cupcake ;them' @shelf
    desc 
    {
        if (isEaten)
            "It's a little cupcake, which you must have dropped earlier. ";
        else
            "They are tiny cupcakes. On looking closely, {i} {can}
            just read the words <q>Eat Me</q> in minute lettering. ";
    }
    
    game551 = true
    mass = 1
    isEaten = nil
    knowdrop = nil
    
    altVocab = 'tiny cake; (cup); cupcake cake'
    useAltVocabWhen = isEaten
        
    readDesc = "{I} {see} the words <q>Eat Me</q> in minute lettering. "
        
    dobjFor(Eat)
    {
        action()
        {
            if(!gActor.isIn(crampedChamber)) 
            {
                "{I} {take} a small bite out of the cake, but it has no effect.
                You decide to wait until it's needed again. ";
                return;
            }
            eat_messages.smaller;
            
            if(tinyKey.isIn(shelf)) 
            {
                knowdrop = true;
                "Oops!  This is not your day. ";
                if (! isEaten) 
                {
                    "You've dropped at least one of the cakes, but maybe this
                    is just as well because you've ";
                    moveInto(topOfSteps);
                }
                else 
                {
                    "Once again you've ";
                    moveInto(archedSteps);
                    archedSteps.fullcount++; // total number of cakes found on steps
                }
                "left the key on the shelf where you can't reach it!  You'd
                better go looking for more mushrooms - maybe you'll find some if
                you go back later.  "; 
                if (isEaten) "You spot another of the cakes you dropped,
                    lying in shadow near the top of the steps. ";
                "<.p>";
                
            }
            else {
                moveInto( nil );
            }
            isEaten = true;
            
            gActor.roomMoveTravel(&transmove,topOfSteps);           
        }
    }
    
    actionDobjCount()
    {
        if (self.isEaten) inherited();
        else 
            "There's something strange about these cakes which makes it hard
            to count them accurately, but there appear to be about a dozen
            of them. ";
    }
    
;   

/* 108 */
sack: BagOfHolding, OpenableContainer 'leather sack;;bag' @insideBuilding    
        "It's a capacious leather sack, large enough to
        hold most objects.  "
        
    game551 = true
    
    openStatusReportable = UsePronoun
    
    affinityFor(obj)
    {
        if(obj.isLong || obj.isLarge || obj.isHuge || obj.nosack ||
           (obj.ofKind(wickerCage) && obj.contents.length > 0))
            return 0;
        
        /* 
         *   Most players won't want the lantern thrust into the sack when it's lit, and it might be
         *   better to avoid that even when it isn'.
         */
        if(obj == brassLantern)
            return brassLantern.isLit ? 0 : 20;
        
        if(obj.ofKind(Treasure))
            return 120;
        
        return inherited(obj);
    }
    
    bulkCapacity = 100
    
    // can't put in safe
    isLarge = true
    nobird = true
    
    iobjFor(PutIn)
    {
        /* The logic appears to be the same on both objects so we needn't repeat it. */
        check()  { safe.checkIobjPutIn();    }
    }
;


/* 113 */
poster: Thing 'poster; faded' @insideBuilding
    "The poster has a picture of a thin man with a long white beard.
    He is wearing a high pointed cap embroidered with strange symbols,
    and he is pointing a finger at you.  Below the picture are the words:
    <q>I want you!--To report all good ideas for extensions to this game
    to me without delay.  Remember: ask not what ADVENTURE can do to
    you; ask what you can do for ADVENTURE.</q>\ \b
    <center>*  *  *</center> \b
    <q>A public service of the John Dillinger Died for You Society.</q>" 
    
    
    game551 = true
    mass = 1
    sdesc = "poster"
    
    initSpecialDesc = "Taped to the wall is a faded poster. "
    readDesc = desc

    dobjFor(LookBehind)
    {
        action()
        {
            if(moved)
                inherited();
            else
            {
                "Hidden behind the poster is a steel safe, embedded in the wall. ";
                safe.isHidden = nil;
            }
        }
    }
    
    dobjFor(Take)
    {
        action()
        {            
            if(!moved)
            {
                "Taking the poster reveals a steel safe embedded in the wall. ";                
            }
            inherited();
            safe.hidden = nil;
            safe.isHidden = nil;
        }
        
    }
    
;

/* 114 */
  whiskbroom: Thing 'small whiskbroom; whisk; broom brush' @tongueOfRock
    
    game551 = true
    mass = 1
    iobjFor(CleanWith)
    {
        preCond = [objHeld]
        verify() {}
    }
 
    iobjFor(SweepWith) asIobjFor(CleanWith)    
    iobjFor(DustWith) asIobjFor(CleanWith)
;

/* 118 */
canister: OpenableContainer 'small metal canister; small cylindrical grey gray metal heavy lead'
    @atWindowOnPit2
    "It's a cylindrical container, made from a heavy grey metal -- possibly lead. At present <<if
      isOpen && contents.length > 0>>\v<<else>>it is <<if isOpen>>open<<else>>closed<<end>>.
    <<end>>"
    
    openStatusReportable = UsePronoun
    
    game551 = true
    mass = 3
    
    iobjFor(PutIn)
    {
        check()
        {
            if(gDobj != glowingStone)
                "{The subj iobj} {is} not a suitable container for {the dobj}. ";
        }   
    }    
    
    isOpen = true
    
;


/* Additional object (sign on throne) */
throneSign: Thing 'Mountain King\'s sign' @throneRoomEast
    "The sign reads: <q>Gone for the day: visiting sick snake. --M.K.</q> "
    game551 = true
    mass = 1
    readDesc = desc
    aName = 'the Mountain King\'s sign'
    
    initSpecialDesc = "On the arm of the throne has been hung a sign which reads <q>Gone for the
        day: visiting sick snake. --M.K.</q>"
    fromloc = throne  
;



boat: Fixture, Booth 'wooden boat; small rowing; dinghy' @grottoWest
    "It's a small rowing boat, of traditional construction and design. "
    
    isVehicle = true
    dobjFor(Board) asDobjFor(Enter)
    bulkCapacity = 10000
    specialDesc = "There is a small rowing boat here. "
    softfloor = true
    
    cannotTakeMsg()
    {
        local msg = '';
        
        if(gActor.isIn(grottoWest))
            msg = 'The boat is too heavy to carry.  It won\'t fit through
                the door, and I don\'t think {i} can use the <q>phuce</q>
                spell to shrink it.  ';
        else
            msg = 'The boat is too heavy to carry, and too bulky for {me}
                to drag it through the cave passages.<p>';
                
        return msg + 'If {i} want{s/ed} to cross the water, {i}\'ll have to get
            into the boat.';           
    }
    
    dobjFor(Move) asDobjFor(Take)
    dobjFor(Push) asDobjFor(Take)
    dobjFor(Pull) asDobjFor(Take)
    
    dobjFor(PoleDir)
    {        
        /* Note: the precondition that the pole must be held is defined on Thing in thingext.t */
        verify()
        {
            if(!gActor.isIn(self))
                illogicalNow('{I}\'d better get into the boat firt. ');
        }
        
        action()
        {
            doInstead(Go, gAction.direction); 
        }
            
    }
    
;

/*
 * Treasures
 */


/* 47 */
cloak: Wearable, Treasure 'silken cloak; lovely warm' @cloakroom
    desc()
    {
        "It's a valuable-looking silken cloak";
        if(!moved)
            ", partially buried under the rocks.
            There's little chance of moving the rocks, but you could
            probably yank it out without tearing it. ";
        else if (wornBy == gPlayerChar)
            "(being worn). You feel very warm! ";
        else ". ";
    }
    
    game551 = true
    mass = 1
    basis = 3
    
    
    initSpecialDesc = "A lovely silken cloak lies partially buried under a pile of
      loose rocks. "
    
    fromloc = cloakrocks
    
    dobjFor(Take)
    {
        check()
        {
            if(!moved)
                "The cloak is stuck tight under the rocks.  You'll probably
                have to yank it out. ";        
        }
        action()
        {
            local m = moved;
            inherited();
            if(moved && !m)
                cloakroom.cave();
        }
    }
    
    dobjFor(Yank)
    {
        check()
        {
            if(!yankObj)
                inherited();
        }
        
    }
    
    icecheck(actor)
    {
        if(wornBy == actor && actor.isIn(hallOfIce))   
        {
            "You'll freeze to death if you take off the cloak in
            here! ";        
            return nil;
        }
        return true;
    }
    
    dobjFor(Doff)
    {
        check()
        {
            if(icecheck(gActor))        
                inherited();
        }
    }
    dobjFor(PutIn)
    {
        check()
        {
            if(icecheck(gActor))        
                inherited();
        }        
    }
        
    dobjFor(PutOn)
    {
        check()
        {
            if(icecheck(gActor))        
                inherited();
        }        
    }
    
    dobjFor(Drop)
    {
        check()
        {
            if(icecheck(gActor))        
                inherited();
        }        
    }
    
    yankObj = (!moved)        
    
//    doWear(actor) = {
//        local pendanlist := [pendant, pendant2, pendant3, broken_pendant];
//        local i, o, l := length(pendanlist), count := 0;
//        inherited.doWear(actor);
//        for (i := 1; i <= l; i++) {
//            o := pendanlist[i];
//            if ((self.location = actor) and self.isworn and 
//            (o.location = actor) and o.isworn)
//                count++;
//        }
//        if (count = 1)
//            "The pendant which you are wearing is now concealed under the 
//            cloak. ";
//        else if (count > 1)
//            "The pendants which you are wearing are now concealed under 
//            the cloak. ";  
//    }
;

/* 52 */
horn: Treasure 'silver horn; solid' @westSideOfFissure
    "It appears to be made of solid silver!"
    
    game551 = true
    mass = 2
    basis = 2

    dobjFor(Blow) asDobjFor(Play)
    
    dobjFor(Play)
    {
        verify() {}
        
        check()
        {
            if(wumpi.isIn(gRoom) || wumpiRemnant.isIn(gRoom))
                "Don't be ridiculous! ";
        }
        
        action()
        {
            local metop = gRoom;
            if(!inArchedHall.jericho && metop is in (inArchedHall, EWCorridorE))
            {
                if(gActor.location.isLit)
                {
                    "As the blast of the horn reverberates through the chamber, the
                    seemingly solid rock wall crumbles away, revealing another
                    room to the <<inArchedHallWalls.dirName>>.
                    The wall was most likely worn thin by an ancient watercourse 
                    which dried up just before completely wearing away the rock. ";                    
                }
                else
                    "As the blast of the horn reverberates through the chamber,
                    you hear a crumbling sound and the acoustics of the room
                    change subtly.  You sense that there is now another exit. ";
                
                inArchedHall.jericho = true;
                inArchedHallWalls.makeOpen(true);
                corridorRubble.moveInto(EWCorridorE);
            }
            else if(gActor.isIn(dog.getOutermostRoom))                
            {
                if(dog.isAsleep)
                    dog.sleeplie();
            }
            else if(gActor.isIn(wumpus.getOutermostRoom) && wumpus.isAsleep)
                nestedAction(Wake, wumpus);
            else if(metop.isoutside && !metop.isindoor)
                
                "The blast of {my} horn echoes throughout hill and dale.";
            else
                "The chamber reverberates to the blast of the horn.
                (Satchmo {i} ain't!)";
            
        }
    }
    
    
    
//    doPlay(actor) = {
//        local metop := toplocation(actor);
//        if ((not In_Arched_Hall.jericho) and (metop = In_Arched_Hall
//        or metop = EW_Corridor_E)) {
//            if(actor.location.islit) {
//                "As the blast of the horn reverberates through the chamber, the
//                seemingly solid rock wall crumbles away, revealing another
//                room to the <<In_Arched_Hall_Walls.holedir>>.
//                The wall was most likely worn thin by an ancient watercourse 
//                which dried up just before completely wearing away the rock. ";
//            }
//            else {
//                "As the blast of the horn reverberates through the chamber,
//                you hear a crumbling sound and the acoustics of the room
//                change subtly.  You sense that there is now another exit. ";
//            }
//            In_Arched_Hall.jericho := true;
//            Sidehole.moveLoclist([In_Arched_Hall EW_Corridor_E]);
//            Corridor_Rubble.moveInto(EW_Corridor_E);
//        }
//        else if (actor.isIn(Dog.location)) {
//            if (Dog.isasleep)
//                Dog.sleeplie;
//            else
//                "The dog growls and barks at %you%.  It clearly doesn't
//                like %your% attempt to play the horn.  The result might be
//                different if %you% find%s% an instrument %you% CAN play.";
//        }
//        else if (actor.isIn(Wumpus.location) and Wumpus.isasleep) {
//            Wumpus.doWake(actor);
//        }
//        else if (metop.isoutside and not metop.isindoor)
//            "The blast of %your% horn echoes throughout hill and dale.";
//        else
//            "The chamber reverberates to the blast of the horn.
//            (Satchmo %you% ain't!)";
//    }
;

/* 65 */

// Not to be confused with singing_sword.
// Note that a refinement has been added from v2.00 - its image when seen
// in a mirror (when waved at Window At Pit or seen in the metal plate) is
// rusty, and the ogre also sees it as rusty.

// Note that it is not possible to pour liquids over the sword in the
// 701-point game - in this version you can only get into this area via
// the waterfall.
sword: Treasure, Weapon 'gleaming sword; elven elvish' @swordPoint
    desc()
    {
        if(isclean && !moved)
            "It looks like a very clean
            elven sword. ";       
        else if(isoily)
            "It's covered in oil, and you can't get
            a firm grip on the handle.  I suspect you won't
            be able to get it now, no matter how hard you try. ";
        else "It's a gleaming elven sword.  Against dwarves, you
            might try using it for hand-to-hand combat.  Due to your lack
            of experience in swordsmanship, I'll assume that you want to
            throw the sword when attacking anything larger. ";
    }

    game551 = true
    mass = 2
    basis = 4
    isoily = nil
    isclean = nil
    vocabLikelihood = 20
      
    sdesc = ""
    initSpecialDesc
    {
        if(isclean) "A very clean sword is stuck in the anvil! ";
        else if(isoily) "An oily sword is stuck in the anvil. ";
        else "A gleaming sword is stuck into the anvil! ";
    }
    
  
    nosack = true  // tell sack_of_holding not to put it into containers
    fromloc = anvil
    
    dobjFor(Take)
    {
        check()
        {
            if (isoily)
                "The handle is now too slippery to grasp. ";
            else if(!moved && gVerbWord != 'yank')
                "You grasp the sword's handle and pull, but the sword won't
                budge.  You could try yanking it out.";
        }
    }
    
    dobjFor(Yank)
    {
        action()
        {
            "You grasp the sword's handle and give a mighty heave, ";
            if (!moved && crown.wornBy != gActor)
            {
                 "but with a loud clang the sword blade shatters into several fragments. ";
                smash();
            }
            else 
            {
                "so that it slides out of the anvil and {i} end{s/ed} up holding it. ";
                // DJP.  Stop the dwarves from attacking after the sword is
                // taken (in the original, the dwarves wouldn't attack after
                // any object was taken)
                Dwarves.noAttack = true;
                actionMoveInto(gActor);
            }
        }
    }

    
    yankObj = (!moved && !isoily)
    
    dobjFor(Pull)
    {
        check()
        {
            if(!moved)
                checkDobjTake();
            else
                inherited();
        }     
        action()
        {
            if(!moved)
                actionDobjTake();
            else
                inherited();                
        }
    }
            
    dobjFor(Clean)
    {
        verify()
        {
            if(isoily)
                illogicalNow('You can\'t do that without soap of some sort. ');
            else if(isclean)
                illogicalAlready('It\'s already very clean. ');             
        }
        check = "You'll have to tell me how to do that. ";
    }
    
    dobjFor(CleanWith)
    {
        verify() { }
        check()
        {       
            if(isoily)
                "You can't remove the oil without soap of some sort. ";
        }
        action = "You clean the sword with {the iobj}, but it doesn't look
        noticeably different. "
    }
    
    iobjFor(PourOnto)
    {
        verify()
        {
            if(moved)
                illogicalNow('There\'s no point in doing that now. ');
        }
    }
    
    pourable = nil
    
    dobjFor(Water)
    {
        verify() { verifyIobjPourOnto(); }
        
        check()
        {
            pourable = valWhich(gActor.allContents.valWhich({o: o is in (bottle, cask, flask) &&
                o.hasWater}));
            if(pourable == nil)
                "{I} {have} nothing to water the sword with.";
        }        
        
        action() {  doInstead(PourOnto, pourable, self);  }
    }     
   
    
    dobjFor(Oil)
    {
        verify() { verifyIobjPourOnto(); }
        check()
        {
            pourable = valWhich(gActor.allContents.valWhich({o: o is in (bottle, cask, flask) &&
                o.hasOil}));
            if(pourable == nil)
                "{I} {have} nothing to oil the sword with.";
        }
        
        
        action() { doInstead(PourOnto, pourable, self); }
    }     
       
    throwsmash
    {
        local toproom = getOutermostRoom;
        if (toproom.softfloor) 
        {
            "The sword misses. ";
            actionMoveInto(toproom);
        }
        else 
        {
            "The sword misses and smashes to smithereens against a rock. ";
             smash();
        }
    }
    smash    
    {
        sword.actionMoveInto(nil);
        swordshards.moveInto(gActor.location.dropLocation);        
//        swordshards.heredesc;
    }
    
    cannotWearMsg = '{I} {have} no scabbard! '    
;

swordshards: Thing 'sword fragments;rusty;shards;them'
    "Something very odd has happened.  There wasn't a sign of
            corrosion on the sword, but the fragments are now covered in
            a thick layer of rust! "
    game551 = true
    bulk = 3 // shards are hard to carry except in a container
    
    initSpecialDesc = "Rusty fragments of a elven sword lie scattered about. "   
;




/* 66 */
 // Not to be confused with irid_crown   
crown: Wearable, Treasure 'elfin crown'
    "It's a small but ancient elfin crown, made of gold and
    encrusted with precious stones of all descriptions.  It must be
    worth an absolute fortune. "
    
    game551 = true
    mass = 1
    basis = 2

   

    noun = 'crown; elvish ancient small gold'

    initSpecialDesc = "An ancient crown of elfin kings lies here!"
    
    dobjFor(Wear)
    {
        action()
        {
            inherited();
            if(wornBy == gActor)
                "{I} {feel} a slight tingling sensation as {i} {put} on
                the crown ...\nOkay, {i}{'m} now wearing {the dobj}. ";
        }
    }
    
    location = throneRoomEast
;

/* 67 */
slippers: Wearable, Treasure 'pair of ruby slippers;;shoes;it them' @overRainbow
    "Close examination of the slippers reveals nothing unusual,
        but the song <q>Somewhere, Over the Rainbow</q>is going round and
        round in your head and you can't get rid of it! <<unless clicked>> 
        You have a strong feeling that these slippers \(are\) special
            in some way.  You don't know the answer but I expect that it
            will all <q>click</q> sometime.<<end>> "
    
    game551 = true
    mass = 1
    basis = 3
    clicked = nil

    /* Handling for CLICK SLIPPERS -- defined as a Special Action below. */
    dobjFor(SpecialAction) 
    {
        preCond = [touchObj]
        verify() {}
        action() { doInstead(Click); }
    }
;
//
///* Enable the command CLICK SLIPPERS just for the slippers */
//SpecialVerb 'click' @slippers 'sp#act';

/* 68 */
lyre: Treasure 'delicate lyre' @lowNSPassage
    "It's certainly a valuable antique.  In fact, it looks
    like the instrument depicted in ancient Greek art. %You've% never had
    any lessons, but somehow %you% know%s% you'll be able to play it well. "
    game551 = true
    mass = 2

    dobjFor(Play)
    {
        preCond = [objHeld]
        verify() {}
        action()
        {
            if(dog.isIn(gActor.getOutermostRoom) && !dog.isAsleep)
            {
                "The air fills with beautiful music.  The dog gradually becomes
                less fierce, and after a short while he lies down by the side
                of the cavern and falls into a deep sleep. ";
                dog.isAsleep = true;
                if (axe.nograb && dog.location == axe.location)
                    axe.nograb = nil;
            }
            else
                "The air is filled with beautiful music. ";
        }        
    }   
;

/* 69 */
sapphire: Treasure 'star sapphire; six-pointed blue;starstone' @starChamber
    "Its appearance is very striking -- a brilliant blue six-pointed star. "
    game551 = true
    mass = 2
    plughed = nil
;


/* 70 */
/* This was called a 'holy grail' in the Fortran but we avoid that description
   in this version - it might mislead people into thinking it has magic
   powers.
*/
/* Actually it can't really hold liquids but we pretend that it does */
    chalice: Treasure 'ornate silver chalice; holy cracked priceless antique; grail'
    @gothicChapel
    "It's a priceless antique.  However, it appears to be slightly
            cracked, and can't actually be used. "
    
    game551 = true
    mass = 2
    basis = 2
    
    iobjFor(PutIn)
    {
        verify() {}
        check()
        {
            if (gDobj.ofKind(RoomLiquid)) 
                "The chalice is slightly cracked.  It won't hold any liquids.";
            
            else if (!gDobj.ofKind(ContLiquid))
                "You couldn't carry objects around in the chalice -- they would fall out! ";
        }    
    }
    
    dobjFor(Fill) 
    { 
        verify() {illogicalNow('The chalice is slightly cracked. It won\'\ hold any liquids. '); }
    }
;

class ProtectRing: object
    dobjFor(Rub)
    {
        preCond = [touchObj]
        verify() {}
        action()
        {
            if(protection) 
            {
                local weaplist = '', count = 0;
                if (wornBy == gActor)
                {
                    "{I} rub(s/?ed} {the dobj} ";
                    
                    if(axe.isIn(actor)) 
                    {
                        weaplist = 'axe';
                        count++;
                    }
                    if(sword.isIn(actor)) 
                    {
                        if(weaplist == '') weaplist = 'sword';
                        else weaplist += ' and sword';
                        count++;
                    }
                    if(singingSword.isIn(actor)) 
                    {
                        if(weaplist == '') weaplist = 'sword';
                        else if(sword.isIn(actor)) weaplist += 's';
                        else weaplist += ' and sword';
                        count++;
                    }
                    if(count > 0) 
                    {
                        " and you notice that your <<weaplist>> ";
                        if (count > 1) "seem"; else "seems";
                        " to be repelled away from it! ";
                    }
                    else ". Nothing unusual happens. ";
                }
                else "You rub {the dobj}.  Nothing exciting happens. ";
            }
            else inherited();
        }
    }
    
    protection = 0
;

/* 72 */
/* N.B. the protect_ring class is now defined in ccr-it11.t */
goldRing: ProtectRing, Wearable, Treasure 'small gold ring; plain' 
    "It's a plain gold ring.  Probably quite valuable, though. "
    
    game551 = true
    mass = 1
    basis = 4
    protection = 3
    taken = nil
    seenspecial = nil
    deducedmagic = nil
    
    initSpecialDesc = "On the Wumpus' finger is a small gold ring! "
    specialDescOrder = 150 // report ring after Wumpus
    fromloc = wumpus
    
    dobjFor(Take)
    {
        action()        
        {
            if(!taken && !moved && location == wumpus.location)
            {
                "As you slip the ring off the Wumpus' finger, you congratulate
                yourself on a job well done.  You're the first adventurer to 
                turn the tables on this evil, cunning monster!
                Another thought comes into your mind.  Old Elvish lore tells of
                many magic rings, and there's a distinct possibility that this
                may be one of them.  ";
                if(global.game701p &&! transindectionKey.moved)
                    "In a flash of intuition - which also gives you a strange
                    sense of foredoding - it occurs to you that the
                    Wumpus may have had other possessions.  
                    They would, of course, have been hidden away from the
                    eyes of light-fingered adventurers like you ... ";
            }
            taken = true;
            inherited();
        }
    }
;


/* 73 */
clover: Wearable, Treasure 'four-leafed clover; four leafed lucky' @knoll
    "It's a rare four-leafed clover, reputed to bring good luck. "
// In the Fortran version this object didn't do anything, but now it
// brings luck in certain circumstances when carried by the player (even if
// it's in a closed container.)  It can be worn.
    
    initSpecialDesc = "{I} {see} a four-leafed clover growing here. "
       
    game551 = true
    mass = 1
    
;

/* 74 */
goldTree: Treasure 'gold tree; intricately carved of[prep] ;statue' @outerCourtyard
    "It's an intricately carved statue of a tree, in solid gold.
     Every leaf is rendered with exquisitely fine detail, and it
     must be worth a fortune. "
    
    game551 = true
    mass = 3
    basis = 5

    initSpecialDesc = "There is a gold statue of a tree here. "
;

/* 75 */
silverDroplet: Treasure 'silver droplet ; mithril little of[prep] metal; sphere' @innerCourtyard
    "It's a little sphere of mithril silver - an extremely
     rare and highly prized metal.  It's therefore highly valuable! "
    
    game551 = true
    mass = 1
    basis = 5

    initSpecialDesc = "There is a single droplet of silver on the ground here. "
;

/* 86 */
wineInTheCask: ContLiquid, Treasure 'wine in the cask;in-cask'
    "It's a large quantity of sparkling vintage wine.  It must be very valuable! "
    game551 = true
    basis = 3   
    
    mycont = cask
    myflag = &hasWine

    targloc = cask
    contloc = treasureChest
    outercontloc = insideBuilding
    
    aName = 'wine'    
    theName = 'the in-cask wine'
;



/* 110 */
rareBook: Treasure 'rare book; dusty leather-bound leather bound; volume' @safe
    "It's a dusty, leather-bound volume. It looks very valuable! "
    game551 = true
    
    mass = 3
    basis = 2   

    readdesc
    {
        switch(global.vNumber) 
        {
            case 1: self.readdesc1; break;
            case 11:
            case 15: self.readdesc15; break;
        }
    }
    readdesc1
    {
    "\ \ \ \ \ \ \ \ *** THE HISTORY OF ADVENTURE (ABRIDGED) ***\n
    \ \ \ \ \ \ \ \ ** By Ima Wimp **";
    
    "<.p>ADVENTURE was originally developed by William Crowther, and later
    substantially rewritten and expanded by Don Woods at Stanford Univ.
    Crowther's original version was modelled on a real cavern, called
    Bedquilt Cave, which is a part of Kentucky's Mammoth Cave system.
    That version of the game included the main maze and a portion of the
    third-level (Complex Junction - Bedquilt -  Swiss Cheese rooms, etc.),
    but not much more.";
    
    "<.p>Don Woods and some others at Stanford later rewrote portions of
    the original program, and greatly expanded the cave.  That version
    of the game is recognizable by the maximum score of 350 points.";
   
    "<.p>Some major additions were done throughout 1978 by David Long while
    at the University of Chicago, Graduate School of Business.
    Long's additions include the seaside entrance and all of
    the cave on the \"far side\" of Lost River (Rainbow Rm - Crystal
    Palace - Blue Grotto - Rotunda - beyond Joshua's wall, etc., etc.).
    The castle problem was added in late 1984 by an anonymous writer.
    The current cave is about 50% larger than the Woods/Stanford model.
    In the process, the code was heavily rewritten to permit more
    generalized handling of objects and to allow a far more complex
    syntax.  The current maximum score is 551 points.";
    
    "<.p>Thanks are owed to Roger Matus and David Feldman, both of U. of C.,
    for several suggestions, including the Rainbow Room, the telephone
    booth and the fearsome Wumpus.  Further thanks go to J. R. Carlson
    for many debugging suggestions.  Most thanks (and apologies)
    go to Thomas Malory, Charles Dodgson, the Grimm Brothers, Dante,
    Homer, Frank Baum and especially Anon., the real authors of
    ADVENTURE.";
    
    "<.p>The original TADS port of the 350-point game (Colossal Cave Revisited)
    was written by David Baggett in 1993.  The 551-point extensions were 
    added by David Picton in 1999. ";
    }
    // used in the 701-point and 701+ point versions
    readdesc15 
    {
    "\ \ \ \ \ \ \ \ *** THE HISTORY OF ADVENTURE (ABRIDGED) ***\n
    \ \ \ \ \ \ \ \ ** By Ima Wimp **";
    
    "<.p>ADVENTURE was originally developed by William Crowther, and later
    substantially rewritten and expanded by Don Woods at Stanford Univ.
    Crowther's original version was modelled on a real cavern, called
    Bedquilt Cave, which is a part of Kentucky's Mammoth Cave system.
    That version of the game included the main maze and a portion of the
    third-level (Complex Junction - Bedquilt -  Swiss Cheese rooms, etc.),
    but not much more.";
   
    "<.p>Don Woods and some others at Stanford later rewrote portions of
    the original program, and greatly expanded the cave.  That version
    of the game is recognizable by the maximum score of 350 points.";
    
    "<.p>Some major additions were done throughout 1978 by David Long while
    at the University of Chicago, Graduate School of Business.
    Long's additions include the seaside entrance and all of
    the cave on the \"far side\" of Lost River (Rainbow Rm - Crystal
    Palace - Blue Grotto - Rotunda - beyond Joshua's wall, etc., etc.).
    The castle problem was added in late 1984 by an anonymous writer,
    bringing the maximum score up to 551 points. ";
    
    "<.p>Another extended version, with 550 points, was independently
    developed in late 1979 by David Platt of the Honeywell Los
    Angeles Development Center.  The extensions in this version include
    the new areas beyond the Giant Room, the Arched Hall and the volcano.
    In 1984 the program was ported to UNIX C by Ken Wellsch. The extensions
    are drawn from the database source code.";
   
    if(global.game701p)
        "<.p>This version of the game has a maximum score of at least 701 points,
        and includes the 550-point and 551-point games, with the exception of 
        the 551-point endgame.  But you now have something extra - a sort of
        sixth sense which may lead you to make discoveries which all 
        previous Adventurers have missed.  If so, you'll literally
        add a new dimension to your exploration of the cave. ";
    else
        "This version of the game has a maximum score of 701 points, and 
        combines the 550-point and 551-point games (with the exception of the 
        551-point endgame.) ";
    
    "<.p>The original TADS port of the 350-point game (Colossal Cave Revisited)
    was written by David Baggett in 1993.  The 551-point extensions were 
    added by David Picton in 1999, followed by the 550-point extensions by 
    Bennett Standeven.  The combined 701-point mode was developed
    in by David Picton in 2000, and a 580-point mode was added by 
    Bennett Standeven in 2003. Finally, the extended 701+ point mode was
    released by David Picton in 2004. ";
    }
   
   
    undiscovered = true // suppress scoring until safe is opened
    createloc = atSWEnd // where to create a copy in the endgame.
;

/* 119 */
// This wasn't a light source in the Fortran version, but it is in this one,
// because a 'brightly' glowing stone would certainly light the room.
// Carrying it around for too long is bad for one's health, unless it's
// in its container.  In the TADS port, the troll knows this.
glowingStone: LightSource, Treasure 'glowing stone; green greenish glowing strange' @bubbleChamber
     "The strange green glow is bright enough to see by!  You
        could use it as a light source, but something in the back of
        your mind urges caution.  I wouldn't throw away your lamp if I were you. "
    
    game551 = true
    mass = 1
    basis = 4

    initSpecialDesc = "Nearby, a strange, greenish stone is glowing brightly! "
    
    mycont = canister  // used by troll code  
;

// The troll puts the stone in here if it's not given in the canister.  It's
// seen only if the sapphire is given to the troll.
leadBox: OpenableContainer 'ornate lead casket'
    "The troll uses this container to store the glowing stone if it
        isn't in the canister. "
    game551 = true    
;

/* 120 */
crystalBall: Treasure 'crystal ball; quartz;sphere palantir' @crystalPalace
    "At first sight, it's just a polished sphere of pure quartz.
    However, it begins to go a little cloudy as you examine it, and you
    are tempted to find out what will happen if you look IN the crystal
    ball! "
    
    game551 = true
    mass = 2
    basis = 2
    noelf = nil

    dobjFor(LookIn)
    {
        check()
        {               
            if (wumpus.isChasing)
                "You'd better do something about the Wumpus first - this
                isn't going to help! ";
            if (goblins.isChasing)
                "You'd better do something about the goblins first - this
                isn't going to help! ";
            else if (blob.isChasing && blob.chase >= 13)
                "You'd better do something about the strange blob first - this
                isn't going to help! ";
            else if (Dwarves.numberhere(gActor) == 1) 
                "You'd better do something about the dwarf first -
                this isn't going to help! ";            
            else if (Dwarves.numberhere(gActor) > 1) 
                "You'd better do something about the dwarves
                first - this isn't going to help! ";           
        }    
    
        action() 
        {
            local sapphloc, catobj, myloc = gActor.location, myprep, 
                catacnum;
            local toploc = gActor.getOutermostRoom;
            sapphloc = sapphire.getOutermostRoom;
            if (sapphloc == nil) sapphloc = sapphire.location;
            if (sapphloc.ofKind(Actor)) 
            {
                if(sapphloc.location)
                    sapphloc = sapphloc.location;
            }
            // Special coding is needed if the sapphire is in Elsewhere,
            // indicating that the sapphire is really in a Catacomb (and if the
            // player is in a Catacomb, the sapphire is in a different one).
            // Adjust the contents of the Catacombs as appropriate
            if (sapphire.isIn(elsewhere)) 
            {
                catobj = sapphire;
                // If the object is contained, find the outermost
                // container.
                while (catobj.location != elsewhere) 
                {
                    catobj = catobj.location;
                    if (catobj == nil) 
                    {
                        "Internal error while trying to find the
                        outermost container of <<sapphire.theName>>.";
                        return;
                    }
                }
                // Remove objects from Catacombs (if the player is there) 
                // and label their room number
                if (gActor.isIn(catacombs))catacombs.leaveRoom;
                // Save the current Catacombs room number
                catacnum = catacombs.roomnumber;
                // Set the Catacombs room number and move the relevant objects
                // into the room.
                catacombs.roomnumber = catobj.catac_room_num;
                catacombs.enterRoom;
                if (sapphloc == elsewhere) sapphloc = catacombs;
            }
            if (toploc.ofKind(OutsideRoom) && !toploc.ofKind(IndoorRoom))
                "You gaze into the crystal ball.  An image begins to form,
                but the bright daylight prevents you from seeing any detail.
                Maybe if you went somewhere a little darker ...";
            else 
            {
                "You feel rather disembodied, as if you were suddenly somewhere
                else entirely.<.p>";
                // Move the player out of the way if he's in the Catacombs and
                // the sapphire is in a different Catacomb, so the player's lamp
                // won't illuminate the location.
                if (catacnum && gActor.isIn(catacombs)) gActor.actionMoveInto(elsewhere);
                if (!sapphire.outermostVisibleParent.isIlluminated) 
                {
                    "You sense that you are in a dark place. The only thing in
                    sight appears to be a companion to the crystal ball which
                    holds your gaze. It seems to be searching the gloom for
                    something to show you, but all it can see is itself: a
                    brilliant blue six-pointed star suspended in space.";
                    if (gActor.isIn(atY2) || gActor.isIn(fakeY2))                         
                        "A hollow voice says \"Plugh\". ";
                    
                    gActor.actionMoveInto(myloc);
                    goto withdraw;
                }
                else
                    gActor.actionMoveInto(myloc);
                
                if (gActor.isIn(sapphloc.getOutermostRoom) &&
                    sapphloc.ofKind(Room) && catacnum == nil) 
                {
                    "You then have a very strange and unnerving experience.
                    You see yourself staring into the crystal
                    ball, to which you somehow feel irresistibly drawn -- and
                    inside the ball, you see another image of yourself, and
                    another ball, and another image, and another ball, until
                    you realize that you can stop the process by closing
                    your eyes. ";
                }
                else if(sapphloc.ofKind(Room)) 
                {
                    gActor.actionMoveInto(sapphloc);
                    global.view_artifact = self;
                    global.onlyviewing = true;
                    showRoom(gActor.location);                    
                    global.onlyviewing = nil;
                    global.view_artifact = nil;
                    if(Dwarves.numberhere(actor) == 1) {
                        "<.p>You see a little dwarf here. ";
                    }
                    else if(Dwarves.numberhere(actor) > 1) {                        
                        "<.p>You see <<say(Dwarves.numberhere(actor))>> little
                        dwarves here. ";
                    }
                    if(gActor.location == riseOverBay) {
                        if (!riseOverBay.seenit || ((rand(100) <= 10)
                            && !goldRing.seenspecial)) {
                            
                            "<.p>A large, stately elf walks up the rise, says the
                            word \"Saint-Michel\", and is instantly
                            transported to the castle. ";
                            riseOverBay.seenit = true;
                            if(goldRing.wornBy == gActor) 
                            {   
                                goldRing.seenspecial = true;
                                "<.p>You hear yourself repeat the word which the
                                elf has just issued. Out of the corner of your
                                eye, you then see your gold ring quiver - and
                                you seem to be somewhere else again...<.p>"; 
                                gActor.actionMoveInto(castlePinnacle);
                                sapphire.actionMoveInto(castlePinnacle);
                                showRoom(gActor.location); 
//                                gActor.location.lookAroundWithin();
                                
                                "<.p>You see the elf walk down the steps. ";
                            }
                        }
                    }
                    else if(gActor.location == castlePinnacle) {
                        if (!castlePinnacle.seenit || rand(100) <= 10) {
                            
                            "<.p>A large, stately elf appears and walks down
                            the steps.";
                            castlePinnacle.seenit = true;
                        }
                    }
                    else if(gActor.location == outerCourtyard) {
                        if (!outerCourtyard.seenit || ((rand(100) <= 10)
                            && !goldRing.seenspecial)) {
                            
                            "<.p>A large, stately elf comes down the steps.  He
                            says <q>Phleece</q>.  You notice that a bracelet,
                            which he wears on his wrist, begins to glow -- then
                            he disappears in a flash of light. ";
                            outerCourtyard.seenit = true;
                            if(goldRing.wornBy == gActor) 
                                
                                goldRing.seenspecial = true;
                            if(global.game701p) {
                                KataVerb.seenspecial = true;
                                AnaVerb.seenspecial = true;
                            }
                            "<.p>You hear yourself repeat the word which
                            the elf has just used.  Out of the corner of 
                            your eye, you see your gold ring quiver - and
                            you seem to be somewhere else again...<.p>"; 
                            sapphire.actionMoveInto(castleRoom);
                            gActor.actionMoveInto(castleRoom);
                            "\("; gActor.location.theName; "\)";
                            gActor.location.lookAroundWithin();
                            "\b";
                            if (global.game701p && !self.noelf) {
                                "You see the elf enter the room to the east,
                                and say \"Kata\".  The air around him seems to
                                shimmer, and he disappears!  Fearing that you 
                                may lose the emerald if you transport it again,
                                you stop yourself from repeating the word. ";
                                
                            } else if (!self.noelf) {
                                "You see the elf enter the room to the east,
                                and utter a magic word which you don't quite
                                manage to hear.  The air around him seems to
                                shimmer, and he disappears!  ";
                            }
                        }
                    }
                    
                    if((gActor.location == castleRoom) && 
                       sapphire.isIn(castleRoom) && !sapphire.plughed) 
                    {
                        
                        "<.p>You start to move your eyes away from the crystal
                        ball, but you notice movement in the sphere and
                        look again. Two elves come into the room from the 
                        southwest, deep in conversation.  Suddenly they notice the
                        sapphire, and immediately step back.  One of them
                        goes into a room to the north, and comes back
                        moments later, wearing a large glowing bracelet,
                        covered in knobs and buttons. He fiddles with the 
                        bracelet, then shouts a familiar word: <q>Plugh!</q>
                        You stop yourself from repeating the word, but
                        a hollow voice seems to say it anyway, 
                        and your gold ring quivers.  Once again, 
                        the elf and the sapphire are both transported.<.p>";
                        
                        if (myloc.getOutermostRoom == atY2)
                            sapphire.actionMoveInto(insideBuilding);
                        else if(myloc.getOutermostRoom == fakeY2)
                            sapphire.actionMoveInto(volcanoPlatform);
                        else if (myloc.getOutermostRoom == volcanoPlatform)
                            sapphire.actionMoveInto(fakeY2);
                        else
                            sapphire.actionMoveInto(atY2);
                        gActor.actionMoveInto(sapphire.location);                        
                        showRoom(gActor.location);
                        "\b";
                        "The elf picks up the sapphire and 
                        puts it down again, satisfied that it's now
                        out of harm's way.  Then he presses
                        another button on his glowing bracelet and 
                        disappears! ";
                        sapphire.plughed = true;
                    }
                    else if((gActor.location == castleRoom) && 
                            sapphire.isIn(castleRoom)){
                        
                        "<.p>You start to move your eyes away from the crystal ball,
                        but you notice movement in the sphere and look again.
                        Three elves are standing in the room, conversing in Elvish
                        and looking at the sapphire as if it's an unexploded bomb!
                        Once again a bracelet is produced, and once again a
                        button is pushed...<.p>";
                        
                        sapphire.actionMoveInto(trollTreasure);
                        gActor.actionMoveInto(sapphire.location);
                        showRoom(actor.location);                        
                    }
                    gActor.moveInto(myloc);
                }
                else 
                {
                    if (sapphloc.ofKind(Surface))
                        myprep = 'on';
                    else
                        myprep = 'in';
                    "You're somehow <<myprep>> <<sapphloc.aName>>! ";
                    if (sapphloc.contents.length > 0)                         
                        "<.p>You can see <<list of sapphloc.contents>> here. ";                   
                    else 
                        "<.p>It appears to be empty. ";
                    
                }
                withdraw: "\b";
                "Your gaze withdraws from the crystal ball, and you are
                now back in your normal senses.<.p>";
                myloc.lookAroundWithin();
            }
            // If catacnum is set, remove objects from the Catacombs location
            // and (if appropriate) move the right objects in.
            if (catacnum) 
            {
                // Remove objects
                catacombs.leaveRoom;
                // Restore original room number
                catacombs.roomnumber = catacnum;
                // If the player is in the Catacombs, move the right objects back.
                if(gActor.isIn(catacombs)) catacombs.enterRoom;
            }
        }
    }
    
    showRoom(loc)
    {
        local oldOpenTag = roomnameStyleTag.openText;
        local oldCloseTag = roomnameStyleTag.closeText;
        try
        {  
            roomnameStyleTag.openText = '\n<i>[';
            roomnameStyleTag.closeText = ']</i>\n';
            loc.lookAroundWithin();            
        }
        finally
        {
            roomnameStyleTag.openText = oldOpenTag;
            roomnameStyleTag.closeText = oldCloseTag;
        }       
    }
;




