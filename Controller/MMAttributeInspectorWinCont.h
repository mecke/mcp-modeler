//
//  MMAttributeInspectorWinCont.h
//  MCPModeler
//
//  Created by Serge Cohen (serge.cohen@m4x.org) on 19/09/04.
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

#import <Cocoa/Cocoa.h>


@class MMInspectorViewAttribute;

@class MCPAttribute;

@interface MMAttributeInspectorWinCont : NSWindowController {
	IBOutlet MMInspectorViewAttribute   *attributeInspectorView;
}

#pragma mark Life Cycle
- (id) init;
- (void) dealloc;

#pragma mark NSWindowConroller Override
- (void) windowDidLoad;
- (NSString *) windowTitleForDocumentDisplayName:(NSString *) displayName;

#pragma mark Actions
- (void) updateAttribute:(id) sender;

#pragma mark Setters
- (void) setAttribute:(MCPAttribute *) iAttribute;

#pragma mark Getters
- (MCPAttribute *) attribute;

@end
