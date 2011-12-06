//
//  MMClassSourceExporter.h
//  MCPModeler
//
//  Created by Serge Cohen (serge.cohen@m4x.org) on 12/11/04.
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

#import <Foundation/Foundation.h>

@class MCPModel;
@class MCPClassDescription;
@class MCPAttribute;
@class MCPRelation;
@class MCPJoin;

@interface MMClassSourceExporter : NSObject {
	NSMutableString			*headerFile;
	NSMutableString			*methodFile;
	
	MCPClassDescription		*exportedClass;

	NSString						*projectName;
	NSString						*disclaimer;
}

#pragma mark Class Messages
+ (void) initialize;

#pragma mark Life Cycle
- (id) initWithExportedClass:(MCPClassDescription *) iExportedClass;
- (void) dealloc;

#pragma mark Utility methods

#pragma mark Actions

#pragma mark Setters
- (void) setExportedClass:(MCPClassDescription *) iExportedClass;
- (void) setProjectName:(NSString *) iProjectName;
- (void) setDisclaimer:(NSString *) iDisclaimer;

#pragma mark Getters
- (NSString *) headerFile;
- (NSString *) methodsFile;
- (MCPClassDescription *) exportedClass;
- (NSString *) projectName;
- (NSString *) disclaimer;

#pragma mark For logging and debugging
- (NSString *) description;

@end
