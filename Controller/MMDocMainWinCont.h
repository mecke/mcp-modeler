//
//  MMDocMainWinCont.h
//  MCPModeler
//
//  Created by Serge Cohen (serge.cohen@m4x.org) on 09/08/04.
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

#import "MCPModel.h"
#import "MCPClassDescription.h"
#import "MCPAttribute.h"
#import "MCPRelation.h"

@class MMInspectorViewModel;
@class MMInspectorViewClassDescription;
@class MMInspectorViewAttribute;
@class MMInspectorViewRelation;

@interface MMDocMainWinCont : NSWindowController {
	IBOutlet NSOutlineView              *modelList;
	IBOutlet NSTabView                  *inspectorTabView;
	IBOutlet MMInspectorViewModel       *modelInspectorView;
	IBOutlet MMInspectorViewClassDescription      *classDescriptionInspectorView;
	IBOutlet MMInspectorViewAttribute   *attributeInspectorView;
	IBOutlet	MMInspectorViewRelation		*relationInspectorView;
	
	MCPModel                             *model;     // Weak reference.
}

#pragma mark Life Cycle
- (id) init;
- (void) dealloc;

#pragma mark NSWindowConroller Override
- (void) windowDidLoad;

#pragma mark Actions
- (IBAction) updateModel:(id) sender;
- (IBAction) addClassDescription:(id) sender;
- (IBAction) addAttribute:(id) sender;
- (IBAction) addRelation:(id) sender;
- (IBAction) addItem:(id) sender;
- (IBAction) removeItem:(id) sender;
- (IBAction) openInspector:(id) sender;

#pragma mark Menu Control
- (BOOL) validateMenuItem:(NSMenuItem *) anItem;

#pragma mark Naming New Items
- (NSString *) nameForNewClassDescription;
- (NSString *) nameForNewAttributeInClassDescription:(MCPClassDescription *) iClassDescription;
- (NSString *) nameForNewRelationInClassDescription:(MCPClassDescription *) iClassDescription;

#pragma mark Call back messages
//- (void) openCodeFile:(NSOpenPanel *) sheet returnCode:(int) returnCode contextInfo: (void *) contextInfo;

#pragma mark Data Source for OutlineView
- (int) outlineView:(NSOutlineView *) outlineView numberOfChildrenOfItem:(id) item;
- (BOOL) outlineView:(NSOutlineView *) outlineView isItemExpandable:(id) item;
- (id) outlineView:(NSOutlineView *) outlineView child:(int) index ofItem:(id) item;
- (id) outlineView:(NSOutlineView *) outlineView objectValueForTableColumn:(NSTableColumn *) tableColumn byItem:(id) item;
- (void) outlineView:(NSOutlineView *) outlineView setObjectValue:(id) object forTableColumn:(NSTableColumn *) tableColumn byItem:(id) item;

#pragma mark Delegate for OutlineView (NSTableView delegate)
- (void) outlineViewSelectionDidChange:(NSNotification *) aNotification;
// - (void) outlineView:(NSOutlineView *) outlineView willDisplayCell:(id) cell forTableColumn:(NSTableColumn *) tableColumn item:(id) item;

#pragma mark Setters
#pragma mark Getters
- (MCPClassDescription *) selectedClassDescription;

@end
