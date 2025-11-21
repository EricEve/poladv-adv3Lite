#charset "us-ascii"
#include "advlite.h"




 /* Oddly, the 550-point version doesn't allow you to fill the flask.
  *  But I'll allow it anyway. Also, I'll insist that PUT FLASK IN PENTAGRAM
  *  be typed, not just DROP FLASK while in the pentagram room. -BJS
  */

flask: OpenableContainer, LiquidContainer 'small, sealed earthenware flask' 
    @arabesque
    "It's a small earthenware flask. It <<unless isOpen>>is tightly-sealed and
     <<end>>has the words, <q>London Dry</q> written on the side."
    
    
    
    
    altVocab = [
        'small, sealed earthenware flask; tightly tightly-sealed london gin dry',
        'small earthenware flask; london gin dry', 
        'small, empty earthenware flask; london gin dry'
    ]
    useAltVocabWhen
    {
        if(isEmpty)
            return 3;
        if(isOpen)
            return 2;
        return 1;
    }
    
    issealable = true // don't try to fill when closed    
    isOpen = nil   
    contname = 'flask'
    game550 = true
    
    aName = inherited Thing
    theName = inherited Thing
    
    
    
    // Code for drinking wine from the container.  In the original
    // version, drinking wine from the bottle/flask had the same effect as
    // drinking from the cask/fountain, which doesn't make sense in
    // view of the smaller quantity.
    winocode
    {        
        local newturns;
        "The wine goes to your head, and you feel very sleepy ...
        You awaken with a mild headache, and try to focus your
        eyes....<.p> ";
        gPlayerChar.health = (gPlayerChar.health*90)/100;
        if (brassLantern.fuelLevel > 25 && brassLantern.isOn) 
        {
            newturns = brassLantern.fuelLevel -
            rand(brassLantern.fuelLevel)/ 10;
            if (newturns < 25) newturns = 25;
            brassLantern.setLife(newturns);
        }
    }

    verifyIobjPutIn()
    {
        if(!isOpen)
            illogicalNow('That\'t a neat trick, putting things into a sealed flask! ');
        else
            inherited();
    }
    
    verifyDobjFill()
    {
        if(!isOpen)
            illogicalNow('That\'s a neat trick,  filling the flask without opening it!');
        else
            inherited();        
    }
    
    verifyDobjEmpty()
    {
        if(!isOpen)
            illogicalNow('I don\'t know how to empty a sealed flask.');
        else
            inherited();        
    }
    
    verifyDobjPourOnto()
    {
        if(!isOpen)
            illogicalNow('That\'s a neat trick, pouring out of a sealed flask!');
        else
            inherited();        
    }
    
    verifyDobjDrink()
    {
        if(!isOpen)
            illogicalNow('That\'s a neat trick, drinking out of a sealed flask!');
        else
            inherited();        
    }

    checkDobjClose()
    {
        "I can't figure out how to reseal it. ";
    }
    
    actionDobjOpen()    
    {
        if(isIn(floorPentagram)) 
        { 
            "The wax seal breaks away easily.  ";
            if(gActor.isIn(floorPentagram)) {
                "A cloud of dark smoke starts to pour up from the
                mouth of the flask and begins to solidify, pushing %you% out 
                of the pentagram!   It condenses into the form of a 
                twelve-foot Djinn.  ";
                gActor.moveInto(floorPentagram.location);
            }
            else {
                "A cloud of dark smoke pours up from the
                mouth of the flask and condenses into the form of
                a twelve-foot Djinn standing in the pentagram.\b";
            }
            "He pushes experimentally at the magical wall of the
            pentagram (which holds), and nods politely to you.\b
            <q>MY THANKS, OH MORTAL,</q> he says in an incredibly
            deep bass voice.  <q>IT HAS BEEN THREE THOUSAND YEARS
            SINCE SOLOMON SEALED ME INTO THAT BOTTLE, AND I AM
            GRATEFUL THAT YOU HAVE RELEASED ME.  IF YOU WILL
            OPEN THIS PENTAGRAM AND LET ME GO FREE, I WILL GIVE
            YOU SOME ADVICE THAT YOU MAY ONE DAY WISH TO
            POSSESS.</q> ";

            djinn.moveInto(floorPentagram);
        }
        else "The flask's wax seal crumbles at your touch.  A large
            cloud of black smoke pours out, solidifying into the
            form of a twelve-foot Djinn.\b<q>AT LAST!</q> he says
            in an earth-shaking voice, <q>I KNEW THAT SOMEDAY
            SOMEONE WOULD RELEASE ME!  I WOULD REWARD YOU FOR
            THIS, MORTAL, BUT IT HAS BEEN THREE THOUSAND YEARS
            SINCE I HAD A SOLID MEAL, AND I'M NOT GOING TO STAND
            HERE CHATTERING WHEN I COULD BE OUT EATING A SIX-INCH
            SIRLOIN STEAK.  FAREWELL.</q> \bWith that, he somewhat
            rudely explodes back into smoke and drifts quickly
            out of sight. ";
        makeOpen(true);
    }

    isEmpty = (inherited && djinn.moved)
