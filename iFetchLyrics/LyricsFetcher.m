//
//  LyricsFetcher.m
//  iFetchLyrics
//
//  Public Domain
//

#import "LyricsFetcher.h"

@implementation LyricsFetcher

- (NSString *)__fetchLyricsForArtist:(NSString *)artist album:(NSString *)album title:(NSString *)title {
	[[NSException exceptionWithName:@"bad" reason:@"exp" userInfo:nil] raise];
	return nil;
}

- (NSString *)_fetchLyricsForArtist:(NSString *)artist album:(NSString *)album title:(NSString *)title {
	NSString *lyrics = [self __fetchLyricsForArtist:artist album:album title:title];

	if (!lyrics && ![lyrics length])
		return nil;

	if ([lyrics length] / [[lyrics componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] count] > 200)
	{
		NSLog([NSString stringWithFormat:@"Warning: ignoring lyrics for artist '%@' and title '%@' from fetcher '%@' for lack of linebreaks.", artist, title, [self className]]);
		return nil;
	}

//	assert([lyrics rangeOfString:@"license"].location == NSNotFound);
//	assert([lyrics rangeOfString:@"Download"].location == NSNotFound);

	return lyrics;
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

	result = [self _fetchLyricsForArtist:artist album:album title:title];
	if (result)
		return result;

	if ([title rangeOfString:@" & "].location != NSNotFound) {
		result = [self _fetchLyricsForArtist:artist album:album title:[title stringByReplacingOccurrencesOfString:@" & " withString:@" and "]];
		if (result)
			return result;
	}

	
	while ([self replaceLastRoundBracketed:title]) {
		title = [self replaceLastRoundBracketed:title];

		result = [self _fetchLyricsForArtist:artist album:album title:title];
		if (result)
			return result;
	}

	if ([title rangeOfString:@" & "].location != NSNotFound) {
		result = [self _fetchLyricsForArtist:artist album:album title:[title stringByReplacingOccurrencesOfString:@" & " withString:@" and "]];
		if (result)
			return result;
	}

	while ([self replaceLastSquareBracketed:title]) {
		title = [self replaceLastSquareBracketed:title];

		result = [self _fetchLyricsForArtist:artist album:album title:title];
		if (result)
			return result;
	}

	if ([title rangeOfString:@" & "].location != NSNotFound) {
		result = [self _fetchLyricsForArtist:artist album:album title:[title stringByReplacingOccurrencesOfString:@" & " withString:@" and "]];
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
