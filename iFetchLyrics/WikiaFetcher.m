//
//  WikiaFetcher.m
//  iFetchLyrics
//
//  Public Domain
//

#import "WikiaFetcher.h"

@implementation WikiaFetcher


- (NSString *)fetchLyricsForArtist:(NSString *)artist album:(NSString *)album title:(NSString *)title {
	//NSLog(@" artist %@ album %@ title %@", artist, album, title);
	artist = [artist stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	title = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	NSString *result = nil;


	result = [self  _fetchLyricsForArtist:artist album:album title:title];
	if (result) return result;


	while ([self replaceLastRoundBracketed:title])
	{
		title = [self replaceLastRoundBracketed:title];

		result = [self  _fetchLyricsForArtist:artist album:album title:title];
		if (result)
			return result;
	}

	while ([self replaceLastSquareBracketed:title])
	{
		title = [self replaceLastSquareBracketed:title];

		result = [self  _fetchLyricsForArtist:artist album:album title:title];
		if (result)
			return result;
	}


	//	NSString *u =	[[NSString stringWithFormat:@"http://lyrics.wikia.com/Special:Search?ns0=1&ns220=1&search=%@ %@", artist, title] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	//	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:u]];

	return nil;
}

- (NSString *)_fetchLyricsForArtist:(NSString *)artist album:(NSString *)album title:(NSString *)title {
	sleep(1);
	NSString *urlStr = [[[NSString stringWithFormat:@"http://lyrics.wikia.com/%@:%@", artist, title] stringByReplacingOccurrencesOfString:@" " withString:@"_"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

	NSURL *url = [NSURL URLWithString:urlStr];
	NSString *cont = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:NULL];
	if ([cont rangeOfString:@"<div class='lyricbox'>"].location == NSNotFound)
	{
		return nil;
	}

	NSString *newline = [cont stringByReplacingOccurrencesOfString:@"<br />" withString:@"XYZNEWLINE"];
	NSString *start = [[newline componentsSeparatedByString:@"<div class='lyricbox'>"] objectAtIndex:1];
	NSString *start2 = [[start componentsSeparatedByString:@"</div>"] objectAtIndex:1];
	NSString *end = [[start2 componentsSeparatedByString:@"<div class='rtMatcher'>"] objectAtIndex:0];
	NSString *final = [end stringByConvertingHTMLToPlainText];
	NSString *final2 = [final stringByReplacingOccurrencesOfString:@"XYZNEWLINE" withString:@"\n"];


	return final2;
}
@end