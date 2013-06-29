//
//  LyricsallFetcher.m
//  iFetchLyrics
//
//  Public Domain
//

#import "LyricsallFetcher.h"

@implementation LyricsallFetcher

// 39% succ 4315 fail 6740
- (NSString *)_fetchLyricsForArtist:(NSString *)artist album:(NSString *)album title:(NSString *)title {
	sleep(RandomFloatBetween(0.5,1.5));
	NSString *urlStr = [[[NSString stringWithFormat:@"http://lyricsall.com/%@_-_%@", artist, title] stringByReplacingOccurrencesOfString:@" " withString:@"_"] lowercaseString];

	if ([urlStr length] > 56)
		urlStr = [urlStr substringToIndex:56];

	urlStr = [[urlStr stringByAppendingString:@".html"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

	NSURL *url = [NSURL URLWithString:urlStr];
	NSString *cont = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:NULL];
	if ([cont rangeOfString:@"class=\"lyrictext\">"].location == NSNotFound) {
		return nil;
	}

	@try {
		NSString *newline = [cont stringByReplacingOccurrencesOfString:@"<br>" withString:@"XYZNEWLINE"];
		NSString *start = [newline componentsSeparatedByString:@"class=\"lyrictext\">"][1];
		NSString *end = [start componentsSeparatedByString:@"class=\"headlinelyric\""][0];
		NSString *final = [end stringByConvertingHTMLToPlainText];


		NSMutableString *tmp = [NSMutableString new];
		for (NSString *line in [final componentsSeparatedByString:@"XYZNEWLINE"]) {

			[tmp appendString:[line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
			[tmp appendString:@"\n"];
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