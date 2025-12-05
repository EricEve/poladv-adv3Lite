#charset "us-ascii"

#include <tads.h>
#include "advlite.h"

/* Additional rooms for 551-point version */

/* Mix-in class for rooms with a brassKey property */
class KeyCheck: object    
    brassKey = smallKey
    roomDaemon
    {
        local obj;
        for(obj in [tinyKey, smallKey, largeKey])
        {
           if(obj.isIn(self) && obj != brassKey)
            {
                brassKey.moveInto(obj.location);
                obj.moveInto(nil);
            }
        }
        inherited();
    }
;

/* Note the following change from the Fortran version.  For consistency,
'building' from a surface location takes us back to At_End_Of_Road, rather
than Inside_Building. */

/* 141 */
/* Note - in the 701-point game this room combines the 551-point Sword Point 
   room with the 550-point N_Of_Reservoir.  Note that the 701-point game has
   two sword-in-the stone puzzles with different solutions!
 */
    
 swordPoint: NoNPC, DarkRoom 'At Sword Point'
    'sword point; narrow; promontory'
    desc()
    {
        "{I} {am} on a narrow promontory at the foot of a waterfall, which
        spurts from an overhead hole in the rock wall and splashes into a
        large reservoir, sending up clouds of mist and spray.
        To the south, the indistinct shape of the opposite shore can be dimly
        seen.\b";
        
        "Through the thick white mist looms a polished marble slab, to
        which is affixed an enormous rusty iron anvil.  In golden letters
        are written the words: <q>Whoso Pulleth Out This Sword of This
        Stone and Anvil, is Rightwise King-Born of All This Mountain.</q>
        There is a narrow chimney on the east side of the promontory";
        
        // In the 701-point game, this room combines the characteristics of
        // the 551-point Sword_Point and the 550-point N_Of_Reservoir.  Players
        // may leave via the chimney, or hit the gong and ride the turtle.
        
        if (global.game701)
            ", and another passage leads north from here.  Large
            clawed tracks are visible in the damp ground, leading from
            the passage into the water. ";
        else ". ";
    }
    
    game551 = true
    
    up = topOfSlide  /* 142 */
    east asExit(up)
    climb asExit(up)    
    chimney asExit(up)
    slide asExit(up)
    south { doInstead(Cross, reservoir); }
    
    cross = (self.south)
    across = (self.south)
    
       
    listenDesc = "You hear the sound of the waterfall, noisily splashing
    into the water. "
    
    north: VarDest, TravelConnector
    {
        calcDest = global.game701 ? warmRoom : nil
    }

    balcony: VarDest, TravelConnector
    {
        calcDest = global.game701 ? inBalcony : nil
    }  
;

;
+ anvil: Fixture 'rusty anvil; enormous iron large'
    "It's just a large, rusty iron anvil, fixed to the marble slab. "
  
//    game551 = true    
    
;

+ Fixture 'marble slab; polished'
    "It's simply a slab of marble, to which a large iron anvil is attached. "
    
//    game551 = true    
;

+ Fixture 'golden letters;gold;;them'
    "The golden letters read, <q>Whoso Pulleth Out This Sword of This
        Stone and Anvil, is Rightwise King-Born of All This Mountain.</q> "
    readDesc = desc
;

+ Distant 'opposite shore; indistinct of[prep]; shape'
   "The indistinct shape of the opposite shore can be dimly seen to the south. "
;

+ Decoration 'thick white mist; misty of[prep]; spray clouds'
    "It's thick, white, and misty. "
;

+ Decoration 'waterfall; overhead rock; wall hole'
    "The waterfall spurts from an overhead hole in the rock wall and splashes into a
        large reservoir. "
;

+ StairwayUp 'narrow chimney' ->topOfSlide
    "Although it's narrow, you could climb up it. "    
;


/* 142 */
topOfSlide: NoNPC, DarkRoom 'At Top of Slide' 'top of slide; narrow (at); shelf'
    "{I} {am} on a narrow shelf above and east of the top of a very
    steep chimney.  A long smooth granite slide curves down out of sight
    to the east. If {i} {go} down the slide, {i} may not be able
    to climb back up. "
    
    game551 = true      

    east = inMistyCavern /* 98 */
    down  asExit(east)
    forward asExit(east)
    slide asExit(east)

    west = swordPoint
    chimney = swordPoint
;

+ StairwayDown 'steep chimney; very of[prep]; top' ->swordPoint
    "It's very steep, but you could climb down it. "
;

+ StairwayDown 'granite slide; long smooth' -> inMistyCavern
    "The long smooth granite slide curves down out of sight
    to the east. If {i} {go} down the slide, {i} may not be able
    to climb back up. "
;


/* 143 */
throneRoom: DarkRoom 'At Entrance to Throne Room' 'throne room entrance;private;chamber'
    "{I} {am} in the private chamber of the Mountain King.  Hewn into the
    solid rock of the east wall of the chamber is an intricately-wrought
    throne of elvish design.  There is an exit to the west."
    
    out: TravelConnector
    {
        destination = inHallOfMtKing
        
        /* Avoid listing this as a duplicate exit if west leads the same way. */
        isConnectorListed = global.game701
    }
    
    // In the 701-point game, this room is off the Morion room; otherwise
    // it is reached directly from the Hall of the Mountain King.
    west: VarDest, TravelConnector
    {
        calcDest
        {
            if(global.game701)
                return morion;
            return
                inHallOfMtKing;          
        }
    }
    
    east = throneRoomEast
    
    floorObj = trFloor
    
    NPCexit1 
    {
        if (! global.game701) return inHallOfMtKing;
        else return morion;
    }
;



+ distantThrone: Distant 'throne; elfish elfin intricate'
    "It's at the far end of the room.  I suggest that {i} {get}
        closer if {i} want{s/ed} to examine it! "
    
//    game551 = true
    vcoabLikelihood = 10
    
    /* The disant throne represents the same object as the actual throne */
    getFacets = [throne]
;

/* 
 *   Rather than using a floorDesc property on the room as in the TADS 2 version, we define a Floor
 *   object to act as the floor to both ends of the Throne Room.
 */
trFloor: Floor 'floor; smooth clean; ground'
    "The floor is exceptionally smooth and clean, but isn't at all slippery or shiny. "    
;

/* 144 */
throneRoomEast: DarkRoom 'At East Side of Throne Room' 'east side of the throne room'
    "{I} {am} on the east side of the throne room.  Very narrow
    passages go north and south, but are too small to enter.  "
    
    game551= true
    
    west = throneRoom
    out = inHallOfMtKing
    north = "That little elfin passage is much too small for humans to enter. "
    south = north
    passage = north
    
    phuce()
    {
        // If the crown etc. hasn't been taken, leave it alone
        if(!crown.moved)
            crown.isFixed = true;
        
        if(!throneSign.moved)
            throneSign.isFixed = true;
        
//        actor.roomMoveTravel(&transmove, Vast_Chamber); // TO DO
        gActor.travelVia(vastChamber); // temporary expedient
        
        if(!crown.moved)
            crown.isFixed = nil;
        if(!throneSign.moved)
            throneSign.isFixed = nil;
        
    }
    
    floorObj = trFloor    
;


+ throne: Fixture, Chair 'throne; elfin elvish intricate small'
    desc()
    {
        "It's rather small, but just large enough for you to sit
        on it.  It is covered in intricately-carved elvish designs. ";
//        if(spelunker_today.read) {
//            "You recognize it as the throne pictured in the magazines,
//            but it's much smaller than you expected it to be! ";
     }
    
//    game551 = true
    
    specialDesc = "A small throne sits near the east end of the hall. "
    
    /* The disant throne represents the same object as the actual throne */
    getFacets = [distantThrone]
    
    dobjFor(Board)
    {
        // If we sit on the throne, the result depends on whether we have
        // proof of royal blood.  If not, the game is restarted and the
        // player moved to the Hall of Mists and various objects to the
        // Rainbow Room.  The slippers are moved, and this provides another
        // route to the Gothic Cathedral.  If the crown is worn, the rod is
        // upgraded if carried.  A picture in the magazines gives a clue
        // to this.
        action()
        {
            inherited();
            // Temporary stuff for testing framework
            if(crown.wornBy == gActor)
            {
                "{My} crown glows, and {i} really
                {feel} as if {i} <i>{am}</i> the mountain king! ";      
                
                if (!blackRod.isupgraded) 
                {
                    if (blackRod.isDirectlyIn(gActor))
                        "Your black rod also glows and issues a strange
                        humming noise.
                        You notice that the star at the end is now shiny,
                        as if it's brand new! ";
                    else if(blackRod.isIn(gActor))
                        "You hear a strange humming hoise, but you're not
                        quite sure where it's coming from. ";
                    if (blackRod.isIn(gActor))
                        blackRod.upgrade(true);
                }
                
                // CODE FOR GREY ROD TO FOLLOW
            }
            else
            {
                local newscore, diffscore;
                
                "A strange cloud of green smoke then
                envelops you, and a strange tune seems to go through your head;
                you then recognize it as 'Somewhere, Over the Rainbow.'
                Coughing and spluttering, you open your eyes and find {i} {am} now ...\b\b";
                
                specialRestart.isActive = true;
                specialRestart.restartProp = &throneRestart;
                specialRestart.turncount = gTurns;
                // score adjustment
                newscore = global.startscore + global.farinpoints;
                if(global.novicemode)
                    newscore += global.novicepoints;
                if(global.nodwarves)
                    newscore -= 5;
                diffscore = newscore - libScore.totalScore;
                addToScore(diffscore, 'squatting on the throne');
                /* 
                 *   Presumably the point of the foregoing is to notify the plaeyer of the score
                 *   change; so we need to do that manually here as it won't be handled by the end
                 *   of turn score notification after the restart.
                 */
                scoreNotifier.checkNotification();
                specialRestart.notifyScore = scoreNotifySettingsItem.isOn;
                
                                
                specialRestart.vNumber = global.vNumber;
                specialRestart.novicemode = global.novicemode;
                specialRestart.randomized = global.randomized;
                specialRestart.nodwarves = global.nodwarves;
                specialRestart.verbose = gameMain.verbose;
                specialRestart.safeloc = safe.location;
                specialRestart.safecombseen = safeCombination.seen;                
                specialRestart.comboSet = safeDial.comboSet;
                specialRestart.safeopened = safe.hasOpened;
                specialRestart.safehidden = safe.hidden;
                specialRestart.safeisHidden = safe.isHidden;
                
                specialRestart.throneRoomSeen = throneRoom.seen;
                specialRestart.riverStyxESeen = riverStyxE.seen;
                specialRestart.pantrySeen = pantry.seen;
                
                specialRestart.knollSeenit = knoll.seenit;
                specialRestart.ROBseenit = riseOverBay.seenit;
                specialRestart.OCseenit = outerCourtyard.seenit;
                specialRestart.blue1loc = blue1.location;
                
                if(global.game701p)
                {
                    // TO FOLLOW
                }
                
                Restart.doRestartGame();
              }
                
        }
    }
    
;

/* 145 */
dragged_down: object
    msg = "{I} {am}  dragged down, down, into the depths of the
    whirlpool. Just as {i} {can} no longer hold {my} breath, {i} {am} shot out
    over a waterfall into the shallow end of a large reservoir. Gasping
    and sputtering, {i} crawl{s/ed} weakly towards the shore....<.p>"
;

vastChamber: NoNPC, DarkRoom 'In a Vast Chamber'
    "{I} {am} in a vast chamber - so vast, in fact, that the
     walls and ceiling are too remote for your lamp to show them. 
     All you can see is a slightly rough floor, stretching in all  directions. "
    
    game551 = true
    sober = true // no drinking here
    
     north 
    {
        "You wander in that direction for a while, but the floor seems to
        stretch endlessly in front of you.  You see no sign of the walls,
        the side passages, or the throne. ";
        if(!traveled)             
            "<.p>Maybe the \"Phuce\" spell would be useful somewhere else, but
            it's no use to you here.  I suspect that the elves can control
            its effect, but you don't know how -- and it's <i>far</i> too powerful 
            in here! ";       
    
        roomMove(vastChamber, throneRoomEast);
        traveled = true;
        return nil;
    }
    
    traveled = nil
    floorObj = slightlyRoughFloor
;
 
slightlyRoughFloor: Floor 'slightly rough floor;;ground'
    "Well, it's a floor and it's slightly rough. "
;

/* 146 */
inForest3: OutsideRoom 'In Forest' 'dense forest; (in)'
    "{I} {am} in dense forest, with a hill to one side.  The trees
        appear to thin out towards the north and east. "
    
    game551 = true    

    east = atHillInRoad
    up asExit(east)
    road asExit(east)
    climb asExit(east)
    
    
    south: VarDest, TravelConnector
    {
        calcDest
        {
            
            if (rand(100) <= 50)
                return inForest2;
            else                
                return inForest3;
        }
    }
    
    forest asExit(south)
    
    west = knoll
    north = saltMarshEdge
    building = atEndOfRoad
    // Exit info. for 'back' command:    
;

+ ProxyRoom ->atHillInRoad;

/* 147 */
knoll: OutsideRoom 'On Grassy Knoll' 'grassy knoll; wide; land'
    "{I} {am} at the high point of a wide grassy knoll, partially
    surrounded by dense forest.  The land rises to the south and east, and drops off
    sharply to the north and west.  The air smells of sea water. "
    
    game551 = true
    
    east = inForest3
    south = inForest3
    north = saltMarshEdge
    west = sandyBeach
    hole = thunderHole
    building = atEndOfRoad
    thunder = thunderHole

    roomDaemon() { elfcurse(); }
    
    elfcurse 
    {        
        if (rand(100) <= 25) 
        {
            "<.p>A tiny elf runs straight at you, shouts <q>Phuce!</q>,
            and disappears into the forest.  ";
            if (!seenit) 
                "Maybe it was a trick of the light, but you thought you saw
                the elf grow larger as he ran away from you. ";
            seenit = true;
        }
    }
    
    seenit = nil
    
    phuce()
    {
        phuce_messages.smaller; 
        
        // If the clover hasn't been picked, leave it alone
        if(!clover.moved)
            clover.isFixed = true;
        roomMove(getOutermostRoom, denseJungle);
        if(!clover.moved)
            clover.isFixed = nil;
        return denseJungle;        
    }
;

+ Decoration 'dense forest;;trees'
    "The forest partly surrounds the knoll. "
;

+ Odor 'sea water; of[prep]; smell'
    "The air smells of sea water. "
;

denseJungle: KeyCheck, OutsideRoom 'In a Dense Jungle'    
        "You're in a dense jungle, surrounded by large leaves which tower above
        your head.  Progress may be possible to the north, east or 
        southwest. "
    
    north = "You manage to walk a short distance to the north, only to encounter
        an unfriendly-looking giant spider.  You decide to beat a hasty retreat. "
    
    east = "You walk a few yards to the east, only to encounter a giant bird!
        Fearing for your life, you beat a rapid retreat. "
        
    southwest =  "You travel a fair distance to the southwest, only to encounter a
        giant grasshopper!   You retreat to your starting point and ask
        yourself whether this was the right place to use the \"Phuce\" spell.
        Most Elvish magic doesn't work for humans, but this particular
        spell seems to be \(too\) effective if you use it here. "
        
    sober = true
    
/* size of brass key as seen in this room */
    brassKey = largeKey
    
    phuce
    {
        phuce_messages.larger;
        roomMove(getOutermostRoom, knoll);
        return knoll;
    }
;
    
+ Decoration 'tall leaves; green large;; them'
    "They look like giant blades of grass. "    
//    game551 = true
;


