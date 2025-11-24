#charset "us-ascii"

#include <tads.h>
#include "advlite.h"

/* 
 *   This file contains locations that aren't needed in the 350, 550 or 551 point games but are
 *   referenced in other parts of the code. They may be moved and fully implemented once we come to
 *   implement other versions of the game, specifically the 701p game.
 */




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

atSwEnd: Room 'At SW End'
;

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
