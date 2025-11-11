#charset "us-ascii"

#include <tads.h>
#include "advlite.h"

#define DefineMagicWord(name) \
    DefineAction(name, MagicWord)

/* 
 *   Note that magic words which don't exist in a given version are currently programmed to say
 *   "Nothing happens," as opposed to, say, "I don't know that word."
 */
class MagicWord: IAction
    endsaid = nil  // These properties are used in the cylindrical room.
    tused = -2
    omegapsical_order = nil    // To future extenders: leave these nil if
    omegaps701_order = nil     // you aren't altering the version in question.
    omegaps580_order = nil     // The unlabeled omegapsical_order
                               // refers to the 550-point version.
;


DefineSystemAction(NoDwarves)
    execAction(c)
    {
        "The dwarves haven't been implemented yet.\b
        Once they have been, switching them off will cost you five points. ";
        
        global.nodwarves = true;
    }
;

VerbRule(NoDwarves)
    'nodwarves' | 'no' ('dwarves' |'dwarf') | 'dwarves' 'off' | 'nodwarf'
    : VerbProduction
    action = NoDwarves
;

DefineSystemAction(Deterministic)
    execAction(c)
    {
        if(global.randomized)
            "You're too late. Once I've randomized, I can't go back to deterministic random numbers.
            ";
        else
        {
            global.nondeterministic = nil;
            "You are now playing a deterministic game. ";
        }
    }
;

VerbRule(Deterministic)
    'deterministic' | 'norandom' | 'norandomize'
    : VerbProduction
    action = Deterministic
;

DefineSystemAction(Health)
    execAction(c)
    {
        local i;       
        "{My} health rating is <<gActor.health>>, out of 100. So ";
       
        if(gActor.health >= 95) {
            if (rand(100) <= 50) i = 2;
            else i = 1;
        }
        else i = 3 + (100 - actor.health) / 20;
        say(self.healthmess[i]);
    }
    
    healthmess = [
        '{i} {am} in perfect health.',
        '{i} {am} as fit as a fiddle.',
        '{i} {am} a bit off top form, but nothing to worry about.',
        '{i} {am} weaker than usual.  Better avoid fights.',
        '{i} really ought to take a break. {I}{\'m} in tough shape.',
        '{i} {am} on the edge of collapse. Lots of sun and fresh air will speed {my} recovery.',
        '{my} strength is nearly gone. Only a miracle can save you now.'
    ]
;

VerbRule(Health)
    'health' | 'diagnose'
    : VerbProduction
    action = Health
    vernPhrase = 'diagnose/diagnosing health'
;

class VersionRestartAction: SystemAction
    points = 350
    vNumber = 0
    execAction(c)
    {
        restartGameVersion();
    }
    
    restartGameVersion()
    {
        local yesno;
//        local silent = nil;
        if(gTurns > 5)
        {
            if(vNumber == 11)
            {
                "Are you sure you want to restart the game (in the
                701+ points mode)? (YES or NO) > ";
            }
            else
                "Are you sure you want to restart the game (in the
                <<points>>-point mode)? (YES or NO) > ";
            
            yesno = yesOrNo();
        }
        
        
        
        else 
        {
            if(vnumber == 11) 
                "Restarting the game in the 701+ points mode (with bonus
                points for finding extensions).\n ";
            
            else 
                "Restarting the game in the <<points>>-point mode.\b\b ";
            
            yesno = true;
//            silent = true;
        }
        if (yesno) 
        {
            "\n";
//            scoreStatus(0, 0);
            // DJP - pass game version information.
//            global.initRestartParam = [vnumber, global.randomized, silent];
            
//            restart(initRestart, global.initRestartParam);
            global.vNumber = vnumber;
            
            /* Note our new version number */
            versionNum.vNumber = vnumber;
            
            /* restart the game. */
            Restart.doRestartGame();            
        }
        else if ( !yesno) 
        {
            "\nOkay.\n";           
        }         
    }  
    
;

/* Store the version number we want to use on restarting. */
transient versionNum: object
    vNumber = 0
;

#define DefVersionRestart(name, gram, pts, vnum)\
    VerbRule(name)\
    gram\
    : VerbProduction\
    action = name\
    verbPhrase = 'restart/restarting in version' + #@vnum\
    ;\
    name: VersionRestartAction \
    baseActionClass = name\
    points = pts\
    vnumber = vnum


