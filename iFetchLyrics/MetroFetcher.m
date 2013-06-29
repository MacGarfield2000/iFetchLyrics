//
//  MetroFetcher.m
//  iFetchLyrics
//
//  Public Domain
//

#import "MetroFetcher.h"

@implementation MetroFetcher

// 47% succ 5200 fail 5800
- (NSString *)_fetchLyricsForArtist:(NSString *)artist album:(NSString *)album title:(NSString *)title {
	sleep(RandomFloatBetween(0.5,1.5));
	NSString *urlStr = [[[[NSString stringWithFormat:@"http://www.metrolyrics.com/%@-lyrics-%@.html", title, artist] stringByReplacingOccurrencesOfString:@" " withString:@"-"] lowercaseString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

	NSURL *url = [NSURL URLWithString:urlStr];
	NSString *cont = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:NULL];
	if ([cont rangeOfString:@"<div id=\"lyrics-body\">"].location == NSNotFound || [cont rangeOfString:@"Unfortunately, we don't have the lyrics"].location != NSNotFound) {
		return nil;
	}

	@try {
		NSString *newline = [cont stringByReplacingOccurrencesOfString:@"</span>" withString:@"XYZNEWLINE"];
		NSString *start = [newline componentsSeparatedByString:@"<div id=\"lyrics-body\">"][1];
		NSString *start2 = [start componentsSeparatedByString:@"<link"][1];
		NSString *start3 = [start2 substringFromIndex:[start2 rangeOfString:@"/>"].location+2];
		NSString *end = [start3 componentsSeparatedByString:@"<link"][0];
		NSString *final = [end stringByConvertingHTMLToPlainText];


		NSMutableString *tmp = [NSMutableString new];
		BOOL skipNext = FALSE;
		for (NSString *line in [final componentsSeparatedByString:@"XYZNEWLINE"]) {
			if ([line rangeOfString:@"http://www.metrolyrics.com/"].location == NSNotFound) {
				if (skipNext) {
					skipNext = FALSE;
				}
				else {
					[tmp appendString:[line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
					[tmp appendString:@"\n"];
				}
			}
			else
				skipNext = TRUE;
		}

		NSString *final2 = [tmp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

		if ([final2 length] == 0)
			return nil;

		return final2;

	} @catch (id e) {
		return nil;
	}
}
@end