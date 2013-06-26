//
//  MetroFetcher.m
//  iFetchLyrics
//
//  Public Domain
//

#import "MetroFetcher.h"

@implementation MetroFetcher


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

	return nil;
}

- (NSString *)_fetchLyricsForArtist:(NSString *)artist album:(NSString *)album title:(NSString *)title {
	sleep(1);
	NSString *urlStr = [[[[NSString stringWithFormat:@"http://www.metrolyrics.com/%@-lyrics-%@.html", title, artist] stringByReplacingOccurrencesOfString:@" " withString:@"-"] lowercaseString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

	NSURL *url = [NSURL URLWithString:urlStr];
	NSString *cont = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:NULL];
	if ([cont rangeOfString:@"<div id=\"lyrics-body\">"].location == NSNotFound)
	{
		return nil;
	}

	NSString *newline = [cont stringByReplacingOccurrencesOfString:@"</span>" withString:@"XYZNEWLINE"];
	NSString *start = [[newline componentsSeparatedByString:@"<div id=\"lyrics-body\">"] objectAtIndex:1];
	NSString *start2 = [[start componentsSeparatedByString:@"<link"] objectAtIndex:1];
	NSString *start3 = [start2 substringFromIndex:[start2 rangeOfString:@"/>"].location+2];
	NSString *end = [[start3 componentsSeparatedByString:@"<link"] objectAtIndex:0];
	NSString *final = [end stringByConvertingHTMLToPlainText];

	NSMutableString *tmp = [NSMutableString new];
	BOOL skipNext = FALSE;
	for (NSString *line in [final componentsSeparatedByString:@"XYZNEWLINE"])
	{
		if ([line rangeOfString:@"http://www.metrolyrics.com/"].location == NSNotFound)
		{
			if (skipNext)
			{
				skipNext = FALSE;
			}
			else
			{
				[tmp appendString:[line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
				[tmp appendString:@"\n"];
			}
		}
		else
			skipNext = TRUE;
	}

	return tmp;
}
@end