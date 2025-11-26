#charset "us-ascii"
#include "advlite.h"



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
    slippMsg() {magicMsg();}
    
    summon(loc) 
    {        
        "Suddenly and without warning, there appears from
        within the very cave walls around you a horde of vicious
        little goblins!  Each one stands about eight inches high
        on a pair of spindly black legs, has a globular, spine-covered
        body resembling a giant gooseberry, a wide mouth filled with
        sharp teeth, and a pair of glittering little green eyes!<.reveal goblins><.p>";
                
        actionMoveInto(loc);
        
    }
    backtrackAct = "\nYou leap over the goblins.\n"    
    
    dobjFor(Attack)
    {
        verify() {}
        action()
        {
            "You attack the goblins and manage to squash
            a few, but the others overwhelm you, forcing you to the ground
            and ripping out your throat. "; 
            die();
        }
    }
    
    dobjFor(AttackWith)
    {
        verify() {}
        action()
        {
            if (gIobj.ofKind(Weapon))
            {
                "You kill several of
                the gooseberry goblins with {the iobj},
                but the others swarm at you, force you to the ground, and rip
                out your throat."; 
                die();
            }
            else if (gIobj == myHands) 
                actionDobjAttack();
            else 
                "You'd be better off using your bare hands than that thing!";
        }
    }
    
    dobjFor(Kick) asDobjFor(Attack)
    
    iobjFor(GiveTo)
    {
        verify() {}
        action()
        {
            if(gDobj.ofKind(ContLiquid) && gDobj.myflag is in (&hasWater, &hasWine))
                doInstead(FeedWith, self, gDobj);
            else if(gDobj.ofKind(Food))
                doInstead(FeedWith, self, gDobj);
            else
                "The goblins show no interest in {the iobj}. ";
                
        }
    }
    
    dobjFor(Feed)
    {
        verify() {}
        action = "Goblins live exclusively on human flesh, and you
        can't spare any of your own to placate them.  On the other
        hand, I suspect that they're going to eat you pretty soon
        whether you like it or not - you'd better find some way
        of killing or driving them away!"
    }
    
    
    dobjFor(FeedWith)
    {
        verify() {}
        action()
        {
            if(gDobj.ofKind(ContLiquid) && gDobj.myflag is in (&hasWater, &hasWine))
                inherited();
            else
                actionDobjFeed();           
        }
    }
    
    
    actionIobjThrowAt()
    {
        "{I} miss{es/ed}. ";
        gDobj.actionMoveInto(gActor.location.dropLocation);
    }
    
    cannotTakeMsg = 'Probably not a wise idea. '
    cannotEatMag = 'Yeetttch!  I think I just lost my appetite. '
    
    checkDobjCount = "You haven't got time to hang around counting the goblins -- there
        are far to many. ";
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
    into nothingness. <.reveal goblins-banished>";
    iobj.banish();  
    dobj.moveInto(nil);
    skip;
}


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
    magicMsg = "Oops! Magic words aren't supposed to work when the blob is chasing you!"
    slippMsg = "Oops! The slippers and the blob cannot exist together!"

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

turtle: Feedable, Actor 'Darwin the Tortoise;large;turtle'
    "On the tortoise's back is inscribed, <q>I'm Darwin - ride me!</q> "
    
    specialDesc = "Darwin the tortoise is swimming in the reservoir nearby. "
    
    dobjFor(Board)
    {
        verify() {}
        action()
        {
            doInstead(Cross, reservoir);
        }
    }
    dobjFor(Enter) asDobjFor(Board)
    dobjFor(Ride) asDobjFor(Board)
    
;


