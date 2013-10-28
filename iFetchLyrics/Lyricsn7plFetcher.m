//
//  Lyricsn7plFetcher.m
//  iFetchLyrics
//
//  Public Domain
//

#import "Lyricsn7plFetcher.h"

@implementation Lyricsn7plFetcher

// 29% succ 3215 fail 8018
- (NSString *)_fetchLyricsForArtist:(NSString *)artist album:(NSString *)album title:(NSString *)title {
	sleep(RandomFloatBetween(0.5,1.5));
	if (!artist || ![artist length])
		return nil;
	NSString *urlStr = [[[[NSString stringWithFormat:@"http://www.lyrics.n7.pl/artists/%@/%@/%@/", [artist substringToIndex:1], artist, title] stringByReplacingOccurrencesOfString:@" " withString:@""] lowercaseString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

	NSURL *url = [NSURL URLWithString:urlStr];
	NSError *err;
	NSString *cont = [[NSString alloc] initWithContentsOfURL:url encoding:NSISOLatin1StringEncoding error:&err];
	if ([cont rangeOfString:@"Lyrics:<br><br><div class=\"tekst\">"].location == NSNotFound) {
		return nil;
	}

	@try {
		NSString *newline = [cont stringByReplacingOccurrencesOfString:@"<br>" withString:@"XYZNEWLINE"];
		newline = [newline stringByReplacingOccurrencesOfString:@"<br />" withString:@"XYZNEWLINE"];
		NSString *start = [newline componentsSeparatedByString:@"Lyrics:XYZNEWLINEXYZNEWLINE<div class=\"tekst\">"][1];
		NSString *end = [start componentsSeparatedByString:@"</div>"][0];
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