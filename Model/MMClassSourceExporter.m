//
//  MMClassSourceExporter.m
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

#import "MMClassSourceExporter.h"
#import "MMClassSourceExporter+Private.h"

#import "MCPModel.h"
#import "MCPClassDescription.h"
#import "MCPClassDescription+Private.h"
#import "MCPClassDescription+MCPEntreprise.h"
#import "MCPAttribute.h"
#import "MCPAttribute+Private.h"
#import "MCPRelation.h"
#import "MCPJoin.h"

#import "NSString+MMHelper.h"

@implementation MMClassSourceExporter

#pragma mark Class Messages
+ (void) initialize
{
	if (self = [MMClassSourceExporter class]) {
		[self setVersion:010000]; // Ma.Mi.Re -> MaMiRe
	}
	return;
}


#pragma mark Life Cycle
- (id) initWithExportedClass:(MCPClassDescription *) iExportedClass
{
	self = [super init];
	if (self) {
		headerFile = [[NSMutableString alloc] init];
		methodFile = [[NSMutableString alloc] init];
		[self setExportedClass:iExportedClass];
		[self setProjectName:@""];
		[self setDisclaimer:@""];
	}
	return self;
}

- (void) dealloc
{
	[headerFile release];
	[methodFile release];
	[exportedClass release];
	[projectName release];
	[disclaimer release];
	[super dealloc];
}

#pragma mark Utility methods

#pragma mark Actions

#pragma mark Setters
- (void) setExportedClass:(MCPClassDescription *) iExportedClass
{
	if (iExportedClass != exportedClass) {
		[exportedClass release];
		exportedClass = [iExportedClass retain];
		[self reInit];
	}
}

- (void) setProjectName:(NSString *) iProjectName
{
	if (iProjectName != projectName) {
		[projectName release];
		projectName = [iProjectName retain];
		[self reInit];
	}
}

- (void) setDisclaimer:(NSString *) iDisclaimer
{
	if (iDisclaimer != disclaimer) {
		[disclaimer release];
		disclaimer = [iDisclaimer retain];
		[self reInit];
	}
}

#pragma mark Getters
- (MCPClassDescription *) exportedClass
{
	return exportedClass;
}

- (NSString *) projectName
{
	return projectName;
}

- (NSString *) disclaimer
{
	return disclaimer;
}

- (NSString *) headerFile
{
	if ([headerFile length]) {
		return headerFile;
	}
	else {
		[self prepareHeader];
		return headerFile;
	}
}

- (NSString *) methodsFile
{
	if ([methodFile length]) {
		return methodFile;
	}
	else {
		[self prepareMethods];
		return methodFile;
	}
}

#pragma mark For logging and debugging
- (NSString *) description
{
	return [NSString stringWithFormat:@"ClassSourceExporter for class : %@", [exportedClass name]];
}

@end

@implementation MMClassSourceExporter (Private)

#pragma mark Internal Piping
- (void) reInit
{
	[headerFile setString:@""];
	[methodFile setString:@""];
}

