//
//  MMDBModelImporter.m
//  MCPModeler
//
//  Created by Serge Cohen (serge.cohen@m4x.org) on 20/09/04.
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

#import "MMDBModelImporter.h"

#import "MCPModel.h"
#import "MCPClassDescription.h"
#import "MCPAttribute.h"
#import "MCPRelation.h"
#import "MCPJoin.h"

static NSCharacterSet *MMUnderscoreCharacterSet;

@interface MMDBModelImporter (Private)

- (void) insertObject:(NSMutableDictionary *) table inTablesAtIndex:(unsigned int) index;
- (void) removeObjectFromTablesAtIndex:(unsigned int) index;
- (void) setCurrentTable:(NSMutableDictionary *) iCurrentTable;

@end

@implementation MMDBModelImporter

#pragma mark Class Messages
+ (void) initialize
{
	if (self = [MMDBModelImporter class]) {
		[self setVersion:010101]; // Ma.Mi.Re -> MaMiRe
		MMUnderscoreCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:@"_"] retain];
	}
	return;
}


#pragma mark Life Cycle
- (id) initWithModel:(MCPModel *) iModel
{
	self = [super init];
	if (self) {
		model = [iModel retain];
		[self setOverwrite:NO];
		tables = [[NSMutableArray alloc] init];
		currentTable = nil;
	}
	return self;
}
- (void) dealloc
{
	[model release];
	[classPrefix release];
	[tablePrefix release];
	[tables release];
	[currentTable release];
	[connection release];
	[protocol release];
	[host release];
	[username release];
	[password release];
	[dbName release];
//	NSLog(@"The MMDBModelImporter was released...");
	[super dealloc];
}

#pragma mark NSCoding protocol
- (id) initWithCoder:(NSCoder *) decoder
{
	self = [super init];
	if ((self) && ([decoder allowsKeyedCoding])) {
//      NSLog(@"in MMDBModelImporter initWithCoder, importer = %@ (pointer = %p)", self, self);
		[self setValue:[decoder decodeObjectForKey:@"MMmodel"] forKey:@"model"];
		[self setValue:[decoder decodeObjectForKey:@"MMclassPrefix"] forKey:@"classPrefix"];
		[self setValue:[decoder decodeObjectForKey:@"MMtablePrefix"] forKey:@"tablePrefix"];
		[self setValue:[NSNumber numberWithBool:[decoder decodeBoolForKey:@"MMoverwrite"]] forKey:@"overwrite"];
		[self setValue:[decoder decodeObjectForKey:@"MMprotocol"] forKey:@"protocol"];
		[self setValue:[decoder decodeObjectForKey:@"MMhost"] forKey:@"host"];
		[self setValue:[decoder decodeObjectForKey:@"MMusername"] forKey:@"username"];
		[self setValue:[decoder decodeObjectForKey:@"MMpassword"] forKey:@"password"];
		[self setValue:[decoder decodeObjectForKey:@"MMdbName"] forKey:@"dbName"];
		tables = [[NSMutableArray alloc] init];
	}
	else {
		NSLog(@"For some reason, unable to decode MMDBModelImporter from the coder!!!");
	}
	return self;	
}

- (void) encodeWithCoder:(NSCoder *) encoder
{
	if (! [encoder allowsKeyedCoding]) {
		NSLog(@"In MMDBModelImporter -encodeWithCoder : Unable to encode to a non-keyed encoder!!, will not perform encoding!!");
		return;
	}
	[encoder encodeConditionalObject:[self model] forKey:@"MMmodel"];
	[encoder encodeObject:[self classPrefix] forKey:@"MMclassPrefix"];
	[encoder encodeObject:[self tablePrefix] forKey:@"MMtablePrefix"];
	[encoder encodeBool:[self overwrite] forKey:@"MMoverwrite"];
	[encoder encodeObject:[self protocol] forKey:@"MMprotocol"];
	[encoder encodeObject:[self host] forKey:@"MMhost"];
	[encoder encodeObject:[self username] forKey:@"MMusername"];
	[encoder encodeObject:[self password] forKey:@"MMpassword"];
	[encoder encodeObject:[self dbName] forKey:@"MMdbName"];
}

