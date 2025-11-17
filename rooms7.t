#charset "us-ascii"

#include <tads.h>
#include "advlite.h"

sOfCenter: NoNPC, Room 'South End of Computer Center'
    "You are standing at the southern end of a long hall in what 
    appears to be a computer center.  The entire hall is lit by four rows 
    of fluorescent lightbulbs.  There are numerous bulletin boards, all
    filled with various messages of one sort or another.  The rest of
    the wall space is filled by a large collection of computer generated
    posters, ranging in size from a two foot square picture of a cat
    to a twenty foot long 360 degree view of Mars taken from the Viking
    lander.  The computer center extends northward from here, and there
    is a small passage to the south.  There is an elevator at the far
    north end of the west wall. "
    
    game580 = true
    
    // DJP: Added a mention of the elevator at the N end (so its existence
    // doesn't come as a surprise if the maintenance man appears before the
    // player has seen the N end of the room)
     
    south = atWittsEnd
    passage = atWittsEnd
    north = nOfCenter
    hasfloor = true
;
    
+ Distant 'elevator;;lift'
    desc = elevator580.desc
    game580 = true
;


MultiLoc, Decoration 'bulletin boards;;board'
    "The bulletin boards are covered with various notices and
    memos, personal messages and system messages.  None of them 
    are particularly interesting. "
    
    game580 = true
    locationList = [sOfCenter, nOfCenter]
    readDesc = desc 
    decorationActions = [Examine, Read]
;

MultiLoc, Decoration 'fluorescent lightbulbs; light of[prep]; lights bulbs rows;them'
    "They're just ordinary fluorescent lightbulbs. "
    initialLocationList = [sOfCenter, nOfCenter]
;

nOfCenter: NoNPC, Room 'North End of Computer Center'
    "You are at the northern end of the computer center.  There are 
    more bulletin boards and posters covering the walls, and a large 
    sign on
    the wall reading, <q>RALPH WITT MEMORIAL COMPUTER CENTER.</q>  Below 
    that there is a considerably smaller sign saying, <q>security area - access
    by authorized personel only.</q>  To your left is an elevator, and next
    to it there is a green button, obviously used to call the elevator. "
    game580 = true
    
    south = sOfCenter    
    north = proxyComputerRoom
    in = elevator580
    west asExit(in)
    
    hasfloor = true
;

+ Fixture 'signs;large smaller small ;sign;them' 
    "A large sign on
    the wall reads <q>RALPH WITT MEMORIAL COMPUTER CENTER.</q>  A smaller
    sign below it reads <q>Security area -- access by authorized personel 
    only.</q> <<if elevator580.isLocked>> There is also an <q>OUT OF ORDER</q> 
    sign on the elevator door.<<end>> "
    
    readDesc = desc
;



+ box580: Fixture 'box; little north n; slot wall'
    "On the north wall there is a little box with a slot in it set 
             into the wall about four feet from the floor. "
    game580 = true
    hasCard = nil
    iobjFor(PutIn)
    {
        verify() 
        {
            if(gVerifyDobj != card)
                illogical('{That dobj} {doesn\'t fit} in the slot. ');            
        }
        
        action()
        {
            "You carefully insert the ID card into the slot in the box, which
             begins to emit a high pitched beeping sound for several seconds.
             All of a sudden, one section of the wall slides away, revealing
             another room to the north. ";
            hasCard = true;
            card.moveInto(nil);
        }
        
    }
    
    initSpecialDesc = "On the north wall there is a little box with a slot in it set 
             into the wall about four feet from the floor. "
    
    useInitSpecialDesc = (!hasCard)
    
    specialDesc = "A cool breeze blows from a room to the north. "    
;

+ Fixture, Button 'green button; lift elevator'
    "It is a green button, obviously used to call the elevator. "
    makePushed()
    {
        if(elevator580.isOpen || elevator580.isLocked)
            "Nothing happens. ";
        else
        {
            elevator580.isOpen = true;
            "OK. The elevator doors are now open. ";
        }
    }
;

+ proxyComputerRoom:ProxyRoom -> computerRoom
    isConnectorApparent = box580.hasCard
    isHidden = !box580.hasCard
