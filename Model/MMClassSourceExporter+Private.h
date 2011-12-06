//
//  MMClassSourceExporter+Private.h
//  MCPModeler
//
//  Created by Serge Cohen (serge.cohen@m4x.org) on 13/11/04.
//  Copyright 2004 Serge Cohen. All rights reserved.
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

#import "MMClassSourceExporter.h"

@interface MMClassSourceExporter (Private)

#pragma mark Internal Piping
- (void) reInit;

#pragma mark Making the header file
- (void) prepareHeader;

#pragma mark Making the method file
- (void) prepareMethods;

- (NSString *) implementationForLifeCycleMethods;

+ (NSString *) setterImplementationForAttribute:(MCPAttribute *) iAttribute;
+ (NSString *) getterImplementationForAttribute:(MCPAttribute *) iAttribute;
+ (NSString *) relationImplementationForRelation:(MCPRelation *) iRelation;

@end