DefVersionRestart(Restart350, 'oldgame' | 'game350', 350,  0);
DefVersionRestart(Restart551, 'game551', 551, 1);
DefVersionRestart(Restart550, 'game550', 550, 2);
DefVersionRestart(Restart701, 'game701', 701, 15);
DefVersionRestart(Restart701p, 'game701p', 701, 11);
DefVersionRestart(Restart580, 'game580', 580, 7);



DefineTAction(Cross)
;

VerbRule(Cross)
    ('cross' | (('walk' | 'go') 'across')) singleDobj
   
    : VerbProduction
    action = Cross
    verbPhrase = 'cross/crossing (what)'
    missingQ = 'what do you want to cross'
    
;

DefineTAction(Wave)
;

VerbRule(Wave)
    'wave' singleDobj
    : VerbProduction
    action = Wave
    verbPhrase = 'wave/waving (what)'
    missingQ = 'what do you want to wave'    
;

VerbRule(WaveVague)
    'wave' 
    : VerbProduction
    action = WaveVague
    verbPhrase = 'wave/waving (what)'
    missingQ = 'what do you want to wave'        
;

DefineIAction(WaveVague)
    execAction(c)
    {
        askForDobj(Wave);
    }
;
    
DefineTIAction(OpenWith)
;

VerbRule(OpenWith)
    'open' singleDobj 'with' singleIobj
    : VerbProduction
    verbPhrase = 'open/opening (what} {with what}'
    missingQ = 'what do you want to open; what do you want to open it with' 
    action = OpenWith
;

DefineTAction(Replace)
;

VerbRule(Replace)
    'replace' singleDobj
    : VerbProduction
    action = Replace
    verbPhrase = 'replace/replacing (what)'
    missingQ = 'what do you want to replace'    
;

DefineTAction(Change)
;

VerbRule(Change)
    'change' singleDobj
    : VerbProduction
    action = Change
    verbPhrase = 'change/changing (what)'
    missingQ = 'what do you want to change'    
;

DefineIAction(Swim)
    execAction(c)
    {
        "{I} {don't know} how. ";
    }
;

VerbRule(Swim)
    'swim'
    :VerbProduction
    action = Swim
    verbPhrase = 'swim/swimming'
;

VerbRule(SwimIn)
    'swim' ('in' | 'across' | 'over') singleDobj
    :VerbProduction
    action = Swim
    verbPhrase = 'swim/swimming (in what)'
;

DefineTAction(PoleDir)
    
    execAction(cmd)
    {
        /* Get the direction of travel from the command */
        direction = cmd.verbProd.dirMatch.dir;
        
        inherited(cmd);
    }
    direction = nil
;

DefineTAction(RideDir)
    
    execAction(cmd)
    {
        /* Get the direction of travel from the command */
        direction = cmd.verbProd.dirMatch.dir;
        
        inherited(cmd);
    }
    direction = nil
;

VerbRule(PoleDir)
    ('pole' | 'punt') singleDobj (|'to'|'to' 'the') singleDir
    : VerbProduction
    action = PoleDir
    verbPhrase = 'pole/poling (what)'
    missinqQ = 'what do you want to pole; which way do you want to pole it'
;

VerbRule(RideDir)
    'ride' singleDobj singleDir
    : VerbProduction
    action = RideDir
    verbPhrase = 'ride/riding (what)'
    missinqQ = 'what do you want to ride; which way do you want to ride it'
;


DefineMagicWord(Fee)
    omegapsical_order = 15
    omegaps580_order = 17
    omegaps701_order = 18
    omegaps701p_order = 20
    
    execAction(c)
    {
        if(said)
            fail();
        else 
        {
            "Ok!";
            Fie.tcount = gTurns + 1;
            Foe.tcount = gTurns + 2;
            Foo.tcount = gTurns + 3;
            said = true;
            Fie.said = nil;
            Foe.said = nil;
        }        
    }
    
    fail()
    {
        if (said) 
        {
            "What's the matter, can't you read?  Now
            you'd best start over. ";
        }
        else 
        {
            "Nothing happens.";
        }

        reset();
    }
    
    reset()
    {
        for (local vb in [Fee, Fie, Foe])
        {
            vb.tcount = -1;
            vb.said = nil;
        }              
    }
        
    said = nil
    tcount = -1
    
