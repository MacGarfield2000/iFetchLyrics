//
//  BeelyricsFetcher.m
//  iFetchLyrics
//
//  Public Domain
//

#import "BeelyricsFetcher.h"

@implementation BeelyricsFetcher

- (NSString *)__fetchLyricsForArtist:(NSString *)artist album:(NSString *)album title:(NSString *)title {
	sleep(RandomFloatBetween(5.0,15.0));
	title = [title stringByReplacingOccurrencesOfString:@"(" withString:@""];
	title = [title stringByReplacingOccurrencesOfString:@")" withString:@""];
	title = [title stringByReplacingOccurrencesOfString:@"  " withString:@" "];
	title = [title stringByReplacingOccurrencesOfString:@"  " withString:@" "];
	NSString *urlStr = [[[NSString stringWithFormat:@"http://www.beelyrics.com/%@/%@/%@.html", [artist substringToIndex:1].lowercaseString, artist.lowercaseString, title.lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@"-"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSString *searchstr = [NSString stringWithFormat:@"<a href=\"/%@/%@\">", [artist substringToIndex:1].lowercaseString, artist.lowercaseString];
	NSURL *url = [NSURL URLWithString:urlStr];
	NSString *cont = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:NULL];
	if ([cont rangeOfString:searchstr].location == NSNotFound) {
		return nil;
	}

	@try {
		NSString *newline = [cont stringByReplacingOccurrencesOfString:@"<br />" withString:@"XYZNEWLINE"];
		NSString *start = [newline componentsSeparatedByString:searchstr][1];
        NSString *start2 = [start componentsSeparatedByString:@"<p>"][1];
		NSString *end = [start2 componentsSeparatedByString:@"</p>"][0];
		NSString *final = [end stringByConvertingHTMLToPlainText];
        
        NSMutableString *tmp = [NSMutableString new];
        for (NSString *line in [final componentsSeparatedByString:@"XYZNEWLINE"]) {
            [tmp appendString:[line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
            [tmp appendString:@"\n"];
        }
        
        NSString *final3 = [tmp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

  
        
		if ([final3 length] == 0)
			return nil;


		return final3;
	} @catch (id e) {
		return nil;
	}
}
@end