#pragma mark Making the header file
- (void) prepareHeader
{
	unsigned int		i;
	NSMutableArray		*usedClasses;

	if ([headerFile length]) {
		NSLog(@"In MMClassSourceExporter(Private) prepareHeader method... the header must be already prepared because it is NOT empty... Will NOT change it at all");
		return;
	}
// Making the disclaimer and front head.
	[headerFile appendFormat:@"%@ %@.h\n// %@\n//\n", @"//", [exportedClass name], projectName];
	[headerFile appendFormat:@"%@ Created by MCPModeler.\n%@", @"//", disclaimer];

// Making the imports.
	[headerFile appendString:@"\n#import <Foundation/Foundation.h>\n#import <MCPKit_bundled/MCPKit_bundled.h>\n//#import <MCPKit_bundled/MCPObject.h>\n#import \"MCPObject.h\"\n\n"];
// Declaring the classes used in the relation(s)
	usedClasses = [[NSMutableArray alloc] init];
	for (i=0; i != [exportedClass countOfRelations]; ++i) {
		MCPClassDescription		*theClassDescription = [[exportedClass objectInRelationsAtIndex:i] destination];

		if (! [usedClasses containsObject:theClassDescription]) { // Checking that we have not declared it already.
			[headerFile appendFormat:@"@class %@;\n", [theClassDescription name]];
			[usedClasses insertObject:theClassDescription atIndex:[usedClasses count]];
		}
	}
	[usedClasses release];
	[headerFile appendString:@"\n"];

// Preparing the interface : the name of the class then the instance variables:
	[headerFile appendFormat:@"@interface %@ : MCPObject {\n", [exportedClass name]];
	[headerFile appendString:@"/*\" Model generated instance variables \"*/\n"];
	for (i=0; i != [exportedClass countOfAttributes]; ++i) {
		MCPAttribute	*theAttribute = [exportedClass objectInAttributesAtIndex:i];

		[headerFile appendFormat:@"\t%@\t%@%@;\n", [theAttribute internalType], ([theAttribute valueClass] != nil) ? @"*" : @"", [theAttribute name]];
	}
	[headerFile appendString:@"}\n\n"];

// Declaring the methods:
	[headerFile appendString:@"/*\" Class methods : \"*/\n#pragma mark Class methods\n"];
	if ([exportedClass singleIntAutoGenKey]) {
		[headerFile appendFormat:@"+ (%@ *) %@FromConnection:(MCPConnection *) iConnection withId:(unsigned int) iId;\n", [exportedClass name], [[[exportedClass name] noPrefixName] deCapitalizedName]];
	}
	else {
		[headerFile appendFormat:@"+ (%@ *) %@FromConnection:(MCPConnection *) iConnection withId:(NSDictionary *) iId;\n", [exportedClass name], [[[exportedClass name] noPrefixName] deCapitalizedName]];
	}
	
	[headerFile appendFormat:@"\n/*\" Creating a %@ : \"*/\n#pragma mark Life cycle\n", [exportedClass name]];
	[headerFile appendString:@"- (id) init;\n"
		"- (id) initWithDictionary:(NSDictionary *) dictionary;\n"
		"- (void) setConnection:(MCPConnection *) iConnection;\n"];
	[headerFile appendString:@"- (void) dealloc;\n\n"];

	[headerFile appendString:@"/*\" Accessors : \"*/\n#pragma mark Getters\n"];
	for (i=0; i != [exportedClass countOfAttributes]; ++i) {
		MCPAttribute	*theAttribute = [exportedClass objectInAttributesAtIndex:i];

		if ([theAttribute hasAccessor]) {
			[headerFile appendFormat:@"- (%@%@) %@;\n", [theAttribute internalType], (nil != [theAttribute valueClass]) ? @" *" : @"" , [theAttribute name]];
		}
	}
	[headerFile appendString:@"\n#pragma mark Setters\n"];
	for (i=0; i != [exportedClass countOfAttributes]; ++i) {
		MCPAttribute	*theAttribute = [exportedClass objectInAttributesAtIndex:i];
		NSString			*theCapAttName = [[theAttribute name] capitalizedName];
		
		if ([theAttribute hasAccessor]) {
			[headerFile appendFormat:@"- (void) set%@:(%@%@) i%@;\n", theCapAttName, [theAttribute internalType], (nil != [theAttribute valueClass]) ? @" *" : @"", theCapAttName];
		}
	}

	[headerFile appendString:@"\n/*\" Relations : \"*/\n#pragma mark Relations\n"];
	for (i=0; i != [exportedClass countOfRelations]; ++i) {
		MCPRelation		*theRelation = (MCPRelation *)[[exportedClass relations] objectAtIndex:i];

		if ([theRelation isToMany]) {
			[headerFile appendFormat:@"- (NSArray *) %@;\n", [theRelation name]];
			[headerFile appendFormat:@"- (unsigned int) countOf%@;\n", [[theRelation name] capitalizedName]];
			[headerFile appendFormat:@"- (%@ *) objectIn%@AtIndex:(unsigned int) index;\n", [[theRelation destination] name], [[theRelation name] capitalizedName]];
			[headerFile appendFormat:@"- (void) insertObject:(%@ *) %@ in%@AtIndex:(unsigned int) index;\n", [[theRelation destination] name], [[theRelation name] singularised], [[theRelation name] capitalizedName]];
			[headerFile appendFormat:@"- (void) removeObjectFrom%@AtIndex:(unsigned int) index;\n", [[theRelation name] capitalizedName]];
			[headerFile appendFormat:@"- (unsigned int) indexOf%@:(%@ *) %@;\n\n", [[[theRelation name] capitalizedName] singularised], [[theRelation destination] name], [[theRelation name] singularised]];
		}
		else {
			[headerFile appendFormat:@"- (%@ *) %@;\n", [[theRelation destination] name], [theRelation name]];
			[headerFile appendFormat:@"- (void) set%@:(%@ *) i%@;\n\n", [[theRelation name] capitalizedName], [[theRelation destination] name], [[[theRelation destination] name] noPrefixName]];
		}
	}
	
	[headerFile appendString:@"\n@end\n\n"];
}

