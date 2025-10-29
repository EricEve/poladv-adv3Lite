#charset "us-ascii"

#include <tads.h>
#include "advlite.h"

/* 108 */
sack: BagOfHolding, OpenableContainer 'leather sack' @insideBuilding    
        "It's a capacious leather sack, large enough to
        hold most objects.  "
        
    game551 = true
    
    openStatusReportable = UsePronoun
    
    affinityFor(obj)
    {
        if(obj.isLong || obj.isLarge || obj.isHuge || 
           (obj.ofKind(wickerCage) && obj.contents.length > 0))
            return 0;
        
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