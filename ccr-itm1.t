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
            "The bees are swarming around the flowers, and %you% can't get
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
            "The hum of the bees rises to an angry buzz as [i]
            move{s/d} towards the flowers. ";
    }    
;

/*
 *   Treasures
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
    
    yankobj = (!moved)        
    
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

/* 96 */
honeycomb: Food 'sweet honeycomb; honey; comb'
    "It looks delicious, but something in the back of your mind
    cautions you against eating it - you may need it for something else. "
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
    
    
    
//    doCount(actor) = {
//        if (self.iseaten) pass doCount;
//        else 
//            "There's something strange about these cakes which makes it hard
//            to count them accurately, but there appear to be about a dozen
//            of them. ";
//    }
;


/* 108 */
sack: BagOfHolding, OpenableContainer 'leather sack;;bag' @insideBuilding    
        "It's a capacious leather sack, large enough to
        hold most objects.  "
        
    game551 = true
    
    openStatusReportable = UsePronoun
    
    affinityFor(obj)
    {
        if(obj.isLong || obj.isLarge || obj.isHuge || 
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

/* 110 */
rareBook: Treasure 'rare book; dusty leather-bound leather bound; volume' @safe
    "It's a dusty, leather-bound volume. It looks very valuable! "
    game551 = true
    
    mass = 3
    basis = 2
    
    
;

/* 113 */
poster: Thing 'poster; faded' @insideBuilding
    "The poster has a picture of a thin man with a long white beard.
    He is wearing a high pointed cap embroidered with strange symbols,
    and he is pointing a finger at you.  Below the picture are the words:
    <q>I want you!--To report all good ideas for extensions to this game
    to me without delay.  Remember: ask not what ADVENTURE can do to
    you; ask what you can do for ADVENTURE.\ \n
    -\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ *  *  * \n
    A public service of the John Dillinger Died for You Society.</q>" 
    
    
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
  whiskbroom: Thing 'small whiskbroom; whisk; broom brush' //@tongueOfRock
    
    game551 = true
    mass = 1
    iobjFor(CleanWith)
    {
        preCond = [objHeld]
        verify() {}
    }
 
    iobjFor(SweepWith) asIobjFor(CleanWith)
    
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

mushroom: Thing;