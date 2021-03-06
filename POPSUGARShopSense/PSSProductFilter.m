//
//  PSSProductFilter.m
//
//  Copyright (c) 2013 POPSUGAR Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "PSSProductFilter.h"
#import "POPSUGARShopSense.h"

NSString * const PSSProductFilterTypeBrand = @"Brand";
NSString * const PSSProductFilterTypeRetailer = @"Retailer";
NSString * const PSSProductFilterTypePrice = @"Price";
NSString * const PSSProductFilterTypeDiscount = @"Discount";
NSString * const PSSProductFilterTypeSize = @"Size";
NSString * const PSSProductFilterTypeColor = @"Color";

@interface PSSProductFilter ()

@property (nonatomic, copy, readwrite) NSString *type;
@property (nonatomic, copy, readwrite) NSNumber *filterID;

@end

@implementation PSSProductFilter

#pragma mark - Init

+ (instancetype)filterWithType:(NSString *)type filterID:(NSNumber *)filterID
{
	return [[[self class] alloc] initWithType:type filterID:filterID];
}

- (instancetype)initWithType:(NSString *)type filterID:(NSNumber *)filterID
{
	NSParameterAssert(filterID != nil);
	NSParameterAssert(type != nil);
	NSAssert([[self class] isValidType:type], @"You must choose a type from the supplied constants.");
	self = [super init];
	if (self) {
		_filterID = [filterID copy];
		_type = [type copy];
	}
	return self;
}

#pragma mark - type

+ (BOOL)isValidType:(NSString *)type
{
	return ([type isEqualToString:PSSProductFilterTypeBrand] || [type isEqualToString:PSSProductFilterTypeRetailer] || [type isEqualToString:PSSProductFilterTypePrice] || [type isEqualToString:PSSProductFilterTypeDiscount] || [type isEqualToString:PSSProductFilterTypeSize] || [type isEqualToString:PSSProductFilterTypeColor]);
}

- (void)setType:(NSString *)type
{
	NSParameterAssert(type != nil);
	NSAssert([[self class] isValidType:type], @"You must choose a type from the supplied constants.");
	if (![type isEqualToString:self.type]) {
		_type = [type copy];
	}
}

#pragma mark - Conversion to URL Query Parameters

- (NSString *)typePrefixForQueryParameterRepresentation
{
	// Filter prefixes are:
	// b - brand
	// r - retailer
	// p - price
	// d - discount
	// s - size
	// c - color
	NSString *prefix = @"";
	if ([self.type isEqualToString:PSSProductFilterTypeBrand]) {
		prefix = @"b";
	} else if ([self.type isEqualToString:PSSProductFilterTypeRetailer]) {
		prefix = @"r";
	} else if ([self.type isEqualToString:PSSProductFilterTypePrice]) {
		prefix = @"p";
	} else if ([self.type isEqualToString:PSSProductFilterTypeDiscount]) {
		prefix = @"d";
	} else if ([self.type isEqualToString:PSSProductFilterTypeSize]) {
		prefix = @"s";
	} else if ([self.type isEqualToString:PSSProductFilterTypeColor]) {
		prefix = @"c";
	}
	return prefix;
}

- (NSString *)queryParameterRepresentation
{
	return [[self typePrefixForQueryParameterRepresentation] stringByAppendingString: self.filterID.stringValue];
}

#pragma mark - NSObject

- (NSString *)description
{
	return [[super description] stringByAppendingFormat:@" %@", [self queryParameterRepresentation]];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
	PSSDLog(@"Warning: Undefined Key Named '%@'", key);
}

- (NSUInteger)hash
{
	// a very simple hash
	NSUInteger hash = 0;
	hash ^= self.type.hash;
	hash ^= self.filterID.hash;
	return hash;
}

- (BOOL)isEqual:(id)object
{
	if (object == self) {
		return YES;
	}
	if (object == nil || ![object isKindOfClass:[self class]]) {
		return NO;
	}
	return ([self.filterID isEqualToNumber:[(PSSProductFilter *)object filterID]] && [self.type isEqualToString:[(PSSProductFilter *)object type]]);
}

#pragma mark - PSSRemoteObject

+ (instancetype)instanceFromRemoteRepresentation:(NSDictionary *)representation
{
	if (representation.count == 0) {
		return nil;
	}
	if (representation[@"id"] == nil || representation[@"type"] == nil) {
		return nil;
	}
	id value = representation[@"id"];
	NSNumber *filterID = nil;
	if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
		filterID = [NSNumber numberWithInteger:[[value description] integerValue]];
	}
	if (filterID == nil) {
		return nil;
	}
	NSString *type = representation[@"type"];
	if (![[self class] isValidType:type]) {
		return nil;
	}
	PSSProductFilter *instance = [[[self class] alloc] initWithType:type filterID:filterID];
	NSMutableDictionary *cleanRep = [representation mutableCopy];
	[cleanRep removeObjectsForKeys:@[ @"id", @"type" ]];
	[instance setPropertiesWithDictionary:cleanRep];
	return instance;
}

- (void)setPropertiesWithDictionary:(NSDictionary *)aDictionary
{
	for (NSString *key in aDictionary) {
		id value = [aDictionary valueForKey:key];
		if ([key isEqualToString:@"url"]) {
			if ([value isKindOfClass:[NSString class]]) {
				self.browseURL = [NSURL URLWithString:value];
			}
		} else if ([key isEqualToString:@"count"]) {
			if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
				self.productCount = [NSNumber numberWithInteger:[[value description] integerValue]];
			}
		} else {
			[self setValue:value forKey:key];
		}
	}
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeObject:self.name forKey:@"name"];
	[encoder encodeObject:self.filterID forKey:@"filterID"];
	[encoder encodeObject:self.browseURL forKey:@"browseURL"];
	[encoder encodeObject:self.type forKey:@"type"];
	[encoder encodeObject:self.productCount forKey:@"productCount"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
	if ((self = [self init])) {
		self.name = [decoder decodeObjectForKey:@"name"];
		self.filterID = [decoder decodeObjectForKey:@"filterID"];
		self.browseURL = [decoder decodeObjectForKey:@"browseURL"];
		self.type = [decoder decodeObjectForKey:@"type"];
		self.productCount = [decoder decodeObjectForKey:@"productCount"];
	}
	return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
	typeof(self) copy = [[[self class] allocWithZone:zone] init];
	copy.filterID = self.filterID;
	copy.type = self.type;
	copy.name = self.name;
	copy.browseURL = self.browseURL;
	copy.productCount = self.productCount;
	return copy;
}

@end
