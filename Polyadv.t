#charset "us-ascii"

#include <tads.h>
#include "advlite.h"

versionInfo: GameID
    IFID = 'ae41d2ae-c33a-4dec-afbe-f47547f82488'
    name = 'Polyadv'
    byline = 'by Eric Eve'
    htmlByline = 'by <a href="mailto:eric.eve@outlook.com">Eric Eve</a>'
    version = '0.1 (beta)'
    authorEmail = 'Eric Eve <eric.eve@outlook.com>'
    desc = 'A TADS3/adv3Lite port of the TADS 2 port of polyadv, itself a multi-version port based
        on the Colossal Adventure game by Crowther and Woods.'
    htmlDesc = 'A TADS3/adv3Lite port of the TADS 2 port of polyadv, itself a multi-version port
        based on the Colossal Adventure game by Crowther and Woods.'
    
    showAbout()    
    {
        aboutMenu.display();      
    }
    
    showCredit()
    {
        "The classic Adventure game on which this version is ultimate;ly based was by Don
        Woods and Willie Crowther. This TADS 3/adv3Lite version is based on the TADS 2 polyadv
        port by David M. Baggett, David J. Picton and Bennett J. Standeven. ";
        
        "ADVENTURE was originally developed by William Crowther, and later
        substantially rewritten and expanded by Don Woods at Stanford Univ.
        Crowther's original version was modelled on a real cavern, called
        Bedquilt Cave, which is a part of Kentucky's Mammoth Cave system.
        That version of the game included the main maze and a portion of the
        third-level (Complex Junction - Bedquilt -  Swiss Cheese rooms, etc.),
        but not much more.";

        P(); I();
        "Don Woods and some others at Stanford later rewrote portions of
        the original program, and greatly expanded the cave.  That version
        of the game is recognizable by the maximum score of 350 points.";

        P(); I();
        "Some major additions were done throughout 1978 by David Long while
        at the University of Chicago, Graduate School of Business.
        Long's additions include the seaside entrance and all of
        the cave on the \"far side\" of Lost River.
        The castle problem was added in late 1984 by an anonymous writer.
        This version has a total score of 551 points.";

        P(); I();
        "Thanks are owed to Roger Matus and David Feldman, both of U. of C.,
        for several suggestions, including the Rainbow Room, the telephone
        booth, and the fearsome Wumpus.  Further thanks go to J. R. Carlson
        for many debugging suggestions.  Most thanks (and apologies)
        go to Thomas Malory, Charles Dodgson, the Grimm Brothers, Dante,
        Homer, Frank Baum and especially Anon., the real authors of
        ADVENTURE.";

        P(); I();
        "Another extended version, with 550 points, was independently
        developed in late 1979 by David Platt of the Honeywell Los
        Angelos Development Center.  Platt also completely rewrote
        the database. In 1984 the program was ported to UNIX C by Ken
        Wellsch. The extensions are drawn from the database source code.";

        P(); I();
        "This version was further extended by Mike Goetz, in his CP/M port.
        Again, the extensions use the database source code. ";
        
        P(); I();
        "This port also includes a 701-point version which combines
        the 551-point game (except the endgame) with all of the extensions
        in the 550-point game. ";

        P(); I();
        "This version is Copyright (c) 1999 Bennett J.\ Standeven, 
        1999-2001 David
        J.\ Picton, and 1993 David M.\ Baggett, and is derived in part from
        David Baggett's port (Colossal Cave Revisited) of the original
        350-point game by Crowther/Woods. The 551-point extensions were
        added by David J. Picton, and the 550/580-point extensions by Bennett
        Standeven.  The 701-point and 701+ point versions were added by
        David Picton. ";

        P(); I();
        "Credit is also due to Sean Barrett's game \"Appallatron: 
        Annoytron III\" for the inspiration behind an new form 
        of travel in the 701+ point version.  Hopefully you'll find this
        version challenging, rather than annoying. ";

        P(); I();
        "The source code contains a modified version of Kevin Forchione's
        parseword package, Copyright (c) 1999, 2000. ";


        P(); I();
        "This program is free software; you can
        redistribute it and/or modify it under the terms of
        version 2 of the GNU General Public License as
        published by the Free Software Foundation.";

        P(); I();
        "This program is distributed in the hope that it
        will be useful, but WITHOUT ANY WARRANTY; without
        even the implied warranty of MERCHANTABILITY or
        FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
        General Public License for more details.";
    }
;

