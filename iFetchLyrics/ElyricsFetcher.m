//
//  ElyricsFetcher.m
//  iFetchLyrics
//
//  Public Domain
//

#import "ElyricsFetcher.h"

@implementation ElyricsFetcher

- (NSString *)__fetchLyricsForArtist:(NSString *)artist album:(NSString *)album title:(NSString *)title {
	sleep(RandomFloatBetween(0.5,1.5));

	if ([[artist lowercaseString] hasPrefix:@"the "])
		artist = [artist substringFromIndex:4];

    if (!artist.length)
        return nil;
    
	NSString *urlStr = [NSString stringWithFormat:@"http://www.elyrics.net/read/%@/%@-lyrics/%@-lyrics.html", [artist substringToIndex:1], artist, title];
	urlStr = [urlStr stringByReplacingOccurrencesOfString:@" " withString:@"-"];
	urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
	urlStr = [urlStr stringByReplacingOccurrencesOfString:@"?" withString:@"%3F"];
	urlStr = [urlStr lowercaseString];

	NSURL *url = [NSURL URLWithString:urlStr];
	NSString *cont = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:NULL];


	if ([cont rangeOfString:@"<div class='ly' id='lyr'>"].location == NSNotFound) {
		return nil;
	}


	@try {
		NSString *newline = [cont stringByReplacingOccurrencesOfString:@"<br>" withString:@"XYZNEWLINE"];
		NSArray *comp = [newline componentsSeparatedByString:@"<div class='ly' id='lyr'>"];
		NSString *start = comp[1];
		start = [start componentsSeparatedByString:@"<div id='inlyr'"][1];
		start = [start componentsSeparatedByString:@">"][1];

		NSString *end = [start componentsSeparatedByString:@"</div>"][0];

		end = [end stringByReplacingOccurrencesOfString:@"<p>" withString:@"XYZNEWLINE"];
		end = [end stringByReplacingOccurrencesOfString:@"</p>" withString:@"XYZNEWLINE"];

		NSString *final = [end stringByConvertingHTMLToPlainText];
		final = [final stringByReplacingOccurrencesOfString:@"Correct these lyrics" withString:@""];

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
