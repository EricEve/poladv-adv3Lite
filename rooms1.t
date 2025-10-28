#charset "us-ascii"

#include <tads.h>
#include "advlite.h"

/* Additional rooms for 551-point version */

/* Note the following change from the Fortran version.  For consistency,
'building' from a surface location takes us back to At_End_Of_Road, rather
than Inside_Building. */

/* 141 */
/* Note - in the 701-point game this room combines the 551-point Sword Point 
   room with the 550-point N_Of_Reservoir.  Note that the 701-point game has
   two sword-in-the stone puzzles with different solutions!
 */
    
 swordPoint: NoNPC, DarkRoom 'At Sword Point'
    desc()
    {
        "{I} {am} on a narrow promontory at the foot of a waterfall, which
        spurts from an overhead hole in the rock wall and splashes into a
        large reservoir, sending up clouds of mist and spray.
        To the south, the indistinct shape of the opposite shore can be dimly
        seen.\b";
        
        "Through the thick white mist looms a polished marble slab, to
        which is affixed an enormous rusty iron anvil.  In golden letters
        are written the words: \"Whoso Pulleth Out This Sword of This
        Stone and Anvil, is Rightwise King-Born of All This Mountain.\"
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
+ anvil: Fixture 'rusty anvil'
    "It's just a large, rusty iron anvil, fixed to the marble slab. "
  
    game551 = true    
    
;

+ Fixture 'marble slab'
    "It's simply a slab of marble, to which a large iron anvil is attached. "
    
    game551 = true    
;

/* 142 */
topOfSlide: NoNPC, DarkRoom 'At Top of Slide'
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



/* 143 */
throneRoom: DarkRoom 'At Entrance to Throne Room'
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



+ Distant 'throne; elfish elfin intricate'
    "It's at the far end of the room.  I suggest that {i} {get}
        closer if {i} want{s/ed} to examine it! "
    
    game551 = true
    vcoabLikelihood = 10
;

/* 
 *   Rather than using a floorDesc property on the room as in the TADS 2 version, we define a Floor
 *   object to act as the floor to both ends of the Throne Room.
 */
trFloor: Floor 'floor; smooth clean; ground'
    "The floor is exceptionally smooth and clean, but isn't at all slippery or shiny. "    
;

/* 144 */
throneRoomEast: DarkRoom 'At East Side ot Throne Room'
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

+ throne: Fixture, Chair 'throne; elfin elvish intricate'
    
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
            its effect, but you don't know how - and it's \(far\) too powerful 
            in here! ";       
    
        roomMove(vastChamber, throneRoomEast);
        traveled = true;
        return nil;
    }
    
    traveled = nil
;

// TO DO - Complete throne room and throne


/* 146 */
inForest3: OutsideRoom 'In Forest'
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


/* 147 */
knoll: OutsideRoom 'On Grassy Knoll'
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
//    phuce = {
//        local actor := getActor(&travelActor);
//        phuce_messages.smaller; 
//        // If the clover hasn't been picked, leave it alone
//        if (not clover.moved) clover.isfixed := true;
//        actor.roomMoveTravel(&transmove, denseJungle);
//        if (not clover.moved) clover.isfixed := nil;
//        return nil;
//    }
    
    phuce()
    {
        phuce_messages.smaller; 
        roomMove(getOutermostRoom, denseJungle);
        return denseJungle;        
    }
;


denseJungle: OutsideRoom 'In a Dense Jungle'    
        "You're in a dense jungle, surrounded by large leaves which tower above
        your head.  Progress may be possible to the north, east or 
        southwest. "
    
    north = "You manage to walk a short distance to the north, only to encounter
        an unfriendly-looking giant spider.  You decide to beat a hasty retreat. "
    
    east = "You walk a few yards to the east, only to encounter a giant bird!
        Fearing for your life, you beat a rapid retreat. "
        
    southweast =  "You travel a fair distance to the southwest, only to encounter a
        giant grasshopper!   You retreat to your starting point and ask
        yourself whether this was the right place to use the \"Phuce\" spell.
        Most Elvish magic doesn't work for humans, but this particular
        spell seems to be \(too\) effective if you use it here. "
        
    sober = true
    
/* size of brass key as seen in this room */
//    brasskey = large_key
//    phuce = {
//        local actor := getActor(&travelActor);
//        phuce_messages.larger; 
//        actor.roomMoveTravel(&transmove, knoll);
//        return nil;
//    }
    
    phuce
    {
        phuce_messages.larger;
        roomMove(getOutermostRoom, knoll);
        return knoll;
    }
;
    
+ Decoration 'tall leaves; green large'
    "They look like giant blades of grass. "    
    game551 = true
;