;

DefineMagicWord(Fie)
    omegapsical_order = 14
    omegaps580_order = 16
    omegaps701_order = 17
    omegaps701p_order = 19
    execAction(c)
{        
    if (tcount == gTurns) 
    {
        said = true;
        "Ok!";
    }
    else
        Fee.fail();       
}

said = nil
    tcount = -1
;


DefineMagicWord(Foe)
    omegapsical_order = 13
    omegaps580_order = 15
    omegaps701_order = 16
    omegaps701p_order = 18
    
    execAction(c)
    {
        if (!Fie.said)
            Fee.fail;
        else if (tcount == gTurns)
        {
            said = true;
            "Ok!";
        }
        else
            Fee.fail();
    }
    
    said = nil
    tcount = -1
;

DefineMagicWord(Foo)
    omegapsical_order = 12
    omegaps580_order = 14
    omegaps701_order = 15
    omegaps701p_order = 17
    
    execAction(c)
    {
        if (!Foe.said)
            Fee.fail();
        else if (tcount == gTurns) 
        {
            if (goldenEggs.isIn(inGiantRoom))
                "Nothing happens.";
            else 
            {
                if (goldenEggs.isIn(gActor.getOutermostRoom))
                    "The nest of golden eggs has vanished! ";
                else
                    "Done!";

                if (goldenEggs.isIn(trollTreasure)) 
                {
                    troll.isPaid = nil;
                    troll.isDuped = true;
                }
                goldenEggs.actionMoveInto(inGiantRoom);

                if (goldenEggs.isIn(gActor.getOutermostRoom)) 
                {                    
                    "<p>A large nest full of golden eggs suddenly appears out of nowhere!";
                }
            }

            Fee.reset();
        }
        else
            Fee.fail();
    }
    
    said = nil
    tcount = -1
;


DefineIAction(Fum)
    execAction(c)
    {
        Fee.fail();
    }
    
    
;

VerbRule(Fee)
    'fee'
    :VerbProduction
    action = Fee
;
         
VerbRule(Fie)
    'fie'
    :VerbProduction
    action = Fie
;

VerbRule(Foe)
    'foe'
    :VerbProduction
    action = Foe
;

VerbRule(Foo)
    'foo'
    :VerbProduction
    action = Foo
;

VerbRule(Fum)
    'fum'
    :VerbProduction
    action = Fum
;

DefineIAction(FooBar)
    execAction(c)
    {
        "Good try, but that is an old worn-out magic word. ";
    }
;

VerbRule(FooBar)
    'sesame' | 'open-sesame' | 'opensesame' | 'abracadabra' |
        'shazam' | 'shazzam' | 'hocus' 'pocus' |'hokus' 'pokus'
        'hocuspocus' |'hocus-pocus' |'hokuspokus' |'hokus-pokus' |
        'foobar' | 'open' 'sesame'
    : VerbProduction
    action = FooBar
;

DefineTAction(Rub)
;

VerbRule(Rub)
    'rub' singleDobj
    : VerbProduction
    action = Rub
    verbPhrase = 'rub/rubbing (what)'
    missingQ = 'what do you want to rub'
;

DefineTAction(Water)
;

DefineTAction(Oil)
;

VerbRule(Water)
    'water' singleDobj
    : VerbProduction
    action = Water
    verbPhrase = 'water/watering (what)'
    missingQ = 'what do you want to water'
;
              

VerbRule(Oil)
    'oil' singleDobj
    : VerbProduction
    action = Oil
    verbPhrase = 'oil/oiling (what)'
    missingQ = 'what do you want to oil'
;

modify VerbRule(Attack)
     ('attack' | 'kill' | 'hit' | 'punch') singleDobj
    :
;

DefineTAction(Kick)
;

VerbRule(Kick)
    'kick' singleDobj
    : VerbProduction
    action = Kick
    verbPhrase = 'kick/kicking (what)'
    missingQ = 'what do you want to kick'
;

DefineIAction(Sing)
    execAction(c)
    {
        singDesc;
    }
    
    singDesc = "You don't sound half bad. But don't quit your day job.";
;


VerbRule(Sing)
    'sing'
    :VerbProduction
    action = Sing
