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

wumpus: Feedable, Chaser 'Wumpus; large hairy huge sleeping ;monster creature; him' @cloakroom   
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
    searchedonce = nil
    upset = nil
    
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
            {
                //
                // If the player throws the axe at the sleeping Wumpus, the
                // axe misses and becomes inaccessible.  (Doh!)
                
                if (gIobj == axe && isAsleep) {
                    if (gVerbWord != 'throw')
                        "\n(throwing the axe)\n";            
                    "You can't even hit a sleeping Wumpus!  It wasn't your
                    fault, though; your axe was well aimed, but
                    it swerved away from the Wumpus as if deflected by a strong
                    magnetic field!  The axe is now lying on the far side
                    of the Wumpus, and you'd be trapped if he woke up while
                    you were retrieving it.";
                    axe.moveInto(location);
                    axe.nograb = true;
                }
                // An even worse outcome is in store if the Wumpus is
                // awake ...
                else if(gIobj == axe) 
                {
                    if (gVerbWord != 'throw')
                        "\n(throwing the axe)\n";            
                    "The Wumpus grabs the axe, stops and picks his teeth with
                    it for a few moments while looking thoughtfully at you.
                    When he finishes picking his teeth, he eats the axe,
                    belches, farts... and starts after you again!";
                    axe.moveInto(nil);
                    // N.B. in this port the axe will reappear when the player next
                    // encounters a dwarf!  We could call it a bug, but I'll choose
                    // to regard it as a feature - DJP.
                }
                else if(gIobj == sword) 
                {
                    if (gVerbWord != 'throw')
                        "\n(throwing the sword)\n";            
                    sword.throwsmash;
                }
                else if (gIobj == singingSword) 
                {
                    if (gVerbWord != 'throw')
                        "\n(throwing the sword)\n";
                    
                    if (location == onLadder) 
                    {
                        "The sword misses, bounces off the wall of the shaft, and
                        lands in the room below. ";
                        singingSword.moveInto(cloakPits);
                    }
                    else {
                        "The sword misses, bounces off the wall, and
                        lands at your feet. ";
                        singingSword.moveInto(location);
                    }
                }
                else if(gIobj == myHands) ridicule;
                else if(isAsleep) doInstead(Wake, self);
                else "Somehow I doubt that'll be very effective. ";
            }            
        }        
    }
    
    // THROWING
    iobjFor(ThrowAt)
    {
        verify()
        {
            if(isDead)
                illogicalNow(deadmess);
            else
                inherited();
        }
        action()
        {
            if(gDobj.ofKind(Food))
                doInstead(GiveTo, gDobj, self);
            else if(gDobj.ofKind(Weapon)) 
                doInstead(AttackWith, self, gDobj);    
            
            else inherited();
        }
    }
    
    iobjFor(ThrowTo)
    {
        verify()
        {
            if(isDead)
            {
                illogicalNow('There\'s no point in throwing anything to a dead Wumpus! ');
            }
            
        }
        action()
        {
            if(gDobj.ofKind(Weapon))
                doInstead(ThrowAt, gDobj, self);
            else
                doInstead(GiveTo, gDobj, self);
        }
    }
    
    // GIVING
    iobjFor(GiveTo)
    {
        verify()
        {
            if(isAsleep)
                illogicalNow('''You can't do that while he's asleep! ''');
            else if(isDead)
                illogicalNow(deadmess);
        }
        
        action()
        {
            if(gDobj.ofKind(ContLiquid) && gDobj.myflag is in (&hasWater, &hasWine))
                doInstead(FeedWith, self, gDobj);
            else if(gDobj.ofKind(Food))
                doInstead(FeedWith, self, gDobj);
            else
                "The Wumpus isn't very interested in {the dobj}. ";        
        }
    }   
    
    // FEEDING
    dobjFor(Feed)
    {
        verify()
        {
            if(isAsleep)
                illogicalNow('''You can't feed the Wumpus without waking him, and that
                    would be a very bad idea. ''');
            else if(isDead)
                illogicalNow('Dead Wumpi, as a rule, are light eaters.  Nothing happens. ');
            else
                inherited();
        }
        action()
        {
            /* First see if there's an edible and reachable item in the player's inventory */
            local food = gPlayerChar.allContents.valWhich({f: f.isEdible &&
                gPlayerChar.canReach(f)});
            
            /* If not, see if there's a reachable edible item in the room. */
            if(food == nil)
                food = getOutermostRoom.allContents.valWhich({f: f.isEdible &&
                gPlayerChar.canReach(f)});
            if(food != nil)
            {
                "\n(trying <<food.theName>>)\n";
                doInstead(FeedWith, self, food);
            }
            else
                "There is nothing here that the Wumpus would want to
                  eat, except *YOU*!";
        }
    }
    
    dobjFor(FeedWith)
    {
        verify() { verifyDobjFeed(); }
        action()
        {
            if(gIobj.ofKind(Food))
                "The Wumpus looks at {the iobj} with distaste.  He
                 looks at *YOU* with relish!";
            else
                inherited();
        }
    }
    
     // OTHER (actor, verb; wake; Chaser methods)
    
    dobjFor(Rub)
    {
        verify()
        {
            if(!isDead && !isAsleep)
                illogicalNow(ridicule);
            else
                inherited();            
        }
        action = "You carefully rub the Wumpus.  He remains fast asleep. "               
    }
    
    handleCommand(action)
    {
        if(isAsleep)
            "He won't be doing anything while he's asleep! ";
        else if (isDead)
            say(deadmess);
        else
            inherited(action);
    }
    
    dobjFor(Wake)
    {
        verify()
        {
            if(!isAsleep)
                illogicalAlready('''He's not asleep. ''');
            else if(isDead)
                illogicalNow(deadmess);
        }
        action()        
        {
            if(getOutermostRoom.isIlluminated)
                "You turkey!!!  Now you've done it!  It took some effort, but you
                woke up the Wumpus.  He slowly opens one red eye, and then another,
                and then one more (!!), and looks at you sleepily. ";              
            else 
                "You hear the sound of someone -- something -- stirring.  You
                fool!  I think you've woken the Wumpus. ";
            
            "He had been dreaming of a late snack.  If you don't act quickly, you'll
            be a *late* adventurer! ";
            summon();            
        }
    }
    
    dobjFor(LookIn)
    {
        verify()
        {
            if(!isDead)
                illogicalNow('Getting so close to a live Wumpus is far too dangerous. ');           
        }
        check()
        {
            
            if(!global.game701p)
                "The Wumpus is not a pretty sight, and an overwhelming feeling
                of revulsion prevents you from searching his body. ";
        }
        action()
        {
            if(!searchedonce)
            {
                "The Wumpus is not a pretty sight, ";
                if(goldRing.moved)
                    "but you suspect";                
                else
                    "but you realize -- in a 
                    flash of intuition which also gives you a strange sense of
                    foreboding -- ";
                
                " that he may be hiding something important. You therefore overcome 
                your squeamishness, and thoroughly search him for hidden possessions";                       
            }
            if(global.game701p)
            {
                if(!searchedonce)
                    ". ";
                inherited();
            }
            else
            {
                if (searchedonce)
                    ", but you ";
                else
                    "You ";
                "find nothing of interest. ";
            }
            searchedonce = true;
        }
    }
    summon(loc)
    {
        isAsleep = nil;
        // Resurrect the Wumpus for the Summon command
        if(isDead) 
        {
            isDead = nil;
            removeVocabWord('body', MatchNoun);
            removeVocabWord('dead', MatchAdj);
            removeVocabWord('defunct', MatchAdj);
           
            if (!goldRing.moved) {
                    goldRing.moveInto(nil);
                    goldRing.moved = nil;
            }
        }
        removeVocabWord('sleeping', MatchAdj);
        
        isChasing = true;
        if (loc)
            actionMoveInto(loc);
        prevloc = nil;  // needed to avoid false backtrackAct calls
        moveDaemon = new Daemon(self, &move, 0);
    }
    moveDaemon = nil
    
    magicMsg = "Something catches the corner of your eye.  To your horror,
        you realize that the Wumpus has materialized right
        behind you!  Evidently he's good at imitating magic words --
        in fact, he probably knows them all. "

    slippMsg()
    {        
        "<.p>As you clicked your heels, the Wumpus did the same.  He
        has no slippers, so he shouldn't -- ";
        
        "<.p>Sorry.  The Wumpus is right behind you!  He's now so close that
        you notice a small detail which eluded you until now.  He is wearing
        a gold ring.  As you may already have realized, many of the rings
        you may find in the cave have magic powers... ";
        goldRing.deducedmagic = true;      
        
        // give the player a hint for free if he's been trying this
        // hard to escape the Wumpus. (proven changed to proved in 
        // accordance with British preferences)
        "<.p>You've proved conclusively that you can't simply use magic to
        escape from the Wumpus, so you'll need to try another tack.  Maybe
        there's another way to use magic against him.  With the aid of a little
        low cunning, you might be able to set a little trap ... ";
    }
    
    backtrackAct()
    {        
        "<.p>You fool!  You've run straight into the Wumpus ....";
        chase = 9;
    }
    chaseMsg() 
    { 
        
        if (isIn(octagonalRoom) && transRoomDoor.isIn(location) && !upset) 
        {
            upset = true;
            "I've never known the Wumpus to be concerned with anything but
            his next meal, but something seems to be distracting his attention
            here.  For some reason he seems to be unhappy about your 
            discovery of the door.  I wonder if he knows something about it?<.p> ";
            
            chase = 3;
            chasehold = 4;
        }
        switch (chase) 
        {
          default: break;
          case 1: case 2:
            "A sleepy Wumpus is ambling towards you.  He wants to invite
            you to dinner.  He wants you to *be* the dinner!"; break;
          case 3: case 4:
            "The Wumpus is still on your trail!  And he's getting
            closer!!"; break;
          case 5: case 6:
            "The Wumpus is only a few steps behind you!  All this exercise
            is making him veerrrrry hungry!"; break;
          case 7: case 8:
            "The Wumpus almost has you in his grasp!  You can feel his hot
            breath on your neck!"; break;
          case 9: case 10:
            " <q>Chomp, chomp.</q>  Crunch!  Chew!  Slurp!  Smack!  Yum!!!";
            break;
        }
        if(chase >= 9) {
            die(); // die routine puts Wumpus back asleep
        }
    }
    
    banish()
    { // Put the Wumpus back to bed
        wumpus.moveInto(cloakroom);
        wumpus.prevloc = nil;
        wumpus.isAsleep = true;
        addVocabWord('sleeping', MatchAdj);
        wumpus.isChasing = nil;
        wumpus.chase = -1;
        if(moveDaemon)
            moveDaemon.removeEvent();        
    }
    demise()
    {
         // The end of the Wumpus        
        "<.p>As the bridge disappears, the Wumpus scrambles frantically to
        reach your side of the fissure.  He misses by inches, and with a
        horrible shriek plunges to his death in the depths of the
        fissure! ";
        actionMoveInto(lostCanyonEnd);
        goldRing.moveInto(lostCanyonEnd);
        goldRing.moved = nil;
        chase = -1;
        isChasing = nil;
        isAsleep = nil;
        isDead = true;
        addVocabWord('dead', MatchAdj);
        addVocabWord('defunct', MatchAdj);
        addVocabWord('body', MatchNoun);        
        prevloc = nil;
        if(axe.nograb && axe.isIn(cloakroom))axe.nograb = nil;
        if(moveDaemon)
            moveDaemon.removeEvent();            
    }
    
    iobjFor(PutOn)
    {
        verify()
        {
            if(!isDead)
                illogicalNow(ridicule);                
        }
        action()
        {
            if (dobj == goldRing) 
            {
                "You put the ring back on the Wumpus' finger. ";
                goldRing.moveInto(self.location);
                goldRing.moved = nil;
            }
            else 
                "In general, I don't see the point of trying to put things onto a Wumpus. ";
        }       
    }  