#pragma mark Making the method file
- (void) prepareMethods
{	unsigned int		i;
	NSMutableArray		*usedClasses;
	
	if ([methodFile length]) {
		NSLog(@"In MMClassSourceExporter(Private) prepareMethods method... the methods must be already prepared because it is NOT empty... Will NOT change it at all");
		return;
	}
// Making the disclaimer and front head.
	[methodFile appendFormat:@"%@ %@.m\n// %@\n//\n", @"//", [exportedClass name], projectName];
	[methodFile appendFormat:@"%@ Created by MCPModeler.\n%@\n", @"//", disclaimer];
		
// Making the imports.
	[methodFile appendFormat:@"#import \"%@.h\"\n", [exportedClass name]];
// Declaring the classes used in the relation(s)
	usedClasses = [[NSMutableArray alloc] init];
	for (i=0; i != [exportedClass countOfRelations]; ++i) {
		MCPClassDescription		*theClassDescription = [[exportedClass objectInRelationsAtIndex:i] destination];
		
		if (! [usedClasses containsObject:theClassDescription]) { // Checking that we have not declared it already.
			[methodFile appendFormat:@"#import \"%@.h\"\n", [theClassDescription name]];
			[usedClasses insertObject:theClassDescription atIndex:[usedClasses count]];
		}
	}
	[usedClasses release];
	[methodFile appendString:@"\n"];

// Now defining the implementation of the class:
	[methodFile appendFormat:@"@implementation %@\n", [exportedClass name]];

	[methodFile appendString:[self implementationForLifeCycleMethods]];
	
	[methodFile appendString:@"\n#pragma mark Getters\n"];
	for (i=0; i != [exportedClass countOfAttributes]; ++i) {
		MCPAttribute	*theAttribute = (MCPAttribute *)[[exportedClass attributes] objectAtIndex:i];
		
		if ([theAttribute hasAccessor]) {
			[methodFile appendString:[MMClassSourceExporter getterImplementationForAttribute:theAttribute]];
		}
	}
	
	[methodFile appendString:@"\n#pragma mark Setters\n"];
	for (i=0; i != [exportedClass countOfAttributes]; ++i) {
		MCPAttribute	*theAttribute = (MCPAttribute *)[[exportedClass attributes] objectAtIndex:i];
		
		if ([theAttribute hasAccessor]) {
			[methodFile appendString:[MMClassSourceExporter setterImplementationForAttribute:theAttribute]];
		}
	}

	[methodFile appendString:@"\n#pragma mark Relations\n"];
//	[methodFile appendString:@"\n/*\" Relations : \"*/\n#pragma mark Relations\n"];
	for (i=0; i != [exportedClass countOfRelations]; ++i) {
		MCPRelation		*theRelation = (MCPRelation *)[[exportedClass relations] objectAtIndex:i];

		[methodFile appendString:[MMClassSourceExporter relationImplementationForRelation:theRelation]];
	}

	[methodFile appendString:@"\n@end\n\n"];
}

