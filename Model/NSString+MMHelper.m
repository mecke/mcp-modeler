//
//  NSString+MMHelper.m
//  MCPModeler
//
//  Created by Serge Cohen on 06/01/05.
//  Copyright 2005 Serge Cohen. All rights reserved.
//
//  This code is free software; you can redistribute it and/or modify it under
//  the terms of the GNU General Public License as published by the Free
//  Software Foundation; either version 2 of the License, or any later version.
//
//  This code is distributed in the hope that it will be useful, but WITHOUT ANY
//  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
//  FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
//  details.
//
//  For a copy of the GNU General Public License, visit <http://www.gnu.org/> or
//  write to the Free Software Foundation, Inc., 59 Temple Place--Suite 330,
//  Boston, MA 02111-1307, USA.
//
//  More info at <http://mysql-cocoa.sourceforge.net/>
//

#import "NSString+MMHelper.h"


@implementation NSString (MMHelper)

- (NSString *) capitalizedName
{
	if ([self length]) {
		return [[[self substringToIndex:1] uppercaseString] stringByAppendingString:[self substringFromIndex:1]];
	}
	else {
		return self;
	}
}

- (NSString *) deCapitalizedName
{
	if ([self length]) {
		return [[[self substringToIndex:1] lowercaseString] stringByAppendingString:[self substringFromIndex:1]];
	}
	else {
		return self;
	}
}


/*Removes all leading capital except the last one.*/
- (NSString *) noPrefixName
{
	if ([self length]) {
		NSScanner			*theScanner = [[NSScanner alloc] initWithString:self];
		NSCharacterSet		*theCapitalsSet = [NSCharacterSet uppercaseLetterCharacterSet];

		[theScanner scanCharactersFromSet:theCapitalsSet intoString:nil];
		return [self substringFromIndex:([theScanner scanLocation] - 1)];
	}
	else {
		return self;
	}
}

/*Removes the last letter of the string if it is a 's'.*/
- (NSString *) singularised
{
	if ([self length] && ((unichar)('s') == [self characterAtIndex:([self length]-1)])) {
		return [self substringToIndex:([self length]-1)];
	}
	else {
		return self;
	}
}

@end
