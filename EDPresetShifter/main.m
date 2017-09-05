//
//  main.m
//  EDPresetShifter
//
//  Created by Christopher Niven on 2017-09-05.
//  Copyright © 2017 Never Be Normal. All rights reserved.
//

#import <Foundation/Foundation.h>

bool determineIfPatternIsBlank(NSDictionary *pattern) {
	if (!pattern) {
		return true;
	} else {
		for (int i = 0; i < 6; i++) {
			NSDictionary *instDict = [pattern objectForKey:[NSString stringWithFormat:@"instrData_%d", i]];
			if (instDict) {
				NSArray *stepArray = [instDict objectForKey:@"stepArray"];
				if (stepArray) {
					for (int j = 0; j < 16; j++) {
						if ([[stepArray objectAtIndex:j] integerValue] > 0) return false;
					}
				}
			}
		}
	}
	return true;
}

int main(int argc, const char * argv[]) {
	@autoreleasepool {
	    // insert code here...
		if (argc > 1) {

			NSString *fileName = [NSString stringWithCString:argv[1] encoding:NSUTF8StringEncoding];
			if (![fileName hasSuffix:@"plist"]) {
				NSLog(@"error: not a plist file.");
				return 0;
			} else {
				NSLog(@"Hello, World! %@", fileName);

				NSFileManager *fm = [NSFileManager defaultManager];
				if ([fm fileExistsAtPath:fileName]) {

					// open and shift down the preset file
					NSMutableDictionary *presetDict = [NSMutableDictionary dictionaryWithContentsOfFile:fileName];

					int destinationPattern = 100;

					do {

						destinationPattern--;
					} while (!determineIfPatternIsBlank([presetDict objectForKey:[NSString stringWithFormat:@"pattern_%d", destinationPattern]]));

					for (int i = 99; i >= 0; i--) {
						NSDictionary *patternDict = [presetDict objectForKey:[NSString stringWithFormat:@"pattern_%d", i]];
						if (!determineIfPatternIsBlank(patternDict) && destinationPattern >= 0 && i < destinationPattern) {
							NSLog(@"shifting pattern %d to %d", i, destinationPattern);
							[presetDict setObject:patternDict forKey:[NSString stringWithFormat:@"pattern_%d", destinationPattern]];
							[presetDict removeObjectForKey:[NSString stringWithFormat:@"pattern_%d", i]];

							do {
								destinationPattern--;
							} while (!determineIfPatternIsBlank([presetDict objectForKey:[NSString stringWithFormat:@"pattern_%d", destinationPattern]]));
						}
					}
					[presetDict writeToFile:fileName atomically:YES];
				}
			}
		}
	}
	return 0;
}
