#charset "us-ascii"

#include <tads.h>
#include "advlite.h"

property npcstuckwarn, NPCdest;

initNPC()
{
    local   o;    //
    local bogusrooms = [ '', 'unknownDest_','unknown'];
        
    // Construct list of NPC exits for each room
    //
    o = firstObj(Room);
    while (o != nil) 
    {
        
        if(o.noNPCs) {
            if (global.debug) 
            {
                //
                // Debugging info:
                //
                "\b\"<< o.theName >>\" is off limits to NPC's.";
            }
        }
        else if(bogusrooms.indexOf(o.roomTitle) != nil) {
            // force set noNPCs for this room!
            o.noNPCs = true;
        }
        else {  
            //
            // Add this room to the global list of rooms
            // the NPC's can be in.
            //
            global.NPCrooms = global.NPCrooms + o;                
            do_exitlist(o);
            do_npclist(o);
        }

        o = nextObj(o, Room);
    }
    
#if __DEBUG
    check_connections();
#endif
}

// not sure this is the correct substitution
debugTrace() {
    t3DebugTrace(T3DebugBreak);
}

/*
 * Add standard exits to the list of exits that NPC's should check
 * when they're wandering about randomly.
 */

do_exitlist(rm) {
	local	exitlist, i, ex;
    local   tot1;

	//
	// List of all exit property names that NPC's will consider.
	// Note that magic words are left out because NPC's don't
	// know them.
	//
	exitlist = [
		&north,&south,&east,&west,&northeast,&northwest,&southeast,&southwest,
        &up,&down,&in,&out, &climb, &climbup, &climbdown,

		&jump, &upstream, &downstream, &forwards, // &outdoors, is a region 
		&left, &right, &center, &cross, &over, &across, &road, &forest,
		&valley, &stairs, &building, &gully, &stream, &rock, &bed, 
		&crawl, &cobble, &tosurface, &dark, &passage, &low, &canyon, 
		&awkward, &giant, &view, &pit, &crack, &steps, &hall, &toDome,
		&barren, &debris, &hole, &wall, &broken, &y2, &floor, &toroom, 
		&slit, &slab, &depression, &entrance, &secret, &cave, 
		&bedquilt, &oriental, &cavern, &shell, &toReservoir, &toMain,
        // &office was removed in updated version
		&fork, &chimney, &slide, &pool, &lair, &mainOffice,
        &ledge, &ice, &bridge, &altar, &grotto
	];
    tot1 = exitlist.length();
    // thought this was defined for any room but I guess not
    if(!rm.propDefined(&NPCexits)) {
//        "Room \"<<rm.roomTitle>>\" does not have an NPCexits property!\n";
        rm.NPCexits = [];
//        return;
    }

	for (i = 0; ++i <= tot1; ) {
		//
		// If this exit property is a simple
		// object (prop 2), NPC's can use it, so
		// add it to the room's NPC exit list.
		//
		// Make sure we don't add the same
		// desination room twice.  Just because
		// there are multiple travel verbs from
		// one place to another doesn't mean the
		// destination should be more likely.
		//
        if(!rm.propDefined(exitlist[i])) continue;
		if (rm.propType(exitlist[i]) == TypeObject && !rm.(exitlist[i]).noNPCs) {
			//
			// Search current exitlist for
			// this exit's destination.
			//
            ex = rm.(exitlist[i]);
            if(!ex.noNPCs) {
                if(rm.NPCexits.length() < 1 || rm.NPCexits.indexOf(ex) == nil)
                    rm.NPCexits += exitlist[i];
            }
		}
	}
}

/*
 * Add NPC special exits to the list of exits that NPC's should check
 * when they're wandering about randomly.
 */
do_npclist(rm) {
	local	npclist, i, tot;

	//
	// NPC exits.  These get considered if even if they're methods.
	// The only way they won't be added to the list of exits to
	// try is if they're = nil and not methods.
	//
	npclist = [
		&NPCexit1,&NPCexit2,&NPCexit3,&NPCexit4,
		&NPCexit5,&NPCexit6,&NPCexit7,&NPCexit8,
		&NPCexit9,&NPCexit10,&NPCexit11,&NPCexit12
	];

    tot = npclist.length();
	for (i = 0; ++i <= tot; ) {
		//
		// If this NPC exit property is anything but
		// nil (i.e., just nil, and not a method
		// that returns nil). then NPC's can use it.
		// Methods that return nil are fine because
		// they might be conditional on some game
		// events, like the crystal bridge having
		// been created, etc.
		//
        if(!rm.propDefined(npclist[i])) continue;
		if (rm.propType(npclist[i]) != TypeNil) {
            rm.NPCexits += npclist[i];
        }
	}
}


/*
 * Make sure NPC room connections are sound.
 */
#ifdef __DEBUG
check_connections()
{
	local o;
	o = firstObj(Room);
	while (o != nil) {
		if (!o.noNPCs && o.roomTitle != nil && o.roomTitle != '')
			do_debug(o);

		o = nextObj(o, Room);
	}
}
	
do_debug(rm)
{
	local	i, j, tot;

	if (rm.NPCexits.length() == 0) {
		P(); I();
		"Oh dear, someone seems to have damaged one of my 
		room connections.  The room \"<<rm.roomTitle>>\" has no exits for NPC's to follow, but it's not 
		listed as off limits to NPC's.  Please notify the 
		cave management as soon as possible!\n";
	}
	else if (global.debug) {
		//
		// Debugging info:
		// 			
		"\b\"<<rm.roomTitle>>\" has <<rm.NPCexits.length()>> NPC exit";
		if (rm.NPCexits.length() > 1)
			"s:";
		else
			":";

	    tot = rm.NPCexits.length();
		for (i = 0; ++i <= tot; ) {
			"\b\t-> ";
			if (rm.(rm.NPCexits[i])) {
                j = rm.(rm.NPCexits[i]);
                if(j.roomTitle != nil && j.roomTitle.length() > 0)
                    "<<j.roomTitle>> ";
                else
                    "DESC: <<j.desc>> ";
            }
			else
				"(nil)";
		}
        "\n";
	}
}

#endif


//////////////////////////////////////////////


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
    
    dobjFor(Attack) { check() {} }
    
    lastmoveloc = nil
    lasttoploc = nil
    prevloc = nil
    
    actionMoveInto( obj )
    {
        local oldloc, newloc = obj ? obj.getOutermostRoom : nil;
        // reset posture variable if location is being changed
        //        if (obj != self.location) {
        //             if(obj) self.posture := obj.default_posture;
        //             else self.posture := nil;
        //        }
        if(lastmoveloc == nil) 
        {
            lastmoveloc  = location;
            lasttoploc = lastmoveloc ? lastmoveloc.getOutermostRoom : nil;
        }
        oldloc = lasttoploc;
        
        // DJP - save previous topmost location.
        if(oldloc !=  newloc) 
            prevloc = oldloc;
        
        // Moves into and out of nestedrooms are ignored, but a move from
        // a top-level room to the same room is acknowledged.
        if(lastmoveloc == obj && newloc == obj) {
            prevloc = oldloc;
        }
        lastmoveloc = obj;
        lasttoploc = lastmoveloc ? lastmoveloc.getOutermostRoom : nil;
        // Pass control to the original movableActor.moveInto
        // method in adv.t.
        inherited(obj);
    }
    
    
    
