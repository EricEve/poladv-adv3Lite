#charset "us-ascii"

#include <tads.h>
#include "advlite.h"

/* Additional rooms for 550-point version */

/*
 * A class for the ice tunnels. Since the NPCs can't use magic words in
 * this game, they will become trapped upon entering the maze. Hence,
 * I've made them NoNPC, although they weren't in the original. -BJS
 */
class IceTunnel: NoNPC, DarkRoom 'Ice Tunnels'   
    desc()
    {  
        local xn = 0, xls = 0;
        "You are in an intricate network of ice tunnels.  ";
        // List exit tunnels:

        // Store the exits which lead somewhere in the number xls.
        // Let xn be the number of exits available.
        if(propType(&north) == TypeObject) { xls += 1; xn++; }
        if(propType(&south) == TypeObject) { xls += 2; xn++; }
        if(propType(&east) == TypeObject) { xls += 4; xn++; }
        if(propType(&west) == TypeObject) { xls += 8; xn++; }
        if(propType(&southwest) == TypeObject) { xls += 16; xn++; }
        if(propType(&northwest) == TypeObject) { xls += 32; xn++; }
        if(propType(&northeast) == TypeObject) { xls += 64; xn++; }
        if(propType(&southeast) == TypeObject) { xls += 128; xn++; }

        if(xn == 0) "Uh, oh!  There are no exits";

        if(xn == 1) { local xi = 1; // xi is direction counter.
            "The only exit is to the ";
            while(xls != 0) {  // print the list of exits.
            if (xls%2 == 1)  // if xls is odd, the exit in
                printdir(xi); // direction xi exists.
            xls /= 2;  // lop off last bit of exitlist,
            xi++;     // and go to next direction.
            }
        }

        if(xn == 2) { local fxp, xi = 1;
            "There are exits to the ";
            while(xls != 0) {  // print the list of exits.
            if (xls%2 == 1) { // if xls is odd, the exit in
                printdir(xi);  // direction xi exists.
                if (!fxp) " and ";
                fxp = true;  // fxp indicates whether the
            }        // first exit has been printed.
            xls /= 2;  // lop off last bit of exitlist,
            xi++;    // and go to next direction.
            }
        }

        if(xn > 2) { local nxp = 0, xi = 1;
            "There are exits to the ";
            while(xls != 0) {  // print the list of exits.
            if (xls % 2 == 1) { // if xls is odd, the exit in
                printdir(xi); // direction xi exists.
                nxp++;   // nxp is number of exits printed.
                if (nxp != xn) ", ";
                if (nxp == xn-1) "and ";
            }
            xls /= 2;   // lop off last bit of exitlist,
            xi++;      // and go to next direction.
            }
        }
        ".  ";
    }
    printdir(dir)
    {
        switch(dir) {
            case 1: "north"; break;
            case 2: "south"; break;
            case 3: "east"; break;
            case 4: "west"; break;
            case 5: "southwest"; break;
            case 6: "northwest"; break;
            case 7: "northeast"; break;
            case 8: "southeast"; break;
        }
    }
     game550 = true
    
//    myhints = [ Icehint ]
;

northOfReservoir: NoNPC, DarkRoom 'North Edge of Reservoir'
    "You are at the northern end of a large underground
     reservoir.  Across the water to the south, a dark passage
     is visible.  Another passage leads north from here.  Large
     clawed tracks are visible in the damp ground, leading from
     the passage into the water. "
    
    
    game550 = true
    // In the 701-point game we use Sword_Point instead
    game701 = nil
    
    north = warmRoom
    passage = warmRoom
    warm = warmRoom
    
    balcony = inBalcony
    
    south { doInstead(Cross, reservoir); }
         
    cross = south
    across = south 
//    exithints = {
//        if (global.game701)return [N_Of_Reservoir, &south];
//        else return [Sword_Point, &south];
//    }
;

+ brassGong: Fixture 'large brass gong'
    "It's just a large brass gong fastened to the wall of the room. "
    game550 = true
    
    specialDesc ="There is a large brass gong fastened to the wall here. "   
    location701 = swordPoint
    
    dobjFor(Attack) // That's how "HIT GONG" gets parsed!
    {
        verify() {}
        action()
        {
            if(turtle.isIn(location))
                "BONNNNNGGGGGGGGGG\b 
                Darwin the Tortoise blinks in surprise at the noise, but does nothing.";
            
            else 
            { 
                "BONNNNNGGGGGGGGGG\b"; 
                "A hollow voice says, \"The GallopingGhost
                Tortoise Express is now at your service!\b
                With a swoosh and a swirl of water, a large
                tortoise rises to the surface and paddles
                over to the shore near you.  The message,
                <q>I'm Darwin - ride me!</q> is inscribed on
                his back in ornate letters.";
                turtle.actionMoveInto(location);
            }        
        }
        
    }
    
    dobjFor(AttackWith) asDobjFor(Attack)    
    dobjFor(Strike) asDobjFor(Attack)
;

+ Decoration 'clawed tracks; damp large (turtle) ;track; them it'
    "Large clawed tracks are visible in the damp ground,
             leading from the passage into the water. "
    location701 = swordPoint
;

SpecialVerb 'bang' @brassGong 'hit';

warmRoom: NoNPC, DarkRoom 'Small Warm Chamber'
    "You are in a small chamber with warm walls.  Mist drifts
     into the chamber from a passage entering from the south
     and evaporates in the heat.  Another passage leads out to
     the northeast. "
    
    game550 = true
    
    south: VarDest, TravelConnector
    {
        calcDest()
        {
            if (global.game701) return swordPoint;
            else return northOfReservoir;
        }
    }
       
    toReservoir = south
    
    northeast = inBalcony
    balcony = inBalcony
//    exithints = {
//        if (global.game701) return [Sword_Point, &south];
//        else return [N_Of_Reservoir, &south];
//    }
    
;

inBalcony: NoNPC, Room 'Treasure Room Balcony'    
        "You are in a high balcony carved out of solid rock
        overlooking a large, bare chamber lit by dozens of
        flickering torches.  A rushing stream pours into
        the chamber through a two-foot slit in the east
        wall and drains into a large pool along the north
        side of the chamber.  A small plaque riveted to
        the edge of the balcony reads, <q>You are looking
        at the Witt Company's main treasure room,
        constructed by the famous architect Ralph Witt
        in 4004 B.C., and dedicated to the proposition
        that all adventurers are created equal (although
        some are more equal than others).  NO ADMITTANCE
        VIA THIS ENTRANCE!</q>  A small, dark tunnel leads
        out to the west. "
        
    game550 = true
    west = warmRoom
    out asExit(west)
    toReservoir: VarDest, TravelConnector
    {
        calcDest()
        {
            if (global.game701) return swordPoint;
            else return northOfReservoir;
        }
    }
    
    
    warm = warmRoom
    
    jump = brokenNeck
//    exithints = {
//        if (global.game701) return [Sword_Point, &reservoir];
//        else return [N_Of_Reservoir, &reservoir];
//    }
;

+ Fixture 'small plaque; riveted; sign'
    "It says, <q>ou are looking at the Witt Company's main
        treasure room, constructed by the famous
        architect Ralph Witt in 4004 B.C., and
        dedicated to the proposition that all
        adventurers are created equal (although
        some are more equal than others).  NO
        ADMITTANCE VIA THIS ENTRANCE!</q>"   
   
    readDesc = desc
    
    game550 = true
;

wheatStoneBridge: DSPassage 'wheat-stone bridge' @atBreathtakingView @valleyFaces
    "The bridge is a fragile-looking arch of wheat-colored stone,
        leading across the volcanic gorge. "
    
    game550 = true
    exists = nil
//    isConnectorApparent = exists //???
    isConnectorListed = exists
    
    specialDesc = "There is a wheat-colored stone bridge arching over the gorge."
    isHidden = (!exists)
    
    iswavetarget = true // magic can be worked by waving the rod at it ...
    
    
    
    dobjFor(Cross) asDobjFor(TravelVia)
    
    canTravelerPass(traveler) { return exists; }    
    explainTravelBarrier(traveler, connector) { "There is no way over the gorge. "; }
    
    travelBarriers = [wsBearBarrier]
    
    noteTraversal(actor)
    {
        if (exists)  // unreachable in 350-point mode.
        {            
            if (actor.isIn(atBreathtakingView))
            {
                // Note that it is not necessary to wear
                // the ring, since the original version
                // had no wear verb. (You do have
                // to wear the ring in the 660-point
                // version, though.)
                
                if(mithrilRing.location == actor) 
                {
                    "As you approach the center of the archway,
                    hot vapors saturated with brimstone drift
                    up from the lava in the gorge beneath your
                    feet.  The mithril ring ";
                    if (mithrilRing.wornBy == actor) "on your finger";
                    else "in your hand";
                    " quivers and glows, and the fumes eddy away
                    from the bridge without harming you.<.p>";                    
                }
                else 
                { 
                    "As you approach the center of the
                    archway, hot vapors saturated with
                    brimstone drift up from the lava in
                    the gorge beneath your feet.  You are
                    swiftly overcome by the foul gasses
                    and, with your lungs burned out, fall
                    off of the bridge and into the gorge.";
                    
                    die();
                }              
            }
            else 
            {
                if(mithrilRing.location == actor)   
                {
                    "As you approach the center of the archway,
                    hot vapors saturated with brimstone drift
                    up from the lava in the gorge beneath your
                    feet.  The mithril ring in your hand
                    quivers and glows, and the fumes eddy away
                    from the bridge without harming you.<p.> ";
                    if(sceptre.isIn(actor))
                    {
                        "As you reach the center of the bridge,
                        a ghostly figure appears in front of
                        you.  He (?) stands at least eight
                        feet tall, and has the lower body of
                        an enormous snake, six arms, and an
                        angry expression on his face.
                        <q>You'll not have my sceptre that
                        easily!</q> he cries, and makes a
                        complex magical gesture with his
                        lower right arm.  There is a brilliant
                        flash of light and a vicious <i>crack</i>;
                        the bridge cracks and plummets
                        into the gorge.";
                        // Zap the bridge ...
                        exists = nil;
                        // self.moveLoclist([]);
                        // drop the sceptre at Valley_Faces
                        sceptre.moveInto(valleyFaces);
                        // but drop the rest of the player's
                        // items at Breath_Taking_View so he
                        // can get across again
                        actor.moveInto(atBreathtakingView); 
                        // Zap the player
                        
                        die();
                    }
                    
                }
                else
                {
                    "As you approach the center of the
                    archway, hot vapors saturated with
                    brimstone drift up from the lava in
                    the gorge beneath your feet.  You are
                    swiftly overcome by the foul gasses
                    and, with your lungs burned out, fall
                    off of the bridge and into the gorge. ";
                    
                    die();
                }
                
            }
            
        }
        else
            "I'm afraid {i} can't go that way - walking on red-hot
            lava is contrary to union regulations (and is bad
            for your health anyhow). ";
    }
