#charset "us-ascii"

#include <tads.h>
#include "advlite.h"

/* 
 *   This file contains various modifications to the Thing class corresponding to the those in the
 *   advmods.t and ccr-thx.t files
 */

modify Thing
    allversions = nil
    versionloc = nil
    fromloc = nil
    
    /* 
     *   Flag, should this thing be regarded as 'deleted' because it's not relevant to the current
     *   version of the game.
     */
    deleted =  nil
    
    /* Handling of additional verbs - mainly correspondinng to ccc-thx.t */
    cannotEatMsg = 'I think I just lost my appetite. '
    
    dobjFor(Cross)
    {
        preCond = [touchObj]
        verify()
        {
            if(!isCrossable)
                illogical(cannotCrossMsg);
        }
        
        
    }
    
    isCrossable = nil
    cannotCrossMsg = '{I} {can\'t} cross {that dobj). '
    
    dobjFor(Wave)
    {
        preCond = [objHeld]
        verify()
        {
            if(!isWaveable)
                illogical(cannotWaveMsg);
        }
        
        action()
        {
            say(waveNoEffectMsg);
        }
    }
    
    isWaveable = !isFixed
    cannotWaveMsg = '{I} {can\'t} wave {that dobj}. '
    waveNoEffectMsg = 'Waving {the dobj} achieves nothing. '
    
    dobjFor(OpenWith)
    {
        preCond = [touchObj]
        verify() { verifyDobjOpen();}
    }
    
    iobjFor(OpenWith)
    {
        preCond = [objHeld]
        
        verify()
        {
            if(gVerifyIobj == self)
                illogicalSelf('[I} {can\'t} open anything with itself. ');
            
            illogical('{I} {can\'t} open anything with {that iobj}. ');
        }
    }
    
    isReplaceable = nil
    cannotReplaceMsg = '{I} {don\'t know} how to replace {that dobj}. '
    
    dobjFor(Replace)
    {
        preCond = [touchObj]
        verify()
        {
            if(!isReplaceable)
                illogical(cannotReplaceMsg);
        }
    }
    
    isChangeable = nil
    cannotChangeMsg = '{I} {don\'t know} how to change {that dobj}. '
    
    dobjFor(Change)
    {
        preCond = [touchObj]
        verify()
        {
            if(!isChangeable)
                illogical(cannotChangeMsg);
        }
    }
    
    dobjFor(Rub)
    {
        preCond = [touchObj, objVisible]
        
        verify() { }
        action()
        {
            "Rubbing {the dobj} achieve{s/d} nothing. ";
        }
    }
    
    dobjFor(Water)
    {
        preCond = [touchObj]
        
        verify()
        {
            illogical('{That subj dobj} hardly seem{s/ed} like something {i} should water. ');
        }
    }
    
    dobjFor(Oil)
    {
        preCond = [touchObj]
        
        verify()
        {
            illogical('{That subj dobj} hardly seem{s/ed} like something {i} should oil. ');
        }
    }
    
    dobjFor(Kick)
    {
        preCond = [touchObj]
        action()
        {
            display(&kickNoEffectMsg);
        }       
        
    }
    kickNoEffectMsg = 'That does no good at all! '
    
    dobjFor(Fill)
    {
        preCond = [touchObj]
        
        verify()
        {
            illogical(cantFillMsg);
        }       
    }
    
    cantFillMsg = '{I} {can\'t} fill {that dobj}. '
    
    dobjFor(FillWith)
    {
        preCond = [touchObj]
        
        verify()
        {
            illogical(cantFillMsg);
        }       
    }
    
    iobjFor(FillWith)
    {
        preCond = [touchObj]
        
        verify()
        {
            illogical('{I} {can\'t} fill anything with {that dobj}' );
        }
    }
    
    dobjFor(Empty)
    {
        preCond = [touchObj]
        
        verify()
        {
            illogical(cantEmptyMsg);
        }       
    }
    
    cantEmptyMsg = '{I} {can\'t} empty {that dobj}. '
    
    dobjFor(Wake)
    {
        preCond = [objVisible]
        
        verify()
        {
            illogical(cantWakeMsg);
        }       
    }
    
    cantWakeMsg = '{The subj dobj} {doesnot appear} to be asleep. '
    
    dobjFor(Feed)
    {
        preCond = [objVisible]
        
        verify()
        {
            illogical(cantFeedMsg);
        }       
    }
    
    cantFeedMsg = '{The subj dobj} {doesnot need} feeding. '
    
    dobjFor(FeedWith)
    {
        preCond = [objVisible]
        
        verify()
        {
            illogical(cantFeedMsg);
        }          
    }
    
    iobjFor(FeedWith)
    {
        preCond = [objHeld]
        verify()
        {
            if(!canFeedWithMe)
                illogical(cantFeedWithMsg);
            if(self == gVerifyDobj)
                illogicalSelf('{I} {can\'t} feed {the iobj} with {himself iobj}. ');
        }      
    }
    
    dobjFor(BlastWith)
    {
        verify() { illogical('Blasting requires dynamite. '); }
    }
    
    canFeedWithMe = isEdible
    cantFeedWithMsg = '{I} {can\'t} feed {the dobj} with {that iobj}. '
    
    dobjFor(Yank)
    {
        preCond = [touchObj]
        verify()
        {
            if(isIn(gActor))
                verifyDobjDrop();
            else if(!yankObj)
                verifyDobjTake();
        }
        check()
        {
            if(!yankObj)
                "OK, OK, no need to be grabby! ";
            else if(isIn(gActor))
                checkDobjDrop();
            else
                checkDobjTake();
        }
        action()
        {
            if(isIn(gActor))
                actionDobjDrop();
            else
                actionDobjTake();
        }
        
        report()
        {
            if(isIn(gActor))
                reportDobjDrop();
            else
                reportDobjTake();
        }
        
    }
    
    yankObj = nil
    
    iobjFor(YankFrom)
    {
        preCond = [touchObj]
        verify()
        {
            verifyIobjTakeFrom();
        }       
        check() { checkIobjTakeFrom(); }
        action() { actionIobjTakeFrom(); }
    }
    
    dobjFor(YankFrom)
    {
        preCond = [touchObj]
        verify()
        {
            if(!yankObj)
                verifyDobjTakeFrom();
            else if(!isIn(gVerifyIobj) && fromloc != gVerifyIobj)
                illogicalNow('{The dobj} isn\'t {in iobj}. ');
        
        }
        check() { checkDobjYank(); }
        action() {  actionDobjTakeFrom(); }
        report() {  reportDobjTakeFrom(); }
    }
    
    dobjFor(Use)
    {
        preCond = [objVisible]
        verify() { illogical('You\'ll have to be a bit more explicit than that. ');  }      
    }
        
    dobjFor(Dust) asDobjFor(Clean)
    dobjFor(DustWith) asDobjFor(CleanWith)
    
    iobjFor(DustWith)
    {
        preCond = [objHeld]
        verify() { illogical('{The iobj} will hardly serve as a broom' ); }
    }
    
    cannotCleanWithMsg = '{The iobj} {is}n\'t much use for cleaning. '
    
    dobjFor(Blow)
    {
        preCond = [objHeld]
        verify() { illogical('{I} {can\'t} blow {that dobj}. '); }
       
    }
    
    dobjFor(Play)
    {
        preCond = [touchObj]
        verify() { illogical('{I} {can\'t} play {that dobj}. '); }
       
    }
    
    
    /* Other mods roughly corresponding to mods to thing and item classes in TADS 2 advmods.t */
    
    actionMoveInto(loc)
    {
        if(global.extendMoveInto)
        {
            local actor;
            if(gActor)
                actor = gActor;
            else if(gPlayerChar.isIn(loc))
                actor = gPlayerChar;
            
            if(actor)
            {
                meprevloc = actor.prevloc;
                metoploc = actor.getOutermostRoom;
            }
            
            //            moved = true; // alreadt standard in adv3Lite
            
            /*
             *   If this is a scoring object, add it to the checklist. If it is a non-empty
             *   container, add it and all its contents to the checklist.  If the object is a 
             *   container for liquids, add the wine to the list.
             */
                
            if(depositpoints != nil || contents.length > 0)
                global.checklist = global.checklist.appendUnique([self]);
            
            
            /* Shouldn't this bne implemented on the objects in questoion? */
            // Special case: check for wine in the cask (which is a floating
            // item)
//            if ((self == cask || cask.isInside(self)) && cask.haswine)
//                global.checklist += wine_in_the_cask;
            
            if(bonusTreasure && !bonusFound)
            {
                local addpoints, transcoord;
                bonusFound = true;
                
                
                addpoints = takepoints != nil ? takepoints + depositpoints : 0;
                
                if(ofKind(Coin))
                {
                    global.coinsets++;
                    freshBatteriesAvailable++;
                }                
                if(ofKind(Treasure))                    
                {
                    if(global.treasuresToFind.indexOf(self) == nil)
                    {
                        
                        global.treasuresToFind += self;
                        global.treasures++;
                        /*
                         *.
                         *   Postpone cave closure if an extra treasure has // been added to the
                         *   list.
                         */
                        if(global.closure)
                        {
                            if(gActor.getOutermostRoom)
                                transcoord = actor.getOutermostRoom.analevel;
                            else
                                transcoord = 0;
                            if(transcoord != 0)
                                cancelCaveClosure(true, true);
                            else
                                cancelCaveClosure(nil, true);
                            
                        }
                        global.origTreasures++;
                        global.treasurelist = global.treasurelist.appendUnique([self]);         
                    }
                }
                else if(addpoints)
                {
                    global.pointobjlist = global.pointobjlist.appendUnique([self]);
                    global.pointobjs++;
                }
                if(addpoints)
                {
                    global.allpointslist += self;
                    global.extras += addpoints;
                    global.maxscore += addpoints;
                    global.maxhiked += addpoints;
                    gameMain.maxScore = global.maxscore;
                }
                
                
                
                
            }
        }
        
        inherited(loc);
    }
    
    mass = 1
    bulk = 1
    /* 
     *   The definition of the weight method now uses the mass property. In a 350 or 550-point game,
     *   the weight is zero.  In a 551 or 701-point game the weight is equal to the mass, or zero if
     *   the item is worn.
     */
    weight = ((global.oldGame || wornBy != nil ) ? 0 : mass)
    
    isLong = nil
    isLarge = nil
    isHuge = nil
    
    meprevloc = nil
    metoploc = nil
    bonusTreasure = nil
    bonusFound = nil
    list = []
    undiscovered = nil//?
    
    objClass = nil
    
    /* This will need some figuring out to get it to work for TADS 3 */
