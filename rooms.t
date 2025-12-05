#charset "us-ascii"

#include <tads.h>
#include "advlite.h"




class AlikeMazeRoom: DarkRoom 'Maze of Twisty Little Passages, All Alike'
    "{I} {am} in a maze of twisty little passages, all alike. "
    mazeskip = alikeMazeSkip
;

/*
 * A class for the dead ends.
 */
class DeadEndRoom: DarkRoom 'At a Dead End'
    "{I} {have} reached a dead end. "    
;

modify StairwayUp
    checkDobjCount = "You have better things to do than count steps and stairs. "
;

modify StairwayDown
    checkDobjCount = "You have better things to do than count steps and stairs. "
;

modify DSStairway
    checkDobjCount = "You have better things to do than count steps and stairs. "
;


/* A class to allow players who hate mazes to escape the tedium of having to navigate them. */
class MazeSkipConnector: VarDest, TravelConnector
    destList = []
    destIdx = 1
    calcDest()
    {
        if(destIdx > 0)
            return destList.element(destIdx);
        return nil;    
    }
    travelDesc()
    {
        "{I} {am} rapidly transported through the maze until {i} arrive{s/d} at...\b";
        if(destIdx < destList.length)
            destIdx++;
        else
            destIdx = 1;
    }
    
;


/*
 * A class for rooms that are outside the cave.
 * These rooms are off limits when the cave is closing (except when the player
 * has escaped from the Cylindrical Room; the inside rooms are then
 * off-limits.)
 */
class OutsideRoom: NotFarIn, NoNPC, Room 
    isoutside = true
    regions = [outdoors]
;

/* 
 *   Objects that can stand in for any holes or passages in rooms that define the hole or passage
 *   pseudo-direction  property respectively.
 */
ProxyExit 'hole'
    "It's just a hole. "
    exitProp = &hole
    travelAction = Hole
    notImportantMsg = 'You can just type HOLE to go through it. '
;

ProxyExit 'passage; very narrow steep large small cavernous shallow steeper little coral another
    low wide obvious (hands) (and) knees walking good gently sloping dark larger other short
    east-west main smaller only' 
    desc()
    {
        if(gRoom.propType(exitProp) == TypeDString)
            gRoom.(exitProp);
        else if(gRoom.propType(exitProp) == TypeSString)
            say(gRoom.(exitProp));
        else
            "Passages are just passages. ";
    }    
    
    exitProp = &passage
    travelAction = PassageAction
    notImportantMsg = 'If it\'s the only passage here, you can just type PASSAGE to go through it.
        Otherwise you\'ll have to say which way you want to go. '
    dobjFor(GoAlong) asDobjFor(TravelVia)
    dobjFor(Follow) asDobjFor(TravelVia)
    dobjFor(ClimbDown) asDobjFor(TravelVia)
    dobjFor(ClimbUp) asDobjFor(TravelVia)
    decorationActions = inherited + [Follow, GoAlong, ClimbDown, ClimbUp]
;

outdoors: Region
;

indoors: Region
;

class NoNPC: Room
    noNPCs = true
;


/*
 * A class for rooms that are in a building or cavern but outside the
 * cave proper.
 */
class IndoorRoom: OutsideRoom
    isindoor = true
    regions = [indoors]
;

/*
 * A class for rooms that aren't far enough in to earn the player
 * the bonus for getting "well in."
 *
 * See the definition of basicMe in advmods.t for info on how this is used.
 */
class NotFarIn: NoNPC, Room
    notfarin = true
;

/* 
 *   We define a more elaborate DarkRoom class here than the TADS 2 version does since we want to
 *   suppress exit listing in the dark and also handle the risk of falling into a pit here.
 */
class DarkRoom: Room
    isLit = nil
    
    /* Travel in the dark is allowed, but perilous */
    allowDarkTravel = true
    
        
    /* 
     *   Since we can travel in the dark we need to select which version of our can't travel that
     *   way to message according to the available light level.
     */
    cannotGoThatWay(dir)
    {
        if(isIlluminated)
            inherited(dir);
        else
            cannotGoThatWayInDark(dir);
    }
    
    /* Travelling in the dark carries the risk of falling into a pit, with fatal consequences. */
    cannotGoThatWayInDark(dir)
    {
        "{I} {am} blundering around blindly in the dark. You might easily fall into a pit. ";
        pitfall();
    }
    
    travelDesc() 
    { 
        if(!isIlluminated && !gActor.isThereALightSourceIn(gActor.allContents))
            pitfall(); 
    }    
    
    pitfall()
    {
        /* 
         *   This should give a 1 in 4 chance of falling into a pit, since rand(4) should generate a
         *   random number between 0 and 3
         */
        if(rand(4) > 2)
        {
            "Oh dear! You have fallen into a pit!";
            die();
        }
    }
    
    /* Suppress exit listing in the dark. */
    listStatusExits(lst, cnt)
    {
        if(isIlluminated)
            return true;
        else
            "too dark to discern";
        return nil;
    }
    
    listExits(lst, cnt)
    {
        return listStatusExits(lst, cnt);
    }
    
;

/* Also necessary to allow travel in the dark. */
modify TravelConnector
    visibleInDark = true
;