#pragma mark Utility methods
- (NSString *) classNameFromTableName:(NSString *) tableName
{
	NSMutableString	*className = [NSMutableString stringWithString:classPrefix];
	NSArray				*components = [tableName componentsSeparatedByString:@"_"];
	unsigned int		i = 0;
	
	if ((tablePrefix) && ([tablePrefix length])) { // Try to remove the table prefix (and _)
		if ([tablePrefix isEqualToString:(NSString *)[components objectAtIndex:0]]) {
			i = 1;
		}
	}
	for (; i<[components count]; ++i) {
		[className appendString:[(NSString *)[components objectAtIndex:i] capitalizedString]];
	}
	
	return [NSString stringWithString:className];
}

- (NSString *) attributeNameFromColumnName:(NSString *) columnName
{
	NSArray				*components = [columnName componentsSeparatedByString:@"_"];
	NSMutableString	*attributeName = [NSMutableString stringWithString:(NSString *)[components objectAtIndex:0]];
	unsigned int		i;
	
	for (i=1; i<[components count]; ++i) {
		[attributeName appendString:[(NSString *)[components objectAtIndex:i] capitalizedString]];
	}
	return [NSString stringWithString:attributeName];
}

#pragma mark Actions

- (BOOL) connect
{
	NSScanner		*hostScanner = [[NSScanner alloc] initWithString:[self valueForKey:@"host"]];
	NSString			*hostname;
	int				portNumber = 0;
	
	if (connection) {
		[connection release];
	}
	[hostScanner scanUpToString:@":" intoString:&hostname];
	if ([hostScanner scanString:@":" intoString:nil]) { // There is one ':', so get the port
		[hostScanner scanInt:&portNumber];
	}
	connection = [[MCPConnection alloc] initToHost:hostname withLogin:[self valueForKey:@"username"] password:[self valueForKey:@"password"] usingPort:portNumber];
	[hostScanner release];
	return [connection isConnected];
}

- (unsigned int) getTablesFromDB
{
	MCPResult		*queryResult;
	unsigned int	i;
	
	if (! [connection isConnected]) {
		return 0;
	}
	if (! [connection selectDB:[self dbName]]) {
		return 0;
	}
	queryResult = [connection listTables];
	[tables removeAllObjects];
	NSLog(@"in -[MMDBModelImporter getTablesFromDB], the table list is : %@", queryResult);
//   [self willChangeValueForKey:@"tables"];
	for (i=0; i<[queryResult numOfRows]; ++i) {
		NSMutableDictionary		*aTableEntry = [NSMutableDictionary dictionary];
		NSArray						*row = [queryResult fetchRowAsArray];
		
		[aTableEntry setValue:[row objectAtIndex:0] forKey:@"tableName"];
		[aTableEntry setValue:[self classNameFromTableName:(NSString *)[row objectAtIndex:0]] forKey:@"className"];
		[aTableEntry setValue:[NSNumber numberWithBool:YES] forKey:@"importClassDescription"];
		[self insertObject:aTableEntry inTablesAtIndex:[tables count]];
	}
//   [self didChangeValueForKey:@"tables"];
//	NSLog(@"in -[MMDBModelImporter getTablesFromDB], the table array (just after preparation) is : %@", tables);
	return [tables count];
}

- (BOOL) prepareNextTable
{
	unsigned int      index;
	
	index = (currentTable) ? [tables indexOfObjectIdenticalTo:currentTable]+1 : 0;
	if (NSNotFound == index) {
		[self setCurrentTable:nil];
		return NO;
	}
	while ((index != [tables count]) && (! [(NSNumber *)[(NSMutableDictionary *)[tables objectAtIndex:index] valueForKey:@"importClassDescription"] boolValue])) {
		++index;
	}
	if ([tables count] == index) {
		[self setCurrentTable:nil];
		return NO;
	}
	[self setCurrentTable:[tables objectAtIndex:index]];
	return YES;
}