/* 148 */
saltMarshEdge: OutsideRoom 'At Edge of Salt Marsh'
    'edge of the salt marsh; trackless (at); view'
    "{I} {am} at the edge of a trackless salt marsh.  Tall reeds obscure the view. "
    game551 = true
    
    south: VarDest, TravelConnector
    {
        calcDest
        {
            if (rand(100) <= 50 || nondeterministic == nil)
                return knoll;
            else
                return inForest3;
        }
    }
    
    
    east = saltMarsh1
    west = saltMarsh1
    north = saltMarsh1
    building = atEndOfRoad    
;

+ Decoration 'reeds;tall;;them';

saltmud: MultiLoc, Decoration 'mud; salty'
    "It's just salty mud.  No use for anything. "
    notImportantMsg = 'It\'s no good for anything. '
    
    locationList = [saltMarsh1, saltMarsh2, saltMarsh3, saltDeadEnd ]
;

/* 149 */
saltMarsh1: OutsideRoom 'In Salt marsh'
    "{I}{'m} in a salt marsh. "
    game551 = true
    
    south = saltMarsh1
    east = saltMarsh3
    west = saltMarsh2
    north = saltDeadEnd

;
/* 150 */
saltMarsh2: OutsideRoom 'In Salty marsh'
    "%You're% in a salty marsh. "
    game551 = true
    
    north = saltMarsh3
    south = saltMarsh3
    east = saltMarsh1
    west = saltMarsh1

;
/* 151 */
saltMarsh3: OutsideRoom 'In a Salt Marsh'
    "{I} {am} in a salt marsh. "
    game551 = true
    
    east = saltMarshEdge
    west = saltDeadEnd
    north = saltMarsh2
    south = saltMarsh1

;

/* 152 */
saltDeadEnd: OutsideRoom, DeadEndRoom 'At Dead End in Salt Marsh'
    "{i} {have} reached a dead end in the salt marsh. "
    game551 = true

    east = saltMarsh3
    south = saltMarsh2
;


/* 153 */
sandyBeach: OutsideRoom 'On Sandy Beach'
     "{I}{'m} on a sandy beach at the edge of the open sea. The beach
    ends a short distance south and the land rises to a point. To
    the north, the beach ends in cliffs and broken rocks. "
    game551 = true
    

    north = brokenRocks
    south = riseOverBay
    east = knoll
    building = atEndOfRoad
    listenDesc = "You hear the sound of the surf pounding against the
    beach and the broken rocks. "
;

+ ProxyRoom -> brokenRocks;
+ Decoration 'sea;open;water' "The sea stretches west as far as you can see. ";
+ Decoration 'cliffs;;;them';
+ Decoration 'sand' ordinary = 'perfectly ordinary';
+ Decoration 'point;;land' "The beach ends a short way south where the land rises to a point. ";

/* 154 */
brokenRocks: OutsideRoom 'At Broken Rocks' 'broken rocks;at[prep] large;;them'
    "{I} {am} at a jumble of large broken rocks, just above the entrance to a cave. 
    <<up.desc>> <<south.desc>> "
    
    game551 = true
    
    north: VarDest, TravelConnector
    {
        calcDest()
        {
            if (rand(100) <= 50)
                return oceanVista;
            else
                return thunderHole;
        }
    }
    
    down = thunderHole
    hole = thunderHole
    
    up: PathPassage 'gentle path' -> oceanVista
    "A gentle path leads up to the top of the nearby cliffs. "
        { location = static lexicalParent }
    
    south: PathPassage 'narrow treacherous path' ->sandyBeach
    "A narrow treacherous path disappears among the rocks at the foot of the cliff. "
        { location = static lexicalParent }
    
    building = atEndOfRoad
    
    listenDesc = "You hear the sound of the surf pounding against the
    beach and the broken rocks. "
;

+ Enterable ->thunderHole 'cave entrance; funnel shaped funnel-shaped (of) (to); hole mouth cavern'   
    "The mouth of the cave is shaped like a funnel. "
;

+ StairwayUp 'cliff; nearby' -> oceanVista
    "<<location.up.desc>> <<location.south.desc>> "
;

+ Decoration 'large broken rocks;;;them'
    
;
/* 155 */
oceanVista: OutsideRoom 'At Ocean Vista' 'ocean vista; (at) high; cliff'
    "{I} {am} on a high cliff overlooking the sea.  Far below the
    rolling breakers smash into a jumble of large broken rocks.
    The thunder of the surf is deafening. "

    game551 = true    
    down asExit(south)
    south = brokenRocks
    jump = cliffDemise1
    building = atEndOfRoad
;

+ Distant 'sea; rolling large broken of[prep]; breakers rocks jumble surf beach view; it them'
    "I've already told you what I know about the view. "
    listenDesc = "You hear the sound of the surf pounding against the
    beach and the broken rocks."
    decorationActions = [Examine, ListenTo]
//    game551 = true
;

/* 156 */
cliffDemise1: Room 'Bottom of Cliff'
    "{I}{'m} at the bottom of the cliff, smashed to smithereens
    by the pounding surf.<.p><<die()>>"   
;


/* 157 */

thunderHole: OutsideRoom 'At Thunder Hole' 'thunder hole; funnel shaped funnel-shaped; cavern cave'
    "{I} {am} at Thunder Hole, a funnel shaped cavern opening onto the
    sea. The noise of the surf pounding against the outer rocks of the cave is
    amplified by the peculiar shape of the cave, causing a thunder-like
    booming sound to reverberate throughout the cave.  Outside, a narrow
    path leads south towards some large rocks.  The cavern leads in to the east."
    
    game551 = true    

    isIndoors = true
    regions = [indoors]
    
    in asExit(east)
    east = riverStyxApproach
    passage asExit(east)
    
    
    out asExit(south)
    south = brokenRocks
    up asExit(south)
    
    building = atEndOfRoad
    listenDesc = "You hear a booming sound, caused by the surf pounding
    against the outer rocks of the cave. "

;

+ ProxyRoom 'large rocks;;;them' ->brokenRocks
;

seaWater: MultiLoc, RoomLiquid 'sea water;huge calm;breakers ocean '
    desc()
    {
        if(gRoom.ofKind(OutsideRoom))
            "Huge breakers pound against the beach.  Even if you could
            swim, you wouldn't choose to do so today! ";        
        else 
            "The calm ocean gently laps against the shore. ";        
    }
    
    cannotTakeMsg = 'The water here isn\'t good for anything much. I\'d look elsewhere
        if I were you. '
    
    cannotDrinkMsg = cannotTakeMsg
    
    dobjFor(Swim)
    {
        verify() {}
        check()
        {
            if(gRoom.ofKind(OutsideRoom)) 
                "Surf's up!  Even if you could swim, you wouldn't choose to do
                so today. ";        
            else 
                "The calm sea looks very inviting, but unfortunately you
                don't know how to swim. ";                             
        }
    }
    
    locationList = [sandyBeach, brokenRocks, thunderHole, beachShelf, beach]
;


/* 158 */
topOfSteps: KeyCheck, IndoorRoom 'At Top of steps (behind Thunder Hole)'
    "{I} {am} at the top of some arched steps.  On the east side there
    is a blank wall with a tiny door at the base and a shelf overhead.  On
    the other side a westward passage leads to the sea. "
           
    game551 = true
    
    west = riverStyxE
    passage = riverStyxE
    steps = riverStyxE
    down asExit(west)
    
    out = thunderHole
    
    phuce: TravelConnector  ->ledgeByDoor
    { 
        noteTraversal(actor)
        {
            phuce_messages.smaller;
            roomMove(topOfSteps, ledgeByDoor);
            roomMove(grottoWest, undergroundSea);
        }
    }

    climb = "The wall is too smooth to climb. "
    up = climb
    ledge =  "The shelf is beyond {my} reach. "
    in asExit(east)
    east = smallDoor
    entrance asExit(east)
    brassKey = smallKey
        
        
//    myhints = [Elfindoorhint]
    listenDesc = "You hear a booming sound, caused by the surf pounding
    against the outer rocks of the cave. "
    // This property suppresses warnings about leaving the lamp on.
    nolampwarn = true
;


+ archedSteps: StairwayDown, Surface 'steps; arched of[prep];flight;them'
    "It's just a normal flight of steps. "
    count = 0
    fullcount = 0    
    
    cakefind = nil
     
    
    dobjFor(LookIn)
    {
        action()
        {
            // Check to see if the player has tried to eat the mushroom when 
            // no cakes are available. 
            if(cakefind) 
            {
                count++;      // cakes found by actually searching the steps
                fullcount++;  // includes all hidden cakes found on the steps
                "There's nothing on the steps.  ";
                switch(count) {
                case 1:
                    "And yet, you have a hunch that you will find a cake if you
                    look carefully enough.  So you search each step with great
                    care - and find a cake, hidden in a crevice between a step and
                    the cave wall!  You take the cake. ";
                    break;
                case 2:
                    "And yet, you found a cake the last time, so you search the
                    steps again.  Once again, your patience is rewarded when you
                    notice another cake, hidden in the gap behind a slightly
                    loose step!  You take the cake. ";
                    break;
                default:
                    "And yet, you've spotted a total of <<fullcount>> cakes, 
                    all hidden on the steps, so maybe there are more!
                    You peer into every nook and cranny, and
                    your patience is rewarded again.  Yet another cake, 
                    hidden in a gap like the others!  You take the cake. ";
                }
                if (!cakes.knowdrop) 
                {
                    cakes.knowdrop = true;
                    "Maybe you dropped it when you took the tiny cakes off
                    the shelf. ";
                }
                cakes.moveInto(gActor);
                self.cakefind = nil;
                "<.p>";
                if(listableContents.length > 0)
                    inherited();             
                
            }
            else inherited();
        }
    }
;
   
+ Unthing 'sea'
    'The sea is out of sight down the passage. '
;

+ Decoration 'blank wall'
    "It has a tiny door in it. "
;
    
    
/* the shelf (when your size is normal */
+ highShelf: Distant 'high shelf'
    "I can't tell {me} much about it, because it's so high up. "
    
    iobjFor(ThrowAt)
    {
        check()
        {
            if((gDobj.isLarge || gDobj.isHuge) && !mushrooms.isEaten)
                "{The subj dobj} {is} too large. ";
        }
        
        action()
        {
            "{The subj dobj} land{s/ed} on the shelf, out of reach. ";
            gDobj.actionMoveInto(shelf);
        }
    }
;

