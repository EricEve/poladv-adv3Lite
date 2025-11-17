#charset "us-ascii"
#include "advlite.h"

basilisk: NPC 'basilisk'
    petrified() {}
    petrifier() {}
;

djinn: Actor 'djinn;;;him'
;

goblins: Feedable, Chaser 'gooseberry goblins;silent giggling vicious little slavering of[prep]
    ;horde goblin;them'
    "Each goblin stands eight inches high on a pair of spindly
    black legs, has a globular, spine-covered body resembling a
    giant gooseberry, a wide mouth filled with sharp teeth, and a
    pair of glittering little green eyes!"
    
    
    // Called once each turn that they chase the player.
    chaseMsg()    
    {
        if(locstay == 0) "You are being pursued by a vicious
                               horde of little gooseberry goblins!\n";
        switch(chase) 
        {
            case 1: "\nYou are surrounded by a horde of silent
                     little gooseberry goblins!";
                     break;
            case 2: "One of the gooseberry goblins begins
                     to giggle in a high-pitched voice.  Another
                     takes up the giggling, then another...  soon
                     all of them are giggling insanely and
                     jumping up and down with glee!";
                    break;
            case 3: "\nYou are surrounded by a giggling horde of
                     little gooseberry goblins!";
                    break;
            case 4: "The goblins are jumping up and down
                     frantically, and are working themselves
                     into a real slavering frenzy!!";
                    break;
            case 5: "\nYou are surrounded by a slavering horde
                     of gooseberry goblins!";
                    break;
            case 6: "With a shrill cry, the gooseberry
                     goblins hurl themselves upon you, tickling
                     you mercilessly.  You crush and hurl away
                     several of them, but are soon borne down
                     to the ground by the endless attack.  The
                     goblins then gleefully rip out your throat,
                     and you sink into unconciousness.";
                    break;
            default: break; // Their first message is given
        }                       // when they appear.
        if(chase > 5) die();
        if(basilisk.isIn(location) && chase > 1)
             "\nFortunately, the sound is not loud enough to wake
             the basilisk.\n";     // BJS: added.
    }
    magicMsg()
    {
        "Congratulations!  The goblins are unable to follow you.";
       banish(); // Although I don't think the player will
                     // actually be able to escape this way.
                     // DJP - although the code allows the player more turns
                     // before the goblins kill him, there's no possibility of
                     // getting to Fake_Y2 soon enough.
    }
    SlippMsg() {magicMsg();}
    
    summon(loc) 
    {        
        "Suddenly and without warning, there appears from
        within the very cave walls around you a horde of vicious
        little goblins!  Each one stands about eight inches high
        on a pair of spindly black legs, has a globular, spine-covered
        body resembling a giant gooseberry, a wide mouth filled with
        sharp teeth, and a pair of glittering little green eyes!<.p>";
                
        inherited(loc);
        
    }
    backtrackAct = "\nYou leap over the goblins.\n"    
;

actionThrowAt(Weapon dobj, goblins iobj)
{
    dobj.doInstead(AttackWith, dobj, iobj);
}

actionThrowAt(dragonTeeth dobj, goblins iobj)
{
    "As each of the dragon's teeth
    strikes the ground, a fully-armed human
    skeleton springs up from where it struck
    and leaps to your defense!  The skeletal
    warriors attack the vicious gooseberry
    goblins and drive them away in screaming
    panic;  they then salute you with their
    ancient and rusty swords, and fade silently
    into nothingness.";
    iobj.banish();  
    dobj.moveInto(nil);
    skip;
}

ogre: NPC 'ogre'
    exists = true
;