- (NSString *) implementationForLifeCycleMethods
{
	NSMutableString		*theImplementation = [NSMutableString string];
	NSMutableString		*theDeallocString = [NSMutableString string];
	unsigned int			i;
	
	[theImplementation appendString:@"\n#pragma mark Class methods\n"];
	if ([exportedClass singleIntAutoGenKey]) {
		NSString		*theObjectName = [NSString stringWithFormat:@"the%@", [[exportedClass name] noPrefixName]];
		
		[theImplementation appendFormat:@"+ (%@ *) %@FromConnection:(MCPConnection *) iConnection withId:(unsigned int) iId\n"
			"{\n"
			"\t%@\t\t*%@ = [[%@ alloc] initWithDictionary:[NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedInt:iId] forKey:@\"%@\"]];\n\n"
			"\tif (%@) {\n"
			"\t\tunsigned int\ttheRetCode = [%@ setPrimaryKey:%@ andFetchFromDB:iConnection];\n\n"
			"\t\tif (MCPDBReturnOK != theRetCode) {\n"
			"\t\t\t[%@ release];\n"
			"\t\t\t\%@ = nil;\n"
			"\t\t}\n"
			"\t\telse {\n"
			"\t\t\t[%@ autorelease];\n"
			"\t\t}\n"
			"\t}\n"
			"\treturn %@;\n"
			"}\n\n"
			, [exportedClass name], [[[exportedClass name] noPrefixName] deCapitalizedName], [exportedClass name], theObjectName, [exportedClass name], [(MCPAttribute *)[[exportedClass primaryKeyAttributes] objectAtIndex:0] name], theObjectName, theObjectName, theObjectName, theObjectName, theObjectName, theObjectName, theObjectName];
	}
	else {
		NSString		*theObjectName = [NSString stringWithFormat:@"the%@", [[exportedClass name] noPrefixName]];
		
		[theImplementation appendFormat:@"+ (%@ *) %@FromConnection:(MCPConnection *) iConnection withId:(NSDictionary *) iId\n"
			"{\n"
			"\t%@\t\t*%@ = [[%@ alloc] initWithDictionary:iId];\n\n"
			"\tif (%@) {\n"
			"\t\tunsigned int\ttheRetCode = [%@ setPrimaryKey:%@ andFetchFromDB:iConnection];\n\n"
			"\t\tif (MCPDBReturnOK != theRetCode) {\n"
			"\t\t\t[%@ release];\n"
			"\t\t\t\%@ = nil;\n"
			"\t\t}\n"
			"\t\telse {\n"
			"\t\t\t[%@ autorelease];\n"
			"\t\t}\n"
			"\t}\n"
			"\treturn %@;\n"
			"}\n\n"
			, [exportedClass name], [[[exportedClass name] noPrefixName] deCapitalizedName], [exportedClass name], theObjectName, [exportedClass name], theObjectName, theObjectName, theObjectName, theObjectName, theObjectName, theObjectName, theObjectName];
	}
	
	[theImplementation appendString:@"\n#pragma mark Life cycle\n"];
	[theImplementation appendString:@"- (id) init\n"
		"{\n"
		"\tself = [super init]; // Takes cares of initialising all attributes described in the class description\n"
		"\tif (self) {\n"
		"// any special codes come here\n"
		"\t}\n"
		"\treturn self;\n"
		"}\n\n"];

	[theImplementation appendString:@"- (id) initWithDictionary:(NSDictionary *) dictionary\n"
		"{\n"
		"\tself = [super initWithDictionary: dictionary]; // Takes cares of initialising all attributes described in the class description\n"
		"\tif (self) {\n"
		"// any special codes come here\n"
		"\t}\n"
		"\treturn self;\n"
		"}\n\n"];

	[theImplementation appendString:@"- (void) setConnection:(MCPConnection *) iConnection\n"
		"{\n"
		"\t[super setConnection:iConnection];\n"
		"}\n\n"];
	
	for (i=0; [exportedClass countOfAttributes] != i; ++i) {
		MCPAttribute		*theAttribute = [exportedClass objectInAttributesAtIndex:i];
		if ([theAttribute valueClass]) {
			[theDeallocString appendFormat:@"\t[%@ release];\n", [theAttribute name]];
		}
	}
	[theImplementation appendFormat:@"- (void) dealloc\n"
		"{\n"
		"// Any special codes come here.\n"
		"// End of special codes.\n"
		"%@"
		"\t[super dealloc]; // Releases all attributes present in the class description... \n"
		"}\n"
		"\n", theDeallocString];
	return theImplementation;
}