;

+ elevator580: Passage 'elevator;;lift doors door' -> insideBuilding
    "The elevator doors are <<if isOpen>>open<<else>>shut<<end>>. <<if isLocked>>Taped to the 
    doors is an <q>OUT-OF-ORDER</q> sign. " 
        
    
    game580 = true
    isOpen = nil
    isLocked = (blob.isChasing || global.closed)
    
    canTravelerPass(actor) { return isOpen; }
    explainTravelBarrier(actor, connector)
    { 
        "The elevator doors are shut. ";  
    }
    
    noteTraversal(actor)
    {
        isOpen = nil;
        "The doors close behind you as you enter, and the elevator 
        immediately starts to go up quite rapidly.  After a while
        the acceleration lessens, but you continue going upwards
        for what seems like a very long time.  Finally the elevator
        starts to slow down (incidently doing nasty things to your
        stomach), and eventually grinds to a stop.<.p>"; 
        
        "Bright light floods into the elevator as the doors open. 
        Bedazzled by the bright light, you stumble out of the
        elevator as your eyes try to adjust.  After a second
        or two, you hear a small 'swoosh' behind you, and, as
        you turn around, you realize that not only have the
        elevator's doors closed, but they have vanished
        altogether! <.p>";
        
    }
    
    
    dobjFor(Ride) asDobjFor(TravelVia)    
    dobjFor(Board) asDobjFor(TravelVia)
;


computerRoom: NoNPC, Room 'Computer Room'
    "You are standing in an air conditioned room with a raised floor.
    Filling most of the room is a LARGE computer with LOTS of blinking
    lights.  There is a display screen mounted in one section of the
    computer.  There appears to be only one control or switch of any
    sort on the machine, that being a big red button marked
    <q>EMERGENCY STOP - Do not push!</q>"
    
    south = nOfCenter
    down = crFloorPanel
    west asExit(down)
    
    floorObj = crFloor
;

+ redButton: Fixture, Button 'big red button; stop'
    "It is a big red button marked <q>EMERGENCY STOP -- Do not push!</q>"
    readDesc = desc
    
    makePushed() 
    {
        "OK.\b"; 
        // EXEC(9, I); // Presumably quits the game.
        "The lights on the computer blink, then go dark.  Everything around
        you fades into a gray nothingness, and you also pass out of 
        existence ... ";
        addToScore(global.deathpoints,'for terminating your existence');
        die();
    }
;

+ Fixture 'large computer;;supercomputer mainframe' 
     "Filling most of the room is a LARGE computer with LOTS of
     blinking lights. "
    game580 = true 
    
    dobjFor(SwitchOff)
    {
        verify() {}
        action() { redButton.makePushed(); }
    }
    
    notSwitchableMsg = 'The computer is already on. '
    
    iobjFor(PutIn)
    {
        verify()
        {
            if(gVerifyDobj == disk)
                illogical('Strangely, I can\'t see a floppy disk reader anywhere. ');
            else
                illogical('I can\'t see any way to put anything into the computer. ');
        }
    }   
;

++ Component 'blinking lights;;;them'
    "Apart from suggesting that the computer is working, you can't figure out what the lights mean.
    "  
;

++ Component 'display screen;indecipherable of[prep];crt monitor numbers'
   "In the middle of the screen is the message <q>Adventure -- RUNNING</q>. 
   Everything else is just an indecipherable display of numbers. "
   game580 = true
   readDesc = desc
;
    
+ crFloorPanel: SecretDoor 'small panels;(floor) (floor\'s));panel;them'
    desc
    {
        if(crFloorPanel.isOpen) "Several of the floor's panels have been 
            removed.  There is a small air duct leading down beneath the
            floor.  It'll be a tight fit, but you should be able to just
            squeeze through. ";
        else "The floor is composed of several small panels, and is higher
            than the floor of the room to the south. ";
    }
    
    vocabWhenClosed = 'small panels;;panel;them'
    vocabWhenOpen = 'small air duct;;panel panels; it them'
    