basilisk: MultiLoc, Fixture 'basilisk'
    desc 
    {
        "I wouldn't wake it up if I were you.  ";
        if(gRoom == northBasilisk)
            "It is asleep, but is twitching
            and grumbling as if restless.";
    }
       
    game550 = true
    alive = true
    specialDesc()
    {
         if (gRoom == southBasilisk)
            "There is a basilisk lying
            in the corridor to the north, snoring quietly. ";
        else
            "There is a basilisk
            in the corridor to the south.  It is
            asleep, but twitching and grumbling
            as if restless.";
    }
    
    locationList = [northBasilisk, southBasilisk]
    
    dobjFor(Attack)
    {
        verify() {}
        action()
        {
            "You attack the basilisk mightily. It instantly
            awakens and looks you dead in the eye, and
            your body turns into solid rock. ";
            die();
        }
    }
    
    dobjFor(AttackWith)
    {
        verify() {}
        action()
        {
            if (gIobj.ofKind(Weapon)) 
            {
                "{The subj iobj} rebound{s/ed} harmlessly from the
                basilisk's tough scales.  The basilisk awakens,
                grunting in shock, and glares at you.  You are
                instantly turned into a solid rock statue (and
                not a particularly impressive one, at that).";
                die();
            }
            else if (gIobj == myHands) 
                actionDobjAttack();        
            else 
                "You'd probably be better off using your
                bare hands than that thing!";        
        }
    }

    dobjFor(Kick) asDobjFor(Attack)
    
     // For THROW AT see multimethod definitions below
    // GIVING
    iobjFor(GiveTo) {verify() {illogical(badIdeaMsg); }}    
    
    badIdeaMsg = '{I} couldn\'t do that without waking
                the basilisk, which would be a very bad idea. '
    // FEEDING 
    
    dobjFor(Feed) {verify() {illogical(badIdeaMsg); }}
    
    dobjFor(Wake)
    {
        verify() {}
        action()
        {
            if (metalPlate.isIn(gActor)) petrified();
            else petrifier();
        }
            
    }
    
    petrified() 
    {
         "The basilisk stirs grumpily and awakens, peering sleepily
        about.  It sees its reflection in the metal plate that
        you are carrying, shudders, and turns into solid granite. <.p>";
        
        alive = nil;
        basiliskStatue.moveInto(locationList);
        moveInto(nil);
    }
    petrifier() 
    {
        "The basilisk stirs grumpily and awakens, peering sleepily
        about.  It spies you, growls, and stares you straight in the
        eye.  Your body is instantly petrified. ";
        
        die();
    }
    
    verifyDobjRub() { illogical('Don\'t be ridiculous! '); }    
;

/* THROW AT handling for the Basilisk */
actionThrowAt(Weapon dobj, basilisk iobj)
{
    dobj.doInstead(AttackWith, basilisk);
    skip;
}

actionThrowAt(glassVial dobj, basilisk iobj)
{
    dobj.actionDobjThrowAt();
    skip;
}

actionThrowAt(Thing dobj, basilisk iobj)
{
    dobj.doInstead(GiveTo, dobj, iobj);
    skip;
}

basiliskStatue: MultiLoc, Fixture 'petrified basilisk; desd of[prep];statue'
    "It looks just the same as it did before it was petrified. "
    
    specialDesc =  "There is a petrified basilisk in the corridor to the 
        <<gRoom == southBasilisk ? 'north' : 'south'>>."
        
    
    cannotAttackMsg = 'You\'ve already done enough damage! '
    cannotBreakMsg = cannotAttackMsg
;


djinn: Actor 'twelve-foot tall djinn;twelve foot;genie;him'
    "The djinn seems impatient for you to open the pentagram. "
    specialDesc = "There is a twelve-foot djinn standing in the center
            of the pentagram, glowering at you. "
    
    phugggtell 
    { 
        if(phugggVerb.isused) return;
        
        "<.p>A large phosphorescent cloud of smoke drifts into
         view, and a large mouth and two dark eyes take shape
         on the side.  One of the eyes winks at you, and the
         djinn's deep voice says <q>GREETINGS AGAIN, MORTAL.  I
         HAVE REMEMBERED A PIECE OF ANCIENT LORE THAT I LEARNED
         FROM MY AUNT, AN AFREET OF GREAT KNOWLEDGE.  THERE
         IS ANOTHER MAGIC WORD THAT YOU MIGHT FIND OF USE IF
         YOU SHOULD EVER FIND YOURSELF BEING ATTACKED BY THOSE
         PESTIFEROUS DWARVES.  YOU SHOULD USE IT ONLY AS A LAST
         RESORT, THOUGH, SINCE IT IS A MOST POTENT WORD AND IS
         PRONE TO BACKFIRE FOR NO OBVIOUS REASON;  ALSO, IT
         SHOULD NEVER BE USED NEAR WATER OR NEAR ANY SHARP
         WEAPON OR THE RESULTS MAY BE MOST UNFORTUNATE.  THE
         WORD IS <q>phuggg</q></q>, whispers the djinn, <q>AND IT MUST
         BE PRONOUNCED CAREFULLY IF IT IS TO HAVE THE PROPER
         EFFECT.  FAREWELL AGAIN, AND GOOD LUCK!</q> With that,
         the djinn-cloud drifts away out of sight.<.p>";       
    }
    
    phugggtime = 5
  