+ (NSString *) setterImplementationForAttribute:(MCPAttribute *) iAttribute
{
	NSString					*theCapAttName = [[iAttribute name] capitalizedName];
	NSMutableString		*theImplementation = [NSMutableString stringWithFormat:@"- (void) set%@:(%@%@) i%@\n", theCapAttName, [iAttribute internalType], (nil != [iAttribute valueClass]) ? @" *" : @"", theCapAttName];

	if ([iAttribute valueClass]) {

		[theImplementation appendFormat:@"{\n"
			"\tif (i%@ != %@) {\n"
			"\t\t[%@ release];\n"
			"\t\t%@ = ([i%@ isNSNull]) ? nil : [i%@ retain];\n"
			"\t}\n"
			"}\n\n"
			, theCapAttName, [iAttribute name], [iAttribute name], [iAttribute name], theCapAttName, theCapAttName];
	}
	else {
		[theImplementation appendFormat:@"{\n"
			"\t%@ = i%@;\n"
			"}\n\n"
			, [iAttribute name], theCapAttName];
	}
	return theImplementation;
}

+ (NSString *) getterImplementationForAttribute:(MCPAttribute *) iAttribute
{
	return [NSString stringWithFormat:@"- (%@%@) %@\n"
		"{\n"
		"\treturn %@;\n"
		"}\n\n"
		, [iAttribute internalType], (nil != [iAttribute valueClass]) ? @" *" : @"", [iAttribute name], [iAttribute name]];	
}

+ (NSString *) relationImplementationForRelation:(MCPRelation *) iRelation
{
	if ([iRelation isToMany]) {
		NSMutableString		*theReturn = [NSMutableString string];

		[theReturn appendFormat:@"- (NSArray *) %@\n" // Getting the array.
			"{\n"
			"\treturn [self getTargetOfRelationNamed:@\"%@\"];\n"
			"}\n\n"
			, [iRelation name], [iRelation name]];
		[theReturn appendFormat:@"- (unsigned int) countOf%@\n" // Getting the count.
			"{\n"
			"\treturn [self countTargetForRelationNamed:@\"%@\"];\n"
			"}\n\n"
			, [[iRelation name] capitalizedName], [iRelation name]];
		[theReturn appendFormat:@"- (%@ *) objectIn%@AtIndex:(unsigned int) index\n" // Getting a target by index.
			"{\n"
			"\treturn (%@ *)[self getTargetOfRelationNamed:@\"%@\" atIndex:index];\n"
			"}\n\n"
			, [[iRelation destination] name], [[iRelation name] capitalizedName], [[iRelation destination] name], [iRelation name]];
		[theReturn appendFormat:@"- (void) insertObject:(%@ *) %@ in%@AtIndex:(unsigned int) index\n" // Adding an object
			"{\n"
			"\t[self addTarget:%@ toRelationNamed:@\"%@\"];\n"
			"}\n\n"
			, [[iRelation destination] name], [[iRelation name] singularised], [[iRelation name] capitalizedName],  [[iRelation name] singularised], [iRelation name]];
		[theReturn appendFormat:@"- (void) removeObjectFrom%@AtIndex:(unsigned int) index\n" // Removing an object from the relation.
			"{\n"
			"\t[self removeTargetToRelationNamed:@\"%@\" atIndex:index];\n"
			"}\n\n"
			, [[iRelation name] capitalizedName], [iRelation name]];
		[theReturn appendFormat:@"- (unsigned int) indexOf%@:(%@ *) %@\n" // Getting the index of a specific target object.
			"{\n"
			"\treturn [self indexOfTarget:%@ inRelationNamed:@\"%@\"];\n"
			"}\n\n"
			,[[[iRelation name] capitalizedName] singularised], [[iRelation destination] name], [[iRelation name] singularised], [[iRelation name] singularised], [iRelation name]];
		return theReturn;
	}
	else {
		return [NSString stringWithFormat:@"- (%@ *) %@\n"
			"{\n"
//			"// should be generated automatically later on...\n"
//			"\treturn nil;\n"
			"\treturn (%@ *)[self getTargetOfRelationNamed:@\"%@\"];\n"
			"}\n\n"
			"- (void) set%@:(%@ *) i%@\n"
			"{\n"
///			"// should be generated automatically later on...\n"
			"\t[self setTarget:i%@ forRelationNamed:@\"%@\"];\n"
//			"\t\n"
			"}\n\n"
			,[[iRelation destination] name], [iRelation name],[[iRelation destination] name], [iRelation name], [[iRelation name] capitalizedName], [[iRelation destination] name], [[iRelation name] capitalizedName], [[iRelation name] capitalizedName], [iRelation name]];
//		return [NSString stringWithFormat:@"implementation for a to-one relation : %@\n", [iRelation name]];
	}
}


@end