gameMain: GameMainDef 
    /* Define the initial player character; this is compulsory */
    initialPlayerChar = me
    
    showIntro()
    {
        if(global.specialstart)
            return;
        
        "Somewhere nearby is Colossal Cave, where others have found
        fortunes in treasure and gold, though it is rumored that some
        who enter are never seen again.  Magic is said to work in the
        cave.  I will be your eyes and hands.  Direct me by typing
        simple commands in natural English.   Commands of one or two
        words, like \"west\" or \"take ingot\", may still be used, but
        I now understand more complex sentences like 
        \"put the large keys in suitcase\" or \"attack giant with
        long sword\".For more information
        type <<aHref('about', 'ABOUT','show about menu')>>. \b";;
    }
    
    showGoodbye()
    {        
        "<.p>Come back and visit the newly remodelled and extended Colossal Cave soon! ";
    }

    
    /* This list will be updated from the appropriate VerGlob object. */
    scoreRanks = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    
    scoreRankTable = [        
        [scoreRanks[1], 'You are obviously a rank amateur.' ],
        [scoreRanks[2], 'Your score qualifies you as a Novice Class adventurer.' ],
        [scoreRanks[3], 'You have achieved the rating: <q>Experienced Adventurer</q>.' ],
        [scoreRanks[4], 'You may now consider yourself a <q>Seasoned Adventurer</q>.' ],
        [scoreRanks[5], 'You reached <q>Junior Master</q> status.' ],
        [scoreRanks[6], 'Your score puts you in Master Adventurer Class C.' ],
        [scoreRanks[7], 'Your score puts you in Master Adventurer Class B.' ],
        [scoreRanks[8], 'Your score puts you in Master Adventurer Class A.' ],
        [scoreRanks[9], 'All of Adventuredom gives tribute to you, Adventurer Grandmaster.' ]
    ]
;


/* 
 *   The player character object. This doesn't have to be called me, but me is a
 *   convenient name. If you change it to something else, rememember to change
 *   gameMain.initialPlayerChar accordingly.
 */


class BodyPart: Component
    cannotTakeMsg = '{1} already have {my} {dobj}. '
    
;

me: Player 'you' @atEndOfRoad 
    desc
    {
        if(mushroom.isEaten) 
            "Your muscles are bulging unbelievably. ";            
        if(global.newGame && health < 95) 
            doNested(Health);        
        else if (!mushroom.isEaten) 
            "{I} hope{s} {i} look{s/ed} the part of an intrepid adventurer. ";        
    }
       
    itemcount = contents.countWhich({x:!x.isFixed})
    
    kickNoEffectMsg = '{I} {give} {myself} a good kicking, which {i} no doubt richly deserve{s/ed}. '   
;

+ myHands: BodyPart '() your hands; bare my ;hand; them it'
     "Two of 'em.  Five fingers each. They look pretty normal to me! "    
    
    dobjFor(Wave)
    {
        preCond = []
        verify() { logicalRank(120); }
        action()
        {
            local loc = getOutermostRoom();
            if(loc.propDefined(&wavehands))
                loc.wavehands;
            else
                inherited();
        }
    }
    
    iobjFor(AttackWith) { verify() {} }
    
    iobjFor(PutIn)
    {       
        action()
        {
            doInstead(Take, gDobj);
        }
    }
    
    actionDobjCount = "Oddly enough, {i} {have} two of those. "
    
    mass = 0 // my hands shouldn't contribute to the weight I'm carrying!
;

+ myFeet: BodyPart '{} your feet; ;foot; them it'
    "Frankly, your feet are nothing to write home about. "
    actionDobjCount = "Let's see: you have one left foot and one right foot, so I 
        guess that makes two feet in all. "
;

/* Suppress the notification of our initial points at game start */
modify scoreNotifySettingsItem
    isOn = (gTurns > 1)
    
;

   
aboutMenu: MenuItem 'About'
    
;

