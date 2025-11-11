#charset "us-ascii"

#include <tads.h>
#include "advlite.h"

/* 
 *   This file contains locations that aren't needed in the 300 point game but are referenced in
 *   other parts of the code. They may be moved and fully implemented once we come to implement
 *   other versions of the game.
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




corrDivis: Room 'Corr Divis'
;

corridor1: Room 'Corridor 1'
;

vault: Room 'Vault'
;

 
coralPassage: DarkRoom
;

coralPass2: DarkRoom
;

sandstoneChamber: DarkRoom 'Sandstone Chamber'
;
 

S_Of_Center: Room
;

tightCrack2: DarkRoom
;

volcanoPlatform: Room 'Volcano Platform';


catacombs: Room 'Catacombs'
    roomNumber = 0
    leaveRoom() {}
    enterRoom() {}
    
;

elsewhere: Room;

fakeY2: Room 'At Y2 (fake)';