//    otherSide = adPanels
    
    dobjFor(OpenWith)
    {
        verify()
        {
            if(isOpen)
                illogicalAlready('The floor panels are already open. ');
            if(gVerifyIobj != cups)
                illogical('{I} {don\'t know} how to open the panels with {the iobj}. ');
        }
    }
    
    dobjFor(Open)
    {
        verify()
        {
            if(isOpen)
                illogicalAlready('The floor panels are already open. ');
        }
        check()
        {
             "I am game; would you care to explain how? ";
        }
    }   
    
    isCloseable = true
    makeOpen(stat)
    {
        inherited(stat);
        if(!stat)
             "You replace the floor tiles, concealing the air duct from view. ";
            
    }
    
    dobjFor(Push) asDobjFor(Close)
    dobjFor(Replace) asDobjFor(Close)
    
    dobjFor(Close)
    {
        verify()
        {
            if(!isOpen)
            {
                local msg;
                switch(gVerbWord)
                {
                case 'push':
                    msg = 'The floor has already been pushed back. '; break;                    
                case 'replace':
                    msg = 'I don\'t know how to replace {the dobj}. '; break;
                default:
                    msg = 'The floor is already shut. '; break;
                    
                }
                
                illogicalAlready(msg);
            }
        }
    }
;

Doer 'move crFloorPanel with cups; take crFloorPanel with cups'
    exec(curCmd)
    {
        doInstead(OpenWith, gDobj, gIobj);
    }
;

actionOpenWith(crFloorPanel dobj, cups iobj)
{
    "With the aid of the suction cups, you manage to pull up
    some of the panels on the floor.  Below the floor there
    is a small air duct leading down and to the west.  It
    looks like a tight fit, but I think you'll make it. ";
    dobj.makeOpen(true);    
}

SpecialVerb 'squeeze through' @crFloorPanel 'enter'
    when = (crFloorPanel.isOpen)
;

crFloor: Floor 'floor;;ground'
    desc = crFloorPanel.desc
;

airDuct: NoNPC, Room 'Air Duct'
    "You are in an air duct running from east to west.  There is a
    brightly lit room at the eastern end of the air duct. "
    game580 = true
    
    east = adPanels
    up asExit(east)
    
    west = sTunnel
;

+ adPanels: Door 'brightly lit room;;floor panel panels'
    "You'd have to return to it to view it properly. "
    otherSide = crFloorPanel
    
    dobjFor(Close)
    {
        check()
        {
            "Better leave it as it is in case you want to get out that way. ";
        }
    }
    alreadyOpenMsg = 'The panels have already been lifted to make a way through. '
;

sTunnel: NoNPC, DarkRoom 'S-Shaped Tunnel'
        "You are in an S-shaped tunnel.  The tunnel starts at the northeast,
         where there is a rectangular opening in the wall, and continues to the
        southwest, from which a dull rumbling can be heard. "
 
        game580 = true
        east asExit(northeast)  
        northeast = airDuct 
        north asExit(northeast) 
    
        southwest = eOfRift
        west asExit(southwest)
        south asExit(southwest)
;

eOfRift: NoNPC, Room 'East Edge of Volcanic Rift' 
    "You are standing on the eastern edge of a HUGE volcanic rift.
    Almost a mile away on the other side, and maybe a hundred feet
    above you, is another passage.  Far to the north is an active
    volcano, the source of the lava flowing far below.  Carved into
    the wall, as if with a pen-knife, are the words <q>THGIRW RUBLIW</q>. " 
    game580 = true
    
    east: TravelConnector -> sTunnel
    {
         canTravelerPass(traveler)
        {
            return traveler.isOrIsIn(persianRug) && persianRug.isActive;
        }
         explainTravelBarrier(traveler, connector)
        {
            "The tunnel isn't suitable for flying up; you might want to
            get off the rug first. ";
        }  
        
        
        
    }
    
    down = 'Don\'t be ridiculous! '
    climb = down
    jump = down
    
    west: TravelConnector -> wOfRift
    {
        canTravelerPass(traveler)
        {
            return traveler.isOrIsIn(persianRug) && persianRug.isActive;
        }
        explainTravelBarrier(traveler, connector)
        {
            "I'm game.  Would you care to explain how? ";            
        }
        isConnectorListed = persianRug.isActive && persianRug.isIn(lexicalParent)
        travelDesc()
        {
            /* 
             *   Here the TADS 2 port indicates that there should be a test for inventory which it
             *   will implememnt later. For now we'll impose an arbitrary weight limit to serve as
             *   that test.
             */
            if(gActor.getCarriedWeight < 10) 
            { // if the player is not carrying too much.
                "You slowly rise up to the level of the ledge on the western side 
                of the rift.  The rug loops around once or twice, and then gently
                deposits you on the western side of the rift. ";
            }
            else 
            {
                "You climb onto the rug which gently starts to float across the 
                rift. The rug struggles to gain altitude (the ledge on the other 
                side is a bit higher), but is unable to because you are too 
                heavy.  The rug gently crumbles into the side of the rift, 
                twenty feet below the ledge it was aiming for.  Despite your 
                best efforts to hold on to a sheer cliff, you fall. ";
                persianRug.moveInto(nil); // remove the rug.
                die();
            }
        }
    }
