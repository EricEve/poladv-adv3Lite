#charset "us-ascii"

#include <tads.h>
#include "advlite.h"

initNPC()
{
    local   o;    //
    // Construct list of NPC exits for each room
    //
    o = firstObj(Room);
    while (o != nil) 
    {
        if (!o.noNPCs) 
        {  
            //
            // Add this room to the global list of rooms
            // the NPC's can be in.
            //
            global.NPCrooms = global.NPCrooms + o;
            do_exitlist(o);
            do_npclist(o);
        }
        else if (global.debug) 
        {
            //
            // Debugging info:
            //
            "\b\"<< o.theName >>\" is off limits to NPC's.";
        }

        o = nextObj(o, Room);
    }
}

do_exitlist(o) {}
do_npclist(o) {}

modify Actor
    locationHistoryLength = 2  
     handleCommand(action)
    {
        local obj = self;
        gMessageParams(obj);
        "{The subj obj} {has} better things to do. ";
    }

    nextRoute = 0
    dobjFor(Rub)
    {
        verify()
        {
            illogical(notCareForMsg);
        }        
    }
    notCareForMsg = 'I {don\'t think} {the dobj} would care for that. '
;


class NPC: Actor
    iobjFor(GiveTo)
    {
        verify() { }        
    }
    place() {}
    move() {}
    
;



class Feedable: object
    dobjFor(Feed)
    {
        preCond = [objVisible]
        verify {}
        
    }
;

snake: Feedable, Actor 'snake;huge fierce green venemous ferocious large big killer
    ;cobra asp' @inHallOfMtKing
    "I wouldn't mess with it if I were you. "    
    
    specialDesc = "A huge green fierce snake bars the way! "
    
    dobjFor(Attack)
    {
        verify(){}
        check() {}
        action() 
        {
            "Attacking the snake both doesn't work and is very dangerous. ";
        }
    }
    
    dobjFor(Kick)
    {
        verify(){}        
        check() 
        {
            "That would be satisfying, but totally insane. ";
        }
    }

    cannotTakeMsg = 'Surely you\'re joking. '
    
    dobjFor(Rub)
    {
        verify()
        {
            illogical('I don\t think {the dobj} would care for that. ');
        }
    }
;


bear: Feedable, Actor 'large bear; (cave) tame ferocious gentle; animal' @inBarrenRoom
    "The bear is extremely large, <<if isTame>>but appears to be friendly.<<else>>
    and seems quite ferocious!<<end>>"

    
    exists = nil
    isFollowing = nil
    isDuped = nil
    wasReleased = nil
    isTame = nil
    rhetoricalTurn = -999
    closexists = nil
        
