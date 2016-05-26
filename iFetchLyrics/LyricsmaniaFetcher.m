//
//  LyricsmaniaFetcher.m
//  iFetchLyrics
//
//  Public Domain
//

#import "LyricsmaniaFetcher.h"

@implementation LyricsmaniaFetcher

- (NSString *)__fetchLyricsForArtist:(NSString *)artist album:(NSString *)album title:(NSString *)title {
	sleep(RandomFloatBetween(0.5,2.5));

	if ([[artist lowercaseString] hasPrefix:@"the "])
		artist = [[artist substringFromIndex:4] stringByAppendingString:@" the"];

	NSString *urlStr = [NSString stringWithFormat:@"http://www.lyricsmania.com/%@_lyrics_%@.html", title, artist];
	urlStr = [urlStr stringByReplacingOccurrencesOfString:@" " withString:@"_"];
	urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	urlStr = [urlStr stringByReplacingOccurrencesOfString:@"?" withString:@"%3F"];
	urlStr = [urlStr lowercaseString];

	NSURL *url = [NSURL URLWithString:urlStr];
	NSString *cont = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:NULL];


	if ([cont rangeOfString:@"<div class=\"fb-quotable\">"].location == NSNotFound) {
		return nil;
	}


	@try {
		NSString *newline = [cont stringByReplacingOccurrencesOfString:@"<br>" withString:@"XYZNEWLINE"];
		newline = [newline stringByReplacingOccurrencesOfString:@"<br />" withString:@"XYZNEWLINE"];
		NSArray *comp = [newline componentsSeparatedByString:@"<div class=\"fb-quotable\">"];
		NSString *start = comp[1];


		NSString *end = [start componentsSeparatedByString:@"<script"][0];



		NSString *final = [end stringByConvertingHTMLToPlainText];

		NSMutableString *tmp = [NSMutableString new];
		for (NSString *line in [final componentsSeparatedByString:@"XYZNEWLINE"]) {

			if ([line rangeOfString:@"(Thanks to "].location == NSNotFound)
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