;


class NPC: Actor
	//
	// List of currect NPC locations.
	//
    oldloclist = []     // where they were
	loclist = []		// where they are
	newloclist = []		// where they're going
    
    iobjFor(GiveTo)
    {
        verify() { }        
    }
    place() {}
    move() {}


	//
	// Scatter any NPC's that are currently in
	// the room to random rooms in the cave.  (We
 	// have to make sure the new rooms aren't off
	// limits to dwarves, though.) 
	//
	scatter(...) {
		local	i, dest, len, r, tot;
        local   melocs;

        if(argcount == 0)
            i = gPlayerChar.location;
        else
            i = getArg(1);
        
        melocs = [];
        while(i) {
            melocs += i;
            // TODO: Not sure if this change is correct
//            if(i.istoproom)
            if(i == i.getOutermostRoom)
                i = nil;
            else
                i = i.location;
        }

        // if NOT in the same room as the player, no need to scatter
        if (melocs.intersect(loclist).length() == 0) return;

		newloclist = [];
		tot = loclist.length();
        len = global.NPCrooms.length();
		for (i = 0; ++i <= tot;) {
			if (melocs.indexOf(loclist[i]) != nil) {
				//
				// Make sure we get a real location.
				//
				dest = nil;
				while (dest == nil) {
					r = rand(len);
					dest = global.NPCrooms[r];
                    if(!dest.NPCvalid || melocs.indexOf(dest) != nil)
                        dest = nil; // DJP
				}
				newloclist += dest;
			}
			else {
				newloclist += loclist[i];
			}

		}
        oldloclist = loclist;
		loclist = newloclist;
	}
    
	//
	// Returns true if any NPC's of this type are in locations
	// adjacent to the player.  (I.e., if any NPC's could take
	// any exit that would bring them to the player's current
	// location.)
	//
	anyadjacent() {
		local	adjacent, i, j, len, dest, melocs;
        local   tot1;
		local   cur;
        local   currentsave = global.currentActor;
        
        global.currentActor = self;

//"\nanyadjacent(enter)\n";

        i = gPlayerChar.location;
        melocs = [];
        while(i) {
            melocs += i;
            // TODO: Not sure if this change is correct
//            if(i.istoproom)
            if(i == i.getOutermostRoom)
                i = nil;
            else
                i = i.location;
        }

		adjacent = nil;
        tot1 = loclist.length();
		for (i = 0; ++i <= tot1; ) {
            cur = loclist[i];
            len = cur.NPCexits.length();
			for (j = 0; ++j <= len; ) {
                dest = cur.(cur.NPCexits[j]);
                
                // TODO: NPCdest is not defined???
                if(dest && dest.ofKind(Door))
                    dest = dest.NPCdest;

				//
				// We need to check the destination
				// to be sure it exists.  It may be
				// nil if we called an NPCexit method.
				//
				if (dest && melocs.indexOf(dest) != nil) {
					adjacent = true;
					break;
				}
			}

			//
			// If we've found an adjacent pirate we
			// can stop looking.
			//
			if (adjacent)
				break;
		}

//"\nanyadjacent(exit)\n";
        // reset the current actor
        global.currentActor = currentsave;
        
		return adjacent;
	}
    
    dobjFor(Summon) {
        verify() { }
        action() {
            local toploc = gPlayerChar.location.getOutermostRoom;
            local i, o;
            local len = self.loclist.length();
            if(!toploc.NPCvalid) {
                "I can't do that, because <<self.theName>> isn't
                allowed in this room. ";
                return;
            }
            if(self == pirates && treasureChest.seen) {
                "You can't summon the pirate after you've spotted the
                treasure chest. ";
                return;
            }
            // attempt to remove one NPC from another location.  NPC's are
            // not removed from the player's room in order to allow repeated
            // SUMMONs to summon up more dwarves.
            for (i = 0; ++i <= len; ) {
                o = self.loclist[i];
                if (o != toploc) {
                    self.loclist -= o;
                    break;
                }
            }
            // add this location to the front of the list.
            self.loclist = [toploc] + self.loclist;
            // start the NPCs if necessary
            if(global.nodwarves)
                global.nodwarves = nil;
            dwarfPirateStart();
            if (self == Dwarves)
                self.noAttack = true;
        }
    }
    
    dobjFor(Banish) {
        verify() {
            if(global.nodwarves && Dwarves.loclist.length() == 0 &&
                pirates.loclist.length() == 0)
                    illogical('The dwarves and pirate have already been banished. ');
        }
        
        action() {
            "Banishing all dwarves and pirates ... ";
            global.nodwarves = true;
            Dwarves.loclist = [];
            pirates.loclist = [];
            if(!treasureChest.seen) {
                 treasureChest.moveInto(deadEnd13);
            }
            global.nodwarves = true;            
        }

    }
;


class Feedable: object
    dobjFor(Feed)
    {
        preCond = [objVisible]
        verify() {}
        action() {
            "There's nothing here that <<self.theName>> would want to
            eat. ";
        }        
    }
    dobjFor(FeedWith) {
        preCond = [objVisible]
        verify() {
            if(gIobj == gPlayerChar) {
                "Pull yourself together!  Self-sacrifice is \(not\)
                the object of this game. ";
                return;
            }
            vertesttake(self,gIobj);
        }
        action() {
            if(gIobj.ofKind(ContLiquid) && 
               (gIobj.myflag == &hasWater || gIobj.myflag == &hasWine)) {
//                if (self.isThem)
//                    "\^<<self.theName>> don't appear to be thirsty. ";
//                else
                    "\^<<self.theName>> {doesn't appear} to be thirsty. ";
            }
            else {
                "I don't think that <<self.theName>>
                would want to eat <<gIobj.name>>. ";
            }
        }
    }

    iobjFor(GiveTo) {
        preCond = [objHeld]
        verify() { }
        action() {
            if(gDobj.ofKind(ContLiquid) && (gDobj.myflag == &hasWater || gDobj.myflag == &hasWine)) {
                doInstead(FeedWith,gDobj,self);
            }
            else if(gDobj.ofKind(Food)) {
                doInstead(FeedWith,gDobj,self);
            }
            else {
                "\^<<self.theName>> doesn't appear to be at all
                interested in <<gDobj.theName>>. ";
            }            
        }
    }
;


