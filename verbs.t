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

DefineSystemAction(EnableMazeskip)
    execAction(c)
    {
        if(global.mazeskip)
        {
            "The mazeskip command is already enabled. ";
            return;
        }
        
        "Enabling the mazeskip command will cost you two points. Do you want to go ahead?\n
        >";
        if(yesOrNo())
        {
            global.mazeskip = true;
            addToScore(-2, 'using mazeskip');
        }
        "<.p>OK";
    }
;

VerbRule(EnableMazeskip)
    'enable' 'mazeskip'
    : VerbProduction
    action = EnableMazeskip
    verbPhrase = 'enable/enabling mazeskip command'
;

DefineSystemAction(NoviceMode)
    execAction(c)
    {
        if(gTurns > 0)
        {
            "This verb is only valid in the first turn of the game. ";
            abort;
        }
        if(global.novicemode)
        {
            "The game is already in novice mode. ";
            abort;
        }
        
        "By default, your lamp will
        last for <<(brassLantern.fuelLevel)>> turns, but in novice
        mode it will last for 1000 turns.  However, this will cost you 
        <<(-1 * global.novicepoints)>> points.\n
        Do you want a novice mode game? >";
        
        if (yesOrNo()) 
        {
            global.novicemode = true;
            addToScore(global.novicepoints, 'for using novice mode');
            brassLantern.fuelLevel = 1000;
            "\bOK -- the game is now in novice mode. "; 
        }
        else
            "\nVery well. ";
        abort;
        
    }
;

VerbRule(NoviceMode)
    'novice' (|'mode')
    :VerbProduction
    action = NoviceMode
    verbPhrase = 'activate/activating novide mode'
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

DefineTAction(HideBehind)
;
VerbRule(HideBehind)
    ('hide'|'go'|'get') 'behind' singleDobj
    : VerbProduction
    action = HideBehind
    verbPhrase = 'hide/hiding (behind what'
    missingQ = 'what do you want to hide behind'
    dobjReply = behindSingleNoun
;

DefineTAction(HideUnder)
;
VerbRule(HideUnder)
    ('hide'|'go'|'get') 'under' singleDobj
    : VerbProduction
    action = HideUnder
    verbPhrase = 'hide/hiding (behind what'
    missingQ = 'what do you want to hide behind'
    dobjReply = behindSingleNoun
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

DefineTVerb(Count, 'count' multiDobj, 'count', 'counting');

modify VerbRule(Fasten)
    ('fasten' | 'tie' | 'knot' | [badness 500] 'buckle' | 'buckle' 'up') multiDobj
    :
;

modify VerbRule(Unfasten)
    ('unfasten' | 'unbuckle' |'untie' | 'unknot' ) multiDobj
    : 
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
DefineTIVerbS(TakeWith, 'take' singleDobj 'with' singleIobj, 'take', 'taking', with);

class VaultKeyVerb: MagicWord
    wordnum = nil
    
    execAction(c)
    {
        if(gActor.isIn(vault) || gActor.isIn(peelgrunt)) 
            safeOpen();
        else 
            nothingHappens;
    }
    
    
    safeOpen()
    {
        if(inSafe.isOpen || inSafe.isFused) 
            nothingHappens;
        else 
        {    if(self.wordnum == inSafe.password) 
                inSafe.opens();            
            else 
                inSafe.melts();
        }
    }
    
    nothingHappens = "Nothing happens. "
    verb = nil
;

blerbiVerb: VaultKeyVerb
    omegapsical_order = 16
    omegaps580_order = 18
    omegaps701_order = 20
    omegaps701p_order = 22
    wordnum = 1
    
    verb = 'blerbi'
;
zortonVerb: VaultKeyVerb
    omegapsical_order = 1
    omegaps701_order = 1
    omegaps580_order = 1
    omegaps701p_order = 1
    wordnum = 2
    
    verb = 'zorton'
