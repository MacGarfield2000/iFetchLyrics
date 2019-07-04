//
//  MetroFetcher.m
//  iFetchLyrics
//
//  Public Domain
//

#import "MetroFetcher.h"

@implementation MetroFetcher

// 47% succ 5200 fail 5800
- (NSString *)__fetchLyricsForArtist:(NSString *)artist album:(NSString *)album title:(NSString *)title {
	sleep(RandomFloatBetween(0.5,1.5));
	NSString *urlStr = [[[[NSString stringWithFormat:@"http://www.metrolyrics.com/%@-lyrics-%@.html", title, artist] stringByReplacingOccurrencesOfString:@" " withString:@"-"] lowercaseString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

	NSURL *url = [NSURL URLWithString:urlStr];
	NSString *cont = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:NULL];
	if ([cont rangeOfString:@"<div id=\"lyrics-body-text\""].location == NSNotFound ||
        [cont rangeOfString:@"Unfortunately, we don't have the lyrics"].location != NSNotFound ||
        [cont rangeOfString:@"<p class='verse'>"].location == NSNotFound) {
		return nil;
	}

	@try {
		NSString *newline = [cont stringByReplacingOccurrencesOfString:@"<br/>" withString:@"XYZNEWLINE"];
		NSString *newline2 = [newline stringByReplacingOccurrencesOfString:@"<br>" withString:@"XYZNEWLINE"];
		NSString *start = [newline2 substringFromIndex:[newline2 rangeOfString:@"<p class='verse'>"].location+17];
		NSString *end = [start componentsSeparatedByString:@"<p class=\"writers\">"][0];
        NSString *end2 = [end componentsSeparatedByString:@"<div class=\"lyrics-bottom\">"][0];
		NSString *final = [end2 stringByReplacingOccurrencesOfString:@"<p class='verse'>" withString:@"XYZNEWLINE"];
		NSString *final1 = [final stringByReplacingOccurrencesOfString:@"</p>" withString:@"XYZNEWLINE"];
        if ([final1 rangeOfString:@"<!--WIDGET - RELATED-->"].location != NSNotFound &&
             [final1 rangeOfString:@"<!--END WIDGET - RELATED-->"].location != NSNotFound)
        {
            NSString *h1 = [final1 componentsSeparatedByString:@"<!--WIDGET - RELATED-->"][0];
            NSString *h2 = [final1 componentsSeparatedByString:@"<!--END WIDGET - RELATED-->"][1];
            final1 = [h1 stringByAppendingString:h2];
        }
        if ([final1 rangeOfString:@"<!--WIDGET - PHOTOS-->"].location != NSNotFound &&
            [final1 rangeOfString:@"<!--END WIDGET - PHOTOS-->"].location != NSNotFound)
        {
            NSString *h1 = [final1 componentsSeparatedByString:@"<!--WIDGET - PHOTOS-->"][0];
            NSString *h2 = [final1 componentsSeparatedByString:@"<!--END WIDGET - PHOTOS-->"][1];
            final1 = [h1 stringByAppendingString:h2];
        }
		NSString *final2 = [final1 stringByConvertingHTMLToPlainText];


		NSMutableString *tmp = [NSMutableString new];
		for (NSString *line in [final2 componentsSeparatedByString:@"XYZNEWLINE"]) {
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