+ MenuLongTopicItem 'About this implementation of PolyAdv'
    "This is a work-in-progress attempt to port the TADS 2 polyadv game to TADS 3/advLite.
        Polyadv is in turn an implementation of the classic Crowther and Woods Colossal Adventure
        game together with several extensions to it. This TADS 3 port aims to reproduce the content
        of the originals while incorporating several player-friendly features such as the exit
        lister, pathfinding via the GO TO command, and a more helpful hint system (especially where
        the original game's puzzles are poorly clued or downright obscure).\b
        So far the implementation of the original (350 point) game is nearing completion,
        and much of the 550, 551, and 580 point versions are in place, which means 
        that much of the 700 point version (which pretty much just combines the 550 and
        551 point versions) is also in place. Work has yet to start on the 701plus extensions
        and in all versions the various non-player characters (pirate, dwarves, Wumpus, etc.)
        are still a work-in-progress, along, no doubt, with some of the finer points of
        implementation in all versions.\b
        More information will be given here as the implementation progresses. ";
;
    
+ MenuLongTopicItem 'Instructions'
    menuContents()
    {        
        P(); I(); "Welcome to Polyadv - a TADS port of the Colossal Cave
        Adventure programs.  Type \"credits\" for information
        on authorship and copyright.";

        P(); I(); "Two commands are provided to give you an easier game.
        The \"novice\" command will make your lamp last longer before you
        have to change the batteries.  This will cost you 5 points.  The
        \"nodwarves\" command will get rid of the dwarves and pirate, and
        this will also cost you 5 points.  (The \"nodwarves\" command will
        also place a certain treasure where the pirate would normally
        hide it, but you won't be given any clues about where to find the
        treasure.)";

        P(); I(); "I know of places, actions, and things.  You can guide
        me using commands that are complete sentences. To move, try
        commands like \"forest,\" \"building,\" \"downstream,\"
        \"enter,\" \"east,\" \"west,\" \"north,\" \"south,\" \"up,\"
        \"down,\" \"enter building,\" \"climb pole,\" etc.  To go back
        to your previous location, you can usually type \"back\".";

        P(); I(); "I know about a few special objects, like a black rod
        hidden in the cave.  These objects can be manipulated using
        some of the action words that I know.  Usually you will need
        to give a verb followed by an object (along with descriptive
        adjectives when desired), but sometimes I can infer the
        object from the verb alone.  Some objects also imply verbs;
        in particular, \"inventory\" implies \"take inventory\",
        which causes me to give you a list of what you're carrying.
        Some objects have side effects; for instance, the rod scares
        the bird.  Note that some objects in the extended versions
        have desirable effects only when worn. ";

        P(); I(); "A word about magic.  In contrast to the Inform port,
        this game will allow you to use magic words which you've seen in
        previous games. ";  
        if(global.newGame) {
            "But elvish magic only works for humans if you use it in the
            right place - where elves have used the same magic before.  And
            elvish magic words can only be used if you've heard the correct
            pronunciation. ";
        }
        if(global.game550) {
            if(global.newGame)"Also, "; else "But take care: "; 
            "it can be dangerous to use certain words before
            you've seen them. ";
        }

        P(); I(); "Many commands have abbreviations.  For example, you can
        type \"i\" in place of \"inventory,\" \"x object\" instead of
        \"examine object,\" etc. ";

        P(); I();; "Usually people having trouble moving just need to try a
        few more words.  Usually people trying unsuccessfully to
        manipulate an object are attempting something beyond their
        (or my!) capabilities and should try a completely different
        tack.";

        P(); I();"To see if any hints are available at your current
        location, type \"hint\" and reply to any prompts.  I'll warn you
        in advance how it will affect your score to accept each hint.";

        P(); I(); "To speed the game you can sometimes walk a long distance
        with a single word.  For example, \"building\" usually gets
        you to the building from anywhere above ground except when
        lost in the forest.  Also, note that cave passages turn a lot,
        and that leaving a room to the north does not guarantee
        entering the next from the south.";

        P(); I(); "A word about my understanding of English.  I understand
        simple sentences in natural English, such as \"take bottle\" or
        \"kill the monster with the knife\".  I will always
        try very hard to do whatever you say, but you must bear in mind that
        computers don't quite have the understanding of language that humans
        do!  Here are a few suggestions.";

        P(); I(); "To grab everything movable at a given location, say
        \"take all\".
        Also, you can specify several objects by using commas or \"and\" and
        several commands separated by \".\" or \"then\", e.g.
        \"take abc,def and xyz then burn witch.  take ashes.\"";

        P(); I(); "It is sometimes useful to use adjectives to distinguish
        between objects, e.g. \"take black frammitz. drop green frammitz\".
        It is often necessary to use prepositions, particularly when
        using containers, e.g. \"put crown in knapsack\".";

        P(); I(); "Another form of command which is sometimes useful involves
        a request to a character, e.g. \"giant, west\".  For example, most
        creatures can be fed with a command of the form \"actor, eat food\",
        as an alternative to \"feed food to actor\" or \"feed actor with
        food\". ";

        P(); I(); "If you misspell a word, you can usually correct it using
        the \"oops\" command.  For example, if you typed \"put grey raincoat
        in green nkapsack\" you can correct the error with \"oops knapsack\"";

        P(); I(); "If you want to end your adventure early, type \"quit\".
        To suspend your adventure such that you can continue later,
        type \"save,\" and to resume a saved game, type \"restore.\"
        To see how well you're doing, type \"score\".  To display the
        credits for this version of Adventure, type \"credits\". ";

        if (global.game701p) {
            "Most treasures must be left safely in the building for full 
            credit, though you get partial credit just for taking them. ";
        }
        else {
            "To get full credit for a treasure, you must have left it safely in
            the building, though you get partial credit just for taking it.  ";
        }

        if (global.newgame) {
            "But beware: in this game version you will find that leaving 
            something in a *safe* place is trickier than you think!  ";
        }

        "Some non-treasure items are best left near where you find them. ";

        P(); I(); "You lose points for getting killed. There are points based
        on how much (if any) of the cave you've managed to explore; in
        particular, there is a bonus just for getting in (to
        distinguish the beginners from the rest of the pack), and
        there are other ways to determine whether you've been through
        some of the more harrowing sections.";

        if(global.newGame) {
            P(); I();
            "In addition to getting yourself killed, you can also be wounded or
            injured in various (non-lethal) ways.  If you get burnt, poisoned,
            electrocuted or whatever, you can check on your current state of
            health by typing \"health\" or \"diagnose\".  Note that 
            recuperation takes place faster outside in the fresh air!";
        }

        P(); I(); "When you've collected all the treasures, I'll let you know.
        Just keep exploring for a while.
        If something interesting happens, it means you're getting a
        bonus and have an opportunity to garner many more points in the 
        master's section.";

        P(); I(); "Finally, you may specify \"brief\",
        which tells me never to repeat the full description of a
        place unless you explicitly ask me to.  (The \"verbose\"
        command turns this off.)";

        P(); I(); "Good luck!";        
    }
;

+ MenuLongTopicItem 'Version Selection'
    menuContents()
    {
        "This TADS port provides several versions of the Colossal Cave
        adventure in one game file!  The alternatives are:\b";
        
        "* The original 350-point game by Crowther and Woods, ported
        by David Baggett.\b";
        
        "* The 550-point extended version by David Platt, ported by
        Bennett Standeven.\b";
        
        "* The 580-point extended version by Mike Goetz, ported by
        Bennett Standeven.\b";
        
        "* The 551-point version by David Long and an anonymous author,
        ported by David Picton.\b";
        
        "* A 701-point version by David Picton, combining the 550-point and  
        551-point versions.\b";
        
        "* A 701+ point version by David Picton, based on the 701-point
        version but with new extensions.  The maximum score is for you
        to discover!\b";
        
        "Type the \"game350\", \"game550\", \"game551\", \"game580\", or
        \"game701\" command to
        restart the game in the 350, 550, 551, 580 or 701-point mode.
        Type \"game701+\" to restart the game in the 701+ point mode
        (like the 701-point game, but with a new extension).\b";
    }
;

+ MenuLongTopicItem 'Special Commands'
    menuContents()
    {
        "For full information about
          uthorship and copyright, please type \"credits\".\b";

          "Type the \"game350\", \"game550\", \"game551\", \"game580\", or
          \"game701\" command to
            restart the game in the 350, 550, 551, 580 or 701-point mode.
            Type \"game701+\" to restart the game in the 701+ point mode
            (like the 701-point game, but with a new extension).\b";

            "Type \"novice\" in the first turn to make your lamp last
            longer.  Type \"nodwarves\" if you want to play without the
            dwarves or pirate.  Type \"noresurrect\" if you want
            to play without reincarnations.\b";
        
            "Type \"enable mazeskip\" to enable the \"mazeskip\" command
            to skip through various mazes without needing to map them
            in detail. This will cost you two points off your score.\b";
        
            "Type \"norandom\" in the first couple of turns to prevent
            reseeding of the random number generator, thereby ensuring
            that the same sequence of commands yields the same outcomes on each
            playthrough (i.e. each play through that starts with a
            \"norandom\" command).\b";

            "Type \"help\" or \"about\" for more detailed help information.\b";

            "Type \"hint\" to find out if a hint is available at your
            location.\b";
    }
    
;


+ MenuLongTopicItem 'Changes in this TADS 3 Port (compared with the TADS 2 version)'
    "This version of Polyadv was ported from the TADS 2 port to TADS 3/adv3Lite, which
    has several features not in TADS 2. These additional features have been deliberately
    retained to give players a slightly smoother playing experience, but you can
    opt of most of them if you wish.\b
    First, there is the exit lister, which shows a list of available exits from your
    current location in the status line, with unvisited exits shown in a different colour
    (by default, green). Most players are likely to find this helpful, but if you don't
    like it or you feel it would be more authentic to play without this aid, you can use
    the EXITS OFF command to disable this exit listing.\b
    Seoond, adv3Lite has built-in pathfinding, which allows you to go to a previously
    visited room or object using the command GO TO X, where X is the name of the room
    or object in question. Note, however, that due to the complex and sometimes
    random nature of the interconnections in Colossal Cave, this command may not
    always able to find the route you're looking for. If it does find it, it will 
    take you one step of the way per turn; after the first turn you can type CONTINUE
    or just C to continue on your way.\b
    Third, that the BACK command in this port makes use of the adv3Lite library's built-in
    pathfinder, which works differently from the custom implementation of a BACK command
    in the TADS 2 port.\b
    Fourth, if you hate mazes, you can use the ENABLE MAZESKIP command (which costs two
    point off your score) to enable the MAZESKIP command to whisk you through any maze
    you find yourself in. For more details see the section on <q>Navigating Mazes</q>.\b
    Fifth, unlike the TADS 2 version, this TADS 3 starts out in VERBOSE mode (which seems
    to be the modern preference), although the VERBOSE and BRIEF commands still exist
    in this version. In verbose mode, you'll see a full room description each time you
    visit a location. In brief mose you'll only get the full description the first time
    you see the location; thereafter you'll simply see the room's name (although you
    can still type LOOK to view the full description.\b
    Sixth, this version of the game makes us of the adv3Lite library's built-in spelling 
    corrector to attempt to correct any typos in your input, as well as the library's
    numbered disambiguation prompt, so that, for example, the game may respond to DROP ROD
    with <q>Which you mean: (1) the black rod or (2) the gray rod?</q> allowing you to 
    just type 1 or 2 to specify which one you mean.\b
    Seventh, this version uses the adv3Lite library's 'invisiclues' hint system to 
    offer hints to the player, and adds to the number of hints provided, not least
    where the oroginal hints seem too vague or cyptic to be helpful or where an obscure
    puzzle had no hints at all. This version also adds a couple of in-game clues for
    puzzles that were badly underclued in the original (the most egregious of these
    being the need to use a magic word that was nowhere revealed to the player, but there
    were others that were almost just as bad). "
    
;
    
+ MenuLongTopicItem 'Navigating Mazes'
    "It may be that the actual Colossal Cave network on which the original version
    of this game could be maze-like in places, but whatever the inspiration for the
    mazes in the original Colossal Adventure and some of its more recent extensions,
    it has become something of a commonplace that mazes are more popular with game
    authors than game players. In the interests of authenticity and fidelity 
    to the original, they have been retained in this port, but with the option to skip
    them if you find them just too tedious to bother with.\b
    There are a number of tried and trusted strategies for navigating a traditional maze.
    First, you need to make a map (typically with pen and paper). For this you need to
    check whether every location in the maze is truly identical or whether there
    are subtle differences, either in the way the location is described or in the exits
    available in each location (the status line exit lister can help you with this, as
    it may also help a little by showing which exits are yet unvisited). If there are
    differences, you'll need to note them on your map so you can tell which location is which.\b
    If all the maze locations are otherwise identical, the standard ploy is to drop one item
    from your inventorry at various different locations and differentiate between them that
    way. Be warned, though, that a maze may well contain quite a few more locations than there
    are items in your inventory.\b
    Seocond, note that room connections in mazes are deliberately illogical. For example, if
    going north from Rooms A take you to Room B, the likelihood is that going south from 
    Room B <i>won't</i> take you back to Room A. This means that you'll have little chance
    of drawing spatially coherent map. Instead you'll just need to draw something along
    the lines of a series of numbered boxes with directional arrows labelled with the numbers
    of other boxes representing maze locations.\b
    If you've never tried finding your way through an IF/Adventure Game before, by all means
    try it out just for the experience, but if you come (or have already come) to the conclusion
    that finding your way through mazes is just a tiresome chore, you won't be alone. For that
    reason, issuing the ENABLE MAZESKIP command will cost you only two points. Thereafter, whenever
    you find yourself stuck in a maze, you can just type MAZESKIP or SKIPMAZE or SKIP MAZE to be
    taken straight to where you need to get to (these commands will cycle between the relevant
    detinations). "    
;

    
modify VerbRule(About)
    'about' | 'help'
    :
;