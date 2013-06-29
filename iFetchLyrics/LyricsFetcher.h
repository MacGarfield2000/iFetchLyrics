//
//  LyricsFetcher.h
//  iFetchLyrics
//
//  Public Domain
//


#import "NSString+HTML.h"

@interface LyricsFetcher : NSObject

- (NSString *)fetchLyricsForArtist:(NSString *)artist album:(NSString *)album title:(NSString *)title;

//- (NSString *)replaceLastRoundBracketed:(NSString *)title;
//- (NSString *)replaceLastSquareBracketed:(NSString *)title;

@end
