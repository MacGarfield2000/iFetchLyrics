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
		NSString *newline = [cont stringByReplacingOccurrencesOfString:@"<br/>" withString:@"XYZNEWLINE"];
		NSString *start = [newline substringFromIndex:[newline rangeOfString:@"<p class='verse'>"].location+17];
		NSString *end = [start componentsSeparatedByString:@"</div>"][0];
		NSString *final = [end stringByReplacingOccurrencesOfString:@"<p class='verse'>" withString:@"XYZNEWLINE"];
		NSString *final1 = [final stringByReplacingOccurrencesOfString:@"</p>" withString:@"XYZNEWLINE"];
		NSString *final2 = [final1 stringByConvertingHTMLToPlainText];


		NSMutableString *tmp = [NSMutableString new];
		for (NSString *line in [final2 componentsSeparatedByString:@"XYZNEWLINE"]) {
			[tmp appendString:[line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
			[tmp appendString:@"\n"];
		}

		NSString *final3 = [tmp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

		if ([final3 length] == 0)
			return nil;

		return final3;

	} @catch (id e) {
		return nil;
	}
}
@end