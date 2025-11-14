#charset "us-ascii"
#include "advlite.h"

metalPlate: Thing 'metal plate'
;

sceptre: Treasure 'sapphire sceptre; long encrusted' @eastAudience
    "It's a long sceptre, ornately encrusted with sapphires!"
    
    mention()
    {
        mentioned = true;
        noteSeen();
        "a long, sapphire-encrusted sceptre";
    }
    
    dobjFor(Take)
    {
        action()
        {
            local i;
            inherited();
            
            //
            // If we didn't get the sceptre (e.g., if the
            // actor's carrying too much), don't do anything
            // else.
            //
            if (!isIn(gActor))
                return;
            else skeleton.moveInto(nil);
            // This will happen every time the sceptre is
            // picked up, but this is harmless.
            
            if(!passwordtold && inSafe.isFused) 
            {
                "As you pluck the sceptre from the
                skeleton's grasp, it raises its head
                and whispers, \"You blew it!\".  It
                then shivers and collapses into a pile
                of fine dust which quickly vanishes.";
                
                passwordtold = true;
            }
            else if(!passwordtold) 
            {
                // First determine the keyword.
                inSafe.password = rand(5) + 1;
                
                "You pluck the sceptre from the skeleton's
                bony hand.  As you do, the skeleton raises
                its head and whispers <q>Remember -- ";
                
                // Now print the word, using its sdesc:
                for (i = firstObj(VaultKeyVerb); i; i = nextObj(i, VaultKeyVerb))
                    if(i.wordnum == inSafe.password) 
                        say(i.verb);
                
                // Done. Now print the rest of the text.
                "!\</q>in a forboding tone; it then sags to the
                ground and crumbles into dust which drifts
                away into the still air of the cave.<.p>"; 
                passwordtold = true;
            }
        }
    }
    
    passwordtold = nil
    
;

bracelet:Thing 'bracelet'
;

singingSword: Weapon 'singing sword; sharp shiny' @sandstoneChamber
    "The sword is sharp and shiny.  It is singing quietly to itself. "
    
    initSpecialDesc = "There is a sword here, with its blade plunged deep into
               the block of stone.  The sword is singing quietly to itself. "
    
    specialDesc()
    {
        
        switch(rand(11) + 1) 
        {
            case 1: "There is a magic sword here, chiming out the bell-like
                tones of \"Kumbu Ice-fall\" by ringing its blade
                against the ground."; break;
            case 2: "There is a sword here, singing \"A Day in the Life\"
                in a quiet, introspective voice."; break;
            case 3: "There is a magic sword here, singing \"Cold Blue
                Steel and Sweet Fire\" to itself in a plaintive,
                hopeless voice."; break;
            case 4: "There is a sharp and obviously magical sword here.
                It is quietly humming excerpts from Prokofiev's \"Romeo
                and Juliet\" ballet to itself."; break;
            case 5: "There is a sword lying on the ground, jauntily
                whistling the March from Tchaikovsky's \"Nutcracker
                Suite\"."; break;
            case 6: "There is a sharp sword lying here. It is (somehow)
                singing Tchaikovsky's \"1812 Overture\" in twelve
                parts, by itself!"; break;
            case 7: "The stirring strains of Rossini's \"William Tell\"
                overture fill the room, coming from a singing
                sword lying on the ground."; break;
            case 8: "There is a singing sword lying on the ground . From
                it resound the massed voices of a two-hundred-singer
                choir, filling the air with the stirring sound
                of the Hallelujah Chorus from Handel's
                \"Messiah\"."; break;
            case 9: "There is a sharp and shiny sword here. It is
                somehow managing to sing Harry Partch's \"Daphne
                of the Dunes\" without destroying its singing
                organs (whatever they happen to be...)."; break;
            case 10: "There is a sword here, singing \"Witchi-Tai-To\"
                in two-part harmony with itself."; break;
            case 11: "There is a very strange singing sword here - it
                is glowing and vibrating, and the eerie electronic
                notes of Charles Wuorinen's \"Time's Encomium\"
                issue from its blade and fill the air."; break;
        }
    }
    
    isStuck = true
    nosack = true
    fromloc = stone
    strongenough = (mushroom.isEaten || (gPlayerChar.blueberriesEaten > 2))
    
    dobjFor(Take)
    {
        check()
        {
            if(isStuck && !strongenough)
            {
                "The sword is firmly embedded in the stone, and you <<if
                  gPlayerChar.blueberriesEaten > 0>> still aren't quite <<else>>
                aren't<<end>> strong enough to pull it out. ";
            }
        }
        
        action()
        {
            if(isStuck && self.strongenough) 
            {
                "The singing sword slides easily out of the rock.  ";
                isStuck = nil;
            }
            Dwarves.noAttack = true;
            inherited();
        }
    }
    
    dobjFor(Pull)
    {
        check()  { checkDobjTake();  }
        
        action()
        {
            if(isStuck)
                actionDobjTake();
            else
                inherited();
            
        }
    }

   yankObj = isStuck
;

sculpture: Treasure 'rock-crystal sculpture; pig eel emu elf mouse rabbit ibex
    frog tiger mule moose crystal crystalline rock carved finely
    finely-carved'   
    @sculptNiche
    "It is a finely-carved sculpture of <<animdesc>>, made of rock crystal!"
    game550 = true
    
    
    animdesc 
    {
        switch(rand(11 + 1)) 
        {
            case 1: "a pig"; break;
            case 2: "an eel"; break;
            case 3: "an emu"; break;
            case 4: "an elf"; break;
            case 5: "a mouse"; break;
            case 6: "a rabbit"; break;
            case 7: "an ibex"; break;
            case 8: "a frog"; break;
            case 9: "a tiger"; break;
            case 10: "a mule"; break;
            case 11: "a moose"; break;
        }
    }
    specialDesc = "There is a finely carved sculpture of <<animdesc>> here! "
    
    mention()
    {
        mentioned = true;
        noteSeen();
        "A finly carved sculpture of <<animdesc>> ";
    }
;