- (BOOL) preparePreviousTable
{
	unsigned int      index;
	
	index = (currentTable) ? [tables indexOfObjectIdenticalTo:currentTable] : [tables count];
	if ((! index) || (NSNotFound == index)) {
		[self setCurrentTable:nil];
		return NO;
	}
	--index;
	while ((index != 0) && (! [(NSNumber *)[(NSMutableDictionary *)[tables objectAtIndex:index] valueForKey:@"importClassDescription"] boolValue])) {
		--index;
	}
	if ((0 == index) && (! [(NSNumber *)[(NSMutableDictionary *)[tables objectAtIndex:index] valueForKey:@"importClassDescription"] boolValue])) {
		[self setCurrentTable:nil];
		return NO;
	}
	[self setCurrentTable:(NSMutableDictionary *)[tables objectAtIndex:index]];
	return YES;
}

- (BOOL) prepareForImportCurrentTable
{
	NSMutableArray    *theAttributes;
	MCPResult			*theResult;
	unsigned int		i;
	
	if (! currentTable) {
		return NO;
	}
	if ([currentTable valueForKey:@"attributes"]) { // Allready ready...
		return YES;
	}
	theAttributes = [[NSMutableArray alloc] init];
	theResult = [connection listFieldsFromTable:[currentTable valueForKey:@"tableName"]];
//	NSLog(@"In -[MMDBModelImporter prepareForImportCurrentTable], got the attributes of table %@ : %@", [currentTable valueForKey:@"tableName"], theResult);
	for (i=0; i != [theResult numOfRows]; ++i) {
		NSMutableDictionary		*theAttributeDict = [[NSMutableDictionary alloc] init];
		NSDictionary            *theRow = [theResult fetchRowAsDictionary];
		NSScanner					*theFullType = [NSScanner scannerWithString:[theRow valueForKey:@"Type"]];
		NSString						*theType = nil;
		NSString						*thePrecision = nil;
		
		[theAttributeDict setValue:[theRow valueForKey:@"Field"] forKey:@"externalName"];
		[theAttributeDict setValue:[self attributeNameFromColumnName:[theRow valueForKey:@"Field"]] forKey:@"name"];
		[theFullType scanUpToString:@"(" intoString:&theType];
		if ([theFullType scanString:@"(" intoString:nil]) { // Gets the precision string
			[theFullType scanUpToString:@")" intoString:&thePrecision];
			[theAttributeDict setValue:thePrecision forKey:@"width"];
		}
		else {
			[theAttributeDict setValue:@"0" forKey:@"width"];
		}
		[theAttributeDict setValue:[theType uppercaseString] forKey:@"externalType"];
		if ( ([theType isEqualToString:@"int"]) || ([theType isEqualToString:@"decimal"])  || ([theType isEqualToString:@"bigint"]) || ([theType isEqualToString:@"smallint"]) || ([theType isEqualToString:@"float"]) || ([theType isEqualToString:@"double"]) ) {
			[theAttributeDict setValue:@"NSNumber" forKey:@"internalType"];
		}
		if (([theType isEqualToString:@"date"]) || ([theType isEqualToString:@"datetime"]) || ([theType isEqualToString:@"timestamp"]) || ([theType isEqualToString:@"year"])) {
			[theAttributeDict setValue:@"NSCalendarDate" forKey:@"internalType"];
		}
		if (([theType isEqualToString:@"char"]) || ([theType isEqualToString:@"varchar"]) || ([theType isEqualToString:@"tinytext"]) || ([theType isEqualToString:@"text"]) || ([theType isEqualToString:@"mediumtext"]) || ([theType isEqualToString:@"longtext"]) || ([theType isEqualToString:@"enum"]) || ([theType isEqualToString:@"set"])) {
			[theAttributeDict setValue:@"NSString" forKey:@"internalType"];
		}
		if (([theType isEqualToString:@"tinyblob"]) || ([theType isEqualToString:@"blob"]) || ([theType isEqualToString:@"mediumblob"]) || ([theType isEqualToString:@"longblob"])) {
			[theAttributeDict setValue:@"NSData" forKey:@"internalType"];
		}
		if ([(NSString *)[theRow valueForKey:@"Null"] isEqualToString:@"YES"]) {
			[theAttributeDict setValue:[NSNumber numberWithBool:YES] forKey:@"allowsNull"];
		}
		else {
			[theAttributeDict setValue:[NSNumber numberWithBool:NO] forKey:@"allowsNull"];
		}
		if (([theType isEqualToString:@"timestamp"]) || ([(NSString *)[theRow valueForKey:@"Extra"] isEqualToString:@"auto_increment"])) {
			[theAttributeDict setValue:[NSNumber numberWithBool:YES] forKey:@"autoGenerated"];
		}
		else {
			[theAttributeDict setValue:[NSNumber numberWithBool:NO] forKey:@"autoGenerated"];
		}
		if ([(NSString *)[theRow valueForKey:@"Key"] isEqualToString:@"PRI"]) {
			[theAttributeDict setValue:[NSNumber numberWithBool:YES] forKey:@"isPartOfKey"];
		}
		else {
			[theAttributeDict setValue:[NSNumber numberWithBool:NO] forKey:@"isPartOfKey"];
		}
		[theAttributeDict setValue:[NSNumber numberWithBool:(! [[theAttributeDict valueForKey:@"isPartOfKey"] boolValue])] forKey:@"hasAccessor"];
#warning Should continue coding here... Still have to find the identity...
		[theAttributeDict setValue:[NSNumber numberWithBool:NO] forKey:@"isPartOfIdentity"];
		[theAttributeDict setValue:[theRow valueForKey:@"Default"] forKey:@"defaultValue"];
		[theAttributes insertObject:theAttributeDict atIndex:[theAttributes count]];
		[theAttributeDict release];
	}
	if (! [self overwrite]) { // If we should not averwrite, the easiest is to re import the model from the model again...
		MCPClassDescription	*theClassDescription = [model objectInClassDescriptionsAtIndex:[model indexOfClassDescription:[currentTable valueForKey:@"className"]]];
//		MCPClassDescription  *theClassDescription = [model classDescriptionWithClassName:[currentTable valueForKey:@"className"]];
		
		if (theClassDescription) { // "Reimport" the class description itself...
			[currentTable setValue:[theClassDescription externalName] forKey:@"tableName"];
			for (i = 0; i != [theClassDescription countOfAttributes]; ++i) {
				MCPAttribute         *theAttribute = [theClassDescription objectInAttributesAtIndex:i];
				NSMutableDictionary  *theAttributeDict = nil;
				unsigned int         j;
				
				for (j = 0; j != [theAttributes count]; ++j) { // Find the dictionary corresponding to 
					if ([[theAttribute name] isEqualToString:[(NSMutableDictionary *)[theAttributes objectAtIndex:j] valueForKey:@"name"]]) {
						theAttributeDict = (NSMutableDictionary *)[theAttributes objectAtIndex:j];
						break;
					}
				}
				if (! theAttributeDict) {
					theAttributeDict = [[NSMutableDictionary alloc] init];
					[theAttributes insertObject:theAttributeDict atIndex:[theAttributes count]];
					[theAttributeDict setValue:[theAttribute name] forKey:@"name"];
					[theAttributeDict release];
				}
				[theAttributeDict setValue:[theAttribute internalType] forKey:@"internalType"];
				[theAttributeDict setValue:[theAttribute externalName] forKey:@"externalName"];
				[theAttributeDict setValue:[theAttribute externalType] forKey:@"externalType"];
//            [theAttributeDict setValue:[NSNumber numberWithUnsignedInt:[theAttribute width]] forKey:@"width"]; // No stored as a number but as a string in the dictionary...
				[theAttributeDict setValue:[NSString stringWithFormat:@"%u", [theAttribute width]] forKey:@"width"];
				[theAttributeDict setValue:[NSNumber numberWithBool:[theAttribute allowsNull]] forKey:@"allowsNull"];
				[theAttributeDict setValue:[NSNumber numberWithBool:[theAttribute autoGenerated]] forKey:@"autoGenerated"];
				[theAttributeDict setValue:[NSNumber numberWithBool:[theAttribute isPartOfKey]] forKey:@"isPartOfKey"];
				[theAttributeDict setValue:[NSNumber numberWithBool:[theAttribute isPartOfIdentity]] forKey:@"isPartOfIdentity"];
				[theAttributeDict setValue:[NSNumber numberWithBool:[theAttribute hasAccessor]] forKey:@"hasAccessor"];
			}
		}
	}
	[currentTable setValue:theAttributes forKey:@"attributes"];
	[theAttributes release];
	return YES;
}

