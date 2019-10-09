//
//  SonglyricsFetcher.m
//  iFetchLyrics
//
//  Public Domain
//

#import "SonglyricsFetcher.h"

@implementation SonglyricsFetcher

- (NSString *)__fetchLyricsForArtist:(NSString *)artist album:(NSString *)album title:(NSString *)title {
	sleep(RandomFloatBetween(0.5,1.5));


	NSString *urlStr = [NSString stringWithFormat:@"http://www.songlyrics.com/%@/%@-lyrics/", artist, title];
	urlStr = [urlStr stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
	urlStr = [urlStr stringByReplacingOccurrencesOfString:@"?" withString:@"%3F"];
	urlStr = [urlStr lowercaseString];

	NSURL *url = [NSURL URLWithString:urlStr];
	NSString *cont = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:NULL];


	if ([cont rangeOfString:@"<div id=\"songLyricsDiv-outer\">"].location == NSNotFound) {
		return nil;
	}


	@try {
		NSString *newline = [cont stringByReplacingOccurrencesOfString:@"<br />" withString:@"XYZNEWLINE"];
		NSArray *comp = [newline componentsSeparatedByString:@"<div id=\"songLyricsDiv-outer\">"];
		NSString *start = comp[1];


		NSString *end = [start componentsSeparatedByString:@"</div>"][0];

		end = [end stringByReplacingOccurrencesOfString:@"<p>" withString:@"XYZNEWLINE"];
		end = [end stringByReplacingOccurrencesOfString:@"</p>" withString:@"XYZNEWLINE"];

		if ([end rangeOfString:@">Sorry, we have no "].location != NSNotFound || [end rangeOfString:@">We do not have the"].location != NSNotFound)
			return nil;
		
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