//    construct()
//    {
//        if(objClass == nil)
//            objClass = self;
//        
//        if(propDefined(&createloc))
//            moveInto(createloc);
//        
//        objClass.list += self;
//        isEquivalent = true;
//        
//    }
    
    // SECTION 5: Generic version-control rules

// All objects specific to the 350-point game are included in the 550-point
// version.  All objects in the 550-point and 551-point games are included 
// in the 701-point game.  If locations differ, the 701-point game uses the
// 551-point location.

   game550 = (game350)

   game701 { return (game550 || game551);}
    
    location701 
    {
        if (propDefined(&location551)) return location551;
        else if (propDefined(&location550)) return location550;
        else return location;
    }
    loclist701  
    {
        if (loclist551 != nil) return loclist551;
        else if (loclist550 !=  nil) return loclist550;
        else return nil;
    }
/* BJS: Everything in the 550-point version is also in the 580-point
 * version. */
   game580 = game550
   
   location580 
   {
        if (propDefined(&location550)) return location550;
        else return location;
   }
   loclist580 
   {
        if (loclist550 != nil) return loclist550;
        else return nil;
   }

/* 
   We define default game701p and location701p methods for the extended
   version. 
 */

   game701p = game701
   location701p = location701
   loclist701p = loclist701

   hasOpened = nil
   makeOpen(stat)
   {
        inherited(stat);
        if(stat)
            hasOpened = true;
   }
    
;

