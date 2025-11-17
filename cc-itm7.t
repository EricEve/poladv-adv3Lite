#charset "us-ascii"

#include <tads.h>
#include "advlite.h"

card: Thing 'plastic ID card; white small rectangular of [prep]' @toolRoom
    "Gee, this is interesting.  This seems to be an I.D. card of some
    sort.  On the front are the initials R.W. and the number 10001,
    and there is some kind of black strip running along the back. "
   
    initSpecialDesc =  "Over in one corner is a small rectangular piece of white plastic. "
;

disk: Treasure 'floppy disk; 8-inch;source adventure label' @computerRoom
    "Scrawled on the the disk's label in a nearly illegible handwriting
             are the words <q>Adventure Source Files</q>."    
    initSpecialDesc = "Taped to the front of the computer is an 8-inch floppy disk. "  
    readDesc = "The disk label says <q>ADVENTURE SOURCE FILES<q>; the disk itself is
             unreadable without a floppy disk drive, and I don't see any of
             those here. "    
;

poster_coll: MultiLoc, Thing 'poster'  
    desc
    {
        switch(rand(9) + 1)
        {
            case 1: "One is a small poster of Albert Einstein. "; break;
            case 2: "One is a small poster of a cat. "; break;
            case 3: "One is a large poster of a cat. "; break;            
            case 4: "One poster is a two foot high nude centerfold. "; break;
            case 5: "One poster is a five foot high nude centerfold. "; break;
            case 6: "One is a three foot square poster of Mr. Spock."; break;
            case 7: "One is a poster of a mountain climber. "; break;
            case 8: "One is an eight foot wide poster showing an
                airplane flying over the Golden Gate bridge. "; break;
            case 9: "One of the posters is a seven foot high, 
                 twenty foot long, three hundred and sixty degree
                 view of Mars taken from the Viking lander. "; 
                break; 
        }       
    }
    game580 = true
    
    isListed = nil // 
    
    
    actionDobjTake()
    {   
        switch(rand(9)+ 1)
        {
            case 1: "You carefully take a small poster of Albert Einstein
                off the wall. "; break;
            case 2: "You carefully take down a small poster of a cat. "; break;
            case 3: "You carefully take down a large poster of a cat. "; break;            
            case 4: "You carefully take down a two foot high nude centerfold poster. "; break;            
            case 5: "You carefully remove from the wall a five foot high
                nude centerfold poster. "; break;
            case 6: "You carefully take a three foot square poster of Mr.
                Spock from the wall."; break;
            case 7: "You carefully take down a poster of a mountain climber. "; break;
            case 8: "You very carefully take down an eight foot wide poster
                showing an airplane flying over the Golden Gate bridge. "; 
            break;
            case 9: "With extreme difficulty, you take down from the wall
                a seven foot high, twenty foot long, three hundred and
                sixty degree view of Mars taken from the Viking lander. "; 
            break; 
        }       
        "\b";
        if(rand(100) < 5)
        {
            "Unfortunately, you ripped one corner of the poster when you
            took it down.  The poster bursts into a ball of flame,
            incinerating you in the process. ";
            die();
        }
        if(global.closed || global.triggered_alert)
        {} // do nothing, because a security alert has already been
        // triggered or the elevator is already locked.
        else
        {
            local delay = 2;            
            "<i>bong</i>\t\t\t\t\t\tThe very air quivers with sound as though\n";
            "\ \ <i>bong</i>\t\t\t\t\tsomeone, somewhere in the distance, has 
            struck\n";
            "\t\ <i>bong</i>\t\t\t\t\tthree powerful blows on an immense brass 
            gong.\b";
            
            "From an overhead speaker an extremely loud mechanical voice says,
            <q>This is a Class 1 security alarm.  All computer center security 
            forces go to Purple Alert. I repeat - Purple Alert.</q>\b"; 
            
            // Add flag so that we can test whether an alert has been issued,
            // before the blob summoning code is executed.  This flag is reset
            // in the die() routine.
            global.triggered_alert = true;
            
            // stop the player from leaving via the elevator, if the button
            // has already been pressed.
            if((location = elevator580.location) && (elevator580.isOpen))
                delay = 1; 
            
            
            new Fuse(blob, &summon, delay); // summon blob, will close and 
            // lock elevator.
        }
        "The poster in your hands disintegrates into fine dust and blows 
        away. ";
        
    }
    
    initialLocationList = [sOfCenter, nOfCenter]
    
;

cups: Thing 'suction cups; of[prep];set;them' @toolRoom
    "It looks like an ordinary set of suction cups. "
     game580 = true
    
    canTakeWithMe = true
    canMoveWithMe = true
    canOpenWithMe = true    
;

stamp: Treasure 'rare stamps; priceless of[prep];assortment; them' @desk
    "It is an assortment of rare stamps. " 
    
     initSpecialDesc = "Resting on the desk are several priceless rare stamps! "
//    location = Study
;