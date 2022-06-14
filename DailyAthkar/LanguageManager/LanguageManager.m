//
//  LanguageManager.m
//  ios_language_manager
//
//  Created by Maxim Bilan on 12/23/14.
//  Copyright (c) 2014 Maxim Bilan. All rights reserved.
//

#import "LanguageManager.h"
#import "NSBundle+Language.h"

static NSString * LanguageCodes[] = {@"en", @"ar"};
static NSString * const LanguageStrings[] = { @"English", @"Arabic"};
static NSString * const LanguageSaveKey = @"currentLanguageKey";

@implementation LanguageManager

+ (BOOL)setupCurrentLanguage
{
    BOOL languageWasAlreadySet = YES;
    NSString *currentLanguage = [[NSUserDefaults standardUserDefaults] objectForKey:LanguageSaveKey];
    if (!currentLanguage) {
        languageWasAlreadySet = NO;
        currentLanguage = @"ar";
        [[NSUserDefaults standardUserDefaults] setObject:@[@"ar-sa"] forKey:@"AppleLanguages"];
        [[NSUserDefaults standardUserDefaults] setObject:currentLanguage forKey:LanguageSaveKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    

    
    
    [[NSBundle mainBundle] setLanguage:currentLanguage];
    

    
    return languageWasAlreadySet;
}

+ (NSArray *)languageStrings
{
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger i = 0; i < ELanguageCount; ++i) {
        [array addObject:NSLocalizedString(LanguageStrings[i], @"")];
    }
    return [array copy];
}

+ (NSString *)currentLanguageString
{
    NSString *string = @"";
    NSString *currentCode = [[NSUserDefaults standardUserDefaults] objectForKey:LanguageSaveKey];
    for (NSInteger i = 0; i < ELanguageCount; ++i) {
        if ([currentCode isEqualToString:LanguageCodes[i]]) {
            string = NSLocalizedString(LanguageStrings[i], @"");
            break;
        }
    }
    return string;
}

+ (NSString *)currentLanguageCode
{
    NSString* savedCode = [[NSUserDefaults standardUserDefaults] objectForKey:LanguageSaveKey];
    return savedCode;
}

+ (NSInteger)currentLanguageIndex
{
    NSInteger index = 0;
    NSString *currentCode = [[NSUserDefaults standardUserDefaults] objectForKey:LanguageSaveKey];
    for (NSInteger i = 0; i < ELanguageCount; ++i) {
        if ([currentCode isEqualToString:LanguageCodes[i]]) {
            index = i;
            break;
        }
    }
    return index;
}

+ (void)saveLanguageByIndex:(NSInteger)index
{
    if (index >= 0 && index < ELanguageCount) {
        NSString *code = LanguageCodes[index];
        [[NSUserDefaults standardUserDefaults] setObject:code forKey:LanguageSaveKey];
        if([code isEqualToString:@"ar"]){
            [[NSUserDefaults standardUserDefaults] setObject:@[@"ar-sa"] forKey:@"AppleLanguages"];
        }else{
            [[NSUserDefaults standardUserDefaults] setObject:@[@"en-us"] forKey:@"AppleLanguages"];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSLog(@"SAVING %@",code);
        [[NSBundle mainBundle] setLanguage:code];
  
    }
}

+ (BOOL)isCurrentLanguageRTL
{
	NSInteger currentLanguageIndex = [self currentLanguageIndex];
	return ([NSLocale characterDirectionForLanguage:LanguageCodes[currentLanguageIndex]] == NSLocaleLanguageDirectionRightToLeft);
}

@end
