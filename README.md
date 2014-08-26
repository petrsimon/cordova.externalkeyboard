# External Keyboard Plugin for Cordova, Phonegap and Ionic

The `cordova.plugins.ExternalKeyboard` provides an easy way to configure keyboard shortcuts for iOS 7 devices with an external bluetooth keyboard. Currently the plugin requires a little bit of manual installation (see below).


# Installation

First install the plugin proper:

    cordova plugin add https://github.com/petrsimon/cordova.externalkeyboard.git

After running the command above, open the iOS project in XCode and add the following code:

## In `MainViewController.h`

replace 

```objective-c
#import "ExternalKeyboard.h"
@interface MainViewController : CDVViewController
@end
```

with 

```objective-c
@interface MainViewController : CDVViewController {
    NSMutableArray *commands;
}

- (void) setKeyCommands:(NSArray*) commands;
@end
```

## In `MainViewController.m`

add 

```Objective-c
- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void) setKeyCommands: (NSMutableArray*) cmds {
    NSLog(@"Setting commands %@", cmds);
    commands = cmds;
}


- (NSArray *)keyCommands {
    return commands;
}

- (void) onKeyPress:(UIKeyCommand*) cmd {
    NSLog(@"onKeyPress");
    
    NSString *combo = [ExternalKeyboard getCombo:cmd];
    
    NSLog(@"COMBO [%@]", combo);
    NSString *jsStatement = [NSString stringWithFormat:@"handleKeyCommand('%@')", combo];
    NSLog(@"onKeyPress %@", jsStatement);
    [self.commandDelegate evalJs:jsStatement];
}
```



### 

# Usage

## Set up 
Currently the expected format for shortcuts is a simple string with modifier keys and input keys delimited by a space and the commands delimited by a configurable string such as `|`:
```javascript
var commands = "ctrl s|ctrl n|meta s|meta alt j";
```

The `meta` key stands for the Command Key (⌘) on Mac. The Mac Option Key (⌥) is represented by "alt".

Then send the commands to the plugin:

```javascript
cordova.plugins.ExternalKeyboard.setKeyCommands(commands, delimiter);
```


## Handling the shortcuts
On the page or in one of your modules, create the function `handleKeyCommand` like so:
```javascript
window.handleKeyCommand = function(combo) {
    // do something usefull
}
```

In AngularJS or Ionic it is quite possible to define of overwrite the `handleKeyCommand` function in a controller or to send the combo to a service that will take care of it, e.g.
```javascript
window.handleKeyCommand = function(combo) {
    $scope.handleCombo(combo)
    // or using a service
    Keymap.handleShortcut(combo);
}
```

# Supported Platforms

- iOS
