//
//  MMInspectorViewModel.h
//  MCPModeler
//
//  Created by Serge Cohen (serge.cohen@m4x.org) on 09/09/04.
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

@class MCPModel;

@interface MMInspectorViewModel : NSView
{
//	IBOutlet MCPModel			*model;
	IBOutlet NSView			*nibView;
//	IBOutlet NSTextField		*modelNameField;
//	IBOutlet NSButton			*usesInnoDBButton;
	
	IBOutlet NSObjectController	*modelController; // Not weak, but instanciated from the nib!!!
}

#pragma mark Life Cycle
- (id) initWithFrame:(NSRect)frameRect;
- (void) dealloc;

#pragma mark NSView Overload
//- (void)drawRect:(NSRect)rect;

#pragma mark Nib Loading
- (void) awakeFromNib;

#pragma mark Setters
- (void) setModel:(MCPModel *) iModel;

#pragma mark Getters
- (MCPModel *) model;
- (NSView *) nibView;

@end