;
klaetuVerb: VaultKeyVerb
    omegapsical_order = 11
    omegaps580_order = 13
    omegaps701_order = 14
    omegaps701p_order = 15
    wordnum = 3
    
    verb = 'klaetu'
;
knerlVerb: VaultKeyVerb
    omegapsical_order = 10
    omegaps580_order = 12
    omegaps701_order = 13
    omegaps701p_order = 14
    wordnum = 4
    
    verb = 'knerl'
;

snoezeVerb: VaultKeyVerb
    omegapsical_order = 4
    omegaps580_order = 5
    omegaps701_order = 4
    omegaps701p_order = 4
    wordnum = 5
    
    verb = 'snoeze'
;


#define DefVKTVerbRule(name)\
    VerbRule(name)\
    #@name\
    :VerbProduction\
    action = name ## Verb

DefVKTVerbRule(blerbi);
DefVKTVerbRule(zorton);
DefVKTVerbRule(klaetu);
DefVKTVerbRule(knerl);
DefVKTVerbRule(snoeze);

nosideVerb: MagicWord
    omegapsical_order = 8
    omegaps580_order = 10
    omegaps701_order = 11
    omegaps701p_order = 12
    said = nil

    
    verb = 'noside'
    
    execAction(c)
    {   
        if (said || !global.game550)
            fail();
        else 
        {
            "Ok!";
            samohtVerb.tcount = gTurns + 1;
            said = true;
        }
    }

    fail() 
    {
        "Nothing happens.";
        reset();
    }

    reset()
    {
        samohtVerb.tcount = -1;
        said = nil;
    }
;

DefVKTVerbRule(noside);


samohtVerb: MagicWord
    omegapsical_order = 5
    omegaps580_order = 6
    omegaps701_order = 5
    omegaps701p_order = 5
    tcount = -1
   
    verb = 'samoht'
    
    execAction(c)
    {
        /* No way that nosideVerb.said could be true in 350-point
         * mode. */
        if (nosideVerb.said && (tcount == gTurns)) 
        {
            brassLantern.magicRecharge();
            nosideVerb.reset();
        }
        else nosideVerb.fail();
    }
;

DefVKTVerbRule(samoht);


// DJP - added a one-line version of noside samoht, because this is what
// the original 550-point game seems to want (whereas the 660-point game
// requires that the words be typed separately).
nosidesamohtVerb: MagicWord
    sdesc = "noside samoht"
    verb = 'noside-samoht'
    execAction(c) 
    {
        if (!global.game550) {
            nosideVerb.fail;
        }
        else {
            brassLantern.magicRecharge();
            nosideVerb.reset;
        }
    }
;

VerbRule(NosideSamoht)
    'noside' 'samoht'
    : VerbProduction
    action = nosidesamohtVerb
;

DefVKTVerbRule(thgirw);
DefVKTVerbRule(rubliw);

thgirwVerb: MagicWord
    omegaps580_order = 4
    said = nil

    sdesc = "thgirw"
    verb = 'thgirw'
    execAction(c)
    {
        if (said || !game580)
            fail();
        else 
        {
            "Ok!";
            rubliwVerb.tcount = gTurns + 1;
            said = true;
        }
    }

    fail 
    {
        "Nothing happens. ";
        reset();
    }

    reset
    {
        rubliwVerb.tcount = -1;
        said = nil;
    }
;


rubliwVerb: MagicWord
    omegaps580_order = 7
    tcount = -1
    sdesc = "rubliw"
    verb = 'rubliw'
    execAction(c) 
    {
        if (thgirwVerb.said && (self.tcount = gTurns)) 
        {
            activate_rug(actor);
            thgirwVerb.reset();
        }
        else thgirwVerb.fail();
    }
    activate_rug(actor) 
    {
        local topl;
        topl = gActor.getOutermostRoom;
        if ((topl is in (eOfRift,  wOfRift))
            && persianRug.isIn(topl)) 
        {
            if (persianRug.isActive) 
            {
                "The persian rug gently settles to the ground. ";
                persianRug.isActive = nil;
            }
            else if (persianRug.isIn(actor)) 
            "The rug ruffles in {my} hands
                for a moment, and then subsides. ";
            else
            {
                "The persian rug levitates itself off the ground! ";
                persianRug.isActive = true;
            }
        }
        else thgirwVerb.fail();
    }