;

wsBearBarrier: TravelBarrier
    canTravelerPass(traveler, connector) { return traveler != bear && !bear.isFollowing; }
    explainTravelBarrier(traveler, connector)
    {
        if(traveler == bear)        
            "The archway looks too fragile to support the bear. ";
        else if(bear.isFollowing)
            "That archway looks pretty fragile -- you'd better leave the bear here.";
    }
;


valleyFaces: NoNPC, Room 'South End of Valley of Faces'
    "You are standing at the southern end of a long valley
        illuminated by flickering red light from the volcanic gorge
        behind you.  Carved into the walls of the valley are an
        incredible series of stone faces.  Some of them look down
        into the valley with expressions of benevolence that would
        credit a saint;  others glare with a malice that makes the
        heart grow faint.  All of them are imbued with a fantastic
        seeming of life by the shifting and flickering light of the
        volcano.  The entire far end of the valley is taken up by
        an immense carving of a seated figure;  its exact form
        cannot be seen from here due to the uncertainty of the light. "

    game550 = true
    wino_wsbridge = true // can only exit via stone bridge
    isbonus = true    
    
    north = byFigure
    south = wheatStoneBridge 
    
    cross = south
    gorge = south
//    exithints = [ At_Breath_Taking_View, &south ]
;

+ Decoration 'stone faces;;face;them'    
   "Some of them look down into the valley with expressions
        of benevolence that would credit a saint;  others glare
        with a malice that makes the heart grow faint.  All of
        them are imbued with a fantastic seeming of life by the
        shifting and flickering light of the volcano."
    
     game550 = true
;
   

byFigure: NoNPC, Room 'North End of Valley of Faces'    
    "You are standing at the north end of the Valley of the
    Stone Faces.  Above you, an incredible bas-relief statue of an
    immense minotaur has been carved out of the rock.  At least
    sixty feet high, it sits gazing down at you with a faint but
    definite expression of amusement.  Between its feet and the
    floor is a rock wall about ten feet high which extends across
    the entire north end of the valley. <<rockWall.described>> "

    
    game550 = true
    wino_wsbridge = true // can only exit via stone bridge
    
    south = valleyFaces
    
    northwest: TravelConnector -> southFog
    {
        isConnectorApparent = (rockWall.has_crumbled)
    }    
   
    left = northwest
    
    northeast: TravelConnector -> windingPass
    {
        isConnectorApparent = (rockWall.has_crumbled)
    }  
        
    right = northeast
    
    north: TravelConnector -> southBasilisk
    {
        isConnectorApparent = (rockWall.has_crumbled)
    }  
    
    middle = north
//    exithints = [ South_Fog, &nw,   Winding_Pass, &ne,
//                   South_Basilisk, &north ]
//;
;

+ rockWall: Fixture 'rock wall; stone' 
    desc 
    { 
        if(has_crumbled) 
            "Dark tunnels lead northeast, north,
            and northwest through the crumbled wall. ";
        else 
            "The rock wall extends across the entire north
            end of the valley. ";
    }
    game550 = true
    has_crumbled = nil
    
    
    described { if(has_crumbled) "Dark tunnels lead northeast, north, and northwest."; }
;

+ Decoration 'immense statue, bas-relief bas relief of[prep]; minotaur'
    "The statue is gazing at you with an amused expression on its face."   

     game550 = true
; 

southFog: NoNPC, DarkRoom 'South End of Foggy Plain'
    "You are standing at the southern end of what appears
        to be a large room filled with multicolored fog.
        The sides and far end of the room cannot be seen due
        to the thickness of the fog - it's a real pea-souper
        (even to the color in places!).  A passage leads
        back to the south;  a dull rumbling sound issues
        from the passage. "
    game550 = true
    wino_wsbridge = true // can only exit via stone bridge
    
    south = byFigure
    
    north: TravelConnector -> foggyPlain
    {
        travelDesc() {  fog.dir_to_go = 1 + rand(8); }
    }
       
    listenDesc = "A dull rumbling sound issues from the passage. "
;

foggyPlain: NoNPC, Room 'Foggy Plain'
    "<<if lamplit>><<fog.desc>><<else>><<fog.inDarkDesc>><<end>>"
    
    darkName = 'Foggy Plain'
    darkDesc = fog.inDarkDesc
    lamplit()
    {
        return allContents.indexWhich({x: x.isLit && gPlayerChar.canSee(x)});
    }
    
    game550 = true
    wino_wsbridge = true // can only exit via stone bridge
    
//    myhints = [ Foghint ]

    // The numbers are for the Fog.ldesc method.
    north { return fog.wander(3); }
    south { return fog.wander(4); }
    east { return fog.wander(1); }
    west { return fog.wander(2); }
    southwest  { return fog.wander(7); }
    northwest { return fog.wander(8); }
    southeast { return fog.wander(6); }
    northeast { return fog.wander(5); }
;

+ fog: Fixture 'fog; thick pea soup pea-soup pale purple red dense black orange magenta pink 
    multicolored multicoloured' 
  game550 = true    
  visibleInDark = true
    
    desc
    {      
        switch( rand(8) + 1) 
        { // DJP
            case 1: "You are standing, badly befuddled, in a
                pale purple fog."; break;
            case 2: "You are wandering around in the middle
                of a bright red fog."; break;
            case 3: "You are lost in the midst of a thick,
                pea-green fog."; break;
            case 4: "You are trying to find your way through
                a dense coal-black fog."; break;
            case 5: "You are lost in the heart of a strange
                yellow fog."; break;
            case 6: "You are standing, badly bedazzled, in a
                day-glow orange fog."; break;
            case 7: "You are hunting your way through a
                shimmering magenta fog."; break;
            case 8: "You are somewhere in the center of a
                weird, pearly pink fog."; break;
        }
    }
        
    inDarkDesc()
    {
        switch (self.dir_to_go) 
        {               
            /* 
             *   direction to go. Should match the values in the direction properties for the
             *   Foggy_Plain.
             */
            
            case 1: "A faint glow of light is visible
                through the fog to the east."; break;
            case 2: "A glimmer of light is visible
                through the fog in the west."; break;
            case 3: "A glow of light is visible through
                the fog to the north."; break;
            case 4: "A faint shimmer of light is
                visible to the south."; break;
            case 5: "A flickering light is visible through
                the fog in the northeast."; break;
            case 6: "A dim light is visible in the
                southeast."; break;
            case 7: "A dim glow of light is visible
                in the southwest."; break;
            case 8: "A dim flickering light is visible
                through the fog in the northwest.";
            break;
            default: "Whoops! The direction hasn't been set yet!";         
            
        }
        "\n";
    }
    dir_to_go = 0 // should be set when fog is entered or wander() is
                  // called.
    
    
    dobjFor(GetOutOf)
    {
        verify() {}
        check = "You'll have to tell me how to do that. "
    }
   
    wander(dir) 
    {
        local actor = gActor;
        local i, dest;
        local iList = [];
        if(!foggyPlain.lamplit && (dir == dir_to_go)) dest = plainCentre;
        else dest = foggyPlain; // Stay on the plain.

        if(brassLantern.isLit &&
        brassLantern.isIn(foggyPlain) &&
        !brassLantern.isIn(actor)) 
        {
            "You're just wasting your batteries leaving the
            lamp on like that.\n";
            return foggyPlain;
        } // Since you can't lose a lit lamp in the fog.

        dir_to_go = rand(8) + 1; /* reset proper direction
                        Doing it in both cases eliminates
                        the need to do it when the player
                        leaves the center. */

        foreach(i in foggyPlain.contents)
        {            // Any items lying around are lost.
            // DJP - exclude fixed items.
            if (i.isFixed) continue;
            i.moveInto(nil);
            iList += i;            
        }
        if(iList.length > 0)
            "The fog is so dense that I don't think you'll be able to find <<makeListStr(iList, 
                &theName, 'or')>>  again.\n";

        return dest;  // Go wherever is necessary.

    }
;


plainCentre: NoNPC, Room 'Foggy Plain by Cairn of Rocks'
    "You are standing in a fog-filled room next to a tall
        cairn of glowing rocks.  An opening in the cairn leads
        down to a dark passage. "
    
    game550 = true
    wino_wsbridge = true // can only exit via stone bridge
    
    // No need to reset the fog, since that was done when we got here.
    north = foggyPlain
    south = foggyPlain
    east = foggyPlain
    west = foggyPlain
    northwest = foggyPlain
    southwest = foggyPlain
    southeast = foggyPlain
    northeast = foggyPlain
    down = nondescript
;

nondescript: NoNPC, DarkRoom 'Nondescript Chamber'
    "You're in a small, nondescript chamber.  A dark
        passage leads up and to the south, and a wide but
        low crawl leads north. "
    
    game550 = true
    wino_wsbridge = true // can only exit via stone bridge
        
    south = plainCentre
    north = byPentagram
    up asExit(south)
    pentagram = byPentagram
;

byPentagram: NoNPC, DarkRoom 'Pentagram Room'
    "You're in a small room with a very smooth rock floor,
        onto which has been marked a pentagram.  A low crawl
        leads out to the west, and a crack in the rock leads north.  "
    
    game550 = true
    wino_wsbridge = true // can only exit via stone bridge
    west = nondescript
    north = chimneyRoom
    out asExit(west)
    toNondescript = nondescript
    crack = chimneyRoom
    chimney = chimneyRoom