;

bees: Feedable, Fixture 'bees;;swarm;them' @flowerRoom
    desc
    {
        if(!arefed) "The bees swarm protectively around the hive. ";
        else "The bees are swarming around the fresh flowers. ";
    }
       
    arefed = nil
    
    // ATTACK
    dobjFor(Attack) { verify() { illogical('That would only enrage the bees! '); }}
    verifyDobjAttackWith() { verifyDobjAttack(); }    
    
    // KICKING
    verifyDobjKick() { verifyDobjAttack(); }
    
    // THROWING
    iobjFor(ThrowAt) asIobjFor(GiveTo)
    iobjFor(ThrowTo) asIobjFor(GiveTo)
    
    // FEEDING
    dobjFor(Feed)
    {
        verify()
        {
            if(arefed)
                illogicalAlready('You\'ve already fed the bees. ');       
        }       
        action() {askForIobj(FeedWith); }
    }
    
    dobjFor(FeedWith)
    {
        verify() { verifyDobjFeed(); } 
        action()
        {
            if (gIobj == flowers) 
            {
                if(tryImplicitAction(Take, flowers))
                {
                    "The bees swarm over the fresh flowers, leaving the hive
                    unguarded and revealing a sweet honeycomb.";
                    flowers.moveInto(location);
                    arefed = true;
                    honeycomb.moveInto(hive);
                }
            }
            else 
                inherited();
        }
    }
    
    // OTHER (verb defaults)
    verifyDobjRub { illogical('''Don't be ridiculous. ''');}
    
    checkReach(actor)
    {
        "The hum of the bees rises to an angry buzz as you move
        towards the <<if arefed>> flowers<<else>> hive<<end>>. ";
    }    