;


// BJS - added a one-line version of rubliw thgirw, for consistency.
thgirwrubliwVerb: MagicWord
    sdesc = "thgirw rubliw"
    verb = 'thgirw-rubliw'
    execAction(c) 
    {
        if (!global.game580) 
            thgirwVerb.fail();        
        else 
        {
            rubliwVerb.activate_rug(gActor);
            thgirwVerb.reset;
        }
    }
;

VerbRule(ThgirwRubliw)
    'thgirw' 'rubliw'
    :VerbProduction
    action = thgirwrubliwVerb
;

melenkurionVerb: MagicWord
    omegapsical_order = 9
    omegaps580_order = 11
    omegaps701_order = 12
    omegaps701p_order = 13
    sdesc = "melenkurion"
    verb = 'melenkurion'
    execAction(c)
    {
        if(gActor.location != byFigure || rockWall.has_crumbled)            
            "Nothing happens. ";
        else 
        {
            rockWall.has_crumbled = true;
            "Rock silently crumbles off of the wall in
            front of you, revealing dark passages leading        
            northwest, north, and northeast.\n";
        }
    }
;

DefVKTVerbRule(melenkurion);

phugggVerb: MagicWord
    omegapsical_order = 7
    omegaps580_order = 9
    omegaps701_order = 9
    omegaps701p_order = 9
    
    execAction(c)
    {
    local toploc = gActor.getOutermostRoom;
        // Don't have djinn mention the word in the future.
        isused = true;
        if(!global.game550 || toploc.ofKind(Outside))
        {
            nothingHappens();
            return;
        }
            
        if(StreamItem.classfind(toploc) ||
            seaWater.isIn(toploc) ||
            waterInTheBottle.isIn(toploc) ||
            waterInTheFlask.isIn(toploc) ||
            waterInTheCask.isIn(toploc)) 
        { // Uh, oh!
            if(rand(100) < 86) 
                nothingHappens();
            else if(rand(100) < 96) 
            {
                P(); "<i>splurch!<i>"; P();
                "Oh, no!  You've turned yourself into
                a jellyfish, and fallen to the ground
                and been splattered far and wide!
                Well, that certainly wasn't very
                smart!!!  You were warned not to use
                that word near water!\n"; die();
            }
            else 
            {  "<.p>The ground begins to shudder ominously,
                and the very cave walls around you begin
                to creak and groan!  A sulphurious stench
                fills the air!"; P();

                "With an incredible lurch, the ground
                begins to dance and ripple as though
                it were liquid!  You are thrown off of
                your feet and tossed violently up and
                down!     The cave walls begin to crumble
                and split from the stress! "; P();

                "There is a terrible ROAR of rending
                rock!!     The cave ceiling splits, and
                rocks plunge down and smash your
                lower body to a gooey paste!!"; P();

                "There is a violent blast in the
                distance!  Steam and smoke drift
                into view through the rents in the
                walls, and furiously-bubbling red-hot
                lava flows in and surrounds you.
                The cave ceiling disintegrates in
                an incredible orgy of grinding
                destruction, and the cave walls fall
                and are pounded into fine dust."; P();

                "You are lying, badly mangled, on a
                small rock island in a sea of molten
                lava.    Above you, the sky is faintly
                visible through a thick pall of smoke
                and steam.  A short distance to the
                north, the remains of a well-house
                are sinking slowly into the bubbling
                ooze."; P();

                "There is a distant, sourceless screech
                of incredible anguish!     With a sharp
                <i>poof<i> and a small puff of orange smoke,
                a bent and bearded elf appears.  He
                is dressed in working clothes, and
                has a name-tag marked <q>Ralph</q> on
                his shirt.  <q>You blithering idiot!</q>
                he storms.  <q>You were warned quite
                clearly not to use that word near
                water!!  I hadn't gotten all of the
                bugs out of it yet, and now your
                incredible incompetence has totally
                destroyed Colossal Cave!!  Do you
                have the faintest scintilla of an
                iota of an understanding of how much
                work I'm going to have to do to get
                the cave rebuilt?!?  I'll have to go
                all the way to Peking for another
                dragon, and I'll have to convince the
                Goblin's Union to send me another team
                of gooseberry goblins; I'll have to
                sub-contract the building of the volcano
                out to the local totrugs, and worst
                of all I'll have to go through eight
                months of paperwork and red tape to
                file a new Environmental Impact
                statement!!  All because you couldn't
                follow directions, you purblind and
                meatbrained moron!  I'm rescinding all
                of your game points and throwing you
                out!  Out!   OUT!   GET OUT!$!%#&'@%!!%%!</q>";
                local penalty = -libScore.totalPoints;
                addToScore(penalty, 'destroying Colossal Cave');
                finishGameMsg(ftGameOver, [finishOptionUndo, finishOptionFullScore]);                
            }
        }
            else 
            {
                local shp; // Did anything happen?
                if (axe.isIn(gActor.location)) 
                { // delete axe.
                    "Your axe glows bright orange and fades into
                    nothingness.\n"; 
                    axe.moveInto(nil); 
                    shp = true;
                } // Note that as the code currently stands, the next
                // dwarf to encounter the player after this will throw
                // another axe!
                if (singingSword.isIn(gActor.location)) { // delete it.
                    "Your singing sword jumps into the air, chants several
                    bars of the <q>Volga Boatman</q>, shoots off several
                    fitful blue sparks, and disintegrates.\n";
                    singingSword.moveInto(nil); 
                    shp = true;
                }
                // Added the elfin sword for the 701-point game.
                if (sword.isIn(gActor.location)) 
                { // delete it.
                    "Your gleaming sword jumps into the air, then disintegrates
                    before your very eyes.   The fragments rust away to
                    nothing. ";
                    sword.moveInto(nil); //TADS 2 had singing_sword here - I assume that was an error
                    shp = true;
                }
                {  // Zap dwarves, if any.
                    local numd,i;
                    // Find number of dwarves present and store in numd.
                    numd = Dwarves.numberhere(actor);
                    
                    if(numd) 
                    { // Kill off the dwarf(s) and/or the player.
                        shp = true;
                        if(rand(10) < 8) 
                        { // it worked: kill dwarves.
                            switch(rand(3)) {
                                case 1: "A clear, liquid chime
                                    sounds in midair.";
                                if (numd > 1) "     A long green
                                    tentacle covered with
                                    sucker disks reaches out
                                    from nowhere, grabs the
                                    dwarves, and pulls them
                                    back to wherever it came
                                    from.";
                                else "    A large, four-clawed
                                    hand reaches out of the
                                    ground, grabs the dwarf,
                                    and pulls it down into
                                    nothingness.";
                                break;
                                case 2: "There is a sharp sizzling
                                    sound.";
                                if(numd == 1) "    The dwarf explodes
                                    into flame and vanishes.";
                                else "    The dwarves are engulfed
                                    in a wave of fire that
                                    appears from nowhere, and
                                    are completely incinerated;
                                    the flames then vanish into
                                    nothingness again.";
                                break;
                                case 3: "There is a sharp whistling
                                    sound from nowhere.";
                                if(numd > 1) "    The dwarves stiffen,
                                    shudder, and melt down into a
                                    large puddle of soggy goo that
                                    quickly soaks into the ground
                                    and vanishes.";
                                else "    The dwarf shudders and
                                    turns into a moth, which then
                                    flies away.";
                                break;
                            }
                            // Remove each of the dwarves.
                            for (i =0; i<numd; i++)
                                Dwarves.loclist -= Dwarves.location;
                            "\n";
                        }
                        else 
                        { // It failed: kill player.
                            switch(rand(3)) {
                                case 1: "A clear, liquid chime
                                    sounds in midair.";
                                if (numd > 1) "     A large and
                                    very toothy mouth appears
                                    in midair and chomps
                                    ferociously.  The dwarves
                                    manage to evade it, but
                                    it bites you in half.";
                                else "    A large, four-clawed
                                    foot appears in midair
                                    and stomps violently
                                    downward, missing the
                                    dwarf but thoroughly
                                    squashing you.";
                                break;
                                case 2: "There is a sharp sizzling
                                    sound.";
                                if(numd == 1) "    A ball of fire
                                    roars out of nowhere, misses
                                    the dwarf, bounces off of a
                                    wall, and incinerates you.";
                                else "    A ball of fire appears
                                    from nowhere, bounces off
                                    the ground, and explodes
                                    violently, incinerating
                                    both you and the dwarves.";
                                break;
                                case 3: "There is a sharp crackling
                                    sound from the air above you.";
                                if(numd > 1) "    The dwarves stiffen,
                                    fall to the ground, and melt
                                    into a large puddle of soggy
                                    goo.  The goo twitches a few
                                    times and then flows at you
                                    with incredible speed;  it
                                    attacks and strangles you
                                    with little difficulty.";
                                else "    The dwarf shudders and
                                    turns into a sabre-toothed
                                    tiger, which attacks and kills
                                    you in short order.";
                                break;
                            }
                            "\n";
                            // Remove each of the dwarves.
                            for (i = 0; i<numd; i++)
                                Dwarves.loclist -= Dwarves.location;
                            
                            die();
                        }
                    }
                    if (!shp) nothingHappens;
                }
            }
        }
    
    isused = nil
    nothingHappens() { gActor.getOutermostRoom.nothingHappens; }