;


+ floorPentagram: Fixture, Platform 'pentagram'
    "It's just a pentagram marked on the floor.  "
    game550 = true
    
//    ldesc = { 
//        self.heredesc;
//        if (itemcnt( self.contents )) {
//            P(); I(); "In "; self.thedesc; " you see ";
//            listcont( self ); ". ";
//        }
//    }
//    heredesc = {
//        if(Djinn.location = self) {
//            P(); I();"There is a twelve-foot
//            djinn standing in the center of the pentagram,
//            glowering at you.  ";
//        }
//    }
    
    checkReachIn(actor, target)
    {
        if(djinn.isIn(self))
            "Right now, the pentagram's magic barrier 
            prevents you from touching any objects it contains. ";
    }
    
   
    reachable = ([]+self)
    onroom = nil // say IN the pentagram, not ON
    
//    out = {return self.location;}
    
    dobjFor(Open)
    {
        verify() {}
        action()        
        {
            if (djinn.isIn(self))
            { 
                "The pentagram's magical barrier sparks fitfully and goes down.  The
                Djinn stretches gratefully and smiles at you.  <q>AGAIN, MY THANKS,</q>
                he says.  <q>MY ADVICE TO YOU WILL TAKE THE FORM OF A HISTORY LESSON.
                WHEN RALPH WITT, THE ARCHITECT AND CONSTRUCTOR OF THIS CAVE, WAS VERY
                YOUNG, HE BECAME VERY INCENSED THAT HIS NAME WAS AT THE END OF THE
                ALPHABET.  HE FELT (FOR SOME REASON) THAT THE LETTER W BELONGED NEAR
                THE BEGINNING OF THE ALPHABET, AND THAT ALL OF THOSE \"UPSTART LETTERS
                WHICH UNFAIRLY USURPED THE BEST PLACES\" SHOULD BE FORCED INTO EXILE
                AT THE END OF THE ALPHABET.  HIS INSTINCT FOR MATTERS MAGICAL AND
                MYSTICAL LED HIM TO APPLY THIS STRANGE BELIEF INTO THE CAVE'S
                STRUCTURE WHEN HE EXCAVATED IT.  YOU HAVEN'T YET BEEN AFFECTED BY HIS
                STRANGE HABITS, BUT YOU SHOULD REMEMBER THIS.  FAREWELL, AND GOOD
                LUCK.<.q>  With that, the Djinn evaporates into a cloud of smoke and
                drifts rapidly away.\n";
                //        if(not phugggVerb.isused)
                //             // Don't mention this if it's already been used.
                //             notify(Djinn, &phugggtell, Djinn.phugggtime);
                
                djinn.moveInto(nil);
            }
            else "The pentagram is empty - there's nothing to  let out!  ";
        }
    }
    
    iobjFor(PutIn) asIobjFor(PutOn)
    iobjFor(PutOn)
    {
        check()
        {
            if (djinn.isIn(self))
                "You can't put things in the pentagram right now. ";
        }
        
        action()
        {
            "You have set {the dobj} down in the center of the pentagram.  ";
            inherited();
        }
    }
    
    iobjFor(ThrowTo) asIobjFor(ThrowAt)
    iobjFor(ThrowAt)
    {
        verify() {}
        action()
        {
            local o = gDobj;
            if(gDobj.ofKind(ContLiquid))
                o = gDobj.mycont;
            if(!djinn.isIn(self))
            {
                "There's not much point in throwing anything at an empty pentagram. ";
                return;
            }
            if(o == glassVial)
            {
                doInstead(ThrowAt, o, djinn);
                return;
            }
            
            
        }
        
    }
       
    dobjFor(Enter) asDobjFor(Board)
    
    dobjFor(Board)
    {        
        check()
        {
            if(djinn.isIn(self))
                "You can't enter the pentagram right now.  ";
        }
        action()
        {
            inherited();
            "Okay, {i}{'m} now on {the dobj}. Nothing unexpected happens. ";
        }
    }    
;

chimneyRoom: NoNPC, DarkRoom 'End of Crack, at Bottom of Chimney'
    "The crack in the rock ends here, but a narrow
        chimney leads up.  You should be able to climb it."
    game550 = true
    wino_wsbridge = true // can only exit via stone bridge    
    
    south = byPentagram
    up = inTube
    climb = inTube
    tube = inTube
    pentagram = byPentagram
    crack = byPentagram
;

inTube: NoNPC, DarkRoom 'Lava Tube at Top of Chimney'
    "You're at the top of a narrow chimney in the rock.
        A cylindrical tube composed of hardened lava leads south. "
    game550 = true
    wino_wsbridge = true // can only exit via stone bridge
    sdesc = ""
    
    south = tubeSlide
    down = chimneyRoom
    climb = chimneyRoom
    chimney = chimneyRoom
    tube = tubeSlide
    slide = tubeSlide
;

tubeSlide: NoNPC, DarkRoom 'Steep Slide in Tube'
       "The lava tube continues down and to the south, but
        it becomes very steep - if you go down it you
        probably won't be able to get back up. "
    
    game550 = true
    wino_wsbridge = true // can only exit via stone bridge
    
    north = inTube
    south: TravelConnector -> southFog
    {
        travelDesc = "Wheeeeee......     <i>oof</i>"
    }
        
    down asExit(south)
    slide = south
    chimney = chimneyRoom
    tube = chimneyRoom
;

southBasilisk: NoNPC, DarkRoom 'Rough, Narrow Passage'
    "You are in a narrow and rough passage running
        north and south.  A dull rumbling sound can be
        heard from the south." 
    
    game550 = true
    wino_wsbridge = true // can only exit via stone bridge
    sdesc = ""
    
    south = byFigure
    north: TravelConnector ->northBasilisk
    {
        travelDesc()
        {
            if(basilisk.isIn(self)) "The basilisk stirs restlessly
                and grumbles in its sleep as you pass, but
                it does not awaken.<.p>"; 
        }
    }
  
//    exithints = [ North_Basilisk, &north ]
;

northBasilisk: NoNPC, DarkRoom 'North of Basilisk'
    "You're in a rough passage to the north of the basilisk's den."
    
    game550 = true
    wino_wsbridge = true // can only exit via stone bridge
    
    south: TravelConnector -> southBasilisk
    {
        // Note that a dead player should not be moved, since
          // it won't occur until after the resurrection.
        canTravelerPass(actor, connector) { return !playerStoned; }
        noteTraversal(actor)
        {
            if (basilisk.isIn(self)) { // Do neither if it's a statue.
                if (metalPlate.location ==  actor) 
                {
                    basilisk.petrified;
                    playerStoned = nil;
                }
                else 
                {
                    basilisk.petrifier;
                    playerStoned = true;
                }
            } 
            
            inherited(actor);
        }
    }
        
    north = basiliskFork
//    exithints = [ South_Basilisk, &south ]
    
    playerStoned = nil
;

basiliskFork:  NoNPC, DarkRoom 'Fork by Steps'
    game550 = true
    wino_wsbridge = true // can only exit via stone bridge
    sdesc = "The passage here enters from the south and divides,
        with a wide tunnel exiting to the north and a set of
        steps leading downward. "
    
    north = peelgrunt
    south = northBasilisk
    down = bfSteps
    steps = bfSteps
    toPeelgrunt = peelgrunt
;

+ bfSteps: StairwayDown 'spiral staircase;;steps;it them' 
    "The steps lead down a spiral staircaae. "
    destination = onSteps
;

peelgrunt: NoNPC, DarkRoom  'Peelgrunt Room'
    "You are in the Peelgrunt room. " 
    
    game550 = true
    wino_wsbridge = true // can only exit via stone bridge
    
    west = safeDoorOutsideE    
       
    in asExit(west)
    south: TravelConnector -> basiliskFork
    {
        canTravlerPass(actor) { return safeDoorOutsideE.isOpen; }
        explainTravelBarrier(actor, connector)
        {
            "The safe's door is blocking the exit
            passage - you'll have to close it to get out of here.";
        }
    }
    
    fork asExit(south)
    out asExit(south)
    
    
//    cantReachRoom(otherRoom) 
//        if (toplocation(otherRoom) = In_Safe) {
//            "You can't reach that from outside the safe. ";
//        }
//        else pass cantReachRoom;
//    }
//    exithints = [ Basilisk_Fork, &out,  In_Safe, &in ]
;
 
+ safeExteriorE: SafeExterior    
    connector = safeDoorOutsideE
;

++ safeDoorOutsideE: ExteriorSafeDoor 'safe door'
    otherSide = innerSafeDoorE
;


onSteps: NoNPC, DarkRoom 'On the Steps'
    "You are on a long, spiral set of steps leading
        downwards into the earth. "
    game550 = true
    
    up = basiliskFork
    down = stepsExit
    steps = stepsExit
;

stepsExit: NoNPC, DarkRoom 'Exit on Steps'
    "A small tunnel exits from the steps and leads north.
        The steps continue downwards. "
    
    game550 = true
    wino_wsbridge = true // can only exit via stone bridge
    
    north: Passage 'small tunnel'
    "The small tunnel leads north. "
     -> fakeY2
    {
        location = lexicalParent
    }
        
    up = onSteps
    down = storage
    steps = storage
    // exit = Fake_Y2   (since "exit" clashes with the keyword.)
;

storage: NoNPC, DarkRoom 'Storage Room'
    "You're in what was once a storage room.  A set of
     steps leads up. "
    game550 = true
    wino_wsbridge = true // can only exit via stone bridge
    
    up: StairwayUp 'set of steps;;;it them' "The steps lead up. " ->stepsExit
    {
        location = lexicalParent
    }
    steps = up    
;



