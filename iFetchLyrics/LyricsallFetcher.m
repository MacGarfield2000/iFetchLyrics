//
//  LyricsallFetcher.m
//  iFetchLyrics
//
//  Public Domain
//

#import "LyricsallFetcher.h"

@implementation LyricsallFetcher


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
	NSString *urlStr = [[[[NSString stringWithFormat:@"http://lyricsall.com/%@_-_%@.html", artist, title] stringByReplacingOccurrencesOfString:@" " withString:@"_"] lowercaseString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

	NSURL *url = [NSURL URLWithString:urlStr];
	NSString *cont = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:NULL];
	if ([cont rangeOfString:@"class=\"lyrictext\">"].location == NSNotFound)
	{
		return nil;
	}

	NSString *newline = [cont stringByReplacingOccurrencesOfString:@"<br>" withString:@"XYZNEWLINE"];
	NSString *start = [[newline componentsSeparatedByString:@"class=\"lyrictext\">"] objectAtIndex:1];
	NSString *end = [[start componentsSeparatedByString:@"class=\"headlinelyric\""] objectAtIndex:0];
	NSString *final = [end stringByConvertingHTMLToPlainText];


	NSMutableString *tmp = [NSMutableString new];
	for (NSString *line in [final componentsSeparatedByString:@"XYZNEWLINE"])
	{

		[tmp appendString:[line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
		[tmp appendString:@"\n"];
	}

	return [tmp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}
@end