;


ogre: Feedable, Actor 'nasty ogre; large nasty-looking' @glassyRoom
    "The ogre looks exceptionally large and nasty."
    game550 = true
    exists = true
    
    specialDesc = "There is a large, nasty-looking ogre blocking your path! "    

    // ATTACKING
    
    dobjFor(Attack)
    {
        action()
        {
            "What, with your bare hands?\b> ";
            if(yesOrNo())
                nicetry();
            else
                "Probably wise. ";            
        }
    }
        
    nicetry()
    {
        if (rand(2) == 1)
            "You attack the ogre, but he fends off
            your attack easily and comes very close
            to crushing your skull with *his* bare
            (but extremely strong) hands.  You are
            forced to retreat in disgrace. ";
        else {
            "You attack the ogre -- a brave but foolish action.
            He quickly grabs you and with a heave of his
            mighty arms rips your body limb from limb. ";
            die();
        }
    }
    
    dobjFor(AttackWith)
    {
        verify() {}
        action()
        {
            if (gIobj.ofKind(Weapon)) 
            {
                "The ogre contemptuously catches {the iobj}
                in mid-swing, rips {him iobj} out of {my} hands, and
                uses {him iobj} to chop off {my} head. ";
                die();
            }
            else if (gIobj == myHands) { nicetry() ; }
            else "You'd be better off using your bare hands than
                that thing!";
        }        
    }
    
      
    // KICKING
    dobjFor(Kick)
    {
        verify() {}   
        action()
        {
            if (rand(2) == 1)
                "You attack the ogre, but he fends off
                your attack easily and comes very close
                to crushing your skull with his bare hands.
                You are forced to retreat in disgrace. ";
            else 
            {
                "You attack the ogre - a brave but foolish action.
                He quickly grabs you and with a heave of his
                mighty arms rips your body limb from limb. ";
                die();
            }
        }
    }

    // THROWING
    iobjFor(ThrowAt)
    {
        verify() {}
        action() 
        {
            if(gDobj == singingSword)
            {
                "The sword halts in mid-air, twirls like a
                dervish, and chants several bars of \"Dies
                Irae\" in a rough tenor voice.  It then begins
                to spin like a rip-saw blade and flies
                directly at the ogre, who attempts to catch
                it without success;  it strikes him full
                on the chest.  There is a brilliant flash
                of light, a deafening roar and a cloud of
                oily grey smoke;  when the smoke clears
                (and your eyes begin working properly again)
                you see that the ogre has vanished.  The sword
                is lying on the ground, sparking and flaming.
                Before your eyes it softens and melts, writhes
                as if in pain, and shrinks rapidly until all
                that is left is a small silvery ring which
                cools rapidly. <.reveal ogre-demise>";
                singingSword.moveInto(nil);                
                mithrilRing.moveInto(getOutermostRoom);
                ogre.moveInto(nil);
                ogre.exists = nil;
            }            
            else if (gDobj.ofKind(Weapon))
            {
                "The ogre casually catches {the dobj} in mid-air, ";
                if(gDobj == sword) "and cries <q> Hah! I've nothing to fear
                    from a rusty old sword like that!</q>  Before you have time
                    to ponder his words (you can't see any rust on
                    the sword) he ";
                "braces his feet, winds up and throws {him dobj}
                straight back at you with incredible force.
                You are unable to dodge {him dobj} and {he dobj} chop{s/?ed} you
                in half";
                if (gDobj == sword) {
                    swordshards.moveInto(location);
                    gDobj.moveInto(nil);
                    ", then shatters to pieces as it hits the wall of the room. ";
                }           
                else ". ";
                die();
            }            
            else inherited();
        }
    }
        
    iobjFor(ThrowTo) asIobjFor(GiveTo)   

    // GIVING uses defaults for class feedable

    // FEEDING
    dobjFor(FeedWith)
    {
        verify() {}
        action()
        {
            if(gIobj.ofKind(ContLiquid) && gIobj.myflag is in (&hasWater, &hasWine))
                inherited();           
            else
                "The ogre doesn't seem interested in {the iobj}<<if gIobj.ofKind(Food)>> -- maybe
                he isn't hungry<<end>>. ";
        }       
    }
    
    dobjFor(Feed) 
    {
        verify() {}
        action()
        {
            if(gActor.allContents.valWhich({o:o.isEdible}) != nil)        
                "The ogre doesn't seem interested in your food -- maybe
                he isn't hungry. ";
            else 
                "You have nothing the ogre wants to eat. "; 
        }        
    }

    // OTHER
    
    cannotTalkToMsg  = 'The ogre doesn\'t seem to be very interested in making conversation. '
    dobjFor(Rub) { verify() { illogical('Don\'t be ridiculous! '); }}
