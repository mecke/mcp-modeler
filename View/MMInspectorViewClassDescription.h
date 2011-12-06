//
//  MMInspectorViewClassDescription.h
//  MCPModeler
//
//  Created by Serge Cohen (serge.cohen@m4x.org) on 13/09/04.
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

@class MCPClassDescription;

@interface MMInspectorViewClassDescription : NSView {
//	IBOutlet MCPClassDescription		*classDescription;
	IBOutlet NSView						*nibView;
//	IBOutlet NSTableView					*attributeTable;
//	IBOutlet NSTableView					*relationTable;
	IBOutlet NSObjectController		*classDescriptionController;
}

#pragma mark Life Cycle
- (id) initWithFrame:(NSRect)frameRect;
- (void) dealloc;

#pragma mark NSView Overload
//- (void)drawRect:(NSRect)rect;

/*
#pragma mark NSTableView datasource and delegate
- (int) numberOfRowsInTableView:(NSTableView *) aTableView;
- (id) tableView:(NSTableView *) aTableView objectValueForTableColumn:(NSTableColumn *) aTableColumn row:(int) rowIndex;
- (void) tableView:(NSTableView *) aTableView setObjectValue:(id) anObject forTableColumn:(NSTableColumn *) aTableColumn row:(int) rowIndex;
*/

#pragma mark Nib Loading
- (void) awakeFromNib;

#pragma mark Actions
- (IBAction) classDescriptionChanged:(id) sender;

#pragma mark Setters
- (void) setClassDescription:(MCPClassDescription *) iClassDescription;

#pragma mark Getters
- (MCPClassDescription *) classDescription;
- (NSView *) nibView;

#pragma mark Temporary for debugging
- (id) valueForUndefinedKey:(NSString *) key;

@end
