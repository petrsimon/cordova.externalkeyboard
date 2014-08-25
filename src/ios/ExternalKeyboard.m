#import "ExternalKeyboard.h"
#import <Cordova/CDV.h>
#import "MainViewController.h"

@implementation ExternalKeyboard

- (void) setKeyCommands: (CDVInvokedUrlCommand*) command {
    NSString* _cmds = [command.arguments objectAtIndex:0];
    NSString* _sep = [command.arguments objectAtIndex:1];
    
    NSMutableArray *cmds = [self prepareCommands:_cmds :_sep];
    
    MainViewController *vc = (MainViewController*) self.viewController;
    [vc setKeyCommands:cmds];
}

- (NSMutableArray*) prepareCommands:(NSString*) _cmds :(NSString*) _sep {
    NSMutableArray *commands = [[NSMutableArray alloc] init];
    NSArray *cmds = [_cmds componentsSeparatedByString:_sep];
    NSLog(@"Cordova ExternalKeyboard setKeyCommands: %@", _cmds);
    for (NSString* cmd in cmds)
    {
        BOOL meta = [cmd rangeOfString:@"meta" options: NSCaseInsensitiveSearch].location != NSNotFound;
        //        BOOL ctrl = [cmd rangeOfString:@"ctrl" options: NSCaseInsensitiveSearch].location != NSNotFound;
        BOOL option = [cmd rangeOfString:@"alt" options: NSCaseInsensitiveSearch].location != NSNotFound;
        //        BOOL shift = [cmd rangeOfString:@"shift" options: NSCaseInsensitiveSearch].location != NSNotFound;
        //
        
        NSLog(@"CMD %@", cmd);
        
        NSMutableArray *parts = [[cmd componentsSeparatedByString:@" "] mutableCopy];
        int size = [parts count];
        
        //FIXME: possibly add support for function keys, which are missing on Logitech keyboard I've got
        if(size>1){
            NSString *input = [parts objectAtIndex:size-1];
            //        if(isMetaOption){
            //            [commands addObject:[UIKeyCommand keyCommandWithInput:input modifierFlags:UIKeyModifierCommand | UIKeyModifierAlternate action:@selector(onKeyPress:)]];
            //        } else {
            [parts removeLastObject];
            NSString *joinedParts = [parts componentsJoinedByString:@" "];
            UIKeyModifierFlags flags = [self getModifierFlag:joinedParts];
            UIKeyModifierFlags f = UIKeyModifierCommand | UIKeyModifierAlternate;
            if(meta && option){
                NSLog(@"FLAGS %d = %d", flags, f);
            }
            
            SEL sel = NSSelectorFromString(@"onKeyPress:");
            [commands addObject:[UIKeyCommand keyCommandWithInput:input modifierFlags:flags action:sel]];
            
            //        }
        }
    }
    
    return commands;
}

- (UIKeyModifierFlags) getModifierFlag:(NSString*) mods {
    
    UIKeyModifierFlags flag = 0;
    
    BOOL meta = [mods rangeOfString:@"meta" options: NSCaseInsensitiveSearch].location != NSNotFound;
    BOOL ctrl = [mods rangeOfString:@"ctrl" options: NSCaseInsensitiveSearch].location != NSNotFound;
    BOOL option = [mods rangeOfString:@"alt" options: NSCaseInsensitiveSearch].location != NSNotFound;
    BOOL shift = [mods rangeOfString:@"shift" options: NSCaseInsensitiveSearch].location != NSNotFound;
    
    NSLog(@"getKeyCMD %@: meta=%hhd, option=%hhd, ctrl=%hhd, shift=%hhd",mods, meta, option, ctrl, shift);
    
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
    
    return flag;
}

+ (NSString*) getCombo:(UIKeyCommand*) cmd {
    
    UIKeyModifierFlags flags = cmd.modifierFlags;
    NSString *input = cmd.input;
    
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
    
    //    if ([input isEqualToString:@"\b"]) {
    //        [inputCharacters appendFormat:@"%@", @"DEL"];
    //    }
    //    if ([input isEqualToString:@"\t"]) {
    //        [inputCharacters appendFormat:@"%@", @"TAB"];
    //    }
    //    if ([input isEqualToString:@"\r"]) {
    //        [inputCharacters appendFormat:@"%@", @"ENTER"];
    //    }
    //    if (input == UIKeyInputUpArrow) {
    //        [inputCharacters appendFormat:@"%@", @"↑"];
    //    }
    //    if (input == UIKeyInputDownArrow) {
    //        [inputCharacters appendFormat:@"%@", @"↓"];
    //    }
    //    if (input == UIKeyInputLeftArrow) {
    //        [inputCharacters appendFormat:@"%@", @"←"];
    //    }
    //    if (input == UIKeyInputRightArrow) {
    //        [inputCharacters appendFormat:@"%@", @"→"];
    //    }
    //    if (input == UIKeyInputEscape) {
    //        [inputCharacters appendFormat:@"%@", @"ESC"];
    //    }
    
    [modifierSymbols addObject:input];
    NSString *combo = [modifierSymbols componentsJoinedByString:@" "];
    return combo;
}

@end

