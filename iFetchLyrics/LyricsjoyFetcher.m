//
//  LyricsjoyFetcher.m
//  iFetchLyrics
//
//  Public Domain
//

#import "LyricsjoyFetcher.h"

@implementation LyricsjoyFetcher

// 64% succ 7133 fail 4100
- (NSString *)_fetchLyricsForArtist:(NSString *)artist album:(NSString *)album title:(NSString *)title {
	sleep(RandomFloatBetween(0.5,1.5));
	title = [title stringByReplacingOccurrencesOfString:@"  " withString:@" "];
	title = [title stringByReplacingOccurrencesOfString:@"  " withString:@" "];
	NSString *urlStr = [[[NSString stringWithFormat:@"http://www.lyricsjoy.com/%@/%@/", artist, title] stringByReplacingOccurrencesOfString:@" " withString:@"_"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

	NSURL *url = [NSURL URLWithString:urlStr];
	NSString *cont = [[NSString alloc] initWithContentsOfURL:url encoding:NSASCIIStringEncoding error:NULL];

	if ([cont rangeOfString:@"<div id=\"lyrics-scroll\">"].location == NSNotFound) {
		return nil;
	}

	@try {
		NSString *newline = [cont stringByReplacingOccurrencesOfString:@"</p><p>" withString:@"XYZNEWLINE"];
		NSString *start = [newline componentsSeparatedByString:@"<div id=\"lyrics-scroll\">"][1];
		NSString *end = [start componentsSeparatedByString:@"</div>"][0];
		NSString *final = [end stringByConvertingHTMLToPlainText];
		NSString *final2 = [final stringByReplacingOccurrencesOfString:@"XYZNEWLINE" withString:@"\n"];
		final2 = [final2 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

		if ([final2 length] == 0)
			return nil;

		if ([final2 rangeOfString:@"Instrumental" options:NSCaseInsensitiveSearch].location != NSNotFound && [final2 length] < 16)
			return @"[Instrumental]";
		
		return final2;
	} @catch (id e) {
		return nil;
	}
}
@end