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
        if (argc > 1) {
            
            NSString *fileName = [NSString stringWithCString:argv[1] encoding:NSUTF8StringEncoding];
            if (![fileName hasSuffix:@"plist"]) {
                NSLog(@"error: not a plist file.");
                return 0;
            } else {
                NSLog(@"Hello, World! %@", fileName);
                
                NSFileManager *fm = [NSFileManager defaultManager];
                NSMutableDictionary *presetDict = [NSMutableDictionary dictionaryWithContentsOfFile:fileName];
                if ([fm fileExistsAtPath:fileName]) {
                    
                    // open and shift down the preset file
                    
                    if (argc > 2) {
                        NSString *flag = [NSString stringWithCString:argv[2] encoding:NSUTF8StringEncoding];
                        
                        // options for shifting the tempo X and keeping everything intact
                        if ([flag isEqualToString:@"-s"]) { //shorten
                            //take list of effects values and scale them by 2
                            int startPattern = 0;
                            int endPattern = 99;
                            
                            if (argc > 4) {
                                startPattern = [[NSString stringWithCString:argv[3] encoding:NSUTF8StringEncoding] intValue];
                                endPattern = [[NSString stringWithCString:argv[4] encoding:NSUTF8StringEncoding] intValue];
                                
                                if (startPattern < 0 || startPattern > 99 || endPattern < 0 || endPattern > 99 || endPattern < startPattern) {
                                    NSLog(@"start pattern should be lower than end pattern and be in the range from 0-99!");
                                    return 0;
                                }                                
                            }
                            
                            
                            for (; startPattern <= endPattern; startPattern++) {
                                NSString *patKey = [NSString stringWithFormat:@"pattern_%d", startPattern];
                                
                                NSMutableDictionary *patternDict = [presetDict objectForKey:patKey];
                                
                                if (patternDict != nil) {
                                    
                                    //TODO: do this eventually
//                                    NSArray *tbValues = @[@(0.5), @(1.0), @(1.5), @(2.0), @(3.0), @(4.0)];
                                    
                                    //TODO: specify instruments
                                    for (int i = 0; i < 6; i++) {
                                        
                                    
                                        NSString *instKey = [NSString stringWithFormat:@"instrData_%d", i];
                                        NSMutableDictionary *instDict = [patternDict objectForKey:instKey];
                                        
//                                        NSLog(@"getting instDict for %@ ->\n%@", instKey, instDict);
                                        
                                        // shorten "tb" by half (minus 2)
                                        float tb = [[instDict objectForKey:@"tb"] floatValue];
                                        NSLog(@"%@ %@ got tb -> %f, setting to %f", patKey, instKey, tb, MAX(0.5, tb / 2.0));

                                        
                                        
//                                        tb = MAX(0.0, tb - 2.0);
                                        tb = MAX(0.5, tb / 2.0);
                                        
                                        
                                        [instDict setObject:[NSNumber numberWithFloat:tb] forKey:@"tb"];
                                        
//                                        [instDict setObject:[NSNumber numberWithFloat:2.0] forKey:@"master_tempoMult"];
                                        NSMutableDictionary *masterData = [patternDict objectForKey:@"masterData"];
                                        float tempoMult = [[masterData objectForKey:@"master_tempoMult"] floatValue];
                                        
                                        NSLog(@"%@ %@ got master_tempoMult -> %f, setting to %f", patKey, instKey, tempoMult, MAX(0.0, tempoMult - 2.0));
                                        
                                        tempoMult = MAX(0.0, tempoMult - 2.0);
                                        [masterData removeObjectForKey:@"master_tempoMult"];
                                        [masterData setObject:@(tempoMult) forKey:@"master_tempoMult"];
                                        
                                        [patternDict removeObjectForKey:@"masterData"];
                                        [patternDict setObject:masterData forKey:@"masterData"];
                                        
                                        [patternDict removeObjectForKey:instKey];
                                        [patternDict setObject:instDict forKey:instKey];
                                        
//                                        NSLog(@"getting instDict for %@ ->\n%@", instKey, instDict);
                                        
                                        //TODO automation??
                                        //                                        for (int j = 0; j < 10; j++) {
                                        //
                                        //                                        }
                                    }
                                    
                                    //effects
                                    
                                    //TODO: master_tempoMult
                                    //TODO: "tb" field (step speed)
//                                    for (int i = 0; i < 4; i++) {
                                        NSMutableDictionary *masterData = [patternDict objectForKey:[NSString stringWithFormat:@"masterData"]];
//                                        NSLog(@"%d: masterData: %@", i, masterData);
                                        for (int j = 0; j < 8; j++) {
                                            NSMutableArray *automateArray = [masterData objectForKey:[NSString stringWithFormat:@"automate%d", j]];
                                                                                        
                                            if (automateArray.count > 1) {
                                                
                                                NSLog(@"automateArray %d: %@", j, automateArray);
                                                NSMutableArray *automateCopy = [NSMutableArray array];
                                                int k = 0;
                                                for (NSNumber *number in automateArray) {
                                                    if (k % 2 == 0) { // eliminate all odd entries
                                                        [automateCopy addObject:number];
                                                    }
                                                    k++;
                                                }
                                                [automateCopy addObjectsFromArray:automateCopy];
                                                
                                                NSLog(@"automateArray %d AFTER: %@", j, automateCopy);
                                                
                                                [masterData removeObjectForKey:[NSString stringWithFormat:@"automate%d", j]];
                                                [masterData setObject:automateCopy forKey:[NSString stringWithFormat:@"automate%d", j]];
                                            }
                                        }
                                        
                                        [patternDict removeObjectForKey:@"masterData"];
                                        [patternDict setObject:masterData forKey:@"masterData"];
//                                    }
                                    [presetDict removeObjectForKey:[NSString stringWithFormat:@"pattern_%d", startPattern]];
                                    [presetDict setObject:patternDict forKey:[NSString stringWithFormat:@"pattern_%d", startPattern]];
                                }
                            }
                        }
                    } else { // preset shift
                        
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
                    }
                    NSLog(@"writing this preset dict: %@", presetDict);
                    [presetDict writeToFile:fileName atomically:YES];
                }
            }
        }
    }
    return 0;
}