;


metalPlate: Thing 'polished metal plate;;mirror' @storage
    "It's so highly polished that you can see your reflection in it<<if sword.location ==
      gPlayerChar>>, but it doesn't seem to be a perfect mirror -- for some
              reason the image of the gleaming sword looks very rusty<<end>>."
             
    game550 = true
    initSpecialDesc = "A highly polished metal plate is leaning against the wall. "
    
        // N.B. SEARCH and LOOK IN are not equivalent for mirrors but are for
    // many other objects e.g. containers, crystal ball.
    dobjFor(LookIn)
    {
        verify() {}
        action = desc;
    }
    
    dobjFor(Search)
    {
        verify() { illogical('How do you search a metal plate? '); }
    }   
;


dragonTeeth: Thing 'dragon\'s teeth;sharp pointed;;them'
    "They're just sharp, pointed teeth."
    game550 = true    
;   // Throwing them is handled in the code for the goblins.


singingSword: Weapon 'singing sword; sharp shiny' @sandstoneChamber
    "The sword is sharp and shiny.  It is singing quietly to itself. "
    
    initSpecialDesc = "There is a sword here, with its blade plunged deep into
               the block of stone.  The sword is singing quietly to itself. "
    
    specialDesc()
    {
        
        switch(rand(11) + 1) 
        {
            case 1: "There is a magic sword here, chiming out the bell-like
                tones of \"Kumbu Ice-fall\" by ringing its blade
                against the ground."; break;
            case 2: "There is a sword here, singing \"A Day in the Life\"
                in a quiet, introspective voice."; break;
            case 3: "There is a magic sword here, singing \"Cold Blue
                Steel and Sweet Fire\" to itself in a plaintive,
                hopeless voice."; break;
            case 4: "There is a sharp and obviously magical sword here.
                It is quietly humming excerpts from Prokofiev's \"Romeo
                and Juliet\" ballet to itself."; break;
            case 5: "There is a sword lying on the ground, jauntily
                whistling the March from Tchaikovsky's \"Nutcracker
                Suite\"."; break;
            case 6: "There is a sharp sword lying here. It is (somehow)
                singing Tchaikovsky's \"1812 Overture\" in twelve
                parts, by itself!"; break;
            case 7: "The stirring strains of Rossini's \"William Tell\"
                overture fill the room, coming from a singing
                sword lying on the ground."; break;
            case 8: "There is a singing sword lying on the ground . From
                it resound the massed voices of a two-hundred-singer
                choir, filling the air with the stirring sound
                of the Hallelujah Chorus from Handel's
                \"Messiah\"."; break;
            case 9: "There is a sharp and shiny sword here. It is
                somehow managing to sing Harry Partch's \"Daphne
                of the Dunes\" without destroying its singing
                organs (whatever they happen to be...)."; break;
            case 10: "There is a sword here, singing \"Witchi-Tai-To\"
                in two-part harmony with itself."; break;
            case 11: "There is a very strange singing sword here - it
                is glowing and vibrating, and the eerie electronic
                notes of Charles Wuorinen's \"Time's Encomium\"
                issue from its blade and fill the air."; break;
        }
    }
    
    isStuck = true
    nosack = true
    fromloc = stone
    strongenough = (mushroom.isEaten || (gPlayerChar.blueberriesEaten > 2))
    
    dobjFor(Take)
    {
        check()
        {
            if(isStuck && !strongenough)
            {
                "The sword is firmly embedded in the stone, and you <<if
                  gPlayerChar.blueberriesEaten > 0>> still aren't quite <<else>>
                aren't<<end>> strong enough to pull it out. ";
            }
        }
        
        action()
        {
            if(isStuck && self.strongenough) 
            {
                "The singing sword slides easily out of the rock.  ";
                isStuck = nil;
            }
            Dwarves.noAttack = true;
            inherited();
        }
    }
    
    dobjFor(Pull)
    {
        check()  { checkDobjTake();  }
        
        action()
        {
            if(isStuck)
                actionDobjTake();
            else
                inherited();
            
        }
    }

   yankObj = isStuck