;

DefineTAction(Fill)
;

VerbRule(Fill)
    'fill' singleDobj
    : VerbProduction
    action = Fill
    verbPhrase = 'fill/filling (what)'
    missingQ = 'what do you want to fill'
;

DefineTAction(FillWith)
;

VerbRule(FillWith)
    'fill' singleDobj 'with' singleIobj
    : VerbProduction
    action = FillWith
    verbPhrase = 'fill/filling (what) (with what)'
    missingQ = 'what do you want to fill; what do you want to fill it with'
;

DefineTAction(Empty)
;

VerbRule(Empty)
    'empty' singleDobj
    : VerbProduction
    action = Empty
    verbPhrase = 'empty/emptying (what)'
    missingQ = 'what do you want to empty'
;

DefineTAction(Wake)
;

VerbRule(Wake)
    ('wake' | 'wake' 'up'| 'awaken' | 'rouse' | 'disturb' ) singleDobj
    : VerbProduction
    action = Wake
    verbPhrase = 'wake/waking (what)'
    missingQ = 'what do you want to wake'
;


DefineTAction(Feed)
;

VerbRule(Feed)
    ('feed' | 'fatten' | 'stuff') singleDobj
    : VerbProduction
    action = Feed
    verbPhrase = 'feed/feeding (what)'
    missingQ = 'what do you want to feed'
;

DefineTIAction(FeedWith)
;

VerbRule(FeedWith)
    ('feed' | 'fatten' | 'stuff') singleDobj 'with' singleIobj
    : VerbProduction
    action = FeedWith
    verbPhrase = 'feed/feeding (what) (with what)'
    missingQ = 'what do you want to fill; what do you want to feed it with'
;

VerbRule(FeedTo)
    'feed'  singleIobj 'to' singleDobj
    : VerbProduction
    action = FeedWith
    verbPhrase = 'feed/feeding (what) (with what)'
    missingQ = 'what do you want to fill; what do you want to feed it with'
;

VerbRule(Release)
    'release' multiDobj    
    : VerbProduction
    action = Drop
    verbPhrase = 'release/releasing (what)'
    missingQ = 'what do you want to release'
;

DefineLiteralTAction(DialOn)
;

VerbRule(DialOn)
    'dial' literalIobj 'on' singleDobj
    : VerbProduction
    action = DialOn
    verbPhrase = 'dial/dialling (what) (on what)'
    missingQ = 'what do you want to dial; what do you want to dial it on'
;

DefineTVerb(BlastWith, ('blast' | 'detonate') (|'with') singleDobj, 'blast', 'blasting');

DefineIVerb(Blast, 'blast'|'detonate'|'explode', 'blast', 'blasting')
    execAction(c) 
    {
        if(gActor.isIn(atNEEnd) || gActor.isIn(atSWEnd))
            endPuzzle();
        else
            "Blasting requires dynamite. ";
    }
;

RemapCmd 'fee fie foe (foo|fum)'
    execute = "Try saying each word individually. "
;

DefineTIVerb(YankFrom, 'yank' multiDobj ('from' | 'out' 'of') singleIobj, 'yank', 'yanking', from);
DefineTVerb(Yank, 'yank' multiDobj, 'yank', 'yanking');    

DefineTVerb(Use, ('use'|'utilize'|'employ') multiDobj, 'use', 'using');
DefineTVerb(Dust, ('brush' | 'sweep' | 'dust') multiDobj, 'dust', 'dusting');
DefineTIVerb(DustWith, ('brush' | 'sweep' | 'dust') multiDobj 'with' singleIobj, 'dust',
             'dusting',with );

/* blow, play (for lyre, horn) */
DefineTVerbS(Blow, 'blow' singleDobj, 'blow', 'blowing');
DefineTVerbS(Play, 'play' singleDobj, 'play', 'playing');
DefineTVerbS(Knock, 'knock' ('on'|) singleDobj, 'knock', 'knocking');