;


dog: Feedable, Actor 'hideous dog; large black; hound' @riverStyxApproach
    "The hideous black dog looks like a hound from Hell.  Calling
    him a <q>nice doggie</q> would be a big mistake. <<if isAsleep>>        
    However, he's now fast asleep. You'd best let sleeping dogs lie.<<end>> "
     
    specialDesc()
    {        
        if (isAsleep)
            "Nearby, a large black dog is in a deep slumber. ";            
        else
            "A hideous black dog bares his teeth and growls at your
            approach.";
    }
    
    sleeplie = 'You\'d better let sleeping dogs lie. '    
    isAsleep = nil
    
    // ATTACKING
    suicide = 'Trying to attack this dog would be tantamount to suicide.
        {I} might be able to calm him down, though. '
   
    dobjFor(Attack)
    {
        verify()
        {
            if(isAsleep)
                illogicalNow(sleeplie);
            else if(gActor.allContents.indexWhich({w: w.ofKind(Weapon) && gActor.canReach(w)}) == nil)
                verifyDobjKick();
        }
        
        action()
        {
            local weapon = gActor.allContents.valWhich({w: w.ofKind(Weapon) && gActor.canReach(w)});
            if(weapon)
            {
                "\n(with <<weapon.theName>>)\n";
                doInstead(AttackWith, self, weapon);
            }
            else actionDobjKick();
        }       
    }
    
    dobjFor(AttackWith)
    {
        verify() 
        { 
            if(isAsleep)
                illogicalNow(sleeplie);
        }
        action()
        {
            //
            // If the player throws the axe at the dog, the
            // axe misses and becomes inaccessible.  (Doh!)
            if (gIobj == axe) {
                if (gVerbWord != 'throw')
                    "\n(throwing the axe)\n";
                
                "The axe misses and lands near the dog where
                you can't get at it.";
                
                axe.actionMoveInto(location);
                axe.nograb = true;         // little hack
            }
            else if (gIobj == sword) {
                if(gVerbWord != 'throw')
                    "\n(throwing the sword)\n";            
                sword.throwsmash;
            }
            else if (gIobj == singingSword) {
                if(gVerbWord != 'throw')
                    "\n(throwing the sword)\n";
                "The sword misses, bounces off the wall, and
                lands at your feet. ";
                singingSword.actionMoveInto(location);
            }
            else say(suicide);            
        }        
    }
    
    // KICKING
    dobjFor(Kick)
    {
        verify()
        {
            if(isAsleep)
                illogicalNow(sleeplie);
            else
                illogical(suicide);                
        }
        action() {}
    }
     
    // THROWING
    iobjFor(ThrowAt)
    {
        verify() {}
        check()
        {
            if(isAsleep)
                say(sleeplie);
        }
        action()
        {
            if(gDobj.isEdible)
                doInstead(GiveTo, gDobj, self);
            else if(gDobj.ofKind(Weapon))
                doInstead(AttackWith, self, gDobj);
            else
                inherited();          
        }
    }
   
    iobjFor(ThrowTo)
    {
        verify() { verifyIobj(GiveTo); }
        action()
        {
            if(gDobj.ofKind(Weapon))
                doInstead(AttackWith, self, gDobj);
            else
                doInstead(GiveTo, gDobj, self);
            
        }
    }
    
    // GIVING
    iobjFor(GiveTo)
    {
        verify()
        {
            if(isAsleep)
                illogicalNow(sleeplie);
        }
        action
        {
            if(gDobj.ofKind(ContLiquid) && gDobj.myflag is in (&hasWater, &hasWine))
                doInstead(FeedWith, self, gDobj);
            else if(gDobj.isEdible)
                doInstead(FeedWith, self, gDobj);
            else
                "The dog isn't very interested in {the dobj}. " ;               
        }        
    }
    
    // FEEDING
    dobjFor(Feed)
    {
        verify()
        {
            if(isAsleep)
                illogicalNow(sleeplie);
            else
                inherited();
        }
        action()
        {
            local food = gActor.getOutermostRoom.allContents({f: f.isEdible &&
                gActor.canReach(f)});
            
            /* don't feed the mushrooms automatically */
            if(food == mushrooms)
               askForIobjX(FeedWith);
            else if(food)
            {
                "\n(with <<food.theName>>)\n";
                doInstead(FeedWith, self, food);
            }
            else
                "{I} {have} nothing the dog wants to eat. ";
        }        
    }
    
    dobjFor(FeedWith)
    {
        verify() { verifyDobjFeed(); }
        action()
        {
            if (gIobj == mushrooms) {
                if(tryImplicitAction(Take, mushroom)) {
                    "The dog wolfs (natch) down the mushrooms.  Then it
                    starts to grow larger!  Within a few seconds, it
                    towers over you, almost filling the chamber.
                    Unfortunately, you don't manage to get away before the
                    dog makes *YOU* part of its meal.";
                    gIobj.moveInto(nil);
                    new Fuse (mushrooms,&regrow,mushrooms.growtime);
                    die();
                }
            }
            // cakes need not be considered (dog must be asleep)
            else if (gIobj.isEdible)
            {
                if(tryImplicitAction(Take, gIobj)) 
                {
                    "The dog wolfs (natch) down {the iobj} and looks
                    around hungrily for more.  However, he does not appear
                    to be any better disposed towards your presence.";
                    gIobj.moveInto(nil);
                    if(gIobj == mushroom)
                        new Fuse (mushroom,&regrow,mushroom.growtime);
                }
            }
            else
                inherited();
        }
    }
    
    // OTHER
    verifyDobjRub()  
    {
        if (isAsleep) 
            illogical(sleeplie);
        else 
            illogical('Trying to pet the dog would be suicidal! ');
    }    
    
    verifyDobjWake()
    {
        if(isAsleep)
            illogicalNow(sleeplie);
        else
            inherited();
            
    }
   
    handleCommand(action)
    {
        if(isAsleep)
            say(sleeplie);
        else if(action == stayVerb)
            stay();
        else
            inherited(action);
    }
    
    stay()
    {
        if(isAsleep) 
             "He's fast asleep, so he's unlikely to do anything but stay where
             he is. ";
        else
             "The dog stays where he is.  Perhaps because he didn't have any 
             intentions of moving in the first place! ";
        
    }
    
    
    blockMessage = "The dog won't let you pass! " // temporary
;

/* Dummy object */
elf: Actor 'tiny elf'
    
;
