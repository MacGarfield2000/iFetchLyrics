//
//  LyricsallFetcher.m
//  iFetchLyrics
//
//  Public Domain
//

#import "LyricsallFetcher.h"

@implementation LyricsallFetcher

// 39% succ 4315 fail 6740
- (NSString *)__fetchLyricsForArtist:(NSString *)artist album:(NSString *)album title:(NSString *)title {
	sleep(RandomFloatBetween(0.5,1.5));
	NSString *urlStr = [[[NSString stringWithFormat:@"http://lyricsall.com/%@_-_%@", artist, title] stringByReplacingOccurrencesOfString:@" " withString:@"_"] lowercaseString];

	if ([urlStr length] > 56)
		urlStr = [urlStr substringToIndex:56];

	urlStr = [[urlStr stringByAppendingString:@".html"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

	NSURL *url = [NSURL URLWithString:urlStr];
	NSError *err;
	NSString *cont = [[NSString alloc] initWithContentsOfURL:url encoding:NSISOLatin1StringEncoding error:&err];
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
			if ([line rangeOfString:@"function.preg-replace"].location != NSNotFound)
				continue;

			[tmp appendString:[line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
			[tmp appendString:@"\n"];
		}

		NSString *final2 = [tmp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

		final2 = [final2 stringByReplacingOccurrencesOfString:@"Ă¤" withString:@"ä"];
		final2 = [final2 stringByReplacingOccurrencesOfString:@"Ăś" withString:@"ö"];
		final2 = [final2 stringByReplacingOccurrencesOfString:@"Ăź" withString:@"ü"];
		final2 = [final2 stringByReplacingOccurrencesOfString:@"Ă" withString:@"ß"];
		final2 = [final2 stringByReplacingOccurrencesOfString:@"â" withString:@"'"];
		final2 = [final2 stringByReplacingOccurrencesOfString:@"â" withString:@"'"];

		if ([final2 length] == 0)
			return nil;


		if ([final2 hasPrefix:@"Download"])
			return [[[[final2 componentsSeparatedByString:@"\n"] subarrayWithRange:NSMakeRange(1, [[final2 componentsSeparatedByString:@"\n"] count] - 1)] componentsJoinedByString:@"\n"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		else
			return final2;
	} @catch (id e) {
		return nil;
	}
}
@end