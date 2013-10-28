//
//  LyricsFetcher.m
//  iFetchLyrics
//
//  Public Domain
//

#import "LyricsFetcher.h"

@implementation LyricsFetcher

- (NSString *)_fetchLyricsForArtist:(NSString *)artist album:(NSString *)album title:(NSString *)title {
	[[NSException exceptionWithName:@"bad" reason:@"exp" userInfo:nil] raise];
	return nil;
}

- (NSString *)fetchLyricsForArtist:(NSString *)artist album:(NSString *)album title:(NSString *)title {
	//NSLog(@" artist %@ album %@ title %@", artist, album, title);
	artist = [artist stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	title = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

	if ([[artist lowercaseString] isEqualToString:@"various artists"] && [title rangeOfString:@" - "].location != NSNotFound) {
		artist = [title componentsSeparatedByString:@" - "][0];
		title = [title componentsSeparatedByString:@" - "][1];
	}
	NSString *result = nil;


	result = [self  _fetchLyricsForArtist:artist album:album title:title];
	if (result)
		return result;


	while ([self replaceLastRoundBracketed:title]) {
		title = [self replaceLastRoundBracketed:title];

		result = [self  _fetchLyricsForArtist:artist album:album title:title];
		if (result)
			return result;
	}

	while ([self replaceLastSquareBracketed:title]) {
		title = [self replaceLastSquareBracketed:title];

		result = [self  _fetchLyricsForArtist:artist album:album title:title];
		if (result)
			return result;
	}

	return nil;
}

- (NSString *)replaceLastRoundBracketed:(NSString *)title {
	if ([title rangeOfString:@"("].location != NSNotFound &&
		[title rangeOfString:@")"].location != NSNotFound &&
		[title rangeOfString:@"("].location < [title rangeOfString:@")"].location)
		return [title substringToIndex:[title rangeOfString:@"(" options:NSBackwardsSearch].location];
	else
		return nil;
}

- (NSString *)replaceLastSquareBracketed:(NSString *)title {
	if ([title rangeOfString:@"["].location != NSNotFound &&
		[title rangeOfString:@"]"].location != NSNotFound &&
		[title rangeOfString:@"["].location < [title rangeOfString:@"]"].location)
		return [title substringToIndex:[title rangeOfString:@"[" options:NSBackwardsSearch].location];
	else
		return nil;
}
@end