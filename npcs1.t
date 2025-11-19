#charset "us-ascii"
#include "advlite.h"



/* The class Chaser is used for things like the Wumpus, blob, etc. that
   follow the player relentlessly. The variable "chase" indicates the
   creature's distance from the player, and is incremented by "moveinc"
   each turn the creature is active. If the player did not move, it is
   further incremented by "stayinc". The variable "ischasing" indicates
   that the creature is on the move. The routine MagicMsg is called
   when the player tries to use a magic word to escape. The routine
   "ChaseMsg" is called each turn to print messages, kill the player,
   or do other tasks that vary from one Chaser to another. The
   "backtrackAct" routine is called when the player returns to the
   previous location. Finally, the "banish" routine sends the Chaser
   away. */
class Chaser: Actor
    isChasing = nil    // Until it is set off by something.

    chase = -1  // Should increase with time in the move routine.
    chasehold = 0 // Set nonzero if the chase level is to be held for
                  // a few turns
    moveinc = 1 // Value by which chase should increase
    stayinc = 0 // Extra chase increment if player stays in same room
    locstay = 1
    
    move 
    {
        local oldloc,newloc,backtrack = nil;
        oldloc = location;
        if(chasehold > 0)
            chasehold--;
        else
            chase += moveinc;
        if(chase < 1) 
        {
            // initialize some variables
            gPlayerChar.reflexmove = nil; // see below
            locstay = 0;    // for comments
            return;
        }
        newloc = gRoom;
        if((newloc == insideBuilding && oldloc == atY2) ||
        (newloc == inPloverRoom && oldloc == atY2) ||
        (newloc == insideBuilding && oldloc == inDebrisRoom) ||
        (newloc == volcanoPlatform && oldloc == fakeY2) ||
        (newloc == fakeY2 && oldloc == volcanoPlatform)) magicMsg;
        // should explain why chaser follows, or does not. Be
        // sure to include all possible cases here...

        if((newloc == rainbowRoom && oldloc == insideBuilding))
            slippMsg;
        // self.locstay counts the turns at this location
        // parserGetMe().reflexmove indicates that the player has travelled 
        // through a looping passage to the same room.
        if(newloc != oldloc || gPlayerChar.reflexmove) locstay = 1;
        // Note: parserGetMe().moveInto sets self.locstay to 0 if you use a passage
        // which takes you back to the same room - the chaser is
        // presumed to have chased you along the same passage.
        else locstay += 1;
        // detect backtracking, i.e. you've gone to the previous
        // location, and you've used the same route and not used
        // a magic word or a passage going back to the same room
        // travel routes are:
        // 0 (default)
        // 1,2,3 (alternative routes e.g. low wide passage in west
        // half of Hall of Mists)
        // 10 (magic)
        // 11 (reflexive - a passage going back to the same room)
        if(newloc == prevloc &&
        gPlayerChar.previousRoute == gPlayerChar.travelRoute
        && (gPlayerChar.travelRoute < 10))
            backtrack = true;
        // move into the new location if appropriate
        if(newloc != location || gPlayerChar.reflexmove)
            actionMoveInto(newloc);
        // clear the reflexmove property
        gPlayerChar.reflexmove = nil;
        // increment chase variable if we haven't moved
        if(locstay > 1) chase += stayinc;
        // act on backtracking
        if (backtrack) backtrackAct;
        // do the rest
        chaseMsg; // Explain motion, kill player, etc.
    }
    banish()
    { // Put the Chaser back to bed
        moveInto(nil);
        prevloc = nil;
        isChasing = nil;
        chase = -1;
        if(myDaemon)
        {
            myDaemon.removeEvent();        
            myDaemon = nil;
        }
    }
    summon(loc = gRoom)
    { // Summon the Chaser.  This is a variable-argument
                    // method which will place the chaser in some default
                    // location if no argument is given; if an argument
                    // is given, it specifies the initial location of
                    // the chaser.  If this routine is called in
                    // a travel method, the argument should be the
                    // player's destination, not the current location.
        
        moveInto(loc);
        
        isChasing = true;
        prevloc = nil;  // needed to avoid false BackTrack calls
        myDaemon = new Daemon(self, &move, 1); 
    }
    
    myDaemon = nil
    chaseMsg = "You are being pursued by <<theName>>. "
    magicMsg = "Magic!"
    slippMsg = nil
    backtrackAct() {}
;

wumpus: Feedable, Chaser 'Wumpus; large hairy huge sleeping ;monster creature' @cloakroom   
    desc
    {
        if(isAsleep) 
        {
            "He's a huge, hairy creature, renowned for his appetite for
            Adventurers.  Whatever you do, don't wake him!   He can
            outrun the fastest humans, and despite his size can squeeze
            through the narrowest passages!  Even magic words won't
            help you to escape, because the Wumpus is good at imitating
            them!";
            if (cloakPit1.seen && cloakPit2.seen && cloakPit3.seen) 
            {
                P();
                "Something occurs to you.  Two of the Featureless Pits
                contained a ring, but someone seems to have visited
                the south pit before you.  Someone with very large
                feet.  Unfortunately the position in which the Wumpus
                is lying prevents you from seeing whether he has the
                missing ring. ";
            }
        }
        else if (!isDead) 
        {
            "He's a huge, hairy creature, renowned for his appetite for
            Adventurers like you.  You're in desperate trouble now that
            you've woken him,  and no-one has found a way to outrun him,
            even using magic words. ";
        }
        else 
            "He's not a pretty sight now. ";        
    }
    
    initSpecialDesc = "In the corner, a Wumpus is sleeping peacefully. "
    useInitSpecialDesc = isAsleep
    specialDesc = "Nearby is the smashed body of a defunct Wumpus. "
    useSpecialDesc = isDead
    
    proper = nil
    isAsleep = true   
    isDead = nil
    isChasing = nil
    
    moveinc = 1
    stayinc = 1
    
    deadmess = 'For crying out loud, the poor thing is dead! '
    ridicule = '''Don't be ridiculous! '''
    
     // ATTACKING
    dobjFor(Attack)
    {
        verify()
        {
            if(isDead)
                illogicalAlready(deadmess);
            
            else if(gActor.allContents.indexWhich({o: o.ofKind(Weapon) && gActor.canReach(o)}) == nil)
                illogical(ridicule);
        }
        
        action()
        {
            local weapon = gActor.allContents.valWhich({o: o.ofKind(Weapon) && gActor.canReach(o)});
            "\n(with <<weapon.theName>>)\n";
            doInstead(AttackWith, self, weapon);                
        }
    }
    
    dobjFor(AttackWith)
    {
        verify()
        {
             if(isDead)
                illogicalAlready(deadmess);            
        }
        action()
        {
            
        }
        
    }
    
    
;





bees: Feedable, Fixture 'bees;;;them'
    
    arefed = nil
;





dog: NPC 'dog'
    isAsleep = nil
    sleepLie() {}
    blockMessage = "The dog won't let you pass! " // temporary
;
