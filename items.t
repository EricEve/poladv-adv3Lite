#charset "us-ascii"

#include <tads.h>
#include "advlite.h"

/*
 * This file defines all carryable items in the original game, and the items
 * for other versions are defined in the other files beginning with ccr-itm.
 * A flag (moved) is set when an item is first moved.
 */

/* Define the default special_cantreach method.  By default, this is 
   called recursively for self.location until the object is found to be
   held by the actor, or self.location evaluates to nil. 

   self = room or container for which the special check is being made.
   obj = object under consideration
   actor = actor trying to reach the object
   chain = list containing the containment chain, starting with 'self' and
           ending with 'obj'.  If chain[1] is the room, chain[2] will be the
           top-level container.

   At present the initial special_cantreach call is made only for portable
   items (class item), but it may be extended to nonportable objects in
   the future.

 */

// class for axes and swords etc.
class Weapon: Thing
    // TADS 2 version had Purloin code that may not be needed/
    
    iobjFor(AttackWith)
    {
        verify()
        {
            if(gVerifyDobj == self)
                illogicalSelf(cannotAttackWithSelfMsg);
            
            logicalRank(120);
        }
    }
;


// Class for objects like the singing sword which use a heredesc when 
// described in the top-level room description, but the normal adesc
// otherwise.

// Used for objects with constantly-changing descriptions.

class CondListed: Thing
    useSpecialDesc = location.ofKind(Room)
;

class CanPick: Thing // for mushrooms, flowers
;

class LightSource: object
    isLit = true
;

SpecialVerb 'pick' 'take' @CanPick;

class PendantItem: Thing
    classcount(actor) { return actor.allContents.countWhich({o: o.ofKind(PendantItem)}); }
;

class LiquidContainer: Thing    
    contentsListed = nil
    
    hasOil = (myLiquid == 'oil')
    hasWater = (myLiquid == 'water')
    /* Added for 551-point version */
    hasWine = (myLiquid == 'wine')
    isSealed = isSealable && !isOpen
    isSealable = nil
    
    contName = ''
     
    myLiquid = nil
    
    desc 
    {
        if (hasWater)
            "The <<contName>> is full of clear water. ";
        else if (hasOil)
            "The <<contName>> is full of oil. ";
        else if (hasWine)
            "The <<contName>> is full of wine. ";
        else 
            "There is nothing inside <<contName>>. ";
        
    }
    
    aName = (myLiquid == nil ? 'an empty <<name>>' : inherited)
    theName = (myLiquid == nil ? 'the empty <<name>>' : inherited)
    
    dobjFor(LookIn) asDobjFor(Examine)
    
    iobjFor(PutIn)
    {
        preCond = [objHeld]
        
        verify()
        {
            if(!isEmpty)
                illogicalNow('The <<contName>> is already full of <<myLiquid>>. ');     
            
        }
        
        action()
        {
            if(gDobj == oil)
            {
                "The <<contName>> is  now full of oil. ";
                myLiquid = 'oil';
            }
            else if(gDobj == wine)
            {
                "The <<contName>> is now full of wine. ";
                myLiquid = 'wine';
            }
            else if(gDobj.ofKind(StreamItem))
            {  
                "The <<contName>> is now full of water.";
                myLiquid = 'water';                   
            }
            /* We shouldn't reach this branch. */
            else
                "Oops! Something went wrong! ";            
        }
    }
    
    dobjFor(Fill)
    {
        precCond = [objHeld]
        
        verify()
        {
            if(hasWater || hasOil || hasWine)
                illogicalAlready('\^<<contName>> is already full. ');         
        }
        
        action()
        {
            local obj = gActor.getOutermostRoom.contents.valWhich({o: o.ofKind(StreamItem)});
            if(obj)
                doInstead(PutIn, obj, self);
            
            else if(oil.isIn(gActor.getOutermostRoom))
                doInstead(PutIn, oil, self);
            
            else if(wine.isIn(gActor.getOutermostRoom))
                doInstead(PutIn, wine, self);           
                
        }   
    }
    
    dobjFor(FillWith)
    {
        preCond = [objHeld]
        
        verify {}
        
        action()
        {
            doInstead(PutIn, gIobj, self);
        }
    }
    
    dobjFor(Empty)
    {
        verify()
        {
            if(isEmpty)
                illogicalAlready('\^<<contName>> is already empty. ');
        }
        
        action
        {
            if(gActor.getOutermostRoom == inWestPit)
                doInstead(PourOnto, self, plant);
            else
            {
                "\^<<contName>> is now empty and the ground is wet. ";
                empty();
            }
        }        
    }
    
    dobjFor(PourOnto)
    {
        preCond = [objHeld]
        verify()
        {
            if(isEmpty)
                illogicalNow('\^<<contName>> is empty. ');
        }
        
        action()
        {
            if(gIobj.ofKind(RustyDoor))
            {
                if(gIobj.isOiled && hasOil)
                    "There's no need to do that now -- {i}{'ve} already oiled this door. ";
                else if(hasOil)
                {
                    "The oil has freed up the hinges so that the
                    door will now move, although it requires some
                    effort. ";
                    gIobj.makeOiled(true);
                }
                else if(hasWater || hasWine)
                {
                    "The hinges are quite thoroughly
                    rusted now and won't budge.";
                    gIobj.makeOiled(nil); 
                }
                
                empty();
            }
            
            else if(gIobj == plant)
            {
                if(hasWater)
                    plant.water();
                else if(hasOil)
                {
                    "The plant indignantly shakes the oil
                    off its leaves and asks, \"Water?\" ";
                }
                
                else if(hasWine)
                {
                    "The plant drunkenly shakes the wine
                    off its leaves and asks, \"Water?\" ";
                }
                
                empty();
            }
            
            else if(gIobj.ofKind(Floor))
            {
                if(isIn(inWestPit))
                    doInstead(PourOnto, plant);
                else
                    doInstead(Empty, self);
                
                empty();
            }
            
            else
                "That doesn't seem productive. ";
            
            
        }
    }
    
    isEmpty = !(hasOil || hasWater || hasOil)
    
    empty()
    {
        myLiquid = nil;
    }
    
    dobjFor(Drink)
    {
        verify()
        {
            if(isEmpty)
                illogicalNow('\^<<contName>> is empty. ');
        }
        
        check()
        {
            if(hasOil)
                "I'd advise you not to drink the oil, you fool! ";
            
        }
        
        action()
        {
            empty();
            "\^<<contName>> is now empty. ";
        } 
        
    }
        
    
;

liquidState: State
    stateProp = &myLiquid
    
    additionalInfo = [
        ['water', ' of water'], ['wine', ' of wine'], ['oil', ' of oil']
    ]
    
    adjectives = [
        [nil, ['empty']], ['water', ['water', 'of']], ['oil', ['oil', 'of']], 
        ['wine', ['wine', 'of']]
    ]  
;