;

/* Liquids for this version follow here. */

waterInTheFlask: ContLiquid 'water in the flask; ordinary in-flask'
    "It looks like ordinary water to me. "
    game550 = true
    mycont = flask
    myflag = &haswater
    aName = 'water'
    theName = 'the in-flask water'   
;

oilInTheFlask: ContLiquid 'oil in the flask; ordinary in-flask'
    "It looks like ordinary oil to me. "
    game550 = true
    mycont = flask
    myflag = &hasoil
    aName = 'oil'
    theName = 'the in-flask oil'       
;

wineInTheFlask: ContLiquid 'wine in the flask'
    "It's a small quantity of sparkling vintage wine in a flask
     marked <q>London Dry</q>.  In a larger container, it might be
     valuable.  "
    game701 = true
    // This object should never show up in other versions.
    mycont = flask
    myflag = &hasWine    
    theName = 'the in-flask wine'    
    aName = 'wine'
;

glassVial: Thing 'vial of oily liquid; glass small fragile; oil' @sphericalRoom
    "It's a small glass vial filled with an oily liquid.  It
             looks somewhat fragile ."
    
    game550 = true
    
    cannotOpenMsg = 'The vial is very securely sealed, and I can\'t
            see any way to open it. '

    lookInMsg = 'The vial contains an oily liquid. '
    
        /* BJS: Added ability to drop vial in Soft Room or on pillow. */

    actionDobjDrop()
    {
        local toproom = gActor.getOutermostRoom, nosmash = noshatter;
        noshatter = nil;
        // check for Wumpi chase condition
        // check for a soft floor
        if (toproom.softfloor) 
        {
            inherited();
            return;
        }
        // check for a room in which objects fall to another room below
        // (vial explodes but player is not harmed)
        else if(toproom.smashdrop) 
        {
            "(Dropping to the room below)\n";
            vapor_cloud(nil);
            moveInto(nil);
        }
        // check for presence of pillow
        else if (velvetPillow.location == gActor.location.dropLocation) 
        {
            "You have set the vial down carefully on the
            pillow.";

            moveInto(velvetPillow);
        }
        // don't kill the player in Transindection areas until the Wumpi
        // chase cycle is complete or the green pendant has been found
        if (wumpi.nodeath(gActor))
        {
            inherited();
            return;
        }
        // look for flag set by checksmash
        else if (nosmash) 
        {
            inherited();
            return;    
        }
        else 
        {
            if (rand(10) == 1) 
            {
                "The vial strikes the ground
                and explodes with a violent <i>foom<i>,
                neatly severing your foot.  You
                bleed to death quickly and messily.";
                shatter();
            }
            else 
                inherited();
        }

    }
    
    
    cannotDrinkMsg = 'The vial is sealed. '
    cannotFillMsg = cannotDrinkMsg
    cannotPutInMsg = cannotDrinkMsg
    

   
    // DJP - BREAK action changed to have the relevant effect on each
    // NPC in the room.
    alleffects(actor)
    {
        local toploc = actor.getOutermostRoom;
        local effectlist = [Dwarves, troll, bear, snake, littleBird,
            slime, dragon, wumpus, bees, dog, djinn, basilisk, goblins, ogre];        
        if (blob.isChasing && (blob.chase >= 13)) effectlist += blob;
        effectlist = effectlist.subset({x: x.isIn(toploc)});
        foreach(local o in effectlist)
        {
            "<.p>"; effects(o);               
        }
    }

    dobjFor(Break)
    {
        verify() {}
        check() {}
        
        action() 
        {
            // DJP - I've taken the liberty to be more explicit about
            // what is supposed to be going on here.  Dropping the vial
            // can kill the player, so breaking it in one's hands would
            // also be unsafe.  So we break it by throwing it at the
            // floor, but away from the player.
            "You throw the vial towards the center of the room.<.p>"; 
            moveInto(nil);
            vapor_cloud(nil);
            alleffects(gActor);
        }
        
    }
    // Throwing the vial at an NPC just affects the NPC.
    // Throwing it at the room or floor is the same as breaking it.
    

    // actionDobjThrowAt() HANDLED by actionThrowAt multimethod below.
    
    shatter() 
    {
        moveInto(nil);
        die();
    }
    // DJP - removed some coding into separate methods to allow it to
    // be used in different places.
    vapor_cloud(o) 
    {
        "The vial ";
        if (o == gPlayerChar)
            {
            // don't kill player during Wumpi chase scene.
            if (wumpi.nodeath(o))
                "bounces off your body, then ";
            else
                "strikes your body, then ";
        }
        else if (o) {
            "lands near to <<o.theName>>. It ";
        }
        "explodes into splinters and disintegrates,
        releasing an oily liquid which rapidly sublimes
        into a large mushroom-shaped cloud of ";
        switch(rand(7) + 1) {
            case 1: "pale puce vapor smelling like sequoia sap
                     and ozone."; break;
            case 2: "bright green vapor smelling like pine
                     needles and sea water."; break;
            case 3: "thick yellow vapor smelling like cheddar
                     cheese and bananas."; break;
            case 4: "choking green vapor smelling like chlorine
                     and apples."; break;
            case 5: "misty white vapor with no scent."; break;

            case 6: "nearly-invisible vapor with a strong odor
                     of walnuts and onions."; break;
            case 7: "ominously glowing vapor smelling of hot
                     iron."; break;
        }
    }
    effects(iobj)
    {
        switch(iobj) 
        {
        case Dwarves:
            if (Dwarves.countWhich({d: d.isIn(gRoom)}) == 1)
                "The dwarf catches a lungful of the cloud,
                gags audibly and stumbles out of the room
                retching, sneezing, and cursing up a storm.";
            else "The dwarves blanche in horror and dash
                away as fast as their brief and misshapen
                legs can carry them.";
            Dwarves.scatter; // Scatter the dwarves.
            break;
            
            case troll: "The troll calmly waves the vapor away.";
            break;
            
            case bear: if(bear.isTame) "The bear inhales some
                of the vapor and moans appreciatively.";
            else "The bear inhales some of the vapor
                and snarls angrily.";
            break;
            
            case snake: "The snake completely ignores the vapor.";
            break;
            
            case littleBird: "The bird breathes in a minuscule
                amount of the vapor and immediately
                sings a twenty-second segment of Morton
                Subotnik's \"Sidewinder\".";
            break;
            
            case slime: "The slime filling the passageway to
                the south blackens and shrivels
                away into nothingness.";
            slime.exists = nil;
            roomMove(slimeRoom,slime.location);
            slime.moveInto(nil);
            break;
            
            case dragon: "The dragon sniffs the air, rumbles
                deep in his chest, and shoots out
                a small puff of flame that ignites
                and incinerates the vapor.";
            break;
            
        case wumpus:
            if (wumpus.isAsleep)
                "The vapor has no effect on the sleeping Wumpus. ";
            else if (wumpus.isDead)
                "Not surprisingly, the vapor has no effect on the dead
                Wumpus. ";
            else
                "The Wumpus sniffs the air, waves away the vapor,
                and starts after you again! ";
            break;
            
            case bees: "The vapor enrages the bees, which swarm all over you
                and sting you to death! ";
            die();
            break;
            
        case dog:
            if (dog.isAsleep)
                "The vapor has no effect on the sleeping dog. ";
            else
                "The dog growls at you, but the vapor has no other
                effect. ";
            break;
            
            case djinn: "The djinn takes in a deep sniff of the
                vapor and comments, \"AH, A TRULY
                FINE ARABIAN PERFUME!  I HAVEN'T
                SMELLED ANYTHING LIKE THAT FOR
                YEARS!\"";
            break;
            
            case basilisk: "The basilisk doesn't wake up.";
            break;
            
            case goblins: "The gooseberry goblins sniff the
                vapor, screech in terror, and dash
                off into the distance.";
            goblins.banish; // scare them off.
            break;
            
        case ogre:  // The authors seem to have missed this case.
            // I'll use the text from the 660 point version.
            "With a contemptuous growl the ogre waves the
            vapor aside.";
            break;
            
        case me: 
            // Don't kill player during Wumpi chase scene
            if (! wumpi.nodeath(gPlayerChar)) 
            {
                "Unfortunately you are cut to ribbons by
                glass shards from the explosion!";
                die();
            }
            break;
            case nil: break; // This should be unreachable, but
            // just in case...
            default: "The vapors have no effect on <<iobj.theName>>.\n";
            // includes the blob, beanstalk, and bivalve,
            // naturally.
        }
    }
    
    // except for Me, the vial doesn't land close enough to the target
    // for the explosion to do any harm, but the gas has effects on
    // various NPC's.
    shatter_near(iobj)
    {
        vapor_cloud(iobj);
        "<.p>";
        effects(iobj);
    }
     
    noshatter = nil