- (BOOL) importTables
{
	unsigned int      i;
	
#warning Should check for overwrite or not... now will never overwrite.
	for (i=0; i != [tables count]; ++i) {
		NSMutableDictionary     *theTable = (NSMutableDictionary *)[tables objectAtIndex:i];
		if ([(NSNumber *)[theTable valueForKey:@"importClassDescription"] boolValue]) { // We have to import this table.
			MCPClassDescription     *theClassDescription = [model objectInClassDescriptionsAtIndex:[model indexOfClassDescription:[theTable valueForKey:@"className"]]];
			NSArray                 *theAttributes = (NSArray *)[theTable valueForKey:@"attributes"];
			unsigned int   j;
			
			if (([self overwrite]) || (! theClassDescription)) { // We have to (erase and then) create a new Class Description
				if (theClassDescription) { // Do we have to delete it first...
//					[model removeClassDescription:theClassDescription];
					[model removeObjectFromClassDescriptionsAtIndex:[model indexOfClassDescription:theClassDescription]];
					theClassDescription = nil;
				}
				theClassDescription = [[MCPClassDescription alloc] initInModel:[self model] withName:(NSString *)[theTable valueForKey:@"className"]];
				[theClassDescription setExternalName:(NSString *)[theTable valueForKey:@"tableName"]];
				for (j=0; j != [theAttributes count]; ++j) {
					NSDictionary      *theAttributeDict = (NSDictionary *)[theAttributes objectAtIndex:j];
					MCPAttribute       *theAttribute = [[MCPAttribute alloc] initForClassDescription:theClassDescription withName:(NSString *)[theAttributeDict valueForKey:@"name"]];
					unsigned int      theWidth;
					
					[theAttribute setInternalType:(NSString *)[theAttributeDict valueForKey:@"internalType"]];
#pragma warning What to do about the valueClass ... should be done by setInternalType...
					[theAttribute setExternalName:(NSString *)[theAttributeDict valueForKey:@"externalName"]];
					[theAttribute setExternalType:(NSString *)[theAttributeDict valueForKey:@"externalType"]];
					[[NSScanner scannerWithString:(NSString *)[theAttributeDict valueForKey:@"width"]] scanInt:&theWidth];
					[theAttribute setWidth:theWidth];
					[theAttribute setAllowsNull:[(NSNumber *)[theAttributeDict valueForKey:@"allowsNull"] boolValue]];
					[theAttribute setAutoGenerated:[(NSNumber *)[theAttributeDict valueForKey:@"autoGenerated"] boolValue]];
					[theAttribute setIsPartOfKey:[(NSNumber *)[theAttributeDict valueForKey:@"isPartOfKey"] boolValue]];
					[theAttribute setIsPartOfIdentity:[(NSNumber *)[theAttributeDict valueForKey:@"isPartOfIdentity"] boolValue]];
					[theAttribute setHasAccessor:[(NSNumber *)[theAttributeDict valueForKey:@"hasAccessor"] boolValue]];
#pragma warning Should take care of the default value...
					[theClassDescription insertObject:theAttribute inAttributesAtIndex:[theClassDescription countOfAttributes]];
				}
				[model insertObject:theClassDescription inClassDescriptionsAtIndex:[model countOfClassDescriptions]];
			}
			else { // Keep as much of the class description as possible, just add new things (attributes)
//				theClassDescription = [model classDescriptionWithClassName:[theTable valueForKey:@"className"]];
				
				for (j=0; j!=[theAttributes count]; ++j) {
					NSDictionary      *theAttributeDict = (NSDictionary *)[theAttributes objectAtIndex:j];
					MCPAttribute		*theAttribute;
					unsigned int      theWidth;

					[[NSScanner scannerWithString:(NSString *)[theAttributeDict valueForKey:@"width"]] scanInt:&theWidth]; // Get the width anyway...
//					if (! (theAttribute = [theClassDescription attributeWithName:[theAttributeDict valueForKey:@"name"]])) { // The attribute was not already existing
					if (! (theAttribute = [theClassDescription objectInAttributesAtIndex:[theClassDescription indexOfAttribute:[theAttributeDict valueForKey:@"name"]]])) { // The attribute was not already existing
						theAttribute = [[MCPAttribute alloc] initForClassDescription:theClassDescription withName:(NSString *)[theAttributeDict valueForKey:@"name"]];
						
						[theAttribute setInternalType:(NSString *)[theAttributeDict valueForKey:@"internalType"]];
#pragma warning What to do about the valueClass ... should be done by setInternalType...
						[theAttribute setExternalName:(NSString *)[theAttributeDict valueForKey:@"externalName"]];
						[theAttribute setExternalType:(NSString *)[theAttributeDict valueForKey:@"externalType"]];
						[theAttribute setWidth:theWidth];
						[theAttribute setAllowsNull:[(NSNumber *)[theAttributeDict valueForKey:@"allowsNull"] boolValue]];
						[theAttribute setAutoGenerated:[(NSNumber *)[theAttributeDict valueForKey:@"autoGenerated"] boolValue]];
						[theAttribute setIsPartOfKey:[(NSNumber *)[theAttributeDict valueForKey:@"isPartOfKey"] boolValue]];
						[theAttribute setIsPartOfIdentity:[(NSNumber *)[theAttributeDict valueForKey:@"isPartOfIdentity"] boolValue]];
						[theAttribute setHasAccessor:[(NSNumber *)[theAttributeDict valueForKey:@"hasAccessor"] boolValue]];
#pragma warning Should take care of the default value...
						[theClassDescription insertObject:theAttribute inAttributesAtIndex:[theClassDescription countOfAttributes]];
					}
					else { // Attribute already existing
						[theAttribute setInternalType:(NSString *)[theAttributeDict valueForKey:@"internalType"]];
#pragma warning What to do about the valueClass ... should be done by setInternalType...
						[theAttribute setExternalName:(NSString *)[theAttributeDict valueForKey:@"externalName"]];
						[theAttribute setExternalType:(NSString *)[theAttributeDict valueForKey:@"externalType"]];
						[theAttribute setWidth:theWidth];
						[theAttribute setAllowsNull:[(NSNumber *)[theAttributeDict valueForKey:@"allowsNull"] boolValue]];
						[theAttribute setAutoGenerated:[(NSNumber *)[theAttributeDict valueForKey:@"autoGenerated"] boolValue]];
						[theAttribute setIsPartOfKey:[(NSNumber *)[theAttributeDict valueForKey:@"isPartOfKey"] boolValue]];
						[theAttribute setIsPartOfIdentity:[(NSNumber *)[theAttributeDict valueForKey:@"isPartOfIdentity"] boolValue]];
						[theAttribute setHasAccessor:[(NSNumber *)[theAttributeDict valueForKey:@"hasAccessor"] boolValue]];
#pragma warning Should take care of the default value...
						// No need to add the attribute to the class description... is is already there.
					}
				}
			}
		}
	}
	return YES;
}