/*
 * Important notes about treasures:
 *
 * If you want to add treasures, use the CCR_treasure_item class.
 *
 * Each treasure is worth self.takepoints points when taken for the
 * first time, and an additional self.depositpoints when deposited
 * in the building.  Scoring is handled by the customized moveInto method 
 * (which adds the relevant object(s) to global.checklist) and by the
 * global.gendaemon code (which checks the position of all objects listed
 * in global.checklist). Be sure to update global.maxscore and scoreRank
 * if you add treasures (or anything else that gives the player points,
 * for that matter).  
 *
 * The proper way to check if an object is a treasure is:
 *
 *    if (isclass(obj, CCR_treasure_item))
 *        ...
 *
 */

class Treasure: Thing ';;treasures goodies'
    basis = 1
    takepoints
    {      // for taking the treasure.
        if (global.game550) return 2;
        else if (global.newGame) return basis*2;
        else return oldtakepoints;
    }
    
    depositpoints 
    { // for correctly depositing the item.
        if (global.game701) return 10;
        if (global.game550) return 13;
        else if (global.newGame) return basis * 3;
        else return olddepositpoints;
    }
    
    oldtakepoints = 2    // points for taking this treasure in old game
    olddepositpoints = 12    // points for putting in building in old game
    
    awardedpointsfortaking = nil
    awardedpointsfordepositing = nil
    
    targloc = safe          // Where to put it for full credit
    contloc = insideBuilding // location of target container or nil
                  // if this is not to be checked
    outercontloc = nil      // location of outer container or nil if
                  // this is not to be checked
                  // Note: in an 'old' (350 or 550 point)
                  // game, targloc, contloc
                  // and outercontloc are ignored and
                  // insideBuilding, nil and nil used
                  // instead, unless the oldkeep property
                  // is set to true.  This includes scoreable
                  // non-treasure objects.
    
    oldkeep = nil
    
    bonustreasure = nil
    
    dobjFor(Throw)
    {
        action()
        {
            if(troll.isIn(getOutermostRoom))
            {
                "\n(at the troll)\n";
                doInstead(ThrowAt, self, troll);
            }
        }
    }
       
    listWith = [treasureGroup]
    listOrder = 100
;

treasureGroup: ListGroupSorted
    listOrder = 200
;

class Coin: Thing
    isCoin = true
    freshBatteriesAvailable = 0
    
    
;

/* Will be implemented in end game file. */
class EndgameClone: object
    objclass = nil
    list = []
;

/* 2 */
/* 
 *   Rather than copy the TADS 2 implementation in full here, we make use of the adv3Lite
 *   FueledLightSoutce extension, which is designed for implementing this kind of object.
 */