/* 148 */
saltMarshEdge: OutsideRoom 'At Edge of Salt Marsh'
    "{I} {am} at the edge of a trackless salt marsh.  Tall reeds obscure the view. "
    game551 = true
    
    south: VarDest, TravelConnector
    {
        calcDest
        {
            if (rand(100) <= 50)
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

MultiLoc, Decoration 'mud; salty'
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

/* 154 */
brokenRocks: OutsideRoom 'At Broken Rocks'
    "{I} {am} at a jumble of large broken rocks.  A gentle path leads up
    to the top of the nearby cliffs.  A narrow treacherous path
    disappears among the rocks at the foot of the cliff. "
    
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
   up = oceanVista
    south = sandyBeach
    building = atEndOfRoad
    
    listenDesc = "You hear the sound of the surf pounding against the
    beach and the broken rocks."

;

/* 155 */
oceanVista: OutsideRoom 'At Ocean Vista'
    "{I} {am} on a high cliff overlooking the sea.  Far below the
    rolling breakers smash into a jumble of large broken rocks.
    The thunder of the surf is deafening. "

    game551 = true
    
    
    down asExit(south)
    south = brokenRocks
    jump = cliffDemise1
    building = atEndOfRoad
    listenDesc = "You hear the sound of the surf pounding against the
    beach and the broken rocks."

;
/* 156 */
cliffDemise1: Room 'Bottom of Cliff'
    "{I}{'m} at the bottom of the cliff, smashed to smithereens
    by the pounding surf.<.p><<die()>>"   
;


/* 157 */

thunderHole: OutsideRoom 'At Thunder Hole'
    "{I} {am} at Thunder Hole, a funnel shaped cavern opening onto the
    sea. The noise of the surf pounding against the outer rocks of the cave is
    amplified by the peculiar shape of the cave, causing a thunder-like
    booming sound to reverberate throughout the cave.  Outside, a narrow
    path leads south towards some large rocks.  The cavern leads in to
    the east."
    
    game551 = true    

    isIndoors = true
    regions = [indoors, outdoors]
    
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

seaWater: MultiLoc, RoomLiquid 'sea water'
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
topOfSteps: OutsideRoom 'At Top of steps (behind Thunder Hole)'
    "{I} {am} at the top of some arched steps.  On the east side there
    is a blank wall with a tiny door at the base and a shelf overhead.  On
    the other side a westward passage leads to the sea. "
    
    isIndoors = true
    regions = [outdoors, indoors]
    
    game551 = true
    

    west = riverStyxE
    passage = riverStyxE
    steps = riverStyxE
    down asExit(west)
    
    out = thunderHole
//    phuce = {
//        local actor := getActor(&travelActor);
//        phuce_messages.smaller; 
//        actor.roomMoveTravel(&transmove,Ledge_By_Door);
//        // also move the objects on the other side of the door
//        roomMove(Grotto_West,Underground_Sea);
//        return ledgeByDoor;
//    }
    climb = "The wall is too smooth to climb. "
    up = climb
    ledge =  "The shelf is beyond {my} reach. "
    in asExit(east)
    east = "{I} can't fit through a six-inch door! "
    entrance asExit(east)
        
//    myhints = [Elfindoorhint]
    listendesc = "You hear a booming sound, caused by the surf pounding
    against the outer rocks of the cave. "
    // This property suppresses warnings about leaving the lamp on.
    nolampwarn = true
;


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


/* 227 */
riverStyxApproach: OutsideRoom 'At Approach to River Styx'
    "{I} {am} in a dimly lit E/W passage behind Thunder Hole.
    Etched into the rock wall are the ominous words: \n
    <i> \ \ \"You are approaching the River Styx.\ \ \ \ \ </i>n
    <i> \ \ Lasciate Ogni Speranza Voi Ch'Entrate.\"\ \ </i>"
    
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

/* 228 */
riverStyx: OutsideRoom '"At River Styx'
    "{I} {am} at the River Styx, a narrow little stream cutting directly
    across the passageway.  The edge of the stream is littered with sticks
    and other debris washed in by a recent rainfall.  On the far side
    of the river, the passage continues east."
    
    isIndoors = true
    regions = [indoors, outdoors]
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

/* 229 */
riverStyxE: OutsideRoom 'On East Side of River Styx'
    "{I}{'m} on the east side of the river's sticks. "
    
    jump = riverStyx
    west: TravelConnector -> riverStyx
    {
        travelDesc() { "\n(jumping the river)\n"; }
    }
    out asExit(west)
    across asExit(west)
    east = topOfSteps
;


beachShelf: OutsideRoom
;

beach: OutsideRoom
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
    
    game551 = true
    cannotEnterMsg = 'You\'ll have to tell me how to do that. '
    cannotBoardMsg = cannotEnterMsg
    decorationActions = [Examine, Enter, Board, GoTo]
;

/* 240 */
castlePinnacle: OutsideRoom 'On Castle Pinnacle'
    "{I} {am} on the highest pinnacle of the castle in the bay.
    Steps lead down into the garden. "
    game551 = true
    
    northeast = riseOverBay
    across asExit(northeast)
    cross asExit(northeast)
    smichel = riseOverBay
    down = castleSteps
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

class KaleidConnector: TravelConnector
    noteTraversal(actor)
    {
        actor.kaleid = nil;
        inherited(actor);
    }
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
        actor.kaleid = true;
        inherited(traveler, origin);
    }
   
    east = outerCourtyard
    southwest = livingMaze2
    west: KaleidConnector -> livingMaze3 {}
        
    northwest: KaleidConnector -> livingMaze5 {}
;

+ redBerries: Fixture, CanPick 'red berries'
    "They look very attractive, but they're probably deadly
        poisonous.  I'd leave them alone if I were you. "
    
    game551 = true
    
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
;

/* 244 */
livingMaze3: OutsideRoom '"In Living Maze (yellow leaves)'
    "{I} {am} in the center of the living maze. The plants here are
    dormant this season, but still carry brilliant yellow leaves. "
    
    game551 = true
    sdesc = "In Living Maze (yellow leaves)"
    
    east = livingMaze1
    
    south: KaleidConnector -> livingMaze2 {}
        
    west = livingMaze4
    north: KaleidConnector -> livingMaze5 {}
;

/* 245 */
livingMaze4: OutsideRoom 'In Living Maze (green leaves)'
    "Unlike the other areas of the hedge system, this area seems to
    have no metallic gleam; nevertheless it is still breathtaking.
    The trees and bushes are all variegated shades of green, the
    evergreens being a rich dark shade while the seasonal bushes
    are a lighter yellowish green, making a startling contrast. "
    
    game551 = true
    
    south: KaleidConnector -> livingMaze2 {}    
   
    east: KaleidConnector -> livingMaze3 {}
    
    north = livingMaze5
    
    west: KaleidConnector -> livingMaze6 {}    
;
    
/* 246 */
livingMaze5: OutsideRoom 'Near Edge of Maze (blueberries)'
    "{I} {am} near the edge of the maze. There are delicious-looking
    blueberries on the bushes.  {I}{'m} tempted to sample them! "
    
    game551 = true
    
    southeast  = livingMaze1
    
    south: KaleidConnector -> livingMaze4 {} 
    
    southwest = livingMaze6
;

+blue2: Fixture 'bluberries' // needs to be changed to the Blueberry class
;


/* 247 */
livingMaze6: OutsideRoom 'Western Edge of Maze (violets)'
    "{I} {am} at the western end of the living maze. Beside the
    shrubs forming the walls are tastefully planted beds of
    violets and brilliant purple pansies.
    To the west, through a small gate, is the inner garden."
    
    game551 = true
    

    southeast: KaleidConnector -> livingMaze2 {} 
    
    east: KaleidConnector -> livingMaze4 {} 
    
    northeat: KaleidConnector -> livingMaze5 {} 
   
    west  {
        local destno;
        local actor = gActor;
        if (actor.kaleid) return courtyardGate;
        else {
            // Open the gate for consistency
            if(! courtyardGate.isOpen) {
                "\n(first opening << courtyardGate.theName >>)\n)";
                courtyardGate.makeOpen(true);               
            }
            // Move the actor randomly to one of the first five rooms
            // of the maze
            "You get a tingling feeling as you walk through the gate,
            and ...\b"; 
            destno = rand(5) + 1;
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
    }
    gate asExit(west)
    in asExit(west)
;

courtyardGate: DSDoor 'gate; small' @livingMaze6 @innerCourtyard 
    "It's <<if isOpen>>open<<else>>closed<<end>>. "
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

+ livingTree: Distant 'living tree'
    "It's the most remarkable tree you've ever seen.
        Unfortunately there is no way to cross the hedge to get a closer look. "
    
    cannotClimbMsg = 'You might be able to climb this tree, but
        you can\'t cross the hedge to get to it. '
    
    decorationActions = [Examine, Climb, ClimbUp]
    
    notImportantMsg = 'Unfortunately, the tree is out of {my} reach on the far side of the hedge. '
;


+ nectar: Distant 'nectar'    
    "I've already told you all I know about it."    
;

castleWalls: MultiLoc, Decoration 'walls;stone stone-built (castle) built;wall;them it'
    "They enclose an octagonal area, and look like normal stone-built walls.  <<if gRoom ==
      outerCourtyard>>There is something odd about them, though - I can't
            see a door anywhere! <<end>>"
    noun = 'wall' 'walls'
    
    adjective = 'castle'
    locationList = [castlePinnacle, outerCourtyard]    
    
//    doCount(actor) = {"The walls form an octagonal shape - so there are
//        eight of them. ";}
;

hedges: MultiLoc, Decoration 'hedges and their leaves and flowers; multicolored multicoloured;
    hedge trees flowers violets pansies leaves maze garden; them it' 
    
    locationList = [
        outerCourtyard, livingMaze1, livingMaze2,
        livingMaze3, livingMaze4, livingMaze5, livingMaze6
    ]
//    doCount(actor) = {"You quickly give up the attempt to count the
//        multicolored hedges. ";}
;

castleRoom: OutsideRoom 'Octagonal Castle Room'
    "You're in an a large octagonal room with shiny white marble walls
    Doorways, each marked with a sign in Elvish, lead out in all compass directions.  "
    
    game551 = true
   
    
    isindoors = true
    regions = [indoors]
    
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





morion: Room 'Morion'
;


warmRoom: DarkRoom
;

inBalcony: DarkRoom
;