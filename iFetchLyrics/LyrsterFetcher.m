//
//  LyrsterFetcher.m
//  iFetchLyrics
//
//  Public Domain
//

#import "LyrsterFetcher.h"

@implementation LyrsterFetcher

// 60% succ 6787 fail 4445
- (NSString *)_fetchLyricsForArtist:(NSString *)artist album:(NSString *)album title:(NSString *)title {
	sleep(RandomFloatBetween(0.5,1.5));
	title = [title stringByReplacingOccurrencesOfString:@"(" withString:@""];
	title = [title stringByReplacingOccurrencesOfString:@")" withString:@""];
	title = [title stringByReplacingOccurrencesOfString:@"&" withString:@""];
	title = [title stringByReplacingOccurrencesOfString:@"  " withString:@" "];
	title = [title stringByReplacingOccurrencesOfString:@"  " withString:@" "];
	NSString *urlStr = [[[[NSString stringWithFormat:@"http://www.lyrster.com/lyrics/%@-lyrics-%@.html", title, artist] stringByReplacingOccurrencesOfString:@" " withString:@"-"] lowercaseString]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

	NSURL *url = [NSURL URLWithString:urlStr];
	NSString *cont = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:NULL];
	if ([cont rangeOfString:@"<div id=\"lyrics\">"].location == NSNotFound) {
		return nil;
	}

	@try {
		NSString *newline = [cont stringByReplacingOccurrencesOfString:@"<br />" withString:@"XYZNEWLINE"];
		NSString *start = [newline componentsSeparatedByString:@"<div id=\"lyrics\">"][1];
		NSString *end = [start componentsSeparatedByString:@"</div>"][0];
		NSString *final = [end stringByConvertingHTMLToPlainText];
		NSString *final2 = [final stringByReplacingOccurrencesOfString:@"XYZNEWLINE" withString:@"\n"];
		final2 = [final2 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

		if ([final2 length] == 0)
			return nil;

		if ([final2 rangeOfString:@"do not have the complete song"].location != NSNotFound)
			return nil;

		return final2;
	} @catch (id e) {
		return nil;
	}
}
@end