/* Define all the special travel actions */
DefSpecialTravel(Xyzzy, &xyzzy, 'xyzzy') darkTravelAllowed = true;
DefSpecialTravel(Plugh, &plugh, 'plugh') darkTravelAllowed  = true;
DefSpecialTravel(Road, &road, 'road');    
DefSpecialTravel(PantryVerb, &to_pantry, 'pantry');  
DefSpecialTravel(Building, &building, 'building' | 'house');    
DefSpecialTravel(Valley, &valley, 'valley');  
//DefSpecialTravel(ClimbVague, &climb, 'climb');   - now defined in library
DefSpecialTravel(CrossVague, &cross, 'cross');
DefSpecialTravel(Across, &across, 'across');

DefSpecialTravel(Upstream, &upstream, 'upstream');
DefSpecialTravel(Downstream, &downstream, 'downstream');
DefSpecialTravel(Forest, &forest, 'forest');
DefSpecialTravel(Stairs, &stairs, 'stairs');
DefSpecialTravel(Gully, &gully, 'gully');
DefSpecialTravel(Stream, &stream, 'stream');
DefSpecialTravel(Rock, &rock, 'rock');
DefSpecialTravel(BedAction, &bed, 'bed');
DefSpecialTravel(Crawl, &crawl, 'crawl');
DefSpecialTravel(Cobble, &cobble, 'cobble');
DefSpecialTravel(PassageAction, &passage, (|'follow') ('passage' | 'tunnel' | 'opening'));
DefSpecialTravel(Left, &left, 'left');
DefSpecialTravel(Right, &right, 'right');
DefSpecialTravel(Middle, &middle, 'middle');
DefSpecialTravel(Giant, &giant, 'giant');
DefSpecialTravel(Pit, &pit, 'pit');
DefSpecialTravel(Hall, &hall, 'hall');
DefSpecialTravel(Over, &over, 'over');
DefSpecialTravel(Debris, &debris, 'debris');
DefSpecialTravel(Hole, &hole, 'hole');
DefSpecialTravel(Depression, &depression, 'depression' | 'grate');
DefSpecialTravel(Entrance, &entrance, 'entrance');
DefSpecialTravel(CaveAction, &cave, 'cave');
DefSpecialTravel(Y2Action, &y2, 'y2' |'at' 'y2' |'at_y2');
DefSpecialTravel(Slab, &slab, 'slab');
DefSpecialTravel(Bedquilt, &bedquilt, 'bedquilt');
DefSpecialTravel(Plover, &plover, 'plover');
DefSpecialTravel(Oriental, &oriental, 'oriental');
DefSpecialTravel(Cavern, &cavern, 'cavern');
DefSpecialTravel(Shell, &shell, 'shell');
DefSpecialTravel(Reservoir, &toReservoir, 'reservoir');
DefSpecialTravel(Fork, &fork, 'fork');
DefSpecialTravel(Crack, &crack, 'crack');
DefSpecialTravel(Secret, &secret, 'secret');
DefSpecialTravel(Dark, &dark, 'dark');
DefSpecialTravel(Slide, &slide, 'slide');
DefSpecialTravel(Chimney, &chimney, 'chimney');
DefSpecialTravel(Phuce, &phuce, 'phuce') darkTravelAllowed = true;
DefSpecialTravel(Thunder, &thunder, 'thunder');
DefSpecialTravel(Smichel, &smichel, 'smichel'|'saint-michel');
DefSpecialTravel(GateAction, &gate, 'gate');
DefSpecialTravel(Phleece, &phleece, 'phleece');
DefSpecialTravel(Pray, &pray, 'pray');
DefSpecialTravel(Bridge, &bridge, 'bridge');
DefSpecialTravel(Altar, &altar, 'altar');
DefSpecialTravel(Balcony, &balcony, 'balcony');
DefSpecialTravel(Warm, &warm, 'warm');

DefSpecialTravel(Click, &click, 'click' (|('my'|'your'|)'heels'))
    execAction(cmd)
{
    if(slippers.wornBy != gActor)
    {  
        "{I} click{s/ed} {my} heels but nothing happens. ";                 
    }
    else
    {
        slippers.clicked = true;
        inherited(cmd);
    }
}    
noGoodHereMsg = "{I} click{s/ed} {my} heels and feel a slight tug, but nothing else happens. "
    omegaps701_order = 19
    omegaps701p_order = 21
;
                 

// THESE WILL NEED FURTHER WORK
DefSpecialTravel(AnaVerb, &ana, 'ana');
DefSpecialTravel(KataVerb, &kata, 'kata');






    