;

/* Use a MultiMethod here to prevent the handling that would otherwise happen on the iobj. */
actionThrowAt(glassVial dobj, Thing iobj)
{
    if(iobj.ofKind(Floor)) 
    {
        "You throw the vial at the center of the floor.<.p>";
        dobj.moveInto(nil);
        dobj.vapor_cloud(nil);
        dobj.alleffects(gActor);
        skip;         
    }
    if(iobj == dobj.getOutermostRoom) 
    {
        "You throw the vial at the center of the room.<.p>"; 
        dobj.moveInto(nil);
        dobj.vapor_cloud(nil);
        dobj.alleffects(gActor);
        skip;        
    }
    if(iobj is in (walls, bWalls)) 
    {
        "You throw the vial at the walls of the room.<.p>";
        dobj.moveInto(nil);
        dobj.vapor_cloud(nil);
        dobj.alleffects(gActor);
        skip;       
    }
    dobj.moveInto(nil);
    dobj.shatter_near(iobj);
    skip;
}


mushroom: CanPick, Food 'small mushroom;;fungus' @inCubicle
    "It's just a small mushroom. "
    game550 = true
        
    initSpecialDesc = "There is a small mushroom growing on the wall. "
    noun = 'mushroom' 'fungus'
    adjective = 'small'

    // For the 701-point game, the player has a sack of holding so the
    // effect of the mushroom is to allow more weight to be carried in the
    // sack, not to allow more items to be held.  The effect of the blueberries
    // is the same, but doesn't wear off.

    actionDobjEat()
    {      
        "As you swallow the mushroom your mouth becomes
        numb, and everything seems to swirl around you.  The
        effect quickly passes, and you find that your muscles
        have bulged unbelievably.";
        if (global.game701) gPlayerChar.weightCapacity += 20;
        else gPlayerChar.bulkCapacity = 12;
        isEaten = true;
        new Fuse(&strengthWear, mushtime);
        moveInto(nil);
    }
    is_eaten = nil  // used for the sword's doTake method.
    // Strength is only temporary:
    strengthWear()
    { 
        "<.p>A strange malaise suddenly afflicts you.
        You shiver with chill, and your muscles seem to
        turn to putty;  everything around you becomes grey
        and unreal.  The fit quickly passes, and you find
        that your body has degenerated back to what it was
        like before you ate the mushroom.";
        if (global.game701) gPlayerChar.weightCapacity -= 20;
        else gPlayerChar.bulkCapacity = 7;
        isEaten = nil;
        new Fuse(self, &regrow, growtime);
    }
    mushtime = 40 // strength wears off after this many turns.
    growtime = 8 // It regrows after this many turns:
    regrow()
    {
        moveInto(inCubicle);
        moved = nil; // obtain initSpecialDesc description
        if (gPlayerChar.isIn(location)) 
        {
            initSpecialDesc;
        }
        
    }   
    isEaten = nil