#pragma mark Setters
- (void) setModel:(MCPModel *) iModel
{
	if (iModel != model) {
		[model release];
		model = [iModel retain];
	}
}

- (void) setClassPrefix:(NSString *) iClassPrefix
{
	if (iClassPrefix != classPrefix) {
		[classPrefix release];
		classPrefix = [iClassPrefix retain];
	}
}

- (void) setTablePrefix:(NSString *) iTablePrefix
{
	if (iTablePrefix != tablePrefix) {
		[tablePrefix release];
		tablePrefix = [iTablePrefix retain];
	}
}

- (void) setOverwrite:(BOOL) iOverwrite
{
	overwrite = iOverwrite;
}

- (void) setProtocol:(NSString *) iProtocol
{
	if (iProtocol != protocol) {
		[protocol release];
		protocol = [iProtocol retain];
	}
}

- (void) setHost:(NSString *) iHost
{
	if (iHost != host) {
		[host release];
		host = [iHost retain];
	}
}

- (void) setUsername:(NSString *) iUsername
{
	if (iUsername != username) {
		[username release];
		username = [iUsername retain];
	}
}

- (void) setPassword:(NSString *) iPassword
{
	if (iPassword != password) {
		[password release];
		password = [iPassword retain];
	}
}

- (void) setDbName:(NSString *) iDbName
{
	if (iDbName != dbName) {
		[dbName release];
		dbName = [iDbName retain];
	}
}