;


slime: Feedable, Fixture 'slime; evil green of[prep] acidic slimy; sheet' @crack2
    "A sheet of evil-looking green slime swathes the floor to
     the south.  It is twitching and flowing as though aware of
     your presence."
    exists = true
       
    specialDesc = "The passage to the south is swathed
           with sheets of evil-looking green slime, which
           twitch and flow as if aware of your presence. "
    
    // ATTACKING
    dobjFor(Attack)
    {
        verify() {}
        // DJP - attacking without a weapon now prompts the player; saying
        // 'yes' to bare hands results in death.
        action() 
        {
            "With what?  {My} bare hands?\b>";
            if(yesOrNo())
            {
                doInstead(Feel, self);
            }
            else
                "Probably wise. ";            
        }        
    }
    
    dobjFor(AttackWith)
    {        
        verify() {}
        // attacking with objects has no effect, but bare hands are fatal.
        action() 
        {        
            if (gIobj == myHands) actionDobjFeel();
            else "The slime is unaffected by your attack. ";
        }
    }
    
    // KICKING
    dobjFor(Kick) asDobjFor(Feel)
    
    // THROWING
    iobjFor(ThrowTo) asIobjFor(ThrowAt)
    
    iobjFor(ThrowAt)
    {
        // DJP: Objects which are thrown get trapped in the slime.  This isn't
        // true to the original game, but probably more logical!
        action()
        {            
            local o = gDobj;
            if(o.ofKind(ContLiquid)) o = gDobj.mycont;
            if (o == glassVial) 
                o.shatter_near(self);
            else 
            {
                "{The subj dobj} {is} caught up in the slime, which flows down and
                hides {him dobj} from view. ";               
                o.moveInto(slimeRoom);                
            }
        }
    }
    
    // GIVING
    iobjFor(GiveTo) asIobjFor(ThrowAt)
    
    // FEEDING
    actionDobjFeed = "There's nothing here it wants to eat (except perhaps you). "

    /* DJP - 'feed slime with me' now does just that. */
    actionDobjFeedWith
    {        
        if (gIobj == gPlayerChar) 
        {
            "Self-sacrifice is <i>not</i> the object of this game!
            However, if you really want to become food to
            repulsive slime ... "; P();
            actionDobjFeel();
        }
        else 
            doInstead(ThrowAt, self, gIobj);
    }
    
    // OTHER
    dobjFor(Rub) asDobjFor(Feel)
    actionDobjFeel()
    {
        "As you touch the slime, it flows up your body
        and rapidly digests away all of your flesh.<.p>";
        die();
    }
    
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
     
    cannotTakeMsg = 'Surely, you\'re joking. '   
;


slimeRoom: NoNPC, Room 'In Slime'
    "You are trapped in an opaque mass of green slime. "
;