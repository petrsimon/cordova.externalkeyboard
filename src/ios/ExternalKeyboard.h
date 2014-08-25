#import <Cordova/CDV.h>

@interface ExternalKeyboard : CDVPlugin

- (void) setKeyCommands: (CDVInvokedUrlCommand*) command;
+ (NSString*) getCombo:(UIKeyCommand*) cmd;
@end

