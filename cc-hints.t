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
    
    