;

rift: MultiLoc, Decoration 'volcanic rift; huge; chasm'
    "It is a huge volcanic rift with passages on the eastern and 
    western sides. Far to the north is an active volcano, the source 
    of the lava flowing far below. Carved into the western wall, as 
    if with a pen-knife, are the words \"THGIRW RUBLIW\". "
    iswavetarget = true // can wave rod at rift.
    
    game580 = true
    locationList = [ eOfRift, wOfRift ]
//    verDoJump(actor) = {}
//    doJump(actor) = {
//        global.travelActor := actor;
//        actor.travelTo(actor.location.jump);
//    }
;

MultiLoc, Distant 'active volcano;of[prep];lava stream'
    "A stream of lava flows from the volcano situated far to the north. "
    locationList = [ eOfRift, wOfRift ]
;

wOfRift: NoNPC, Room 'West Edge of Volcanic Rift'    
    "You are on the western edge of the volcanic rift.  A passage
         continues up and west from here. "
    
    east: TravelConnector -> eOfRift
    {
        canTravelerPass(traveler)
        {
            return traveler.isOrIsIn(persianRug) && persianRug.isActive;
        }
        explainTravelBarrier(traveler, connector)
        {
            "I'm game.  Would you care to explain how? ";            
        }
        isConnectorListed = persianRug.isActive && persianRug.isIn(lexicalParent)
    }
    
    west: TravelConnector -> panelledPassage
    {
        canTravelerPass(traveler)
        {
            return traveler.isOrIsIn(persianRug) && persianRug.isActive;
        }
         explainTravelBarrier(traveler, connector)
        {
            "The passage isn't suitable for flying up; you might want to
            get off the carpet first. ";
        }        
    }
    up asExit(west)
    down = 'Don\'t be ridiculous! '
    jump = down
    climb = down
        
;

panelledPassage: NoNPC, Room 'Panelled Passage'
    "You are in a long sloping passage.  The walls are covered with fine
    redwood paneling.  From the east comes a dim light and a dull rumbling
    noise. "
    game580 = true
    
    east = wOfRift
    down asExit(east)
    west = study
    up asExit(west)
;

+ Decoration 'panelling; fine redwood; panels walls'
    "The walls are covered with fine redwood panelling. "
    game580 = true
    vocabLikehood = 10
;

+ Decoration 'dim light'
    "It comes from the east. "
    notImportantMsg = 'The light is too insubstantial for that. '
;

study:  NoNPC, DarkRoom 'Study'
    "You are in an elaborately furnished study. "
    
    east = panelledPassage
    out asExit(east)
    down asExit(east)    
;

+ desk: Heavy, Surface 'desk; magnificent redwood'
    "There is a magnificent redwood desk in the center of the room. "
    game580 = true
    specialDesc = desc    
;
    
+ Heavy, Flashlight 'desk lamps'
    desc{
        if(isLit)
            "The room is lit by several desk lamps scattered about the room. ";
        else
            "There are several unlit desk lamps scattered about the room. ";
    }
    
    game580 = true
    sdesc = "desk lamps"
    
    isLit = true
    isOn = true
    specialDesc = desc
    visibleInDark = true // to allow lamps to be turned on in the dark
;