class ElfinDoor: DSDoor    
    stateDesc()
    {
        "The door is ";
        if (isOpen) "open";
        else {
            "closed"; 
            if (isLocked) " and locked";
            else " but unlocked";
        }
        ". ";
    }
       
    nothingThruMsg = '{I} {see} nothing of note through <<theName>>. '
    thruDesc1 = "<<nothingThruMsg>>"
    thruDesc2 = "<<nothingThruMsg>>"
    
    dobjFor(LookThrough)
    {
        verify()
        {
            if(!isOpen)
                illogicalNow('{I} {can\'t} see anything through {the dobj}, since {he dobj}{\'s}
                    closed. ');                    
        }
        
        action()
        {
            if(inRoom1)
                thruDesc1;
            else
                thruDesc2;   
        }         
    }
    
    doorList = [smallDoor, ironDoor]
    
    /* 
     *   Presuambly the two ElfinDoors are meant to be the same physical door, so although the TADS
     *   2 code doesn't seem to anything about it, their locked and opened status shoulf be kept in
     *   sync.
     */
    
    makeOpen(stat)
    {
        inherited(stat);
        if(propType(&getFacets) == TypeList && getFacets.length > 0 && getFacets[1].isOpen != stat)
            getFacets[1].makeOpen(stat);
            
    }
    
    makeLocked(stat)
    {
        inherited(stat);
        if(propType(&getFacets) == TypeList && getFacets.length > 0 && getFacets[1].isLocked !=
           stat)
            getFacets[1].makeLocked(stat);
            
    }   
;

smallDoor: ElfinDoor 'tiny door' @topOfSteps @grottoWest
    "It's a tiny door, about six inches high.  A cat might be able
    to get through, but {i} {can't}. "
    
    keyList = [smallKey]
    
    canTravelerPass(actor) { return nil; }
    explainTravelBarrier(traveler, connector)
    {
        "{I} {can't} fit through a six-inch door! ";
    }
    
    thru1Desc1()
    {
        "{I} peer{s/ed} through the tiny doorway.  {I} {see} a
        large flooded cavern, lit by a strange bluish glow. ";
        if (boat.isIn(grottoWest))
            "There is a small boat on the western shore,
            near the door.  ";
    }    
    
    getFacets = [ironDoor]
;

ironDoor: ElfinDoor 'wrought-iron door; wrought iron large substantial' @ledgeByDoor @undergroundSea
    "It's a large and very substantial door, about eight feet high. "
    
    keyList = [largeKey]
    
    thruDesc1()
    {
        "{I} look{s/ed} through the open doorway.  {I} {can} see the
        shore of a vast underground sea, lit by a blue glow. ";
        if (boat.isIn(grottoWest))
            "A high wooden structure - possibly a ship - extends out
            of the water.  ";
    }   
    
    getFacets = [smallDoor]
    travelBarriers = [noBoatBarrier]    
;

/* 159 */
crampedChamber: KeyCheck, IndoorRoom 'Cramped Chamber' 'low cramped chamber; small; cave'
    
    "{I} {am} in a low cramped chamber at the back of a small cave.
    There is a shelf in the rock wall at about the height of 
    {my} shoulder."

    
    game551 = true
    sober = true // no getting out by drinking wine
    
    brassKey = tinyKey
    
    out = "{I} {am} now too big to leave the way {i} came in. "
    west asExit(out)
    
    
    phuce =  "The shelf appears to rise above your
        head for a few seconds, before returning to the level of your
        shoulder.  It looks as if you'll need to find another way to
        return to your normal size. "
        
    
    // This property suppresses warnings about leaving the lamp on.
    nolampwarn = true
;

+ shelf: Fixture, Surface 'shelf; rock'
//    game551 = true
    iobjFor(ThrowAt) asIobjFor(PutOn)

;

/* 160 */
ledgeByDoor: KeyCheck, IndoorRoom 'On Ledge by Wrought Iron Door' 'ledge by the door; wide'
    "{I} {am} on a wide ledge, bounded on one side by a rock wall,
    and on the other by a sheer cliff.  The only way past is through
    a large wrought-iron door. "
    
    game551 = true
    
    east = ironDoor
    in asExit(east)
    brassKey = largeKey
    
    phuce: TravelConnector -> topOfSteps
    {
        noteTraversal(actor)
        {
            phuce_messages.larger; 
            roomMove(ledgeByDoor, topOfSteps);
            roomMove(undergroundSea, grottoWest);
        }
    }
    
    west = 'The cliff is unscalable. '
    climb = west
    down = west
    jump = cliffDemise2
    nolampwarn = true
;

+ Decoration 'rock wall';
+ Decoration 'sheer cliff';

phuce_messages: object

/* 161 */
    smaller
    {
//        local actor := getActor(&travelActor);
        local toploc = gRoom;
         "{I} {feel} dizzy...Everything around {me} is spinning,
        expanding, growing larger.... Dear me!  ";
        if(toploc.isindoor || !toploc.isoutside)
            "Is the cave bigger";
        else
            "Has the vegetation grown suddenly or {am} {i} smaller?";
        "?\b";
    }

/* 162 */
    larger = "{I} {am} again overcome by a sickening vertigo, but
        this time everything around {me} is shrinking...Shrinking...\b";




eat_messages: object // issued when size-changing foods are eaten
/* 163 */
    smaller =  "{I} {am} closing up like an
        accordian....shrinking..shrinking. {I} {am} now {my}
            normal size.<.p>"
    

/* 164 */
    larger = "{I} {am} growing taller, expanding like a telescope!
        Just before {my} head strikes the top of the chamber, the mysterious
    process stops as suddenly as it began. <.p>"
;
    
/* 165 */
cliffDemise2: Room 'Bottom of Cliff'
    "{I}{'m} at the bottom of the cliff with a broken neck.<.p><<die()>> "
;    

/* 
 *   The TADS 2 code uses separate direction and boat_direction properties to enforce travel by
 *   both. In TADS 3 it makes more sense to enforce this with a TravelBarrier.
 */

boatBarrier: TravelBarrier
    /* Only allow travel if the traveler is or is the boat */
    canTravelerPass(traveler, connector)
    {
        return traveler.isOrIsIn(boat);
    }
    
    explainTravelBarrier(traveler, connector)
    {
        "{I} {can't} swim.  {I}'d best go by boat. ";
    }    
;

poleCheck: TravelBarrier
    canTravelerPass(traveler, connector)
    {
        return pole.isIn(boat);
    }
    
    explainTravelBarrier(traveler, connector)
    {
        "Casting yourself adrift without a paddle is a bad idea.
        The boat's oars were stolen by the dwarves to play
        bing-bong. (That's dwarvish ping-pong -- with rocks!). 
        {I}'d better bring something else to propel the boat.";
    }
;

/* 
 *   Presumably there'll be some directions the actor can't go in without first getting out of the
 *   boat.
 */
noBoatBarrier: TravelBarrier
    canTravelerPass(traveler, connector)
    {
        return !traveler.isOrIsIn(boat);
    }
    
    explainTravelBarrier(traveler, connector)
    {
        "{I} {can\'t} go thay way by boat. ";
    }  
;


/* the lake */

grottoLake: MultiLoc, Decoration 'lake;large clear deep;water'  
       "It's a large lake, almost covering the floor of the
        chamber.  The reflection of the light from the lake fills the
        room with a bluish glow.  The water is very clear and very deep --
        you won't be able to cross it except by boat."
    
    locationList = [grottoWest, blueGrottoEast, gravelBeach, bubbleChamber, darkCove]
    
    decorationActions = [Examine, Swim]
    dobjFor(Swim)
    {
        verify() { illogical('{I} {can\'t} swim. '); }
    }
;

MultiLoc, Decoration 'blue glow; hazy bluish'
     "It's just a glow. "
     locationList = [grottoWest, blueGrottoEast, gravelBeach, bubbleChamber, darkCove]
;

/* 166 */
grottoWest: NoNPC, Room 'At West Wall of Blue Grotto'
    "{I} {am} at the western tip of the Blue Grotto.  A large lake
    almost covers the cavern floor, except for where {i} {am} standing.
    Small holes high in the rock wall to the east admit a dim light.  The
    reflection of the light from the water suffuses the cavern with
    a hazy bluish glow. "
        
    game551 = true
    // no getting out by drinking wine
    
    in asExit(west)
    out asExit(west)
    west =  "{I} {can't} fit through a six-inch door! " 

    
/* Directions for use when in the boat */
    east: TravelConnector ->blueGrottoEast
    {
        travelBarriers = [boatBarrier, poleCheck]
        noteTraversal(actor)
        {
            if(pole.isIn(boat))
                poling_messages.calm;
        }
    }
    
    cross asExit(east)
    across asExit(east)
    northeast: TravelConnector -> bubbleChamber
    {
        travelBarriers = [boatBarrier, poleCheck]
    }
    
    south: TravelConnector -> gravelBeach
    {
        travelBarriers = [boatBarrier, poleCheck]
        noteTraversal(actor)
        {
            if(pole.isIn(boat))
                poling_messages.dark;
        }
    }
    
    north: TravelConnector -> darkCove
    {
        travelBarriers = [boatBarrier, poleCheck]
        noteTraversal(actor)
        {
            if(pole.isIn(boat))
                poling_messages.blue;
        }
    }
    
    phuce  
    {    
        phuce_messages.smaller; 
        gActor.roomMoveTravel(&transmove,undergroundSea);
        // also move the objects on the other side of the door
        roomMove(topOfSteps, ledgeByDoor);        
    }    
;

+ Distant 'small holes; rock dim; light east e wall; them it'
    "Small holes high in the rock wall to the east admit a dim light. "
;

/* dummy object */
oars: Thing 'oars;;oar;them it'
;


/* 167 */

/* The original spoke of a 'wooden structure', but it seems more likely that
the adventurer would recognize it as a large ship. */

undergroundSea: NoNPC, Room 'At Underground Sea'
    "{I} {am} on the shore of an underground sea.  The way west is
     through a wrought-iron door."
    
    game551 = true
    sober = true // no getting out by drinking wine
    
    phuce
    {       
        phuce_messages.larger; 
        gActor.roomMoveTravel(&transmove,grottoWest);
        
        // also move the objects on the other side of the door
        roomMove(ledgeByDoor, topOfSteps);        
    }
       
    west = ironDoor
    out asExit(west)
    in asExit(west)
    
    east: TravelBarrier    
    {
        canTravelerPass(traveler) { return nil; }
        explainTravelBarrier(traveler, connector)
        {
            if (boat.isIn(grottoWest))
                "{I} {can\'t} swim, and there's no way into
                the ship, so {i} couldn't possibly cross this sea.";
            else
                "{I} couldn't possibly cross this sea without a large ship.";
        }
        
        /* There's not much point listing a direction the player can't travel in. */
        isConnectorListed = nil
        
    }
    
    cross asExit(east)
    over asExit(east)
    across asExit(east)
    
    brassKey = largeKey    
;

+ ship: Fixture 'vast wooden ship'
    "Despite its vast scale, it is constructed like an
    old-fashioned wooden rowing boat. "
    
    specialDesc = "A high wooden ship of vast
        proportions extends out of the water to the east.  There
        doesn't appear to be any way into the ship. "
    
    /* The 'ship' isn't here if the boat isn't in the corresponding location */
    isHidden = !boat.isIn(grottoWest)
    cannotEnterMsg = '{I} {can\'t} see any way to enter the ship. '
    cannotBoardMsg = cannotEnterMsg
    cannotClimbMsg = 'Even with rock-climbing equipment,
        {i}\'d have great difficulty climbing the sheer hull of the ship. '
    cannotTakeMsg = 'You must be joking! '
;


/* 168 */
blueGrottoEast: Room 'At East Side of Blue Grotto'
    'east side of the blue grotto; eastern; shore'
    "{I} {am} on the eastern shore of the Blue Grotto.  To the west
    a large lake almost fills the cavern floor, and an ascending
    tunnel disappears into the darkness to the SE."
    
    game551 = true
    
    southeast: Passage, StairwayUp 'ascending tunnel' ->windyTunnel
    "The tunnel leads up to the southeast. "
    {
        travelBarriers = [noBoatBarrier]
        location = static lexicalParent    
    }
    
    up asExit(southeast)
    passage asExit(southeast)
    
    north: TravelConnector -> bubbleChamber
    {
        travelBarriers = [boatBarrier, poleCheck]        
    }
    
    south: TravelConnector -> gravelBeach
    {
        travelBarriers = [boatBarrier, poleCheck]        
    }
    
    west: TravelConnector -> grottoWest
    {
        travelBarriers = [boatBarrier, poleCheck]        
    }
    
    cross asExit(west)
    over asExit(west)
    across asExit(west)   
;

+ Enterable 'darkness'
    "Who'd have guessed? It's dark! "
    connector = location.southeast
;

/* 169 */
bubbleChamber: NoNPC, Room 'In Bubble Chamber' 'bubble chamber; watery (in) high; rock'
    desc
    {
        "{I} {am} at a high rock on the NE side of a watery chamber at the
        mouth of a small brook. <<unknownGas.desc>> ";
        if (!grottoWest.seen)        
            "To the southwest lies the Blue Grotto, a large chamber lit
            by a bluish light.  A lake almost completely covers the
            floor. ";           
        else 
            bcBluishLight.desc;     
    }
    
    
    game551 = true
    wino_trollstop = true // troll stops a wino from getting to cloak_pits
    
    south: TravelConnector -> blueGrottoEast
    {
        travelBarriers = [boatBarrier, poleCheck]        
    }
    
    northwest: TravelConnector -> darkCove
    {
        travelBarriers = [boatBarrier, poleCheck]        
    }
    
    southwest: TravelConnector -> grottoWest
    {
        travelBarriers = [boatBarrier, poleCheck]        
    }
    
    east:TravelConnector -> muddyDefile
    {
        travelBarriers = [noBoatBarrier]
    }
    
    passage asExit(east)
    up asExit(east)
    stream asExit(east)
    upstream asExit(east)   
;

+ ProxyRoom -> grottoWest isHidden = !grottoWest.seen;
+ Decoration 'small brook; of[prep]; mouth';
+ unknownGas: Decoration 'unknown gas'
    " An unknown gas bubbles up through the water from the chamber floor. "
;
+ bcBluishLight: Decoration 'bluish light; blue'
    "A bluish light can be seen to the southwest. "
;
+ Distant 'lake';

/* 170 */
windyTunnel: DarkRoom 'In Windy Tunnel' 'windy e/w tunnel; (in) east-west e-w'
    "{I} {am} in a windy E/W tunnel between two large rooms. "
    
    game551 = true
    
    east = batCave
    up asExit(east)
    west = blueGrottoEast
    down asExit(east)
;
+ Decoration 'large rooms; two 2; room; them'
    "The tunnel runs between two large rooms, one to the east and the other to the west. "
    notImportantMsg = 'It would be simpler to visit them. '
;


/* 171 */
batCave: DarkRoom 'In Bat Cave'
    desc
    {
        "{I} {am} in the Bat Cave.  The walls and ceiling are covered with
        sleeping bats.  ";
        if (guano.swept) 
            "A mass of dry, foul-smelling guano has been swept
            to one side of the room. ";
        else 
            "The floor is buried by a mass of dry, foul-smelling guano. ";
        "The stench is overpowering. Exits to the NW and east.";
    }
    
    northwest = windyTunnel
    down asExit(northwest)
    
    east = tongueOfRock
    up asExit(east)
    
    floorObj = batFloor
    
;

+ guano: Fixture 'some guano'
    desc
    {
        if(swept)
            "It's piled up against one side of the room";
        else
            "It covers the floor and smells absolutely terrible.  I
            suggest that we make a move out of here as soon as possible. ";
    }
    
    swept = nil
    swept2 = nil
    
    smellDesc = "The stench is overpowering. Let's get out of here. "
    cannotTakeMsg = 'I\'d rather not, thank you. '
    dobjFor(PutIn)
    {
        verify() { illogical('I\'d prefer to leave the stinking guano where it is. '); }
    }
    
    lookUnderMsg = 'There\'s nothing under the guano except the floor of the
        cave.  Please get me out of here - I can\'t stand the smell. '
    
    dobjFor(LookIn)
    {
        verify() 
        {
            illogical('There\'s nothing hidden in the guano!  Can we go now,
                please - the smell is making me feel unwell.');
        }
    }
    
    sweepmess() 
    {        
        if(swept) 
        {
            if (swept2) 
                "If you think there's anything useful to do in this
                room, you're barking up the wrong tree.  So I'll move
                you on! ";            
            else 
            {
                "Ignoring my advice, you attempt to sweep the guano once
                again.  However, you are overwhelmed by a feeling of
                nausea, and wisely decide to move on. ";
                swept2 = true;
            }
            "<.p>";
            if(gActor.prevloc == windyTunnel)
                gActor.travelVia(tongueOfRock);
            else
                gActor.travelVia(windyTunnel);        
            
        }
        else
            "In the hope of finding a hidden treasure, you sweep the
            guano to one side of the room, revealing nothing.  Vowing not
            to be beaten, you then sweep it all to the other side - again
            revealing nothing.  We now know for certain that nothing was
            hidden here, and the smell is now absolutely nauseating.  So
            please, PLEASE can we move on. ";
            swept = true;
    }
    
    dobjFor(CleanWith)
    {
        verify() {}
        action() 
        { 
            if(gIobj == whiskbroom)
                sweepmess(); 
            else
                inherited();
        }
    }
    
    dobjFor(SweepWith) asDobjFor(CleanWith)
    
;

+ Fixture 'bats; sleeping;;them'
    "The bats are sleeping, and cover the walls and ceiling.  I
        suggest that we leave them alone and move on.  It stinks in
        here! "
    isCleanable = nil
    cannotCleanMsg = 'The bats don\'t need cleaning.  I suggest that
        you leave them alone.'
    dobjFor(Sweep) asDobjFor(Clean)
    dobjFor(SweepWith) asDobjFor(CleanWith)
    dobjFor(Wake)
    {
        verify()
        {
            illogical('Leave the bats alone, please! ');
        }
    }
    
;

+ Odor 'stench; indescribable overpowering nauseating of[prep]; smell stink (guano)'
    "The stench of guano here is overpoweringly nauseating. "
    smellDesc = desc
;

batFloor: Floor 'floor;;ground'
    "The floor is covered in dried guano.  The smell is
    indescribable!  Let's get out of here."
;

/* 172, 173 */
tightCrack: DarkRoom 'In Tight N/S Crack'
    desc
    {
        "{I} {am} in a very tight N/S crack. ";
        if (cloakroom.caved)
            "The passage south is blocked by a recent cave-in. ";
        else
            "The passage seems to widen to the south. ";
    }
    game551 = true
    
    north = atEastEndOfLongHall
    
    
    passage asExit(south)
    
    south: TravelConnector ->cloakroom
    {
        canTravelerPass(actor) { return !cloakroom.caved; }
        explainTravelBarrier(actor, connector)
        {
            "The passage south is blocked by a recent cave-in. ";
        }
    }
       
    
    NPCexit1 = cloakroom.caved ? nil : cloakroom
    
    ana2 
    {
        "You see a brief flash of blue light, then feel a sickening 
        \"crunch\" as your entire body collides with a solid wall of 
        concrete.  Fortunately the spell reverses itself, and you find 
        yourself back in the crack. ";
        return nil;
    }

;



crackrocks: MultiLoc, Fixture, Surface 'rocks; large loose;;them'
    "The rocks are too large to move or carry, and they are
    now blocking the southern end of the passage.  "
    
//    game551 = true


    locationList = [greenTightCrack]

    cannotMoveMsg ='The rocks are far too large to move. '
    cannotTakeMsg = 'The rocks are too large to carry. '   
    
    lookInMsg = 'You find nothing of interest. '
;

greenTightCrack:Room
;

/* 174 */
cloakroom: DarkRoom 'In Cloakroom'
    "{I}{'m} in the Cloakroom.  This is where the dreaded Wumpus
      repairs to sleep off heavy meals.  (Adventurers are his favorite
      dinner!)  Two very narrow passages exit NW and NE. <<if caved>> 
      Unfortunately, the NE passage is now blocked by a rockslide.<<end>>  "
    
    game551 = true
    caved = nil
    
    passage: TravelConnector -> cloakPits
    {
        canTravelerPass(actor) { return caved; }
        explainTravelBarrier(actor, connector)
        {
            "There's more than one passage - please tell me which
            direction you want to go. ";
        }
    }
    
    northeast: TravelConnector -> tightCrack
    {
        canTravelerPass(actor) { return !caved; }
        explainTravelBarrier(actor, connector)
        {
            ne_blocked.msg;
        }
    }
      
    
    crack asExit(northeast)
    
    northwest = cloakPits
    cave 
    { // used when cloak is taken        
        "{I} {have} jerked the cloak free of the rocks.  However, in doing
        so {i} {have} caused a small rockslide, blocking the entrance
        and making an unholy din.";
        caved = true;        
        crackrocks.moveIntoAdd(tightCrack);
        tightCrack.seen = nil; // full description when next seen
        if (wumpus.isAsleep && wumpus.isIn(self))              
        { 
            "<.p>";
            wumpus.actionDobjWake();
        }
    }

    NPCexit1 {if(caved)return nil; else return tightCrack;}
    
//    myhints = [Cloakhint]
    ana2 = "You see a brief flash of blue light, then feel a sickening 
        <i>crunch</i>.  For a short moment you are surrounded by junk of all
        kinds - old display boards, broken filing cabinets and worn-out
        office machinery.   The pendant then transports you back to Red level. ";
        
;

cloakrocks: Fixture, Surface 'rocks; large loose' @cloakroom
    desc 
    {
        "The rocks are too large to move or carry.  ";
        if(cloakroom.caved) 
        {
            "Unfortunately, they are now blocking the passage to the
            northeast.  ";
        }
    }
    
//    game551 = true
    
    cannotMoveMsg = 'The rocks are far too large to move. '
    cannotTakeMsg = 'The rocks are too large to carry. '
    lookInMsg =  'You find nothing of interest. '   
;


/* 175 */
cloakPits: DarkRoom 'In Room with Small Pits'
    'room with small pits; damp'
    "{I}{'m} in a damp room containing several small climbable pits.
    Passages exit to the east and north.  On the south wall you see the
    remains of an iron ladder which once led upwards, but it is now badly
    corroded and unclimbable. "
    
    game551 = true
    
    passage = "There's more than one passage - please tell me which
        direction you want to go. "
    
    pitlist = [cloakPit1, cloakPit2, cloakPit3]
    south = cloakPit1
    northeast = cloakPit2
    northwest = cloakPit3
    
    north = atHighHole
    east = cloakroom
    
    pit: VarDest, TravelConnector
    {
        calcDsst() { return rand(lexicalParent.pitlist); }
    }
    
    up =  "<<ladder1.cannotClimbMsg>>"
    climb asExit(up)
    
    ana2 =  "You see a brief flash of blue light, then feel a sickening 
        <i>crunch</i> as your body collides with solid concrete.  For a
        brief moment you see that the floor at Blue level has been raised,
        and is almost at the level of your shoulders.  Then the pendant
        returns you to Red level. ";
        
;

+ ladder1: Fixture 'remains of the ladder[n];iron rusted corroded rusty metal fragile;;them it'
    "Years of corrosion in this damp room have reduced the ladder
    to a few broken pieces of heavily rusted metal.  They certainly
    won't bear your weight. "
    
    
    cannotClimbMsg = 'You attempt to climb up, but the remains of the ladder are too
        fragile to bear your weight.  You give up the attempt.'
;

+ featurelessPits: CollectiveGroup 'featureless pits; small climbable;; them'
    "There are three pits, to the south, northeast and northwest.
    To find out more, I suggest that you enter them. "
    
    collectiveActions = [Examine, ClimbDown, Climb, Enter]
    
    dobjFor(Enter) 
    {
        verify() {}
        check = "You'll have to tell me which pit you want to enter.  For example,
        to enter the south pit say ENTER SOUTH PIT or just SOUTH. "
    }
    
    dobjFor(Climb) asDobjFor(Enter)
    dobjFor(ClimbDown) asDobjFor(Enter)
    
//    game551 = true
;

+ pit1: Featurelesspit 'south pit; s southern'
    destination = cloakPit1
;

+ pit2: Featurelesspit 'northeast pit; ne northeastern'
    destination = cloakPit2
;

+ pit3: Featurelesspit 'northwast pit; nw northwestern'
    destination = cloakPit3
;


class Featurelesspit: StairwayDown
    desc = "To find out more, I suggest that you enter <<theName>>. "
//    game551 = true
    dobjFor(Enter) asDobjFor(ClimbDown)
    dobjFor(Board) asDobjFor(ClimbDown)
    dobjFor(Climb) asDobjFor(ClimbDown)
    collectiveGroups = [featurelessPits]
    
;

/* 176 */

// From version 2.00 there are three pits.  Two of them contain
// a ring, but the third is empty because the Wumpus has stolen the gold
// ring.  A clue to the significance of the rings is in the Octagonal Room.

class CloakPitRoom: NoNPC, DarkRoom
    game551 = true
    
    up:TravelConnector -> cloakPits
    {
        noteTraversal(actor) { actor.nextRoute = 1; }
    }
    climp = up
    out asExit(up)
    
    dobjFor(Climb)
    {
        verify() {}
        action() { goInstead(up); }
    }
    ana2 = "You see a brief flash of blue light, then feel a sickening 
        <i>crunch</i> as your entire body collides with solid concrete.  The
        pendant then returns you to Red level. "
    
;

cloakPit1: CloakPitRoom 'In Featureless Pit' 'featureless pit; small of[prep] in[prep] at[prep];
    bottom'
    "{I} {am} at the bottom of a small pit, which is featureless
    except for large footprints which suggest that
    someone -- or something -- has been here before you. "
;

+ Fixture 'large footprints;foot;prints; them'
    "They look too large to have been made by a human being. "
    
    cannotTakeMsg = 'I\'d like to see you try! '
;

cloakPit2: CloakPitRoom 'In Very Featureless Pit'
    'very featureless pit; small totally of[prep] at[prep] in[prep]; bottom'
    "{I} {am} at the bottom of a small, totally featureless pit. "
;

cloakPit3: CloakPitRoom 'In Fairly Small Pit' 
    'fairly small pit; featureless  of[prep] at[prep] in[prep]; bottom'
    "{I} {am} at the bottom of a fairly small, featureless pit. "
;


/* 177 */
atHighHole: DarkRoom 'At High Hole'
    "{I} {am} at a high hole in a rock wall."
    game551 = true
    
    down = atEastEndOfLongHall
    climb asExit(down)
    jump asExit(down)
    south = cloakPits
    ana2  = "You see a brief flash of blue light, and for a short moment you
        seem to be inside a water tank!  More familiar surroundings reappear
        moments later, and you are relieved to find that you and your
        possessions are still dry.  Evidently the pendant is able to protect
        the wearer in situations like this. "      
;
+ Decoration 'rock wall';

/* 178 */
ne_blocked: object
    msg = "The NE passage is blocked by a recent cave-in.\b";
;

/* 179 */
muddyDefile: NoNPC, DarkRoom 'In Muddy Defile' 'sloping muddy defile'
    "{I} {am} in a sloping muddy defile, next to a tumbling brook."
    
    wino_trollstop = true // troll stops a wino from getting to cloak_pits
    game551 = true

    down asExit(west)
    downstream asExit(west) // Added - DJP
    west = bubbleChamber
    
    up asExit(east)
    upstream asExit(east)// Added - DJP
    east = fairyGrotto
    stream asExit(east)

;

+ Decoration 'tumbling brook'
    "The brook runs from east (upstream) to west (downstream). "
;

/* 180 */
tongueOfRock: DarkRoom 'At Tongue of Rock' 'tongue of rock; (in) level e/w; passage'
    "{I} {am} in a level E/W passage partially blocked by an overhanging
    tongue of rock. <<up.desc>>"
    
    game551 = true
   
    passage = "The passage goes in two directions.  Please tell me which way
        you want to go. "
        
    west = batCave
    up: StairwayUp 'steep scramble; upward; crawl'-> upperPassage
    "A steep scramble would take you up over the tongue,
    whence continues an upward crawl. "
        { location = static lexicalParent }
    
    climb asExit(up)
    east = passageEndAtHole
;

/* 181 */
dog_message: object
    msg = "The dog won't let you pass."
;

/* 182 */
upperPassage: DarkRoom 'In Upper Passage' 'upper passage; long level e/w (in); tunnel'
    "{I}{'m} in the Upper Passage, a long level E/W tunnel. "
    
    game551 = true
    
    passage = "The passage goes in two directions.  Please tell me which way
        you want to go "
        
    west = tongueOfRock
    east = starChamber
;

;
/* 183 */
starChamber: DarkRoom 'In Star Chamber ' 'star-shaped chamber; star'
    "{I} {am} in a star-shaped chamber.  Passages exit north, east,
    south and west. "
    
    game551 = true
    
    passage = "There's more than one passage -- please tell me which
        direction you want to go. "
        

    west = upperPassage
    east: VarDest, TravelConnector
    {
        calcDest
        {
            if (rand(100) <= 50 || !global.nondeterministic)
                return elbowInPassage;
            else
                return tunnelIntersection;
        }
    }
        
    south = deadEnd15
    north = narrowEWPassage

    NPCexit1 = elbowInPassage
    NPCexit2 = tunnelIntersection
;

;
/* 184 */
elbowInPassage: DarkRoom 'At Elbow in Passage'
    "{I} {am} at an elbow in a winding E/W passage.  {I} {can} go SW or SE. "
    
    game551 = true   

    passage = "The passage goes in two directions.  Please tell me which way
        you want to go. "
    
    southwest = starChamber
    southeast = rotunda
;

/* 185 */
deadEnd15: DeadEndRoom
    game551 = true

    north = starChamber
    out asExit(north)
;

/* 186 */
tunnelIntersection: DarkRoom 'At Tunnel Intersection'
    "{I}{'m}at the intersection of two long tunnels.  One goes NW,
    the other NE. "
    
    game551 = true
    
    passage = "The tunnel goes in two directions.  Please tell me which way
        you want to go "
        
    northwest = starChamber
    northeast = rotunda
;

/* 187 */
narrowEWPassage: DarkRoom 'In Narrow East-West Passage'
    'narrow east-west; e-w e/w east/west long; passage'
    "{I}{'m} in a long narrow east-west passage which curves out of sight
    at both ends. "
    
    passage = "The passage runs east and west -- please tell me in which
        direction you want to go. "
    
    west = starChamber
    east = rotunda
;

/* 188 */
rotunda: DarkRoom 'In Rotunda'
    "{I}{'m} in the Rotunda.  Corridors radiate in all directions.\b       
        There is a telephone booth standing against the north wall."
    
    
    game551 = true
    
    hasfloor = true // this seems to be a room in the normal sense rather
                    // than a natural chamber.
    passage =  "There's more than one passage - please tell me which
        direction you want to go. "
        
    north = narrowEWPassage
    west = elbowInPassage
    
    southwest: VarDest, TravelConnector
    {
        calcDest()
        {
            if (rand(100)<= 65) return devilsChair;
            else return tunnelIntersection;
        }
    }
    
    down asExit(southwest)
  
    in = phoneBooth1Door   
    
    travelerLeaving(actor, dest)
    {
        if (dest != inPhoneBooth1) 
        {
            // leave things as we expect to find them when we re-enter
            // the room.
            // Remove the gnome
            gnome.moveInto(nil);
            // The booth door will be closed
            phoneBooth1.mydoor.isOpen = nil;
            // If the phone is unbroken, it will be ringing and
            // the gnome may barge in.
            if (!phoneBooth1.myphone.isbroken) 
            {
                gnome.isntcoming = nil;
                phoneBooth1.myphone.isringing = true;
            }
            // If the phone is broken, the gnome won't be coming.
            else gnome.isntcoming = true;
        }
        noleaveroom = nil;
        inherited(actor, dest);
        
    }
    
    noleaveroom = nil

    NPCexit1 = devilsChair
    NPCexit2 = tunnelIntersection

//    extraScopeItems = (gnome.isIn(inPhoneBooth1) ? [gnome] : [])
;


/* 189 */
// I'll come back to do the phone booth and phone later
// Is it best to make the phone booth a Booth or a Room with a separate Enterable?

+ phoneBooth1: Enterable 'phone booth; telephone' -> phoneBooth1Door
    desc()
    {
        if(gnome.isIn(inPhoneBooth1))
            "At present, it is occupied by a gnome who is talking excitedly
            to someone at the other end of the line. ";
        else
            "It contains a banged-up pay telephone of ancient design. ";
    }
//    game551 = true
    
    specialDesc
    {        
        if(gnome.isIn(inPhoneBooth1))
            "The phone booth is occupied by a gnome.  He is talking
            excitedly to someone at the other end.";
        else if (myphone.isringing)
            "The telephone booth is unoccupied.  The phone is ringing.";
        else "The telephone booth is unoccupied.";
    }
    
    
    gnomecount = 0
    gnomecheck
    {
       if(gnome.isIn(inPhoneBooth1)) 
        {
            "You can't, because the gnome is inside the booth and firmly
            blocks the door.";
            return;
       }
       if(!gnome.isntcoming && !global.closed && !myphone.isbroken &&
         (gnomecount == 0 || rand(100) <= 55)) 
        {
            gnomecount++ ;
            "As you move towards the phone booth, a gnome suddenly streaks
            around the corner, jumps into the booth and rudely slams the
            door in your face.  You can't get in.";
            gnome.moveInto([inPhoneBooth1, rotunda]);
            myphone.isringing = nil;
            mydoor.makeOpen(nil);
       }
       else gnome.isntcoming = true;
    }
    
    mydoor = phoneBooth1Door
    myphone = phone1
    
    dobjFor(Open) { remap = mydoor }
    dobjFor(Close) { remap = mydoor }
;

++ Component, ProxyPhone 'phone; ancient banged-up; telephone'
    "You can't examine the phone more closely until you enter the booth. "
    checkReach(actor)
    {
        "You'll need to get inside the phone booth to do that. ";
    }
    myphone = phone1   
    
//    game551 = true
;

ProxyPhone: Distant
    myphone = nil
    isringing = (myphone ? myphone.isringing : nil)
    listenDesc
    {
        if(isringing)
            "The phone is ringing. ";
        else
            inherited;
    }
    
    isProminentNoise = isringing
    notImportantMsg = '{I}\'d have to get into the booth for that. '
    decorationActions = [ListenTo, Examine]
;


inPhoneBooth1: Room 'In Phone Booth'
    "{I} {am} standing in a telephone booth at the side of a
     large chamber.  Hung on the wall is a banged-up pay telephone of
     ancient design. <<if myphone.isringing>>The phone is ringing.<<end>> "
    isLit = rotunda.isLit
    myphone = phone1
    
    out = rotunda    
;

+ ProxyRoom 'large chamber' -> rotunda;

+ phone1: Phone 'old banged-up payphone;ancient pay;phone receiver telephone handset payphone'
    isringing = true
    
    answermethod()
    {
        "No one replies.  Instead, {i} hear{s/ed} music, which {i} {think}
        {i} recognize{s/d} as <q>The Walls of Jericho</q>.  Maybe it's a crossed
        line.   After a few seconds, the line goes dead with a definite
        <i>Click</i>.  You replace the receiver.  ";
        isbroken = true;
        dropmethod();
    }
   
    dobjFor(Attack)
    {
        action()
        {
            "A few lead slugs drop from the coinbox.  (Gnomes are
            notoriously cheap....)  But {i} {have} broken the phone
            beyond all hope.  ";
            vandalize();
            slugs.moveInto(location);            
        }
    }    
;

class Phone: Fixture 
// a telephone.  The following properties are set:
    // enddesc: description of what phone is doing for use in
    // ldesc
    // isringing:  Whether it is ringing.
    // isoffhook:  Whether the receiver has been lifted.
    // isanswering: (When isoffhook is set) we are answering the phone
    // isbroken (when phone is out of order)
    // isdented (when phone has been hit)

    // It is recommended that the following properties be customized
    // as required:
    // mybooth - if non-nil, this is set to the room which the player
    //           must be in to interact with the phone.  By default, it
    //           is set to the location of the phone.
    // ldesc - long description, which may include self.enddesc
    // location - where it is
    // needtopay - true if coins must be inserted before dialing
    // doTake (actor) - all actions when receiver is lifted
    // takemethod (actor) - basic variable settings for when the
    // receiver is lifted
    // dropmethod (actor) - actions when the receiver is replaced.
    // answermethod(actor) - what to do when the phone is answered
    // dialtonemethod(actor) - message to be issued when a dial tone is
    //                         received.
    // brokenmethod - message when the phone is broken
    // dialmethod(actor, value) - what to do when the phone is dialled
    // with value 'value' (value = -1 if no number was specified)    
    
    desc = "It's an old battered payphone. <<enddesc>>"
    enddesc()
    {
        if(isoffhook) 
            "<.p>You have lifted the receiver.  ";        
        if(self.isringing) 
            "<.p>The phone is ringing. ";        
        else if(self.isbroken) 
        {
            "<.p>The phone is out of order";
            if(isdented)
                " and is badly dented";
            ". ";
        }
    }    
    
    isringing = nil
    isbroken = nil
    isoffhook = nil
    isanswering = nil
    isdented = nil
    mybooth = location
    needtopay = true
    ispaid = nil
    
    dobjFor(Take)
    {
        verify()
        {
            if(isanswering && !isringing)
                illogicalNow('{The subj dobj} {is}n\'t ringing. ');
            
            if(isoffhook)
                illogicalAlready('{The subj dobj} {is} already off the hook. ');
        }
        
        check() {}
        
        action()
        {
            takemethod();
            if (isanswering) answermethod();
            else if (isbroken) brokenmethod();
            else dialtonemethod();
            
            isanswering = nil;
        }            
    }
    
    dobjFor(Drop)
    {
        verfy()
        {
            if(!isoffhook)
                illogicalAlready('The receiver has already been replaced. ');
        }
        
        action()
        {
            dropmethod();
            "Done. ";
        }
    }
    
    dobjFor(DialOn)
    {              
        verify()
        {
            if(isringing)
                illogicalNow('{The subj dobj} {is} ringing. {I}\'d better answer it first. ');
        }
        
        check()
        {
            dialNum = tryInt(gLiteral);
            if(dialNum == nil)
                "{I} {can\'t} dial that! ";
            else if(dialNum < 0)
                "{I} {can\'t} dial a negative number. ";            
        }
        
        action()
        {
            if(!isoffhook)
            {
                "\n(first lifting the receiver)\n";
                takemethod();"\n";
            }
            else if(isanswering)
            {
                "\n(first replacing and lifting the receiver)\n";
                dropmethod();
                actionDobjTake();"\n";
            }
            
            if(isbroken) 
                brokenmethod();
            else 
                dialmethod(dialNum);
        }    
    }
    
    dialNum = nil
    
    // Sabotage the phone.  By default, it goes out of order and refuses to
    // return your coins.
    dobjFor(Attack)
    {
        verify()             
        {
            if(isdented)
                illogicalAlready('The phone is out of order and your hand is sore. ');
        }
        
        check() {}
        action()
        {
            "The telephone is now badly dented, and {i} {have} broken
            it beyond all hope.  ";
            vandalize();
        }
    }
    
    dobjFor(Break) asDobjFor(Attack)
    
    vandalize()
    {
        isdented = true;
        isbroken = true;
        isanswering = nil;
        isringing = nil;
        brokenretain = true;
    }
    
    brokenretain = nil
    
    // basic actions for lifting receiver (doTake does the complete job)
    takemethod()
    {
        isoffhook = true;
        if (isringing) 
        {
            isanswering = true;
            isringing = nil;
        }
    }
    // method for replacing receiver.  If ispaid is set to an object, it
    // is returned unless the brokenretain property is set.
    dropmethod() 
    {
        isoffhook = nil;
        isanswering = nil;
        isringing = nil;
        if(ispaid && !(isbroken && brokenretain)) 
        {
            "\nThe phone returns your coins, which you take.\n";
            ispaid.moveInto(actor);
        }
        ispaid = nil;
    }
    // The following methods should be customized as required
    answermethod()
    {
        "You answer the phone, but there is no-one at the other end.";
    }
    dialtonemethod()
    {
        "You hear a dial tone.  ";
    }
    brokenmethod()
    {
        "The phone appears to be out of order.  There is no dial tone. ";
    }
    
    dialmethod(val)
    {
         if(val == nil)          
            "Please tell me what number you want to dial, e.g.
            dial &lt;number&gt; on <<theName>>. ";         
        else if(needtopay && ispaid == nil)
            "Nothing happens.  {I} will need to insert coins first.";
        else {
            "You hear a <q>number unobtainable</q>tone and replace the receiver.  ";
            dropmethod();        }
    }
    
    iobjFor(PutIn)
    {
        
        check()
        {
            if(!gDobj.ofKind(Coin))
                "{I} only want{s/ed} to put coins into the phone. ";
            else if(!needtopay)
                "(I} {don't need} to insert coins to use this phone. ";
            else if(isanswering || isringing)
                "{I} {don't need} to insert coins for an incoming call. ";
            else if (ispaid)
                "Hold on!  {I} {have} already put coins into the phone. ";
        }
        
        action()
        {           
            if (!isoffhook) {
                "\n(Lifting the receiver)\n";
                actionDobjTake();
            }
            if (isbroken) 
            {
                "{The subj dobj} drop{s/ped} into the coinbox with a dull
                <I>clunk</i>. There is still no dial tone. ";
            }
            else "Done.  ";
            gDobj.moveInto(nil);
            ispaid = gDobj;           
        }       
    }
    
    listenDesc
    {
        if(isringing)
            "The phone is ringing. ";
        else
            inherited;
    }
    
    isProminentNoise = isringing
;

/* Make ANSWER PHONE equivalent to TAKE PHONE */
SpecialVerb 'answer' 'take' [Phone, ProxyPhone]
//    objChecks(dobj, iobj, aobj)
//    {
//        dobj.isanswering = true;
//    }
;

/* Make REPLACE PHONE equivalent to DROP PHONE */
SpecialVerb 'replace' 'drop' @Phone;

phoneBooth1Door: DSDoor '(phone) (booth) door' @rotunda @inPhoneBooth1
    "It's <<if isOpen>>open<<else>>closed<<end>>. "
    mybooth = phoneBooth1 
    dobjFor(Open)
    {
        check()
        {
            mybooth.gnomecheck();
            inherited();              
        }
    }
;

// The gnome doesn't need much code because he's always unreachable!
gnome: MultiLoc, Fixture 'gnome; large'
   "The large gnome is occupying the phone booth, firmly
    blocking the door.  He is talking excitedly to someone at the
     other end of the phone. "
//    game551 = true  
    isntcoming = nil //? Not defined as a property of gnome in TADS 2 port, though referenced
    checkReach(actor) { "You can't get at the gnome while he's in the phone booth. "; }
    isAttackable = true
;


/* 190 */
devilsChair: DarkRoom 'At Devil\'s Chair'
    "{I}{'m} at the Devil's Chair, a large crystallization shaped like a
    seat, at the edge of a black abyss. {I} {can't} see the bottom.
    <<up.desc>>. "
    
    game551 = true
    
    north = decrepitBridge
    cross asExit(north)
    scross asExit(north)
    bridge asExit(north)
    up: PathPassage 'upward path' -> rotunda
    "An upward path leads away from the abyss. "
        { location = static lexicalParent }

       
    NPCexit1
    {
         if (!decrepitBridge.isfallen) return nil;
         else return dantesRest;
    }
    jump 
    {
        if (!decrepitBridge.isfallen)         
            "I respectfully suggest you go across the
            bridge instead of jumping.";        
        else
            didnt_make_it.death;
    }
    
//    listenDesc
//    {
//        inherited();
//        if (global.oldGame) 
//            return;
//        global.listenAdd = true;       
//        "You hear a distant roar, like the sound of a fast-flowing
//             river, from the depths of the abyss. ";
//    }
;

abyss: MultiLoc, Fixture 'deep abyss; yawning chasm\'s black dark of[prep]; chasm depths edge
    bottom   ' 
    "The chasm is so deep you can scarcely see the bottom. "
    iswavetarget = true // magic can be worked by waving the rod at it ...
    locationList = [devilsChair, dantesRest]
    dobjFor(JumpOver)
    {
        verify() {}
        action() { gActor.travelVia(gActor.getOutermostRoom.jump); }
    }
    
    listenDesc =  "You hear a distant roar, like the sound of a
    fast-flowing river, from the depths of the abyss. "
;

decrepitBridge: DSPassage 'bridge; natural decrepit' @devilsChair @dantesRest
    desc 
    {
        if(!isfallen) 
        {
            "That bridge looks very fragile. ";
            if(crosscount >= 0) "I'd take care when crossing
                it. ";
        }
        else
            "The remnants of the bridge can still be seen, but there
            is now no way across the chasm. ";
    }
    
    canTravelerPass(actor) { return !isfallen; }
    explainTravelBarrier(actor, connector)
    {
        "There is no longer any way across the chasm. ";
    }
    
    specialDesc()
    {
        if(!isfallen)         
            "A decrepit natural bridge spans the chasm.  A message
            scrawled into the rock wall reads: <q>Bridge out of repair.
            Maximum load: 35 Foonts.</q>";        
        else 
            "The remnants of a natural bridge partially overhang the
            chasm. ";        
    }
    
    /* Code for crossing the bridge follows.  It can always be crossed
       safely if the total weight of objects carried is 4 or less.  If
       more than 4, the bridge may collapse and we'll end up in the
       Lost River Canyon.  Each time the bridge is crossed, the probability
       of collapse goes up (provided that the allowable weight was
       exceeded).   The upgraded magic wand can temporarily make the
       bridge safer.
    */
    
    noteTraversal(actor)
    {
        local safecross = nil, fallpct, i, l, o;
        local olist, wt;
        
        crosscount++;
        wt = actor.getCarriedWeight();
        
        if((crosscount <= 0) || (wt <= 4))
            safecross = true;
        
        if(!safecross) 
        {
            fallpct = ((wt + crosscount) * (wt + crosscount))/10;
            if(fallpct < 10) 
                fallpct = 10;
            if(rand(100) <= fallpct) 
            {
                isfallen = true;
                "The load is too much for the bridge!  With a roar, the
                entire structure gives way, plunging you headlong into the
                raging river at the bottom of the chasm and scattering all
                your holdings.  As the icy waters close over your head,
                you flail and thrash with all your might, and with your
                last ounce of strength pull yourself onto the south bank
                of the river.<p>";
                
                if(brassLantern.isIn(actor))
                    brassLantern.moveInto(lostCanyonE);
                if(axe.isIn(actor))
                    axe.moveInto(lostCanyonS);
                l = FreshBatteries.list.length;
                for (i = 1; i <= l; i++) 
                {
                    o = FreshBatteries.list[i];
                    if(o.isIn(actor))
                        o.moveInto(lostCanyonS);
                }
                l = actor.contents.length; 
                olist = actor.contents;
                for (i = 1; i <= l; i++) 
                {
                    o = olist[i];
                    o.moveInto(nil);
                    if (o == mushrooms || o == mushroom) // Regrow mushrooms
                        new Fuse(o, &regrow, o.growtime);                        
                }
                actor.travelVia(lostCanyonE);
                exit;
            }
            else         
                "The bridge shakes as you cross.  Large hunks of clay and
                rock near the edge break off and hurtle far down into the
                chasm.  Several of the cracks on the bridge surface widen
                perceptibly. <.p>";
            
        }
        
    }
    
    
//    game551 = true
    dobjFor(Cross) asDobjFor(TravelVia)
    isfallen = nil
    iswavetarget = true 
    crosscount = 0
    
    
;

bridgeMess: MultiLoc, Decoration 'message; warning'
    desc
    {       
        readDesc();
        if(decrepitBridge.isfallen) 
            "It's certainly out of repair now.  You should have taken
            more heed of the warning. ";
        
        else if (decrepitBridge.crosscount >= 0) 
            "The bridge certainly looks very fragile.\b
            You'll need to keep the weight of your inventory to a bare
            minimum, otherwise it won't be safe to cross. ";
    }
        
    readDesc = "It reads: <q>Bridge out of repair. Maximum load: 35 Foonts.</q> " 
    locationList = [dantesRest, devilsChair]
    game551 = true
;

/* 191 */
deadEndCrack: DeadEndRoom 'In Dead End Crack' 'dead end crack;dead-end (in)'
    "{I}{'m} in a dead-end crack. "
    
    game551 = true
    
    north = atEastEndOfLongHall
    out asExit(north)
//    ana2 = Blue_Dead_End_Crack
;

/* 192 */
gravelBeach: NoNPC, Room 'On Gravel Beach' 'small gravel beach; (on) blue;grotto'
    "{I}{'m} on a small gravel beach at the south wall of the Blue Grotto.
    A gravelly path leads east. "
    
    game551 = true
    sober = true // don't allow player to leave by drinking wine
    
    north: TravelConnector -> grottoWest
    {
        travelBerriers = [boatBarrier, poleCheck]
    }
    
    northeast: TravelConnector -> blueGrottoEast
    {
        travelBerriers = [boatBarrier, poleCheck]
    }
    
    east: PathPassage 'gravelly path' -> vestibule
    "The gravelly path leads east. "
    {
        travelBarriers = [noBoatBarrier]
        location = static lexicalParent    
    }    
;



/* 193 */
flowerRoom: NoNPC, DarkRoom 'In Flower Room'
    "{I}{'m} in the Flower Room.  The walls are covered with colorful,
    intricate, flower-like patterns of crystallized gypsum. A hole leads
    to the west. "
    game551 = true
    sober = true // don't allow player to leave by drinking wine    

    west: Passage 'hole' -> vestibule {location = lexicalParent }
    hole = west
;


+ hive: Fixture, Container 'beehive; (bee) ;hive '
    desc()
    {
        
        if (!bees.arefed)
            "Due to the bees, you can't examine the hive closely. ";
        else
            "It's a normal-looking beehive, securely fixed to the floor. ";
//        if (itemcnt(self.contents) > 0) {
//            "\nIt contains "; listcont(self);".  ";   
    }
    
    contentsListed = bees.arefed
    
//    game551 = true
     
    specialDesc 
    {        
        if(!bees.arefed)
            "There is an active beehive nearby.  The bees hum
            protectively around the hive.  ";
        else
            "There is a beehive here, securely fixed to the floor. ";
    }

    checkReach(actor)
    {
        if(!bees.arefed)
            "The hum of the bees rises to an angry buzz as you move
            towards the hive. ";
    }
    
    dobjFor(LookIn)
    {
        check()
        {
            if(!bees.arefed)
                desc();
        }        
    }
    
    iobjFor(ThrowAt)
    {
        check()
        {
            if(gDobj != flowers)
            "That would only enrage the bees!";    
        }
        action
        {
            doInstead(FeedWith, bees, gDobj);
        }
    }
           
   
/* 
 *   Allow objects to be put in the hive provided they are not too bulky, and provided that the bees
 *   have been fed (the latter condition should be enforced by checkReach() )
 */    
    iobjFor(PutIn)
    {
        check()
        {
            if(gDobj.islong)
                "{The subj dobj} {is} too long to go into {the iobj}. ";
            else if(gDobj.isLarge)
                "{The subj dobj} {is} too large to go into {the iobj}. ";
            else if(gDobj.isHuge)
                "{The subj dobj} {is} are too large to go into {the iobj}. ";
            else 
                inherited();                
        }
    }   
;

/* 194, 195 */

EWCorridorE: DarkRoom 'At East End of Short E/W Corridor'
    desc() 
    {
        if(inArchedHall.jericho) 
            
            "{I} {am} looking west from the end of a short E/W corridor.
            At {my} feet is a pile of loose rubble. On {my} left is
            a hole into another chamber. ";
        
        else 
            "{I} {am} at the end of a short E/W corridor.";
    }
    
    game551 = true
    sober = (!inArchedHall.jericho)
    
    south = inArchedHallWalls
    
//    south: TravelConnector -> inArchedHall
//    {
//        isConnectorApparent = inArchedHall.jericho
//    }
    
    hole asExit(south)
    wall asExit(south)
    cross asExit(south)
    left asExit(south)
    west = crypt

    // Avoid getting NPC's trapped in here.
    NPCexit1 = inArchedHall
    // Exit info. for 'back' command:
    
    listenDesc
    {
        if (jericho || global.oldGame)
            inherited();
        else
            "You pace around the room, listening carefully to your
            footsteps.  You have a strong feeling that the wall to your
            south is hollow. ";
    }
    
;

+ corridorRubble: Fixture 'loose rubble'
    "It's just loose rubble. "
//    game551 = true
   
    cannotTakeMsg = 'You\'ve come here to find treasures, not to cart
    useless rubble around the cave.  I suggest that you leave it where
    it is. '
    
    lookInMssg = 'You sift through the rubble, but find nothing
    of interest. '
 
    dobjFor(Move)
    {
        verify() {}
        action = "You move the rubble to one side, but find nothing of interest. "
    }
;

/* 196 incorporated with In_Arched_Hall */
/* 197 */
vestibule: NoNPC, DarkRoom 'In the Vestibule'
    "{I}{'m} in the Vestibule, a short east-west passage between two rooms. "
    
    game551 = true
    sober = true // don't allow the player to leave by drinking wine
    
    passage = "The passage goes in two directions.  Please tell me which way
        you want to go "
        
    east = flowerRoom
    west = gravelBeach
;

/* 198 */
fairyGrotto: Room 'In the Fairy Grotto'
    "{I} {am} in the Fairy Grotto.  All around {me} innumerable
    stalactites, arranged in immense colonnades, form elegant arches.  On every side
    you hear the dripping of water, like the footsteps of a thousand
    fairies.  A small stream runs from the SW corner.  A bright glow
    emanates from the south side of the grotto, and a steep passage
    descends to the east."
    
    wino_trollstop = true // troll stops a wino from getting to cloak_pits
    game551 = true
    

    southwest = muddyDefile
    stream asExit(southwest)
    downstream asExit(southwest)
    passage asExit(southwest)
    
    east = coldPassage
    down asExit(east)
    
    south: TravelConnector -> crystalPalace
    {
        canTravelerPass(actor)
        {
            return !(brassLantern.isIn(actor) && brassLantern.isLit);    
        }
        explainTravelBarrier(actor, connector)
        {
            "You go a short way down the bright passage, but the light
            grows to blinding intensity.  You can't continue. ";
        }
    }
        
    up asExit(south)
    NPCexit1 = crystalPalace
    // Exit info. for 'back' command:
    
;

+ Decoration 'stalactites; innumerable immense elegant; colonnades arches; them'
    "The stalactites, arranged in immense colonnades, form elegant arches. "
;

+ Decoration 'small stream'
    "The stream runs from the sw corner. "
;

+ Decoration 'bright glow'
    "The glow emanates from the south side of the grotto. "
;

/* 199 */
too_cold: object
    mag = "{I} {have}} approached the lower end of a steep passage,
        but it is just too cold here to hang around, and {i} {aren't}
        properly equipped to continue.  With teeth chattering, {i} climb{s/ed}
    back up....<.p>"
;


/* 200 */
// This is the reverse of a darkroom.  When the lamp is on, the light is
// blinding.

crystalPalace: Room 'In the Crystal Palace'
    "{I} {am} in the Crystal Palace.  An overhead vein of
        phosphorescent quartz casts a luminous glow which is reflected by
        countless chips of mica embedded in both walls, which consist of
        some sort of highly reflective glass, apparently of volcanic
        origin.  A winding path of yellow sandstone leads west and rises
        steeply to the east. "
    
    lookAroundWithin()
    {
        if(blinding)
            "The glare from the walls is absolutely
            blinding.  If you were to proceed you would almost certainly fall
            into a pit. ";
        else
            inherited();
    }
    
    listStatusExits(lst, cnt)
    {
        if(blinding)
            "too dazzling to make out";
        else
            return true;
        return nil;
    }
    


    game551 = true
    wino_trollstop = true // troll stops a wino from getting to cloak_pits
    
            
    west: TravelConnector -> fairyGrotto
    {
        travelBarriers = [blindingBarrier]
    }

    east: TravelConnector -> yellowPath
    {
        travelBarriers = [blindingBarrier]
    }

    up asExit(east)


    NPCexit1 = fairyGrotto
    NPCexit2 = yellowPath

   
    // This property indicates that the light level in the room is too
    // high ...
    blinding = (brassLantern.isLit && brassLantern.isIn(self))
    
    roomBeforeAction()
    {
        
        if(gActionIn(PutIn) && gDobj.ofKind(FreshBatteries) && gIobj == brassLantern
           && gActor.canReach(gDobj) && gActor.canReach(gIobj))
            return;
        
        if(gActionIn(Replace, Change) && gDobj.ofKind(FreshBatteries) &&
           gActor.canReach(brassLantern) && gActor.canReach(gDobj))
            return;
        
        if(gActionIs(Drop) || gAction.ofKind(SystemAction) || gAction.ofKind(TravelAction)
           || gAction.ofKind(IAction))
            return;
        
        if(gActionIn(Extinguish, SwitchOff) && gDobj == brassLantern && 
           gActor.canReach(brassLantern) && gActor.canReach(gDobj))
            return;
        
        if(blinding)
        {
            
            "The glare from the walls is so bright that you can\'t see
            a thing.\n";
            exit;
        }       
    }  
;

+ Decoration 'overhead vein of phosphorescent quartz; highly reflective luminous volcanic;
    glow chips mica glass'
    "I've already told you all you need to know about that. "
    notImportantMsg = 'You don\'t need to refer to that. '
;

+ Fixture 'winding path; yellow sandstone of[prep]; sandstone'
    "The yellow path runs both east and west from here. "
    cannotFollowMsg = 'You\'ll have to say which way you want to go. '
    cannotClimbMsg = cannotFollowMsg
;

blindingBarrier: TravelBarrier
    canTravelerPass(traveler, connector)
    {
        return !traveler.getOutermostRoom.blinding;
    }
    explainTravelBarrier(traveler, connector)
    {
        "The glare from the walls is absolutely blinding.
         If you tried to proceed you would almost certainly fall into
         a pit. ";
    }
;

/* 201 */
yellowPath: Room 'On the Yellow Path' 'yellow path; (on) east-west sandstone'
    "{I} {am} following an east-west yellow sandstone path.  There is a
    glow to the west.   A dark passage branches off to the north. "
    
    game551 = true
    wino_trollstop = true // troll stops a wino from getting to cloak_pits
    

/* Mention of the north passage has been added, on the grounds of fairness
to Adventurers.  */
    
    west: TravelConnector -> crystalPalace
    {
        canTravelerPass(actor)
        {
            return !(brassLantern.isIn(actor) && brassLantern.isLit);
        }
        explainTravelBarrier(actor, connector)
        {
            "You go a short way down the bright passage, but the light
            grows to blinding intensity.  You can't continue. ";
        }      
    }
    down asExit(west)
    east = rainbowRoom
    north = ledgeAbovePinnacles
    passage asExit(north)
    
    NPCexit1 = crystalPalace    
;

+ Distant 'glow'
    "The glow is off to the west. "
;

/* 202 */
rainbowRoom: DarkRoom 'In the Rainbow Room' 'rainbow room;very tall; chamber'
    "{I} {am} in a very tall chamber whose walls are comprised of many
    different rock strata.  Layers of red and yellow sandstone
    intertwine with bright bands of calcareous limestone in a rainbow-
    like profusion of color.  The rainbow effect is so real, you
    are almost tempted to look for a pot of gold!  Poised far over 
    {my} head, a gigantic slab, wedged tightly between the north and
    south walls, forms a natural bridge across the roof of the chamber.
    A trail leads east and west. "
    
    game551 = true
    wino_trollstop = true // troll stops a wino from getting to cloak_pits
    
    west = yellowPath
    click = overRainbow
    east = greenLakeRoom
//    myhints = [Bridgehint]
;

+ Fixture 'trail; e-w east-west'
    "The trail leads east and west. "
    cannotFollowMsg = 'The train leads east and west; which way do you want to go? '
    cannotClimbMsg = cannotFollowMsg
;

+ Decoration 'rock strata; different red yellow calcareous;layers limestone sandstone;them'
   ordinary = 'quite interesting'  
;

rainbowSlab: MultiLoc, Fixture 'natural bridge; gigantic; slab'   
    checkReach(actor)
    {
        if(actor.isIn(rainbowRoom))
            "It's too far away. ";
    } 
    
    locationList = [rainbowRoom, overRainbow]
;

/* 203 */
coldPassage: DarkRoom 'In Cold Passage'
    "{I}{'m} in a steeply sloping passage.  It is very cold here. "
    
    game551 = true
    wino_trollstop = true // troll stops a wino from getting to cloak_pits
    
    
    passage = "The passage goes in two directions.  Please tell me which way
        you want to go "
    
    east: TravelConnector -> hallOfIce
    {
        canTravlerPass(actor) { return cloak.wornBy == actor; }
        explainTravelBarrier(actor, connector) { too_cold.msg; }             
    }
    
    down asExit(east)
    ice asExit(east)
    west = fairyGrotto
    up asExit(west)    
    
    // No NPCexits - hall of ice is off limits to dwarves
;

/* 204 */
//too cold for NPCs
hallOfIce: NoNPC, DarkRoom 'In Hall of Ice' 'hall of ice; in[prep];room'
    "{I} {am} in the Hall of Ice, in the deepest part of the caverns.
    During winter, frigid outside air settles here, making this room
    extremely cold all year round.  The walls and ceiling are covered
    with a thick coating of ice.  An upward passage exits to the west. "
    
    game551 = true
    wino_trollstop = true // troll stops a wino from getting to cloak_pits
    
    west = coldPassage
    up asExit(west)
    out asExit(west)
    passage asExit(west)
;

+ Decoration 'ice; thick of[prep]; coating'
    "The ice covers the walls and ceiling. "
//    game551 = true    
;

/* 205 */
overRainbow: DarkRoom 'Over the Rainbow (Room)' 'over the rainbow; natural huge; room bridge slab'
    "{I} {am} standing on a natural bridge far above the floor of a circular
    chamber whose walls are a rainbow of multi-colored rock.  The bridge
    was formed eons ago by a huge slab which fell from the ceiling and
    is now jammed between the north and south walls of the chamber."
    
    game551 = true
    // Don't allow drinking unless the Walls of Jericho are down.
    sober = (!inArchedHall.jericho)  

    north = gothicCathedral
    click = rainbowRoom
    jump = rainbow_demise
;

+ Distant 'circular chamber; multicolored multicoloured below of[prep] multi-colored
    multi-coloured; rock walls'
    "The circular chamebr below is enclosed in walls of multicolored rock. "
    
    notImportantMsg = 'The circular chamber is too far below. '
;

/* 206 */
greenLakeRoom: DarkRoom 'In Green Lake Room' 'green lake room; low wide (in)'
 
   "{I} {am} in a low, wide room below another chamber.  A small green
    pond fills the center of the room.  The lake is apparently spring-
    fed.  <<glrStream.desc>> A larger passage continues west. "
    
    game551 = true
    wino_trollstop = true // troll stops a wino from getting to cloak_pits
   
    passage =  "There's more than one passage -- please tell me which
        direction you want to go. "
        
    north = redRockCrawl
    stream asExit(north)
    downstream asExit(north)    
    crawl asExit(north)
    
    west = rainbowRoom
    up = 'The hole is too far up for {me} to reach. '
    hole = up
    climb = up
;

+ greenLake: StreamItem 'green pond;spring-fed;lake water'
    "It would be better described as a small pond rather than a
      lake.  It fills the center of the room and has a definite
     green tint, probably caused by minerals dissolved from the
      floor of the chamber. "
    
//    game551 = true    
;

+ glrStream: StreamItem 'small stream'
    "A small stream exits through a narrow passage to the north. "
;

+ Distant 'other chamber; another'
    "You can't see much of it from here. "
    notImportantMsg = location.up
;

/* 207 */
redRockCrawl: DarkRoom 'In Red Rock Crawl' 'red rock crawl; (in) tight north/south'
    "{I} {am} in a tight north/south crawl through a stratum of red
    colored rock.  The air is damp with mist. "
    
    game551 = true
    wino_trollstop = true // troll stops a wino from getting to cloak_pits
   
    north = lostCanyonS
    south = greenLakeRoom
    upstream asExit(south)
    downstream asExit(north)
;

+ Decoration 'mist' ordinary = 'ordinary';
+ Decoration 'stratum; red colored coloured of[prep] rock';

/* 208 */
lostCanyonS: DarkRoom 'On South Side of Lost River Canyon'
    'south side of the lost river canyon; (on) tall'
    "{I} {am} in a tall canyon on the south side of a swift, wide river.
    Written in the mud in crude letters are the words: <q>You Have Found
    Lost River.</q>  A wide path leads east and west along the bank. <<south.desc>> "
    
    game551 = true
    wino_trollstop = true // troll stops a wino from getting to cloak_pits
   
    east = lostCanyonE
    upstream asExit(east)
    south: PathPassage 'tight crawlway' -> redRockCrawl
    "A tight crawlway would take you south out of the canyon. "
        { location = static lexicalParent }
    crawl = south
    west = lostCanyonEnd
    downstream = lostCanyonEnd 
    cross =  north
    across = north
    north = 'The river is too wide and deep to cross. '     
;

+ PathPassage 'wide path' -> lostCanyonS
    "The path leads east and west. "
    canTravelerPass(actor) {return nil;}
    explainTravelBarrier(actor, conn) { desc; "Which way do you want to go? "; }
;

+ Fixture 'mud;crude ordinary;lettering letters note'
      "It's just ordinary mud, on which a previous adventurer has
        written the following:\b<<readDesc>>"   
       readDesc = "<q>You have found the Lost River.</q>"
;

lost: MultiLoc, StreamItem 'river; wide deep swift rapid fast flowing lost raging fast-flowing; 
    water stream'
    "The river is wide, deep and fast-flowing.  There's no way to cross it. "
    locationList = [lostCanyonS, lostCanyonEnd, lostCanyonE,
        nicheAboveRiver, narrowLedge]

    cannotCrossMsg = 'The river is too wide and deep to cross. '
    
     // The river is a distant item in some locations.
    checkReach(actor)
    {
        if(actor.getOutermostRoom not in (lostCanyonS, lostCanyonE))
           "It's too far away. ";
    }
    
    listenDesc = "You hear the roar of the wide, fast-flowing river. "
;

/* 209 */
lostCanyonEnd: DarkRoom 'At End of Lost River Canyon' 
    'end of lost river canyon; large flat rock (at); table'
    "{I} {am} standing on a large flat rock table at the western end of
    Lost River Canyon.  Beneath {my} feet, the river disappears amidst
    foam and spray into a large sinkhole.  A gentle path leads east
    along the river's south shore.  Another leads sharply upward along
    the river's north side. "
    
    game551 = true
    wino_trollstop = true // troll stops a wino from getting to cloak_pits
    
    downstrean = "Don't be ridiculous! " 
    jump = downstream    
    
    east: PathPassage 'gentle path' ->lostCanyonS
    "The gentle path leads east. "
        { location = static lexicalParent }
    upstream asExit(east)
    up = nicheAboveRiver
    climb = nicheAboveRiver
//    listendesc = "You hear the roar of the wide, fast-flowing river. "
;

+ Fixture 'large sinkhole; sink (and); hole foam spray'
    "Beneath {my} feet, the river disappears amidst
    foam and spray into a large sinkhole "
    cannotEnterMsg = 'You must be joking! '
;


/* 210 */
nicheAboveRiver: DarkRoom 'At Niche in Ledge above Lost River'
    'niche in the ledge above the lost river; at[prep] canyon; wall'
    "{I} {am} at a niche in the canyon wall, far above a raging river.
    The air is filled with mist and spray, making it difficult to see
    ahead.  A downward sloping ledge narrows to the east. The path
    to the west is easier. "
    
    game551 = true
    wino_trollstop = true // troll stops a wino from getting to cloak_pits
    sdesc = "."
    
    east: PathPassage, StairwayDown 'narrow sloping ledge; downward' -> narrowLedge
    "The ledge narrows to the east. "
        { location = static lexicalParent }
    
    down asExit(east)
    west: PathPassage 'path; east easier' ->lostCanyonEnd
    "It looks like the easier path. "
      { location = static lexicalParent }
    
    // This should be provided by the lost river object:
//    listendesc = "You hear the roar of the wide, fast-flowing river, far
//    below you. "
;

+ Decoration 'mist and spray;;;them' ordinary = 'plain ordinary';


/* 211 */
narrowLedge: DarkRoom 'At Narrow Ledge'
    "The ledge is growing very narrow and treacherous, and falls off almost
    vertically.  {I} could go down, but {i} won't be able to climb
    back. "
    game551 = true
    wino_trollstop = true // troll stops a wino from getting to cloak_pits
    
    west = nicheAboveRiver
    up asExit(west)
    east = onNESideOfChasm
    down asExit(east)
    
    // Let NPC's get out of here
    NPCexit1 = onSWSideOfChasm
//    listendesc = "You hear the roar of the wide, fast-flowing river, far
//    below you. "
;


/* 212 */
// See inPhoneBooth2 in endgame.t
//phoneBooth2: NoNPC, Room 'In Phone Booth' 
//    "{I} {am} standing in a telephone booth at the side of the Repository. "
//    game551 = true
//       
//    south = atNEEnd
//    out = asExit(south)
//;

/* 213 */
passageEndAtHole: DarkRoom 'At East End of Level Passage'
    "{I}{'m} at the east end of a level passage at a hole in the floor. "    
    game551 = true
    
    down = greenLakeRoom
    hole = greenLakeRoom
    passage = tongueOfRock
    west = tongueOfRock

;

/* 214 */
darkCove: NoNPC, Room 'In Dark Cove'
    "{I}{'m} at the north edge of a dark cove.  To your south lies
    the Blue Grotto.  A large lake almost fills the cavern floor. "
    
    wino_trollstop = true // troll stops a wino from getting to cloak_pits
    game551 = true
    
    south: TravelConnector -> grottoWest
    {
        travelBarriers = [boatBarrier, poleCheck]
    }
    southeast: TravelConnector -> bubbleChamber
    {
        travelBarriers = [boatBarrier, poleCheck]
    }
    
    northeast: TravelConnector -> dryBasin
    {
        travelBarriers = [noBoatBarrier]
    }    
;

+ Enterable 'blue grotto'
    "The Blue Grotto lies to the south of here. "
    connector = location.south
;

/* 215 */
dryBasin: NoNPC, DarkRoom 'In Dry Basin' 'dry granite basin; (in) smooth'
    "{I} {am} in a dry granite basin, worn smooth eons ago by water
    swirling down from a now-dry spillway. "
    
    game551 = true
    wino_trollstop = true // troll stops a wino from getting to cloak_pits
    
    southwest = darkCove
    up = oldSpillway
;

+ ProxyRoom 'dry spillway; now now-dry' -> oldSpillway;

/* 216 */
oldSpillway: NoNPC, DarkRoom 'In Old Spillway'
    "{I}{'m} in a dry spillway east of and above a smooth rock basin. "
    game551 = true
    wino_trollstop = true // troll stops a wino from getting to cloak_pits
   
    down = dryBasin
    east = winery
    up asExit(up)
;

+ ProxyRoom 'smooth rock basin' ->dryBasin;

/* 217 */
winery: NoNPC, DarkRoom 'In Winery' 'winery; (in) cool dark; room'
    "{I} {am} in the Winery, a cool dark room which extends some
    distance off to the east." 
    
    game551 = true
    wino_trollstop = true // troll stops a wino from getting to cloak_pits
    
    west = oldSpillway
    down asExit(west)
    out asExit(west)
    
    east = limestonePinnacles
    pit = limestonePinnacles
;

+ wine: RoomLiquid 'wine; of[prep];fountain'
    "It appears to be expensive vintage wine!  It would be
        very valuable if you could find a suitable cask to carry it in.  "
    
//    game551 = true

    liquid = 'wine'
    /* wine prefers to go into the cask by default */
    contlist = [cask, bottle]
    specialDesc =  "There is a fountain of sparkling vintage wine here! "

    dobjFor(Drink)
    {
        check()        
        {
            local numdwarves = Dwarves.numberhere(gActor);
            if (wumpus.isChasing) 
                "You'd better do something about the Wumpus
                first - this isn't going to help! ";
            
            else if(numdwarves > 0)
                "You'd better do something about the <<numdwarves == 1 ? 'dwarf' : 'dwarves'>> 
                first -- this isn't going to help! ";                
            
        }
        action() { cask.winocode(); }
    }   
;

/* 218 */
limestonePinnacles: NoNPC, DarkRoom 'At Limestone Pinnacles' '
    limestone pinnacles; at[prep]'
    "{I} {am} to the east of the Winery, where the room ends in a
    thicket of high, sharp, pointed, climbable limestone pinnacles.  There is a
    narrow ledge just above the top of the spires.  If you go up, it
    might be difficult to get back down."
    game551 = true
    wino_trollstop = true // troll stops a wino from getting to cloak_pits

    west = winery
    up: StairwayUp 'spires; high sharp pointed climbable;pinnacles; them' ->ledgeAbovePinnacles
        "The spires lead up to a narrow ledge. "
        { location = static lexicalParent }
    climb = ledgeAbovePinnacles
;

+ ProxyRoom -> winery;
+ ProxyRoom -> ledgeAbovePinnacles;

/* 219 */
gothicCathedral: DarkRoom 'In Gothic Cathedral'
    'gothic cathedral; high vaulted high-vaulted (in); cavern'
    "{I} {am} in a high-vaulted cavern whose roof rises over fifty
    meters to culminate in a series of pointed arches directly over 
    {my} head.  There are also two low arches to either side, forming
    side portals.  The whole effect is that of a gothic cathedral. 
    {I} {can} proceed north, south, east, or west. "
    
    game551 = true
    // Don't allow drinking unless the Walls of Jericho are down.
    sober = (!inArchedHall.jericho)
    
    south = overRainbow
    bridge = overRainbow
    north = altarFoot
    altar = altarFoot
    east = eastPortal
    west = westPortal
    pray = insideBuilding
;

+ Decoration 'arches; pointed low (two) side; portals; them'
    "I've already told you all I know about the arches and side portals. "
;
    

/* 220 */
eastPortal: DarkRoom 'At East Portal of Gothic Cathedral'
    "{I}{'m} at the east portal of the Gothic Cathedral. The path
    leads east and west. "
    game551 = true
    // Don't allow drinking unless the Walls of Jericho are down.
    sober = (!inArchedHall.jericho)
    
    west = gothicCathedral
    east = gothicChapel
    path: PathPassage 'path' ->eastPortal
    "The path leads east and west. "
    {
        location = lexicalParent
         canTravelerPass(traveler) { return nil; }
        explainTravelBarrier(traveler, connector)
        {
            desc; "Which way do you want to go? ";
        } 
    }
;

/* 221 */
westPortal: DarkRoom 'At West Portal of Gothic Cathedral'
    "{I}{'m} at the west portal of the Gothic Cathedral. "
    game551 = true
    // Don't allow drinking unless the Walls of Jericho are down.
    sober = (!inArchedHall.jericho)
    
    east = gothicCathedral
;

/* 222 */
altarFoot: DarkRoom 'At Foot of Altar' 'foot of the altar; at[prep]'
    "{I} {am} at the foot of the Altar, an immense, broad stalagmite.
     An opening leads south. "
    game551 = true
    // Don't allow drinking unless the Walls of Jericho are down.
    sober = (!inArchedHall.jericho)
    
    passage = gothicCathedral
    south = gothicCathedral
    up = topOfStalagmite
    climb = topOfStalagmite
    pray = insideBuilding
;

+ Fixture 'immense, broad stalagmite; altar'
    "Its looks a bit like at altar, at any rate. "
;

+ StairwayUp 'immense broad stalagmite;enormous broad;altar'
    "It does have an uncanny resemblance to a large cathedral altar. "
//    game551 = true
    
    destination = topOfStalagmite
    
    // Don't allow drinking unless the Walls of Jericho are down.
    sober = (!inArchedHall.jericho) 
;

/* 223 */
topOfStalagmite: DarkRoom 'On Top of Stalagmite'
    'top of the stalagmite; on[prep] enormous broad'
    "{I}{'m} on top of an enormous, broad stalagmite.  There is a hole
    in the ceiling overhead. "
    
    game551 = true
    // Don't allow drinking unless the Walls of Jericho are down.
    sober = (!inArchedHall.jericho)
    down = altarFoot
    climb = altarFoot    
    up = crypt
    hole = crypt
;


+ StairwayDown 'enormous broad stalagmite;immense broad;altar'
    "If you want to find out more, I suggest that you climb down it. "
//    game551 = true
    
    dobjFor(Climb) asDobjFor(ClimbDown)
    destination = altarFoot
;

/* 224 */
crypt: DarkRoom 'In the Crypt' 'crypt; (in) small; room'
    "{I} {am} in a room the size and shape of a small crypt.  A narrow
    cut exits east.  There is a hole in the floor. "

    game551 = true
    // Don't allow drinking unless the Walls of Jericho are down.
    sober = (!inArchedHall.jericho)
    
    down = topOfStalagmite
    hole = topOfStalagmite
    east = EWCorridorE
;

/* 225 */
gothicChapel: DarkRoom 'In Gothic Chapel' 'gothic chapel; (in) small; chamber'
    "{I} {am} in the Gothic Chapel, a small chamber adjoining the Gothic
    Cathedral. A path leads west. "
    game551 = true
    // Don't allow drinking unless the Walls of Jericho are down.
    sober = (!inArchedHall.jericho)
    
    west: PathPassage 'path' ->eastPortal "The path leads west. "
        { location = static lexicalParent }
;

+ Unthing 'gothic cathedral' 'It\'s not visible from here. ';

/* 226 */
rainbow_demise: Room 'Floor of the Rainbow Room'
    ldesc = "{I} {am} on the floor of the Rainbow Room.  In fact,
        {i} {am} spread <i>ALL OVER</i> the floor of the Rainbow Room. <<die()>>"    
;
    

/* 227 */
riverStyxApproach: OutsideRoom 'At Approach to River Styx'
    'approach to the river styx; dimly lit e/w; passage'
    "{I} {am} in a dimly lit E/W passage behind Thunder Hole.
     <<styxRockWall.desc>>"
    
    isIndoors = true
    regions = [indoors, outdoors]
    game551 = true
    
    west = thunderHole
    out asExit(west)
    up asExit(west)
    
    passage =  "The passage goes in two directions.  Please tell me which way
        you want to go. "        
    
    
    east: TravelConnector -> riverStyx
    {
        canTravelerPass(traveler) { return !dog.isIn(self) || dog.isAsleep; }
        explainTravelBarrier(traveler, connector)
        {
            dog.blockMessage;
        }        
    }

    in asExit(east)
    down asExit(east)
    
//    myhints = [Doghint]
    listenDesc()    
    {
        "You hear the sound of the river, and in the background there
        is a booming sound, caused by the surf pounding
        against the outer rocks of the cave. ";
        if(!dog.isAsleep)         
            "<.p>You also hear the dog growling at you!  I wouldn't
            go too close if I were you. ";        
    }
;

+ styxRockWall: Decoration 'rock wall; ominous; words; it them'
    "Etched into the rock wall are the ominous words: \n
    <i> \ \ \"You are approaching the River Styx.\ \ \ \ \ </i>\n
    <i> \ \ Lasciate Ogni Speranza Voi Ch'Entrate.\"\ \ </i>"
    readDesc = desc
    decorationActions = [Examine, Read]
;

+ ProxyRoom ->thunderHole;

/* 228 */
riverStyx: IndoorRoom 'At River Styx'
    "{I} {am} at the River Styx, a narrow little stream cutting directly
    across the passageway.  The edge of the stream is littered with sticks
    and other debris washed in by a recent rainfall.  On the far side
    of the river, the passage continues east."
        
    game551 = true
    

    north = "The stream flows out of one very small crack and into another."

    south = north
    upstream =  north
    downstream =  north
    crack =  north
    
    
    up asExit(west)
    west = riverStyxApproach
    out asExit(west)
    jump = riverStyxE
    // Modified to allow us across once we've worked out how to
    // cross the stream.
    
    east: TravelConnector ->riverStyxE
    {
        canTravelerPass(traveler) { return riverStyxE.seen; }
        explainTravelBarrier(traveler, connector)        
        {
            "How do you propose to cross the river? ";
        }
        travelDesc() { "\n(jumping the river)\n"; }
    }
    in asExit(east)
    across asExit(east)
    cross asExit(east)
    over asExit(east)
        
    passage = "The passage goes in two directions.  Please tell me which way
        you want to go "

    listenDesc = "You hear the sound of the river, and in the background
    there is a booming sound, caused by the surf pounding against the
    outer rocks of the cave. "
;

MultiLoc, Decoration 'sticks at Styx;river\'s tangled;branches debris mud;them it'
    "The sticks and branches litter the edge of the stream. "
    notImportantMsg = 'The sticks and branches are all in a tangle and are stuck in the
        mud.  You\'d need a shovel to dig them out. '   
    locationList = [riverStyx, riverStyxE]
    
;

MultiLoc, StreamItem 'River Styx; narrow little; stream'
    "The narrow little stream cuts directly across the passageway. "
    dobjFor(Cross)
    {
        verify() {}
        action()
        {
            local prop = (location == riverStyx ? &east : &west);
            local conn = location.(prop);
            conn.travelVia(gActor);
        }
    }
    locationList = [riverStyx, riverStyxE]
;

/* 229 */
riverStyxE: OutsideRoom 'On East Side of River Styx'
    "{I}{'m} on the east side of the river's sticks. A passage runs east. "
    
    jump = riverStyx
    west: TravelConnector -> riverStyx
    {
        travelDesc() { "\n(jumping the river)\n"; }
    }
    out asExit(west)
    across asExit(west)
    east = topOfSteps
    passage = east
;


/* 230 */
ledgeAbovePinnacles: DarkRoom 'On ledge above limestone pinnacles'
    'ledge above the limestone pinnacles; at[prep]; narrow'
    "{I} {am} on a ledge at the northern end of a long N/S crawl.  The
    ledge is above a large number of sharp vertical limestone spires.
    An attempt to climb down with bulky items could be dangerous, if
    you get my *point*!"
    
    game551 = true
    wino_trollstop = true // troll stops a wino from getting to cloak_pits
    
    
    /* 
     *   The effect of going down here has been reworked.  Now you can get down safely unless you
     *   are carrying any bulky items.
     */
    
    down: VarDest, StairwayDown 'limestone spires; sharp vertical;pinnacles;them' 
    "You could attemmpt to climb downb the spires, but doing so with 
    bulky items could prove dangerous. "
    {        
        location = static lexicalParent
            
            calcDest()
        {
            local o, tx, skewered = nil;
            o = gActor.allContents.subset(
                {x: !x.isFixed && x != sack && (x.isHuge || x.isLarge)});
            
            if(o.length > 0)
            {
                skewered = true;
                if(o.length == 1)            
                    tx = 'the bulky ' + o[1].name;
                else
                    tx = 'the bulky items';
            }       
            
            if (skewered) 
            {
                pinnacle_demise.bulkyObject = tx;
                return pinnacle_demise;
            }
            else return limestonePinnacles;
        }
    }
    // Jumping down will always get you skewered.
    jump {return pinnacle_demise.jumpdeath;}
    
    south: PathPassage 'long n/s crawl' -> yellowPath
    "The crawl leads off to the south. "
    {
        location = static lexicalParent
    }
    
    
    crawl = south
    // Exit info. for 'back' command:
    //    exithints = [Limestone_Pinnacles, &down]
    //    myhints = [Caskhint]
;

/* 231 */
pinnacle_demise: Room 'Skewered on Pinnacle'
    desc() { bulkdeath(bulkyObject);}
    jump = "That wasn't exactly your most brilliant move!
    You are very neatly skewered on the point of a sharp
    rock. "
    
    bulkyObject = nil
    
    bulk(tx) 
    {
        "Your attempt to climb down is hampered by
        <<tx>> you are carrying.  You lose your grip and fall to
        your death! You are now very neatly skewered on the point
        of a sharp rock. ";
    }

    // Note that we don't drop the player's possessions at
    // Limestone Spires.  This would be realistic, but it would allow the
    // player to obtain the wine after reincarnation!  The main
    // objection to this is that the player might be misled into seeking
    // the wrong type of solution (i.e. getting the cask down safely
    // instead of finding the way round.)

    jumpdeath {jump; die(); return nil;}
    bulkdeath(tx) {bulk(tx); die(); return nil;}
;



/* 232-234 */
poling_messages: object
    calm = "{I} {have} poled {my} boat across the calm water.<.p>"
    dark = "{I} {have} poled {my} boat across the dark water.<.p>"
    blue = "{I} {have} poled {my} boat across the Blue Grotto.<.p>"

;


/* 235 */
dantesRest: DarkRoom 'At Dante\'s Rest'
    "{I}{'m} at Dante's Rest, on the north side of a yawning dark chasm.
    A passage continues west along the chasm's edge. "
    game551 = true
    
    cross = decrepitBridge
        
    south = decrepitBridge
    across = decrepitBridge
    bridge = decrepitBridge
    passage = inMistyCavern
    west = inMistyCavern
    
    NPCexit1 
    {
         if (decrepitBridge.isfallen) return nil;
         else return devilsChair;
    }
    jump 
    {
        if (!decrepitBridge.isfallen) 
        {
            "I respectfully suggest you go across the
            bridge instead of jumping.";

            return nil;
        }
        else
            return didnt_make_it.death;
    }
    
    listenDesc = "You hear a distant roar, like the sound of a fast-flowing
             river, from the depths of the chasm. "  
;


/* 236 */
lostCanyonE: DarkRoom 'At East End of Lost River Canyon'
    "{I} {am} at the east end of a riverbank path in Lost River Canyon. "
    game551 = true
    wino_trollstop = true // troll stops a wino from getting to cloak_pits
    
    west: PathPassage 'riverbank path' -> lostCanyonS
    "The path runs west along the riverbank. "
        { location = static lexicalParent }
    downstream = west 
    upstream = "The path ends here and you can't go any further upstream. "
;


/* 238 */
pantry: IndoorRoom 'In the Caretaker\'s Pantry'
    "{I}{\'m} in the Caretaker's Pantry. "   
    
    game551 = true
    
    south = insideBuilding
    out asExit(south)
    nolampwarn = true
    entrance = insideBuilding
;




/* 239 */
riseOverBay: OutsideRoom 'On a Small Rise Over the Bay'
    "{I} {am} on a small rise overlooking a beautiful bay. In the center
    of the bay is the castle of the elves. "
    game551 = true
    

    north = sandyBeach
    northeast = sandyBeach
    smichel = castlePinnacle
    building = atEndOfRoad
//    myhints = [Castlehint]
;

+ Distant 'Castle of the Elves'
    "It looks like a fairy-tale <q>castle in the air.</q>  It's in
     the middle of the bay, and I can see no obvious way to get to it!"
    
//    game551 = true
    cannotEnterMsg = 'You\'ll have to tell me how to do that. '
    cannotBoardMsg = cannotEnterMsg
    decorationActions = [Examine, Enter, Board, GoTo]
;

+ Distant 'beautiful bay'
    "In the center of the bay is the castle of the elves. "
;

/* 240 */
castlePinnacle: OutsideRoom 'On Castle Pinnacle'
    'castle pinnacle; on[prep] of[prep] highest'
    "{I} {am} on the highest pinnacle of the castle in the bay.
    Steps lead down into the garden. "
    game551 = true
    
    northeast = riseOverBay
    across asExit(northeast)
    cross asExit(northeast)
    smichel = riseOverBay
    down = castleSteps
;

+ Distant 'bay;;sea water'
    "The bay is spread out below you. "
;
+ Enterable ->castleSteps 'outer courtyard of the garden'
    "The garden is at the bottom of the steps. "
;


castleSteps: DSStairway 'steps;stone;;them' @castlePinnacle @outerCourtyard
    "Stone steps lead from the top of the tower to the outer 
     courtyard of the garden. "    
;

/* 241 */
outerCourtyard: OutsideRoom 'In Outer Courtyard'    
    "{I} {am} in the outer courtyard of the garden of the elves.
    Steps lead up to the tower, and to the west, separating you
    from the inner courtyard, is a maze of hedges, living things,
    but almost crystalline in their multicolored splendor. "
    
    game551 = true
    
    up = castleSteps
    west = livingMaze1
;

+ Distant 'tower'
;

+ ProxyRoom 'maze of hedges; crystalline multicolored multicoloured; splendor splendour'
    "The hedges are almost crystalline in their multicolored splendor. "
    destination = livingMaze1
; 

+ Unthing 'inner courtyard'
    'You can\'t see the inner courtyard from here; the maze is in the way. '
;
    

class KaleidConnector: TravelConnector
    noteTraversal(actor)
    {
        actor.kaleid = nil;
        inherited(actor);
    }
;

livingMazeSkip: MazeSkipConnector
    destList = [outerCourtyard, livingMaze6]
;

/* 242 */
livingMaze1: OutsideRoom 'In Living Maze (red berries)'
    "From the inside the maze looks like a kaleidoscope, with
    swatches of color dancing as you move. In this part the colors
    are produced by shining red berries on the branches. "
    game551 = true
      

    // actor.kaleid implements the 'kaleidoscope code' in the original
    // version.  Here the implementation is simple: global.kaleid is
    // set to true whenever you enter the first room, but false if
    // you make a wrong move.
    travelerEntering(traveler, origin)
    {
        traveler.kaleid = true;
        inherited(traveler, origin);
    }
   
    east = outerCourtyard
    southwest = livingMaze2
    west: KaleidConnector -> livingMaze3 {}
        
    northwest: KaleidConnector -> livingMaze5 {}
    mazeSkip = livingMazeSkip
;


+ redBerries: Fixture, CanPick 'red berries;shining;branches;them'
    "They look very attractive, but they're probably deadly
        poisonous.  I'd leave them alone if I were you. "
    
//    game551 = true
    
    cannotTakeMsg = 'They look very attractive, but they\'re probably deadly
        poisonous.  I\'d leave them alone if I were you. '
    cannotEatMsg = cannotTakeMsg  
;


/* 243 */
livingMaze2: OutsideRoom 'In Living Maze (orange flowers)'
    "{I} {am} surrounded by a tall hedge with sharp iridescent leaves
    and metallic orange flowers. "
    
    game551 = true
        
    northeast = livingMaze1
    north = livingMaze3
    northwest: KaleidConnector -> livingMaze6 {}    
    mazeSkip = livingMazeSkip
;

+ Decoration 'tall hedge; sharp iridescent metallic orange;leaves flowers; it them'
    "The hall hedge has sharp iridescent leaves and metallic orange flowers. "
    decorationActions = [Examine, Climb]
    cannotClimbMsg = '{I} {am} unable to climb over the tall hedge. '
//    game551 = true
;

/* 244 */
livingMaze3: OutsideRoom 'In Living Maze (yellow leaves)'
    "{I} {am} in the center of the living maze. <<yellowPlants.desc>> "
    
    game551 = true
    sdesc = "In Living Maze (yellow leaves)"
    
    east = livingMaze1
    
    south: KaleidConnector -> livingMaze2 {}
        
    west = livingMaze4
    north: KaleidConnector -> livingMaze5 {}
    mazeSkip = livingMazeSkip
;

+ yellowPlants: Fixture 'plants; brilliant yellow dormant; leaves; them'
    "The plants here are dormant this season, but still carry brilliant yellow leaves. "

    cannotClimbMsg = '{I} {am} unable to climb over the plants. '
//    game551 = true
;

/* 245 */
livingMaze4: OutsideRoom 'In Living Maze (green leaves)'
    "Unlike the other areas of the hedge system, this area seems to
    have no metallic gleam; nevertheless it is still breathtaking.
    <<hedgeSystem.desc>> "
    
    game551 = true
    
    south: KaleidConnector -> livingMaze2 {}    
   
    east: KaleidConnector -> livingMaze3 {}
    
    north = livingMaze5
    
    west: KaleidConnector -> livingMaze6 {}    

    
    mazeSkip = livingMazeSkip
;

+ hedgeSystem: Decoration 'hedge system; lighter seasonal yellowish green (this); trees bushes 
    evergreens shade area;it them'
    "The trees and bushes are all variegated shades of green, the
    evergreens being a rich dark shade while the seasonal bushes
    are a lighter yellowish green, making a startling contrast. "
//    game551 = true
;
    
/* 246 */
livingMaze5: OutsideRoom 'Near Edge of Maze (blueberries)'
    "{I} {am} near the edge of the maze. There are delicious-looking
    blueberries on the bushes.  {I}{'m} tempted to sample them! "
    
    game551 = true
    
    southeast  = livingMaze1
    
    south: KaleidConnector -> livingMaze4 {} 
    
    southwest = livingMaze6
    mazeSkip = livingMazeSkip
;

+blue2: Blueberries 
//    game551 = true
;


/* 247 */
livingMaze6: OutsideRoom 'Western Edge of Maze (violets)'
    'western edge of the living maze; (west) (w); end'
    "{I} {am} at the western end of the living maze. <<wallShrubs.desc>>
    To the west, through a small gate, is the inner garden."
    
    game551 = true
    

    southeast: KaleidConnector -> livingMaze2 {} 
    
    east: KaleidConnector -> livingMaze4 {} 
    
    northeast: KaleidConnector -> livingMaze5 {} 
   
    west = courtyardGate
    gate asExit(west)
    in asExit(west)
    mazeSkip = livingMazeSkip
;

+ wallShrubs: Decoration 'shrubs; brilliant purple planted (of); beds violets pansies walls; them'
    "Beside the shrubs forming the walls are tastefully planted beds of
    violets and brilliant purple pansies. "
;

+ Enterable 'inner garden;;courtyard'
    "The inner garden is situated through the small gate to the weat. "
    connector = location.west
;

courtyardGate: DSDoor 'gate; small' @livingMaze6 @innerCourtyard 
    "It's <<if isOpen>>open<<else>>closed<<end>>. "
    
    getDestination(origin)
    {
        if(origin == innerCourtyard || gActor.kaleid)
        {
            return inherited(origin);
        }
        local destno = rand(5) + 1;
        switch(destno) {
        case 1:
            return livingMaze1;
        case 2:
            return livingMaze2;
        case 3:
            return livingMaze3;
        case 4:
            return livingMaze4;
        case 5:
            return livingMaze5;
        default:
            "\nInternal error, destno = ";
            say(destno);"\n";
            return nil;
        }
    }   
    
    noteTraversal(actor)
    {
        if(!actor.kaleid)
            "You get a tingling feeling as you walk through the gate,
            and ...\b"; 
        inherited(actor);
    }   
;


/* 248 */
innerCourtyard: OutsideRoom 'In Inner Courtyard'
    "{I} {am} in the inner garden of the elves. In the center is
    a living tree, with shimmering silvery bark, glistening metallic
    green leaves, and flowers ripe with nectar. As the nectar falls
    to the ground it forms droplets of silver. Around the tree is
    a hedge of briars which cannot be crossed. Unfortunately for
    adventurers such as you, most of the nectar falls inside the hedge.
    The exit is to the east." 
    
    east = courtyardGate
    gate = courtyardGate
    out asExit(east)
    
    cross = "You can't cross the hedge of briars. "
    in = cross
    mazeskip = outerCourtyard
;

+ briars: Fixture 'hedge of briars;;thorns;it them'
    "The shoulder-high hedge is about three foot wide and is
     full of razor-sharp thorns.   You'd be torn to shreds if you
     tried to force your way through. "
    
    cannotCrossMsg = '''The thorns are razor sharp.  You can't cross the hedge of  briars.'''
    cannotJumpOverMsg = '''A top Olympic athlete might be able to get over the hedge that
        way, but it's unlikely that you could.  You'd be torn to
        shreds in the attempt. '''
    
    dobjFor(Kick)
    {
        verify()
        {
            illogical('Those thorns look very nasty.  Your legs would be torn to shreds. ');
        }
    }
    
    dobjFor(CutWith)
    {
        verify()
        {
            if(!gVerifyIobj.ofKind(Weapon))
                illogical('I don\'t see how you cut a hedge with {a iobj}. ');
        }
        
        action()
        {
            "You slash {the dobj} vigorously with {the iobj}.
            This has no effect whatsoever on {the dobj} but you
            have noticeably blunted the edge of your weapon.  I'd
            give up trying to cross the hedge if I were you. ";
        }
    
    }
    
    dobjFor(AttackWith) asDobjFor(CutWith)
    
;

+ livingTree: Distant 'living tree; shimmering silvery metallic green; bark leaves flowers'
    "It's the most remarkable tree you've ever seen.
        Unfortunately there is no way to cross the hedge to get a closer look. "
    
    cannotClimbMsg = 'You might be able to climb this tree, but
        you can\'t cross the hedge to get to it. '
    
    decorationActions = [Examine, Climb, ClimbUp]
    
    notImportantMsg = 'Unfortunately, the tree is out of {my} reach on the far side of the hedge. '
;


+ nectar: Distant 'nectar; of[prep]; drops silver'    
    "I've already told you all I know about the nectar. "    
;

castleWalls: MultiLoc, Decoration 'walls;stone stone-built (castle) built;wall;them it'
    "They enclose an octagonal area, and look like normal stone-built walls.  <<if gRoom ==
      outerCourtyard>>There is something odd about them, though - I can't
            see a door anywhere! <<end>>"
    noun = 'wall' 'walls'
    
    adjective = 'castle'
    locationList = [castlePinnacle, outerCourtyard]    
    
    actionDobjCount = "The walls form an octagonal shape -- so there are
        eight of them. ";
;

hedges: MultiLoc, Decoration 'hedges and their leaves and flowers; multicolored multicoloured;
    hedge trees flowers violets pansies leaves maze garden; them it' 
    
    locationList = [
        outerCourtyard, livingMaze1, livingMaze2,
        livingMaze3, livingMaze4, livingMaze5, livingMaze6
    ]
    checkDobjCount = "You quickly give up the attempt to count the
        multicolored hedges. "
;

castleRoom: IndoorRoom 'Octagonal Castle Room' 'octagonal castle room; large'
    "You're in an a large octagonal room with shiny white marble walls
    Doorways, each marked with a sign in Elvish, lead out in all compass directions.  "
    
    game551 = true
   
    north: TravelConnector -> atEndOfRoad
    {
        travelDesc()
        {
            "As you approach the doorway, a loud buzzer sounds and your bracelet
            glows red.   (I guess the Elves' security systems are better than
            we thought).  You then get a strange tinging
            sensation, and you find yourself...<\b>";
            
            // move any objects which the player dropped
            roomMove(self, atEndOfRoad);
        }
    }    
    
    south = north
    east = north
    west = north
    northwest = north
    southwest = north
    northeast = north
    southeast = north
    
    phleece = outerCourtyard

    listenDesc = "There's nothing but a strange silence.  Something isn't
        quite right here ... "
;

+ Decoration 'shiny white marble walls;;;them'
    "You know as much as I do. "
;

+ Decoration 'sign; elvish'
    "The signs are marked in Elvish. "
    readDesc = desc
    decorationActions = [Examine, Read]
;