fakeY2: NoNPC, DarkRoom 'At <q>Y2</q>'
    "You are in a large room, with a passage to the
        south, a passage to the west, and a wall of broken
        rock to the east. There is a large <q>Y2</q> on 
    <<if gActor.isIn(fakeY2Rock)>>the rock you are sitting on<<else>>
    a rock in the room's center<<end>>>. "
      
    
    game550 = true
    wino_wsbridge = true // can only exit via stone bridge
    sdesc = "At \"Y2\"?"
    
    plugh = volcanoPlatform
    south = stepsExit
    
    east = fakeJumbleOfRock
    wall = fakeJumbleOfRock
    
    
    broken = fakeJumbleOfRock
    west: TravelConnector -> catacombs
    {
        travelDesc()
        {
            catacombs.roomnumber = 1;
        }
    }       
       
    plover = volcanoPlatform

    roomDaemon()
    {
        if (rand(100) <= 25) 
            "<p>A hollow voice says, <q>Plugh</q>. ";
        
    }
;

+ fakeY2Rock: Fixture, Chair '<q>Y2</q> rock fake; y2'
    "There is a large <q>Y2</q> painted on the rock. "
    game550 = true
    wino_wsbridge = true // can only exit via stone bridge
    
    dismabigName = 'fake Y2 rock'   
;

fakeJumbleOfRock: NoNPC, DarkRoom 'Jumble of Rock'
    "You are in a jumble of rock, with cracks everywhere. "
    game550 = true
    wino_wsbridge = true // can only exit via stone bridge
    
    down = fakeY2
    y2 = fakeY2
    up: TravelConnector -> catacombs
    {
        travelDesc() { catacombs.roomnumber = 1; }
    }    
;

// Note how the catacombs are implemented!  There is really only one room,
// but it looks like 19 rooms to the player.  The relevant properties and
// methods are:
//
// roomnumber: The catacomb number (which in the 550-point game goes up
// if you choose the correct direction or down for the wrong direction.)
// oldnumber: The old value of roomnumber (for the leaveroom method).
//
// leaveroom: This method is now called by the standard leaveRoom method, and
// causes objects in the room are moved into Elsewhere.  They are 'tagged'
// with the room number so they can be reinstated when the same .
//
// enterroom: This method is called by the standard enterRoom method.
// It updates oldnumber and reinstates the correct room contents.

catacombs: Room 'Catacombs'
    desc()
    {
        "You are in the catacombs.  Enchanted tunnels lead in all directions. ";
#ifdef __DEBUG        
        "(You are in room number <<roomnumber>>.) ";
#endif    
    }
    
    oldnumber = 1
    maxnumber = 0   // highest number seen by player        
    roomnumber = 1
    
    leaveRoom()
    { // called whenever the player leaves one room.
        local i,o,c,l;
        c = contents;
        l = c.length;
        for (i =1; i <= l; i++) 
        {
            o = c[i];
            if (o.isFixed) continue; // DJP - exclude fixed items
            // Move everything out so it doesn't show up
            // in the next room. Only alters objects directly
            // in the catacombs of course, not in the player.
            //
            o.moveInto(elsewhere);
            o.catac_room_num = oldnumber;
        }
    }
    
    enterRoom() 
    {
        local i,o,c,l; // Update oldnumber and reinstate items
        
        /* 
         *   In this version we obtain a list of items with the right roomnumber here rather than
         *   checking for it in the loop below, as in the TADS 2 original.
         */
        c = elsewhere.contents.subset({o: o.catac_room_num == roomnumber});
        l = c.length;
        // DJP - make the room look 'unseen' if it should be.
        if (roomnumber > maxnumber) 
        {
             seen = nil;
            visited = nil;
             maxnumber = roomnumber;
        }
        oldnumber = self.roomnumber;
        
        
        // Move everything with the appropriate room
        // number into the new room.        
        // Note that in this implementation x is already the subset of
        // objects with the relevant catac_room_num        
        for (i =1; i <= l; i++) 
        {            
            o = c[i];
            if (!o.isFixed) // DJP - exclude fixed items                
                o.moveInto(self);
        }
    }    
    
    travelerLeaving(traveler, dest) 
    { 
        leaveRoom();
        inherited(traveler, dest);
    }
    
    
    travelerEntering(traveler, origin) 
    { 
        enterRoom();
        inherited(traveler, origin);
    }
    
    // For the 550-point game, the directions through the Catacombs
    // are fixed.  Note that this is not the case for the 660-point
    // game, which will need rather different coding.  The 'correct'
    // moves through the catacombs are chosen by the player on his
    // first trip through them!

    north
    {  // Direction to next room varies with the room number
        // in last room, leads out.
        if(roomnumber == 20)
            return fakeY2;           
        if(roomnumber is in (0, 8, 10, 19))
            roomnumber ++;
        else if(roomnumber > 1)
            roomnumber--;
             
        return self; // leads to previous room in catacombs        
    }
    
    south
    {
        if(roomnumber is in (0, 1, 4, 9, 18))
           roomnumber++;
        else if(roomnumber > 0)
            roomnumber--;
        return self;
    }
    
    east
    {
        if(roomnumber == 11)
            return westAudience;
        if(roomnumber is in (0, 12, 15))
           roomnumber++;
        else if (roomnumber > 1) 
            roomnumber--;
        return self;
    }
    
    west
    {
        if(roomnumber is in (0, 6))
            roomnumber++;
        else if (roomnumber > 1) 
            roomnumber--;   
        return self;
    }
    
    northwest
    {
        if(roomnumber is in (0, 3, 7))
           roomnumber++;
        else if(roomnumber > 1) 
           roomnumber--;
        return self;          
    }
    
    northeast
    {
        if(roomnumber is in (0, 14))
           roomnumber++;
        else if(self.roomnumber > 1)
            roomnumber--;
        return self;
    }
    
    southeast
    {
        if(roomnumber is in (0, 13, 16))
            roomnumber++;
        else if (roomnumber > 1) 
            roomnumber--;
        return self;
    }
    
    southwest
    {
        if(roomnumber is in (0, 2, 11))
            roomnumber++;
        else if (roomnumber > 1) 
            roomnumber--;
        return self;
    }
    
    down
    {
        if(roomnumber is in (0, 5, 17))
            roomnumber++;
        else if (roomnumber > 1) 
            roomnumber--;
        return self;
    }
    
    
    up
    {
        if (roomnumber > 1) 
            roomnumber--;
        return self;
    }   // None of the rooms use up as the passage to the next room!
    
    /* 
     *   The TADS 2 port (and presumably that original) offers no easy way for the player to
     *   navigate this maze, which modern players may find quite taxing and tedious, but since the
     *   tunnels are described as enchanyted we'll take that as a hint to use some magic words here,
     *   XYZZY to go forward through the maze and  PLUGH get out again at fake Y2.
     */
    xyzzy()
    {
        "Nothing obvious happens, but you feel your attention mysteriously drawn to the exit leading
        <<['south', 'southwest', 'northwest', 'south', 'down', 'west', 'northwest', 'north',
        'south', 'north', 'east', 'north', 'north','north', 'north', 'north', 'north', 'north',
            'south', 'south', 'south'].element(roomnumber)>>. ";
    }
    
    plugh()
    {
        "Nothing obvious happens, but you feel your attention inexorably drawn to the exit leading
        <<['south', 'southwest', 'northwest', 'south', 'down', 'west', 'northwest', 'north',
        'south', 'north', 'southwest', 'east', 'southeast', 'northeast', 'east', 'southeast',
            'down', 'south', 'north', 'north'].element(roomnumber)>>. ";
    }
    
    
    
//    back = {
//        "The directions are particularly confusing in here, and
//        the rooms all look alike.  You'll have to tell me how to go
//        back. ";
//        return nil;
//    }    
;

+ Decoration 'tunnels;enchanted confusing bewildering ;tunnel direction;them'
    "The tunnels run off bewilderingly in every conceivable direction. "
    notImportantMsg = 'You\'ll have to say which way you want to go. '
;
    


westAudience: NoNPC, Room 'West Audience Hall'
        "You are standing at the west end of the royal
        Audience Hall.  The walls here are composed
        of the finest marble, and the floor is built
        of slabs of rare onyx and bloodstone.  The
        ceiling is high and vaulted, and is supported
        by pillars of rare Egyptian red granite; it
        gives off a nacreous glow that fills the
        entire chamber with a light like moon-light
        shining off of polished silver. "

    game550 = true
    wino_wsbridge = true // can only exit via stone bridge
    
    west = catacombs  // roomnumber should still be 11.
    east = eastAudience
;

eastAudience: NoNPC, Room 'East Audience Hall'
    "You are at the eastern end of the Audience Hall.
    There is a large dais rising out of the floor
    here;  resting upon the dais is a strange-looking
    throne made out of interlocking bars and rods of
    metal. "
    game550 = true
    wino_wsbridge = true // can only exit via stone bridge
    
    west = westAudience
;

+ serpentThrone: Fixture 'throne; (serpent) strange strange-looking metal;bars rods'
    "The throne is composed of several interlocking bars and rods,
        as though its owner had a serpentine body. "
    
    cannotBoardMsg = 'It\'s not built for humans. '
    cannotEnterMsg = cannotBoardMsg    
    cannotSitOnMsg = cannotBoardMsg
    cannotLieOnMsg = cannotBoardMsg
    cannotStandOnMsg = cannotBoardMsg
;

+ skeleton: Fixture 'skeleton; giant incredible strange six-armed skeletal; waist arms python'
    "Below the waist, the skeleton resembles that of a giant
        python, and is wrapped carefully through the throne.  Above
        the waist, it resembles the skeleton of a giant human with
        six arms.  In one of these arms is <<mention name sceptre>>! "
    game550 = true
    
    cannotPutInMsg = 'I don\'t know how to put anything into {the iobj}. '
    
   initSpecialDesc = "Resting on the throne (<q>sitting</q> isn't really the
            right word) is an incredible skeleton.  It
            is fairly humanoid from the waist up (except
            for its incredible size and four extra arms);
            below that, it resembles the body of a giant
            python, and is wrapped in and around the bars
            and rods of the throne.  Clutched in one bony
            hand is <<mention name sceptre>>!! "
;


