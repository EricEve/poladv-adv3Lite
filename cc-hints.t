#charset "us-ascii"

#include <tads.h>
#include "advlite.h"

/* 
 *   Hints for this version of Colossal Cave Adventure. Instead of porting the adv2 implementation,
 *   where hints are sparse and not always all that helpful, we'll implement some fuller hints using
 *   adv3Lite's hintsys module, especially as many of the original game's puzzles are unfair or
 *   inadequately clued. We will, however, apply a small score penalty for using hints.
 */

modify Hint
    
    
    /* 
     *   Flag to see if this hint has been viewed before, to ensure we don't apply the same score
     *   penalty more than once.
     */
    hintViewed = nil
    
    getItemText()
    {
        applyScorePenalty();
        return inherited();
    }
    
    
;
    
modify Goal    
    displaySubItem(idx, lastBeforeInput, eol)
    {
        inherited(idx, lastBeforeInput, eol);
        
        /* 
         *   Keep track of the latest hint shown so that we don't apply the score penalty more than
         *   once.
         */
        if(idx > lastHintShown)
        {
            applyScorePenalty();
            lastHintShown = idx; 
        }        
    }
    
    lastHintShown = 0      
    
    /* The score penalty to be applied for viewing this hint. */
    scorePenalty = -1
    
    /* The text of the explanation for why points have been deducted */
    scorePenaltyMsg = 'for using hints'
    
    /* Apply the score penalty */
    applyScorePenalty()    
    {        
        addToScore(scorePenalty, scorePenaltyMsg);         
    }
    
    
;

topHintMenu: TopHintMenu;

+ Goal 'What am I meant to be doing in this game?'
    [
        'Explore your surroundings, collect as many treaures as you can, and bring them back to the
        building. ',
        'Also, make a careful note of anything that might be a magic word. '
    ]
    
    openWhen = true
    closeWhenSeen = westSideOfFissure
;

+ Goal 'How do I get into the cave?'
    [
        'I don\'t know where the cave is, but hereabouts no stream can
            run on the surface for long.  I would try the stream. '
    ]
    openWhen = true
    closeWhen = atY2.seen || inDebrisRoom.seen || belowTheGrate.seen || outsideGrate.seen
;

+ Goal 'How do I get into the cave?'
    [
        'The grate is very solid and has a hardened steel lock.
        You cannot enter without a key, and there are no keys nearby.
        I would recommend looking elsewhere for the keys. ',
        
        'You have looked inside the building, haven\'t you? ',        
        
        'Presumably you know to UNLOCK GRATE WITH KEYS. '
    ]
    openWhen = grate.seen && !setOfKeys.moved
    closeWhen = atY2.seen || inDebrisRoom.seen || belowTheGrate.seen || setOfKeys.moved
;

+ Goal 'How do I take the little bird?'
    [
        'Perhaps you\'re doing something to scare it. ',
        'Could you be carrying something scary? ',
        'Funnily enough, I don\'t mean the cage. '
    ]
    
    openWhenRevealed = 'bird-scared'
    closeWhenMoved = littleBird
;
    
+ Goal 'How do I get past the snake?'
    [
        'You can\'t deal with the snake by yourself. ',
        'You\'ll need to enlist help. ',
        'From some other creature -- have you see one?' 
    ]
    openWhenRevealed = 'snake-block'
    closeWhenMoved = snake
;

+ Goal 'How do I get past the dragon?'
    [
        'It\'s easier than you think. ',
        'Be bold! '
    ]
    openWhenSeen = dragon
    closeWhen = dragon.isIn(nil)
;

+ Goal 'Is there a way across the fissure?'
    [
        'Yes. ',
        'But you\'ll have to create it yourself. ',
        'And not by any natural means. ',
        'Have you found anything that could perhaps be used for magical purposes? ',
        'How might magicians typically used such an implement? '
        
    ]
    openWhenSeen = onEastBankOfFissure
    closeWhen = crystalBridge.exists
;

+ Goal 'What can I do about the bear?'
    [
        'Maybe he\'s hungry '
    ]
    openWhenRevealed = 'ferocious bear'
    closeWhen = isTame
;

+ Goal 'How do I get past the troll?'
    [
        'Better do eggsactly as he wants. '
    ]
    openWhenSeen = troll
    closeWhenRevealed = 'troll-departs'
;

+ Goal 'How do I get past the troll a second time?'
    [
        'You need to enlist help. ',
        'From a creature stronger than you are. ',      
        'You\'ll have to persuade him to follow you back to the troll. '
    ]
    openWhenSeen = onNESideOfChasm 
    closeWhenRevealed = 'bear-attack'
;

+ Goal 'How do I get the sword out of the anvil? '
    [
        'If you could convince me of your royal blood, you might get somewhere. ',
        'What could you wear that might do that? '
    ]
    openWhenRevealed = 'sword-stuck'
    closeWhen = sword.isIn(gPlayerChar)
;

+ Goal 'How do I get up the slide?'
    [
        slideHint,        
        'I\'d advise you to try to find another way into the area. '
    ]
    
    openWhenRevealed = 'slide-back'
    closeWhenSeen = swordPoint
;

