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
    
    if (!artist.length)
        return nil;
    
	NSString *urlStr = [NSString stringWithFormat:@"http://www.lyricsmode.com/lyrics/%@/%@/%@.html", [artist substringToIndex:1], artist, title];
	urlStr = [urlStr stringByReplacingOccurrencesOfString:@" " withString:@"_"];
	urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
	urlStr = [urlStr stringByReplacingOccurrencesOfString:@"?" withString:@"%3F"];
	urlStr = [urlStr lowercaseString];

	NSURL *url = [NSURL URLWithString:urlStr];
	NSString *cont = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:NULL];


	if ([cont rangeOfString:@"id=\"lyrics_text\""].location == NSNotFound) {
		return nil;
	}


	@try {
		NSString *newline = [cont stringByReplacingOccurrencesOfString:@"<br />" withString:@"XYZNEWLINE"];
		NSArray *comp = [newline componentsSeparatedByString:@"id=\"lyrics_text\""];
		NSString *start = comp[1];
        start = [start componentsSeparatedByString:@"relative;\">"][1];
		NSString *end = [start componentsSeparatedByString:@"</p>"][0];
        end = [end stringByReplacingOccurrencesOfString:@"data-annotation-type=\"explain\">Explain</a>" withString:@"></a>"];
        end = [end stringByReplacingOccurrencesOfString:@"data-annotation-type=\"request\">Request</a>" withString:@"></a>"];
        end = [end stringByReplacingOccurrencesOfString:@"×" withString:@""];
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
