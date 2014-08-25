#import "ExternalKeyboard.h"
#import <Cordova/CDV.h>

@implementation ExternalKeyboard

- (void) setKeyCommands: (CDVInvokedUrlCommand*) command {
    NSString* _cmds = [command.arguments objectAtIndex:0];
    NSString* _sep = [command.arguments objectAtIndex:1];
    NSLog(@"Cordova ExternalKeyboard setKeyCommand: %@", _cmds);
    
    NSArray *cmds = [_cmds componentsSeparatedByString:_sep];
    
    MainViewController *vc = (MainViewController*) self.viewController;
    [vc setKeyCommands:cmds];
}

@end

