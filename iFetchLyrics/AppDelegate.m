//
//  AppDelegate.m
//  iFetchLyrics
//
//  Public Domain
//

#import "iTunes.h"
#import "NSMutableArray+Shuffling.h"
#import <ScriptingBridge/ScriptingBridge.h>
#import "AppDelegate.h"
#import "WikiaFetcher.h"
#import "MetroFetcher.h"
#import "Lyricsn7plFetcher.h"
#import "LyrsterFetcher.h"
#import "LyricsmodeFetcher.h"
#import "GeniusFetcher.h"
#import "SonglyricsFetcher.h"
#import "ElyricsFetcher.h"
#import "MusixmatchFetcher.h"
#import "AzlyricsFetcher.h"
#import "LyricsmaniaFetcher.h" // blocks after a while ;(


@interface AppDelegate ()

@property (unsafe_unretained) IBOutlet NSView *view1;
@property (unsafe_unretained) IBOutlet NSView *view2;
@property (unsafe_unretained) IBOutlet NSView *view3;
@property (unsafe_unretained) IBOutlet NSWindow *window;

@property (strong, nonatomic) NSString *currentSongInfo;
@property (strong, nonatomic) NSString *progressInfo1;
@property (strong, nonatomic) NSString *progressInfo2;
@property (strong, nonatomic) NSString *finishInfo;
@property (strong, nonatomic) NSArray *playlists;
@property (assign, nonatomic) int selectedPlaylist;
@property (assign, nonatomic) int ignoreWithLyrics;

@property (strong, nonatomic) NSMutableArray *fetchers;
@property (assign) BOOL running;

@end

@implementation AppDelegate

- (IBAction)fetchLyrics:(id)sender {
	self.running = YES;
	[self.window setContentView:self.view2];

	NSString *playlistName = (self.playlists)[self.selectedPlaylist];
	iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
	iTunesPlaylist *playlist = [[(iTunes.sources)[0] userPlaylists] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@", playlistName]][0];
	SBElementArray *tracks = [playlist tracks];

	dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
	{
		int all = 0, skip = 0, succ = 0, fail = 0;

		@try {
			for (iTunesTrack *track in tracks) {
				if (!self.running)
					break;
				
				all++;
				if (self.ignoreWithLyrics && [track lyrics] && [[track lyrics] length]) {
					skip++;
					continue;
				}

				[self.fetchers shuffle]; // load distribution

				NSString *lyrics = nil;
				for (LyricsFetcher *fetcher in self.fetchers) {
					lyrics = [fetcher fetchLyricsForArtist:track.artist
													album:track.album
														title:track.name];

					dispatch_sync(dispatch_get_main_queue(), ^{
						self.currentSongInfo = [NSString stringWithFormat:@"%@ - %@", track.artist, track.name];
						self.progressInfo1 = [NSString stringWithFormat:@"[song %i of %i]", all, [tracks count]];
						self.progressInfo2 = [NSString stringWithFormat:@"[succ: %i fail: %i skip: %i]", succ, fail, skip];
					});
					
					if (lyrics) {
#ifdef DEBUG
						lyrics = [lyrics stringByAppendingString:[NSString stringWithFormat:@"\n\nFetched by iFetchLyrics v%@ from '%@'",
								  [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
								  [[fetcher className] stringByReplacingOccurrencesOfString:@"Fetcher" withString:@""]]];
#endif
						[track setLyrics:lyrics];
						if ([lyrics length] < 20 && [lyrics rangeOfString:@"instrumental" options:NSCaseInsensitiveSearch].location == NSNotFound)
							NSLog(@"Warning: suspected damaged lyrics fetched: artist: %@ title: %@ lyrics: %@", track.artist, track.name, lyrics);
						
						succ++;
						break;
					}
				}

				if (!lyrics)
					fail++;
			}
		} @catch (NSException *e) {
            dispatch_sync(dispatch_get_main_queue(), ^
            {
                NSRunAlertPanel(@"Error", [@"Sorry an unrecoverable error occured. Please open a ticket at github with the song information." stringByAppendingString:e.description], @"OK", nil, nil);
            });
			exit(1);
		}

		if (self.running) {
			dispatch_sync(dispatch_get_main_queue(), ^{
				self.finishInfo = [NSString stringWithFormat:@"[succ: %i fail: %i skip: %i]", succ, fail, skip];

				[self.window setContentView:self.view3];
			});
		}
	});
}

- (IBAction)cancel:(id)sender {
	self.running = NO;
	[self.window setContentView:self.view1];

}

- (IBAction)thanks:(id)sender {
	self.running = NO;
	[self.window setContentView:self.view1];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	self.fetchers = [NSMutableArray arrayWithArray:@[
                                                     [WikiaFetcher new],
                                                     [MetroFetcher new],
                                                     [Lyricsn7plFetcher new],
                                                     [LyrsterFetcher new],
                                                     [LyricsmodeFetcher new],
                                                     [MusixmatchFetcher new],
                                                     [GeniusFetcher new],
                                                     [SonglyricsFetcher new],
                                                     [ElyricsFetcher new],
                                                     [AzlyricsFetcher new],
                                                     [MusixmatchFetcher new],
													 [LyricsmaniaFetcher new] // blocks after a while ;(
												 ]];



	[self.window setContentView:self.view1];

	iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
	self.playlists = [[(iTunes.sources)[0] userPlaylists] arrayByApplyingSelector:@selector(name)];
	self.ignoreWithLyrics = 1;
	 

#ifdef DEBUG
	for (LyricsFetcher *fetcher in self.fetchers)
	{
		{
            NSLog(@"\n\n");
            NSLog(fetcher.className);
            NSLog(@"\n\n");
            NSString *l0 = [[fetcher fetchLyricsForArtist:@"Metallica"
                                                    album:@""
                                                    title:@"Fuel"] lowercaseString];


            assert(l0 && [l0 rangeOfString:@"=="].location == NSNotFound);
            assert(l0 && [l0 rangeOfString:@"gasoline"].location != NSNotFound);
            assert([[l0 componentsSeparatedByString:@"\n"] count] > 5);
            NSLog([l0 substringToIndex:100]);

            NSString *l1 = [[fetcher fetchLyricsForArtist:@"Rammstein"
                                             album:@""
                                             title:@"Du Hast"] lowercaseString];


            assert(l1 && [l1 rangeOfString:@"=="].location == NSNotFound);
            assert(l1 && [l1 rangeOfString:@"gefragt"].location != NSNotFound);
            assert([[l1 componentsSeparatedByString:@"\n"] count] > 5);
            NSLog([l1 substringToIndex:100]);

			NSString *l2 = [[fetcher fetchLyricsForArtist:@"Garbage"
											 album:@""
											 title:@"As Heaven Is Wide"] lowercaseString];

			assert(l2 && [l2 rangeOfString:@"=="].location == NSNotFound);
			assert(l2 && [l2 rangeOfString:@"angels"].location != NSNotFound);
			assert([[l2 componentsSeparatedByString:@"\n"] count] > 5);
			NSLog([l2 substringToIndex:100]);
		}

        {
            NSString *l3 = [fetcher fetchLyricsForArtist:@"mondayssuck"
                                                   album:@""
                                                   title:@"garfieldrocksthefloor"];

            assert(!l3);
        }
	}
#endif
}
@end


int main(int argc, char *argv[]) {
	return NSApplicationMain(argc, (const char **)argv);
}