blob: Feedable, Chaser 'large white blob;translucent bouncing throbbbing roaring immense
    unfriendly looking unfriendly-looking ;rover'
    "It is six feet across and resembles a blob of
    translucent white jelly.  Although it looks massive, it is
    bouncing lightly up and down as though it were as light as
    a feather.  It is emitting a constant throbbing sound. "
    
    // ATTACKING 
    isAttackable = true
    futileToAttackMsg = 'You attack the strange blob, but bounce
        harmlessly off of its strong but very rubbery skin. '
    
    actionDobjAttackWith()
    {
        if(gIobj.ofKind(Weapon)) 
            "{The subj iobj} {cut} through the blob's body (?) without harming it. ";
        
        else if (gIobj == myHands) 
            actionDobjAttack();
        else "You'd be better off using your bare hands  than that thing!";
        
    }
    
    // KICKING
    dobjFor(Kick) asDobjFor(Attack)
    
    // THROWING
    actionIobjThrowAt()
    { 
        local o = gDobj;
        if (o.ofKind(ContLiquid)) 
            o = gDobj.mycont;
        if (o.ofKind(Weapon))
        {            
            actionDobjAttackWith();
            o.actionMoveInto(gActor.location.dropLocation);
        }
        else if (o == glassVial)
            ; // The multimethod should already have dealt with this
        
        else 
            "{The subj dobj} bounce{s/d} harmlessly off the blob's body.  You catch {him dobj} 
            on the rebound. ";
    }

    
    iobjFor(ThrowTo) asIobjFor(GiveTo)

   
    // GIVING -- uses class feedable defaults

    // FEEDING -- uses class feedable defaults

    // OTHER - chaser code etc.

    // Called once each turn that it chases the player.
    chaseMsg()
    {
        if(stayloc == 0 && chase > 11)
            "The blob bounces after you.\n";
        switch(chase) 
        {
            case 1: "The bubbling sound grows louder.";
            break;
            case 2: "The bubbling sound ends with a loud <i>splash</i>.";
            break;
            case 3: "A hollow, echoing <i>ROAR</i> sounds in the distance.";
            break;
            case 5: "A strange throbbing sound can be heard in the distance.";
            break;
            case 7: "The throbbing sound is growing louder.";
            break;
            case 9: "The source of the throbbing sound is
                approaching quickly.  Another hollow
                <i>ROAR</i> echoes through the cave.";
            break;
            case 11: "There is a loud <i>ROAR</i> only a short distance away!!";
            break;
            case 13: "Into view there bounces a horrible
                creature!!  Six feet across, it resembles
                a large blob of translucent white jelly;
                Although it looks massive, it is bouncing
                lightly up and down as though it were as
                light as a feather.  It is emitting a
                constant throbbing sound, and it <I>ROAR</i>s
                loudly as it sees you."; 
            isHidden = nil; // Now we can see the blob
            break;
            case 14: "There is an immense and unfriendly-looking
                blob in the room with you!"; break;
            case 15: "The blob <i>ROAR</i>s triumphantly
                and bounces straight at you with
                amazing speed, crushing you to the
                ground and cutting off your air
                supply with its body.  You quickly
                suffocate."; break;
            default: break; // The first message is given
        }                   // when it appears.
        if(basilisk.isIn(getOutermostRoom))
            "\nFortunately, the sound is not loud enough to wake
            the basilisk.\n";     // BJS: added.
        if(chase > 14) die();
    }
    MagicMsg = "Oops! Magic words aren't supposed to work when the blob is chasing you!"
    SlippMsg = "Oops! The slippers and the blob cannot exist together!"

    summon()
    {
        "From somewhere in the distance comes an ominous bubbling sound. ";
        startClosing(nil); // Security alert.
        isHidden = true; // presumably we can't see the blob till it comes into view
        inherited();
    }
    backtrackAct() { // Do nothing.
    }

    listenDesc  
    {
        switch(chase)         
        {
            case -1:
            case 0:
            case 1:
                "You hear a bubbling sound in the distance. ";
                break;
            case 2:
            case 3:
            case 4:
                "You hear nothing unexpected. ";
                break;
            case 5:
            case 6:
            case 7:
            case 8:
                "A strange throbbing sound can be heard in the distance. ";
                break;
            case 9:
            case 10:
            case 11:
            case 12:
                "A strange throbbing sound can be heard, approaching
                quickly. ";
                break;
            case 13:
            case 14:
            case 15:
                "\^<<theName >>is making a strange throbbing
                sound. It <i>ROAR</i>s as you look at it. ";
            break;
        }
    }
//    dobjCheck(a, v, i, p) = {
//        if(self.chase >= 13 or v = summonVerb or v = banishVerb or
//        v = gonearVerb or v = listenVerb)
//            return;
//        if(v = inspectVerb) {
//            "It hasn't yet come into view. ";
//            exit;
//        }
//        else {
//            "It's too far away. ";
//            exit;
//        }
//        exit;
//    }
//    iobjCheck(a, v, d, p) = {
//        if (v = askVerb or v = tellVerb) return;
//        self.dobjCheck(a, v, d, p);
//    }

    cannotEatMsg = 'Yeetttch!  I think I just lost my appetite. '
      
//    doSummon(actor) {
//        local waschasing := self.ischasing;
//            if (not waschasing) self.move; // initialize variables
//            inherited.doSummon(actor);
//            if (not waschasing) self.chase := 12; // make blob appear
//    }
   
;

slime: Feedable, Fixture 'slime; evil green of[prep]; sheet' @crack2
    "A sheet of evil-looking green slime swathes the floor to
     the south.  It is twitching and flowing as though aware of
     your presence."
    exists = true
    
    dobjFor(Cross)
    {
        verify() {}
        action()
        {
            "As you enter the passage, you are forced to
            brush up against some of the green slime.  Instantly
            it flows down and covers your body, and rapidly
            digests away all of your flesh.";
            die();
        }
    }
    
    specialDesc = "The passage to the south is swathed
           with sheets of evil-looking green slime, which
           twitch and flow as if aware of your presence. "
    
       
    
;

slimeRoom: Room
;