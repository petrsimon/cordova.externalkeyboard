#import "ExternalKeyboard.h"
#import <Cordova/CDV.h>
#import "MainViewController.h"

@implementation ExternalKeyboard


- (void) redraw: (CDVInvokedUrlCommand*) command {
    MainViewController *vc = (MainViewController*) self.viewController;
    [vc.view setNeedsDisplay];
}

- (void) setKeyCommands: (CDVInvokedUrlCommand*) command {
    NSString* _cmds = [command.arguments objectAtIndex:0];
    NSString* _sep = [command.arguments objectAtIndex:1];
    
    NSMutableArray *cmds = [self prepareCommands:_cmds :_sep];
    
    MainViewController *vc = (MainViewController*) self.viewController;
    [vc setKeyCommands:cmds];
}

- (NSMutableArray*) prepareCommands:(NSString*) _cmds :(NSString*) _sep {
    NSLog(@"Cordova ExternalKeyboard setKeyCommands: %@", _cmds);
    
    NSMutableArray *commands = [[NSMutableArray alloc] init];
    NSArray *cmds = [_cmds componentsSeparatedByString:_sep];
    
    for (NSString* cmd in cmds)
    {
        
        NSMutableArray *parts = [[cmd componentsSeparatedByString:@" "] mutableCopy];
        int size = [parts count];
        
        NSString *input = [parts objectAtIndex:size-1];
        [parts removeLastObject];
        NSString *joinedParts = [parts componentsJoinedByString:@" "];
        
        UIKeyModifierFlags flags = [self getModifierFlags:joinedParts];
        
        // using runtime selector, because onKeyPress is a method of MainViewController
        SEL sel = NSSelectorFromString(@"onKeyPress:");
        
        if ([input isEqual:@"enter"]){
            input = @"\r";
        } else if ([input isEqualToString:@"up"]){
            input = UIKeyInputUpArrow;
        } else if ([input isEqualToString:@"down"]){
            input = UIKeyInputDownArrow;
        } else if ([input isEqualToString:@"left"]){
            input = UIKeyInputLeftArrow;
        } else if ([input isEqualToString:@"right"]){
            input = UIKeyInputRightArrow;
        } else if ([input isEqualToString:@"esc"]){
            input = UIKeyInputEscape;
        } else if ([input isEqualToString:@"tab"]){
            input = @"\t";
        } else if ([input isEqualToString:@"del"]){
            input = @"\b";
        } else if ([input isEqualToString:@"space"]){
            input = @" ";
        }
        
        [commands addObject:[UIKeyCommand keyCommandWithInput:input modifierFlags:flags action:sel]];
    }
    return commands;
}

- (UIKeyModifierFlags) getModifierFlags:(NSString*) mods {
    
    UIKeyModifierFlags flag = 0;
    
    BOOL meta = [mods rangeOfString:@"meta" options: NSCaseInsensitiveSearch].location != NSNotFound;
    BOOL ctrl = [mods rangeOfString:@"ctrl" options: NSCaseInsensitiveSearch].location != NSNotFound;
    BOOL option = [mods rangeOfString:@"alt" options: NSCaseInsensitiveSearch].location != NSNotFound;
    BOOL shift = [mods rangeOfString:@"shift" options: NSCaseInsensitiveSearch].location != NSNotFound;
    BOOL caps = [mods rangeOfString:@"caps" options: NSCaseInsensitiveSearch].location != NSNotFound;
    
    //NSLog(@"getKeyCMD %@: meta=%hhd, option=%hhd, ctrl=%hhd, shift=%hhd",mods, meta, option, ctrl, shift);
    
    // multiple
    if (meta && option) {
        flag = UIKeyModifierCommand | UIKeyModifierAlternate;
    }
    
    else if (meta && ctrl) {
        flag = UIKeyModifierCommand | UIKeyModifierControl;
    }
    
    else if (meta && shift) {
        flag = UIKeyModifierCommand | UIKeyModifierShift;
    }
    
    else if (ctrl && option) {
        flag = UIKeyModifierControl | UIKeyModifierAlternate;
    }
    else if (ctrl && meta) {
        flag = UIKeyModifierControl | UIKeyModifierCommand;
    }
    
    else if (ctrl && shift) {
        flag = UIKeyModifierControl | UIKeyModifierShift;
    }
    else if (option && shift) {
        flag = UIKeyModifierAlternate | UIKeyModifierShift;
    }
    
    else if (meta) {
        flag = UIKeyModifierCommand;
    }
    
    else if (ctrl){
        flag = UIKeyModifierControl;
    }
    
    else if (option){
        flag = UIKeyModifierAlternate;
    }
    
    else if (shift){
        flag = UIKeyModifierShift;
    }
    
    else if (caps){
        flag = UIKeyModifierAlphaShift;
    }
    
    return flag;
}

+ (NSString*) getCombo:(UIKeyCommand*) cmd {
    UIKeyModifierFlags flags = cmd.modifierFlags;
    NSString *input = cmd.input;
    //NSUInteger length = [input length];

    //NSLog(@"Cordova ExternalKeyboard INPUT: [%@] len=%d flags=%d", cmd.input, (unsigned long)length, (unsigned long)cmd.modifierFlags);
    
    
    NSMutableArray *modifierSymbols = [[NSMutableArray alloc] init];
    
    if((flags & UIKeyModifierCommand) == UIKeyModifierCommand){
        [modifierSymbols addObject:@"meta"];
    }
    
    if((flags & UIKeyModifierAlternate) == UIKeyModifierAlternate){
        [modifierSymbols addObject:@"alt"];
    }
    
    if((flags & UIKeyModifierControl) == UIKeyModifierControl){
        [modifierSymbols addObject:@"ctrl"];
    }
    
    if((flags & UIKeyModifierShift) == UIKeyModifierShift){
        [modifierSymbols addObject:@"shift"];
    }
    
    if((flags & UIKeyModifierAlphaShift) == UIKeyModifierAlphaShift){
        [modifierSymbols addObject:@"caps"];
    }
    
    if ([input  isEqual: @"\r"]){
        [modifierSymbols addObject:@"enter"];
    }
    else if (input == UIKeyInputUpArrow){
        [modifierSymbols addObject:@"up"];
    }
    else if (input == UIKeyInputDownArrow){
        [modifierSymbols addObject:@"down"];
    }
    else if (input == UIKeyInputRightArrow){
        [modifierSymbols addObject:@"right"];
    }
    else if (input == UIKeyInputLeftArrow){
        [modifierSymbols addObject:@"left"];
    }
    else if (input == UIKeyInputEscape){
        [modifierSymbols addObject:@"esc"];
    }
    else if ([input isEqualToString:@"\t"]){
        [modifierSymbols addObject:@"tab"];
    }
    else if ([input isEqualToString:@"\b"]){
        [modifierSymbols addObject:@"del"];
    }
    else if ([input isEqualToString:@" "]){
        [modifierSymbols addObject:@"space"];
    }
    else {
        [modifierSymbols addObject:input];
    }
    
    
    NSString *combo = [modifierSymbols componentsJoinedByString:@" "];
    return combo;
}

@end