//    useSpecialDesc = wasReleased
    
    prevloc = nil
    stayloc = inBarrenRoom
    
    followDaemon = nil
    startFollowing()
    {
        isFollowing = true;
        followDaemon = new Daemon(self, &followMe, 1);
    }
    
    followMe()
    {
        if(getOutermostRoom != gRoom)
        {
            gRoom.travelVia(self);
            
            specialDesc();
        }
    }
    
    stopFollowing()
    {
        isFollowing = nil;
        if(followDaemon)
            followDaemon.removeEvent();
        followDaemon = nil;
    }
       
    
    specialDesc()
    {
        
        if(isFollowing)
            "{I} {am} being followed by a very large, tame bear. ";
        else
        {    
            if(isTame)
            {
                if(!wasReleased && isIn(inBarrenRoom))
                    "There is a gentle cave bear sitting placidly in one corner. ";
                else
                    "There is a contented-looking bear wandering about nearby. ";
            }
            else 
                "There is a ferocious cave bear eyeing you from the far end of the
                room! <.reveal ferocious-bear>";
        }
        
    }
    
    

    
    dobjFor(Attack)
    {
        verify()
        {
            if(isTame)
                illogicalNow(onlyfriend);
        }
        
        check()
        {
            if(gActor.contents.indexWhich({o: o.ofKind(Weapon)}) == nil)
                bearhands;
        }
        action()
        {
            local obj = gActor.contents.valWhich({o: o.ofKind(Weapon)});
            if(obj)
            {
                "\n(with <<obj.theName>>)\n";
                doInstead(AttackWith, self, obj);
            }
        
        }
    }
    
    dobjFor(AttackWith)
    {
        verify()
        {
            if(isTame)
                illogicalNow(onlyfriend);
        }
        
        action()
        {
            
            switch(gIobj)
            {
                // Other potential weapons will need adding here
                // but they haven't been defined yet
                
            case myHands:
                nicetry;
                break;
            default:
                "You'd be better off using your bare hands than that thing. ";
            }
        }
    }
    
    dobjFor(Kick)
    {
        verify()
        {
            inherited();
            if(isTame)
                illogicalNow(onlyfriend);
        }
        
        eheck()
        {
             "You obviously have not fully grasped the
            gravity of the situation.  Do get a grip onourself.";
        }
    }
    
    
    iobjFor(ThrowAt)
    {
        verify()
        {
            inherited();
            if(isTame && gVerifyDobj.ofKind(Weapon))
                illogicalNow(onlyfriend);
        }       
        
        action()
        {
            if(gDobj.ofKind(Weapon))
                doInstead(AttackWith, self, gDobj);
            else if(gDobj.isEdible)
                doInstead(GiveTo, gDobj, self);
            else
                doInstead(AttackWith, self, gDobj);
            
        }
    }
    
    iobjFor(ThrowTo) asIobjFor(GiveTo)
    
    iobjFor(GiveTo)
    {
        
        verify() {}
        action()
        {
            if(gDobj.isEdible || (gDobj.ofKind(ContLiquid) && gDobj.myflag is in (&hasWater,
                &hasWine)))
                doInstead(FeedWith, self, gDobj);
            else
            {
                if(isTame)
                    "The bear doesn't seem very interested in {my} offer.";
                else
                    "Uh-oh -- {my} offer only makes the bear angrier!";
            }
        }
        
        
    }
    
    dobjFor(Feed)
    {
        verify() {}
        check()
        {
            if(gActor.allContents.indexWhich({o: o.isEdible}) == nil)
                "The bear seems more likely to eat {me}
                than anything {i}{'ve} got on {me}! ";
        }
        
        action()
        {
            local obj = gActor.allContents.valWhich({o: o.isEdible});
            if(obj && gActor.canReach(obj))
            {
                gMessageParams(obj);
                "\n(with {the obj})\n";
                doInstead(FeedWith, self, obj);                
            }
            else if(isTame)
                "{I} {have} nothing left to give the bear.";
            
            
                
        }
    }
    
    dobjFor(FeedWith)
    {        
        verify() {}
        action()
        {
            if(global.newGame && gIobj == tastyFood)
                "All {I} {have} are watercress sandwiches.  The bear
                is less than interested. ";
            else
            {
                "The bear eagerly wolfs down {the iobj} after
                which he seems to calm down considerably and
                even becomes rather friendly. ";
                gIobj.actionMoveInto(nil);
                isTame = true;
            }              
        }
    }
    
    dobjFor(Drop)
    {
        preCond = [objVisible]
        verify()
        {
            if(!isFollowing)
                illogicalNow('The bear isn\'t following you. ');
        }
        
        action()
        {
            stopFollowing();
            
            if(troll.isIn(gRoom))
                replaceActorAction(self, Attack, troll);
            else 
            {
                "OK, the bear is no longer following you around.";
                stayloc = location;
                prevloc = gPlayerChar.getPreviousLocation;
                
            }
            
        }
    }
    
    dobjFor(Take)
    {
        verify()
        {
            if(!isTame)
                illogicalNow('Surely you\'re joking! ');
            else if(!wasReleased)
                illogicalNow('The bear is still chained to the wall. ');
            else if(isFollowing)
                illogicalAlready('The bear is already following you. ');
        }
        
        action()
        {
            startFollowing();
            "Ok, the bear's now following you around. ";
        }
    }
    
    /* I'm not sure about this -- the TADS 2 code here doesn't seem to make sense. */
//    moveInto(loc)
//    {
//        local oldloc, newloc;
//        oldloc = getOutermostRoom;
//        inherited(loc);
//        newloc = getOutermostRoom;
//        if(oldloc != newloc) 
//        {
//            prevloc = oldloc;
//            stopFollowing();
//            stayloc = loc;
//        }
//    }
    
    handleCommand(action)
    {
        if(action == Follow && gDobj == gPlayerChar)
            doInstead(Take, self);
        else if(action == Attack && gDobj == troll && canReach(troll))
        {
            stopFollowing();
            replaceActorAction(self, Attack, troll);  
        }
        
        else
            "The bear isn't quite sure what you want it to do. ";
        
    }
    
    
    onlyfriend = 'The bear is confused; he only wants to be {my} friend. '
    bearhands()
    {
        "With what?  {my} bare hands?  Against <i>his</i> bear hands??";

        rhetoricalTurn = gTurns;
    }
    
    nicetry()
    {
        
        if (!global.game550)
            "Nice try, but sorry.";
        else 
        {
            if (rand(2) == 1) 
                
                "The bear dodges away from your attack, growls, and
                swipes at you with his claws.  Fortunately, he misses. ";
            
            else 
            {
                "The bear snarls, ducks away from your attack and
                slashes you to death with his claws. ";
                die();
            }
        }
    }

    
    stay 
    {
        if (isFollowing)
            "The bear isn't following you.";
        else 
        {
            "OK, the bear is no longer following you around.";
            stayloc = self.location;
            prevloc = gPlayerChar.getPreviousLocation();
            stopFollowing();
        }
    }
     

;

deadBear: MultiLoc, Distant 'bridge wreckage and dead bear'
    "The remains of the bridge and the smashed body of a dead bear
     are at the bottom of the chasm.  It's just as well that you
     can't examine them closely - the bear isn't a pleasant sight."
;



troll: Actor 'burly troll;;;him' @onSWSideOfChasm
    "Trolls are close relatives with rocks and have skin
        as tough as that of a rhinoceros. "
    
    isPaid = nil
    closeloc = nil
        
    specialDesc 
    {
        if (!isIn(trollTreasure))
            "A burly troll stands by the bridge and insists you
            throw him a treasure before you may cross. ";
        else
            "You see the troll here, counting money and cataloguing
            his treasures. You hear him muttering something about
            golden eggs.";
    }
    
    dobjFor(Attack)
    {
        verify() { }        
        check() {}
        
        action()        
        {
            if(gActor == bear)
            {
                "The bear lumbers toward the troll, who lets
                out a startled shriek and scurries away.  The
                bear soon gives up the pursuit and wanders back. <.reveal bear-attack>";
                moveInto(nil);
                bear.stayloc = bear.location;
                bear.prevloc = bear.getPreviousLocation();
                bear.stopFollowing();
            }
            else
            {
                local obj = gActor.contents.valWhich({o: o.ofKind(Weapon)});
                if(obj)
                {
                    "\n(with <<obj.theName>>))\n";
                    doInstead(AttackWith, self, obj);    
                }
                else 
                    "The troll fends off {my} blows effortlessly. ";
            }
            
        }
    }
    
    dobjFor(Kick)
    {
        verify() {}
        action()
        {
            "The troll laughs aloud at {my} pitiful attempt to injure him.";
        }
    }
    
    iobjFor(GiveTo)
    {
        preCond = [touchObj]
        verify() {}
        action()
        {
            local cont,vb1,vb2,adv;
            if(gVerbWord != 'throw')
            {
                vb1 = 'takes';
                vb2 = 'gives';
                adv = '';
            }
            else 
            {
                vb1 = 'catches';
                vb2 = 'tosses';
                adv = 'deftly ';
            }
            
            // add test for liquid here then else clause:
            
            cont = gDobj;
            if(cont.ofKind(Treasure))
            {
                local letfall;
                if(cont == glowingStone) 
                {
                    "The troll catches the glowing stone, then sets it down and
                    steps back.  He says \"Don't you realize what this
                    is?  Next time, use a suitable container. \" He then
                    scurries off and quickly reappears with
                    an ornate lead casket.  He places the stone into the 
                    casket, closes it, and disappears out of sight again. ";
                    cont.moveInto (leadBox);
                    cont = leadBox;
                }
                else if (dobj == goldenEggs && isDuped) 
                {
                    if (vb1 =='catches') 
                        "The troll nimbly steps
                        to one side and grins nastily as the nest of
                        golden eggs flies past him and plummets into
                        the chasm.  \"Fool me once, shame on you;
                        fool me twice, shame on me!\" he sneers.
                        \"I want something a touch more substantial
                        this time!\"";
                    else 
                        "The troll nimbly moves his hand away and
                        grins nastily as the nest of golden eggs falls
                        from your hand and plummets into the chasm.
                        \"Fool me once, shame on you; fool me twice,
                        shame on me!\" he sneers.  \"I want something
                        a touch more substantial this time!\"";
                    
                    letfall = true;
                }
                else 
                    "The troll <<vb1>> {my} treasure and
                    scurries away out of sight. <.reveal troll-departs>";
                
                if(letfall)
                    cont.moveInto(nil);
                else
                {
                    cont.actionMoveInto(trollTreasure);
                    self.actionMoveInto(trollTreasure);
                }
                isPaid = letfall ? nil : gActor.getOutermostRoom;
            }
            else if(cont.isEdible)
            {
                checkDobjFeed();
            }
            else
            {
                gMessageParams(cont);
                "The troll <<adv>><<vb1>> {the cont},
                examines {him cont}> carefully,
                and <<vb2>> {him cont} back, declaring, \"Good workmanship,
                but {the subj cont} {is} not valuable enough.\"";
            }
        }
    }

    iobjFor(ThrowTo) asIobjFor(GiveTo)
    iobjFor(ThrowAt) asIobjFor(GiveTo)
    
    dobjFor(Feed)
    {
        verify() {}
        check()
        {
            "Gluttony is not one of the troll's vices. Avarice, however, is. ";
        }
    }
    
    dobjFor(Rub) { verify() { illogical('I don\'t think {the dobj} would care for that. ');} }
    
    cannotTalkToMsg = 'He wants treasure, not gab. '
;

absentTroll: MultiLoc, Unthing    
    unObject = troll
    notImportantMsg = 'The troll is nowhere to be seen. '
    locationList = [onNESideOfChasm, onSWSideOfChasm ]
;

dragon: Actor 'dragon; monster beast lizard; huge green scaly fierce giant ferocious' @persianRug
    "I wouldn't mess with it if I were you. "
    beforeTravel(traveler, connector)
    {
        if(traveler.getPreviousLocation != inSecretNSCanyon0 
           && connector.destination == inSecretNSCanyon0)
        {
            blockMsg;
            exit;          
        }
        
         if(traveler.getPreviousLocation == inSecretNSCanyon0 
            && connector.destination == inSecretEWCanyon)
        {
            blockMsg;
            exit;          
        }
        
    }
    
    initSpecialDesc = "A huge green dragon bars the way! "
    
    blockMsg = "The dragon looks rather nasty.  You'd best not try to get by. "
    
    dobjFor(Attack)
    {
        verify() {}
        check() {}
        action()
        {
            "What, with your bare hands? ";
            if(yesOrNo())            
                kill();             
            else
                "Thought not! ";
               
        }       
        
    }
    
    dobjFor(AttackWith)
    {
        verify() {}
        check() {}
        action()
        {
            if(gIobj.ofKind(Weapon))
            {
                if(gVerbWord != 'throw')
                    "\n(throwing (the iobj})\n";
                "{The subj iobj} bounce{s/d} harmlessly off the dragon's thick scales. ";
                gIobj.moveInto(gActor.getOutermostRoom);                
            }
            else if(gIobj == myHands)
                kill();
            else
                "{I}'d probably be better off using {my} bare hands than that thing! ";
        }
    }
    
    kill()
    {
        "Congratulations! {I} {have} just vanquished a
        dragon with {my} bare hands!  (Unbelievable,
        isn't it?)";

        dragonCorpse.moveInto(getOutermostRoom);
        if(global.game550) 
            dragonTeeth.moveInto(getOutermostRoom);
        moveInto(nil);
    }
    
    dobjFor(Kick)
    {
        verify() {}
        action()
        {
             "Right idea, wrong limb. ";
        }
    }
    
    iobjFor(ThrowAt)
    {
        action()
        {
            if(gDobj.ofKind(Weapon))
                doInstead(AttackWith, self, gDobj);
            else if(gDobj == glassVial)
                ; // let the dobj handle it
            else
                doInstead(GiveTo, gDobj, self);
        }
    }
    
    // GIVING AND FEEDING USE FEEDABLE DEFAULTS
    
    dobjFor(Rub) { verify() { illogical('Don\'t be ridiculous! '); }}
;

dragonCorpse: Fixture 'dragon;dead green huge;corpse'
    "It's the rotting carcass of a huge dragon, lying off to one
        side.  There isn't a mark on it, and I can't really explain
        how you managed to kill it with your bare hands.  \(That\)
        mystery will always defy attempts at a rational explanation. " 
    
    specialDesc =  "The body of a huge green dead dragon is lying off to
        one side. "   
    
    /* Added an appropriate response here. */
    cannotTakeMsg = 'Even if (i) had a use for it, the dragon corpse is far too heavy
        and bulky to lug around. '
    
    dobjFor(Kick)
    {
        verify() { illogicalNow('You\'ve already done enough damage!'); }
    }
    
    dobjFor(Attack)
    {
        verify() { illogicalNow(alreadyDeadMsg); }
    }
    
    dobjFor(AttackWith)
    {
        verify() { illogicalNow(alreadyDeadMsg); }
    }

    alreadyDeadMsg = 'For crying out loud, the poor thing is already dead!  '
    closeloc = nil
;

dragonTeeth: Thing
;

wumpus: NPC 'wumpus'
    isChasing = nil
    isAsleep = true
    
    
    
;

dog: NPC 'dog'
    isAsleep = nil
    
    blockMessage = "The dog won't let you pass! " // temporary
;

/* Dwarves with a captital D because dwarves is already in use as an object property. */
Dwarves: NPC 'dwarves;;;them'
    noAttack = nil
    
    /* Methods to be added: */
    move() { }
    place() {}
    numberhere(actor) { return 0; } // temporary - to be fixed.
;

pirates: NPC 'pirate;;;him'
    
    
;

bees: Feedable, Fixture 'bees;;;them'
    
    arefed = nil
;

dwarfstart(parm)
{
    // Place all the NPC's.  Now initiated from Me.travelTo.
    
    Dwarves.place;
    new Daemon(Dwarves, &move, 1);    

    if (!treasureChest.spotted) 
    {
        pirates.place;
        new Daemon(pirates, &move, 1);
    }

    global.NPCstarted = true;
}