;

DefVKTVerbRule(phuggg);

/* 
 *   Allow the player to fly the rug in a specified direction when the conditions are right for
 *   doing so.
 */
VerbRule(FlyDir)
    'fly' (| (|'persian') 'rug') singleDir
    :VerbProduction
    action = Travel
    verbPhrase = 'fly/flying (where)'
    isActive = (global.game580 && persianRug.isActive && gPlayerChar.isIn(persianRug))    
;


/* For completeness, provide graceful handling of FLY OBJ <DIR> under other circumstances. */
VerbRule(NonFlyDir)
    'fly' singleDobj singleDir
    :VerbProduction
    action = NoFly
    verbPhrase = 'fly/flying (what) (where)'
    isActive = (!(global.game580 && persianRug.isActive && gPlayerChar.isIn(persianRug)))    
;
    
DefineTAction(NoFly)
    execAction(c)
    {
        if(c.dobj == persianRug)
        {
            if(global.game580)
                "The rug can't be flown right now. ";
            else
                "Only wizards can do that. ";
        }
        else
            "How do you propose to do that? ";
    }
;

class MagicTravelAction: MagicWord, SpecialTravelAction
    execAction(c)
    {
//        local newtoploc;   
        
        // prevent the possibility of a Transindection movement straight
        // after a security alert
        if (global.triggered_alert) 
        {
             alert_message(gActor);
             return;
        }
        
        // The Wumpus is wearing his ring (but there aren't any
        // magic words which would transport him while sleeping)
        if (gActor.canSee(wumpus) && wumpus.isAsleep) 
        {
            if (self == Click)
                "You see the Wumpus click his heels in his sleep.\n";
            else
                "You hear the Wumpus repeat the magic word in his sleep.\n";
        }
        
        // modified to remove all the agonizing if the player has been through
        // it before, then sat on the throne without a crown.

        if(!global.game701) goto no_wumpi; // Skip if there are no Wumpi to check
//        local toploc = gActor.getOutermostRoom;
              
//        local Wumpimove;
//        if ((Wumpi.isVisible(actor) || Wumpi_remnant.isVisible(actor)) and 
//        (Wumpi.phase < 4)) 
//        {
//            Wumpimove = true;
//            if(gold_ring.seenspecial and not self.hesitated
//            and not Green_Tight_Crack_2.isseen) {
//                "You hesitate.  When you spied on an elf with the crystal
//                ball, his teleportation spell took the sapphire with him.
//                You feel sure that this has something to do with the gold
//                ring which you found on the Wumpus.  These Wumpi are also
//                wearing gold rings, so you ask yourself what will happen
//                if you teleport yourself from here ... ";
//
//                "But then you question whether the Wumpi would be silly enough
//                to wear rings which could transport them while sleeping.  In
//                any case, you'll need to use magic to get out of here without
//                waking the Wumpi, so ";
//                if (self = clickVerb)
//                    "you go ahead ... ";
//                else
//                    "you say the word ... ";
//                P();
//                self.hesitated := true;
//            }
//            else if(gold_ring.deducedmagic and not self.hesitated
//            and not Green_Tight_Crack_2.isseen) {
//                "You hesitate, remembering how the Wumpus managed to follow
//                you when you tried to escape using the slippers.  You
//                suspected that this had something to do with his ring.  These
//                Wumpi 
//                are also wearing gold rings, which look remarkably similar
//                to the one you took from the Wumpus ... ";
//                P();
//                "But then you question whether the Wumpi would be silly enough
//                to wear rings which would transport them while sleeping.
//                In any case, you'll need to use magic to
//                get out of here without waking the Wumpi, so ";
//
//                if (self = clickVerb)
//                    "you go ahead ... ";
//                else
//                    "you say the word ... ";
//                P();
//                self.hesitated := true;
//            }
//
//            if(toploc = Green_Large_Circular_Room) {
//                if(not (pendant2.obtained or (self = kataVerb))) {
//                    local proportion := 'most';
//                    if(Wumpi_remnant.isVisible(actor)) 
//                        proportion := 'about half';
//                    if(self = clickVerb)
//                        "You see <<proportion>> of the Wumpi click their heels
//                        in their sleep. \n";
//                    else
//                        "You hear <<proportion>> of the Wumpi repeat the magic
//                        word in their sleep. \n";
//                }
//            }
//            else {
//                if(self == clickVerb)
//                    "All of the Wumpi click their heels in their sleep.\n";
//                else
//                    "All of the Wumpi repeat the magic word in their sleep.\n";
//            }
//        }
        
        no_wumpi: ; // Skip to here if Wumpi doen't exist.
        
        gActor.nextRoute = 10; // indicating that it was magic
//        travelsave = global.travelActor;
//        currentsave = gActor;
        inherited(c);
        gActor.nextRoute = 0; // return to default in case the travel method
        
        

        travelActor = gActor;  // actor doing the travelling
//        global.currentActor := actor; // reference actor for location method
                                      // evaluation
        

//        global.travelActor = travelsave;
//        global.currentActor := currentsave;

        gActor.nextRoute = 0; // return to default in case the travel method
                              // changed it.

//        newtoploc = gActor.getOutermostRoom;
    }
    
    alert_message(actor)
    {
        "Nothing happens. ";
    }
    
    /* Presumably we don't need light to use a magic word. */
    darkTravelAllowed = true