brassLantern: FueledLightSource, EndgameClone, Flashlight 
    'brass lantern; electric shiny; lamp headlamp torch headlight'
    @insideBuilding
    "It is a shiny brass lamp<<if isLit>><<if fuelLevel <= 30>>, glowing dimly<<else>>, glowing
    brilliantly<<end>>.<<else>>. It is not currently lit.<<end>> "
    
    
    nosack = true
    mass = 1
    
    /* 
     *   The TADS 2 version calls this property turnsleft, but the FueledLightSource class calls
     *   this property fuelLevel.
     */
    fuelLevel = 650 
    
    setLife(v) 
    { 
        /* Not sure if this is needed. */        
        // if the lamp life was 0 or less, and we're now setting it
        // to a positive quantity, and the lamp is off, we turn off
        // the daemon.
        if(fuelLevel < 1 && !isOn && v > 0)
            stopFuelDaemon();
        
        /* But this probably is: */
        // if the lamp life was positive, and we're now setting it
        // to 0 or less, and the lamp is off, we turn on the daemon.
        if(fuelLevel > 0 && !isOn && v < 1)
            startFuelDaemon();
        
        // reset wandernote if we've recharged the batteries
        if(v > 0) 
            wandernote = nil;
        
        // change the number of turns to the desired value.
        fuelLevel = v; 
    }
    
    
    
    iobjFor(PutIn)
    {
        preCond = [touchObj]
        verify()
        {
            if(gVerifyDobj.ofKind(OldBatteries))
                illogicalNow('Those batteries are dead; they won\'t
                    do any good at all.');         
            else if(!gVerifyDobj.ofKind(FreshBatteries))
                illogical('The only thing {i} might successfully put in
                    the lamp is a fresh set of batteries. ');
        }
        check()
        {
            if (fuelLevel > 30 ) 
                "There's still life left in {my} batteries -- I
                wouldn't change them until {my} lamp starts to grow dim. ";            
        }
        action()
        {
            do_replace(gDobj);
            "Done. ";
        }
    
    }
    
    burnedOutMsg = 'Your lamp has run out of power'
    
    /* This method is called once per turn by the FueledLightSource class while the lamp is lit. */
    showWarning()
    {
        local toploc = gRoom;
        if(fuelLevel < 1)
        {
            if(replaceBatteries)
                ; //do nothing
            else if(toploc.isoutside && !toploc.nolampwarn && !wandernote)
            {
                wandernote = true;
                "<.p>Your lamp emits its final flicker\b
                You can't explore the cave without a lamp,
                and there's not much point in wandering around
                out here";
                if(global.newGame)
                    ", unless you want to explore the castle. If not, ";
                
                else
                    ". ";
                "I suggest you quit now";
                if (!destroyed && FreshBatteries.obtained > FreshBatteries.used) 
                {
                    if (global.game550) 
                        ", unless you can get
                        hold of those batteries, or find some
                        other way of recharging the lamp.
                        (As a special concession I'll allow you to
                        CHANGE BATTERIES in a dark room, if you
                        can reach it without falling into a
                        pit.) ";
                    else ", unless you can get hold of those
                        batteries.
                        (As a special concession I'll allow you to
                        CHANGE BATTERIES in a dark room, if you
                        can reach it without falling into a
                        pit.) ";
                }
                else
                {
                    if (!destroyed && global.game550)
                        ", unless you can find some way of
                        recharging the lamp. ";
                    else
                        ". ";
                }
                
            }
        }
        else if(fuelLevel == 30)
        {
            "Your lamp is getting dim. ";
            if(replaceBatteries)
                ; //do nothing
            else if (FreshBatteries.used >= FreshBatteries.available) 
            {
                // DMB: changed the wording of this
                // slightly for convenience.
                "You're also out of spare batteries.
                You'd best start wrapping this up. ";
            }
            // or are there some unused fresh batteries
            // around somewhere?
            else if (FreshBatteries.obtained >  FreshBatteries.used) 
            {
                "You'd best go back for those batteries. ";
            }
            else {
                "You'd best start wrapping this up,
                unless you can find ";
                if(FreshBatteries.obtained == 0) 
                {
                    "some fresh batteries.  I seem to recall
                    there's a vending machine in the maze.
                    Bring some coins with you. ";
                }
                else 
                    "a further set of batteries -- maybe
                there are more coins you can use in the
                vending machine.  ";
            }
                
        }
    }
    
    dobjFor(LookIn)
    {
        action()
        {
            "You open the lamp, revealing ";
            if (fuelLevel > 30)
                "a set of batteries. When the time comes to replace
                them, do PUT BATTERIES IN LAMP or CHANGE BATTERIES, if
                I haven't already done it for you. ";
            else if(fuelLevel > 0)
                "a set of nearly-dead batteries.  To
                replace them, do PUT BATTERIES IN LAMP or CHANGE BATTERIES. ";
            else
                "a set of worn-out batteries.  To
                replace them, do PUT BATTERIES IN LAMP or CHANGE BATTERIES.
                As a special concession, I'll allow you to do this even in
                a dark room. ";
            "You close the lamp again. ";
        }
    }
    
    replaceBatteries()
    {
        // modified - DJP.  It only happens automatically
        // if we are in a lit room, or the batteries are
        // in our possession.   But batteries can be
        // changed manually even in a dark room.
        
        //        local waslit gRoom.isLit;
        local i,o,l = FreshBatteries.list.length;
        for (i = 1; i <= l; i++) 
        {
            o = FreshBatteries.list[i];
            if (o.isIn(gRoom) && gPlayerChar.canSee(o) &&
                gPlayerChar.canReach(o) && (gRoom.isIlluminated || o.isIn(gPlayerChar)))
            {
                "\nI'm taking the liberty of replacing the batteries. ";
                self.do_replace(o);
                /* 
                 *   DJP - check whether the lamp has just lit the room and print the room
                 *   description if appropriate.
                 */
                /* Adv3Lite should handle this automatically */
                //                if (Me.location.islit and not waslit) {
                //                    "\n";
                //                    Me.location.enterRoom(Me);
                //                }
                return true;
            }
        }
        return nil;
    }
    
    do_replace(o)
    {
        o.delete();
        // create a set of used batteries and drop them
        local p = new OldBatteries;
        p.actionMoveInto(gPlayerChar.location.dropLocation);
        
        if(fuelLevel < 1 && !isOn)
            stopFuelDaemon();
        if (global.vnumber == 0)
            fuelLevel = 2500;
        else {
            // original 551-point Fortran version gave only 400
            // turns per set of batteries, but this seems ungenerous
            // compared with the old game.  So we give 1000 turns
            // for the first set of new batteries and 2500 turns
            // for the second.    In novice mode, we add another
            // 500 turns in each case.
            //
            // Similarly, the 550-point version only gave 300 turns for the
            // batteries, but we give 1000 or 1500 instead.
            //
            if (FreshBatteries.used == 1)
            fuelLevel = 1000;
            else
            fuelLevel = 2500;
            if(global.novicemode) 
                fuelLevel += 500;
        }
        wandernote = nil;
        // DJP -- allow one use of NOSIDE SAMOHT for each set of batteries.
        // (in accordance with original adv550 coding).
        isRelit = nil;
    }
    isRelit = nil
    
    dobjFor(Open) asDobjFor(LookIn)
    cannotCloseMsg = 'It\'s already closed. '
    
    dobjFor(Rub)
    {
        action()
        {
            "Rubbing the electric lamp is not particularly
            rewarding.  Anyway, nothing exciting happens. ";
        }
    }
    
    makeLit(stat)
    {
        inherited(stat);
        if(stat && isIn(crystalPalace))
            "Your lamp is now on, but the glare from the walls is
            absolutely blinding.  If you proceed you are likely to
            fall into a pit. ";
    }
    
    wontLightMsg = 'Unfortunately, the batteries seem to be dead. '
    
    wandernote = nil
    destroyed = nil
   
    
    // BJS: NOSIDE SAMOHT has been used to
    // recharge the lamp:
    magicRecharge()
    {
          
//        local i, ultloc, d = nil;    // Find room that lamp is in.
//        for (i = self; i != nil; i = i.location) 
//            ultloc = i;
        local ultloc = getOutermostRoom, d = nil;        
        
        if(gPlayerChar.isIn(ultloc) && ultloc.ofKind(DarkRoom)
            && !isRelit) 
        {
            // self.is_relit flags that NOSIDE SAMOHT has been used to
            // recharge the current set of batteries.  (In accordance with
            // the original acode source, we now allow one recharge per set
            // of batteries.  The acode source (but not the TADS port) also 
            // checks that the Sorcerer's Lair has been visited.

            // Note that the 660-point and 770-point games allow multiple
            // recharges with NOSIDE SAMOHT.  However, the 701(+) point
            // versions only allow one recharge per set of batteries.  There is
            // a good reason - the player can obtain one set of batteries
            // for free, using a set of non-treasure coins (lead slugs).

            //
            //  If player is in same room, which isn't lit, then:

            // Electrocute player if lamp is held.
            if (isIn(gPlayerChar)) 
            { 
                "With a sharp sizzling
                sound, a large spark of electricity
                jumps out of thin air and strikes
                your lamp.  The immense electrical
                charge flows to ground through your
                body and fries you to a crisp.    ";
                d = true;
            }

            // Blow up lamp if it's already charged.
            if (fuelLevel > 40) 
            {
                if (rand(2) == 1 && !d) 
                {
                    "With a loud \"zap\" a bolt
                    of lightning springs out of
                    midair and strikes your lamp,
                    which immediately and violently
                    explodes.  You narrowly miss
                    being torn to shreds by the
                    flying metal.<.p>"; 
                }

                else if (!d) 
                { 
                     "In a loud crackle
                    of electricity, a bolt of
                    lightning jumps out of nowhere
                    and strikes your lamp.    The
                    lamp instantly explodes like
                    a grenade, and you are mown
                    down by a cloud of shrapnel.";
                    d = true;
                }
                // Blow up the lamp.
                moveInto(nil); 
                makeLit(nil);
                setLife(0);
                destroyed = true;
            }
            // Otherwise recharge it. Give twice as many turns as in
            // original...
            else {
                isRelit = true;
                setLife(300); // But give more time in novice mode.
                if(global.novicemode) setLife(500);
                if(!d) makeLit(true);
                if(!d) "The air fills with tension,
                    and there is a subdued crackling sound.
                    A blue aura forms about your lantern,
                    and small sparks jump from the lantern
                    to the ground.  The aura fades away after
                    several seconds, and your lamp is once
                    again shining brightly.";
            }
                // Kill player if d is true:
            if (d) die();
        }
        else "Nothing happens."; // If lamp isn't in room, etc.
    
    }    
;

/* 4 */
wickerCage: EndgameClone, OpenableContainer 'empty wicker cage; small;birdcage' @inCobbleCrawl
    desc
    {
        if(contents.length > 0)
            "It's a small wicker cage. <.p>It contains  <<list of listableContents>>. ";
        else
            "It's a small empty wicker cage. ";
    }
    
    
    hasBird = contents.length > 0
    
    /* Adjust the vocabulary when a bird is put in or taken out. */
    altVocab = 'occupied wicker cage; small; birdcage'
    useAltVocabWhen = hasBird
    
    mass = 1
    
//    endgame_pile = wicker_cage_row
//    pass_class = container
    
    iobjFor(PutIn)
    {
        preCond = [touchObj]
        check()
        {
            if(!gDobj.ofKind(littleBird))
                "{The subj iobj} {is}n't suitable for anything but a bird. ";
            else if(contents.length > 0 )
                "There's already a bird in the cage. ";
        }
    }
    
    isTransparent = true
    contentsListed = nil
    
    
    dobjFor(Open)
    {        
        verify()
        {
            if(contents.length == 0)
                illogicalAlready('It\'s already open. ');
            else
                contents[1].verifyDobjDrop();
        }
        action()
        {
            local birdObj = contents[1];
            "(releasing the bird)\n";
            birdObj.actionDobjDrop();            
        }
    }
    
    dobjFor(Close)
    {
        verify()
        {
            if(contents.length > 0)
                illogicalAlready('It\'s already closed. ');
            else
                illogicalNow('There\'s little point closing the cage when it\'s empty. ');
        }
    }  
    
;

class WaveableRod: Thing
    
    dobjFor(Wave)
    {
        action()        
        {
            /* clear global.noAskWave (see thing.doWave) */
            global.noAskWave = nil;
            if (window.isIn(getOutermostRoom))
                "The shadowy figure waves back at you with a
                similar-looking rod, but nothing else happens. ";
            
            if (isIn(westSideOfFissure) || 
                isIn(onEastBankOfFissure)) 
            {
                if (global.closed && isupgraded)
                    "Peculiar.  Nothing happens.";
                else {
                    if (crystalBridge.exists)
                        crystalBridge.vanish(actor,self);                        
                    else
                        crystalBridge.appear();
                }
            }
            
            else if(decrepitBridge.isIn(getOutermostRoom) &&
                    isupgraded && !decrepitBridge.isfallen) 
            {
                "Nothing obvious happens. ";
                decrepitBridge.crosscount = -1;
            }
            
            else if(ricketyBridge.isIn(getOutermostRoom) &&
                    isupgraded && ricketyBridge.exists) 
            {
                "Nothing obvious happens. ";
                ricketyBridge.strengthened = true;
            }
            
            else if(isIn(atBreathtakingView) || isIn(valleyFaces)) 
            {
                if (!global.game550) 
                    "Nothing happens (in this version of Adventure). ";
                else if (global.closed && !isupgraded)             
                    "Peculiar.  Nothing happens. ";
                
                // In the 701-point game the rod must be upgraded before you
                // can create the bridge
                else if (global.game701 && !isupgraded) 
                    "Flakes of rust fall off the rod, but nothing else happens. ";            
                else 
                {
                    if (wheatStoneBridge.exists) 
                    {
                        "The earth shudders violently,
                        and steam blasts upward from
                        the geyser.  The wheat-stone
                        bridge cracks and splits, and
                        the fragments fall into the gorge. ";
                        //  wheatStoneBridge.moveInto(nil); // may not be needed 
                        wheatStoneBridge.exists = nil;
                    }
                    else {
                        "The earth begins to shudder
                        violently, and smoke flows up
                        from the gorge beneath your
                        feet.  With a violent <i>glop</i>,
                        the volcano belches out an
                        immense blast of molten lava
                        which flies into the air above
                        the gorge and suddenly solidifies
                        into a fragile-looking arch of
                        wheat-colored stone that bridges
                        the gorge. ";
                        //                    wheatStoneBridge.moveInto(
                        //                    [atBreathTakingView, valleyFaces]); // may not be needed
                        wheatStoneBridge.exists = true;
                    }
                }
            }
            // This is only possible in the 550-point or 701-point game.  In the 
        // latter, we require that the rod be upgraded.
            else if (isIn(coralPassage) || isIn(coralPass2)) 
            {
                if(global.closed && ! isupgraded)
                    "Peculiar. Nothing happens. ";
                else if(global.game701 && ! isupgraded) 
                    "Flakes of rust fall off the rod, but nothing else happens. ";            
                else {
                    // Don't soften the quicksand when the rod is waved again.
                    // That would be too difficult.
                    "Nothing obvious happens.";
                    quicksand.isHard = true;
                }
            }
        else
            "Nothing happens.";
            
        }
    }
    
    isupgraded = nil
    upgrade(stat)  {  isupgraded = stat;  }
;
   
State
    stateProp = &isupgraded
    adjectives = [[nil, ['rusty']], [true, ['shiny']]]
;


/* 5 */
blackRod: EndgameClone, WaveableRod 'black rod;rusty star magic ;wand' @inDebrisRoom
    desc()
    {
        "It's a three foot black rod with a <<if isupgraded>>shiny<<else>>rusty<<end>>
        star on an end. ";
        if (atSWEnd.visited)
        {
            "To distinguish this type of rod from the kind found at the
            southwest end, I'll refer to it as a \"star rod\" and to the
            other type as a \"marked rod\". ";
            name = 'star rod';
        }
    }   
    
    myHome = inDebrisRoom
    myHome2 = [inDebrisRoom]
    mass = 2
    disambigName = 'star rod'
    
//    downgrade() {}
;

/*
 * The following rod is actually an explosive.    The 350-point game
 * leaves the player to figure it out from a so-called hint, but
 * the 551-point game is more direct.
 *
 * I've added the words 'explosive' and 'dynamite' as nouns and adjectives,
 * and 'blast' as an adjective.     Perhaps this will give some lucky soul
 * a clue.
 *
 * Note that this object is never seen - it is in fact used as a class for
 * dynamic object creation.  However, it should NOT be defined as a class.
 * For the benefit of the score-checking routine, it should be left as
 * an object so that it will appear in the appropriate lists when they are
 * built by preinit.  In the 551-point game the appropriate score will be
 * given when any of its dynamically-created 'clones' is deposited in the
 * target location.
 *
 */

/* 6 */
blackMarkRod: EndgameClone, WaveableRod 'marked rod; 
    black rusty mark marked blast ;explosive dynamite' 
    "It's a three foot black rod with a rusty mark on an end.
        To distinguish the two types of rod, I'll refer to this
        type as a \"marked rod\" and to the other type as a
        \"star rod\". "
    
    mass = 2
    
    disambigName = 'marked rod'
   
    // This rod scores points in the 551-point game, but not in the 
    // 550-point and 701-point versions which use the 'cylindrical room' 
    // endgame.
    depositpoints = global.newGame && !global.game701 ? 2 : 0
    
    targloc 
    {
        if(global.newGame) 
            return inPhoneBooth2;
        else 
            return atNEEnd;
    }
    contloc = nil
    oldkeep = true

    dobjFor(Wave)
    {
        action()
        {
            global.noAskWave = nil;
            "Nothing happens.";
        }
        
    }
    
    iobjFor(BlastWith)
    {
        verify() {}
        action()
        {
            endPuzzle();
        }       
    }

    
;


/* 10 */
velvetPillow: EndgameClone, Surface 'velvet pillow' @inSoftRoom
    desc
    {     
        "It's just a small velvet pillow. ";
        if(contents.length > 0)    
            "<.p>Resting delicately on the pillow, you see <<list of listableContents>>. ";
    }
    
    iobjFor(PutOn)
    {
        check()
        {
            if(isIn(gActor))
                "{I} could at least drop {the iobj} first! ";
            else if(location.ofKind(Container))
                "{I} can't do that while {the iobj} is in a container. ";
                
        }  
    }
    
    dobjFor(Take)
    {
        check()
        {
            if (mingVase.isIn(self))
                "{I}'d better take the vase first. ";
            if (glassVial.isIn(self)) 
                "{I}'d better take the vial first. ";
        }
    }
    mass = 1
    
    
    listContents = nil
;


/* 14 */
giantBivalve: EndgameClone, Thing 'giant clam;bivalve shell enormous massive big huge tightly
        closed five foot five-foot 5-foot; oyzter clam' @inShellRoom
    "It's <<aName>> with its shell tightly closed. "

    
    mass = 7
    bulk = 4
    opened = nil
    isHuge = true
    
    dobjFor(Open)
    {
        check()
        {
            if(trident.isIn(gActor))
                //
                // In the original, "open clam" would work
                // as long as you were carrying the trident,
                // but this seems very prone to accidental
                // solving, and since we aren't limited to
                // two word parsing, I've just taken the
                // liberty of forcing the player to type
                // "open clam with trident."
                //
                "The clam can't be opened just like that.  {I}'ll have to open it
                <i>with</i> something. "; // DJP - made a little more user-friendly.
            // (we don't use askio because this might
            // choose the trident automatically)
            
            else
                "{I} {don't have} anything strong enough to open <<theName>>. ";
        }
    }
    
    dobjFor(OpenWith)
    {
        preCond = [touchObj]
        verify() {}
        
        check()
        {
            if(gIobj != trident)
                "{The subj iobj} {is}n't strong enough to open {the dobj}. ";
             
        }
        
        action()
        {
             if (opened) 
            {
                "The oyster creaks open, revealing nothing
                but oyster inside.  It promptly snaps shut
                again.";
            }
            else 
            {
                "A glistening pearl falls out of the clam and
                rolls away.  Goodness, this must really be an
                oyster.     (I never was very good at
                identifying bivalves.)    Whatever it is, it
                has now snapped shut again. <.reveal open-clam>";

                opened = true;
                name = 'giant oyster';
                pearl.actionMoveInto(inACulDeSac);
            }
        }
    }
    
    isBreakable = nil
    cannotBreakMsg = 'The shell is very strong and is impervious to attack. '
    cannotAttackMsg = cannotBreakMsg
;

/* 16 */
spelunkerToday: Thing 'recent issues of Spelunker Today;dwarvish; magazines issue issues;them'
    @inAnteroom
    desc
    {
        "I'm afraid the magazines are written in dwarvish. ";
        if (global.newGame) 
        {
             isRead = true;
            "However, two pictures attract {my} attention. ";
             if (safeCombination.seen) {
                 "One shows a dwarf sweeping the rock in the
                 Dusty Rock room, revealing the inscription. ";
             }
             else {
                 "One shows a dwarf brushing the
                 dust off a rock, revealing an inscription which looks like
                 a series of numbers - a date, perhaps? Unfortunately
                 you can't read them clearly. ";
             }
             if (throneRoom.seen) {
                 "Another picture shows the diminutive Mountain King
                 sitting on his throne, wearing his little crown and
                 holding a black rod with a shiny star on an end. ";
             }
             else {
                 "Another picture shows
                 a king sitting on a large, intricately-wrought throne.
                 He wears a heavy-looking crown, and he holds a long black
                 staff with a shiny metal star on one end. ";
             }
        }
        /* At least add a vague clue that the magazines should be left at Witts End. */
        "You're not sure how valuable they are, so you consider dumping them if you
        run out of ideas. ";
       read = true;
    }
    
    isRead = nil
    read = nil
    readDesc = desc
    takepoints = 0
    depositpoints = 1
    targloc = atWittsEnd
    contloc = nil
    oldkeep = true
    depositpointsawarded = nil
   
;

/* 19 */
tastyFood: Food 'some tasty food; yummy tasty; watercress rations sandwiches' @insideBuilding
    desc
    {
        if(global.newGame) 
        {
            "It's your favorite - watercress sandwiches.  They might not
            be to everyone's taste, though.";
        }
        else {
            "Sure looks yummy! However, something in the back of your
            mind cautions you against eating it.  This is an Adventure
            game, and the food may be needed for something else!";
        }
    }
    
    location551 = pantry
;
  

/* 20 */
bottle: LiquidContainer 'bottle' @insideBuilding
    
    
    mass = 1
    myLiquid = 'water'
    contName = 'the bottle'
    setup() 
    {
        myLiquid = nil;
    }
    location551 = pantry
    
    winocode()
    {        
        local newturns;
        "The wine goes to your head, and you feel very sleepy ...
        You awaken with a mild headache, and try to focus your
        eyes....\b"; 
        gPlayerChar.health = (gPlayerChar.health * 90) / 100;
        if(brassLantern.fuelLevel > 25 && brassLantern.isOn)            
        {
            newturns = brassLantern.fuelLevel - rand(brassLantern.fuelLevel)/10;
            if(newturns < 25)
                newturns = 25;
            brassLantern.setLife(newturns);
        }
            
    }
;

/* 28 */    
axe: Weapon 'dwarf\'s axe; little'
    desc()
    {
        if (nograb) 
        {
            if (gPlayerChar.isIn(bear.location))
                "It's lying beside the bear. ";
            else if (gPlayerChar.isIn(dog.location))
                "It's lying beside the dog. ";
            else if (gPlayerChar.isIn(wumpus.location))
                "It's lying beside the Wumpus. ";
        }
        else {
            "It's just a little axe.  It may be useful to throw
            it in self-defence";
            if (global.oldGame && !global.game550)
                ". ";
            else
                ", and in the case of dwarves you
                might try using it for hand-to-hand combat. ";
        }
    }
    
    mass = 3
    nograb = nil// hack for when you attack the bear etc. with it
   
    
    dobjFor(Take)
    {
        check()
        {
            if (nograb)
            {
                "No chance.  It's lying beside the ";
                if (gActor.isIn(bear.location))
                    "ferocious bear";
                else if (gActor.isIn(dog.location))
                    "hideous black dog";
                else if (gActor.isIn(wumpus.location))
                    "Wumpus";
                ", quite within harm's way.";
            }
            else
                inherited();
        }     
        
        action()
        {
            Dwarves.noAttack = true;
            inherited();
                
        }
    }
;

/* 101 */
littleBird: Thing 'litte bird; cheerful' @inBirdChamber
    "<<if location.ofKind(wickerCage)>>The little bird looks unhappy in the cage. 
    <<else>>The cheerful little bird is sitting here singing.<<end>> "
    
    aName = (isIn(wickerCage) ? inherited : 'a cheerful ' + name)
    theName = (isIn(wickerCage) ? inherited : 'the cheerful ' + name)
    mass = 2
    
    
    dobjFor(Take)
    {
        verify()
        {
            if(isIn(gActor))
                illogicalAlready('{I} already {have} the little bird. If
                    you take it out of the cage it will likely fly away from you. ');
        }
        check() 
        {
            cageObj = gActor.contents.valWhich({x: x.ofKind(wickerCage)});
            if(cageObj == nil)
                "{I} {can} catch the bird, but {i} cannot carry it. ";
            else 
            {
                cageObj = gActor.contents.valWhich({x: x.ofKind(wickerCage) && !x.hasBird});
                if(cageObj == nil)
                    "You have no empty cage in which to carry the bird. ";     
            }
        }
        action()
        {
            doInstead(PutIn, self, cageObj);
        }
    }
    
    cageObj = nil
    
    dobjFor(PutIn)
    {
        preCond = [touchObj]
        
        verify()
        {
            inherited();
            
            if(location.ofKind(wickerCage) && location != wickerCage)
                illogicalAlready('The bird is already in a wicker cage. ');
        }
        
        check()
        {
            local rodcond = true;
            if(global.oldGame && blackRod.isIn(gActor))
               rodcond = nil;
            if(global.oldGame && greyRod.isIn(gActor))
               rodcond = nil;
            if(global.newGame && gActor.canSee(blackRod))
                rodcond = nil;
            if(global.newGame && gActor.canSee(greyRod))
                rodcond = nil;
            if(!rodcond)
                "The bird was unafraid when {i} entered, but
                as {i} approach{es/ed} it becomes disturbed and {i}
                {cannot} catch it. <.reveal bird-scared>";
               
            else
            {               
                if(gIobj != wickerCage && !gIobj.ofKind(Room))
                    "Don't put the poor bird {in iobj}. ";
                
            }
            
        }
    }
    
    dobjFor(Drop)
    {
        preCond = [objVisible]
        verify()
        {
            if(!isIn(gActor))
                illogicalNow('{I}{\'m} not carrying {the dobj}. ');
        }
        
        action()
        {
            if(snake.isIn(getOutermostRoom))
            {
                "The little bird attacks the green snake, and
                in an astounding flurry drives the snake away.";
                
                actionMoveInto(snake.location);
                snake.moveInto(nil);
            }
            else if(dragon.isIn(getOutermostRoom))
            {
                "The little bird attacks the green dragon,
                and in an astounding flurry gets burnt to a
                cinder.  The ashes blow away. ";
                
                self.moveInto(nil);
            }
            else if(snakepit.isIn(getOutermostRoom))
            {
                "The little bird attacks the green snakes, and in an astounding 
                flurry chases the snakes away.  Some of them escape into the 
                Treasure Vault, but others head towards the north-eastern end of 
                the room where the dwarves are sleeping ... \n";
                //            end_dwarves();
            }
            else
            {
                actionReport('{I} release((s/d} the bird. ');
                inherited();                
            }
            
            
        }
    }
    
    listenDesc 
    {
        if (location.ofKind(wickerCage))
            "The little bird is sulking silently in its cage. ";
        else
            "The little bird is singing sweetly. ";
    }
    
;


/* 102 */
setOfKeys: Key, Surface 'set of keys;key; keyring ring key-ring ' @insideBuilding
    "It's a normal-looking keyring, to which several keys are attached"
    
    mass = 1
    location551 = pantry
    
    actualLockList = global.oldGame ? [grate, goldenChain] : [grate, goldenChain, treasureChest]
    plausibleLockList = [grate, goldenChain, treasureChest]
    
    keyDoesntFitMsg
    {
        if(!global.oldGame || gDobj != treasureChest)
            return inherited;
        return inherited + ' Still, it is obviously full of fabulously valuable treasures, so 
            we\'ll allow you the points for just leaving it in the building. ';
    }
    
    iobjFor(PutOn)
    {
        verify()
        {
            if(gDobj.isIn(self))
                illogicalAlready('{The subj dobj} (is} already on the ring. ');
            inherited;
        }
        
        check()
        {
            if(!gDobj.ofKind(Key))
                "{I} could only attach keys to the ring. ";
                
        }
    }
    actionDobjCount()
    {
        "There are about half a dozen keys on the ring";
        if (contents.length > 0)
            ", plus the keys which you have attached. ";
        else
            ". ";
    }
    iobjFor(AttachTo) { remap = [PutOn, gDobj, self] }
    iobjFor(FastenTo) { remap = [PutOn, gDobj, self] }
    iobjFor(DetachFrom) { remap = [TakeFrom, gDobj, self] }
;

/*
 * Treasures from the original version.
 */
/* 50 */
largeGoldNugget: Treasure 'large gold nugget; sparkling' @inNuggetOfGoldRoom
    "It's a large sparkling nugget of gold! "
    mass = 6
    basis = 2
    isLarge = true
    olddepositpoints = 10
    targloc = treasureChest
    
    
;

/* 51 */
severalDiamonds: Treasure '() several diamonds; high quality high-quality;;them' 
    @westSideOfFissure
    "They look to be of the highest quality! "
    mass = 2
    basis = 2
    theName = 'the diamonds'
    location551 = hallOfIce
    olddepositpoints = 10
;

/* 53 */
preciousJewelry: Treasure 'some precious jewelry; equisite' @inSouthSideChamber
    "It's all quite exquisite! "
    mass = 2
    olddepositpoints = 10
;

/* 54 */
rareCoins: Treasure, Coin 'rare coins;;;them' @inWestSideChamber
    "They're a numismatist's dream! "
    
    olddepositpoints = 10
    
    mass = 3
    basis = 5
;
    
/* 55 */
treasureChest: OpenableContainer, Treasure 'treasure chest' @deadEnd13
    desc  
    {
        if(global.oldGame) 
        {
            "It's the pirate's treasure chest, completely filled
            with riches of all kinds! ";
        }
        else {
            "It's the pirate's treasure chest, partly filled with
            riches of all kinds.   There's plenty of room
            for anything else you might want to store in there. ";
        }
        if(global.newGame) 
        {
            "At present it is ";
            if (isOpen) 
                "open";
            else 
            {
                "closed"; 
                if (isLocked) 
                    " and locked";
                else 
                    " but unlocked";
            }
            ".\n";
        }
    }

    lockability = lockableWithKey 
    
    mass = 5
    basis = 5
    spotted = nil
    targloc = insideBuilding
    contloc = nil
    bulkCapacity = global.newGame ? 500 : 0
    isHuge = true
;



/* 56 */
goldenEggs: Treasure 'nest of golden eggs; beautiful;egg;it them' @inGiantRoom
    "The nest is filled with beautiful golden eggs!"
    
    mass = 4
    basis = 3
    olddepositpoints = 14       
;

/* 57 */
trident: Treasure 'jeweled trident; jewel-encrusted encrusted fabulous' @inCavernWithWaterfall
    "The trident is covered with fabulous jewels! " 
    
    mass = 3
    basis = 2
    olddepositpoints = 14
    targloc = treasureChest    
    location551 = blueGrottoEast    // changed for 551-point version
   

    isLarge = true

    iobjFor(OpenWith)
    {
        preCond = [objHeld]
        verify() {}
        
    }
;

/* 58 */
mingVase: Treasure'ming vase; delicate precious; pottery' @inOrientalRoom
    "It's a delicate, previous, ming vase!"
    
    mass = 2
    basis = 2
    olddepositpoints = 14
    oldkeep = true
    
    /* 
     *   For full credit, the pillow puzzle must normally be solved! Putting the
     *   vase in the sack or chest is possible but won't do.  There is one
     *   exception - if we succeed in dropping the vase in the building without
     *   breaking it.  This should only be possible if the player gets killed in
     *   the building.
     */
    
    targloc = (location == insideBuilding) ? location : velvetPillow
    contloc = (location == insideBuilding) ? nil : inherited()
      
    
    shatter() 
    {
        moveInto(nil);
        shards.moveInto(gActor.getOutermostRoom);
    }
    
    dobjFor(Break)
    {
        verify() {}
        action()
        {
            "{I} {have} taken the vase and hurled it delicately to the ground. ";
            shatter();
        }
            
    }
    
  
    
    dobjFor(Drop)
    {
        
        
        action()
        {
            local toproom = gActor.getOutermostRoom;
            // in soft room, vase can simply be dropped safely on the
            // floor - DJP
            if(toproom.softfloor)
                inherited();
            // or in any other room where the pillow is in the
            // normal location for dropping objects.  (However we exclude
            // the case where the player's room has the smashdrop property;
            // this is set when objects fall down to another room).
            else if(velvetPillow.location == toproom)
            {
                "The vase is now resting, delicately, on a velvet pillow. ";
                actionMoveInto(velvetPillow);
            }
            // otherwise, vase shatters.
            else
            {
                "The ming vase drops with a delicate crash. ";
                shatter();
            }
        }
    }
;

shards: Thing 'worthless shards of pottery;;;them'
    desc
    {
        "They're just worthless shards of pottery";

        if (location.ofKind(Room))    // not in a container
            ", littered everywhere.";
        else
            ".";

        " They look to be the remains of what was once a
        beautiful vase. I guess some oaf must have dropped it.";
    }
    mass = 2
    bulk = 3 // shards are hard to carry, except in a container
    
;

/* 59 */
eggSizedEmerald: Treasure 'egg-sized emerald' @inPloverRoom
    "Plover's eggs, by the way, are quite large. "
    
    isLit = true
    mass = 3
    basis = 3
    olddepositpoints = 14
;

/* 60 */
platinumPyramid: Treasure 'platinum pyramid' @inDarkRoom
    "The platinum pyramid is 8 inches on a side! "
    mass = 4
    basis = 4
    olddepositpoints = 14
;

/* 61 */
pearl: Treasure 'glistening pearl; ncredible incredibly large'
    "It's incredibly large! "
    
    mass = 1
    basis = 4
    olddepositpoints = 14

;

/* 62 */
/* 
 *   This is one of the most complicated objects in the game.  It can be carried, but it is also a
 *   nestedroom on which the player can sit, lie or stand. In the 580-point game it is also a means
 *   of transport. It also behaves like a vehicle when Transindection movements are made.
 *
 *   MORE COMPLEX BEHAVIOUR TO BE IMPLEMENTED LATER
 */
persianRug:Treasure, Platform 'Persian rug; fine finest' @inSecretCanyon
    desc
    {
        if (dragon.isIn(self))
            "The dragon is sprawled out on the Persian rug!!";
            else if (!self.isIn(gPlayerChar))
            "The Persian rug is spread out on the floor here.";
            else
            "The Persian rug is the finest {i}{'ve} ever seen!";
            if(isActive) " It is floating in midair!";
            if(contents.length > 0)         
            "<.p>On the rug, {i} {see} <<list of contents>>. ";
        
        
    }
    
    initSpecialDesc = "\^<<mention a dragon>> bars the way!
        \bYou see a Persian rug here (on which the dragon is sprawled out). "
    useInitSpecialDesc = dragon.isIn(self)
    
    specialDesc = "The Persian rug is floating in mid-air. "
    useSpecialDesc = isActive
    
    isFixed = nil
    isActive = nil
    mass = 3
    basis = 3
    olddepositpoints = 14
    targloc = insideBuilding
    isVehicle = isActive
    isHuge = true
    isdroploc = true
    
    softfloor = location && location.softfloor
    
    dobjFor(Take)
    {
        check()
        {
            if(dragon.isIn(self))                
                "{I}'ll need to get the dragon to move first! ";
            else if(isActive)
                "The rug floats away from {me} every time {i} try to grab it.";
            else if(listableContents.length == 1)
            {
                local o = listableContents[1];
                "{I}'d better remove <<o.theName>> first. ";
            }
            else if(contents.length > 1)
                "There are objects on {tne dobj}.  {I}'d better remove them first.";
        }
    }
    
    /* If we purloin for testing purpoases, we presumably don't want the dragon with it. */
    dobjFor(Purloin)
    {
        action()
        {
            if(dragon.isIn(self))
                dragon.moveInto(location);
            inherited();
        }
    }
    
    verifyDragon()
    {
        if(dragon.isIn(self))
            illogicalNow('That would be unwise. {I}\'d better get the dragon to move first. ');
    }
    
    verifyDobjBoard()
    {
        verifyDragon();
        inherited();
    }
    verifyDobjStandOn()
    {
        verifyDragon();
        inherited();
    }
    verifyDobjSitOn()
    {
        verifyDragon();
        inherited();
    }
    verifyDobjLieOn()
    {
        verifyDragon();
        inherited();
    }
    
    verifyIobj(PutOn)
    {
        verifyDragon();
        inherited();
    }
    
    dobjFor(Ride) asDobjFor(Board)
    
    proper = nil    
;

RemapCmd 'fly (|persian) rug'
    execute()
    {
        if(!gActor.canSee(persianRug))
            "I see no rug here. ";
        else if(!global.game580)
            "Only wizards can do that. ";
        else if(!persianRug.isActive)
            "It doesn't look ready to fly. ";
        else if(!gActor.isIn(persianRug))
        {
            if(tryImplicitAction(Board, persianRug))
                "(first getting on the rug)\nJust say which way you want to go. ";
            else
                "That doesn't seem possible right now. ";
        }
        else
            "Just say which way you want to go. ";            
    }
;


/* 63 */
rareSpices: Treasure 'rare spices;exotic;spice;them' @inChamberOfBoulders
    "They smell wonderfully exotic! "
    smellDesc = "The spices smell wonderfully exotic! "
    
    
    mass = 1
    olddepositpoints = 14
    
;

/* 64 */
goldenChain: Treasure 'golden chain' @inBarrenRoom
    desc
    {
        "The chain has thick links of solid gold!";
        if (isLocked) {
            if (bear.wasReleased)
                "It's locked to the wall! ";
            else
                " The bear is chained to the wall with it! ";
        }
    }
    
    
    mass = 3
    basis = 4
    olddepositpoints = 14
    
    lockability = lockableWithKey
    isLocked = true
//    isFixed = isLocked
    isOpenable = true
    isOpen = nil
    
    dobjFor(Lock)
    {
        check()
        {
            if(!isIn(inBarrenRoom))
                "There is nothing here to which the chain can be locked. ";               
        }
    }
    
    dobjFor(LockWith) { check() { checkDobjLock(); }}
    
    dobjFor(Unlock)
    {
        check()
        {
            if (!bear.wasReleased && !bear.isTame)         
                "There is no way to get past the bear to
                unlock the chain, which is probably just as
                well.";
        }
    }
    
    dobjFor(UnlockWith) { check() { checkDobjUnlock(); }}
    
    makeLocked(stat)
    {
        inherited(stat);
        if(stat == nil)
            bear.wasReleased = true;
    }
    
    dobjFor(Take)
    {
        check()
        {
            if (!bear.wasReleased)             
                "It's locked to the <<bear.isTame ? 'friendly' : 'ferocious'>> bear! ";            
            else if (isLocked)
                "The chain is still locked to the wall. ";
        }
    }
    
    specialDesc
    {
        "There is a golden chain here, ";
        if (bear.wasReleased)
             "locked to the wall.";
        else
            "and a large cave bear is locked to the wall with it!";
    }
    
    useSpecialDesc = isLocked
;

barsOfSilver: Treasure 'bars of silver;;;them' @lowNSPassage
    "They're probably worth a fortune!"
    game350 = true    // Note that this implies game550 by default
    olddepositpoints = 10
    
    isHidden = !global.game350
;




//pirates: MultiLoc, Thing
//;


/* Provided here for testing purposes for now. */
goldCoin: Coin 'gold coin'
;


class FreshBatteries: Thing 'sets of fresh batteries;;;them'
    "They look like ordinary batteries.  A sepulchral
        voice says, \"Still going!\""
    
    initSpecialDesc = "Some fresh batteries lie on the floor just in front of the vending
        machine. "
    
    available = true
    mass = 3
    isEquivalent = true
    
    used = 0
    obtained = 0
    construct() 
    { 
        moved = nil;
        FreshBatteries.obtained++ ;
        FreshBatteries.list += self;
    }
    
    delete()
    {
        FreshBatteries.used++;
        FreshBatteries.list -= self;
        moveInto(nil);        
    }
       
    
    dobjFor(TakeFrom)
    {
        check()
        {
            if(gIobj == brassLantern)
                "To replace the batteries in the lamp, do
                PUT BATTERIES IN LAMP or CHANGE BATTERIES. ";
        }
    }
    dobjFor(Change) asDobjFor(Replace)
    
    dobjFor(Replace)
    {
        preCond = [touchObj]
        verify()
        {
            if(!gActor.canSee(brassLantern) || !gActor.canReach(brassLantern))
                illogicalNow('You can\'t do that unless the lamp is at hand. ');
        }
        
        check()
        {
            if (brassLantern.fuelLevel > 30 )                 
                "There's still life left in your batteries - I
                wouldn't change them until your lamp starts to
                grow dim. ";
        }
        
        action()
        {
//            local waslit = actor.location.isLit;
            brassLantern.do_replace(self); // may need changing
            "Done. ";
        /* 
         *   DJP - check whether the lamp has just lit the room and print the room description if
         *   appropriate. But adv3Lite should handle that automatically. 
         */
        
            
        }
        
        list = []
        
        /* 
         *   The player is more likely to mean fresh batteries than dead ones if they just refer to
         *   batteries.
         */
        vocabLikelihood = 10
    }
    
    
;

class OldBatteries: Thing 'set of worn-out batteries;old worn (out) worn-out dead dry flat
    discharged ;battery sets; it them'
    "They look like ordinary batteries.  A sepulchral voice says: \"They're now useless.\" "
    mass = 3
   isEquivalent = true
    
    dobjFor(TakeFrom)
    {
        check()
        {
            if(gIobj == brassLantern)
                "To replace the batteries in the lamp, do
                 PUT BATTERIES IN LAMP. ";
        }
    }
    
    dobjFor(Change) asDobjFor(Replace)
    dobjFor(Replace)
    {
        preCond = [touchObj]
        verify()
        {
             if(!gActor.canSee(brassLantern) || !gActor.canReach(brassLantern)
        || !(gActor.location.isLit || brassLantern.isIn(gActor)))
                illogical('{I} can\'t do that unless the lamp is at hand. ');
        else
            illogical ('Those batteries are dead; they won\'t do any good at all. ');
        }
    }
;

class ContLiquid: VarLoc, Fixture
    mycont = nil
    myflag = nil
    calcLocation = (mycont.(myflag) ? mycont : nil)
    dobjFor(Take) {remap = mycont ?? nil}
    dobjFor(Drop) {remap = mycont ?? nil}
    dobjFor(PourOnto) {remap = mycont ?? nil}
    dobjFor(Drink) {remap = mycont ?? nil}
    dobjFor(GiveTo) {remap = mycont ?? nil}
    verifyDobjThrowAt() { if(mycont) mycont.verifyDobjThrowAt(); }
    verifyDobjThrowTo() { if(mycont) mycont.verifyDobjThrowTo(); }  
    checkDobjPutIn()
    {
        "{The subj iobj} would leak all over the place if you tried to put liquids in it. ";
    }
    /*  
     *   In case there is any rogue code which tries to move the liquid, anywhere but nil or its
     *   proper container the moveInto method will move the container instead.
     */
    
    moveInto(loc)
    {
        if(loc is in (nil, mycont))
            inherited(loc);
        else
            mycont.moveInto(loc);
    }       
;

/* 81 */
waterInTheBottle: ContLiquid 'water in the bottle; bottled'
    "It looks like ordinary water to me."
    mycont = bottle
    myflag = &hasWater
    aName = 'water'
    theName = 'the bottled water'    
;

/* 83 */
oilInTheBottle: ContLiquid 'oil in the bottle; bottled'
   "It looks like ordinary oil to me. "
    mycont = bottle
    myflag = &hasOil
    aName = 'oil'
    theName = 'the bottled oil'    
;
 

greyRod:Thing 'gray rod'
;

brokenPendant: Thing
;

transindectionKey: Thing;