windingPass: NoNPC, DarkRoom 'Winding Passage'
    "You are in a winding passage which enters from
        the northwest, loops around several times, and
        exits to the north. "
    game550 = true
    wino_wsbridge = true // can only exit via stone bridge
    
    north = golden
    toGolden = golden
    northwest = byFigure
;

golden: NPC, DarkRoom 'Golden Chamber'
     "You are in a chamber with golden walls and a high
        ceiling.  Passages lead south, northeast, and
        northwest. "
    game550 = true
    wino_wsbridge = true // can only exit via stone bridge
    
    passage = "Passages lead south, northeast, and northwest. You'll have to
         say which way you want to go. "

    south = windingPass
    northwest = translucent
    northeast = arabesque
    toArabesque = arabesque
    toTranslucent = translucent
;

+ Decoration 'golden walls;;;them'
;
+ Distant 'high ceiling'
;

translucent: NoNPC, Room 'Translucent Room'
    "You are in a large room whose walls are composed of
        some translucent whitish material.  The room is
        illuminated by a flickering reddish glow shining
        through the southern wall.  A passage leads east."
    game550 = true
    wino_wsbridge = true // can only exit via stone bridge
    
    east:TravelConnector -> golden
    {
        travelDesc()
        {
            if(!gobs_called && bracelet.isIn(gActor)) 
            {
                gobs_called = true; // Don't summon them twice.
                /* 
                 *   Summon the goblins at the end of the turn, after we've completed the move to
                 *   the new location.
                 */
                new Fuse(self, &summonGoblins, 0);
            }
        }
        
        gobs_called = nil
        
        summonGoblins() { goblins.summon(golden); }
    }
        
    out asExit(east)
    toGolden = east
    passage = east
//    exithints = [ Golden, &east ]   
;
    
+ Decoration 'translucent white walls; whitish southern s south; material wall; them it'
    "The walls are composed of some translucent whitish material. <<redGlow.desc>>"
;   

+ redGlow: Decoration 'flickering reddish glow; red'
    "The glow is shining through the southern wall. "
    notImportantMsg = 'The glow is too insubstantial for that. '
;
 
arabesque: NoNPC, DarkRoom 'Arabesque Room' 'arabesque room; small elaborate of[prep]; 
    walls pattern figures; it them'
    "You are in a small room whose walls are covered
     with an elaborate pattern of arabesque figures and designs."
    
    game550 = true
    
    south = golden
    out asExit(south)
    toGolden = golden
;

volcanoPlatform: NoNPC, Room 'Platform above Volcano'  'platform above the volcano; tiny'
    "You are precariously perched on a tiny platform
    suspended in midair.  Two thousand feet below
    you is the mouth of a very active volcano,
    spewing out a river of hot lava. "
    
    game550 = true
    wino_wsbridge = true // can only exit via stone bridge
    sdesc = ""
    
    plugh = fakeY2
    plover = fakeY2    
    
    north: TravelConnector ->volcanoPlatform
    { 
        isConnectorListed = nil
        
        travelDesc()
        {
            "EEEEEEEEAAAAAAAAAAAaaaaahhhhhhhh........... <i><b>sizzle</b></i>";
            die();
        }
    }
    
    south asExit(north)
    east asExit(north)
    west asExit(north)
    northwest asExit(north)
    southwest asExit(north)
    southeat asExit(north)
    northeast asExit(north)
    jumnp asExit(north)
    climb asExit(north)
    down asExit(north)
    noExits = 'none immediately apparent'
;


+ Distant 'active volcano; hot very of[prep];lava river mouth'
    "Two thousand feet below you is the mouth of a very
        active volcano, spewing out a river of hot lava. "
;

sandstoneChamber: DarkRoom 'Sandstone Chamber' 'sandstone chamber room; small'
    "You are in a small chamber to the east of the Hall
        of Mists.  The walls are composed of rough red
        sandstone.  There is a large, cubical chunk of rock
        in the center of the room. "
    game550 = true
    
    west = inHallOfMists
    out asExit(west)
    mists = inHallOfMists
//    ana2 = Blue_Sandstone_Chamber // ADD FOT 701p game if and when
;

+ Decoration 'walls; rough red sandstone;;them'
     "The walls are composed of rough red sandstone. "    
;

+ ProxyRoom ->inHallOfMists;

+ stone: StoneClass     
    stateDesc()
    {
        if(singingSword.isStuck)
            singingSword.initSpecialDesc();
    }
    
    dobjFor(Search)
    {
        action()
        {
            if(singingSword.isStuck)                
            {               
                singingSword.initSpecialDesc();
                if(contents.length > 0)
                    inherited();
            }
            else
                inherited();
        }
    }
    
;

class StoneClass: Fixture, Surface 'chunk of rock;large cubical;stone block'
    "It's a large, cubical chunk of rock sitting in the center of the room. "
;


morion: DarkRoom 'Morion Room'   
    desc 
    { 
        "You are in a small room.  The walls are composed of
        a dark, almost black form of smoky quartz; they
        glisten like teeth in the lamp-light. ";
        if (global.game701)
            "The exits are the passage to the south through
            which you entered, and a narrow passage leading northeast. ";
        else
            "The only exit is the passage to the south through which you
            entered. ";
    }
    south = inHallOfMtKing
    out asExit(south)
    northeast: TravelConnector -> throneRoom
    {
        isConnectorApparent = global.game701
    }
    
    
    

    NPCexit1 
    {
        if (global.game701) return throneRoom;
        else return nil;
    }

//    exithints = {
//        if (global.game701) return [Throne_Room, &ne];
//        else pass exithints;
//    }
;




/* 
 *   The TADS 2 port makes this object both a room representing the inside of the safe and a
 *   floating_decoration (MultiLoc) representing its exterior in two different location. The TADS
 *   3/adv3Lite implementation will need to be rather different. Here we use inSafe to represent the
 *   inside of the safe and, provisionally, safeExterior to represent its outside, but this may need
 *   dividing into safeExterior1 and safeExterior2.
 */

class SafeExterior: Enterable 'large metal safe; walk-in'
    desc()
    {
        if (connector.isOpen) 
            "It's a large metal safe, only one wall of which is visible.  ";
        else 
            "It's a large metal walk-in safe, the door of which has been swung open.  "; 
    }
    
    specialDesc 
    {
        "A massive walk-in safe takes up one entire wall.  ";
        if (connector.isOpen)
            "Its door has been swung open and blocks the exit passage.";
        else if(inSafe.isFused) 
            "It is closed, and there are signs of melting around the edges of its door.";
        else 
            "It is tightly closed, and has no handle, lock, or keyhole. ";
    }   
    
    game550 = true
    
    dobjFor(Open) { remap = connector }
    dobjFor(Close) { remap = connector }
;

vault: DarkRoom 'Vaulted Room'
    "You are in a room with a high, vaulted ceiling.  A
        tunnel leads upwards and to the north. "
    
    game550 = true
    
    north: TravelConnector -> inHallOfMtKing
    {
        canTravelerPass(actor) { return !safeDoorOutsideW.isOpen; }
        explainTravelBarrier(actor, connector)
        {
            "The safe's door is blocking the exit
            passage -- you'll have to close it to get out of here. ";
        }
    }
    
    up asExit(north)
    east = safeDoorOutsideW
    in asExit(east)
    toSafe = safeDoorOutsideW
    
      
//    myhints = [ Vaulthint ]

    // Let NPCs out of here.
    NPCexit1 = inHallOfMtKing 
    // NPCs can enter the safe, but only if it opens to the Vault.
    NPCexit2 
    {
        if(inSafe.out == self) return inSafe;
        else return nil;
    }
      
    
;

+ safeExteriorW: SafeExterior    
    connector = safeDoorOutsideW
;

++ safeDoorOutsideW: ExteriorSafeDoor 'safe door'
    otherSide = innerSafeDoorW
;

class ExteriorSafeDoor: Door 'safe door'
    "It's currently <<if isOpen>>open<<else>>closed<<end>>. "
    
    dobjFor(Open)
    {
        check()
        {
            if (inSafe.isFused) 
                "The door to the safe seems to be fused shut -- I can't open it. ";
            else 
                "The door to the safe has no keyhole, dial,
                or handle -- I can't figure out how to open it! ";
        }        
    }
    
    makeOpen(stat)
    {
        inherited(stat);
        if(stat)
            otherSide.discover();
    }
;


class InteriorSafeDoor: Door 'door'
    desc 
    {
        if (isOpen) 
        {
            "{The subj dobj} {is} open, but I don't think you'll be
            able to close it from inside the safe. ";
        }
        else {
            "{The subj door} {is} firmly closed, and I can't figure
            out any way to open it. "; 
        }    
    }
    
    isHidden = true  
    
    dobjFor(Open)
    {
        check()
        {
            "I can't figure out any way to open {the dobj}. ";
        }
    }
    
    dobjFor(Close)
    {
        check()
        {
            "There is no handle on the inside of the safe door, nor any 
            other way to get a firm enough grip on it.  You'll have to 
            leave the safe before shutting it. ";
        }
    }
    game550 = true
    
    dobjFor(Push)
    {
    }
;