;

#define DefMTA(action, prop) action : MagicTravelAction travelProp = prop allowDarkTravel = true
#define DefMTAVR(name, voc) VerbRule(name) voc :VerbProduction action = name 
#define DefMagicTravel(action, prop, voc) \
    DefMTAVR(action, voc);\
    DefMTA(action, prop)

/* Define all the magic travel actions */
DefMagicTravel(Xyzzy, &xyzzy, 'xyzzy')
    omegapsical_order = 2
    omegaps580_order = 2
    omegaps701_order = 2
    omegaps701p_order = 2
    verb = 'xyzzy'    
;

DefMagicTravel(Plugh, &plugh, 'plugh')
    omegapsical_order = 6
    omegaps580_order = 8
    omegaps701_order = 8
    omegaps701p_order = 8
    verb = 'plugh'
;

DefMagicTravel(Plover, &plover, 'plover')
    omegapsical_order = -7
    omegaps580_order = -9
    omegaps701_order = -9
    omegaps701p_order = -9
    verb = 'plover'
;

DefMagicTravel(Phuce, &phuce, 'phuce')
    verb = 'phuce'
    omegaps701_order = 10
    omegaps701p_order = 10
    execAction(c)
    {
        if (!global.newGame)
            "Nothing happens. ";
        else if (!knoll.seenit) {
            "Nothing happens.  If that's an attempt at Elvish magic, 
            it won't work at all until you've heard how to pronounce the word
            correctly. ";
        }
        else
            inherited(c);
    }

