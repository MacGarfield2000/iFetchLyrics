//
//  AppDelegate.h
//  iFetchLyrics
//
//  Public Domain
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (unsafe_unretained) IBOutlet NSTextView *textView;
@property (strong) NSArray *fetchers;

@end