inSafe: DarkRoom 'In the Safe'
    desc()
     {         
        "You are inside the safe.  ";
        switch (out) 
        {
            case nil:
                if(bothdoors) "Both doors are firmly shut. ";
                else "The door is firmly shut.  So firmly, in fact, that
                     you can only just make out its outline in the 
                     wall. ";
                break;
            case innerSafeDoorW:
                if(bothdoors) "The west door is open. ";
                else "The door is open and exits to the west. ";
                break;
            case innerSafeDoorE:
                if(bothdoors) "The east door is open. ";
                else "The door is open and exits to the east. ";
                break;
        }
    }
    
    
    game550 = true      // This safe is not to be confused with Safe in the building
    isOpen = (out != nil)
    bothdoors = nil
    
    password = nil  // Initially. When sceptre is taken, it changes to
                    // the number for the appropriate word.
    
    
    melts()
    {
        "<i>bong</i>\t\t\t\t\t\tThe very air quivers with sound as though\n";
        "\ \ <i>bong</i>\t\t\t\t\tsomeone, somewhere in the distance, has struck\n";
        "\t\ <i>>bong<i>\t\t\t\t\tthree powerful blows on an immense brass gong.\n";
        "<.p>Smoke trickles out from around the edges of the
        safe's door, and the door itself glows red with
        heat for a moment.\b"; 
        "A hollow voice says,  <q>This is a Class 1 security
        alarm.  All cave security forces go to Orange Alert.
        I repeat - Orange Alert.</q>";
        isFused = true;
        // Add flag so that we can test whether an alert has been issued,
        // before the blob summoning code is executed.  This flag is reset
        // in the die() routine.
        global.triggered_alert = true;
        new Fuse (blob, &summon, 2); // Two turns before blob is
                                  // actually summoned.
    }
    
    
    
    isFused = nil
    
    out = [innerSafeDoorW, innerSafeDoorE].valWhich({d: d.isOpen})
    east = innerSafeDoorE
    west = innerSafeDoorW
    
    wino_wsbridge
    {
        if(out) {
            if(out.destination.wino_wsbridge) return true;
            else return nil;
        }
        else return nil;
    }   
    
       
    
    opens()
    { 
        "<i>ker-THUNK<\t>screeeeeeeeeech</i>\b
        The (somewhat rusty) safe is now open. ";
        if(gActor.isIn(vault))
            safeDoorOutsideW.makeOpen(true);
        if(gActor.isIn(peelgrunt))
            innerSafeDoorE.makeOpen(true);
            
        
//        self.isopen := true;
//        self.out := self.location;
    }
;

+ innerSafeDoorW: InteriorSafeDoor 'door; west w'
    
    disambigName = 'west door'
    otherSide = safeDoorOutsideW
;

+ innerSafeDoorE: InteriorSafeDoor 'door; east e'
    
    disambigName = 'east door'
//    otherside = safeDoorOutsideW
;

// BJS: Added this object, to reveal the
 // unused keywords./ BJS: Added this object, to reveal the
 // unused keywords.

+ Fixture 'list of words;;word'
    desc()
    {
        "It says: <q>zorton snoeze knerl klaetu blerbi</q>";
        local i; 
        if (inSafe.password) 
        {
            "\nThere is a marking next to <q>";
            // Now print the vault keyword, using its sdesc.
            for(i = firstObj(VaultKeyVerb); i;  i = nextObj(i, VaultKeyVerb))
            {
                if(i.wordnum == inSafe.password) 
                    say(i.verb);
            }
            ".</q2>\n";
        }
    }
    
    game550 = true
    
    specialDesc = "A list of words hangs on one wall. "
    // DJP - make 'x list' the same as 'read list'
    
    cannotTakeMsg = 'The list is attached so firmly to the wall that
        it won\'t come off. '    
;

+ Decoration 'walls; (north) (south) (east) (west) (n) (s) (w) (e) inner; wall; them'
    desc
    { 
        "The inner walls of the safe are almost featureless";
        if (inSafe.out == nil) // only when viewed with sapphire
            ", but close examination reveals the outlines of doors in the 
            east and west walls.  Both are firmly shut. ";
        else 
        {
            ", but a large door has been opened in the ";
            if (inSafe.out == innerSafeDoorE) "east"; else "west";
            " wall.  At first glance the ";
            if (inSafe.out == innerSafeDoorE) "west"; else "east";
            " wall looks completely blank, but close examination reveals 
            the outline of a second door, identical to the first - but firmly 
            closed. ";
        }
        inSafe.bothdoors = true;
        innerSafeDoorE.discover();
        innerSafeDoorW.discover();        
    }
;

corridor1: DarkRoom 'Wide, North-and-South Corridor'
    "You are standing in a wide, north-and-south corridor."
    
    game550 = true
   
    north = corridor2
    south = inHallOfMtKing
;

corridor2: DarkRoom 'Bend in Wide Corridor'
    "You are standing at a bend in a wide corridor which
        runs to the east and west.  To the east, the corridor
        turns left and continues north; to the west, it turns
        left and continues south."
    
    game550 = true
    
    north asExit(east)
    south asExit(west)
    west = corridor1
    east = toolRoom
    southwest asExit(west)  // BJS: Added.
    northeast asExit(east)   //  "" "" ""
;


toolRoom: DarkRoom 'Tool Room'
    "You are in a small, low-ceilinged room with the words,
        <q>Witt Company Tool Room -- Melenkurion division</q>
        carved into one of the walls.  A wide corridor runs
        south from here."
    
    game550 = true
    
    south = corridor2
    out asExit(south)
;

+ Fixture 'carving on the wall; carved;message words writing'
    "The message carved into the wall reads, <q>Witt Company
        Tool Room -- Melenkurion division.</q> "
    game550 = true
    readDesc = desc
;

corrDivis: DarkRoom 'Division in Passage' 'division in passage; narrow main; spurs'
    "You are at a division in a narrow passage.  Two spurs
     run east and north;  the main passage exits to the south."
    
    game550 = true
    
    north = sphericalRoom
    south = inHallOfMtKing
    east = inCubicle
;
    
inCubicle: DarkRoom 'Dank Cubicle' 'dank cubicle; small; rock'
    "You are in a small, dank cubicle of rock.  A small
        passage leads back out to the south;  there is no
        other obvious exit."
    game550 = true
    
    south = corrDivis
    out asExit(south)
    corridor = corrDivis
    passage = corrDivis
;

sphericalRoom: DarkRoom 'Spherical Room'
    "You're in a large, completely spherical room with
    polished walls.  A narrow passage leads out to the north. "
    game550 = true
    
    north = corrDivis
    out asExit(north)
    corridor = corrDivis
    passage = corrDivis
;

glassyRoom: DarkRoom 'Large Room with Glassy Walls' 
    "You're standing in a very large room (which however
      is smaller than the Giant room) which has smooth,
      glassy-looking walls.  A passage enters from the
      south and exits to the north. "
    game550 = true
    
    south = atRecentCaveIn
    
    north: TravelConnector -> sorcLair
    {
        canTravelerPass(actor) { return !ogre.exists; }
        explainTravelBarrier(actor, connector)
        {
            "The ogre growls at you and refuses to let you pass. ";
        }       
    }
    
    lair = north
        
    
    NPCexit1  { return sorcLair; } // As usual, NPCs get by with no trouble.
//    exithints = [ Sorc_Lair, &north ]
;


sorcLair: Room 'Sorcerer\'s Lair'
    "This is the Sorcerer's Lair.  The walls are covered
    with exotic runes written in strange, indecipherable
    scripts;  the only readable phrase reads <q>noside
    samoht</q>.  Strange shadows flit about on the walls,
    but there is nothing visible to cast them.
    Iridescent blue light drips from a stalactite far
    above, falls towards the floor, and evaporates before
    touching the ground.  A deep, resonant chanting
    sound vibrates from deep in the ground beneath your
    feet, and a whispering sound composed of the echoes
    of long-forgotten spells and cantrips seeps from the
    walls and fills the air.  Passages exit to the east
    and west. "
    game550 = true
    isbonus = true
    
    west = glassyRoom
    east = brinkNorth
;

+ Fixture 'exotic runes; indecipherable ;walls rune words; them'
    "The walls are covered with exotic runes written in strange,
    indecipherable scripts;  the only readable phrase reads
    <q>noside samoht</q>."
    game550 = true    
;

brinkNorth: DarkRoom 'Brink of Bottomless Pit'
    "You are standing on the brink of what appears to
    be a bottomless pit plunging down into the bowels
    of the earth.  Ledges run around the pit to the
    east and west, and a passage leads back to the
    north. "
    game550 = true
    
    north = sorcLair
    west = brinkSouth
    east = brinkEast
    lair = sorcLair
    jump { bottPit.plunge(gActor); }    
;

brinkSouth: DarkRoom 'South Edge of Bottomless Pit'
    "You are standing at the south end of a ledge running
    around the west side of a bottomless pit.  The ledge
    once continued around to the east side of the pit,
    but was apparently obliterated by a rock-slide years
    ago.  A cold wind blows out of a tunnel leading to
    the southeast. "
    game550 = true
        
    north = brinkNorth
    southeast = iceRoom
    jump { bottPit.plunge(gActor); }       
;

brinkEast: DarkRoom 'East Side of Bottomless Pit'
    "You are standing on the eastern side of a bottomless
    pit.  A narrow ledge runs north towards a
    dimly-visible passage;  the ledge once continued
    south of this point but has been shattered by falling
    rock.  A narrow crack in the rock leads northeast. "
    game550 = true
   
    north = brinkNorth
    northeast = crack1
    crack = crack1
    jump { bottPit.plunge(gActor); }    
    
;

