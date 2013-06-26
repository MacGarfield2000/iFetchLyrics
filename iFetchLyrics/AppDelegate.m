//
//  AppDelegate.m
//  iFetchLyrics
//
//  Public Domain
//

#import "iTunes.h"
#import <ScriptingBridge/ScriptingBridge.h>
#import "AppDelegate.h"
#import "WikiaFetcher.h"
#import "MetroFetcher.h"
#import "LyricsallFetcher.h"
#import "Lyricsn7plFetcher.h"

@interface AppDelegate ()

@property (strong, nonatomic) NSString *currentSongInfo;
@property (strong, nonatomic) NSString *progressInfo1;
@property (strong, nonatomic) NSString *progressInfo2;
@property (strong, nonatomic) NSString *finishInfo;

@property (strong, nonatomic) NSArray *playlists;
@property (assign, nonatomic) int selectedPlaylist;
@property (assign, nonatomic) int ignoreWithLyrics;
@property (assign) BOOL running;
@property (unsafe_unretained) IBOutlet NSView *view1;
@property (unsafe_unretained) IBOutlet NSView *view2;
@property (unsafe_unretained) IBOutlet NSView *view3;

@end

// TODO: variousartists handling
// TODO: improve/more fetchers

@implementation AppDelegate

- (IBAction)fetchLyrics:(id)sender {
	self.running = YES;
	[self.window setContentView:self.view2];

	NSString *playlistName = [self.playlists objectAtIndex:self.selectedPlaylist];
	iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
	iTunesPlaylist *playlist = [[[[iTunes.sources objectAtIndex:0] userPlaylists] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@", playlistName]] objectAtIndex:0];
	SBElementArray *tracks = [playlist tracks];

	dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
	{
		int all = 0, skip = 0, succ = 0, fail = 0;

		for (iTunesTrack *track in tracks)
		{
			if (!self.running)
				break;
			
			all++;
			if (self.ignoreWithLyrics && [track lyrics] && [[track lyrics] length])
			{
				skip++;
				continue;
			}

			NSString *lyrics = nil;
			for (LyricsFetcher *fetcher in self.fetchers)
			{
				lyrics = [fetcher fetchLyricsForArtist:track.artist
														   album:track.album
														   title:track.name];

				dispatch_sync(dispatch_get_main_queue(), ^
				{
					self.currentSongInfo = [NSString stringWithFormat:@"%@ - %@", track.artist, track.name];
					self.progressInfo1 = [NSString stringWithFormat:@"[song %i of %i]", all, [tracks count]];
					self.progressInfo2 = [NSString stringWithFormat:@"[succ: %i fail: %i skip: %i]", succ, fail, skip];
				});
				
				if (lyrics)
				{
					[track setLyrics:lyrics];
					succ++;
					break;
				}
			}

			if (!lyrics)
				fail++;
		}

		if (self.running)
		{
			self.finishInfo = [NSString stringWithFormat:@"[succ: %i fail: %i skip: %i]", succ, fail, skip];

			[self.window setContentView:self.view3];
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
	self.fetchers = @[[LyricsallFetcher new], [WikiaFetcher new], [MetroFetcher new], [Lyricsn7plFetcher new]];

	iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
	self.playlists = [[[iTunes.sources objectAtIndex:0] userPlaylists] arrayByApplyingSelector:@selector(name)];
	self.ignoreWithLyrics = 1;

	[self.window setContentView:self.view1];
}
@end


int main(int argc, char *argv[]) {
	return NSApplicationMain(argc, (const char **)argv);
}