;

/*
 * Treasures for 550-point version
 */
// Not to be confused with the elfin crown
iridCrown: Wearable, Treasure 'massive iridium crown; floating levitating weightless' @inSafe
    "It is quite massive, but nearly weightless."
    game550 = true
    
    specialDesc = "There is a massive crown made of solid iridium
         floating in midair! "
    
    actionDobjWear = "You set the crown on your head, but it floats off. "    
     // In this version , anyway...
      // N.B. In the 660-point game, the player can wear the crown and
      // hears all the safe passwords.
;

/* N.B. the TADS version allows these coins to be used in the vending machine.
   The original version didn't! */
bag: Coin, Treasure 'bag filled with pieces of eight;valuable;coins; it them' @beach
    "The coins look quite valuable! "
    game550 = true
    
    initSpecialDesc = "There is a bag (obviously filled with pieces of eight) in
    the dinghy! "
    
    lookInMsg = 'The bag is filled with pieces of eight.  They look valuable. '
    
    verifyIobjTakeFrom()
    {
        if(gVerifyDobj == self)
            illogical('{I}\'d better leave the coins in the bag.  ' );
        else
            inherited();
    }    
;

/* This object has special properties only in the 550-point game. */
    /* N.B. this object isn't wearable in the 660-point version. */
helmet: ProtectRing, Wearable, Treasure  'gem-encrusted visorless helmet; gem encrusted visorless 
    ;helm' @morion
    "It is encrusted with precious jewels!"    
    
    game550 = true
    
    protection = ((global.game701) ? 0: 3)    