#pragma mark Getters
- (MCPModel *) model
{
	return model;
}

- (NSString *) classPrefix
{
	return classPrefix;
}

- (NSString *) tablePrefix
{
	return tablePrefix;
}

- (BOOL) overwrite
{
	return overwrite;
}

- (NSMutableArray *) tables
{
	return tables;
}

- (unsigned int) countOfTables
{
	return [tables count];
}

- (NSMutableDictionary *) objectInTablesAtIndex:(unsigned int) index
{
	return [tables objectAtIndex:index];
}

- (NSMutableDictionary *) currentTable
{
	return currentTable;
}

- (MCPConnection *) connection
{
	return connection;
}

- (NSString *) protocol
{
	return protocol;
}

- (NSString	*) host
{
	return host;
}

- (NSString	*) username
{
	return username;
}

- (NSString	*) password
{
	return password;
}

- (NSString	*) dbName
{
	return dbName;
}

#pragma mark For logging and debugging
- (NSString *) description
{
	NSMutableString	*theDescription = [NSMutableString stringWithFormat:@"MMDBModelImporter, for model named %@\n", [[self model] name]];
	
	[theDescription appendFormat:@"\t- class prefix is : %@\n", [self classPrefix]];
	[theDescription appendFormat:@"\t- table prefix is : %@\n", [self tablePrefix]];
	[theDescription appendFormat:@"\t- overwrite set to : %@\n", ([self overwrite]) ? @"YES" : @"NO" ];
	[theDescription appendString:@"connecting to DB server using :\n"];
	[theDescription appendFormat:@"\t- protocol used : %@\n", [self protocol]];
	[theDescription appendFormat:@"\t- host used : %@\n", [self host]];
	[theDescription appendFormat:@"\t- user name used : %@\n", [self username]];
	[theDescription appendFormat:@"\t- db name used : %@\n", [self dbName]];
	[theDescription appendString:@"current list of table to handle :*****************************\n"];
	[theDescription appendString:[tables description]];
	[theDescription appendString:@"\n*******************************************************\n"];
	return theDescription;
}

@end

@implementation MMDBModelImporter (Private)

- (void) insertObject:(NSMutableDictionary *) table inTablesAtIndex:(unsigned int) index
{
	[tables insertObject:table atIndex:index];
}

- (void) removeObjectFromTablesAtIndex:(unsigned int) index
{
	[tables removeObjectAtIndex:index];
}

- (void) setCurrentTable:(NSMutableDictionary *) iCurrentTable
{
	if (iCurrentTable != currentTable) {
		[currentTable release];
		currentTable = [iCurrentTable retain];
	}
}


@end
