#charset "us-ascii"

#include <tads.h>
#include "advlite.h"

/* 
 *   This file contains locations and items that aren't needed in the 350, 550 or 551 point games
 *   but are referenced in other parts of the code. They may be moved and fully implemented once we
 *   come to implement other versions of the game, specifically the 701p game.
 */

/* 
 *   Although this item appears in the 551 and 550 points games, the TADS 2 port places it in the
 *   item11 file for 701 points games, so we do the same here.
 */
ringNote: Thing 'torn scrap of paper; small cryptic; message' @octagonalRoom
    desc()
    {
        "It's a small scrap of paper which seems to have been
        torn from a large piece.  The following cryptic message is
        written on it: \n\b";
        if (global.newgame) 
        {
            "C=1\n
            B=2\n
            G=3\n";            // copper, brass, gold rings
            if(global.game701)
                "M=3\n";       // mithril ring
            
        }
        else
            "H=3\n
            R=3\n";       // helmet, mithril ring
        "Total 3: basic protection. \n
        Total 6: retaliation. \n";
        if (global.game701) 
        {
            "Total 9: search and destroy. \b";
            // i.e. 3 points will protect you against the Dwarves' knives,
            // 6 will kill off the dwarves by sending the knives back.
            // 9 will destroy all dwarves after they try to attack you.
            if (global.game701p) 
            {
                if (!isRead)
                    "At first sight, the back of the paper appears to be
                    blank - until you notice that the bottom edge has
                    been folded over.  You unfold it, revealing the
                    words:\b ";
                else
                    "The back of the scrap also bears a message:\b ";
                "Pendant keywords: ANA, KATA, PHR...\n";
                "Unfortunately the bottom right hand corner is missing,
                so you can only see the first three letters of the third
                pendant keyword. ";
            }
        }
        isRead = true;
    }

    readDesc = desc
    
    isRead = nil
    game551 = true
    game550 = true
    mass = 0    
    
    location550 = vault
    location701 = octagonalRoom
;




swordPointNOfReservoir: DarkRoom
;


InSecretNSCanyon1: DarkRoom
;

debrisWest: Room 'Debris West'
;

greenTopOfSmallPit: Room 'Green Top of Small Pit'
;

blueTopOfSmallPit: Room 'Blue Top of Small Pit'
;

blueHallOfMists: Room 'Blue Hall of Mists'
;

blueEastBankOfFissure: Room
;

greenHallOfMists: Room 'Green Hall of Mists'
;
//
//atSwEnd: Room 'At SW End'
//;

blueBirdChamber: Room 'Blue Bird Chamber'
;    

greenUpperTransRoom: Room
    isdotroom = nil
;
 



tightCrack2: DarkRoom
;
elsewhere: Room;

tarnishedPendant: Thing;
dullPendant: Thing;
pendant2: Thing;
pendant: Thing;
manual: Thing
    isread = nil
;

transRoomDoor: Thing
    isunlocked = !isLocked
;
greenMaintenanceRoom: Room;
blueMaintenanceRoom: Room;
onLadder: DarkRoom;
machineChamber: Room;

rockfalls: Fixture
    ismoved = nil
;

octagonalRoom: Room

    NPCexits = []
;

blueBoard: Fixture 'blue board'
    isread = nil
;