;

DefMagicTravel(Smichel, &smichel, 'smichel'|'saint-michel')
    verb = 'saint-michel'
    omegaps701_order = 6
    omegaps701p_order = 6
    execAction(c)
    {
        if (!global.newGame) 
            "Nothing happens. ";        
        else if (!riseOverBay.seenit) 
            "Nothing happens.  If that's an attempt at Elvish magic, 
            it won't work at all until you've heard the correct intonation
            for the words. ";        
        else 
            inherited(c);
    }
;


DefMagicTravel(Thurb, &thurb, 'thurb')
    omegapsical_order = 3
    omegaps580_order = 3
    omegaps701_order = 3
    omegaps701p_order = 3
    verb = 'thurb'
;

DefMagicTravel(Click, &click, 'click' (|('my'|'your'|)('heels'|'slippers')))
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


DefMagicTravel(Pray, &pray, 'pray')
    omegaps701_order = 7
    omegaps701p_order = 7
    verb = 'pray'
;

DefMagicTravel(Phleece, &phleece, 'phleece')
    verb = 'phleece'
    // we give this verb an 'omegapsical' order only in the 701+ point
    // version.
    omegaps701p_order = -12 //optional after 11
    execAction(c)
    {
        if(!outerCourtyard.seenit) 
            "Nothing happens.  If that's an attempt at Elvish magic, 
            it won't work at all until you've heard how to pronounce the word
            correctly. ";
        
        /* This will allow this code to compile before we've added this game701p object */
        else if(defined(copperBracelet) && copperBracelet.wornBy == gActor)
                inherited();           
        
        else if(gActor.isIn(outerCourtyard))
        {
            "Nothing happens.  It looks to me as if this word works
            only if you're wearing a special bracelet!
            I don't believe for a moment that the elves would
            be careless enough to leave one lying around";
            if(goldRing.seenspecial) 
            {
                ", or to let you follow them using the gold ring you found
                on the Wumpus - they're wise to that trick. ";
            }
            else ". ";
            "You'd be well advised to concentrate on exploring the 
            garden. ";
        }
        else 
            "Nothing happens. ";        
    }

