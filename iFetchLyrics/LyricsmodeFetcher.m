//
//  LyricsmodeFetcher.m
//  iFetchLyrics
//
//  Public Domain
//

#import "LyricsmodeFetcher.h"

@implementation LyricsmodeFetcher

- (NSString *)__fetchLyricsForArtist:(NSString *)artist album:(NSString *)album title:(NSString *)title {
	sleep(RandomFloatBetween(0.5,1.5));
	if ([[artist lowercaseString] hasPrefix:@"the "])
		artist = [artist substringFromIndex:4];
	NSString *urlStr = [NSString stringWithFormat:@"http://www.lyricsmode.com/lyrics/%@/%@/%@.html", [artist substringToIndex:1], artist, title];
	urlStr = [urlStr stringByReplacingOccurrencesOfString:@" " withString:@"_"];
	urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	urlStr = [urlStr stringByReplacingOccurrencesOfString:@"?" withString:@"%3F"];
	urlStr = [urlStr lowercaseString];

	NSURL *url = [NSURL URLWithString:urlStr];
	NSString *cont = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:NULL];


	if ([cont rangeOfString:@"<p id=\"lyrics_text\" class=\"ui-annotatable\">"].location == NSNotFound) {
		return nil;
	}


	@try {
		NSString *newline = [cont stringByReplacingOccurrencesOfString:@"<br />" withString:@"XYZNEWLINE"];
		NSArray *comp = [newline componentsSeparatedByString:@"<p id=\"lyrics_text\" class=\"ui-annotatable\">"];
		NSString *start = comp[1];
		NSString *end = [start componentsSeparatedByString:@"</p>"][0];
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