class RoomLiquid: Fixture
    contlist = [bottle, flask, cask]
    
    liquid = ''
    
    getCont() 
    {
        local actor = gActor;
        local i, o, l, cur;
        i = 1; o = nil; l = length(contlist);
        while (i <= l && o == nil) 
        {
            cur = contlist[i];
            // find the first empty, unsealed container in the list
            if(cur.isIn(actor) && actor.canReach(cur)
            && !! (cur.hasWater || cur.hasOil || cur.hasWine || cur.isSealed))
                o = cur;
            i++;
        }
        return o;
    }
    
    hasWater = nil
    hasOil = nil
    hasWine = nil
    isSealed = nil
    
    carryingCont = nil
    
    dobjFor(Take)
    {
        verify()
        {
            
        }        
        
        check()
        {
            carryingCont = getCont();
            if(carryingCont == nil)
                "{I} {have} nothing in which to carry the <<liquid>>. ";
            else if (!carryingCont.isOpen)               
                "{I}'d have to open <<carryingCont.theName>> before {i} could put
               anything into it. ";
        }
        
        action()
        {
            actionMoveInto(carryingCont);
            "{I} {put} some <<liquid>> in <<carryingCont.theName>>. ";
        }
    }
    
    dobjFor(PutIn)
    {
        preCond = [touchObj]
        
        verify()
        {
            if(contlist.indexOf(gIobj) == nil)
                illogical('{The subj iobj} would leak all over the place if {i} tried to carry
                    liquids in it. ');
        }
    }
;
    
    
class StreamItem: RoomLiquid
    liquid = 'water'
 
    hasWater = true
    
    dobjFor(Drink)    
    {
        preCond = [touchObj]
        verify() {}
        action()
        {
            "{I} {have} taken a drink from {the dobj}. The water
            tastes strongly of minerals, but is not unpleasant.
            It is extremely cold.";
        }
    }
;     


atEndOfRoad: OutsideRoom 'At End of Road'
    "{I} {am} standing at the end of a road before a
    small brick building. Around {me} is a forest.  A
        small stream flows out of the building and down a gully. "
    
    west = atHillInRoad
    up asExit(west)
    road asExit(west)
    
    in = insideBuilding
    east asExit(in)
    
    south = inAValley
    down asExit(south)
    
    north = inForest1
    
    downstream = inAValley
    gully = inAValley
    stream = inAValley
    forest = inForest1
    depression = outsideGrate    
    toKnoll = knoll
    thunder = thunderHole
    hole = thunderHole
    
    nolampwarn = true
;

+ walls: Decoration 'walls;;wall;them'
    "The buiiding has four of them. "
    decorationActions = inherited + ThrowAt 
;

MultiLoc, Enterable 'building; small brick well; house wellhouse'
    "It's a small brick building.  It seems to be
     a well house."
    connector = insideBuilding
    locationList = [atEndOfRoad, atHillInRoad]    
    checkReach(actor)
    {
        if(!actor.isIn(atEndOfRoad))
            "It's too far away. ";
    }
;


MultiLoc, Decoration 'forest; surrounding open hardwood oak maple pine
    spruce birch ash berry; tree trees oak maple grove pine
    spruce birch ash saplings bushes leaves; it them'
    
    "The trees of the forest are large hardwood oak and
        maple, with an occasional grove of pine or spruce.
        There is quite a bit of undergrowth, largely birch
        and ash saplings plus nondescript bushes of various
        sorts.  This time of year visibility is quite
        restricted by all the leaves, but travel is quite
    easy if {i} detour{s/ed} around the spruce and berry
        bushes."
    
    decorationActions = [Examine, Climb]
    
    locationList = [atEndOfRoad, atHillInRoad, inForest1, inForest2, inForest3,inAValley]
    
    cannotClimbMsg = 'None of the trees appear to be easily climbable. '
    
    actionDobjCount = "There is one forest, but you can't possibly count all the treees. "
;

MultiLoc, Decoration 'road;;street path'    
    locationList = [atEndOfRoad, atHillInRoad,inForest2]    
;

MultiLoc, Decoration 'gully'
    locationList = [atEndOfRoad, atSlitInStreambed, outsideGrate]
;



MultiLoc, StreamItem 'stream; small tumbling splashing babbling rushing
        reservoir stream large;water brook river spring'
    "<<if gActor.isIn(insideBuilding)>>The stream flows out through a pair of 1
    foot diameter sewer pipes.<<else>>It looks like an ordinary stream to me.<<end>> "
    
//    loclist = [
//        At_End_Of_Road  In_A_Valley  At_Slit_In_Streambed
//        In_Pit  In_Cavern_With_Waterfall
//        Inside_Building Pantry Green_Lake_Room Muddy_Defile
//        Fairy_Grotto Bubble_Chamber Red_Rock_Crawl
//    ]
    
    locationList = [atEndOfRoad, inAValley, insideBuilding, atSlitInStreambed]
    
    listenDesc = "You hear the sound of running water, splashing along the
                 bed of the stream. "
;

/* 2 */
atHillInRoad: OutsideRoom 'At Hill in Road'
    "{I} {have} walked up a hill, still in the forest.
        The road slopes back down the other side of the
        hill.  There is a building in the distance. "
    
    east = atEndOfRoad
    down asExit(east)
    north asExit(east)
    building asExit(east)
    
    road = atEndOfRoad
    fore asExit(east)
    forest: VarDest, TravelConnector
    {
        calcDest = (global.newGame && rand(100) < 30) ? inForest3 : inForest1
    }
    
    west: TravelConnector -> inForest3
    {
        isConnectorApparent = global.newGame
    }
    
    
;

+ Distant 'other side of[prep] the hill' 
    "Why not explore it yourself? "
;

/* 3 */
insideBuilding: IndoorRoom 'Inside the Building' 'inside the building;well; house'
    "{I} {am} inside the building, a well house for a large spring.  
    <<if global.newGame>>On the north side, through an open doorway,
    is a small pantry.<<end>> "    
 
    out tcMsg(atEndOfRoad, "{I} step{s/ed} outside. ")
    west asExit(out)
    nolampwarn = true
    
    xyzzy ulMsgExit(inDebrisRoom, "{I am} translated in the twinkling of an eye. ")
    plugh = atY2    
    
    /* We musn't use a room name as a property */
    to_pantry asExit(north)
    in asExit(north)    
    
    north: TravelConnector -> pantry
    {
        isConnectorApparent = global.newGame
    } 
    
    stream = "The stream flows out through a pair of 1 foot
        diameter sewer pipes. It would be advisable to use
        the exit. "
    downstream = stream
    passage asExit(in)
    
    click = rainbowRoom // if slippers worn 551 point game
      
    
    floorObj = concreteFloor
;

+ Decoration 'pair of 1 foot diameter sewer pipes[n]; ;pipe; it them'
    
;



+ ProxyDest, Enterable 'pantry;open;doorway'
    "The pantry is a small room through an open doorway on the north side of the building. "
    connector = pantry
    game551 = true
    
    dobjFor(LookIn) asDobjFor(Enter)
    dobjFor(Search) asDobjFor(Enter)
    dobjFor(GoThrough) asDobjFor(Enter)
    cannotPutInMsg = 'That would be easier if you first took {the dobj} into the pantry. '
    
//    iobjFor(PutIn)
//    {
//        preCond = [actorInPantry]
//        verify() {}
//        check() { safe.checkIobPutIn(); }
//        action()
//        {
//            gDobj.actionMoveInto(pantry);
//        }
//    }
                   
;


+ safe: Fixture, OpenableContainer 'steel safe; steel (wall) combination ;door'
    desc
    {
        "It's a very solid-looking combination safe, embedded in
        the wall. At present it is <<isOpen ? 'open' : 'closed'>>.\n ";
        
        if (!isOpen) 
            "To the right of the door there is a dial numbered from
            0 to <<safeDial.maxSetting>>.  You note that the 0 setting is
            marked \"Reset\".  The dial is currently set
            to <<safeDial.curSetting>>. ";
        
        else  if(listableContents.length > 0) 
            "It contains <<list of listableContents>>. ";       
        
    }
    
    specialDesc = "A steel safe is embedded in the wall. "    
    
    game551 = true    
    isHidden = true
    bulkCapacity = 1000
    noBird = true
    
    lockability = indirectLockable
    indirectLockableMsg = 'You\'ll have to tell me how to do that. '
    
    dobjFor(UnlockWith)
    {
        verify()
        {            
            if(!isLocked)
                illogicalAlready('The safe is already unlocked! ');
            else if(gVerifyIobj.ofKind(Key))
                illogical('This is a combination safe. {The subj iobj} won\'t help. ');
            else if(gVerifyIobj != safeDial)
                illogical('{I} {can\'t} unlock a combination safe with {a iobj}. ');
               
        }
        
        check()
        {
            if(gIobj == safeDial)
                "It's obvious that the dial has something to do with opening
                the safe, but you'll have to be more specific than that! ";
        }
    }
    
    dobjFor(OpenWith) asDobjFor(UnlockWith)
    
    dobjFor(Close)
    {
        action()
        {
            inherited();
            "The safe's door clicks shut. ";
            makeLocked(true); // not in TADS 2 code but seemingly implied.
            
        }
    
    }
    
    iobjFor(PutIn)
    {
        check()
        {
            if(gDobj.isLong)
                "{The subj dobj) {is} too long to go into {the iobj}. ";
            else if(gDobj.isLarge)
                "{The subj dobj) {is} too large to go into {the iobj}. ";
            else if(gDobj.isHuge)
                "{The subj dobj) {is} far too large to go into {the iobj}. ";
            else if(gDobj == mingVase)
                "{The subj dobj} won't quite fit {in iobj). ";
            else if(gDobj == wickerCage && littleBird.isIn(wickerCage))
                "Are you kidding?  Do you want to suffocate the poor bird? ";
            else if(gDobj.ofKind(PendantItem) && gDobj != brokenPendant)
                "A strange feeling of insecurity comes over you as you place
                {the dobj} in the safe.  Somehow you <i>know</i> that
                it belongs with you, not in there! ";      
            else
                inherited();
        }
    }
    
    hidden = true
    
    checkReach(actor)
    {
        if(hidden)
            "You'd better remove the poster first. ";
    }
;
// In this implementation, the combination is a random set of
// three different numbers from 1 to 50.  Turning the dial to
// the zero position resets the dial.  A reset is needed whenever
// the dial has been turned to an incorrect number.

+ safeDial: Fixture, NumberedDial 'dial'
    "It's just to the right of the safe's door. You notice that the 0 setting is marked
    <q>Reset</q>. "
    
    isHidden = safe.isHidden
    game551 = true
    maxSetting = 50
    minSetting = 0
    curSetting = '0'
    
    combo = [11, 22, 33] // initial value for testing
    currentCombo = []
    comblen = combo.length
    comboSet = nil
    
    abscounter = 0 // absolute counter of settings
    
    
    makeSetting(val)
    {
        if(safe.isOpen)
        {
            "The dial won't turn while the safe's open. ";
            return;
        }
        
        if(!comboSet)
            setComb();
        
         /* 
          *   Limit the scope for trial and error.  Before the player learns the combination, the
          *   dial can be set to a nonzero value up to 15 times, allowing (at most) five
          *   combinations to be tried.
          */
        
        if(abscounter > (comblen * 5) && val != '0' && !safeCombination.seen && !safe.hasOpened)
        {
            "This is getting ridiculous!  It's highly unlikely that
            you could open the safe by trial and error, so I suggest
            that you wait until you've found the combination. ";
            return;
        }
        
        local num = toInteger(val);
        inherited(val);
        
        /* reset */
        if(val == '0')  
        {
            currentCombo = [];
            "You hear a <i>clunk</i> as the mechanism resets itself. ";
        }
        else
        {            
            currentCombo += toInteger(num);
            local len = currentCombo.length;
            local ok = true, i;
            abscounter++;
            
            
            if(len > comblen)
                ok = nil;
            else
            {
                for(i = 1; i <= len; i++)
                {
                    if(currentCombo[i] != combo[i])
                    {
                        ok = nil;
                        break;
                    }
                }
            }
              
            if(ok)
            {
                if(safeCombination.seen || safe.hasOpened || len == comblen)
                    "You hear a satisfying <i>click</i>";
                else
                    "You hear a <i>click</i>, but you have no way
                        of knowing whether the setting is correct";
                
                if(len == comblen)
                {                    
                    safe.makeLocked(nil);                    
                    safe.makeOpen(true);
                    if(rareBook.undiscovered)
                    {
                        global.checklist += rareBook;
                        rareBook.undiscovered = nil;
                    }
                     ", and the safe's door smoothly swings open";
                    if(safe.contents.length > 0)
                        ", revealing <<list of safe.contents>>";                    
                    "!";
                }                
            }
            else
            {
                if(safeCombination.seen || safe.hasOpened)                     
                    "You hear an unsatisfying <i>click</i>.
                    Maybe if {i} rubbed {my} fingers with sandpaper ...";                
                else                    
                    "You hear a <i>click</i>, but you have no way
                    of knowing whether the setting is correct. ";       
                
            }               
        }      
    }
    
    /* Set a random comination */
    setComb()
    {
        combo = [0, 0, 0];
        for(local i in 1..3)
        {
            combo[i] = rand(maxSetting) + 1;
        }
        comboSet = true;
    }
    
;

concreteFloor: Floor 'floor; concrete; ground'
    "It's just an ordinary concrete floor. "
;


/* 4 */
inAValley: OutsideRoom 'In a Valley'
    "{I} {am} in a valley in the forest beside a
        stream tumbling along a rocky bed."
    
    north = atEndOfRoad
    building asExit(north)
    
 
    forest = inForest1
    east = inForest1
    west = inForest1
    up asExit(east)
    downstream = atSlitInStreambed
    south = atSlitInStreambed
    down asExit(south)
    depression = outsideGrate
;

+ Decoration 'rocky bed';
 
/* 5 */
inForest1: OutsideRoom 'In Forest'
    "{I} {am} in open forest, with a deep valley to
        one side. <<if (global.newGame)>>Not far is a large billboard.<<end>> "
    
    east = inAValley
    down asExit(east)
    north = inForest1
    west = inForest1
    south = inForest1
    fore asExit(north) 
    valley = inAValley
    forest: VarDest, TravelConnector
    {
        calcDest = rand(100) < 50 ? inForest1 : inForest2
    }    
;

+ ProxyRoom 'deep valley' -> inAValley;

+ billboard: Fixture 'billboard; large'
    desc()
    {
        
        "The billboard reads:\n
        <q>Visit Beautiful Colossal Cave.  Open Year Around.  Fun for
        the entire family, or at least for those who survive.</q>\b
        Below the headline is an impossibly complicated map showing how
        to find Colossal Cave.  Not that it matters, because all the
        directions are written in Elvish.  However, one illustration
        catches your attention.  It seems to show a group of elves
        involved in a strong-man competition.  For some reason, they
        appear to be gorging themselves on blueberries!<.p>";
        
        if(blue1.isIn(nil))
        {
            // blueberries added by DJP
            "You notice a blueberry bush nearby. ";
            
            blue1.moveInto(location);
        }
    }
    
    readDesc = desc
    game551 = true
    
;

class Blueberries: CanPick, Fixture 'blueberries;blue delicious ;berries berry bush bushes;them'    
    "The berries look delicious!  You're tempted to sample them." 
    
    count = 0

    dobjFor(Eat) asDobjFor(Take)
    
    dobjFor(Take)
    {
        verify() {}
        check()
        {
            if(gActor.blueberriesEaten >= 5)             
                "You reach for the blueberries, but then have second
                thoughts.  For some reason you seem to have lost your
                appetite! ";
        }
        
        action()
        {
            "You take a few of the blueberries, and can't resist eating
            them ... \n
            MMMM! They're delicious, and now you somehow feel a little
            stronger than you did before.";
            
            // Note that the player is allowed to carry more weight, but
            // not more bulk.  The sack must be carried.
            gActor.weightCapacity += 2;
            
            gActor.blueberriesEaten++ ;
            
            count++;
        }
    }    
    
    checkDobjCount = "There are too many to count. "
;

blue1: Blueberries 
    desc
    {        
        if (count >= 2)
            "The bush has been picked clean now - there aren't any berries
            left. ";
        else
            "Someone else has almost picked the bush clean, but there are
            still a few left.  You're tempted to sample them. ";
    }
    
    altVocab = 'blueberry bush; blue berry; blueberries berries; it them'
    useAltVocabWhen = (count >= 2)
    
    game551 = true
    
    specialDesc = "There is blueberry bush here. "
    
    checkDobjCount
    {
        if(count >= 2)
            desc();
        else
            inherited();   
    }
    
;
    
/* 6 */
inForest2: OutsideRoom 'In Forest'
    "{I} {am} in open forest near both a valley and a road. "
    
    road asExit(north)
    north = atEndOfRoad
    valley asExit(east)
    east = inAValley
    west = inAValley
    down asExit(east)
    forest asExit(south)
    south = inForest1
;

+ ProxyRoom ->inAValley;
+ ProxyRoom ->atEndOfRoad;

/* 7 */
atSlitInStreambed: OutsideRoom 'At Slit in Streambed'
    "At {my} feet all the water of the stream
        splashes into a <<if (global.closed)>>2-foot<<else>>2-inch<<end>>              
        slit in the rock.  Downstream the streambed is bare rock."
    
    north = inAValley
    east = inForest1
    west = inForest1
    south = outsideGrate
    building = atEndOfRoad
    upstream = inAValley
    forest = inForest1
    downstream = outsideGrate
    rock = outsideGrate
    bed = outsideGrate
    
    
    down: Passage 'slit; two 2 inch foot two-inch 2-inch 2-foot two-foot' -> edgeOfPool
    "All the water of the stream splashes into the slit. "
    {
        canTravelerPass(traveler) { return global.closed; }
        explainTravelBarrier(traveler, connector) { "{I} {don't fit} through a two-inch slit!"; }
        
        isConnectorListed = (global.closed)
        
        travelDesc() { plungeToPond(); } // see endgame.t
        
        location = atSlitInStreambed
        dobjFor(ClimbDown) asDobjFor(TravelVia)    
    }
;

+ Distant 'bare rock' ordinary = 'ordinary';

/* 8 */
outsideGrate: OutsideRoom 'Outside Grate'
    "{I} {am} in a 20-foot depression floored with
        bare dirt.  Set into the dirt is a strong steel grate
        mounted in concrete.  A dry streambed leads into the
        depression. "
    
    south = inForest1
    north = atSlitInStreambed
    east = inForest1
    west = inForest1
    
    down = grate
    building = atEndOfRoad
    forest = inForest1
    upstream = atSlitInStreambed
    gully = atSlitInStreambed
    in asExit(down)
;

+ Fixture '20-foot depression; twenty foot twenty-foot; dirt'
    "{I}{'m} standing in it. "
;

+ Scenery 
    [['dry streambed', nullObj], ['concrete', nullObj]]
;

grate: DSDoor 'steel grate; metal strong 3x3 ; lock grille'  @outsideGrate @belowTheGrate   
    
    lockability = lockableWithKey
    room1Desc = "It just looks like an ordinary grate mounted in concrete. "
    room2Desc = "It's just a 3x3 steel grate mounted in the ceiling."
    stateDesc = 'It is <<if isOpen>>open<<else if isLocked>>closed and
        locked<<else>>closed<<end>>. '
    
    vocabLikelihood = 20
;


/* 9 */
belowTheGrate: NotFarIn 'Below the Grate' 'small chamber beneath the grate'
    "{I} {am}  in a small chamber beneath a 3x3 steel
     grate to the surface. A low crawl over cobbles leads
     inward to the west."
    
    up = grate
    out asExit(up)
    west: Passage 'low crawl over cobbles' ->inCobbleCrawl
    "The crawl leads inwward to the west. "
    {  location = static lexicalParent  }    
    
    in asExit(west)
    crawl = inCobbleCrawl
    cobble = inCobbleCrawl
    pit = atTopOfSmallPit
//    outdoors asExit(up)
;

MultiLoc, Decoration 'cobbles; cobble; cobble cobblestones cobblestone stones
    stone; them it'
    "They're just ordinary cobbles. "
    locationList= [belowTheGrate, inCobbleCrawl, inDebrisRoom]
    checkDobjCount = "Surely you have better things to do that waste time counting cobblestones? "
;


/* 10 */
inCobbleCrawl: NotFarIn 'In Cobble Crawl' 'cobble crawl; (in) low; passage'
    "{I} {am} crawling over cobbles in a low passage.
     There is a dim light at the east end of the passage."
    
    east = belowTheGrate
    out asExit(east)
    west = inDebrisRoom
    tosurface = belowTheGrate
    in asExit(west)
    dark = inDebrisRoom
    debris = inDebrisRoom
    pit = atTopOfSmallPit    
    depression = depressionConnector
;

+ Decoration 'cobbles;;;them';
+ Distant 'dim light' "There is a dim light at the east end of the passage. ";

/* 11 */
inDebrisRoom: DarkRoom, NotFarIn 'In Debris Room'
    "{I} {am} in a debris room filled with stuff
    washed in from the surface. A low wide passage with cobbles
    <<if west == debrisWest>>is now only partially blocked with debris, 
    and continues to the west. An awkward canyon leads upward<<else>>
    becomes plugged with mud and debris here, but an awkward canyon leads upward and west<<end>>.
      <.p>A note on the wall says, <q>Magic word XYZZY.</q>"
        
    east = inCobbleCrawl
    
    west = inAwkwardSlopingEWCanyon
    
    up ulExit(inAwkwardSlopingEWCanyon)
    in ulExit(inAwkwardSlopingEWCanyon)
    
    xyzzy ulExit(insideBuilding)
    
    entrance = belowTheGrate
    crawl = inCobbleCrawl
    passage = inCobbleCrawl
    low = inCobbleCrawl
    pit = atTopOfSmallPit 
    canyon = inAwkwardSlopingEWCanyon
    depression = inCobbleCrawl.depression
       
;

+ Passage 'awkward canyon' -> inAwkwardSlopingEWCanyon
    "The awkward canyon leads upwards and weat. "
;

+ Fixture 'note'
    "The note says <q>Magic word XYZZY.</q> "
    readDesc = desc
;

+ MultiLoc, Fixture 'rubble;;stuff mud debris'
    "You see nothing of interest. "
    
    lookInMsg = 'You sift through the debris, but find nothing of interest. '
    moveNoEffectMsg = lookInMsg
    isMoveable = true
    pushNoEffectMsg = lookInMsg
    
    cannotTakeMsg = 'You have come here to find treasures, not to
    cart around useless rubble, debris or mud.  I suggest that you
    leave it where it is. '
    
    cannotPutMsg = cannotTakeMsg
    
    
    locationList = [inDebrisRoom]
    
    vocabLikelihood = 20
    
    checkDobjDebris = "How do you propose going about counting debris? "
;

depressionConnector: VarDest, TravelConnector    
        calcDest = grate.isLocked ? belowTheGrate : grate;    
;

/* 12 */

inAwkwardSlopingEWCanyon: DarkRoom, NotFarIn 'In Awkward Sloping E/W Canyon'
    "{I} {am} in an awkward sloping east/west canyon."
    east = inDebrisRoom
    down asExit(east)
    
    west = inBirdChamber
    up asExit(west)
    in asExit(west)
    pit = atTopOfSmallPit 
    depression = depressionConnector
    
;

/* 13 */
inBirdChamber: DarkRoom, NotFarIn 'In Bird Chamber' 'bird chamber; (in) splendid'
    "{I} {am} in a splendid chamber thirty feet high.
      The walls are frozen rivers of orange stone.  An
      awkward canyon and a good passage exit from east and
       west sides of the chamber. "
    
    
    east: PathPassage 'awkward canyon' -> inAwkwardSlopingEWCanyon
    "The awkward canyon exits to the east. "
    {
        location = inBirdChamber    
    }
    west = atTopOfSmallPit
    debris = inDebrisRoom
    entrance = belowTheGrate
    canyon = inAwkwardSlopingEWCanyon
    pit = atTopOfSmallPit
    passage = atTopOfSmallPit
    depression = depressionConnector
    
;


orangeStone: MultiLoc, Fixture 'orange stone;; column massive travertine walls'    
    "It's a column of travertine -- a beautiful mineral found in wet
    limestone. <<unless gRoom == inBirdChamber>>You could climb down it but you wouldn't be able to 
    climb up.<<end>> "
    
    locationList = [inBirdChamber, blueBirdChamber, atBrinkOfPit ]
    
    dobjFor(Climb)
    {
        verify() {}
        action() { goInstead(down); }
    }
    dobjFor(ClimbDown) asDobjFor(Climb)
;


/* 14 */
atTopOfSmallPit: DarkRoom, NotFarIn 'At Top of Small Pit'
    "At {my} feet is a small pit breathing traces of
     white mist.  A passage from the east ends here except for a
     small crack leading on."
    
    
    east = inBirdChamber
    west = "The crack is far too small for {me} to follow. "
    entrance = belowTheGrate
    debris = inDebrisRoom
    passage = inBirdChamber
    crack asExit(west)
    depression = depressionConnector
    
    down: TravelConnector
    {
        destination = largeGoldNugget.isIn(gActor) ? brokenNeck : inHallOfMists
    }
    
    analevel = nil
;

MultiLoc, Fixture 'rough stone steps; stairs staircase'
    "<<if largeGoldNugget.isIn(gActor)>>It wouldn't be safe to descend the steps with what you're
            carrying<<else>>The rough stone steps lead down the pit<<end>>. "
     
    initSpecialDesc = "Rough stone steps lead down the pit. "
    useInitSpecialDesc = !largeGoldNugget.isIn(gPlayerChar)
    
    dobjFor(ClimbDown)
    {
        verify() {}
        action() { goInstead(down); }
    }
    
    locationList = [atTopOfSmallPit, greenTopOfSmallPit]
    checkDobjCount = "You have better things to do than count steps and stairs. "
;

smallPit: MultiLoc, Fixture 'small pit'
    desc()
    {
        "The pit is breathing traces of white mist.\n";
        if (location.analevel == 1)
            "The steps have been removed.  The elevator is the only way down
            at this Level. ";
        else if (largeGoldNugget.isIn(gActor))
            "I'm not sure {I}'ll be able to climb down it
            safely with what {I}{'m} carrying. ";
        else
            "It looks like {I} might be able to climb down it.";
    }
    
    dobjFor(ClimbDown)
    {
        verify() {}
        action() { goInstead(down); }
    }
    
    dobjFor(Climb) asDobjFor(ClimbDown)
    
    locationList = [atTopOfSmallPit, blueTopOfSmallPit, greenTopOfSmallPit]
;

pitCrack: MultiLoc, Fixture 'crack; small leading (on)'
    "<<cannotEnterMsg>>"
    
    cannotEnterMsg = 'The crack is very small -- far too small for {me} to follow. '
    cannotBoardMsg = cannotEnterMsg
    lookInMsg = '''There's nothing in the crack (in this version of Adventure,
        anyway). '''
    analevel = location ? location.analevel : 0
    
    
    locationList = [atTopOfSmallPit, blueTopOfSmallPit, greenTopOfSmallPit]
    
;

mist: MultiLoc, Distant 'mist;white; vapor vapour wisps'
    "Mist is a white vapor, usually water, seen from time
     to time in caverns.  It can be found anywhere but is
     frequently a sign of a deep pit leading down to water. "
    
    notImportantMsg = 'It\'s too diffuse to do anything to. '
    
    locationList = [atTopOfSmallPit, inHallOfMists,
    onEastBankOfFissure,  atWindowOnPit1,
        atWestEndOfHallOfMists, inMistyCavern,
        inMirrorCanyon,  atReservoir, atWindowOnPit2, onSWSideOfChasm
    ]
    
    
;



/* 15 */
inHallOfMists: DarkRoom 'In Hall of Mists' 'hall of mists; vast'
    desc()
    {
        "{I} {am} at one end of a vast hall stretching forward out of sight to the west";
        if (global.game550) {
            ", filled with wisps of
            white mist that sway to and fro almost as if alive.  There
            is a passage at the top of a dome above {me}  A wide
            staircase runs downward into the darkness;  a chill wind
            blows up from below.  There are small passages to the north
            and south, and a small crack leads east.";
        }
        else {
            ".  There are openings
            to either side.  Nearby, a wide stone staircase leads
            downward.  The hall is filled with wisps of white
            mist swaying to and fro almost as if alive.  A cold
            wind blows up the staircase.  ";
            
            "There is a passage at the top of a dome behind {me}.";
        }
    }
    
    
    up: TravelConnector
    {
        destination = atTopOfSmallPit
        canTravelerPass(actor) { return !largeGoldNugget.isIn(actor); }
        explainTravelBarrier(actor) { "The dome is unclimbable."; }
    }
    
    south = inNuggetOfGoldRoom
    
    west = onEastBankOfFissure
    
    fore asExit(west)
    
    down = homStairs
    
    left = inNuggetOfGoldRoom
    hall = onEastBankOfFissure    
    
    east: VarDest,TravelConnector
    {
        calcDest = destination = global.game550 ? sandstoneChamber : lexicalParent.up
    }
    
    crack: TravelConnector
    {
        isConnectorApparent = global.game550
        travelVia(actor) 
        {
            if(isConnectorApparent)
                lexicalParent.up.travelVia(actor); 
        }
    }
    
    north: TravelConnector
    {
        destination = inHallOfMtKing
        noteTraversal(actor)
        {
            actor.nextRoute = 1;
            inherited(actor);
        }
    }
    
    y2: VarDest, TravelConnector
    {
        calcDest = global.newGame ? atY2 : jumbleOfRock
        travelDesc()
        {
            if(global.newGame)
            {
                "{I} locate{s/d} a hidden passage on the north side of the
                hall, and climb{s/ed} down a wall of broken rock ...<.p>";
                
                if(wumpus.isChasing) 
                    wumpus.actionMoveInto(jumbleOfRock);
            }
        }
        
    }
    
    stairs = inHallOfMtKing
    
    passage = "There's more than one opening -- please tell me which
        direction you want to go. "
    
    climb =  "You'll have to tell me whether you want to climb UP or DOWN."
       
    
    
    NPCexit1 {
        if(global.newGame) return atY2;
        else return jumbleOfRock;
    }
    NPCexit2 {
        if (global.game550) return sandstoneChamber;
        else return nil;
    }
    
//    ne {
//        if (not blueHallOfMists.isseen) 
//            pass ne;
//        else
//            "You stand in the northeast corner of the room, in the position
//            of the elevator shaft at Blue level. ";
//            P();
//            return Red_NE_Corner;
//    }
    
    ana2 = blueHallOfMists
;
+ Decoration 'chill wind; cold';

class HOMStaircase: StairwayDown 'wide stone staircase;; stairs steps;it them'
    "The staircase leads down. "    
    ;

+ homStairs: HOMStaircase
    destination = inHallOfMtKing
;

domeSteps: MultiLoc, Fixture 'rough stone steps'
    desc()
    {
        if(largeGoldNugget.isIn(gActor))
            "You won't be able to climb the steps with what you're
            carrying. ";
        else
            "The rough stone steps lead up the dome. ";
    }
    
    initSpecialDesc = "Rough stone steps lead up the dome. "
    useInitSpecialDesc = !largeGoldNugget.isIn(gPlayerChar)
    
    
    locationList = [inHallOfMists, blueHallOfMists, greenHallOfMists]
    
    dobjFor(Climb)
    {
        verify() {}
        action() { goInstead(up); }
    }
    
    dobjFor(ClimbUp) asDobjFor(Climb)    
    
    checkDobjCount = "You really shouldn't waste time counting steps and stairs. "
    
;

dome: MultiLoc, Fixture 'dome'
    desc()
    {
        if (location.analevel == 1)
            "The rough stone steps have been removed. The elevator is the only
            way up at this Level. ";
        else if (largeGoldNugget.isIn(gActor))
            "I'm not sure {i}'ll be able to get up it
            with what (i){'m} carrying.";
        else
            "It looks like {i} might be able to climb up it. ";
    }
    
    dobjFor(Climb) { remap = domeSteps }
    dobjFor(ClimbUp) { remap = domeSteps }
    
    locationList = [inHallOfMists, blueHallOfMists, greenHallOfMists]
;



/* 17 */
onEastBankOfFissure: DarkRoom 'On East Bank of Fissure'
    'east bank of the fissure; (on); hall'
    "{I} {am} on the east bank of a fissure slicing
     clear across the hall. The mist is quite thick here,
     and the fissure is too wide to jump. "
    
    east = inHallOfMists
    hall = inHallOfMists
    
    jump()
    {
        if(crystalBridge.exists)
            "I respectfully suggest{i} {go} across the
            bridge instead of jumping. ";
        else
            didnt_make_it.death();
        exit;        
    }
    
    fore { jump(); }
    across { doInstead(Cross, crystalBridge); }
    over { across; }
    cross { across; }
    
    isfissureroom = true   
;

bridgeFissure: MultiLoc, Fixture 'fissure; wide'
    desc {
        if (location.analevel == 2)
            "An iron bridge spans the fissure. ";
        else if (crystalBridge.exists)
            "A crystal bridge now spans the fissure. ";
        else
            "The fissure looks far too wide to jump. ";
    }
    
    locationList = [onEastBankOfFissure, westSideOfFissure]
    
    listenDesc = "You hear a distant roar, like the sound of a fast-flowing
             river, from the depths of the fissure. "
    
    dobjFor(JumpOver)
    {
        preCond = [objVisible]
        verify() {} 
        action() { location.jump(); }
    }
;

crystalBridge: MultiLoc, Fixture, Surface 'crystal bridge; magic' 
    "It spans the fissure, thereby providing {me} a way across."
    
    exists = nil
    isHidden = !exists
      
    
    isWaveTarget = true
    
    
    locationList = [onEastBankOfFissure, westSideOfFissure]
    
    
    appear()
    {
//        moveIntoAdd([onEastBankOfFissure, westSideOfFissure]);
//        moveIntoAdd(westSideOfFissure);
        exists = true;
        if(gActor.getOutermostRoom.isfissureroom)
            "A crystal bridge now spans the fissure!" ;
        
        onEastBankOfFissure.west = westSideOfFissure;
        westSideOfFissure.east = onEastBankOfFissure;
        
    }
    
    vanish(actor, exclude?)
    {   
        local i,o,l, objlist = contents, wheretogo, righthere = nil;
        if(isIn(gRoom))
        {
            "The crystal bridge has vanished!";
            righthere = true;
        }
                
        exists = nil;
        onEastBankOfFissure.west = nil;
        westSideOfFissure.east = nil;
        
        
        if(contents.length > 0)
        {
            wheretogo = global.newGame ? lostCanyonEnd : inCavernWithWaterfall;
            l = length(objlist);
            for(i = 1; i <= l; i++) 
            {
                o = objlist[i];
                if (!o.isFixed) {
                    if(righthere && !(o == exclude)) 
                    {
                        gMessageParams(o);
                        "{The o} {falls} into the depths of the fissure!\n ";
                    }
                    // deal with fragile items
                    if (o == mingVase) {
                        o.shatter;
                        o = shards;
                    }
                    else if (o == glassVial)
                        wheretogo = nil;
                    else if (o == exclude)
                        wheretogo = actor.getOutermostRoom;
                    o.moveInto(wheretogo);
                }
            }
        }
        if(wumpus.isChasing) 
        {
            if (wumpus.prevloc.isfissureroom &&
                (gPlayerChar.location != wumpus.prevloc) &&
                (wumpus.locstay == 1))
                wumpus.demise();
        }
        
    }
    
        
    noWayToCrossMsg = 'There is no way across the fissure.'
    
    doCross()
    {
        local dest = gActor.isIn(onEastBankOfFissure) ? westSideOfFissure : onEastBankOfFissure;
        dest.travelVia(gActor);
    }
    
    dobjFor(Enter)
    {
        verify() {}    
        action()
        {
            "You stand on the bridge, but you can't help looking down into the
            depths of the fissure.  This makes you feel very insecure, so you
            continue across ...\b";
            doCross();
        }
    }
    dobjFor(Board) asDobjFor(Enter)
 
    isCrossable = true
    
    dobjFor(Cross)
    {       
        verify()
        {
            if(!exists)
                illogicalNow(noWayToCrossMsg);
        }
        
        action() 
        {
            "{I} cross{es/ed} the bridge.<.p> ";   
            doCross(); 
        }        
    }
;

/* 18 */
inNuggetOfGoldRoom: Room 'In Nugget of Gold Room' 'gold nugget room; low (in) (of)'
    "This is a low room with a crude note on the wall. <<nuggetNote.readDesc>> "
          
    north = inHallOfMists
    out asExit(north)
    
    hall = inHallOfMists
//    ana2 = Blue_Nugget_Of_Gold_Room
;

+ nuggetNote: Fixture 'note; crude'
    "The note says, \"You won't get it up the steps.\""
    readDesc = desc
;

/* 19 */
inHallOfMtKing: DarkRoom 'In the Hall of the Mountain King'
    "{I} {am} in the Hall of the Mountain King, with
        passages off in all directions. "    
    
    up = staircase2a
    
//    snakeCheck(actor)
//    {
//        if(snake.isIn(actor.location))
//        {
//            "{I} can't get past the snake. ";
//            return nil;
//        }
//        return true;      
//    }
    
    east: TravelConnector
    {
        noteTraversal(actor) 
        {
            actor.nextRoute = 1;
            inherited(actor);
        }
        destination = inHallOfMists
    }
    
    left asExit(north)
    right asExit(south)
    fore asExit(west)
    
    south: TravelConnector
    {
        travelBarriers = [snakeBarrier]
        destination = inSouthSideChamber
    }
    
    west: TravelConnector
    {
        travelBarriers = [snakeBarrier]
        destination = inWestSideChamber
    }
    
    north: TravelConnector
    {
        travelBarriers = [snakeBarrier]
        destination = lowNSPassage
    }
    
    southwest: TravelConnector
    {
        travelBarriers = rand(100) <= 35 ? [] :[snakeBarrier]       
        
        destination = inSecretEWCanyon
    }
    
    northeast: VarDest, TravelConnector
    {
 
        calcDest()
        {
            if(global.oldGame && !global.game550)
                return inherited;
            if(global.game550)
                return morion;
            if(throneRoom.seen)
                return throneRoom;
                        
            if (rand(100) < 75 && !clover.isIn(gActor))
                return lexicalParent;
            
            return throneRoom;
        }             
        
        
        travelBarriers = [snakeBarrier]
        
        travelDesc = "<<if destination==lexicalParent>><<crawled_around.crawlMsg>><<end>>"
        
    }
    
    northwest: VarDest, TravelConnector
    {
        calcDest
        {
            if(!global.game550) return inherited;
            
            return corrDivis;
        }
        
        travelBarriers = [snakeBarrier]
    }
    
    southeast: TravelConnector
    {
        destination = global.game550 ? corridor1 : inherited;
        
        travelBarriers = [snakeBarrier]
    }
    
    down: TravelConnector
    {
        destination = global.game550 ? vault : inherited;
        
        travelBarriers = [snakeBarrier]
    }
    
    passage = "Passages lead off in all directions; you'll have to specify which way you want to
        go. "
;

+ staircase2a: Staircase2
    destination = inHallOfMists
;

snakeBarrier: TravelBarrier
    canTravelerPass(actor, connector)
    {
        return !snake.isIn(actor.getOutermostRoom);
    }
    
    explainTravelBarrier(actor, connector)
    {
        "{I} {can't} get past the snake. <.reveal snake-block>";
    }
    
;

class Staircase2: StairwayUp 'wide stone staircase;; stair stairs steps;it them'
    "The staircase leads up. "
    
    canTravelerPass(actor)
    {
        return !(largeGoldNugget.isIn(actor) && global.newGame);
    }
    
    explainTravelBarrier(actor)
    {
        "The staircase is now unclimable. ";
    }
;

/* 20-22 are messages */
/* 23 */
atWestEndOfTwoPitRoom: DarkRoom 'At West End of Twopit Room' 'west end of the twopit room'
    desc
    {
        "{I} {am} at the west end of the twopit room.
        There is a large hole in the wall above the pit at
        this end of the room. ";

        if (plantStickingUp.isIn(self)) 
        {
            plantStickingUp.desc;
        }
    }
    
    east = atEastEndOfTwoPitRoom 
    
    across asExit(east)
    west = inSlabRoom
    slab asExit(west)
    down = inWestPit
    pit asExit(down)
    
    up = 'The hole is too far up for {me} to reach. '
    hole asExit(up)
    
;

+ Distant 'hole above[prep] the pit[n]; large' 
    
    notImportantMsg = 'It\'s too far up for you to reach. '
    
;


 

plantStickingUp: MultiLoc, Distant 'plant'
    desc()    
    {
        if (plant.size == 1)
            "The top of a 12-foot-tall beanstalk is
            poking out of the west pit. ";
        else
            "There is a huge beanstalk growing out of the
            west pit up to the hole. ";
    }
    
    
;

/* 24 */
inEastPit: DarkRoom 'In East Pit' 'east pit; (in) eastern'
    "{I} {am} at the bottom of the eastern pit in the
     twopit room.  There is a small pool of oil in one
     corner of the pit. "
 
    up = atEastEndOfTwoPitRoom
    out asExit(up)
    climb = atEastEndOfTwoPitRoom

    dobjFor(Climb)
    {
        verify() {}
        action() { goInstead(up); }
    }
    
    dobjFor(ClimbUp) asDobjFor(Climb)
;

+ ProxyRoom -> atEastEndOfTwoPitRoom;


+ oil: RoomLiquid 'pool of oil; small'
    liquid = "oil"
;

eastPit: MultiLoc, StairwayDown 'eastern pit; east e; corner'
    "The best way to examine the pit would be to go down into
    it. "
    
    destination = inEastPit
    
    locationList = [atEastEndOfTwoPitRoom, atWestEndOfTwoPitRoom]
    
    checkReach(actor)
    {
        if(!actor.isIn(atEastEndOfTwoPitRoom))
            "You'll have to go over to the east end of the room first. ";
    }       
    
    
    dobjFor(Enter) asDobjFor(ClimbDown)
    dobjFor(Climb) asDobjFor(ClimbDown)
    dobjFor(Board) asDobjFor(Enter)
    
;

/* 25 */
inWestPit: DarkRoom 'In West Pit' 'west pit; western (in)'
    "{I} {am} at the bottom of the western pit in the
     twopit room.  There is a large hole in the wall about
     25 feet above you. "
    
    up = atWestEndOfTwoPitRoom
    out asExit(up)
    climb { actionDobjClimb(); }   
 
    
    dobjFor(Climb)
    {
        verify() {}
        action() 
        { 
            if(plant.size < 1 || plant.size > 2)
            {
                "\n(the pit)\n";
                goInstead(up); 
            }
            else
            {
                "\n(the plant)\n";
                doInstead(Climb, plant);
            }
                       
                
        }
    }
    
    dobjFor(ClimbUp) asDobjFor(Climb)
    
     NPCexit1 {
        if (plant.size != 2) return nil;
        else return inNarrowCorridor;
    }
;

+ ProxyRoom ->atWestEndOfTwoPitRoom;

+ Fixture 'hole above pit; large'
    "The hole is in the wall above you."
    
    checkReach(actor)
    {
        if(plant.size != 2)
            "({}{'m} not anywhere near the hole -- it's far overhead.";
        else
            "The hole is too far away. ";
    }
    
    
;

   
+ plant: StairwayUp 'plant; tiny little' 
    desc()
    {
        switch(size)
        {
        case 0:
            "There is a tiny little plant in the pit,
            murmuring \"Water, water, ...\"";
            plantStickingUp.moveInto(nil);
            break;
        case 1:
            "There is a 12-foot-tall beanstalk stretching
            up out of the pit, bellowing \"Water!!
            Water!!\"";
            plantStickingUp.moveInto(atWestEndOfTwoPitRoom);
            plantStickingUp.replaceVocab('top of 12-foot beanstalk; twelve foot tall bean ;plant stalk');
            break;
        case 2:
            "There is a gigantic beanstalk stretching all
            the way up to the hole.";
            plantStickingUp.replaceVocab('huge beanstalk; bean giant ;plant stalk');
            break;
        }
    }
    
    specialDesc { desc(); }
       
    size = 0
    resize(num)
    {
        size = num;
        switch(num)
        {
        case 0: 
            replaceVocab('plant; tiny little murmuring');
            break;
        case 1:
            replaceVocab('beanstalk; twelve foot 12 twelve-foot tall bellowing; plant');
            plantStickingUp.replaceVocab('top of[prep] twelve foot beanstalk[n]; 12 ;plant ');
            plantStickingUp.moveIntoAdd([atWestEndOfTwoPitRoom, atEastEndOfTwoPitRoom]);
            break;
        case 2:
            replaceVocab('giant beanstalk; giant gigantic; plant');
            break;
        }
    }
    
    dobjFor(Climb)
    {        
        verify()
        {
            if(size == 0)
                illogicalNow('It\'s just a little plant. ');
        }
        
        action()
        {
            if(size == 1)
                destination = atWestEndOfTwoPitRoom;
            if(size == 2)
                destination = inNarrowCorridor;
            
            inherited();
        }
    }
    
    travelDesc()
    {
        if(size == 1)
            "{I} climb{s/ed}} up the plant and out of the
            pit.\b ";
        if(size == 2)
            "{I} clamber{s/ed} up the plant and scurry through
            the hole at the top.\b";
    }
    
    cannotTakeMsg = 'The plant has exceptionally deep roots and cannot be
        pulled free. '
    cannotPullMsg = cannotTakeMsg
    
    water()
    {
        resize(size + 1);
        switch(size)
        {
        case 1:
            "The plant spurts into furious growth for a
            few seconds. ";
            break;
        case 2:
            "The plant grows explosively, almost filling
            the bottom of the pit. ";
            break;
        default:
            "You've over-watered the plant!  It's
            shriveling up!  It's, it's...";
            resize(0);
        }
        
        desc();
    }
    
    dobjFor(Water)
    {
        verify() { }
                
        action()
        {
            if(bottle.isIn(gActor) && bottle.hasWater)
                doInstead(PourOnto, bottle, self);
            else if(cask.isIn(gActor) && cask.hasWater)
                doInstead(PourOnto, cask, self);
            else if(flask.isIn(gActor) && flask.hasWater)
                doInstead(PourOnto, flask, self);
            else
                "{I} {have} nothing to water the plant with. ";
        }
    }
    
    dobjFor(Oil)
    {
        verify() { }
                
        action()
        {
            if(bottle.isIn(gActor) && bottle.hasOil)
                doInstead(PourOnto, bottle, self);
            else if(cask.isIn(gActor) && cask.hasOil)
                doInstead(PourOnto, cask, self);
            else if(flask.isIn(gActor) && flask.hasOil)
                doInstead(PourOnto, flask, self);
            else
                "{I} {have} nothing to oil the plant with. ";
        }
    }
    
    allowPourOntoMe = true
   
//    ana2 = blueEastBankOfFissure
    
;

westPit: MultiLoc, StairwayDown 'western pit; west w corner'
    "The best way to examine the pit would be to go down into
    it. "
    
    destination = inWestPit
    
    locationList = [atEastEndOfTwoPitRoom, atWestEndOfTwoPitRoom]
    
    checkReach(actor)
    {
        if(actor.isIn(atEastEndOfTwoPitRoom))
            "You'll have to go over to the west end of the room first. ";
    }       
    
    
    dobjFor(Enter) asDobjFor(ClimbDown)
    dobjFor(Climb) asDobjFor(ClimbDown)
    dobjFor(Board) asDobjFor(Enter)
    
;




/* 27 */
westSideOfFissure: DarkRoom 'West Side of Fissure'
    "You are on the west side of the fissure in the hall of mists. "
    
    west = atWestEndOfHallOfMists
    north: TravelConnector
    {
        destination = atWestEndOfHallOfMists
        travelDesc()
        {
            gActor.nextRoute = 1; // DJP
            "{I} {have} crawled through a very low wide passage
            parallel to and north of the hall of mists.\b";
        }
    }
    
    jump()
    {
        if(crystalBridge.exists)
            "I respectfully suggest {i} {go} across the
            bridge instead of jumping. ";
        else
            didnt_make_it.death();
        exit;
    }           
    
    isfissureroom = true
    
    across asExit(east)
    cross asExit(east)
    over asExit(east)
    
    east: TravelConnector
    {
        isConnectorApparent = crystalBridge.exists
        destination = onEastBankOfFissure        
    }    
;

+ ProxyRoom -> atWestEndOfHallOfMists
;

/* 28 */
lowNSPassage: DarkRoom 'Low N/S Passage'
    "You are in a low N/S passage at a hole in the
     floor.  The hole goes down to an E/W passage."
    
    south = inHallOfMtKing
    out asExit(south)
    north = atY2
    down = inDirtyPassage
    
    hall = inHallOfMtKing
    y2 = atY2
    hole = inDirtyPassage
;

+ Passage 'hole'  -> inDirtyPassage
    "The hole goes down to an E/W passage. "
;

+ ProxyRoom ->inDirtyPassage
;

/* 29 */
inSouthSideChamber: DarkRoom 'In South Side Chamber'    
    "You are in the south side chamber."
    
    hall asExit(north)
    out asExit(north)
    north = inHallOfMtKing
;

/* 30 */
inWestSideChamber: DarkRoom 'In West Side Chamber'    
    "You are in the west side chamber of the hall of the mountain king. 
    A passage continues west and up here. "
    
    hall asExit(east)
    out asExit(east)
    east = inHallOfMtKing
    west = crossover
    up asExit(west)
    passage = crossover
;

/* 31 - 32 are messages */
/* 33 */
atY2: DarkRoom 'At "Y2"' 'at Y2; large; room'    
    desc() 
    {
        
        "You are in a large room, with a passage to the
        south, a passage to the west, and a wall of broken
        rock to the east. There is a large \"Y2\" on ";

        if (gActor.isIn(Y2Rock))
             "the rock you are sitting on. ";
        else
             "a rock in the room's center. ";
    }
    plugh = insideBuilding
    south = lowNSPassage
    east = jumbleOfRock
    wall asExit(east)
    broken asExit(east)
    passage = "There are passages to south and west. "
    
    west = atWindowOnPit1
    
    plover: TravelConnector
    {
        destination = inPloverRoom
        noteTraversal(actor)
        {
            if (eggSizedEmerald.isIn(actor))
                eggSizedEmerald.actionMoveInto(atY2);
            
            inherited(actor);
            
        }
    }
      
    roomDaemon() { hollowVoice(); }
    hollowVoice 
    {
        if (!gPlayerChar.isIn(self))
            return;
        
        if (rand(100) <= 25) 
            "A hollow voice says, <q>Plugh.</q>\n";
        
    }

;

+ Decoration 'wall of broken rock';

+ Y2Rock: Fixture, Chair 'Y2 Rock'
    "There is a large \"Y2\" painted on the rock."
;

jumbleOfRock: DarkRoom 'Jumble of Rock'
    "You are in a jumble of rock, with cracks everywhere. "
    
    down = atY2
    y2 asExit(down)
    up = inHallOfMists    
;

+ Decoration 'cracks;;;them'
;

/* 34 */
atWindowOnPit1: Room 'At Window on Pit' 'window on pit; 1'
    "{i}{'m} at a low window overlooking a huge pit,
        which extends up out of sight.  A floor is
        indistinctly visible over 50 feet below.  Traces of
        white mist cover the floor of the pit, becoming
        thicker to the right. Marks in the dust around the
        window would seem to indicate that someone has been
        here recently.  Directly across the pit from you and
        25 feet away there is a similar window looking into a
        lighted room. A shadowy figure can be seen there peering back at {me}."
    
    east = atY2
    y2 asExit(east)
    jump()
    {
        if(!window.isOpen)
            tryImplicitAction(Open, window);
        
        brokenNeck.travelVia(gPlayerChar);
    }
    
    reflect()
    {
        if (global.newGame) return atWindowOnPit2;
        else return inherited();
    }
    
    wavehands = "The shadowy figure waves back at {me}. ";
;

window: MultiLoc, Fixture 'window; low'
     "It looks like a regular window."
    locationList = [atWindowOnPit1, atWindowOnPit2]
    isOpenable = true
    isWaveTarget = true
    
    makeOpen(stat)
    {
        if(stat)
            "OK, the window is now open.  You notice that
            the shadowy figure opened his window at the same time. ";
        else
            "OK, the window is now closed.  You notice that
            the shadowy figure closed his window at the same time. ";
        
        inherited(stat);
    }
;

MultiLoc, Distant 'huge pit'
    "It's so deep you can barely make out the floor below,
        and the top isn't visible at all. " 
    
    locationList  = [atWindowOnPit1, atWindowOnPit2]
;

MultiLoc, Decoration 'marks in the dust;;;them'
    "Evidently {I}{'m} not alone here."
    locationList = [atWindowOnPit1, atWindowOnPit2]
    
//    doCleanWith( actor, io ) = {theFloor.doCleanWith( actor, io );}
//    doSweepWith( actor, io ) = {theFloor.doSweepWith( actor, io );}
;

MultiLoc, Distant 'shadowy figure; mysterious; person shadow individual stranger man; him'
     "The shadowy figure looks very similar to you.
      Perhaps he's another adventurer.  He seems to be trying to attract
      your attention. "
    
    specialDesc =  "The shadowy figure seems to be trying to attract your
        attention. "
    
    isWaveTarget = true
    locationList = [atWindowOnPit1, atWindowOnPit2]
;

MultiLoc, Distant 'similar window; distant'
    "It looks much like the one at your location. "
    locationList = [atWindowOnPit1, atWindowOnPit2]
;

MultiLoc, Distant 'lighted room; distant'
    "So far as you can tell from here, it's similar to the one you're in. "
    locationList = [atWindowOnPit1, atWindowOnPit2]    
;

/* 36 */
inDirtyPassage: DarkRoom 'In Dirty Passage' 'dirty passage; broken e/w east/west east-west'
    "You are in a dirty broken passage.  To the east
     is a crawl.  To the west is a large passage.  Above
    you is a hole to another passage."
    
    east = onBrinkOfPit
    crawl asExit(east)
    up = lowNSPassage
    hole asExit(up)
    climb asExit(up)
    west = inDustyRockRoom
    slab ulExit(inSlabRoom)
    bedquilt ulExit(inBedquilt)
    passage = inDustyRockRoom
;

+ PathPassage 'crawl' -> onBrinkOfPit
    "The crawl leads east. "
;

+ Passage 'hole' -> lowNSPassage
    "Above you is a hole to another passage. "
    dobjFor(ClimbUp) asDobjFor(TravelVia)
    dobjFor(Climb) asDobjFor(TravelVia)
;

+ ProxyRoom 'another passage' -> lowNSPassage
;

/* 37 */
onBrinkOfPit: DarkRoom 'On Brink of Pit'
    "You are on the brink of a small clean climbable
    pit.  A crawl leads west. "
    
    west = inDirtyPassage
    crawl asExit(west)
    down = cleanPit
    pit asExit(down)
    climb = cleanPit
    in asExit(down)
;

+ Passage 'crawl' -> inDirtyPassage
    "The crawl leads west. "
;

+ cleanPit: StairwayDown 'small pit; clean climbable'
    "It looks like you might be able to climb down into it. "
    
    destination = inPit
    dobjFor(Climb) asDobjFor(ClimbDown)
    checkDobjCount = nil
;

/* 38 */
inPit: DarkRoom, NoNPC 'In Pit'
    "You are in the bottom of a small pit with a
      little stream, which enters and exits through tiny
      slits. "
    
    up = cleanPit2
    out asExit(up)
    climb = cleanPit2
    
    slit = down
    stream = down
    upstream = down
    downstream = down
    
    down = 'You don\'t fit through the tiny slits! '
   
;

+ cleanPit2: StairwayUp 'small pit; clean climbable'
    desc = (location.desc)
    
    destination = onBrinkOfPit
    getFacets = [cleanPit]
    
    vocalLikelihood = 20
    checkDobjCount = nil
;

+ Decoration 'tiny slits; complex; rock pattern; them it'
    "The slits form a complex pattern in the rock. "
;

+ Decoration 'little stream'
    "The stream enters and exits through tiny slits. "
;

/* 39 */
inDustyRockRoom: DarkRoom 'In Dusty Rock Room' 'dusty rock room; in[prep] large'
    "You are in a large room full of dusty rocks.
     There is a big hole in the floor.  There are cracks
     everywhere, and a passage leading east. "
    
    east = inDirtyPassage
    passage asExit(east)
    down: Passage 'big hole' ->atComplexJunction
        {  location = lexicalParent }
    hole asExit(down)
    bedquilt =inBedquilt
    floor = atComplexJunction   
;

+ dustyRocks: Fixture 'dusty rocks;dirty;stones boulderns stone boulder rock;them'
    desc()
    {
        if (global.oldGame)
            "They're just rocks.  (Dusty ones, that is.)";
        else if (areswept)
            "They are covered with a thick coating of dust.  However, the
            dust has been swept away from one of the larger rocks,
            revealing a carved inscription. ";
        // this happens if we sit on the throne without a crown
        else if (safeCombination.seen)
            "They are covered with a thick coating of dust.  I know that
            there is an inscription on one of the rocks, but I can no
            longer see it - you'll have to sweep the rock again. ";
        else
            "They are covered with a thick coating of dust.  You'll have
            to find some way to remove it before you can examine them
            properly. ";

    }
    
    areswept = nil
    
    readDesc 
    {        
        if(!areswept) 
        {
            if (safeCombination.seen)
                "Sorry, but I can't quite remember what the inscription
                reads.  You'll have to sweep the rock again. ";
            else
                "Even if there was anything readable, I wouldn't be able
                to see it for all the dust!";
        }
        else 
            "In the rock is carved the message: <q><<safeCombination.showCombo()>></q>. ";
    }       
    
    dobjFor(Clean)
    {
        preCond = [touchObj]
        verify()  {  }
        check() { sweepCheck(); }
        action() { askForIobj(CleanWith); }
    }
    
    dobjFor(CleanWith)
    {
        verify() {}
        
        check()
        {
            if(gIobj != whiskbroom)
                "{The subj iobj} won't do much of a job. ";
            else 
                sweepCheck();
        }
        
        action()  {  sweep(); }
    }        

    sweepCheck()
    {
        if(areswept)
            "Enough dusting, already!  {I}{\'m} making me sneeze.
            If {i} want{s/ed} to read the inscription, please say so. ";
    }
    
    dobjFor(SweepWith) asDobjFor(CleanWith)
    dobjFor(DustWith) asDobjFor(CleanWith)
    dobjFor(Dust) asDobjFor(Clean)
    dobjFor(Sweep) asDobjFor(Clean)
    sweep()
    {        
        if (!safeDial.comboSet) 
            safeDial.setComb();
        "Brushing the dust from one of the larger rocks reveals some carved
        characters.  They appear to read: <q><<safeCombination.showCombo>></q>. ";        
        
        areswept = true;
        safeCombination.moveInto(location);
        safeCombination.seen = true;       
    }    
    
    checkDobjCount = "There are too many to waste time trying to count them. "
;

safeCombination: Fixture 'carved inscription; writing; combination letters characters; it them'
    "They are just 2-inch high characters, carved into the rock. "
    
    readDesc = "They read: <<showCombo()>>. "
    
    showCombo()
    {
        local i;
        for (i = 1; i <= safeDial.comblen; i++) 
        {
            say(safeDial.combo[i]); 
            if (i < safeDial.comblen) "-";
        }
        isseen = true;
    }
    
    isseen = nil
;

/* 40 is a message */
/* 41 */
atWestEndOfHallOfMists: DarkRoom 'At West End of the Hall of Mists'
    "You are at the west end of the hall of mists.
    A low wide crawl continues west and another goes
    north.  To the south is a little passage 6 feet off
    the floor. "

    east = westSideOfFissure
    west = atEastEndOfLongHall
    south = alikeMaze1
    up asExit(south)
    climb = alikeMaze1
    crawl = atEastEndOfLongHall
    
    north: TravelConnector
    {
        travelDesc()
        {
            gActor.nextRoute = 1;
            "{I} {have} crawled through a very low wide passage
            parallel to and north of the hall of mists.\b ";
        }
        
        destination = westSideOfFissure
    }
    
    passage = south
;

+ Passage 'low wide crawl; another' -> alikeMaze1    
    "A low wide crawl continues west and another goes north."
;

alikeMazeSkip:MazeSkipConnector
    destList = [atBrinkOfPit, deadEnd13, atWestEndOfHallOfMists]
;

alikeMaze1: AlikeMazeRoom
    up = atWestEndOfHallOfMists
    north = alikeMaze1
    east = alikeMaze2
    south = alikeMaze4
    west = alikeMaze11
    
    
    // Help NPCs escape from the maze
    NPCexit1 = atWestEndOfHallOfMists
    NPCexit2 = atWestEndOfHallOfMists
;

alikeMaze2: DarkRoom, AlikeMazeRoom
    west = alikeMaze1
    south = alikeMaze3
    east = alikeMaze4    
    // Help NPCs escape from the maze
    NPCexit1 = atWestEndOfHallOfMists
    NPCexit2 = atWestEndOfHallOfMists
;

alikeMaze3: DarkRoom, AlikeMazeRoom
    east = alikeMaze2
    down = deadEnd3
    south = alikeMaze6
    north = deadEnd10    
;


alikeMaze4: DarkRoom, AlikeMazeRoom
    west = alikeMaze1
    north = alikeMaze2
    east = deadEnd1
    south = deadEnd2
    up = alikeMaze14    
    down = alikeMaze14
    
    // Help NPCs escape from the maze
    NPCexit1 = atWestEndOfHallOfMists
    NPCexit2 = atWestEndOfHallOfMists
;

/* 46 */
deadEnd1: DeadEndRoom
    west = alikeMaze4
    out asExit(west)
;

deadEnd2: DeadEndRoom
    east = alikeMaze4
    out asExit(east)
;

deadEnd3: DeadEndRoom
    up = alikeMaze3
    out asExit(up)
;

/* 49 */
alikeMaze5: DarkRoom, AlikeMazeRoom
    east = alikeMaze6
    west = alikeMaze7    
;

/* 50 */
alikeMaze6: DarkRoom, AlikeMazeRoom
    east = alikeMaze3
    west = alikeMaze5
    down = alikeMaze7
    south = alikeMaze8   
;

/* 51 */
alikeMaze7: DarkRoom, AlikeMazeRoom
    west = alikeMaze5
    up = alikeMaze6
    east = alikeMaze8
    aouth = alikeMaze9   
;

/* 52 */
alikeMaze8: DarkRoom, AlikeMazeRoom
    west = alikeMaze6
    east = alikeMaze7
    south = alikeMaze8
    up = alikeMaze9
    north = alikeMaze10
    down = deadEnd12    
;

alikeMaze9: DarkRoom, AlikeMazeRoom
    west = alikeMaze7
    east = alikeMaze8
    south = deadEnd4    
;

/* 54 */
deadEnd4: DeadEndRoom
    west = alikeMaze9
    out asExit(west)
;

/* 55 */
alikeMaze10: DarkRoom, AlikeMazeRoom
    west = alikeMaze8
    north = alikeMaze10
    down = deadEnd5
    east = atBrinkOfPit
;
    
/* 56 */
deadEnd5: DeadEndRoom
    up = alikeMaze10
    out asExit(up)
;    

/* 57 */
atBrinkOfPit: DarkRoom 'At Brink of Pit'
    "You are on the brink of a thirty foot pit with
    a massive orange column down one wall.  You could
    climb down here but you could not get back up.  The
    maze continues at this level. "
    
    down = inBirdChamber
    west = alikeMaze10
    south = deadEnd6
    north = alikeMaze12
    east = alikeMaze13
    mazeskip = alikeMazeSkip
    
    climb = inBirdChamber
    
    // Allow NPCs out of here (to the Hall of Mists)
    NPCexit1 = inHallOfMists
    NPCexit2 = inHallOfMists
    
;
//
//+ orangeColumn: StairwayDown 'massive orange column; big huge'
//    "It's a column of travertine -- a beautiful mineral found in wet
//    limestone.  You could climb down it but you wouldn't be able to 
//    climb up. "
//    destination = inBirdChamber
//    dobjFor(Climb) asDobjFor(ClimbDown)
//;
//
+ Fixture 'pit; thirty foot 30 30-foot'
    "You'll have to climb down to find out anything more..."
    
    disambigName = 'thirty foot pit'
    dobjFor(ClimbDown) { remap = orangeStone }
    dobjFor(Enter)
    {
        verify() {}
        action() { doInstead(ClimbDown, orangeStone); }
    }
;

+ Fixture 'maze; this; level'
    "The maze surrounds you in every horizontal direction at this level. "
    cannotTakeMag = 'How exactly do you propose to do that? '
    cannotEnterMsg = 'Which way? North, south, east, or west? '
;

/* 58 */
deadEnd6: DeadEndRoom
    east = atBrinkOfPit
    out asExit(east)
;




/* 59 is a message */
/* 60 */
atEastEndOfLongHall: DarkRoom 'At East End of Long Hall'
    'east end of the very long hall; (at)'
    "You are at the east end of a very long hall apparently without side
    chambers.  <<if global.newGame>>In the south wall are several wide cracks and a high
    hole, but the hole is far above {my} head.<<end>> 
    To the east a wide crawl slants up.  To the north a round two foot hole slants down."  
    
    east = atWestEndOfHallOfMists
    crawl asExit(east)
    up asExit(east)
    west = atWestEndOfLongHall
    north: Passage 'round two foot hole; 2 ft slanting' -> crossover
    "The round hole slants down. "
        { location = static lexicalParent }
    down asExit(north)
    hole asExit(north)
 
    south: VarDest, TravelConnector
    {
        isConnectorApparent = !global.oldGame
        
        calcDest()
        {
            local movecontents = deadEndCrack.contents.subset({o: !o.isFixed});   
            if(!deadEndCrack.seen || movecontents.length > 0)
            {
                randomChoice = true;
                return rand(100) < 50 ? tightCrack: deadEndCrack;
            }
            else
            {
                randomChoice = nil;
                return tightCrack;
            }
                
        }
        
        travelDesc = "\n(choosing <<if randomChoice>>one of the cracks at random<<else>>the left
            crack<<end>>)\n"
        
        randomChoice = true
    }
       
    crack asExit(south)
    left = global.newGame ? tightCrack: nil
    middle = global.newGame ? tightCrack: nil
    right = global.newGame ? deadEndCrack : nil
    
    NPCexit1 {
        if(global.newGame) return tightCrack;
        else return nil;
    }
    NPCexit2 {
        if(global.newGame) return tightCrack2;
        else return nil;
    }
    NPCexit3 {
        if(global.newGame) return deadEndCrack;
        else return nil;
    }
;

+ Distant 'high hole'
    "The high hole is far above your head. "
    game551 = true
    notImportantMsg = 'The high hole is too high up to reach. '
;

hallCracks: MultiLoc, CollectiveGroup, Fixture 'cracks;;;them'
    desc
    {
        if(analevel == 1) 
        {
            "There are three cracks in the south wall, but the middle and
            left cracks have been blocked with concrete.  ";
        }
        else 
        {
            "There are three cracks in the south wall.  To choose which
            one to enter, type LEFT, MIDDLE or RIGHT.  ";
            if(self.location.analevel != 2) 
            {
                "The middle crack is narrower than the other two";
                if (tightCrack2.seen)
                    ". ";
                else 
                    " and it doesn't appear that you can proceed very far down 
                    it. ";
            }
        }
    }
    
    dobjFor(Enter)
    {
        verify() {}
        action() { gActor.travelVia(location.crack); }
    }
    
    dobjFor(Board) asDobjFor(Enter)
    dobjFor(GoThrough) asDobjFor(Enter)
    
    locationList = [atEastEndOfLongHall]
    
    actionDobjCount = "There are three cracks in the south wall. "
;

leftCrack: MultiLoc, Enterable 'left crack'
    "It's one of three cracks on the south wall.  It looks large
     enough to enter. "
    
    game551 = true // in 551-point game only
    
    locationList = [atEastEndOfLongHall]

    connector = tightCrack
    
    dobjFor(Board) asDobjFor(Enter)
    
    collectiveGroups = [hallCracks]
;

rightCrack: MultiLoc, Enterable 'right crack'
    desc 
    {
        "It's one of three cracks on the south wall.  It looks large
        enough to enter";
        if(location.analevel ==1)
           ", but unfortunately it has been blocked up with concrete. ";
        else
           ". ";
    }
    
    game551 = true // in 551-point game only

    locationList = [atEastEndOfLongHall]
    //        , Blue_East_End_Of_Long_Hall, Green_East_End_Of_Long_Hall]
    
    dobjFor(Board) asDobjFor(Enter)
    dobjFor(GoThrough) asDobjFor(Enter)    
    
    connector = location.right    
    collectiveGroups = [hallCracks]
;


middleCrack: MultiLoc, Enterable 'middle crack; centre center'
    desc
    {
        if(location.analevel == 2)
            "It's one of three cracks on the south wall.  It may once have been
            narrow like its counterpart at Red level, but it appears to have
            been widened at some time in the past. ";
        else 
        {
            "It's one of three cracks on the south wall.  It's very
            narrow, although it looks just large enough to enter";
            if(location.analevel == 1)
                ".  Unfortunately you can't, because it has been blocked up
                with concrete. ";
            else if (tightCrack2.seen)
                ". ";
            else 
                ", but I doubt whether you could proceed very far down it. ";
        }
    }
    
    
    game551 = true // in 551-point game only
    sdesc = "middle crack"
    
    connector = location.middle
    
    locationList = [atEastEndOfLongHall]
    //        , Blue_East_End_Of_Long_Hall, Green_East_End_Of_Long_Hall]
    
    dobjFor(Board) asDobjFor(Enter)
    dobjFor(GoThrough) asDobjFor(Enter)    
    collectiveGroups = [hallCracks]
;





northHole: MultiLoc, Fixture 'round hole; (n) (north) two foor two-foot'
    "It's a round two-foot hole, going north. "
    
    dobjFor(Enter)
    {
        verify() {}
        action()
        {
            goInstead(north);
        }
    }
    dobjFor(GoThrough) asDobjFor(Enter)
    dobjFor(ClimbDown) asDobjFor(Enter)
    locationList = [atEastEndOfLongHall]                               
                
;


/* 61 */

atWestEndOfLongHall: DarkRoom 'At West End of Long Hall'
    'west end of the long hall; very featureless'
    "You are at the west end of a very long
     featureless hall.  The hall joins up with a narrow
     north/south passage. "
    
    east = atEastEndOfLongHall
    north = crossover
    south = differentMaze1
    passage = "The paasage runs north and south. "
;


/* 62 */
crossover: DarkRoom 'N/S and E/W Crossover'
   "You are at a crossover of a high N/S passage and a low E/W one. "
    
    west = atEastEndOfLongHall
    north = deadEnd7
    east = inWestSideChamber
    south = atWestEndOfLongHall
    passage = desc
;


/* 63 */
deadEnd7: DeadEndRoom
    desc = "You have reached a dead end. "
    south = crossover
    out asExit(south)
    
;

+ Fixture 'message on the wall; scratched; writing script scrawl' @deadEnd7
    "The message reads, \"Stand where the statue gazes, and
     make use of the proper tool.\""
    
    game550 = true
    
    specialDesc = "Scratched on the wall is the
          message, \"Stand where the statue gazes, and make use of
         the proper tool.\""    
    
    isHidden = !global.game550

;

/* 64 */
atComplexJunction: DarkRoom 'At Complex Junction'
    "You are at a complex junction.  A low hands and
         knees passage from the north joins a higher crawl
         from the east to make a walking passage going west.
         There is also a large room above.  The air is damp
         here. "
    up = inDustyRockRoom
    west = inBedquilt
    north = inShellRoom
    east: Passage 'higher crawl' -> inAnteroom
    "The crawl enters from the east. "
    {
        location = atComplexJunction
    }
        
    toRoom = inDustyRockRoom
    passage = " A low hands and knees passage from the north joins a higher crawl
         from the east to make a walking passage going west."
    
    climb asExit(up)
    hole asExit(up)
    bedquilt asExit(west)
    shell = inShellRoom
    
;

+ ProxyRoom 'large room' -> inDustyRockRoom
;


/* 65 */
inBedquilt: DarkRoom 'In Bedquilt'
    "You are in bedquilt, a long east/west passage
     with holes everywhere. To explore at random select
     north, south, up, or down. "
    
    east = atComplexJunction
    west = inSwissCheeseRoom
    
    south: TravelConnector
    {
        canTravelerPass(actor)
        {
            return rand(100) > 80 || clover.isIn(actor);
        }
        
        explainTravelBarrier(actor, connector)
        {
            crawled_around.crawlMsg;
        }


        
        destination = inSlabRoom
    }
    
    up: VarDest, TravelConnector
    {
        canTravelerPass(actor)
        {
            return rand(100) > 80 || clover.isIn(actor);
        }
        
        explainTravelBarrier(actor, connector)
        {
            crawled_around.crawlMsg;
        }
        
        calcDest()
        {
            if (rand(100) <= 50)
                return inSecretNSCanyon1;
            else
                return inDustyRockRoom;
        }
    }

    slab ulExit(inSlabRoom)
    
//    /* allow holes to be climbed up or down */
//    uphole = true
//    downhole = true
    
    secret = inSecretNSCanyon1
    
    north()
    {
        if (rand(100) <= 60 && ! clover.isIn(gActor))
            crawled_around.crawlMsg;
        else if (rand(100) <= 75)
            return inLargeLowRoom;
        
        return atJunctionOfThreeSecretCanyons;
    }
    
    down: TravelConnector
    {
        canTravelerPass(actor)
        {
            return rand(100) > 80 || clover.isIn(gActor);
        }
        
        explainTravelBarrier(actor, connector)
        {
            crawled_around.crawlMsg;
        }
        
        destination = inAnteroom
    }
    
    hole = "There are holes everywhere, so you'll have to tell me which
        direction you want to go in. "
    
    climb = "You could go up or down. "
    
    NPCexit1 = inDustyRockRoom
    NPCexit2 = inLargeLowRoom
    NPCexit3 = atJunctionOfThreeSecretCanyons
    NPCexit4 = inAnteroom
;


/* 66 */
inSwissCheeseRoom: DarkRoom 'In Swiss Cheese Room'
     "You are in a room whose walls resemble swiss
     cheese.  Obvious passages go west, east, ne, and nw.
     Part of the room is occupied by a large bedrock block. "    
    
    northeast = inBedquilt
    west = atEastEndOfTwoPitRoom
    
    east = inSoftRoom
    
    south: TravelConnector
    {
        canTravelerPass(actor) { return clover.isIn(actor) || rand(100) > 80; }
        explainTravelBarrier { crawled_around.crawlMsg; }
        destination = inTallEWCanyon
    }
    
    canyon ulExit(inTallEWCanyon)
    
    northwest: TravelConnector
    {
        canTravelerPass(actor) { return clover.isIn(actor) || foundOrient || rand(100) > 80; }
        explainTravelBarrier { crawled_around.crawlMsg; }        
        destination = inOrientalRoom
    }
    
    oriental: TravelConnector
    {
        destination = inOrientalRoom
        travelDesc() { foundOrient = true; }
    }
    
    passage = "Obvious passages go west, east, ne, and nw.
     Part of the room is occupied by a large bedrock block. " 
    
    
    foundOrient = nil
    
    // let NPCs out of here
    NPCexit1 = inOrientalRoom
;

+ Fixture 'bedrock block; huge large'
    "It's just a huge block."
    
    cannotMoveMsg = 'Surely you\'re joking. '
    cannotTakeMsg = cannotMoveMsg 
    
;


/* 67 */
atEastEndOfTwoPitRoom: DarkRoom 'At East End of Twopit Room' 'east end of the twopit room'
    "You are at the east end of the twopit room.
        The floor here is littered with thin rock slabs,
        which make it easy to descend the pits. There is a
        path here bypassing the pits to connect passages from
        east and west.  There are holes all over, but the
        only big one is on the wall directly over the west
        pit where you can't get to it. 
    <<if plantStickingUp.isIn(self)>>plantStickingUp.desc<<end>> "
    
    east = inSwissCheeseRoom
    
    west = atWestEndOfTwoPitRoom
    across = atWestEndOfTwoPitRoom
    
    down = eastPit
    
    hole =  "The only hole you could enter is on the wall directly over the
        west pit, and you can't get to it from here. "
    passage = "There are passages to east and west. "
;

+ PathPassage 'path; connecting' -> atEastEndOfTwoPitRoom
    "The path bypasses the pits to connect passages from east and west. "
    canTravelerPass(actor) { return nil; }
    explainTravelBarrier(t,conn) { "You'll have to say whether you want to go west or east. "; }
;

/* 68 */
inSlabRoom: DarkRoom 'In Slab Room' 'slab room; large low circular; chamber'
    "You are in a large low circular chamber whose
     floor is an immense slab fallen from the ceiling
     (slab room). <<passage>> "
    
    south = atWestEndOfTwoPitRoom
    
    up = inSecretNSCanyon0
    north = inBedquilt
    climb = inSecretNSCanyon0
    passage = "East and west there once were large
     passages, but they are now filled with boulders.  Low
     small passages go north and south, and the south one
     quickly bends west around the boulders. "
    floorObj = islFloor
;

+ Fixture 'boulders'
    "Boulders block the passages running east and west, but the passage
    south manages to skirt them. "
    cannotTakeMsg = 'The boulders look too numerous and too heavy to shift. '
    cannotMoveMsg = cannotTakeMsg
    cannotPushMsg = cannotTakeMsg
;

islFloor: Floor 'floor; immense; slab ground'
    "The floor is an immense slab fallen from the ceiling. "
;



/* 69 */
inSecretNSCanyon0: DarkRoom 'In Secret N/S Canyon'
    "You are in a secret N/S canyon above a large room. "
    
    down = inSlabRoom
    slab asExit(down)
    south = inSecretCanyon
    north = inMirrorCanyon
    toReservoir = atReservoir
    
;


/* 70 */
inSecretNSCanyon1: DarkRoom 'In Secret N/S Canyon'
    "You are in a secret N/S canyon above a sizable passage. "
    
    down = inBedquilt
    passage = inBedquilt
    north = atJunctionOfThreeSecretCanyons
    south = atopStalactite
;


/* 71 */
atJunctionOfThreeSecretCanyons: DarkRoom 'At Junction of Three Secret Canyons' 
    'junction of three secret canyons; tall; canyon' 
    "You are in a secret canyon at a junction of
     three canyons, bearing north, south, and se.  The
     north one is as tall as the other two combined. "
    
    southeast = inBedquilt
    south = inSecretNSCanyon1
    north = atWindowOnPit2
;

/* 72 */
inLargeLowRoom: DarkRoom 'In Large Low Room'
    // for some reason the directions in the 551-point game have
    // been changed, so the room description, travel and exithints methods
    // all have to check for the global.newgame variable.  The 551-point
    // room description has been changed so that the order of the
    // directions corresponds: Dead_End_Crawl, In_Oriental_Room,
    // In_Sloping_Corridor.    
    
        "You are in a large low room.  Crawls lead
        north, <<if(global.newGame)>>sw, and ne<<else>>
        se, and sw<<end>>. "
    
    bedquilt ulExit(inBedquilt)

    northeast: TravelConnector -> inSlopingCorridor
    {
        isConnectorApparent = (global.newGame)
    }
    
    
    southwest: VarDest, TravelConnector
    {
        calcDest = (global.newGame ? inOrientalRoom : inSlopingCorridor)
    }    
   
    north = deadEndCrawl
    
    southeast: VarDest, TravelConnector
    {
        calcDest = global.oldGame ? inOrientalRoom : inherited;
    }
    
    
    oriental ulExit(inOrientalRoom)

    // let NPCs out of here
    NPCexit1 = inSlopingCorridor    
;

/* 73 */
deadEndCrawl: DeadEndRoom 'Dead End Crawl'
    "This is a dead end crawl. "
    
    south = inLargeLowRoom
    crawl asExit(south)
    out asExit(south)
;


/* 74 */
inSecretEWCanyon: Room 'In Secret E-W Canyon'
     "You are in a secret canyon which here runs E/W. It crosses over a very tight canyon 15 feet
     below. If you go down you may not be able to get back up." 
    
    east = inHallOfMtKing
    west = inSecretCanyon
    down = inNSCanyon
;

/* 75 */
 inNSCanyon: DarkRoom 'In N/S Canyon' 'n/s canyon; very tight north-south (n) (s) n-s (north)
     (south) wide; place'
    "You are at a wide place in a very tight N/S canyon." 
   
    south = canyonDeadEnd
    north = inTallEWCanyon
;

/* 76 */
canyonDeadEnd: DeadEndRoom 'Canyon Dead End'
        "The canyon here becomes too tight to go further south. "
    
    north = inNSCanyon
;

/* 77 */
inTallEWCanyon: DarkRoom 'In Tall E/W Canyon'
    "You are in a tall E/W canyon.  A low tight crawl goes 3 feet north and seems to open up. "
    
    east = inNSCanyon
    west = deadEnd8
    north: PathPassage 'low tight crawl' ->inSwissCheeseRoom
    "The low tight crawl goes 3 feet north and seems to open up. "
        { location = static lexicalParent }
    crawl asExit(north)
;

/* 78 */
deadEnd8: DeadEndRoom 'At a Dead End' 'dead end; at[prep]; canyon'
    "The canyon runs into a mass of boulders -- dead end. 
     <<if (global.game550)>> Scratched on one of the boulders are
            the words, <q>Jerry Cornelius was here.</q><<end>> "
    
    south = inTallEWCanyon
    out asExit(south)       
;

+ Fixture 'mass of boulders[n];;;it them'
    "They are just like ordinary boulders. <<if global.game550>> Scratched on one of the 
    boulders are the words, \"Jerry Cornelius was here.\"<<end>>"
    
    checkDobjCount = "Do you really have nothing better to do than count boulders? "
;

/* 80 */
alikeMaze11: DarkRoom, AlikeMazeRoom
    north = alikeMaze1
    west = alikeMaze11
    south = alikeMaze11
    east = deadEnd9    
;

/* 81 */
deadEnd9: DeadEndRoom
    west = alikeMaze11
    out asExit(west)
;


/* 82 */
deadEnd10: DeadEndRoom
    south = alikeMaze3
    out asExit(south)
;


/* 83 */
alikeMaze12: DarkRoom, AlikeMazeRoom
    south = atBrinkOfPit
    east = alikeMaze13
    west = deadEnd11
;

/* 84 */
alikeMaze13: DarkRoom, AlikeMazeRoom
    north = atBrinkOfPit
    west = alikeMaze12
    northwest = deadEnd13
;

/* 85 */
deadEnd11: DeadEndRoom
    east = alikeMaze12
    out asExit(east)
;

/* 86 */
deadEnd12: DeadEndRoom
    up = alikeMaze8
    out asExit(up)
;

/* 87 */
alikeMaze14: DarkRoom, AlikeMazeRoom
    up = alikeMaze4
    down = alikeMaze4
;



/* 88 */
inNarrowCorridor: DarkRoom 'In Narrow Corridor'
    "You are in a long, narrow corridor stretching
    out of sight to the west.  At the eastern end is a
        hole through which you can see a profusion of leaves. "
   
    down asExit(east)
    climb = inWestPit
    east = inWestPit
    
    jump { return brokenNeck.death; }
    
    west = inGiantRoom
    giant asExit(west)
    
    // Let NPC's out of here even if we haven't grown the beanstalk
    NPCexit1 = atWestEndOfTwoPitRoom
;

+ Fixture 'leaves;;profusion leaf plant beanstalk stalk;them it'
    "The leaves appear to be attached to the beanstalk you climbed to get here. "
    
    checkDobjCount = "There are far too many leaves for you to even begin counting them. "
;

+ Decoration 'hole; eastern east e; end'
    "At the eastern end is a hole through which you can see a profusion of leaves. "
;

/* 91 */
atSteepInclineAboveLargeRoom: DarkRoom 'At Steep Incline Above Large Room'
    "You are at the top of a steep incline above a
        large room.  You could climb down here, but you would
        not be able to climb up.  There is a passage leading
        back to the north. "
    
    north = inCavernWithWaterfall
    cavern asExit(north)
    passage asExit(north)
    down = inLargeLowRoom
    climb = inLargeLowRoom
;

/* 92 */
inGiantRoom: DarkRoom 'In Giant Room'    
        "You are in the giant room.  The ceiling here is
        too high up for your lamp to show it.  Cavernous
        passages lead east, north, and south.  On the west
        wall is scrawled the inscription, <<inscription.text>>. "
    
    south = inNarrowCorridor
    east = atRecentCaveIn
    north = inImmenseNSPassage
    passage = "Passages lead east, north and north; which way do you want to go? "
;

+ inscription: Fixture 'scrawled inscription' 
    "It says <<text>>."
    readDesc = desc
    
    text = '<q>Fee, fie, foe, foo [sic]</q>'
;

/* 93 */
atRecentCaveIn: DarkRoom 'At Recent Cave-in' 'recent cave-in; low tunnel passage'
    desc
    {
       if (global.game550) {
            "You are in a low tunnel with an irregular ceiling. ";
            caveIn.desc;
        }
        else 
            "The passage here is blocked by a recent cave-in. ";
    }
    
    south = inGiantRoom
    giant asExit(south)
    out asExit(south)
    
    north: TravelConnector
    {
        canTravelerPass(traveler)  { return global.game550; }
        explainTravelBarrier(traveler, oonnector)
        {
            "The tunnel is blocked (in this version). ";
        }
        destination = glassyRoom
        isConnectorList = global.game550
    }
    
   
    NPCexit1 = glassyRoom
   
;

+ caveIn: Fixture 'cave-in;(in);cave'
    desc 
    {
        if (global.game550)
            "To the north, the tunnel is partially
            blocked by a recent cave-in, but you can probably
            get past the blockage without much trouble. ";
        else
            "To the north, the tunnel is blocked by a recent cave-in. ";
    }
    

    vocabLikelihood = 20
;


/* 94 */
inImmenseNSPassage: DarkRoom 'In Immense N/S Passage'
    "You are at one end of an immense north/south passage. "
    
    south = inGiantRoom
    giant asExit(south)
    passage asExit(south)
    
    dobjFor(Enter)
    {
        verify() {}
        action() { goInstead(north); }
    }
    
    in asExit(north)
    
    cavern = rustyDoor
    north = rustyDoor 
   
;

class RustyDoor: DSDoor
    isOiled = nil
    
    makeOiled(stat) { isOiled = stat; }
    
    allowPourOntoMe = true
    
    dobjFor(Oil)
    {
        verify() 
        {
            if(gActor.contents.indexWhich({x: x.hasOil}) == nil)
               illogicalNow('{I} {have} nothing to oil {the dobj} with. ');
        }
        action()
        {
            local obj = gActor.contents.valWhich({x: x.hasOil});            
            if(obj)
                doInstead(PourOnto, obj, self);
        }
    }
;
    

rustyDoor: RustyDoor 'rusty door; big massive iron; hinge hinges' 
    @inImmenseNSPassage @inCavernWithWaterfall
    "It's just a big iron door."
    
    
    dobjFor(Open)
    {
        check()
        {
            if(!isOiled)
                 "The door is extremely rusty and refuses to open. ";
        }
    }
    
    dobjFor(Close)
    {
        check()
        {
            if(!isOiled)
                 "The hinges are quite thoroughly rusted now and won't budge. ";
        }
    }
    
    specialDesc
    {
        local dir = byRoom(['north', 'south']);
        
        if (!isOiled && !isOpen)
            "The way <<dir>> is barred by a massive, rusty, iron door.";
        else
            "The way <<dir>> leads through a massive, rusty, iron door.";
    }    
;


inCavernWithWaterfall: DarkRoom 'In Cavern With Waterfall'
    'cavern with waterfall; magnificent' 
    "You are in a magnificent cavern with a rushing
        stream, which cascades over a sparkling waterfall
        into a roaring whirlpool which disappears through a
        hole in the floor.  Passages exit to the south and
        west. "
    
    south = rustyDoor
    out asExit(south)
    giant asExit(south)
    
    west = atSteepInclineAboveLargeRoom
    
    down
    {            
        if (global.oldGame && !global.game550) 
        {
            "You can't be serious! ";
            return;
        }
        else if (global.newGame && !global.game701) 
        {            
            dragged_down.msg;
            swordPoint.travelVia(gActor);
        }
        
        else if (global.game550) 
        {
            "What, into the whirlpool?\b>";
            //                waterfall.rhetoricalturn = gTurns;
            if(yesOrNo())
            {
                waterfall.enter;
                northOfReservoir.travelVia(gActor);
            }                
        }      
    }
   
    
    hole = down
    passage = "Passages exit to south and west. "
;

+ waterfall: Fixture 'waterfall;sparkling roaring whirling; whirlpool'    
    desc 
    {
        if(global.oldGame && !global.game550)
            "Wouldn't want to go down it in a barrel! ";
        else
            /* Changed to hint that the player might try going down. */
            "It's a roaring whirlpool.  Only the most foolhardy
            adventurers would try going down it. ";
    }
    
    rhetoricalturn = -999  // see yesVerb in CCR-VERB.T
    
    dobjFor(Enter)
    {
        verify()
        {
            if(global.oldGame && !global.game550)
                inherited();
        }
        
        action() { goInstead(down); }
    }
   
    cannotEnterMsg = 'You\'ve got to be kidding! '
   
    dobjFor(Board) asDobjFor(Enter)
    
    
    

//    // BJS: added these verbs:
//    verDoRide(actor) = { return self.verDoEnter(actor); }
//    doRide(actor) = { return self.doEnter(actor); }

    // BJS: routine for 550-point and 701-point games.
    // DJP: changed to keep items which are worn - and to remark about the
    // crown when it's still there.
    enter
    {
         
            local obj, ripped = nil, wornkept = 0, crownkept = nil;
            local actor = gActor;
            
            if (brassLantern.isIn(actor)) 
                "You plunge into the water and are sucked down by the whirlpool.  ";
            else 
                "You plunge into the water and are sucked down by
                the whirlpool into pitch darkness.  ";
            
            for(obj = firstObj(Thing); obj != nil; obj = nextObj(obj, Thing)) 
            {
                if (obj.isFixed) 
                    continue; // DJP - exclude fixed items
                if(obj.location == actor && obj != brassLantern && obj.wornBy != actor) 
                {
                    obj.moveInto(nil); // Remove any carried objects
                    //                if (obj == mushrooms or obj == mushroom) // Regrow mushrooms
                    //                    notify(obj,&regrow,obj.growtime);
                    ripped = true;    // except for the lamp.
                }
                else if (obj.location == actor && obj.wornBy == actor) 
                {
                    wornkept++;
                    if (obj == crown) 
                        crownkept = true;
                }
            }
            if (ripped && actor.contents.length > 0) 
            {
                if (brassLantern.isIn(actor)) 
                {
                    "The current is incredibly
                    strong, and you barely manage to hold
                    on to your lamp;  everything else ";
                    
                    if (wornkept) "(except what you are wearing) ";
                    "is pulled from your grasp and is lost
                    in the swirling waters. ";
                }
                else 
                {
                    "The current is incredibly strong, and
                    everything that you are carrying ";
                    if (wornkept) "(except what you are wearing) ";
                    "is ripped from your grasp and is lost in
                    the swirling waters. ";
                }
            }
            
            "<.p>The swirling waters deposit you, not ungently, on solid ground. <.reveal
            waterfall-transit>";
            if (crownkept) "<.p>Instinctively, you reach up to
                check that the crown is still there.  Miraculously, it is! <.p>";     
    }
;

+ Decoration 'rushing stream'
    "The rushing stream cascades over the sparkling waterfall. "    
;

/* 96 */
inSoftRoom: DarkRoom 'In Soft Room'    
        "You are in the soft room.  The walls are
        covered with heavy curtains, the floor with a thick
        pile carpet.  Moss covers the ceiling. "
    
    west = inSwissCheeseRoom
    out asExit(west)
    
    softfloor = true // we can safely drop the vase here    
    hasfloor = true // described as 'floor' not 'ground'
    
    hasfloordesc = true // custom floor description    
    
    floorObj = softRoomFloor
;

+ curtains: Decoration 'curtains; heavy thick;; them it'
    "They seem to absorb sound very well. "
    
    decorationActions = [Examine, LookBehind, Remove]
    
    lookBehindMsg = 'You don\'t find anything exciting behind the curtains (in this version
        of Adventure, anyway). '
    
    cannotTakeMsg = 'Now don\'t go ripping up the place! '
    
    actionDobjCount = "There are about a dozen curtains here in all. "
;

+ Distant 'some moss; typical everyday'
    "It just looks like your typical, everyday moss. "
    decorationActions = inherited + Eat
    
    cannotEatMsg = 'Eeeewwwww. '
    notImportantMsg = 'It\'s too high up for you to reach. '
    
;


softRoomFloor: Floor 'floor; plush thick ;carpet pile'
    "The carpet is quite plush. "    
;
    
/* 97 */
inOrientalRoom: DarkRoom 'In Oriental Room'
   "This is the oriental room.  Ancient oriental
    cave drawings cover the walls.  A gently sloping
    passage leads upward to the north, another passage
    leads southeast, and a hands and knees crawl leads 
    <<if(global.newGame)>> east<<else>> west<<end>>. "
    
    southeast = inSwissCheeseRoom
    crawl = inLargeLowRoom
    
    
/* changed direction for 551-point version */
    east: TravelConnector
    {
        destination = inLargeLowRoom
        isConnectorApparent = global.newGame        
    }
    
    west: TravelConnector 
    {
        destination = inLargeLowRoom
        isConnectorApparent = global.oldGame                   
    }
    
    north = inMistyCavern
    up asExit(north)
    passage = "A gently sloping passage leads upward to the north, while another passage
    leads southeast"

    cavern asExit(north)   
;

+ iorCrawl: Passage 'hands and knees crawl' ->inLargeLowRoom
    "The hands and knees crawl leads 
    <<if(global.newGame)>> east<<else>> west<<end>>. "    
;

+ Decoration 'ancient oriental drawings;cave;art paintings;them'
    "They seem to depict people and animals. "
;

/* 98 */
inMistyCavern: DarkRoom 'In Misty Cavern' 'misty cavern; (in) (of) large outer wide; edge rim path'
    desc 
    {
        "You are following a wide path around the outer
        edge of a large cavern. Far below, through a heavy
        white mist, strange splashing noises can be heard.
        The mist rises up through a fissure in the ceiling. ";
        if(global.oldGame) {
            "The path exits to the south and west. ";
        }
        else 
        {
            "The path hugs the cavern's rim to the NE and south, while
            another branch forks west.  A round chute with extremely
            smooth walls angles sharply up to the southwest. ";
        }
    }
    south = inOrientalRoom
    oriental asExit(south)
    west = inAlcove
    
    /* 'Up' works only 3% of the time in the 551-point game.  In the 701-point
    version we disable it altogether, because the adventurer should not
    be able to bring any objects into the area (except items which are worn).
    */
    up: TravelConnector
    {
        destination = topOfSlide
        
        canTravelerPass(actor)
        {
            if(global.oldGame)
                return nil;
            if(!global.game701 && rand(100) <= 3)
                return true;
            return nil;
        }
        explainTravelBarrier(actor, connector)
        {
            "<.reveal slide-back>";
            if (rand(100) <= 75)
                "{I} managed to climb about halfway up before losing
                {my} hold and sliding back. ";
            else 
                "You were only a few yards from the top when you slipped
                and tumbled all the way back down. ";
        }   
        
        isConnectorApparent = !global.oldGame
    }
   
    southweat asExit(up)
    
    /* 
     *   The TADS 2 version makes this unconditional, but presumably this exit should only exist it
     *   we're not in the oldGame version.
     */
    northeast: TravelConnector
    {
        isDestinationApparent = !global.oldGame
        destination = dantesRest
    }    
    

    // This verb has been taken out, because it looks like a game-testing
    // short cut.

    // chimney = {
    //    if(global.newgame) return Sword_Point;
    //    else pass chimney;
    // }

    // Exit info. for 'back' command:
//    exithints = [Top_Of_Slide, &up]
//    myhints = [Slidehint]
    listenDesc 
    {
        if (global.oldGame) 
        {
            inherited;
            return;
        }
        global.listenAdd = true;
        inherited;
        "You hear strange splashing noises from the cavern far below you. ";
        global.listenAdd = nil;
    }
;

+ Distant 'fissure'
    "You can't really get close enough to examine it. "
;

+ Decoration 'heavy white mist'
    "It's just mist. "
    notImportantMsg = 'The mist is too insubstantial for that. '    
;

+ Fixture 'chute; round steep'
    "Its walls are very smooth and steep.  If you tried to climb
     it, you'd likely slide back down again! "
    
    dobjFor(Climb)
    {
        verify() {}
        action() { goInstead(up); }
    }
    
    dobjFor(ClimbUp) asDobjFor(Climb)
;

/* 99 */
inAlcove: DarkRoom 'In Alcove'
    "You are in an alcove.  A small northwest path seems
        to widen after a short distance.  An extremely tight
        tunnel leads east.  It looks like a very tight squeeze.  
    An eerie light can be seen at the other end. "
    
    northwest: PathPassage 'small northwest path; nw'  ->inMistyCavern
    "The path to the northwest seems to widen after a short distance. "
        { location = static lexicalParent }
    cavern asExit(northwest)
    passage asExit(east)    
    
    east:Passage 'extremely tight tunnel' -> alcovePloverPassage
    "The tunnel leads east. "
        { location = static lexicalParent }    
    //
    // Let NPC's go in the plover room regardless of what
    // they're carrying.  (Life's not fair in the Colossal Cave.)
    //
    NPCexit1 = inPloverRoom
    // Exit info. for 'back' command:
    exithints = [inPloverRoom, &east]
;

+ Decoration 'eerie light'
    "The eerie light is at the other end of the tunnel leading east. "
    notImporantMsg = 'That\'s hardly something you can usefully attempt with an eerie light. '
;

alcovePloverPassage: DSPassage 'tight tunnel; extremely; passage' @inAlcove @inPloverRoom 
    "It looks extremely tight; it may be a little difficult to squeeze through. "
    
    //
        // The player must be carrying only the emerald or
        // nothing at all to fit through the tight tunnel.
        //
        canTravelerPass(actor)
        {
            if(actor.itemcount > 1 || (actor.itemcount == 1 && !eggSizedEmerald.isIn(actor)))
                return nil;
            
            return true;
        }
        
        explainTravelBarrier(actor, connector)
        {
            wontfit.wfMsg;
        }      
;


/* 100 */
inPloverRoom: Room 'In Plover Room' 'plover room; in[prep]; small chamber'  
    "{I}{'m} in a small chamber lit by an eerie green
    light.  An extremely narrow tunnel exits to the west.
    A dark corridor leads northeast. "
    
    
    passage asExit(west)
    out asExit(west)
    west: Passage 'extremely narrow tunnel' -> alcovePloverPassage
    "The narrow tunnel exits to the west. "
    {    
        location = inPloverRoom
    } 
    
    northeast: Passage 'dark corridor' -> inDarkRoom
    "The dark corridor leads northeast. "
    {
        location = inPloverRoom
    } 
    dark asExit(northeast)
    
    plover: TravelConnector
    {
        destination = atY2
        travelDesc()
        {
            if(eggSizedEmerald.isIn(gActor))
               eggSizedEmerald.actionMoveInto(inPloverRoom);               
        }
    }
    
    
    //
    // Let NPCs leave the plover room regardless of what
    // they're carrying.  (Life's not fair in the Colossal Cave.)
    //
    NPCexit1 = inAlcove
    // Exit info. for 'back' command:
    exithints = [inAlcove, &west]
//    myhints = [Ploverhint]
;

+ Decoration 'eerie green light'
    "It's green, and it's eerie. "
    notImportantMsg = 'The eerie green light is too insubstantial for that. '
;
    

/* 101 */
inDarkRoom: DarkRoom 'In Dark Room'
    "{I}{'m} in the dark room.  A corridor leading south is the only exit. "        
    
    south: PathPassage 'corridor; leading (s) (south)' -> inPloverRoom
    "The corridor leading south is the only exit. "
    {  location = lexicalParent  }
    plover asExit(south)
    out asExit(south)
;

+ Fixture 'stone tablet; massive'
    "A massive stone tablet imbedded in the wall reads:
     \"Congratulations on bringing light into the dark-room!\""
    
    specialDesc = desc
;


/* 102 */
inArchedHall: DarkRoom 'In Arched Hall'
    desc
    {
        "You are in an arched hall. ";
        if(global.game550) 
        {
            "A coral passage continues up and east.
            The air smells of sea water. ";
            if (jericho)
                "The north wall has partially crumbled, exposing a
                connecting hole to another room. ";
        }
        else if(jericho)
            "The remnants of a now-plugged coral
            passage lie to the east.  The north wall has partially crumbled,
            exposing a connecting hole to another room. ";
        else
            "A coral passage
            once continued up and east from here, but is now
            blocked by debris.  The air smells of sea water. ";
    }

/* This flag will be set to true when the horn is blown */
    jericho = nil
    
    east: TravelConnector
    {
        canTravelerPass(actor) { return global.game550; }
        explainTravelBarrier(actor, connector)
        {
            "The coral passage is blocked -- in this version, anyway. ";
        }
        destination = coralPassage
    }
    
    passage = east
    
    down = inShellRoom
    shell asExit(down)
    out asExit(down)
    up asExit(east)
    
    north = inArchedHallWalls
    hole asExit(north)
    
    
    
    
// Let npcs through, after the horn has been blown.  Note that
// NPC's are allowed to go from EW_Corridor_E to here even before
// the horn has been blown; this is to prevent them from getting
// trapped.
    NPCexit1 {if(jericho)return EWCorridorE;
               else return nil;}
    NPCexit2 = coralPassage
    // Exit info. for 'back' command:
//    exithints = [EW_Corridor_E, &north,
//                Coral_Passage, &east]
    listenDesc
    {        
        if (jericho || global.oldGame)
            "You hear nothing but the sound of your own breathing. ";
        else
            "You pace around the room, listening carefully to your
            footsteps.  You have a strong feeling that the wall to your
            north is hollow. ";
    }   
;

+ Odor 'sea water;of[prep];smell'
    "The air smells of sea water. "
    smellDesc = desc
;

// May need more work once EWCorridorE is implemented
inArchedHallWalls: SecretDoor, DSDoor 'north wall; (n); walls'  @inArchedHall @EWCorridorE
    vocabWhenClosed = 'north wall; (n); walls'
    vocabWhenOpened = 'hole; (north) (n) crumbled; wall walls'
    desc()
    {
        if(!global.newGame)
            "I've already told all I know about the walls. ";
        
        else if(isOpen)
            "The north wall has partially crumbled, exposing a
              connecting hole to another room. ";
        else
            "You can't see anything unusual about the walls. ";
    }
    
    travelBarriers = [clamBarrier]  
    
    dobjFor(Break) asDobjFor(Attack)
    dobjFor(Attack)
    {
        verify()
        {
            if(inArchedHall.jericho)
                illogicalAlready('{I}{\'ve} already done enough damage. ');
        }
        action()
        {
            "The <<dirName>> wall sounds hollow, but holds firm against 
            your onslaught. ";
        }
    }
    
    dobjFor(Knock)
    {
        verify() {}
        action()
        {
            "The <<dirName>> wall sounds hollow. ";
        }
    }
    
    holedir = 'north'
;

clamBarrier: TravelBarrier
    canTravelerPass(actor, connector) { return !giantBivalve.isIn(actor); }
    explainTravelBarrier(actor, connector)
    {
        "You can't fit this five-foot <<giantBivalve.opened ? 'oyster' : 'clam'>> through
        <<connector.theName>>. ";        
    }
    
;


/* 103 */
inShellRoom: DarkRoom 'In Shell Room' 'shell room; large sedimentary; rock'
    "{I}{'m} in a large room carved out of
        sedimentary rock.  The floor and walls are littered
        with bits of shells imbedded in the stone.  A shallow
        passage proceeds downward, and a somewhat steeper one
        leads up.  A low hands and knees passage enters from
        the south. "
    
    up = inArchedHall
    hall asExit(up)
    down = inRaggedCorridor
    passage =  "A shallow passage proceeds downward, and a somewhat steeper one
        leads up.  A low hands and knees passage enters from
        the south. You'll have to say which way you want to go. "

    south = lowPassage
    //
    // Let NPCs through.
    //
    NPCexit1 = atComplexJunction
    // Exit info. for 'back' command:
//    exithints = [At_Complex_Junction, &south]
;

+ Decoration 'shells; of[prep]; bits stone; them'
    "The floor and walls are littered
    with bits of shells embedded in the stone. "
;

lowPassage: DSPassage 'low passage' @inShellRoom @atComplexJunction
    "The low passage enters from the south. "
    travelBarriers = [clamBarrier]    
    destination = atComplexJunction
;


/* 104 */
inRaggedCorridor: DarkRoom 'In Ragged Corridor' 'ragged corridor; long sloping'
     "You are in a long sloping corridor with ragged sharp walls. "  

    up = inShellRoom
    shell asExit(up)
    down = inACulDeSac
;

+ Decoration 'ragged sharp walls;;;them'
    "They're sharp and ragged. "    
;

/* 105 */
 inACulDeSac: DarkRoom 'In a Cul-de-Sac'
    "You are in a cul-de-sac about eight feet across. "
    
    up = inRaggedCorridor
    out asExit(up)
    shell ulExit(inShellRoom)
;

/* 106 */
inAnteroom: DarkRoom 'In Anteroom'    
    "You are in an anteroom leading to a large
        passage to the east.  Small passages go west and up.
        The remnants of recent digging are evident.\b
    A sign in midair here says <q>Cave under
        construction beyond this point. Proceed at own risk<<if global.vNumber < 2>> --
        blasting in progress<<end>>.
        [Witt Construction Company]</q>"
    
    up = atComplexJunction
    west = inBedquilt
    east = atWittsEnd
    passage = "Passages lead west and up; you'll have to say which way you want to go. "
;

// This wording tweaked as a further clue to the otherwise underclued engame puzzle - ECSE
+ Distant 'hanging sign'
    "It's hanging way above {my} head."
    readDesc = "It says \"Cave under construction beyond this point.
        Proceed at own risk<<if global.vNumber < 2>> --
        blasting in progress<<end>>.  [Witt Construction Company]\""
    
    notImportantMsg = 'No chance.  It\'s too far up.'    
;

// This object added as a further clue to the otherwise underclued engame puzzle - ECSE
+ abandonedBox: Container, Fixture 'long wooden box;faded old; letters' @inAnteroom
    "It looks as if it may have been there for quite a long time.
    <<readDesc>> "
    
    initSpecialDesc = "A long wooden box lies abandoned by the passage east. "
    bulk = 8
    mass = 6
    
    readDesc = "Faded letters stenciled on the side read <q>DYNAMITE</q>. "
    
    cannotTakeMsg = 'The box looks too heavy and bulky to be worth lugging around. '
    iobjFor(PutIn)
    {
        action()
        {
            inherited();
            if(gDobj == blackRod)
                "You find that the box is just long enough for the rod to fit inside. ";
        }
    }
    
    isHidden = (global.vNumber > 1)
;


class DifferentMazeRoom: DarkRoom, NoNPC
    desc = "{I} {am} in a <<roomTitle.toLower()>>. "
    mazeskip = differentMazeSkip
;

differentMazeSkip: MazeSkipConnector
    destList = [deadEnd14, atWestEndOfLongHall]
;

DifferentMazeRoom template 'roomTitle';

/*
 * This maze is off limits to NPCs again, in keeping with the 551-point
 * version.  (And because it's hard for NPCs to get out of this maze once
 * they've entered it.)
 */
/* 107 */
differentMaze1: DifferentMazeRoom    
    'You are in a maze of twisty little passages, all different. '
    
    south = differentMaze3
    southwest = differentMaze4
    northeast = differentMaze5
    southeast = differentMaze6
    up = differentMaze7
    northwest = differentMaze8
    east = differentMaze9
    west = differentMaze10
    north = differentMaze11
    down = atWestEndOfLongHall
;

/* 108 */
atWittsEnd: DarkRoom 'At Witt\'s End' 'Witt\'s End; witts'   
    "You are at Witt's End.  Passages lead off in *all* directions. "
    
    east = wittConnector
    
    west = "{I} {have} crawled around in some little holes and
        found {my} way blocked by a recent cave-in.  {I} {am}
        now back in the main passage. "

    north = wittConnector
    south = wittConnector 
    northeast = wittConnector
    southeast = wittConnector 
    southwest = wittConnector 
    northwest = wittConnector 
    up = wittConnector 
    down = wittConnector
    passage = "Passages lead off in all directions; you'll have to say which way you want to go. "

    
//    roomAfterAction()
//    {
//        if(spelunkerToday.location == self && !spelunkerToday.depositpointsawarded)
//        {
//            spelunkerToday.depositpointsawarded = true;
//            addToScore(spelunkerToday.depositpoints, 'dropping the magazines at Witts End');
//        }
//    }
    
    //
    // Let NPCs out of here with no trouble; they always go back 
    // to the anteroom, since they have no way out of the computer 
    // center.
    //
    NPCexit1 = inAnteroom
    // but if we try to go back, we're blocked by the cave-in.
    // Exit info. for 'back' command:
//    exithints = [inAnteroom, &west]
//    myhints = [Witthint]
;

wittConnector: VarDest, TravelConnector
    calcDest()   
    {
        if (global.game580) return sOfCenter;
            else return inAnteroom;
    }
     
    canTravelerPass(actor)
    {        
        local wittpct = 95;     
        if (clover.isIn(actor)) 
            wittpct = 80;
        
        return (rand(100) > wittpct);
       
    }
    explainTravelBarrier(actor, connector)     { crawled_around.crawlMsg; }     
;

/* 109 */
inMirrorCanyon: DarkRoom 'In Mirror Canyon'    
    "You are in a north/south canyon about 25 feet
        across.  The floor is covered by white mist seeping
        in from the north.  The walls extend upward for well
        over 100 feet.  Suspended from some unseen point far
        above you, an enormous two-sided mirror is hanging
        parallel to and midway between the canyon walls.\b
       
        The mirror is obviously provided for the use of the
        dwarves, who as you know, are extremely vain.\b

        A small window can be seen in either wall,
        some fifty feet up. "
    
    south = inSecretNSCanyon0
    north = atReservoir
    toReservoir asExit(north)
;

+ Distant 'enormous mirror; huge big large suspended hanging vanity dwarvish two-sided two sided'
    "It looks like an ordinary, albeit enormous, mirror. "
    
    decorationActions = inherited + LookIn
    
    notImportantMsg = '{I} can\'t reach it from here. '
    
    dobjFor(LookIn)
    {
        preCond = [objVisible]
        action()
        {
            "All you can see is a reflection of the canyon walls.  The
             mirror is too high up to show your reflection. ";
        }
    }    
;
    
+ Distant 'windows;small;window; them it'
    "A window can be seen in both the east and the west walls
        of the canyon, about 50 feet up. "
    
    actionDobjCount = "There are two of them. "
    decorationActions = inherited + Count
    
;

+ Decoration 'canyon walls;;;them'
    "The walls extend upward for well over 100 feet. "
;

/* 110 */
atWindowOnPit2: DarkRoom 'At Window on Pit'
    "{I}{'m} at a low window overlooking a huge pit,
        which extends up out of sight.  A floor is
        indistinctly visible over 50 feet below.  Traces of
        white mist cover the floor of the pit, becoming
        thicker to the left. Marks in the dust around the
        window would seem to indicate that someone has been
    here recently.  Directly across the pit from {me} and
        25 feet away there is a similar window looking into a
        lighted room.  A shadowy figure can be seen there
      peering back at {me}. "
    
    west = atJunctionOfThreeSecretCanyons
    jump() {brokenNeck.travelVia(gActor); }
    
    reflect = atWindowOnPit1
    
    wavehands = "The shadowy figure waves back at {me}. ";
;

/* 111 */
atopStalactite: DarkRoom 'Atop Stalactite' 'atop stalactite; large; stalagmite'
    "A large stalactite extends from the roof and
    almost reaches the floor below.  You could climb down
    it, and jump from it to the floor, but having done so
    you would be unable to reach it to climb back up."
    
    north = InSecretNSCanyon1
    
    jump  { goInstead(down); }
    climb  { goInstead(down); }
    
    down: VarDest, TravelConnector
    {
        calcDest()
        {        
            if (rand(100) <= 40)
                return alikeMaze6;
            else if (rand(100) <= 50)
                return alikeMaze9;
            else
                return alikeMaze4;
        }
    }
    
    cannotMoveMsg = 'Do get a grip on yourself. '
    cannotTakeMsg = cannotMoveMsg
    cannotLookUnderMsg = cannotMoveMsg
    canLookUnderMe = nil
    
    
    //
    // Let NPCs through to the maze
    //
    NPCexit1 = alikeMaze6
    NPCexit2 = alikeMaze9
    NPCexit3 = alikeMaze4
;


/* 122 */
differentMaze2: DifferentMazeRoom    
    'Little Maze of Twisting Passages, All Different'    
    
    southwest = differentMaze3
    north = differentMaze4
    east = differentMaze5
    northwest = differentMaze6
    southeast = differentMaze7
    northeast = differentMaze8
    west = differentMaze9
    down = differentMaze10
    up = differentMaze11
    south = deadEnd14
;


atReservoir: DarkRoom 'At Reservoir; reservoir room; (at)'
//    sdesc = { if (global.game550) "South Edge of Reservoir";
//                else "At Reservoir"; }
    desc() {
        // This one changes a lot between the three versions.
        if (global.game550)
            "You are at the southern edge of a
            large underground reservoir.  A thick cloud of white mist
            fills the room and rises rapidly upward.  The lake is fed
            by a stream, which tumbles out of a hole in the wall about
            10 feet overhead and splashes noisily into the water near
            the reservoir's northern wall.  A dimly-seen passage exits
            through the northern wall, but you can't get across the
            water to get to it.  Another passage leads south from here.";
        else 
        {
            "You are at the edge of a large underground
            reservoir.  An ";
            if (global.newGame)
                "almost "; // DJP - added for 551-point version
            "opaque cloud of white mist fills the
            room and rises rapidly upward.  The lake is fed by a
            stream, which tumbles out of a hole in the wall about
            10 feet overhead and splashes noisily into the water
            somewhere within the mist.  ";
            if (global.newGame)
                "The indistinct shape of the
                opposite shore can be dimly seen through the mist. ";
            "The only passage goes back toward the south. ";
        }
    }
    south = inMirrorCanyon
    out asExit(south)
    passage = south
    
    north: TravelConnector
    {
        isConnectorListed = turtle.isIn(lexicalParent)
        travelVia(actor) { doInstead (Cross, reservoir); }
        
    }
    
    
//        local actor := getActor(&travelActor);
//        Reservoir.doCross(actor);
//        return nil;
//    }
    cross asExit(north) // BJS: Added
    across asExit(north)
;

+ Decoration 'hole;;stream wall'
    " The lake is fed  by a stream, which tumbles out of a hole in the wall about
            10 feet overhead and splashes noisily into the water near
            the reservoir's northern wall. "
;
    
reservoir: MultiLoc, StreamItem 'reservoir;underground large;lake water stream'
    
    desc() {
        "It's a large reservoir, from which a cloud of mist rises. ";
        if(global.newGame || global.game550)
            "The opposite shore can be seen indistinctly through
            the mist.  However, you can't swim and there is no
            way across the reservoir from here. ";
        else
            "There is no way across the reservoir. ";
    }
    
    locationList = [atReservoir, swordPoint, northOfReservoir]
    
    dobjFor(Cross)
    {
        verify {}
        check
        {
            if(global.game550)
            {
                if(turtle.location == location)             
                    return;   
                
                else
                    "I can't swim, or walk on water.  You'll have to find
                    some other way across, or get someone to assist you.";
            }
            else if(global.newGame)
                "I can't swim, or walk on water.  You'll have to find some other way across.";
            else
                "I can't swim, or walk on water. There is no way across.";
        }
        action()
        {
            "You step gently on Darwin the Tortoise's back,
            and he carries you smoothly over to the southern
            side of the reservoir.  He then blows a couple of
            bubbles at you and sinks back out of sight.";
            turtle.moveInto(nil);
                
            gActor.travelVia(atReservoir);
        }
    }
;

//
// Here's where the pirate(s) keeps his treasure (as well as any loot
// he's swiped from the player).  Once the chest has been been found
// here, turn off the pirate(s) completely.  (This is how the original
// handled it, and it's thankfully merciful so I've kept it the same.)
//
// DJP - corrected a bug in enterRoom so that the pirate really is turned
// off as intended.
//
/* 114 */
deadEnd13: DeadEndRoom 'At a Dead End' 'dead end; (at) pirate\'s'
    desc = "This is the pirate's dead end."

    southeast = alikeMaze13
    out asExit(southeast)
    mazeskip = alikeMazeSkip
    
    travelerEntering(actor, origin)
    {
     // DJP - isIn(Me) changed to isIn(self)
        if (treasureChest.isIn(self) && !treasureChest.seen && litWithin()) 
        {
           "<.p>You've found the pirate's treasure chest!<.p>";
            
            pirates.moveInto(nil);
//            unnotify(Pirates, &move);
//            treasure_chest.spotted := true;
//            PirateMessage.moveInto(nil);
        }

        inherited(actor, origin);
    }
    
    dismabigName = 'pirate\'s dead end'
;

/* 115,116 are at the end of this file */

/* 117 */
onSWSideOfChasm: DarkRoom 'On SW Side of Chasm'    
    "You are on one side of a large, deep chasm.  A
    heavy white mist rising up from below obscures all
    view of the far side.  A southwest path leads away
    from the chasm into a winding corridor. <<ricketyBridge.xdesc>>"
    
    southwest: PathPassage 'southwest path; sw winding corridor'  ->inSlopingCorridor
    "The southwest path leads away from the chasm into a winding corridor."
    {  location = lexicalParent }
    
    //    across = { return self.over; }
    //    cross = { return self.over; }
    northeast = ricketyBridge
    
    
    //    over = {
    //        local actor := getActor(&travelActor);
    //        RicketyBridge.doCross(actor);
    //        return nil;
    //    }
    
    jump() 
    {
        if (ricketyBridge.exists)     
            "I respectfully suggest you go across the
            bridge instead of jumping." ;        
        else
            didnt_make_it.death;
    }

    over()
    {
        if(ricketyBridge.exists)
            doInstead(TravelVia, ricketyBridge);
        else
            "There's no way of crossing the chasm. ";
    }
    
    cross() {over();}
    across() {over(); }
    
    
    //
    // No NPC exits because we don't want the pirate to be able
    // to go across the bridge and steal the player's return toll.
    // (All rooms on the other side of the bridge are off limits
    // to NPC's.)
    //
    // It would be OK for dwarves to show up over there, except
    // that they might run into the bear, a situation for which we don't
    // have any code.  (This is how the original was as well.)
    //
    // Exit info. for 'back' command:
//    exithints = [On_Ne_Side_Of_Chasm, &over]
;


class RFD: MultiLoc, Fixture 
    desc = "You know as much as I do at this point."
;

trollChasm: RFD 'chasm; deep large'
 
    locationList = [onSWSideOfChasm, onNESideOfChasm ]
    isWaveTarget = true
;

+ MultiLoc, Decoration 'mist; heavy white misty'
    "It looks pretty misty to me. "
    notImportantMsg = 'The mist is too insubstantial for that. '
    locationList = [onSWSideOfChasm, onNESideOfChasm ]
;

ricketyBridge: DSPassage 'rickety bridge; unstable wooden wobbly rope'     
    @onSWSideOfChasm @onNESideOfChasm 
    "It just looks like an ordinary, but unstable, bridge. "
    
    
    isWaveTarget = true
    xdesc() 
    {
        if (exists) 
        {
            "A rickety wooden bridge extends across the
            chasm, vanishing into the mist.\b";
            
            "A sign posted on the bridge reads,
            <q>Stop! Pay troll!</q>";
        }
        else if(isBurnt) 
            "The charred remains of a wooden
            bridge can be seen at the bottom of the chasm. ";
        else 
            "The wreckage of a bridge (and a dead bear)
            can be seen at the bottom of the chasm." ;
    }
    
    
    exists = true
    strengthened = nil
    prevStrength = nil
    isBurnt = nil
    isConnectorApparent = exists
    isHidden = !exists
    
    dobjFor(Cross) asDobjFor(GoThrough)
    
    travelDesc()
    {
        local actor = gActor;
        if (bear.isFollowing) 
        {            
            if(!strengthened) 
            {
                "Just as you reach the other side, the bridge
                buckles beneath the weight of the bear, which
                was still following you around. You scrabble
                desperately for support, but as the bridge
                collapses you stumble back and fall into the
                chasm.";
            }
            else 
            {
                "The bridge is no longer rickety!  In fact it
                feels very secure as you cross, and easily
                supports the weight of the bear, which was still
                following you around.   Unfortunately the spell
                seems to wear off at the instant you reach the
                other side.   With a loud <q>Crack!</q> the bridge
                collapses under the weight of the bear, which
                scrambles frantically
                to reach your side but fails to make it. ";
            }
            
            // Get rid of the bridge in case the
            // player gets reincarnated and
            // continues the game.
            exists = nil;
            //            self.moveLoclist([]);
            //            On_Sw_Side_Of_Chasm.contents -= self;
            //            On_Ne_Side_Of_Chasm.contents -= self;
            // No more bear!
            bear.exists = nil;
            //            deadBear.moveLoclist([On_Sw_Side_Of_Chasm,
            //                On_Ne_Side_Of_Chasm]);
            /* 
             *   DJP: The player survives if the bridge has been strengthened.
             */
            if(strengthened) 
            {
                strengthened = nil;
                return true;
                //                actor.travelTo(On_Sw_Side_Of_Chasm);
            }
            else 
            {
                /* 
                 *   DJP: in accordance with the original game, move the adventurer to the other
                 *   side to make his possessions accessible after reincarnation.
                 */
                actor.moveInto(onSWSideOfChasm);
                finishGameMsg(ftDeath, [finishOptionUndo]);
            }
            return nil;
        }
        else if (troll.isDuped && global.game550
                 && troll.isPaid == nil) 
        {
            "As you reach the middle of the bridge, the troll
            appears from out of the tunnel behind you, wearing
            a large backpack.  \"So, Mister Magician,\" he
            shouts, \"you like to use magic to steal back my
            hard-earned toll?  Let's see how you like a little
            of MY magic!!\"  With that, he aims a tube running
            from the backpack directly at the bridge and pulls
            a trigger.  A spout of magical fire roars out and
            incinerates the bridge supports, causing the bridge
            to sway giddily and collapse into the chasm.  You
            plunge down to your death.";
            exists = nil;
            isBurnt = true;
            //            self.moveLoclist([]);
            burntBridge.moveIntoAdd([onSWSideOfChasm, onNESideOfChasm]);
            /* 
             *   DJP: in accordance with the original game, move the adventurer to the other side to
             *   make his possessions accessible after reincarnation.
             */
            actor.moveInto(onSWSideOfChasm);
            finishGameMsg(ftDeath, [finishOptionUndo]);
            return nil;
        }
        else if (actor.isIn(onSWSideOfChasm)) 
        {
            troll.isPaid = nil;
            /* DJP - issue message if upgraded rod has been used */
            if(self.strengthened) 
            {
                "As you cross, you get a vague sense that something
                isn't quite right.  You realize what it is -
                although the bridge still \(looks\) very rickety,
                it doesn't actually \(feel\) rickety!\b ";
                
                strengthened = nil;
                prevStrength = true;
            }
            else if(prevStrength) 
            {
                "You notice that the bridge is now as rickety
                as it looks.  You deduce that the magic wears off
                after one crossing.\b"; 
                prevStrength = nil;
            }
            return true;
            //            actor.travelTo(On_Ne_Side_Of_Chasm);
        }
        else 
        {
            troll.isPaid = nil;
            /* DJP - issue message if upgraded rod has been used */
            if(strengthened) 
            {
                "As you cross, you get a vague sense that something
                isn't quite right.  You realize what it is -
                although the bridge still \(looks\) very rickety,
                it doesn't actually \(feel\) rickety! <.p>";
                
                strengthened = nil;
                prevStrength = true;
            }
            else if(prevStrength) 
            {
                "You notice that the bridge is now as rickety
                as it looks.  You deduce that the magic wears off
                after one crossing.<.p> ";
                prevStrength = nil;
            }
            return true;
            //            actor.travelTo(On_Sw_Side_Of_Chasm);
        }       
    }
    
    canTravelerPass(actor)
    {
        if(actor == bear)
            return nil;
        else if(troll.isPaid == location || troll.location == nil)
            return true;
        return nil;            
    }
    
    explainTravelBarrier(traveler, connector)
    {
        if(traveler == bear)
            "That bridge looks very rickety.  The bear refuses
            to cross it ahead of you.";
        else if(troll.location != location)        
        {
            "The troll steps out from beneath the bridge and blocks {my} way. ";                
            troll.moveInto(location);
        }
        else
            "The troll refuses to let you cross. ";
        
    }
    
//    travelVia(actor)
//    {
//        if(cross(actor))
//            inherited(actor);
//    }
;

+ Component 'sign'
    "The sign posted on the bridge reads, <q>Stop! Pay troll!</q> "
    readDesc = desc
;
burntBridge: MultiLoc, Distant 'bridge wreckage; burnt wrecked destroyed wrecked charred 
    burned wooden'
    "The charred remains of the bridge lie at the bottom of the
            chasm.  They are too far away to examine closely."
    
    locationlist = []
;



/* Special treasure room for the troll. An ldesc is defined because we might
   be able to view it after the sapphire has been used as a toll.  It's
   otherwise off limits to players.

   The original a-code implementation of the 550-point version has similar
   rooms.  LIMBO is a repository for objects which are unavailable to the 
   player, including tolls.  YLEM is a 'circular file' for objects which have 
   been irretrievably lost or destroyed.  Note that the TADS implementation 
   does not have an YLEM and allows certain objects to reappear after they 
   have been lost.  For example, the axe may reappear, the lamp will reappear 
   after reincarnation (if not destroyed), and the eggs can always be sent to 
   the Giant room. 
 */

trollTreasure: Room, NoNPC 'Troll\'s treasure room'
    desc {
        "You are in a large chamber, lit by a strange orange
        glow.  It appears to be the room where the troll stores his
        treasures!  Fixed to the walls
        are numerous shelves, stacked with gold, silver and platinum
        articles, musical instruments, vases, clocks and ornaments
        of all descriptions.
        Part of the room is stacked to the ceiling with treasure
        chests, all full to overflowing with precious stones.
        Another area is full of antique furniture which the troll has
        collected over the centuries - some of the items must be
        worth an absolute fortune!
        In the center of the room a table is piled high with
        valuable coins, and an open ledger records the tolls paid
        by adventurers over the years.  ";
        if((troll.location == nil) && (!global.closed)) 
        { 
        //troll chased away by the bear
            "You see the troll here, counting money and cataloging
            his treasures.  You hear him muttering something about
            \"that pesky bear\".";
        }
    }
;

/* 118 */
inSlopingCorridor: DarkRoom 'In Sloping Corridor' 'sloping corridor; (in} long winding'   
    "You are in a long winding corridor sloping out
    of sight in both directions."
    
    down = inLargeLowRoom
    up = onSWSideOfChasm
;

/* 119 to 121 */

/* (This was implemented as 3 locations in the original version, but now
 * there is just one location.  While the dragon is present, the reachability
 * of objects is checked in a similar way to the glass bridge in The Mulldoon
 * Legacy.  Items are reachable only if they were dropped on the same side
 * as the dragon.)
 */
#define EAST_EXIT 0
#define NORTH_EXIT 1


inSecretCanyon: DarkRoom 'In Secret Canyon'    
    "You are in a secret canyon which exits to the north and east. "
    
    north: VarDest, TravelConnector
    {
        calcDest()
        {
            local loc = gActor.getPreviousLocation;
            if(loc == inSecretNSCanyon0)
                return loc;
            else            
                return inSecretNSCanyon0;                         
        }
    }
        
    east: VarDest, TravelConnector
    {
        calcDest()
        {
            local loc = gActor.getPreviousLocation;
            if(loc != inSecretNSCanyon0)           
                return inSecretEWCanyon;
            else
                return inSecretNSCanyon0;            
        }
    }
         

    // dragonCheck is implemented on dragon object.
    
    fore: VarDest, TravelConnector
    {
        isConnectorListed = nil
        
        calcDest = gActor.getPreviousLocation == inSecretNSCanyon0 ? lexicalParent.east.destination :
        lexicalParent.north.calcDest;
    }
    
    
    out: VarDest, TravelConnector
    {
        isConnectorListed = nil;
        calcDest = gActor.getPreviousLocation == inSecretNSCanyon0 ? lexicalParent.north.destination :
        lexicalParent.east.destination;
    }
    
    NPCexit1 = inSecretNSCanyon0
    NPCexit2 = inSecretEWCanyon
    
    // is it worth implementing non-reachability of objects on the wrong side of the dragon?
    
;

/* 122 */
onNESideOfChasm: DarkRoom, NoNPC 'On NE Side of Chasm'    
     "You are on the far side of the chasm.  A
        northeast path leads away from the chasm on this
        side. <<ricketyBridge.xdesc>> "
       
    
    wino_trollstop = true // troll stops a wino from getting to cloak_pits
    
    northeast = inCorridor
    southwest = ricketyBridge
    over asExit(southwest)
    aross asExit(southwest)
    cross asExit(southwest)

    
    jump ()
    {
        if (ricketyBridge.exists)         
            "I respectfully suggest you go across the
            bridge instead of jumping. ";        
        else
            didnt_make_it.death;
    }

    fork = atForkInPath
    view = atBreathtakingView
    barren = inFrontOfBarrenRoom
    
    // Exit info. for 'back' command:
//    exithints = [On_Sw_Side_Of_Chasm, &over]
;

/* 123 */
inCorridor: DarkRoom, NoNPC 'In Corridor'    
    "{I}{'m} in a long east/west corridor.  A faint
     rumbling noise can be heard in the distance. "
    
    
    wino_trollstop = true // troll stops a wino from getting to cloak_pits
    
    west = onNESideOfChasm
    east = atForkInPath
    fork = atForkInPath
    view = atBreathtakingView
    barren = inFrontOfBarrenRoom
//    listenDesc = "You hear a faint rumbling noise in the distance. "
;

+ Noise 'faint rumbling noise'
    "You hear a faint rumbling noise in the distance. "
    listenDesc = desc
;
    

/* 124 */
atForkInPath: DarkRoom, NoNPC 'At Fork in Path'    
        "The path forks here.  The left fork leads
        northeast.  A dull rumbling seems to get louder in
        that direction.  The right fork leads southeast down
        a gentle slope.  The main corridor enters from the
        west. "
           
    wino_trollstop = true // troll stops a wino from getting to cloak_pits
    
    west = inCorridor
    northeast = atJunctionWithWarmWalls
    left = atJunctionWithWarmWalls
    southeast = inLimestonePassage
    right = inLimestonePassage
    down asExit(southeast)
    
    view = atBreathtakingView
    barren = inFrontOfBarrenRoom
    listenDesc = "You hear a faint rumbling noise in the distance. "
;

+ PathPassage 'left fork' -> atJunctionWithWarmWalls
    "The left fork leads northeast. "
;

+ PathPassage 'right fork; gentle; slope' ->inLimestonePassage
     "The right fork leads southeast down a gentle slope. "
;

+ PathPassage 'main corridor' ->inCorridor
    "The main corridor enters from the west. "
;


/* 125 */
atJunctionWithWarmWalls: DarkRoom, NoNPC  'At Junction With Warm Walls'
    'junction with warm walls; (at) entire; cave'
        "The walls are quite warm here.  From the north
        can be heard a steady roar, so loud that the entire
        cave seems to be trembling.  Another passage leads
        south, and a low crawl goes east. "   
    
        wino_trollstop = true // troll stops a wino from getting to cloak_pits
    
    south = atForkInPath
    fork = atForkInPath
    north = atBreathtakingView
    view = atBreathtakingView
    east: PathPassage 'low crawl' -> inChamberOfBoulders
    "The low crawl goes east. "
        { location = static lexicalParent }
    
    crawl = inChamberOfBoulders
    passage = south    
;

+ Noise 'steady roar; loud'
    "You hear a steady roar from the north. "
    listenDesc = desc
;


/* 126 */
atBreathtakingView: Room, NoNPC 'At Breath-Taking View'    
    'breath-taking view; breathtaking (at); cavern'
    desc()
    {
        "{I} {am} on the edge of a breath-taking view. Far
        below {me} is an active volcano, from which great
        gouts of molten lava come surging out, cascading back
        down into the depths.  The glowing rock fills the
        farthest reaches of the cavern with a blood-red
        glare, giving everything an eerie, macabre
        appearance. The air is filled with flickering sparks
        of ash and a heavy smell of brimstone.  The walls are
        hot to the touch, and the thundering of the volcano
        drowns out all other sounds.  Embedded in the jagged
        roof far overhead are myriad twisted formations
        composed of pure white alabaster, which scatter the
        murky light into sinister apparitions upon the walls.
        To one side is a deep gorge, filled with a bizarre
        chaos of tortured rock which seems to have been
        crafted by the devil himself.  An immense river of
        fire crashes out from the depths of the volcano,
        burns its way through the gorge, and plummets into a
        bottomless pit far off to {my} left.<.p>  ";
        
        if (global.game550) {
            "Across the gorge, the entrance to
            a valley is dimly visible.  ";
        }
        "To the right, an immense geyser of blistering steam erupts
        continuously from a barren island in the center of a
        sulfurous lake, which bubbles ominously.  The far
        right wall is aflame with an incandescence of its
        own, which lends an additional infernal splendor to
        the already hellish scene.  A dark, forboding passage
        exits to the south.";
    }
    
    wino_trollstop = true // troll stops a wino from getting to cloak_pits
    
    south = atJunctionWithWarmWalls
    passage = atJunctionWithWarmWalls
    out asExit(south)
    
    fork = atForkInPath
    // DJP - changed this to pass on the actor.  We must make sure that
    // the bear doesn't go where he shouldn't!
    valley 
    {        
        if (global.game550)
            return wheatStoneBridge;
        else 
            "There is no valley here. Perhaps in another version...";
        return nil;            
    }  
    
    north = wheatStoneBridge

    cross asExit(north)
    gorge asExit(north)

    
    jump asExit(down)
    down = 'Don\'t be ridiculous! '
    
    listenDesc = "The sound of the volcano is almost deafening. "
//    exithints = [ Valley_Faces, &north ]
    
    cannotGoThatWay(dir)
    {
        if(dir == northDir)
            "There is no way over the gorge. ";
        else
            inherited(dir);
    }
;

+ Distant 'some sparks of ash; flickering; air spark; them'
    "The sparks are too far away for you to get a good look at them. "    
;

+ Distant 'jagged roof; twisted murky pure white sinister; alabaster formations apparitions ceiling'
    "Embedded in the jagged roof far overhead are myriad
     twisted formations composed of pure white alabaster,
     which scatter the murky light into sinister
      apparitions upon the walls. "
;

+ Distant 'valley'
    "It's dimly visible across the gorge. "
    
    iswavetarget = true 
    isHidden = !global.game550
    game550 = true
;

MultiLoc, Distant 'active volcano; glowing blood red blood-red eerie macabre; rock glare'
   "Great gouts of molten lava come surging out of the
    volcano and go cascading back down into the depths.
    The glowing rock fills the farthest reaches of the
    cavern with a blood-red glare, giving everything an
     eerie, macabre appearance. "
    
    locationList = [atBreathtakingView, valleyFaces]
    iswavetarget = true 
;

MultiLoc, Distant 'deep gorge; bizarre tortured; chaos rock depths'
    desc
    {
        "The gorge is filled with a bizarre chaos of tortured
        rock which seems to have been crafted by the devil
        himself. ";
        if (global.game550 && gActor.isIn(atBreathtakingView))
            "Across the gorge, the entrance to a valley is dimly visible. "; 
    }
    locationList = [atBreathtakingView, valleyFaces]
    iswavetarget = true 
;

MultiLoc, Distant 'river of fire; fiery firey bottomless;lava pit'
    "The river of fire crashes out from the depths of the
        volcano, burns its way through the gorge, and
    plummets into a bottomless pit far off to {my}
     <<if gActor.isIn(atBreathtakingView)>>left<<else>> right<<end>>. "
        
    iswavetarget = true // magic can be worked by waving the rod at it ...
    locationList = [atBreathtakingView, valleyFaces]
;

MultiLoc, Distant 'immense geyser; blistering barren sulfrous sulphurous sulprhous
   sulfurous bubbling; steam island lake'
    
     "The geyser of blistering steam erupts continuously
        from a barren island in the center of a sulfurous
        lake, which bubbles ominously. "
    
    
    iswavetarget = true // magic can be worked by waving the rod at it ...
    locationList = [atBreathtakingView, valleyFaces]
;

/* 127 */
inChamberOfBoulders: DarkRoom, NoNPC 'In Chamber of Boulders'
    'chamber of boulders; (in) small; room'
       "You are in a small chamber filled with large
        boulders.  The walls are very warm, causing the air
        in the room to be almost stifling from the heat.  The
        only exit is a crawl heading west, through which is
        coming a low rumbling. "
    
    wino_trollstop = true // troll stops a wino from getting to cloak_pits
    
    west: PathPassage 'crawl heading west' ->atJunctionWithWarmWalls
        { location = static lexicalParent }
    out asExit(west)
    crawl asExit(west)
    fork = atForkInPath
    view = atBreathtakingView
    
;

+ Decoration 'boulders; warm ordinary large; rocks stones boulder; them'
    "They're just ordinary boulders.  They're warm. "
;

+ Noise 'low rumbling;;sound noise'
    "You hear a low rumbling sound. "
    listenDesc = desc
;


/* 128 */
inLimestonePassage: DarkRoom, NoNPC 'In Limestone Passage'
    "You are walking along a gently sloping
     north/south passage lined with oddly shaped limestone formations. "    
    
    wino_trollstop = true // troll stops a wino from getting to cloak_pits
    
    north = atForkInPath
    up asExit(north)
    fork = atForkInPath
    
    south = inFrontOfBarrenRoom
    down asExit(south)
    barren = inFrontOfBarrenRoom
    
    view = atBreathtakingView
;

+ Decoration 
    'limestone formations; lime stone limestone oddly sheped oddly-shaped ;shape shapes; them'
     "Every now and then a particularly strange shape catches {my} eye. "
    
    wino_trollstop = true // troll stops a wino from getting to cloak_pits    
;    


/* 129 */
inFrontOfBarrenRoom: DarkRoom, NoNPC 'In Front of Barren Room'
     "You are standing at the entrance to a large,
        barren room.  A sign posted above the entrance reads:
        \"Caution!  Bear in room!\"" 
        
     wino_trollstop = true // troll stops a wino from getting to cloak_pits
    
    west = inLimestonePassage
    up asExit(west)
    fork = atForkInPath
    
    east = inBarrenRoom
    in asExit(east)
    
    barren = inBarrenRoom
//    enter = In_Barren_Room
    view = atBreathtakingView
;

+ Fixture 'barren room sign'
    "The sign reads, \"Caution!  Bear in room!\""
    readDesc = desc
;

+ Enterable -> inBarrenRoom 'entrance; barren; room'
     "A sign posted above the entrance reads: <q>Caution!  Bear in room!</q>" 
    dobjFor(GoThrough) asDobjFor(Enter)
    vocabLikehood = 10
;

/* 130 */
inBarrenRoom: DarkRoom 'In Barren Room'    
    "You are inside a barren room.  The center of
     the room is completely empty except for some dust.
     Marks in the dust lead away toward the far end of the
     room.  The only exit is the way you came in."
    
    wino_trollstop = true // troll stops a wino from getting to cloak_pits
    
    west = inFrontOfBarrenRoom
    out asExit(west)
    fork = atForkInPath
    view = atBreathtakingView
;

+ Decoration 'dust;;marks'
    "It just looks like ordinary dust. "
;

/* 131 */
differentMaze3: DifferentMazeRoom 'Maze of Twisting Little Passages, All Different'   
    west = differentMaze1
    southeast = differentMaze4
    northwest = differentMaze5
    southwest = differentMaze6
    northeast = differentMaze7
    up = differentMaze8
    down = differentMaze9
    north = differentMaze10
    south = differentMaze11
    east = differentMaze2
;

/* 132 */
differentMaze4: DifferentMazeRoom 'Little Maze of Twisty Passages, All Different'
   
    northwest = differentMaze1
    up = differentMaze3
    southeast = differentMaze2
    
    north = differentMaze5
    south = differentMaze6
    west = differentMaze7
    southwest = differentMaze8
    northeast = differentMaze9
    east = differentMaze10
    down = differentMaze11    
;


/* 133 */
differentMaze5: DifferentMazeRoom 'Twisting Maze of Little Passages, All Different'
   
    up = differentMaze1
    down = differentMaze3
    west = differentMaze4
    south = differentMaze2
    
    northeast = differentMaze6
    southwest = differentMaze7
    east = differentMaze8
    north = differentMaze9
    northwest = differentMaze10
    southeast = differentMaze11    
;

/* 134 */
differentMaze6: DifferentMazeRoom 'Twisting Little Maze of Passages, All Different'
    
    ne = differentMaze1
    sw = differentMaze2
    north = differentMaze3
    nw = differentMaze4
    se = differentMaze5
    
    east = differentMaze7
    down = differentMaze8
    south = differentMaze9
    up = differentMaze10
    west = differentMaze11
    
;

/* 135 */
differentMaze7: DifferentMazeRoom 'Twisty Little Maze of Passages, All Different'
    
    north = differentMaze1
    up = differentMaze2
    southeast = differentMaze3
    down = differentMaze4
    south = differentMaze5
    east = differentMaze6
    
    west = differentMaze8
    southwest = differentMaze9
    northeast = differentMaze10
    northwest = differentMaze11
    
;

/* 136 */
differentMaze8: DifferentMazeRoom 'Twisty Maze of Little Passages, All Different'
    
    east = differentMaze1
    north = differentMaze2
    west = differentMaze3
    up = differentMaze4
    southwest = differentMaze5
    down = differentMaze6
    south = differentMaze7
    
    northwest = differentMaze9
    southeast = differentMaze10
    northeast = differentMaze11
    
;

/* 137 */
differentMaze9: DifferentMazeRoom 'Little Twisty Maze of Passages, All Different'
    
    southeast = differentMaze1
    west = differentMaze2
    northeast = differentMaze3
    south = differentMaze4
    down = differentMaze5
    up = differentMaze6
    northwest = differentMaze7
    north = differentMaze8
    
    southwest = differentMaze10
    east = differentMaze11
    
;

/* 138 */
differentMaze10: DifferentMazeRoom 'Maze of Little Twisting Passages, All Different'
   
    down = differentMaze1
    northwest = differentMaze2
    east = differentMaze3
    northeast = differentMaze4
    up = differentMaze5
    west = differentMaze6
    north = differentMaze7
    south = differentMaze8
    southeast = differentMaze9
    southwest = differentMaze11
    
;

/* 139 */ 
differentMaze11: DifferentMazeRoom 'Maze of Little Twisty Passages, All Different'
    
    southwest = differentMaze1
    northwest = differentMaze3
    east = differentMaze4
    west = differentMaze5
    north = differentMaze6
    down = differentMaze7
    southeast = differentMaze8
    up = differentMaze9
    south = differentMaze10
    northeast = differentMaze2
;

/*
 * We don't allow NPC's here because it would be *really* bogus
 * if the pirate stole the batteries right after the player bought
 * them.
 */
/* 140 */
deadEnd14: NoNPC, DeadEndRoom 'At a Dead End, in Front of a Massive Vending Machine'
    'dead end; (in) (front) (of) (at) '
    "{I} {have} reached a dead end. There is a massive vending machine here.
    <<if (pirateMessage.isIn(self))>>\bHmmm...  There is a message here
            scrawled in the dust in a flowery script.<<end>>"      

    north = differentMaze2
    out asExit(north)
    mazeskip = differentMazeSkip
;

+ vendingMachine:Fixture 'vending machine; massive slot'
    "The instructions on the vending machine read,
     \"Insert coins to receive fresh batteries.\""
    
    canPutInMe = true
    iobjFor(PutIn)
    {
        check()
        {
            if(!gDobj.ofKind(Coin))
                 "The machine seems to be designed to take coins. ";
        }
        
        action()
        {
            local newbatt;
        
            "Soon after {i} insert{s/ed} ";
            if (gDobj == bag) "the pieces of eight";
            else "<<gDobj.theName>>";
            " in the coin slot, the vending machine makes a
            grinding sound, and a set of fresh batteries falls at
            {my} feet. ";
            if (gDobj == bag) {
                "You discard the empty bag, which disappears
                out of sight through a crevice in the floor. ";
            }
            gDobj.moveInto(nil);
            newbatt = new FreshBatteries;
            newbatt.moveInto(location); // Added - absent from TADS 2 code
            
            
            if(gDobj.ofKind(Treasure))
                global.vendingTreasures++;
        }
        
    }
    
;

pirateMessage: Fixture 'message in the dust;scrawled flowery;scrawl writing script'
    "The message reads, <q>This is not the maze where the
        pirate leaves his treasure chest.</q>"
    
    readDesc = desc
    
    location = nil  // moved to deadEnd14 when pirate spotted
;



 

brokenNeck: Room 'Bottom of Pit'
    "{I} {am} at the bottom of the pit with a broken neck.\b
    <<finishGameMsg(ftDeath, [finishOptionUndo])>> "    
;

westSideChamber: Room 'West Side Chamber'
;

didnt_make_it: object
    death = "You didn't make it.\b <<finishGameMsg(ftDeath, [finishOptionUndo])>>"         
; 

crawled_around: object
    crawlMsg = "{I} {have} crawled around in some little holes and
        wound up back in the main passage.<.p>";    
;

wontfit: object
    wfMsg = "Something {i}{'m} carrying won't fit through the
        tunnel with you. You'd best take inventory and drop
        something. ";
;


class Backdrop: MultiLoc, Decoration
    desc = "You know as much as I do at this point. "
    /* A Backdrop should never be included in ALL */
    hideFromAll(action) { return true; }
    
    /* 
     *   If there's anything else in the match list, remove myself from the
     *   matches
     */
    filterResolveList(np, cmd, mode)
    {
        if(np.matches.length > 1)
            np.matches = np.matches.subset({m: m.obj != self});
    }
    
    /* 
     *   Backdrops are potentially everywhere. This can be narrowed down on specific backdrop
     *   objects.
     */
      
    initialLocationClass = Room
    
    decorationActions = inherited + ThrowAt
;

bWalls: Backdrop 'walls; swiss cheese ragged sharp warm hot (north) (south) (east) (west)
    (e) (n) (s) (w); wall;them it'
    "I've already told all I know about the walls. "
    
    /* exclude walls from outdoor rooms. */
    exceptions = [outdoors]   
    deoorationActions = [Examine, Count, Read]
    
    actionDobjCount()
    {
        switch(gRoom)
        {
        case octagonalRoom:
            "It's an octagonal room.  That means it has 8 walls! "; break;
        case insideBuilding:
        case pantry:
            "This room has - wait for it -- four walls! "; break;
        case cylindricalRoom:
            "The wall of this room is one continuous surface. "; break;
        case sphericalRoom:
             "It's a spherical room.  That means that the wall, floor
            and ceiling are all one continuous surface, broken only
             by the exit passage. "; break;
        default:
            "Counting walls isn't easy in a cave, due to the irregular
            shapes of most rooms. ";
        }
    }
;

bCeiling: Backdrop 'ceiling;;roof'
    desc()
    {
        {        
            if (gActor.location == inSlabRoom) 
            {
                "You realize that this room doesn't have a ceiling any more!
                It looks as if you could go up to another room.";
            }
            //        else if (actor.location = Beach or actor.location = Beach_Shelf)
            //            "Actually, this room has no ceiling.";
            else inherited;
        }
    }
    
    
    /* exclude ceiling  from outdoor rooms. */
    exceptions = [outdoors] 
;

pdrop: Backdrop 'passage;
    low wide plugged good (east) (eastern) (e) (west) (w) (north) (n)
    (small) twisty little (n/s) e/wd (dirty) broken long
            (large) walking sizeable sizable cavernous
            blocked (immense) (gently) sloping coral dimly-seen
            dimly (seen) rumbling (rough) winding narrow
    shallow (somewhat) steeper (dark) forboding tight fourier; 
    opening openings corridor corridors path paths tunnel'
    
    
    
    decorationActions = [Examine, Enter, GoThrough, Follow]
    
    dobjFor(GoThrough) asDobjFor(Enter)
    dobjFor(Follow) asDobjFor(Enter)
    
    dobjFor(Enter)
    {
        verify() {}
        action()
        {
            local conn;
            local loc = gActor.getOutermostRoom();
            if(loc.propDefined(&passage))
            {
                switch(loc.propType(&passage))
                {
                case TypeObject:                
                    conn = loc.passage;
                    conn.travelVia(gActor);
                    break;
                case TypeCode:
                case TypeDString:
                    loc.passage();
                    break;
                case TypeSString:
                    say(loc.passage);
                    break;
                default:
                    moreSpecificMsg;
                    break;
                }
                
            }
            else
                    moreSpecificMsg;
            
           
        }
    }
     moreSpecificMsg = "You'll have to be more specific: which direction do you want to go in? "
    
    isInitiallyIn(obj) 
    { 
        return obj.hasPassage || obj.propDefined(&passage); 
    }
    
;

bAir: Backdrop 'air'
    decorationActions = [Examine, SmellSomething]
    
    smellDesc 
    {
        if(gRoom.propDefined(&smellDesc, PropDefDirectly))            
            gRoom.smellDesc; 
        else
            "The air smells pretty much like you would expect. ";
    }
    
    notImportantMsg = 'The air is too insubstantial for that. '    
;

bFootsteps: Backdrop '() your footsteps;;;them'  
    desc 
    {   
        if (global.oldGame || !(gActor.isIn(inArchedHall) ||
        (gActor.isIn(EWCorridorE))) || inArchedHall.jericho) {
            "They sound pretty normal to me. ";
        }
        else {
            "They reverberate hollowly around the chamber.  You have the
            feeling that the <<inArchedHallWalls.holedir>> wall is 
            maybe not as solid as it looks. ";
        }
    }
    
    decorationActions = [Examine, ListenTo]
    
    listenDesc
    {        
        if(isProminentNoise)
           "Your footsteps echo hollowly throughout the chamber.  ";
    }
    
    isProminentNoise = (!global.oldGame && (gActor.getOutermostRoom is in (inArchedHall,
        EWCorridorE)) && !inArchedHall.jericho)
;