;


/* Define all the other special travel actions */
DefSpecialTravel(Road, &road, 'road' | 'hill');    
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
DefSpecialTravel(SurfaceAction, &surface, 'surface');
DefSpecialTravel(LowAction, &low, 'low');
DefSpecialTravel(CanyonAction, &canyon, 'canyon');
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
DefSpecialTravel(Awkward, &awkward, 'awkward');
DefSpecialTravel(Barren, &barren, 'barren');
DefSpecialTravel(WallAction, &wall, 'wall');
DefSpecialTravel(Broken, &broken, 'broken');
DefSpecialTravel(FloorAction, &floor, 'floor');
DefSpecialTravel(Slit, &slit, 'slit');


DefSpecialTravel(Slab, &slab, 'slab' | 'slabroom');
DefSpecialTravel(Bedquilt, &bedquilt, 'bedquilt');

DefSpecialTravel(Oriental, &oriental, 'oriental');
DefSpecialTravel(Cavern, &cavern, 'cavern');
DefSpecialTravel(Shell, &shell, 'shell');
DefSpecialTravel(Reservoir, &toReservoir, 'reservoir');
DefSpecialTravel(Fork, &fork, 'fork');
DefSpecialTravel(Crack, &crack, 'crack');
DefSpecialTravel(Dome, &dome, 'dome');
DefSpecialTravel(Steps, &steps, 'steps');
DefSpecialTravel(Secret, &secret, 'secret');
DefSpecialTravel(Dark, &dark, 'dark');
DefSpecialTravel(Slide, &slide, 'slide');
DefSpecialTravel(Chimney, &chimney, 'chimney');
DefSpecialTravel(View, &view, 'view');
DefSpecialTravel(Y2Action, &y2,'y2');