bottPit: MultiLoc, Fixture 'bottomless pit; deep looking deep-looking'
    "It's a deep-looking pit. "
    game550 = true
    
    locationList = [ brinkNorth, brinkEast, brinkSouth ]
  
    
    dobjFor(Enter)
    {
        verify() {}
        action() { plunge(gActor); }
    }
    
    plunge(actor) 
    {
            local eaten;
            "You have jumped into a bottomless pit.
            You continue to fall for a very long time. ";
            if(brassLantern.isLit && brassLantern.isIn(actor))
            {
                    "First, your lamp runs out of power and goes
                    dead. ";
            }


            // Zap the lamp if it's lit (wherever it is)
            if (brassLantern.isLit) brassLantern.setLife(0);
            // Since we're mentioning hunger and thirst, consume
            // any accessible food and drink.  The code to do this is a 
            // little complex - in the 701-point game, the items may be
            // in closed containers and we must open them first.

            // Start by opening the sack if we have it (it might contain the
            // keys to unlock the chest)
            if (sack.isIn(actor)) {
                sack.makeOpen(true);
            }
            // Open the chest if it is unlocked.
            if (treasureChest.isIn(actor) && !treasureChest.isLocked) {
                treasureChest.makeOpen(true);
            }
            // Unlock the chest if we can.
            if (treasureChest.isIn(actor) && treasureChest.isLocked
            && setOfKeys.isIn(actor) && !setOfKeys.isIn(treasureChest)) {
                if(setOfKeys.location != actor) 
                    setOfKeys.moveInto(actor);
                treasureChest.makeOpen(true);
                treasureChest.makeLocked(nil);
            }
            // Try opening the sack again (in case it was hidden inside
            // the chest)
            if (sack.isIn(actor) && !sack.isOpen) {
                sack.makeOpen(true);
            }
            if (tastyFood.isIn(actor)){
                tastyFood.moveInto(nil);
                eaten = true;
            }
            if (honeycomb.isIn(actor)){
                honeycomb.moveInto(nil);
                eaten = true;
            }
            if (mushrooms.isIn(actor)){
                mushrooms.moveInto(nil);
                mushrooms.regrow(); // Regrow mushrooms straight away due to
                                  // lapse of time.
            }
            if (mushroom.isIn(actor)){
                mushroom.moveInto(nil);
                mushroom.regrow();  // Regrow mushroom straight away due to
                                  // lapse of time.
            }
            if (bottle.isIn(actor) && bottle.haswater)bottle.empty;
            if (flask.isIn(actor) && flask.haswater)flask.empty;
            if (cask.isIn(actor) && cask.haswater)cask.empty;
            if (bottle.isIn(actor) && bottle.haswine)bottle.empty;
            if (flask.isIn(actor) && flask.haswine)flask.empty;
            if (cask.isIn(actor) && cask.haswine)cask.empty;

            // Mention hunger only if we didn't manage to eat any
            // substantial food items (mushrooms don't count).
            "Later, you die of ";
            if (!eaten) "hunger and ";
            "thirst.\n";
            die();
    }
;



crack1: DarkRoom 'Narrow, Twisting Crack'
    "You are following a narrow crack in the rock which
    enters from the southwest, turns and twists somewhat,
    and exits to the southeast. "
    game550 = true
   
    southwest = brinkEast
    southeast = crack2    
;

crack2: DarkRoom 'North End of Tight Passage'
    "You are standing at the northern end of a rather
    tight passage.  A narrow crack in the rock leads west. "
    
    game550 = true
    
    west = crack1
    
    south: TravelConnector -> crack3
    {
        canTravelerPass(actor) { return !slime.exists; }
        explainTravelBarrier(actor, connector)
        {
            doInstead(Cross, slime);
        }
    }
    
    cross = south
    across = south
    

    NPCexit1 
    { 
        if (slime.exists) return nil;
        else return crack3;
    }       // NPCs can't cross the slime.
//    exithints = [ Crack_3, &south ]
;

crack3: DarkRoom 'South End of Tight Passage'
    "You are at the southern end of a tight passage.
    A hands-and-knees crawl continues to the south. "
    game550 = true
    
    north = crack2   // The slime must be dead by now.
    south = crack4
    crawl = crack4
;

crack4: DarkRoom 'Very Small Chamber'
    "You are in a very small chamber.  A narrow crawl leads north. "
    game550 = true
    
    north = crack3
    out asExit(north)
    crawl = crack3
;

iceRoom: DarkRoom 'Ice Room'
    "You are in the Ice room.  The walls and ceiling here
    are composed of clear blue glacial ice;  the floor
    is fortunately made of rock and is easy to walk
    upon.  There is a passage leading to the northwest,
    and a slide of polished ice leading downwards to the
    east -- if you were to slide down it you probably
    couldn't get back up. "
    game550 = true
    
    northwest = brinkSouth
    
    down: TravelConnector -> slideBase
    {
        travelDesc = "Wheeeeee...... OOF! "
    }
    
    east asExit(down) // Note that NPCs won't use these exits. If they
    slide = down      // did, they would become trapped.
    thurb = iceCaveExit // The exit was originally one-way, but I've
;                               

slideBase: NoNPC, DarkRoom 'Bottom of Icy Slide'
    "You're at the entrance to an extensive and intricate
    network of ice tunnels carved out of solid ice.  A
    slippery slope leads upwards and north, but you
    cannot possibly climb up it.  Other passages lead
    south and northwest. "
    
    game550 = true
    
    north = "The icy slide is far too steep and slippery to climb. "
    up asExit(north)
    slide = north
    climb = north
    south = Ice_21
    northwest = Ice_4             
    
//    exithints = [ Ice_Room, &north ]
;

Ice_1: IceTunnel 
    north = Ice_1a
    west = Ice_2
;
Ice_1a: IceTunnel
    south = Ice_1
;
Ice_2: IceTunnel
    east = Ice_1
    west = Ice_3
    north = Ice_2a
;
Ice_2a: IceTunnel
    north = slideBase
    south = Ice_2
;
Ice_3: IceTunnel
    east = Ice_2
    north = Ice_3a
;
Ice_3a: IceTunnel
    south = Ice_3
;
Ice_4: IceTunnel
    east = slideBase
    west = Ice_5
;
Ice_5: IceTunnel
    northeast = Ice_4
    south = Ice_6
;
Ice_6: IceTunnel
    north = Ice_5
    south = Ice_7
    west = Ice_9
;
Ice_7: IceTunnel
    north = Ice_6
;
Ice_8: IceTunnel
    north = Ice_9
;
Ice_9: IceTunnel
    east = Ice_6
    south = Ice_8
    north = Ice_10
;
Ice_10: IceTunnel
    south = Ice_9
    northwest = Ice_11
;
Ice_11: IceTunnel
    east = Ice_10
    west = Ice_12
;
Ice_12: IceTunnel
    northeast = Ice_11
    south = Ice_12a
    west = Ice_15
;
Ice_12a: IceTunnel
    north = Ice_12
    south = Ice_13
;
Ice_13: IceTunnel
    north = Ice_12a
;
Ice_14: IceTunnel
    north = Ice_15a
;
+ sculptNiche: Fixture 'niche; melted icy; wall' // BJS: added this object,
    game550 = true                    // put the sculpture in it.
    
    specialDesc = "There is a niche here, melted out of the icy wall of the tunnel. "
    initSpecialDesc = "<<mention name sculpture>> is resting in a niche melted out of the icy 
        wall of the tunnel! "
   
    useInitSpecialDesc = sculpture.isIn(self)
    
    iobjFor(PutIn)
    {
        check()
        {
            if(gDobj.isLong || gDobj.isLarge || gDobj.isHuge)
                "It won't fit! ";
            else
                inherited();
        }
    }  
;

Ice_15: IceTunnel
    east = Ice_12
    south = Ice_15a
    nw = Ice_16
;
Ice_15a: IceTunnel
    south = Ice_14
    north = Ice_15
;
Ice_16: IceTunnel
    east = Ice_15
    west = Ice_17
;
Ice_17: IceTunnel
    northeast = Ice_16
    south = Ice_18
;
Ice_18:IceTunnel
    north = Ice_17
    south = Ice_19
    west = Ice_21
    nw = Ice_22
;
Ice_19: IceTunnel
    north = Ice_18
    west = Ice_20
;
Ice_20: IceTunnel
    east = Ice_19
    north = Ice_21
;
Ice_21: IceTunnel
    east = Ice_18
    south = Ice_20
;
Ice_22: IceTunnel
    southeast = Ice_18
    northwest = Ice_23
;
Ice_23: IceTunnel
    east = Ice_22
    west = Ice_24
;
Ice_24: IceTunnel
    northeast = Ice_23
    south = Ice_25
    west = Ice_29
;
Ice_25: IceTunnel
    north = Ice_24
    south = Ice_26
    west = Ice_28
    northwest = Ice_28a
;
Ice_26: IceTunnel
    north = Ice_25
    northwest = Ice_27
;
Ice_27: IceTunnel
    southeast = Ice_26
    north = Ice_28
;
Ice_28: IceTunnel
    east = Ice_25
    south = Ice_27
;
Ice_28a:IceTunnel
    southeast = Ice_25
    north = Ice_29
;
Ice_29: IceTunnel
    east = Ice_24
    south = Ice_28a
    northwest = iceCaveExit
;

// lit by the letters. BJS
iceCaveExit: NoNPC, Room 'Small, Icy Chamber'
     "You are in a small chamber melted out of ice.  Glowing
        letters in midair spell out the words <q>This way out</q>. "
    
    east = Ice_29
    thurb = iceRoom
;

+ Fixture 'glowing letters; midair; words; them'
    "Glowing letters in midair spell out the words <q>This way out</q>. "
    readDesc = desc
    
    checkReach(actor)
    {
        "Your hand passes right through the letters. ";
    }
;

coralPassage: DarkRoom 'Coral Passage'
    "You are in an arched coral passage which enters from
    the west, splits, and continues on to the east over
    a smooth and damp-looking patch of sand.  The fork
    in the passage once led to the south, but it is
    now completely blocked by debris. "
    
    game550 = true
    wino_quicksand = true // must cross quicksand to leave
   
    south = 'The passage south is blocked by the debris. '
    
    east = quicksand
                                           
    cross = quicksand            
    west = inArchedHall
;      

+ Decoration 'debris'
    "The debris completely blocks the passage to the south, and it doesn't
    look there's any way of clearing it. "
    game550 = true
;

quicksand: DSPassage 'damp-looking sand;damp smooth wet wet-looking quick; sand quicksand' 
    @coralPassage @coralPass2
    "A smooth, damp-looking patch of sand. "
    game550 = true
    
    dobjFor(Cross) asDobjFor(TravelVia)
    
    canTravelerPass(actor) { return isHard && !giantBivalve.isIn(actor) ; }
    explainTravelBarrier(actor, connector)
    {
        if(sankBefore)
            "You know, I've heard
             of people who really fell in for the soft
             sell, but <i>glub</i> this <i>glub</i> is <i>glub</i>
             ridiculous! <i>blop!</i>";
        else
        {
            "Hmmm... this sand is rather soft, and you're
             sinking in a little....  In fact, you're
             sinking in a lot!  Oh, no - it's
             QUICKSAND!!  HELP!!  HELP!!!  HELP!!
             <i>glub   glub    blurp</i>";
             sankBefore = true;
        }
        die();
    }
    
    noteTraversal(actor) { isHard = nil; }
    
    sankBefore = nil
    isHard = nil
    iswavetarget = true // magic can be worked by waving the rod at it ...
