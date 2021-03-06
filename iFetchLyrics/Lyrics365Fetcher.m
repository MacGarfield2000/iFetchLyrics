//
//  Lyrics365Fetcher.m
//  iFetchLyrics
//
//  Public Domain
//

#import "Lyrics365Fetcher.h"

@implementation Lyrics365Fetcher

- (NSString *)__fetchLyricsForArtist:(NSString *)artist album:(NSString *)album title:(NSString *)title {
	sleep(RandomFloatBetween(0.5,1.5));


	NSString *urlStr = [NSString stringWithFormat:@"http://www.lyrics365.net/%@-%@-lyrics.html", artist, title];
	urlStr = [urlStr stringByReplacingOccurrencesOfString:@" " withString:@"-"];
	urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	urlStr = [urlStr stringByReplacingOccurrencesOfString:@"?" withString:@"%3F"];
	urlStr = [urlStr lowercaseString];

	NSURL *url = [NSURL URLWithString:urlStr];
	NSString *cont = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:NULL];


	if ([cont rangeOfString:@"<div id=\"post-content\">"].location == NSNotFound) {
		return nil;
	}


	@try {
		NSString *newline = [cont stringByReplacingOccurrencesOfString:@"<br />" withString:@"XYZNEWLINE"];
		NSArray *comp = [newline componentsSeparatedByString:@"<div id=\"post-content\">"];
		NSString *start = comp[1];


		NSString *end = [start componentsSeparatedByString:@"<div"][0];

		end = [end stringByReplacingOccurrencesOfString:@"<p>" withString:@"XYZNEWLINE"];
		end = [end stringByReplacingOccurrencesOfString:@"</p>" withString:@"XYZNEWLINE"];

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
