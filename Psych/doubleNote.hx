// OG SCRIPT BY: BFDI 26 DEVS
// MODIFIED BY: camlikeskirby
// CLEANED UP BY: Xarlosgammer0FNF
// This is some messy code and can prob be shortend but it works.

import states.PlayState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween.IFlxTween;
import flixel.util.FlxStringUtil;

using StringTools;

var inGFSection:Bool = false;
var ghostCount:Int = 0;

var settings = {
    ghostLimit: 20,
    animated: false,
    ghostMoves: true,
    ghostSustains: false,
    coloredGhosts: true,
    howFarItMoves: 80,
    howFarLongItTakesToMove: 8,
    typeOfEase: FlxEase.circOut
};

var bfStuffs = {
    lastNote: -1,
    lastNoteDir: "",
    lastNoteData: 0,
    lastSwagNote: false,
    lastTailLength: 0
};

var opStuffs = {
    lastNote: -1,
    lastNoteDir: "",
    lastNoteData: 0,
    lastSwagNote: false,
    lastTailLength: 0
};

function goodNoteHit(n) {
    if (n.isSustainNote) return;
    calcalateInfo(n, boyfriend);
}

function opponentNoteHit(n) {
    if (n.isSustainNote) return;
    calcalateInfo(n, dad);
}

function calcalateInfo(n, character) {
    var stuffs = null;
    var isGF:Bool = (n.gfNote) || inGFSection;
    var theCharNeeded = isGF ? gf : character;

    if (character == dad) stuffs = opStuffs;
    else stuffs = bfStuffs;

    if (stuffs.lastNote == n.strumTime) {
        var tailLength:Bool = n.sustainLength >= 150;
        var length = stuffs.lastTailLength;

        if (length == 0 || length == null) length = 0.55;
        makeGhost(theCharNeeded, stuffs.lastNoteDir, stuffs.lastNoteData, stuffs.lastSwagNote, length);
    } else {
        stuffs.lastNote = n.strumTime;
        stuffs.lastNoteDir = theCharNeeded.getAnimationName();
        stuffs.lastNoteData = n.noteData;
        if (n.tail != null && n.tail.length > 0 && settings.ghostSustains) 
            stuffs.lastSwagNote = true;
        else 
            stuffs.lastSwagNote = false;
        stuffs.lastTailLength = (n.tail != null) ? n.tail.length : 0;
    }
}

function makeGhost(char, animToPlay:String, noteData:Int, swagNote:Bool, noteLength:Float) {
    if (ghostCount >= settings.ghostLimit || !char.visible || char.alpha == 0) return;

    ghostCount = ghostCount + 1;
    var trail = new Character(char.x, char.y, char.curCharacter, (char == boyfriend) ? true : false);
    
    if (!settings.coloredGhosts) 
        trail.color = char.color; 
    else 
        trail.color = getIconColor(char);
    
    trail.scale.set(char.scale.x, char.scale.y);
    trail.holdTimer = 0;
    trail.alpha = char.alpha;
    
    if (char == boyfriend) addBehindBF(trail);
    else if (char == dad) addBehindDad(trail);
    else addBehindGF(trail);
    
    trail.playAnim(animToPlay);

    if (settings.ghostMoves) {
        switch(noteData) {
            case 0:
                FlxTween.tween(trail, {x: trail.x - settings.howFarItMoves}, settings.howFarLongItTakesToMove, {ease: settings.typeOfEase});
            case 1:
                FlxTween.tween(trail, {y: trail.y + settings.howFarItMoves}, settings.howFarLongItTakesToMove, {ease: settings.typeOfEase});
            case 2:
                FlxTween.tween(trail, {y: trail.y - settings.howFarItMoves}, settings.howFarLongItTakesToMove, {ease: settings.typeOfEase});
            case 3:
                FlxTween.tween(trail, {x: trail.x + settings.howFarItMoves}, settings.howFarLongItTakesToMove, {ease: settings.typeOfEase});
        }
    }

    var fadeTime = 0.55;
    if (swagNote) {
        fadeTime = (noteLength != 0.55) ? noteLength / 4.2 : 0.55;
    }

    FlxTween.tween(trail, {alpha: 0}, fadeTime).onComplete = function() {
        trail.kill();
        remove(trail, true);
        ghostCount = ghostCount - 1;
        if (ghostCount < 0) ghostCount = 0;
    };

    if (!settings.animated) {
        trail.animation.frameName = trail.animation.frameName;
    }
}

function onSectionHit() {
    try {
        if (PlayState.SONG.notes[curSection].gfSection) 
            inGFSection = true;
        else 
            inGFSection = false;
    } catch (e) {
        inGFSection = false;
    }
}

function getIconColor(chr) {
    if (chr == dad) 
        return FlxColor.fromString('#' + rgbToHex(game.dad.healthColorArray));
    else if (chr == boyfriend) 
        return FlxColor.fromString('#' + rgbToHex(game.boyfriend.healthColorArray));
    else if (chr == gf) 
        return FlxColor.fromString('#' + rgbToHex(game.gf.healthColorArray));
    else 
        return FlxColor.fromString('#' + rgbToHex(game.dad.healthColorArray));
}

function rgbToHex(array:Array<Int>):String {
    return StringTools.hex((array[0] << 16) | (array[1] << 8) | array[2], 6);
}