DefSpecialTravel(Thunder, &thunder, 'thunder');

DefSpecialTravel(GateAction, &gate, 'gate');

DefSpecialTravel(Knoll, &toKnoll, 'knoll');
DefSpecialTravel(Ledge, &ledge, 'ledge');
DefSpecialTravel(Ice, &ice, 'ice');
DefSpecialTravel(Grotto, &grotto, 'grotto');
DefSpecialTravel(Gorge, &gorge, 'gorge');
DefSpecialTravel(Lair, &lair, 'lair');
DefSpecialTravel(FourierAction, &fourier, 'fourier');
DefSpecialTravel(JonahAction, &jonah, 'jonah');
DefSpecialTravel(Bridge, &bridge, 'bridge');
DefSpecialTravel(Altar, &altar, 'altar');
DefSpecialTravel(Balcony, &balcony, 'balcony');
DefSpecialTravel(Corridor, &corridor, 'corridor');
DefSpecialTravel(Pentagram, &pentagram, 'pentagram');
DefSpecialTravel(Nondescript, &toNondescript, 'nondescript');
DefSpecialTravel(Tube, &tube, 'tube');
DefSpecialTravel(Peelgrunt, &toPeelgrunt, 'peelgrunt');
DefSpecialTravel(SafeVerb, &toSafe, 'safe');
DefSpecialTravel(Golden, &toGolden, 'golden');
DefSpecialTravel(Arabasque, &toArabesque, 'arabesque');
DefSpecialTravel(Translucent, &toTranslucent, 'translucent');

    


DefSpecialTravel(MainOffice, &mainOffice, 'main' | 'office' | 'main' 'office');

DefSpecialTravel(Warm, &warm, 'warm') ;
DefSpecialTravel(MazeSkip, &mazeskip, 'mazeskip' | 'skipmaze'| 'skip' 'maze')
    execAction(c)
{
    if(global.mazeskip)
        inherited(c);
    else
        "You haven't enabled that command. ";
}
;

                 

// THESE WILL NEED FURTHER WORK
DefSpecialTravel(AnaVerb, &ana, 'ana');
DefSpecialTravel(KataVerb, &kata, 'kata');

osalVerb: MagicWord //not really
   execAction(c)
    {
        "Nothing happens, and you have the distinct feeling that you're
        missing something here ... ";
    }
;    
DefVKTVerbRule(osal);

phrosalVerb: MagicWord
    execAction(c)
    {
        if(!game701p || gActor.getOutermostRoom == machineChamber)
        {
            "Nothing happens. ";
            return;
        }
        /* To be added when we come to adding the 701p game. */
        "Something should happen but it's not implemented yet. ";
    }
;


modify VerbRule(MoveWith)
    ('move' | 'pull') singleDobj 'with' singleIobj
    :
;

DefineIVerb(stayVerb, 'stay', 'stay', 'staying')
    execAction(c)
    {
        if(gActor == gPlayerChar)
             "This command should be issued to someone else, e.g. \"dog, stay\".";
        else
            gActor.stay();
    }
;



    

