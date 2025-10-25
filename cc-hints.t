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

+ Goal 'What am I meant to be doing now?'
    [
        'Finding a way out -- but you won\'t find any ready-made exits. ',
        'You\'ll need to file a pile of objects that aren\'t what they might first appear to be. ',
        'Think of it as an explosive discovery -- it\'ll be a blast! ',
        'Don\'t stand too close! '       
    ]
    openWhenSeen = atNEEnd
;
    