vertesttake(a,dobj) {
    /* Procedure to be called during verification, to check that an object can
    be taken.  For liquids in containers, the container is checked
    instead.  For normal objects, the verDoTake method is called; for 
    objects with the noImpliedTake property the verifyRemove method is used
    instead.  Finally, any fixed items which have slipped through the net
    are caught. }
     */

    // _outputCapture
//    local outhideStatus;
    local o = dobj;
    if (o.ofKind(ContLiquid))
        o = dobj.mycont;

#if 0
    // TODO: Not sure how to handle this
    if (!o.noImpliedTake) {
        if (o.location != a) {
            /*
             *   silently check the verification method
             */
//            outhideStatus = outhide(true);
//            o.verifyDobjTake();
//            if (outhide(outhideStatus)) {
//                /*
//                 *   verification failed - run again, showing the message
//                 *   this time
//                 */
//                o.verifyDobjTake();
//                return nil;
//            }
        }
    }
    else {
        if (o.location != a) {
            /*
             *   silently check the verification method
             */
//            outhideStatus = outhide(true);
//            o.verifyRemove(a);
//            if (outhide(outhideStatus)) {
//                /*
//                 *   verification failed - run again, showing the message
//                 *   this time
//                 */
//                o.verifyRemove(a);
//                return nil;
//            }
        }
    }
#endif

    /* trap any fixed items which have slipped through the net */
    if (o.isFixed) {"%You% can't do that with <<o.theName>>.\n";}
    return (!o.isFixed);
}

testtake(a,dobj) {
    /* procedure to try to take an object before it is given or
    fed to something.  A suitable verification method (e.g. vertesttake,
    verifyRemove, or verDoTake) should have been invoked at the verification
    stage.   If the object is a liquid in a container, the container is taken
    instead.  Items with the noImpliedTake property are exempt and return true.
    However, all fixed items return false because they couldn't be given to
    anything else. */

    local o = dobj;
    if (o.ofKind(ContLiquid)) o = dobj.mycont;

#if 0
    local tflag = a.realtake;
    if (!o.noImpliedTake) {
        if (o.location != a){
            "\n(Trying to take ";o.thedesc; ")\n";
            a.realtake := true; // dotake will use normal methods
                                // for all actors
            o.doTake(a);        // take the object
            a.realtake := tflag;

            if (o.location = a) return true;
            else return nil;
        }
        else
            return (!o.isFixed);
    }
    else
#endif
        return (!o.isFixed);
}


/*
 *  addbulk: function(list)
 *
 *  This function returns the sum of the bulks (given by the bulk
 *  property) of each object in list.  The value returned includes
 *  only the bulk of each object in the list, and not of the contents
 *  of the objects, as it is assumed that an object does not change in
 *  size when something is put inside it.  You can easily change this
 *  assumption for special objects (such as a bag that stretches as
 *  things are put inside) by writing an appropriate bulk method
 *  for that object.
 */
addbulk(alist)
{
    local i, tot, totbulk, cur;

    tot = alist.length();
    i = 1;
    totbulk = 0;
    while(i <= tot)
    {
        cur = alist[i];
        if (!cur.isWornBy(gPlayerChar))
            totbulk += cur.bulk;
        ++i;
    }
    return totbulk;
}



