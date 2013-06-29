//
//  LyricstimeFetcher.m
//  iFetchLyrics
//
//  Public Domain
//

#import "LyricstimeFetcher.h"

@implementation LyricstimeFetcher

- (NSString *)_fetchLyricsForArtist:(NSString *)artist album:(NSString *)album title:(NSString *)title {
	sleep(RandomFloatBetween(5.0,15.0));
	title = [title stringByReplacingOccurrencesOfString:@"(" withString:@""];
	title = [title stringByReplacingOccurrencesOfString:@")" withString:@""];
	title = [title stringByReplacingOccurrencesOfString:@"&" withString:@""];
	title = [title stringByReplacingOccurrencesOfString:@"'" withString:@""];
	title = [title stringByReplacingOccurrencesOfString:@"  " withString:@" "];
	title = [title stringByReplacingOccurrencesOfString:@"  " withString:@" "];
	NSString *urlStr = [[[NSString stringWithFormat:@"http://www.lyricstime.com/%@-%@-lyrics.html", artist, title] stringByReplacingOccurrencesOfString:@" " withString:@"-"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

	NSURL *url = [NSURL URLWithString:urlStr];
	NSString *cont = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:NULL];
	if ([cont rangeOfString:@"<div id=\"songlyrics\""].location == NSNotFound) {
		return nil;
	}

	@try {
		NSString *newline = [cont stringByReplacingOccurrencesOfString:@"<br />" withString:@"XYZNEWLINE"];
		NSString *start = [newline componentsSeparatedByString:@"<div id=\"lyrics\">"][1];
		start = [start componentsSeparatedByString:@">"][1];
		NSString *end = [start componentsSeparatedByString:@"</div>"][0];
		NSString *final = [end stringByConvertingHTMLToPlainText];
		NSString *final2 = [final stringByReplacingOccurrencesOfString:@"XYZNEWLINE" withString:@"\n"];
		final2 = [final2 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

		if ([final2 length] == 0)
			return nil;


		return final2;
	} @catch (id e) {
		return nil;
	}
}
@end