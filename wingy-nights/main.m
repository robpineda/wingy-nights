//
//  main.m
//  wingy-nights
//
//  Created by Roberto Pineda on 11/21/24.
//

#import <UIKit/UIKit.h>
#import "SpriteAppDelegate.h"

int main(int argc, char * argv[]) {
    NSString * appDelegateClassName;
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([SpriteAppDelegate class]);
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
