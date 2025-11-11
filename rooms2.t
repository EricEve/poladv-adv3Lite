#charset "us-ascii"

#include <tads.h>
#include "advlite.h"

/* Additional rooms for 550-point version */

/*
 * A class for the ice tunnels. Since the NPCs can't use magic words in
 * this game, they will become trapped upon entering the maze. Hence,
 * I've made them NoNPC, although they weren't in the original. -BJS
 */
class IceTunnel: NoNPC 'Ice Tunnels'   
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
        isConectorApparent = (rockWall.has_crumbled)
    }    
   
    left = northwest
    
    northeast: TravelConnector -> windingPass
    {
        isConectorApparent = (rockWall.has_crumbled)
    }  
        
    right = northeast
    
    north: TravelConnector -> southBasilisk
    {
        isConectorApparent = (rockWall.has_crumbled)
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
    
    
    described { if(has_crumbled) "Dark tunnels lead northeast,north, and northwest."; }
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




windingPass: Room;
southBasilisk: Room;