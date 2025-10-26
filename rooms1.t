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
    
    out = inHallOfMtKing
;


warmRoom: DarkRoom
;

inBalcony: DarkRoom
;