;

coralPass2: NoNPC, DarkRoom 'Bend in Arched Coral Corridor'
    "You are at a bend in an arched coral passage;  the
    passage enters from the west over a patch of damp
    sand, turns, and continues north."
    game550 = true
    wino_quicksand = true // must cross quicksand to leave
    
    north = archFork
    west = quicksand
                                           
    cross = quicksand           
;

archFork: NoNPC, DarkRoom 'Fork in Arched Coral Passage'
    "You are at a fork in a high, arched coral passage.
        The main portion of the passage enters from the south;
        two smaller passages lead east and north. <<smellDesc>> "
    game550 = true
    wino_quicksand = true // must cross quicksand to leave
    
    south = coralPass2
    north = Fourier
    east = Jonah
    jonah = Jonah
    fourier = Fourier
    
    smellDesc = "The smell of salt water is very strong here. "
;
    
Jonah: NoNPC, DarkRoom 'Entrance to Jonah Room'
    "You are standing at the entrance of the Jonah room,
     a cavernous hall with high ribbed walls.  The hall
     extends far to the south;  a coral passage leads west."
    game550 = true
    wino_quicksand = true // must cross quicksand to leave
    
    west = archFork
    south = inJonah
;

+ ProxyRoom -> inJonah;
    
inJonah: NoNPC, DarkRoom 'South End of Jonah Room'
    "You are at the south end of the Jonah room.  Ahead
    of you, the way is barred by a large set of immense
    stalactites and stalagmites which intermesh like
    clenched teeth.  Nothing except blackness is visible
    between the stone formations. "
    
    game550 = true
    wino_quicksand = true // must cross quicksand to leave
    
    north = Jonah
    out asExit(north)
    south = 'The stalactites and stalagmites bar any progress in that direction. '
;

+ Decoration 'set of stalactices and stalagmites; immense stone intermneshed clenched; 
    formations teeth; it them'
    "The intermeshed stalactites and stalagmites block the way south. "
;


Fourier: NPC, DarkRoom 'Fourier Passage'
    "You are in the Fourier passage.  This is a long and
    highly convoluted passage composed of coral, which
    twists and turns like the path of an earthworm
    tripping on LSD.  The passage here enters from the
    northwest, convulses, and exits to the southwest
    (from which direction can be felt a cool and
    salty-smelling breeze). "
    game550 = true
    wino_quicksand = true // must cross quicksand to leave
    Zarkalonroom = true
    
    northwest = archFork
    sworthest = beachShelf
//    ana = Blue_Fourier
;


beachShelf: NoNPC, Room 'Shelf of Rock Above Beach'
    game550 = true
    wino_quicksand = true // must cross quicksand to leave
    Zarkalonroom = true // Zarkalonized pendant required for transindection
    
    //
    // Note by D.J. Picton:
    // This area is different in the 660-point game.  So different,
    // in fact, that I've taken the liberty of coding it here, even
    // though the 660-point game isn't implemented yet!
    //
    // (The 660 and 770-point games move the alien scene to the Pentagram 
    // Room area.
    //
    // The 701-point game is based on the 550-point game so we keep the alien
    // scene here, neatly solving the problem of differing sea levels.
    //
    // The 660 and 770-point games do have an apparent sea level problem,
    // because the sea is said to be 1000ft below the surface and we don't
    // have the feeling of having climbed down that far to reach this room
    // (or the sewage outflow in the ante-room area). I say 'apparent',
    // because there could still be hidden space portals in the cave.)
    //
    desc
    { 
        
        if(global.game660) {   
            "You are standing on a large shelf of sedimentary rock overlooking
            a sandy beach. The shelf is an extension of sheer chalk cliff which
            continues north and south for as far as the eye can see. Crudely
            carved steps lead down from the shelf to the beach, and a twisting
            coral passage exits to the west. "; 
        }
        // N.B. in the 770-point game this area lies at the foot of the
        // 1000ft cliff below the giant's picnic site.  There are more rooms
        // and the east and west directions are reversed!
        else {
            "You are standing on a large shelf of sedimentary rock
            overlooking a lava beach.  The shelf is an extension
            of an incredible cliff which extends north, south, and
            upwards for as far as the eye can see.  Crudely carved
            steps lead down from the shelf to the beach, and a
            twisting coral passage exits to the west. ";
            // special stuff for 701+ point game.
            if(global.game701p) 
            {
                if (defined(blueBeachShelf) && blueBeachShelf.seen &&!
                bluebeach.seen && !seen) 
                {                    
                    "<.p>In a flash of intuition, you notice something which
                    previous adventurers may have missed.  There's a zig-zag
                    pattern on the cliff which doesn't look like a natural
                    feature.  Then you realize what it is -- the remains of
                    a stone path which has now been almost obliterated by
                    rockfalls. ";
                }
                else {
                    "A stone path once led up the cliff, but much of 
                    it has now been obliterated by rockfalls. ";
                }
            }
        }
    }
    west = Fourier
    down = beachSteps
    steps = beachSteps
//    ana = Blue_Beach_Shelf
//    myhints = {
//        if(global.game701p) 
//            return [Beach_Shelfhint];
//        else
//            return nil;
//    }
   
;

+ Fixture 'stone path'
    "The rockfalls have destroyed most of the path.  The
    lowest intact section starts about 20 feet above you. "
    game701p = true  // 701+ point game only
    wino_quicksand = true // must cross quicksand to leave    
;

beachSteps: DSStairway 'crudely carved steps;;;them' @beachShelf @beach   
    "The steps are a little crude but are nevertheless readily usable. "
;

MultiLoc, Decoration 'cliff'    
    desc 
    {
        "It extends north, south and upwards as far as the eye can see. ";
        if (location.analevel == 1)
            "The cliff looks exactly as it did at Red level - but now a timber
            roadway has been built on the remains of the path, leading up the
            cliff. ";
        else if (global.game701p)
            "A stone path once led up the cliff face, but most of it has now
            been obliterated by rockfalls. ";
    }    
    locationList = [beachShelf, beach] // Blue_Beach_Shelf, Blue_Beach]
;

beach: NoNPC, Room 'Beach'
    game550 = true
    wino_quicksand = true // must cross quicksand to leave
    Zarkalonroom = true // Zarkalonized pendant required for transindection
    isbonus = true
   
    desc 
    {         
        if(global.game660) {
            "You are standing on a short, rocky beach. To the west a sheer
            white cliff rises into the sky. Rugged and unclimbable outcrops of
            rock block out all view to the north and south. To the east, a
            narrow inlet of sea water laps gently upon the beach. Steps lead up
            the cliff to a shelf of rock. ";
        }
        else {
            "You are standing on a short, barren beach composed of
            hardened lava.  Rugged and unclimbable volcanic hills
            block all view to the north and south, and a seemingly
            infinite cliff fills the entire western hemisphere.
            To the east, a narrow inlet of ocean water laps gently
            upon the beach.  The scene is illuminated by the light
            of three small moons shining through the shimmering
            glow of an aurora that fills the entire sky with
            golden splendor.  Steps lead up the cliff to a shelf
            of rock. ";
        }
    }
    
    ttravelerLeaving(traveler, dest) { dinghy.seen_before = true; }
    
    west = beachSteps
    
//    { Dinghy.seen_before := true;
//             return Beach_Shelf;
//    }
    up asExit(west)
    steps = beachSteps
    ledge = beachSteps
//    exithints = [ Beach_Shelf, &west ]
//    ana = Blue_Beach
;

+ dinghy: Fixture 'shattered dinghy; of[prep];boat remains'  
   "The remains consist of little more than a few broken boards,
        upon one of which may be seen a crude sketch of a skull and
        two crossed thighbones (perhaps this dinghy was once owned
        by a cook?) "
    
    game550 = true
    seen_before = nil  // The description appears only on the first visit.
    specialDesc()
    {
     
        if (!seen_before) 
        {
            "Lying upon the beach
            are the shattered remains of what must once
            have been a dinghy.  ";
            desc;
        }
        else
            "The shattered remains of a dinghy lie
            forlornly on the beach.";
    }
    
    dobjFor(Ride) { verify() {illogicalNow('The dinghy is too badly damaged to be seaworthy. '); } }
    dobjFor(Enter) asDobjFor(Ride) 
    dobjFor(Board) asDobjFor(Ride)     
;

+ Decoration 'narrow inlet; ocean of[prep]; water'
    "A narrow inlet of ocean water laps gently upon the beach. "    
;

+ Distant 'volcanic hills; rugged unclimbable; view;them'
    "The volcanic hills block all view to the north and south. "
;

SpecialVerb 'row|launch' @dinghy 'ride';

moons: MultiLoc, Distant 'moons;red blue small;moon light;them'
    "Yes -- three moons!  The largest one looks about half
    the size of the Earth's moon and has a red tinge; the other
    two are much smaller and look blue. It appears that you have passed 
    through a space portal without realizing it ..."
    
    locationList = [beachShelf, beach]
    
//    
//    loclist = [Beach_Shelf, Blue_Beach_Shelf, Beach, Blue_Beach,
//              Zarkalon_Tunnel_Entrance, Blue_Zarkalon_Tunnel_Entrance,
//              Zarkalon_Cliff_Top, Blue_Zarkalon_Cliff_Top,
//              Zarkalon_Tower_Top, Blue_Zarkalon_Tower_Top]
//    doCount(actor) = {
//        "What planet do you think you're on?  I've already told you that
//        there are three moons.  On second thoughts, that was a dumb
//        question.  ";
//        if(global.knowsgreenname)
//            "You know that the Green-level elves call this planet 
//            \"Ondralstir\" and the Blue-level humans call it \"Zarkalon\".
//            I guess we'll stay with the Blue-level name. ";
//        else if(BlueBoard1.isread)
//            "I guess we'll stay with the Blue-level name for this planet:
//            Zarkalon. ";
//        else
//            "I don't know the answer either... ";
//    }
;

