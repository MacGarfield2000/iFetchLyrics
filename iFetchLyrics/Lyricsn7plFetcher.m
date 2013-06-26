//
//  Lyricsn7plFetcher.m
//  iFetchLyrics
//
//  Public Domain
//

#import "Lyricsn7plFetcher.h"

@implementation Lyricsn7plFetcher


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
	NSString *urlStr = [[[[NSString stringWithFormat:@"http://www.lyrics.n7.pl/artists/%@/%@/%@/", [artist substringToIndex:1], artist, title] stringByReplacingOccurrencesOfString:@" " withString:@""] lowercaseString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

	NSURL *url = [NSURL URLWithString:urlStr];
	NSError *err;
	NSString *cont = [[NSString alloc] initWithContentsOfURL:url encoding:NSISOLatin1StringEncoding error:&err];
	if ([cont rangeOfString:@"Lyrics:<br><br><div class=\"tekst\">"].location == NSNotFound)
	{
		return nil;
	}

	NSString *newline = [cont stringByReplacingOccurrencesOfString:@"<br>" withString:@"XYZNEWLINE"];
	NSString *start = [[newline componentsSeparatedByString:@"Lyrics:XYZNEWLINEXYZNEWLINE<div class=\"tekst\">"] objectAtIndex:1];
	NSString *end = [[start componentsSeparatedByString:@"</div>"] objectAtIndex:0];
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