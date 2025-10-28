#charset "us-ascii"

#include <tads.h>
#include "advlite.h"

versionInfo: GameID
    IFID = 'ae41d2ae-c33a-4dec-afbe-f47547f82488'
    name = 'Polyadv'
    byline = 'by Eric Eve'
    htmlByline = 'by <a href="mailto:eric.eve@outlook.com">Eric Eve</a>'
    version = '1'
    authorEmail = 'Eric Eve <eric.eve@outlook.com>'
    desc = 'A TADS3/adv3Lite port of the TADS 2 port of polyadv, itself a multi-version port based
        on the Colossal Adventure game by Crowther and Woods.'
    htmlDesc = 'A TADS3/adv3Lite port of the TADS 2 port of polyadv, itself a multi-version port
        based on the Colossal Adventure game by Crowther and Woods.'
    
    showAbout()
    {
        "This is a work-in-progress attempt to port the TADS 2 polyadv game to TADS 3/advLite.
        Polyadv is in turn an implementation of the classic Crowther and Woods Colossal Adventure
        game together with several extensions to it. This TADS 3 port aims to reproduce the content
        of the originals while incorporating several player-friendly features such as the exit
        lister, pathfinding via the GO TO command, and a more helpful hint system (especially where
        the original game's puzzles are poorly clued or downright obscure).\b
        More information will be given here as the implementation progresses. ";
    }
    
    showCredit()
    {
        "The classic Adventure game on which this version is ultimate;ly based was by Don
        Woods and Willie Crowther. This TADS 3/adv3Lite version is based on the TADS 2 polyadv
        port by David M. Baggett, David J. Picton and Bennett J. Standeven. ";
    }
;

gameMain: GameMainDef 
    /* Define the initial player character; this is compulsory */
    initialPlayerChar = me
    
    showIntro()
    {
        "Somewhere nearby is Colossal Cave, where others have found
        fortunes in treasure and gold, though it is rumored that some
        who enter are never seen again.  Magic is said to work in the
        cave.  I will be your eyes and hands.  Direct me by typing
        simple commands in natural English.   Commands of one or two
        words, like \"west\" or \"take ingot\", may still be used, but
        I now understand more complex sentences like 
        \"put the large keys in suitcase\" or \"attack giant with
        long sword\".\b";
    }
    
    showGoodbye()
    {        
        "<.p>Come back and visit the newly remodelled and extended Colossal Cave soon! ";
    }

    
    /* This list will be updated from the appropriate VerGlob object. */
    scoreRanks = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    
    scoreRankTable = [        
        [scoreRanks[1], 'You are obviously a rank amateur.' ],
        [scoreRanks[2], 'Your score qualifies you as a Novice Class adventurer.' ],
        [scoreRanks[3], 'You have achieved the rating: <q>Experienced Adventurer</q>.' ],
        [scoreRanks[4], 'You may now consider yourself a <q>Seasoned Adventurer</q>.' ],
        [scoreRanks[5], 'You reached <q>Junior Master</q> status.' ],
        [scoreRanks[6], 'Your score puts you in Master Adventurer Class C.' ],
        [scoreRanks[7], 'Your score puts you in Master Adventurer Class B.' ],
        [scoreRanks[8], 'Your score puts you in Master Adventurer Class A.' ],
        [scoreRanks[9], 'All of Adventuredom gives tribute to you, Adventurer Grandmaster.' ]
    ]
;


/* 
 *   The player character object. This doesn't have to be called me, but me is a
 *   convenient name. If you change it to something else, rememember to change
 *   gameMain.initialPlayerChar accordingly.
 */


class BodyPart: Component
    cannotTakeMsg = '{1} already have {my} {dobj}. '
    
;

me: Player 'you' @atEndOfRoad 
    "{I} hope{s} {i} look{s/ed} the part of an intrepid adventurer. "
    
    itemcount = contents.countWhich({x:!x.isFixed})
    
    kickNoEffectMsg = '{I} {give} {myself} a good kicking, which {i} no doubt richly deserve{s/ed}. '
;

+ myHands: BodyPart '() your hands; bare my ;hand; them it'
     "Two of 'em.  Five fingers each. They look pretty normal to me! "    
    
    dobjFor(Wave)
    {
        preCond = []
        verify() { logicalRank(120); }
        action()
        {
            local loc = getOutermostRoom();
            if(loc.propDefined(&wavehands))
                loc.wavehands;
            else
                inherited();
        }
    }
    
    iobjFor(AttackWith) { verify() {} }
    
    iobjFor(PutIn)
    {       
        action()
        {
            doInstead(Take, gDobj);
        }
    }
    
    mass = 0 // my hands shouldn't contribute to the weight I'm carrying!
;


/* Suppress the notification of our initial points at game start */
modify scoreNotifySettingsItem
    isOn = (gTurns > 1)
    
;

