#charset "us-ascii"
#include "advlite.h"

basilisk: NPC 'basilisk'
    petrified() {}
    petrifier() {}
;

djinn: Actor 'djinn;;;him'
;

goblins: NPC 'goblins'
    summon(loc) {}
;

ogre: NPC 'ogre'
    exists = true
;

slime: Feedable, Fixture 'slime; evil green of[prep]; sheet' @crack2
    "A sheet of evil-looking green slime swathes the floor to
     the south.  It is twitching and flowing as though aware of
     your presence."
    exists = true
    
    dobjFor(Cross)
    {
        verify() {}
        action()
        {
            "As you enter the passage, you are forced to
            brush up against some of the green slime.  Instantly
            it flows down and covers your body, and rapidly
            digests away all of your flesh.";
            die();
        }
    }
    
    specialDesc = "The passage to the south is swathed
           with sheets of evil-looking green slime, which
           twitch and flow as if aware of your presence. "
    
        
;