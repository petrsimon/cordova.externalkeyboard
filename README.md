# External Keyboard Plugin for Cordova, Phonegap and Ionic

This project is part of [Atuhi](http://atuhi.com)

The `cordova.plugins.ExternalKeyboard` provides an easy way to configure keyboard shortcuts for iOS 7 devices with an external bluetooth keyboard. The plugin runs an `after-install` hook to modify the MainViewController.h and MainViewController.m files as described below.


# Installation

First install the plugin proper:

    cordova plugin add https://github.com/petrsimon/cordova.externalkeyboard.git

When the plugin is installed, the iosAfterInstall.js hook script will modify the MainViewController.h and MainViewController.m files as shown here:

## In `MainViewController.h`

replace 

```objective-c
@interface MainViewController : CDVViewController
@end
```

with 

```objective-c
#import "ExternalKeyboard.h"
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
    [self.commandDelegate evalJs:jsStatement];
}
```



### 

# Usage

## Set up 

Currently the expected format for shortcuts is a simple string with modifier keys and input keys delimited by a space and the commands delimited by a configurable string such as `|`:

```javascript
var commands = "ctrl s|ctrl n|meta s|meta alt j|up|shift up";
```

You can use arrow keys (`up`, `down`, `left`, `right`) and `enter`, `space`, `tab`, `del` either as single key commands or with combination with modifier. Please notice, that these keys will stop fulfilling their default function. Supported modifier keys are `meta`, `ctrl`, `alt`, `shift` and `caps`.

The `meta` key stands for the Command Key (⌘) on Mac. The Mac Option Key (⌥) is represented by "alt". The `caps` key stands for the CapsLock key. CapsLock cannot be combined with any other modifier keys.

Then send the commands to the plugin:

```javascript
var commands = "ctrl s|ctrl n|meta s|meta alt j",
    delimiter = "|";
cordova.plugins.ExternalKeyboard.setKeyCommands(commands, delimiter);
```


## Handling the shortcuts
On the page or in one of your modules, create the function `handleKeyCommand` like so:
```javascript
window.handleKeyCommand = function(combo) {
    // do something usefull
}
```

In AngularJS or Ionic it is quite possible to define or overwrite the `handleKeyCommand` function in a controller or to send the combo to a service that will take care of it, e.g.
```javascript
window.handleKeyCommand = function(combo) {
    $scope.handleCombo(combo)
    // or using a service
    Keymap.handleShortcut(combo);
}
```

# Supported Platforms

- iOS