;


sceptre: Treasure 'sapphire sceptre; long encrusted' @eastAudience
    "It's a long sceptre, ornately encrusted with sapphires!"
    
    mentionName = "a long, sapphire-encrusted sceptre"    
    
    dobjFor(Take)
    {
        action()
        {
            local i;
            inherited();
            
            //
            // If we didn't get the sceptre (e.g., if the
            // actor's carrying too much), don't do anything
            // else.
            //
            if (!isIn(gActor))
                return;
            else skeleton.moveInto(nil);
            // This will happen every time the sceptre is
            // picked up, but this is harmless.
            
            if(!passwordtold && inSafe.isFused) 
            {
                "As you pluck the sceptre from the
                skeleton's grasp, it raises its head
                and whispers, \"You blew it!\".  It
                then shivers and collapses into a pile
                of fine dust which quickly vanishes.";
                
                passwordtold = true;
            }
            else if(!passwordtold) 
            {
                // First determine the keyword.
                inSafe.password = rand(5) + 1;
                
                "You pluck the sceptre from the skeleton's
                bony hand.  As you do, the skeleton raises
                its head and whispers <q>Remember -- ";
                
                // Now print the word, using its sdesc:
                for (i = firstObj(VaultKeyVerb); i; i = nextObj(i, VaultKeyVerb))
                    if(i.wordnum == inSafe.password) 
                        say(i.verb);
                
                // Done. Now print the rest of the text.
                "!\</q>in a forboding tone; it then sags to the
                ground and crumbles into dust which drifts
                away into the still air of the cave.<.p>"; 
                passwordtold = true;
            }
        }
    }
    
    passwordtold = nil
    