++ slideHint: Hint
    itemText
    {
        if(global.game701)
            return 'You could spend all day trying to get up there. ';
        else 
            return 'The chute is particularly slippery in this version of the
                game, and I don\'t think you\'ll get up there however hard you try. ';            
    }
;

+ Goal 'How do I get to the other side of the tiny door?'
    [
        'This is obviously an elfin entrance.  Unless you can squeeze
        yourself through a six-inch door, you\'ll have to find another
        way into the cave. ',
        'You can\'t make the door any bigger, so the only way to fit yourself
        through would be to...',
        'To make yourself smaller would require magic. Know any good magic words? '
    ]
    
    openWhenSeen = topOfSteps
    closeWhenSeen = ledgeByDoor    
;

+ Goal 'How do I reach the natural bridge above the rainbow room?'
    [
        'You can\'t get to it by climbing the walls or jumping or anything
        like that. You could always put in a telephone call to the local
        spelunking club for advice, if you could find a phone. ',
        
        'We\'re off to the see the wizard, the wonderful wizard of... ',
        
        '<q>The Wizard of Oz</q> features both a relevant song and a relevant
        magical item worn by Dorothy. ',
        
        'Amongst other things, the wearable whatsits near the low-frequency end of the rainbow
        could be used for teleportation. ',
        
        'I guess I\'ll just have to stand here clicking my heela until you
        figure it out. '
    ]
    
    openWhenSeen = rainbowRoom
    closeWhenSeen = overRainbow
;

+ Goal 'How do I get down from the ledge above limestone pinnacles with bulky items?'
    [
        'Maybe you\'d better look for another way into the cave. ',
        'And another mode of transport. '
    ]
    
    openWhenSeen = ledgeAbovePinnacles
    closeWhenSeen = grottoWest
;

+ Goal 'How do I get past the dog?'
    [
        'The only person I can remember who managed to get past the dog
        was that singer, ummm, what\'s his name... Euridice\'s friend...',
        
        'If your voice sounds untrue, you may need to try something less vocal. '
    ]
    openWhenSeen = dog
    closeWhen = dog.isAsleep
;

+ Goal 'How do I deal with the ogre?'
    [
        'Unnatural opponents may require unnatural weapons. ',
        'Have you encountered one that behaves a bit strangely? ',
        'But don\'t get too close to the ogre with it! '
    ]
    openWhenSeen = ogre
    closeWhenRevealed = 'ogre-demise'   
;

+ Goal 'How do I deal with the slime?'
    [
        'Whatever you do, don\'t touch it!',
        'This requires a chemical solution. ',
        'Have you found something that might contain something suitably toxic? '
    ]
    openWhenSeen = slime
    closeWhen = (!slime.exists)
;

+ Goal 'What do I do at the waterfall cavern?'
    [
        'Something you\'d probably dream of doing in real life. ',
        'What\'s the most foolhardy thing you can think of? '
    ]
    openWhen = (global.game550 && !global.game701 && waterfall.seen)
    closeWhenRevealed = 'waterfall-transit'
;

+ Goal 'What am I meant to be doing now?'
    [
        'Finding a way out -- but you won\'t find any ready-made exits. ',
        'You\'ll need to file a pile of objects that aren\'t what they might first appear to be. ',
        'Think of it as an explosive discovery -- it\'ll be a blast! ',
        'Don\'t stand too close! '       
    ]
    openWhenSeen = atNEEnd
;
    
+ Goal 'What should I do with the giant clam?'
    [
        'Might there be something of value inside? ',
        'It\'s a very big clam, though, so it may take something equally substantial to open it. '        
    ]
    openWhenSeen = giantBivalve
    closeWhenRevealed = 'open-clam'
;

+ Goal 'How do I deal with the goblins?'
    [
        'Multiple enemies require multiple simultaneous responses. ',
        'You need to summon a lot of helpers -- fast!',
        'A remnant of a foe you\'ve already vanquished may do the trick. '        
    ]
    openWhenRevealed = 'goblins'
    closeWhenRevealed = 'goblins-banished'
;

+ Goal 'How do I get out of the cylindrical room?'
    [
        'When natural means fail, maybe you need to resort to magic. ',
        'Remember what the djinn told you about Witt\'s alphabetic eccentricity. ',
        'I hope you\'ve noted all the magic words mentioned in this game. ',
        'You need to recite them all in reverse alphabetical order. '
    ]
    openWhen = (gRoom == cylindricalRoom)
    closeWhenRevealed = 'exitcylinder'    
;

+ Goal 'What do I do with the earthenware flask?'
    [
        'Nothing remotely obvious, but don\'t be in too much of a hurry to open it. ',
        'Find a symbol to place it in/on. ',
        'Then open it. '        
    ]
    openWhenMoved = flask
    closeWhen = flask.isOpen
;

+ Goal 'How do I open the walk-in safe?'
    [
        'In a roundabout manner of speaking, you kinda need a skeleton key. ',
        'A magical, insusbstantial one. ',
        'Something a skeleton told you. '       
    ]
    openWhenRevealed = 'walk-in'
    closeWhenSeen = inSafe
;

+ Goal 'What happens now?'
    [
        'Try exploring not too far from the building. ',
        'Has anything changed? ',
        'Is there somewhere you could go you couldn\'t go before? '
    ]
    openWhenRevealed = 'exitcylinder'    
;