snake: Feedable, Actor 'snake;huge fierce green venemous ferocious large big killer
    ;cobra asp' @inHallOfMtKing
    "I wouldn't mess with it if I were you. "    
    
    specialDesc = "A huge green fierce snake bars the way<<if
          wickerCage.isDirectlyHeldBy(gPlayerChar) && wickerCage.hasBird>>, hissing furiously at
        something you're carrying<<end>>! "
    
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
            local conn = getConnectorTo(gRoom);            
            conn = conn ?? gRoom;
            conn.travelVia(self);
            
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
        
        check()
        {
             "You obviously have not fully grasped the
            gravity of the situation.  Do get a grip on yourself.";
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
            global.saidThrow = true;
            if(gDobj.ofKind(Weapon))
                doInstead(AttackWith, self, gDobj);
            else if(gDobj.isEdible)
                doInstead(GiveTo, gDobj, self);
            else
                doInstead(AttackWith, self, gDobj);
            global.saidThrow = nil;
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
                prevloc = gPlayerChar.prevloc;                
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
        else if(action == stayVerb)
            stay();
        
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
            stayloc = location;
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
                bear.prevloc = gPlayerChar.prevloc;
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

dragon: Actor 'huge green dragon; monster beast lizard; scaly fierce giant ferocious' @persianRug
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
    specialDescOrder = 50
    /* We want to mention the dragon before the rug it's lying on. */
    specialDescBeforeContents = true
    
    blockMsg = "The dragon looks rather nasty.  You'd best not try to get by. "
    
    dobjFor(Attack)
    {
        verify() {}
        check() {}
        action()
        {
            "What, with your bare hands?\b>";
            if(yesOrNo())            
                kill();             
            else
                "Chicken! ";
               
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


//////////////////////////////////////////////////////////////////////////////////////

/* Dwarves with a capital D because dwarves is already in use as an object property. */
Dwarves: NPC 'threatening little dwarf;nasty mean;dwarves dwarfs guy;them him'
    noAttack = nil
	rhetoricalturn = -999	// hack -- see yesVerb in ccr-verbs.t
	attackers = 0		// number of dwarves that attack this turn
	
	desc = "It's probably not a good idea to get too close.  Suffice
		it to say the little guy's pretty aggressive. "

    oldmelocs = []      // old melocs
    loc = nil           // actual location

	//
	// We don't use actorDesc for the dwarves because it gets printed
	// too early.  (We want to let the player know that a dwarf is
	// in the room as soon as the dwarf moves into the room, not at
	// the start of the next turn.)
	//
//	actorDesc = {}

	location {
		local i = gPlayerChar.location;
        local melocs = [];

        while(i) {
            melocs += i;
            // TODO: Not sure if this change is correct
//            if(i.istoproom)
            if(i == i.getOutermostRoom)
                i = nil;
            else
                i = i.location;
        }
		if (melocs.intersect(loclist).length() == 0)
		    return nil;

		//
		// Check each dwarf's location.  If at least one dwarf
		// is in the same location as the player, make our
		// location the same as the player's.
		//
		for (i = 0; ++i <= loclist.length();)
			if (melocs.indexOf(loclist[i]) != nil)
				return loclist[i];

		return nil;
	}
    
    dobjFor(Attack) {
        verify() {
            if (!(axe.isIn(gPlayerChar) || sword.isIn(gPlayerChar) || singingSword.isIn(gPlayerChar))) {
                "With what?  Your bare hands? ";
                rhetoricalturn = gTurns;
                noAttack = true;
            }
        }
        action() {
            // By default, attack with the axe ...
            if (axe.isIn(gPlayerChar)) {
                "\n(with the axe)\n";
                doInstead(AttackWith,self,axe);
            }
            // or the sword ...
            else if (sword.isIn(gPlayerChar)) {
                "\n(with the sword)\n";
                doInstead(AttackWith,self, sword);
            }
            else if (singingSword.isIn(gPlayerChar)) {
                "\n(with the singing sword)\n";
                doInstead(AttackWith,self,singingSword);
            }            
        }
    }

    dobjFor(Kick) {
        verify() { }
        action() {
            "You boot the dwarf across the room.  He curses, then 
            gets up and brushes himself off.  Now he's madder 
            than ever! ";
        }
	}
    
    dobjFor(AttackWith) {
        verify() { }

        action() {
            local kilpct = 25, count, skipnext;
            local pass_to_game551 = nil;
            
            switch(global.vNumber) {
            case 11:
            case 15: // In 701-point mode, we mainly use the 550-point code
                   // except for the gleaming sword.
            case 2:  // In 550-point mode
            case 7:  // In 580-point mode
                count = self.numberhere(gPlayerChar);
                switch(gIobj) {
                case axe: // The axe is best off thrown.
                    kilpct = 5*(gPlayerChar.bulkCapacity - addbulk(gPlayerChar.contents)) + 15*count;
                    kilpct += (global.saidThrow? 45 : 30);
                    if (rand(100) <= kilpct)
                        self.kill;
                    else
                        "You attack a little dwarf, but he
                        dodges out of the way. ";
                    break;
                
                case sword: // Pass on to 551-point code
                    pass_to_game551 = true;
                    break;
                    
                case singingSword: // The sword is best off not thrown.
                    kilpct = 5*(gPlayerChar.bulkCapacity - addbulk(gPlayerChar.contents)) + 15*count;
                    kilpct += (global.saidThrow? 30 : 45);
                    // added provision for clover in 701-point game
                    if (clover.isIn(gPlayerChar))
                        kilpct += 25;
                    if (rand(100) <= kilpct)
                        self.kill;
                    else
                        "You attack a little dwarf, but he
                        dodges out of the way. ";
                    break;
                        
                case myHands: // This has different code.
                    kilpct = 10*(gPlayerChar.bulkCapacity - addbulk(gPlayerChar.contents)) + 20;
                    if (rand(100) <= kilpct)
                        self.kill;
                    else
                        "You attack a little dwarf, but he
                        dodges out of the way. ";
                    break;
                
                default:
                    "Somehow I doubt that'll be very effective. ";
                    break;
                }
                if (!pass_to_game551) {
                    if (global.saidThrow) {
                        // DJP - updated destination to use new 
                        // throwHitDest property
                        // MM - code examination shows it is always same dest EXCEPT
                        // when On_Ladder and then it goes to Cloak_Pits
                        // gIobj.moveInto(gPlayerChar.getOutermostRoom.throwHitDest);
                        local locn = gPlayerChar.getOutermostRoom;
                        if(locn == onLadder) locn = cloakPits;
                        gIobj.moveInto(locn);
                        global.saidThrow = nil;
                    }
                    break;
                }
                // INTENTIONAL FALL THRU
                
            case 1:
            if((gIobj == axe || gIobj == sword) && !global.saidThrow) {
                skipnext = true;
                if(clover.isIn(gPlayerChar)) kilpct = 50;
                if(gIobj == sword && crown.isWornBy(gPlayerChar))
                    kilpct = 95;
                // If only one dwarf is present, we disable dwarf attacks
                // at the end of the turn.
                if (self.numberhere(gPlayerChar) < 2) self.noAttack = true;
                if(rand(100) <= kilpct) self.kill;
                else if(rand(100) <= 25) {
                    if (gPlayerChar.protection < 3) {
                        "As you move in for the kill, the dwarf neatly slips a
                        knife between your ribs. ";
                        die();
                    }
                    else if(gPlayerChar.protection <= 5) {
                        "As you move in for the kill, the dwarf lunges at
                        you with a knife - but something seems to deflect it
                        away from you. It misses. ";
                    }
                    else if(gPlayerChar.protection >= 6) {
                        "As you move in for the kill, the dwarf lunges at
                        you with a knife, but it flies out of his hand
                        and stabs him in the heart!  The body vanishes in a
                        cloud of greasy black smoke. ";
                        hoist_petard(1);
                    }
                    else if(gPlayerChar.protection >= 9) {
                        "As you move in for the kill, the dwarf lunges at
                        you with a knife, but it flies out of his hand
                        and stabs him in the heart!  The body vanishes in a
                        cloud of greasy black smoke. Normally the knife
                        would also vanish, but it doesn't. ";
                        search_and_destroy(1);
                    }
                }
                else {
                    "You can't get close enough for a clean thrust. ";
                    if(rand(100) <= 36) return;
                    "As you approach, the dwarf slashes out with his knife! ";
                    if(gPlayerChar.protection < 3) {
                        if(rand(100) <= 61)
                            "It misses! ";
                        else {
                           "It gets you! ";
                            die();
                        }
                    }
                    else if(gPlayerChar.protection <= 5)
                        "Something seems to deflect the knife away from
                        you, and it misses! ";
                    else if(gPlayerChar.protection >= 6) {
                        "For some reason the knife flies out of the dwarf's
                        hand, does a 180 degree flip, and then shoots
                        towards him, stabbing him in the chest! The body
                        vanishes in a cloud of greasy black smoke. ";
                        if (gPlayerChar.protection < 9) {
                            hoist_petard(1);
                        }
                        else {
                            "Normally, the knife would also vanish, but it
                            doesn't. ";
                            search_and_destroy(1);
                        }
                    }
                }
            }
            if(skipnext) break;

            // Code to handle throwing the axe or gleaming sword in the
            // 350-point or 550-point game.
            case 0:
                switch (gIobj) {
                case axe:
                    // DJP - the clover brings luck by making the axe more accurate
                    if (!global.saidThrow) {
                        "\n(throwing the axe)\n";
                    }
                    global.saidThrow = nil;
                    if (clover.isIn(gPlayerChar) && rand(100) <= global.luckyhit) {
                        self.kill;
                    }
                    else if (rand(100) <= global.dwarfhit) {
                        self.kill;
                    }
                    else {
                        "You attack a little dwarf, but he
                        dodges out of the way. ";
                    }

                    // drop the axe
                    // DJP - updated destination to use new 
                    // throwHitDest property
                    // MM - code examination shows it is always same dest EXCEPT
                    // when On_Ladder and then it goes to Cloak_Pits
                    // gIobj.moveInto(gPlayerChar.getOutermostRoom.throwHitDest);
                    local locn = gPlayerChar.getOutermostRoom;
                    if(locn == onLadder) locn = cloakPits;
                    axe.moveInto(locn);
                    break;

                case sword: // (It's more fragile than it looks)
                    global.saidThrow = nil;
                    sword.throwsmash;
                    break;

                case myHands:
                    self.nicetry;
                    break;

                default:
                    "Somehow I doubt that'll be very effective.";
                    break;
                }
                break;

            default: "Error! Unrecognized version number <<global.vNumber>>!"; break;
            }
            global.saidThrow = nil; // safety measure
        }
    }

	//
	// The following method is called when the player responds, "yes"
	// to "With what?  Your bare hands?"
	//
	nicetry() { "You wish. "; }
    kill() {
        "You killed a little dwarf.  The body
        vanishes in a cloud of greasy black
        smoke. ";
        //
        // Remove this location from our list
        // of locations where dwarves are.
        //
        self.loclist -= self.location;
    }
    // Method to kill off attacking dwarves when Me.protection = 6.  Any
    // other dwarves who witness the event will also 'flee in terror' and
    // won't be seen again.
    hoist_petard(n) {
        local i, l;
        // kill off 'n' dwarves
        for (i = 0; ++i <= n; ) {
            self.loclist -= self.location;
        }
        // work out how many are still left at this location
        l = self.numberhere(gPlayerChar);
        if (l == 0) return;
        if (l == 1)
            "The remaining dwarf flees in terror! ";
        else if (l > 1)
            "The remaining dwarves flee in terror! ";
        for (i = 0; ++i <= n; ) {
            self.loclist -= self.location;
        }
    }
    search_and_destroy(n) {
        local i, l;
        // kill off 'n' dwarves
        for (i = 0; ++i <= n; ) {
            self.loclist -= self.location;
        }
        // work out how many are still left at this location
        l = self.numberhere(gPlayerChar);
        if (l == 0) {
            "The knife flies out of the room";
        }
        else if (l == 1)
            "The knife stabs the remaining dwarf, then flies out of the
            room ";
        else if (l > 1)
            "The knife stabs the remaining dwarves, then flies out of the
            room ";
        self.loclist = [];
        ", presumably searching for more dwarves.  Anyway, I have the feeling
        that they won't be troubling you again. ";
    }

	iobjFor(GiveTo) {
        verify() { }
        action() {
            if (gDobj == tastyFood || gDobj == coal) {
                doInstead(FeedWith,self,gDobj);
            }
            else {
                "The dwarf is not at all interested in your 
                offer. ";
            }
        }
    }

    iobjFor(ThrowAt) {
        verify() { }
        action() {
            global.saidThrow = true;
            if (gDobj == axe)
                doInstead(AttackWith,self,axe);
            else
                doInstead(GiveTo,self,gDobj);
        }
    }
    iobjFor(ThrowTo) asIobjFor(ThrowAt)
    
    dobjFor(Feed) {
        verify() { }
        action() {
            askForIobj(FeedWith);            
        }
    }
    dobjFor(FeedWith) {
        verify() { }
        action() {
            if(gIobj == coal) {
                if(testtake(self,coal)) {
                    "A little dwarf has run off with your coal! ";
                    //
                    // Remove this location from our list
                    // of locations where dwarves are.
                    //
                    self.loclist -= self.location;
                    gIobj.moveInto(nil);
                }
            } else if(gIobj.ofKind(Food)) {
                "You fool, dwarves eat only coal!  Now you've 
                made him *really* mad!! ";
            }
        }
    }

	//
	// Place dwarves in starting locations.
	//
	place() {
		local	i, dloc, r;

		loclist = [];
		for (i = 0; ++i <= global.dwarves; ) {
			//
			// If there are any fixed starting locations
			// for dwarves left, put this dwarf in the
			// next one.  Otherwise place him randomly.
			//
			dloc = nil;
			if (global.dwarfloc.length() >= i)
				dloc = global.dwarfloc[i];

			//
			// Invalidate initial location if it's off limits
			// to NPC's.
			//
			if (dloc && !dloc.NPCvalid)
                dloc = nil;

			//
			// Make sure we get a real location.
			//
			while (dloc == nil) {
				r = rand(global.NPCrooms.length()) + 1;
				dloc = global.NPCrooms[r];
                // do not pick the same room twice
                if(loclist.indexOf(dloc) != nil)
                    dloc = nil;
			}
			
			//
			// Add this dwarf's location to the list.
			//
			loclist += dloc;
		}
	}

	//
	// Move dwarves.
	//
	move() {
		local	j, len, vlen = 0, dest, done, dir, count;
		local   melocs =  [];
        local   i = gPlayerChar.location;
        local   currentsave = global.currentActor;
        
        global.currentActor = self;
        
//"\ndwarves.move(enter)\n";

		//
		// Move each remaining dwarf.
		//
		// If the dwarf is currently in the player's location,
		// he stays where he is.
		//
		// If a dwarf is in a location adjacent to the player's
		// current location, he moves into the player's location
		// if he can.  (We check his possible exits to see if
		// any of them go the player's location.)  A consequence
		// of this is that dwarves will follow the player
		// relentlessly once they've spotted him.  (But the global
		// value dwarftenacity can be set to prevent dwarves
		// from *always following*, of course.)
		//
		// If a dwarf isn't adjacent to the player, he just moves
		// around randomly.
		//
	    
        while(i) {
            melocs += i;
            if (i == i.getOutermostRoom) i = nil;
            else i = i.location;
        }

		newloclist = [];
		attackers = 0;	// assume no dwarves attack this turn
		for (i = loclist.length(); i > 0; i--) {
			//
			// Get a copy of this dwarf's location for speed.
			//
			loc = loclist[i];

			//
			// Haven't found a new location yet.
			//
			done = nil;

			//
			// In player's current location?
			//
            if (melocs.indexOf(loc) != nil) {
				dest = loc;	// stay put
				done = true;

			//
			// Try each exit and see if we can reach the
			// player.  If we have an exit that leads to
			// the player, we know it's an OK destination
			// location, since we pruned off all the noNPCs
			// rooms when we constructed the exit lists. 
			//
			} else {
                len = loc.NPCexits.length();
                for (j = len; j > 0; j--) {
                    dir = loc.NPCexits[j];
                    dest = loc.(dir);
                    
                    if(dest && dest.ofKind(Door))
                        dest = dest.NPCdest;
                    if(dest && dest.NPCvalid)
                        ++vlen;
                    //
                    // We need to check the destination
                    // to be sure it exists.  It may be
                    // nil if we called an NPCexit method.
                    //
                    if (dest != nil && melocs.indexOf(dest) != nil) {
                        
                        if(dest.NPCvalid) {
                            //
                            // Is this dwarf tenacious enough
                            // to follow the player?
                            //
                            // DJP - changed to work more like the original
                            // versions.  Dwarves will stick with the player
                            // once they've entered the player's location, but
                            // will have less tendency to 'spot' the player
                            // from an adjacent room.   This should reduce the
                            // 'ganging up' of several dwarves in one room.
                            //
                            if(oldmelocs.indexOf(loc) != nil) {
                                if (rand(100) <= global.dtenacity)
                                    done = true;
                            } else {
                                if (rand(100) <= global.dspotfromadj)
                                    done = true;
                            }
                            break;
                        }
                    }
                }
            }

			//
			// Have we found a destination yet?  If not,
			// move dwarf to a randomly selected adjacent
			// location.
			//
			// We need to check the destination because
			// the NPCexit methods in the rooms can sometimes
			// return nil.  (For example, when the crystal
			// bridge doesn't exist yet, the giant's door
			// has not been opened, etc.)
			//
            count = 0;
			while (!done) {
                ++count;
                if(vlen < 1 || count > 50) {
                    debugTrace();
                    if (!loc.npcstuckwarn) {
                        "\bWarning: NPCs appear not to be finding any
                        valid exits in \"<<loc.roomTitle>>\"! Please ask 
                        the cave management to check the room connection 
                        table.\b";
                        loc.npcstuckwarn = true;
                    }
                    self.scatter(loc);
                    dest = self.loclist[i];
                    break;                    
                }
				dir = loc.NPCexits[rand(len)+1];
				dest = loc.(dir);

                if(dest && dest.ofKind(Door))
                    dest = dest.NPCdest;

				if (dest) {
                    if(dest.NPCvalid) {
                        // DJP - avoid going to a previous
                        // location in the first 3 attempts.  If no dwarves
                        // have been killed, we look at the previous loc of
                        // the current dwarf.  If a dwarf has been killed,
                        // there won't be a one-to-one correspondence and
                        // we instead look at whether any dwarf was
                        // previously at the proposed location.
                        if (count <= 3) {
                            if (oldloclist.length() != loclist.length())
                                prevloc = (oldloclist.indexOf(dest) != nil);
                            else
                                prevloc = (oldloclist[i] == dest);
                            if (!prevloc)
                                done = true;
                        }
                        else
                            done = true;
                    }
                }
			}

			//
			// Set new destination.
			//
			newloclist += dest; 

			//
			// If the dwarf didn't move, he has an opportunity
			// to attack.
			//
			if (loc == dest && !noAttack) {
                if(melocs.indexOf(loc) != nil && rand(100) <= global.dwarfattack)
                    attackers++;

				//
				// Print some debugging info if in debug mode
				//
				if (global.debug) {
					P();
					"Dwarf stays at \"<<dest.roomTitle>>\".\n";
				}
			}
			else {
				//
				// Print some debugging info if in debug mode
				//
				if (global.debug) {
					P();
					"Dwarf moves from \"<<loclist[i].roomTitle>>\" to
                    \"<<dest.roomTitle>>\"\n";
				}
			}
		}

		//
		// Replace old locations with destinations.
		//
        oldloclist = loclist;
		loclist = newloclist;
        global.currentActor = currentsave;
        loc = nil;

		tell();
//"\ndwarves.move(exit)\n";
        noAttack = nil;
        oldmelocs = melocs;
	}

	//
	// Tell the player what's going on with the dwarves.
	//
	tell() {	
		local	count;
		local   melocs = [];
        local   i = gPlayerChar.location;
//"\ntell(enter)\n";

        // Do nothing if the room is dark
        if (!i.isLit) {
            self.attackers = 0;
            return;
        }

		
        //
		// Count how many dwarves are in the room with the player.
		//
        while (i) {
            melocs += i;
            if (i == i.getOutermostRoom)
                i = nil;
            else
                i = i.location;
        }
        count = melocs.intersect(loclist).length();

		//
		// If any dwarves are in the room with the player and
		// the axe hasn't been thrown yet, throw the axe and
		// scatter the dwarves.
		//
		if (count > 0 && axe.location == nil) {
			P(); I();

			"A little dwarf just walked around a corner, 
			saw you, threw a little axe at you which 
			missed, cursed, and ran away. ";

			axe.moveInto(location); // not applying throwHitDest here

			//
			// Scatter any dwarves in the room.
			//
			scatter();

			//
			// No dwarves in the room.  Be sure we take back
			// those attacks too...
			//
			count = 0;
			attackers = 0;
		}

		//
		// Tell the player if any dwarves are in the room with him,
		// or if any are nearby.
		//
		if (count == 0) {
			//
			// If no dwarves are in the room, but at least
			// one dwarf is in an adjacent location, tell
			// the player he hears something.
			//
			// (Only the pirate makes noise in the original,
			// which seem a bit strange and not as much fun.)
			//
			if (anyadjacent()) {
				P(); I(); "You hear the pitter-patter 
				of little feet. ";
			}
		}
		else if (count == 1) {
			P(); I();
			"There is a threatening little dwarf in the 
			room with you! ";
		}
		else if (count > 1) {
			P(); I();
			"There are <<count>> threatening 
			little dwarves in the room with you! ";
		}

		//
		// Handle dwarf attacks.
		//
		if (attackers > 0) {
			if (attackers == 1) {
				if (count == 1)
					" He throws a knife at you! ";
		 		else
					" One of them throws a knife 
					at you! ";
			}
			else {
				if (attackers == count) {
					if (count == 2)
						" Both of them throw 
						knives at you! ";
					else 
						" All of them throw 
						knives at you! ";
				}
				else {
					"<<attackers>> of them throw 
					knives at you! ";
				}
			}

			//
			// Curtains for our hero?!
			//
            if(gPlayerChar.protection < 3) {
                count = 0;
                for (i = 0; ++i <= self.attackers; ) {
                    if (rand(100) <= global.dwarfaccuracy)
                        count++;
                }

                P(); I();
                if (count > 0) {
                    if (count == self.attackers) {
                        if (count == 1)
                            "It gets you! ";
                        else if (count == 2)
                            "Both of them get you! ";
                        else
                            "All of them get you! ";
                    }
                    else if (count == 1) {
                        "One of them gets you! ";
                    }
                    else {
                        "<<count>> of them get you!";
                    }

                    die();
                }
                else {
                    if (attackers == 1) 
                        "It misses you! ";
                    else if (attackers == 2)
                        "Both of them miss you! ";
                    else
                        "They all miss you! ";
                }
            } else if (gPlayerChar.protection <= 5) {
                if (attackers == 1)
                    "Something seems to deflect the knife away from you! ";
                else if (attackers > 1)
                    "Something seems to deflect the knives away from
                    you! ";
            } else if (gPlayerChar.protection >= 6) {
                if (attackers == 1) {
                    "Something very strange happens.  The knife stops in
                    mid-air, turns round, and stabs the dwarf in the
                    chest!  The body disappears in a puff of greasy
                    black smoke. ";
                    if (gPlayerChar.protection < 9)
                        hoist_petard(attackers);
                    else {
                        "Normally the knife would also disappear, but it
                        doesn't. ";
                        search_and_destroy(attackers);
                    }
                    hoist_petard(1);
                }
                else if (attackers > 1) {
                    "Something very strange happens.  The knives stop in
                    mid-air, turn round, and stab your attackers in the
                    chest!  The bodies disappear in puffs of greasy black
                    smoke. ";
                    if (gPlayerChar.protection < 9)
                        hoist_petard(attackers);
                    else {
                        "Normally the knife would also disappear, but it
                        doesn't. ";
                        search_and_destroy(attackers);
                    }
                }
            }
		}
//"\ntell(exit)\n";
	}
    
    numberhere(actor) { // DJP - a convenient method to return the
                           // number of dwarves in the player's room.
        local    melocs = [];
        //
        // Count how many dwarves are in the room with the player.
        //
        local count = 0;
        local i = actor.location;
        while (i) {
            melocs += i;
            if (i == i.getOutermostRoom)
                i = nil;
            else
                i = i.location;
        }
        for (i = 0; +i <= length(loclist); ){
            if(melocs.indexOf(loclist[i]) != nil)
                ++count;
        }
        return count;
    }
;

/*
 * The player can never get the dwarves' knives (that would be too easy),
 * but we'll let him examine them anyway.
 */
DwarfKnives: Thing 'dwarf\'s knife;sharp nasty dwarvish dwarven dwarfish'
    desc { verifyRemove(gPlayerChar); }

    location {
        return Dwarves.location;
    }

/* DJP: 'Take knife' gives the message about knives vanishing. */
    dobjFor(Take) {
        verify() {
            verifyRemove(gPlayerChar);
        }
    }
    verifyRemove(actor) {
        illogical('The dwarves\' knives vanish as they strike the walls of the cave. ');
    }

    iobjFor(AttackWith) {
        verify() {
            illogical('You don\'t have the dwarf\'s knife! ');
        }
    }

#if 0
    dobjGen(a, v, i, p) =
    {
        if ((v <> inspectVerb) and (v <> gonearVerb) and (v <> countVerb))
        {
            self.verifyRemove(a);
            exit;
        }
    }
    iobjGen(a, v, d, p) = {
        if (v = askVerb or v = tellVerb or v = waveVerb)return;
        self.dobjGen(a, v, d, p);
    }
    verDoCount(actor) = {self.verifyRemove(actor);}
#endif
;



pirates: NPC 'pirate;;;him'
    seen = nil
    loc = nil  // DJP

    noStone = nil       // special tracking item
    
    location() {
        // DJP - during NPC movement, the location method returns the 
        // room of interest.
        if(loc && (global.currentActor == self)) {
             return loc;
        }
        // The Pirate isn't a real actor, so in other cases we pretend he
        // doesn't exist.
        else
            return nil;
    }

    // No need for attacking,giving,feeding etc.

    //
	// Place pirates in starting locations
	//
	place() {
		local	i, loc, r;
        local currentsave = global.currentActor;
        global.currentActor = self;

		loclist = [];
		for (i = 0; ++i <= global.pirateCount; ) {
			//
			// If there are any fixed starting locations
			// for pirates left, put this pirate in the
			// next one.  Otherwise place him randomly.
			//
			loc = nil;
			if (global.pirateloc.length() >= i)
				loc = global.pirateloc[i];

			//
			// Invalidate initial location if it's off limits
			// to NPC's.
			//
			if (loc && loc.NPCvalid)
                loc = nil;

			//
			// Make sure we get a real location.
			//
			while (loc == nil) {
				r = rand(global.NPCrooms.length()) + 1;
				loc = global.NPCrooms[r];
                if (!loc.NPCvalid)
                    loc = nil;
			}
			
			//
			// Add this pirate's location to the list.
			//
			loclist += loc;
		}
        global.currentActor = currentsave;
	}

    //
	// Move pirates.
	//
	move() {
		local	j, len, dest, done, dir, count;
        local vlen = 0;
        local melocs = [];
        local i = gPlayerChar.location;
        local currentsave = global.currentActor;

//        "\npirates.move(enter)\n";
		//
		// Move each remaining pirate.
		//
		// If the pirate is currently in the player's location,
		// he stays where he is.
		//
		// If a pirate is in a location adjacent to the player's
		// current location, he moves into the player's location
		// if he can.  We limit this with the ptenacity global.
		//
		// If a pirate isn't adjacent to the player, he just moves
		// around randomly.
		//
        while(i) {
            melocs += i;
            if(i == i.getOutermostRoom)
                i = nil;
            else
                i = i.location;            
        }

        // go through all of the pirates (typically 1)
        global.currentActor = self;
		newloclist = [];
		for (i = 0; ++i <= loclist.length();) {
			//
			// Haven't found a new location yet.
			//
			done = nil;
            len = loclist[i].NPCexits.length();

			//
			// In player's current location?
			//
			if (melocs.indexOf(loclist[i]) != nil) {
				dest = loclist[i];	// stay put
				done = true;

                //
                // Try each exit and see if we can reach the
                // player.  If we have an exit that leads to
                // the player, we know it's an OK destination
                // location, since we pruned off all the noNPCs
                // rooms when we constructed the exit lists. 
                //
            } else {
                
                for (j = 0; ++j <= len; ) {
                    dir = loclist[i].NPCexits[j];
                    dest = loclist[i].(dir);
                    
                    if(dest && dest.ofKind(Door))
                        dest = dest.NPCdest;
                    if (dest) {
                        if (dest.NPCvalid) vlen++;
                    }

                    //
                    // We need to check the destination
                    // to be sure it exists.  It may be
                    // nil if we called an NPCexit method.
                    //
                    if (dest && melocs.indexOf(dest) != nil) {
                        if(dest.NPCvalid) {
                            //
                            // DJP - renamed ptenacity to pspotfromadj
                            // for consistency.
                            //
                            // Will this pirate spot the player?
                            // (note: ptenacity is not defined because
                            // the pirate 'scatters' after seeing the
                            // player, rather than continuing to follow
                            // the player.)
                            //
                            if (rand(100) <= global.pspotfromadj)
                                done = true;
                            break;
                        }
                    }
                }
            }
            
			//
			// Have we found a destination yet?  If not,
			// move pirate to a randomly selected adjacent
			// location.
			//
			// We need to check the destination because
			// the NPCexit methods in the rooms can sometimes
			// return nil.  (For example, when the crystal
			// bridge doesn't exist yet, the giant's door
			// has not been opened, etc.)
			//
            count = 0;
			while (!done) {
                if(vlen < 1 || count > 50) {
                    debugTrace();
                    if (!loc.npcstuckwarn) {
                        "\bWarning: NPCs appear not to be finding any
                        valid exits in \"<<loc.roomTitle>>\"! Please ask 
                        the cave management to check the room connection 
                        table.\b";
                        loc.npcstuckwarn = true;
                    }
                    scatter(loc);
                    dest = loclist[i];
                    break;
                }
				dir = loclist[i].NPCexits[rand(len)+1];
				dest = loclist[i].(dir);
                if(dest && dest.ofKind(Door))
                    dest = dest.NPCdest;
                if (dest) {
                    if (dest.NPCvalid) {
                        // DJP - avoid going to a previous
                        // location in the first 3 attempts.  If no pirates
                        // have been removed, we look at the previous loc
                        // of the current pirate.  If a pirate has been
                        // removed, there won't be a one-to-one
                        // correspondence and we instead look
                        // at whether any pirate was previously
                        // at the proposed location.
                        if (count <= 3) {
                            if (oldloclist.length() != loclist.length())
                                prevloc = (oldloclist.indexOf(dest) != nil);
                            else
                                prevloc = (oldloclist[i] == dest);
                            if (!prevloc)
                                done = true;
                        }
                        else
                            done = true;
                    }
                }
			}

            // Do we have a new location?
            if(done) {
                //
                // Set new destination.
                //
                newloclist += dest; 

                //
                // Print some debugging info if in debug mode
                //
                if (loclist[i] == dest) {
                    if (global.debug) {
                        P();
                        "Pirate stays at \"<<dest.roomTitle>>\".\n";
                    }
                }
                else {
                    if (global.debug) {
                        P();
                        "Pirate moves from \"<<loclist[i].roomTitle>>\" to
                        \"<<dest.roomTitle>>\".\n";
                    }
                }
            } else
                newloclist += loclist[i];
		}
        global.currentActor = currentsave;

		//
		// Replace old locations with destinations.
		//
        oldloclist = loclist;
		loclist = newloclist;

		tell();
//        "\npirates.move(exit)\n";
	}

	//
	// Tell the player what's going on with the pirates.
	//
    tell() {
		local   o, t, count, snagged, left_pendants = 0, left_ring = nil;
    
//        "\npirates.tell(enter)\n";
        local   melocs = [];
        local   i = gPlayerChar.location;

		//
		// Count how many pirates are in the room with the player.
		// (We really only need to know if there are any at all,
		// but this is just as easy.)
		//
        while (i) {
            melocs += i;
            if (i == i.getOutermostRoom)
                i = nil;
            else
                i = i.location;
        }
		count = melocs.intersect(loclist).length();
						
		//
		// Tell the player if any pirates are nearby.
		//
		if (count == 0) {
			//
			// If no pirates are in the room, but at least
			// one pirate is in an adjacent location, tell
			// the player he hears something.
			//
			if (anyadjacent()) {
				P(); I();
				"There are faint rustling noises from 
				the darkness behind you. ";
			}
		}
		else if (count > 0) {
			//
			// A pirate has snagged the player.
			// Move any treasures the player is carring
			// to the pirate's repository, currently
			// hard-coded as Dead_End_13 because there's
			// code in that room that can't easily be
			// made general.
			//
			// Since the player may be keeping his treasures
			// in containers, it's actually easier just
			// to search through the global list of
			// treasures and check each one's location to
			// see if it's in the player, rather than
			// recursively checking all the player's belongings
			// and seeing if they're treasures.  (Also, we want
			// to get treasures that are just lying around in
			// the room too.)
			//
			snagged = 0;
            noStone = nil;
            local locn = gPlayerChar.location.getOutermostRoom;
			for (i = 0; ++i <= length(global.treasurelist); ) {
				t = global.treasurelist[i] ;
                // a treasure is eligible for taking if it is visible,
                // or (in the case of the glowing stone) its container
                // is visible and contains the treasure.
				if (t.isIn(locn) || (t == glowingStone && t.location == canister
                                            && canister.isIn(locn))) {
                    // DJP - pirate ignores the glowing stone when
                    // the canister is unavailable
                    if ((t == glowingStone) && !canister.isIn(locn)) {
                        noStone = true;
                        continue;
                    }
                    // DJP - have the pirate put the glowing stone into
                    // the canister and close it.
                    else if (t == glowingStone){
                        t.moveInto(canister);
                        canister.makeOpen(nil);
                    }
                    // DJP - deny hard-to-get treasures to the pirate.
                    // For example, the pirate shouldn't take the pyramid
                    // from the Dark Room unless it is lit.  No check is
                    // needed for the sword or chain because their
                    // locations are NoNPC. BJS: The same thing goes
                    // for most 550-point treasures.
                    if (t == persianRug && t.location == dragon.location)
                        continue;
                    else if (t == platinumPyramid && t.location == inDarkRoom &&
                        !inDarkRoom.isLit)
                            continue;
                    else if (t == cloak && !t.moved)
                        continue;
                    // In the 551-point game and derivatives, don't let the 
                    // pirate lock the mithril ring in the chest if the keys
                    // are inaccessible, or are located on the far side of
                    // the stone bridge (need the ring to get there)
                    else if (t == mithrilRing && global.newgame) {
                         local keytop = setOfKeys.getOutermostRoom;
                         if(keytop != nil) {
                             if(keytop.wino_wsbridge) {
                                 left_ring = true;
                                 continue;
                             }
                         }
                    }
                    // Also don't let the pirate lock any pendant in the
                    // chest if the keys are accessible only via Transindection
                    else if (t.ofKind(PendantItem)) {
                         local keytop = setOfKeys.getOutermostRoom;
                         if(keytop != nil) {
                             if(keytop.analevel != 0 || keytop.isolated) {
                                 left_pendants++;
                                 continue;
                             }
                         }
                    }
                    
                    // BJS: The 550-point version makes an exception
                    // for the ring, but I'm not sure why...
                    // The sword is not a treasure.
                    // decide on actual object to
                    // move - in case of wine, move
                    // the cask.
                    if(t.mycont)
                        o = t.mycont;
                    else
                        o = t;
                    // decide on where the object is
                    // to go - in the chest if possible, otherwise in
                    // Dead_End_13 (N.B. chest is full in old game)
                    if(o == treasureChest || !treasureChest.accepts_item(o)
                        || ((treasureChest.bulkCapacity - addbulk(treasureChest.contents)) < o.bulk ))
                            o.moveInto(deadEnd13);
                    else
                        o.moveInto(treasureChest);
					++snagged;
				}
			}

			//
			// Print a message telling the player what happened.
			//
			if (snagged > 0) {
				P();
				I(); "Out from the shadows behind you 
				pounces a bearded pirate!  <q>Har, 
				har,</q> he chortles.  <q>I'll just take 
				all this booty and hide it away with 
				me chest deep in the maze!</q>  He 
				snatches your treasure and vanishes 
				into the gloom. ";
                global.gendaemon;
			}
			else {
				//
				// In the original code, if you weren't
				// holding the lamp, you just wouldn't
				// see the pirate when you weren't
				// carrying any treasures.  This seems
				// bogus, so I've added a conditional here.
				//
				P();
				I(); "There are faint rustling noises 
				from the darkness behind you.  As you 
				turn toward them, ";

				if (brassLantern.isIn(Me))
					"the beam of your lamp falls 
					across";
				else
					"you spot";

				" a bearded pirate. He is carrying a lamp and a
				large chest.  <q>Shiver me timbers!</q> 
				He cries, <q>I've been spotted!  I'd 
				best hide meself off to the maze to 
				hide me chest!</q> With that, he 
				vanishes into the gloom. ";
			}
            if (noStone) {
                noStone = nil; P(); I();
                "You realize that the pirate seems to have
                overlooked the glowing stone.  I wonder if
                he knows something that you don't? ";
            }
            if (left_pendants > 0) {
                "You notice that the pirate seems to have missed your
                pendant";
                if(left_pendants > 1)"s";
                ".  That's just as well - he locks his treasures in the chest,
                and you may need to use the pendant";
                if(left_pendants > 1)
                    "s";
                " to get to the keys. ";
            }
            if (left_ring) {
                "For some reason the pirate hasn't taken your mithril ring.
                That's just as well - he locks his treasures in the chest, and
                the keys are on the far side of the stone bridge! ";
            }

			//
			// Install the treasure chest if it hasn't
			// already been installed.  No worries about
			// the chest appearing out of nowhere when
			// the player's at Dead_End_13, because the
			// pirate can't go there.  (It's off limits
			// to NPC's.)
			//
			if (!seen) {
				treasureChest.moveInto(deadEnd13);
                pirateMessage.moveInto(deadEnd14);
				seen = true;
			}

			//
			// Scatter any pirates in the room.
			//
			scatter();
		}
//"\npirates.tell(exit)\n";
	}
;

/*
 *   Call this routine to get the pirates and dwarves spun up properly
 */
dwarfPirateStart()
{
    // Place all the NPC's.  Run this at the start of the game (in ShowIntro)
    if(!global.NPCstarted) {
    
//        global.debug = true;    // so we can see what is going on with dwarves and pirates
        
        Dwarves.place();
        new Daemon(Dwarves, &move, 1);    

        if (!treasureChest.seen) 
        {
            pirates.place();
            new Daemon(pirates, &move, 1);
        }

        global.NPCstarted = true;
    }
}