;

SpecialVerb 'row' @yacht 'ride';
SpecialVerb 'launch' @yacht 'sp#act';

yacht: Treasure 'ruby-covered toy yacht;ruby toy covered encrusted ruby-encrusted omar
                    khayyam khayyam\'s rubaiyat' @nondescript
    "It is a small toy yacht totally covered with rubies, 
    and has the words <q>Omar Khayyam</q> engraved on the side!" 
    game550 = true
    
    initSpecialDesc = "There is a small toy yacht sitting on the floor. It is
                totally covered with rubies, and has the words        
                <q>Omar Khayyam</q> engraved on the side!! "
    
    verifyDobjRide() {illogical('It\'s only a toy yacht, you fool! ');}
    dobjFor(Enter) asDobjFor(Ride)
    dobjFor(Board) asDobjFor(Ride)
    verifyDobjSpecialAction {illogical('I wouldn\'t advise it - the yacht is far too
        valuable.  ');}    
;


beads: Wearable, Treasure 'ancient Indian turquoise beads;of[prep];string;them' @balcony
    "The turquoise beads complement each other beautifully! "
    game550 = true
    
    initSpecialDesc = "There is a string of ancient Indian turquoise beads draped
                casually over the edge of the balcony! "   
;


mithrilRing: ProtectRing, Wearable, Treasure 'mithril ring; shiny'
   "It's a shiny ring crafted of the finest mithril. "

    game550 = true
    protection = 3    
;

spyglass: Treasure 'scrimshaw spyglass;baleen whale;glass' @inJonah
    "It's small spyglass carved out of whale baleen.  It's a valuable 
        trifle, but it has no utilitarian value.  You certainly can't see
        much through it. "
    
    game550 = true
    // Part of the ldesc has been borrowed from the 660-point game.
    
    // In case someone doesn't notice the sdesc.
    lookThroughMsg = "You see a very small, blurred image through the spyglass.  Unlike
        some treasures, it's valuable but not useful. "    
;


sculpture: Treasure 'rock-crystal sculpture; pig eel emu elf mouse rabbit ibex
    frog tiger mule moose crystal crystalline rock carved finely
    finely-carved'   
    @sculptNiche
    "It is a finely-carved sculpture of <<animdesc>>, made of rock crystal!"
    game550 = true   
    
    animdesc 
    {
        switch(rand(11 + 1)) 
        {
            case 1: "a pig"; break;
            case 2: "an eel"; break;
            case 3: "an emu"; break;
            case 4: "an elf"; break;
            case 5: "a mouse"; break;
            case 6: "a rabbit"; break;
            case 7: "an ibex"; break;
            case 8: "a frog"; break;
            case 9: "a tiger"; break;
            case 10: "a mule"; break;
            case 11: "a moose"; break;
        }
    }
    specialDesc = "There is a finely carved sculpture of <<animdesc>> here! "
    
    mentionName = "A finely carved sculpture of <<animdesc>> "    
;


bracelet: Wearable, Treasure 'jade bracelet; ancient chinese' @translucent
    "An ancient Chinese jade bracelet! "
    game550 = true    
;

casket: Treasure 'casket of opals; rare black opal' @crack4
    "The casket is full of rare black opals!"
    game550 = true
    
    lookInMsg = desc
    cannotOpenMsg = 'Best leave it closed so as not to spill the opals. '
    cannotCloseMsg = 'It\'s already closed. '
    cannotPutInMsg = 'It\'s full of opals; there\'s no room for anything else. '
    cannotTakeFromSelfMsg = 'It\'s best to leave the opals in the casket. '
    
;
