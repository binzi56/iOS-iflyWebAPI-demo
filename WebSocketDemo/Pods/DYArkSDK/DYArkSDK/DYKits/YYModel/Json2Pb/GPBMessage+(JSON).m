//
//  GPBMessage+(JSON).m
//  Wolf
//
//  Created by huang pengfei on 2017/11/16.
//  Copyright © 2017年 com.mewe.party. All rights reserved.
//

#import "GPBMessage+(JSON).h"
#import "GPBUtilities.h"
//#import "WFBaseMacro.h"

@implementation GPBMessage (JSON)

#pragma mark - json2pb

+ (void)json2fieldInternal:(GPBMessage*)msg
                     field:(GPBFieldDescriptor*)field
                jsonObject:(id)jf
                    keyMap:(NSDictionary*)keyMap
{
    BOOL repeated = ([field fieldType] == GPBFieldTypeRepeated);
    
    switch ([field dataType]) {
            
#define __SET_OR_ADD(sfunc, value, arraytype)                                  \
do {                                                                         \
if (repeated) {                                                            \
arraytype *array = GPBGetMessageRepeatedField(msg, field);               \
if ([array respondsToSelector:@selector(addValue:)]) {                   \
[array addValue:value];                                                \
} else {                                                                 \
assert(0);                                                             \
}                                                                        \
} else {                                                                   \
sfunc(msg, field, value);                                                \
}                                                                          \
} while (0);
#define __CASE(type, arraytype, sfunc, value)                             \
case type: {                                                                 \
__SET_OR_ADD(sfunc, value, arraytype);                                     \
break;                                                                     \
}
            
            __CASE(GPBDataTypeDouble, GPBDoubleArray, GPBSetMessageDoubleField, [jf doubleValue]);
            __CASE(GPBDataTypeFloat, GPBFloatArray,GPBSetMessageFloatField, [jf floatValue]);
            __CASE(GPBDataTypeInt64,  GPBInt64Array,GPBSetMessageInt64Field, [jf longLongValue]);
            
            __CASE(GPBDataTypeSFixed64, GPBInt64Array,GPBSetMessageInt64Field, [jf longLongValue]);
            __CASE(GPBDataTypeSInt64, GPBInt64Array,GPBSetMessageInt64Field, [jf longLongValue]);
            __CASE(GPBDataTypeUInt64,GPBUInt64Array,GPBSetMessageUInt64Field, [jf unsignedLongLongValue]);
            __CASE(GPBDataTypeFixed64,GPBUInt64Array,GPBSetMessageUInt64Field, [jf unsignedLongLongValue]);
            __CASE(GPBDataTypeInt32,GPBInt32Array,GPBSetMessageInt32Field, [jf intValue]);
            __CASE(GPBDataTypeSInt32,GPBInt32Array,GPBSetMessageInt32Field, [jf intValue]);
            __CASE(GPBDataTypeSFixed32,GPBInt32Array,GPBSetMessageInt32Field, [jf intValue]);
            __CASE(GPBDataTypeUInt32,GPBUInt32Array,GPBSetMessageUInt32Field, [jf unsignedIntValue]);
            __CASE(GPBDataTypeFixed32,GPBUInt32Array,GPBSetMessageUInt32Field, [jf unsignedIntValue]);
            __CASE(GPBDataTypeBool,GPBBoolArray,GPBSetMessageBoolField, [jf boolValue]);
#undef __SET_OR_ADD
#undef __CASE
            
#define __SET_OR_ADD(sfunc, value, arraytype)                                  \
do {                                                                         \
if (repeated) {                                                            \
arraytype *array = GPBGetMessageRepeatedField(msg, field);               \
if ([array respondsToSelector:@selector(addObject:)]) {                  \
[array addObject:value];                                               \
} else {                                                                 \
}                                                                        \
} else {                                                                   \
sfunc(msg, field, value);                                                \
}                                                                          \
} while (0);
            
        case GPBDataTypeString:
        {
            if ([jf isKindOfClass:[NSString class]]) {
                NSString* string = jf;
                __SET_OR_ADD(GPBSetMessageStringField, string, NSMutableArray);
            } else {
                
                NSAssert(NO, @"fdf");
            }
        }
            break;
        case GPBDataTypeBytes:
        {
            if ([jf isKindOfClass:[NSString class]]) {
                NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:jf options:0];
                __SET_OR_ADD(GPBSetMessageBytesField, decodedData, NSMutableArray);
            } else {
                NSAssert(NO, @"unexpected");
            }
        }
            break;
        case GPBDataTypeMessage:
        {
            GPBMessage* mf = nil;
            
            if (repeated) {
                NSMutableArray* array = GPBGetMessageRepeatedField(msg, field);
                
                if ([array respondsToSelector:@selector(addObject:)]) {
                    mf = [[field.msgClass alloc] init];
                    [self json2pbInternal:mf dict:jf map:nil];
                    [array addObject:mf];
                }
            } else if ([field fieldType] == GPBFieldTypeMap) {
                
                NSAssert(NO, @"unexpected here");
            
                
            } else {
                
                mf = [[field.msgClass alloc] init];
                
                if ([jf isKindOfClass:[NSDictionary class]]) {
                    [self json2pbInternal:mf dict:jf map:keyMap];
                }
                
                GPBSetMessageMessageField(msg, field, mf);
            }
        }
            break;
        case GPBDataTypeEnum:
        {
            GPBEnumDescriptor* ed = field.enumDescriptor;
            int32_t value = 0;
            if ([jf isKindOfClass:[NSNumber class]]) {
                value = [jf unsignedIntValue];
            } else if ([jf isKindOfClass:[NSString class]]) {
                BOOL ret = [ed getValue:&value
                  forEnumTextFormatName:jf];
                NSAssert(ret, @"should be NSString");
            } else {
                
            }
            if (repeated) {
                GPBEnumArray* array = GPBGetMessageRepeatedField(msg, field);
                [array addRawValue:value];
            } else {
                GPBSetMessageEnumField(msg, field,value);
            }
        }
            break;
        default:
            break;
    }
}

+ (void)json2MapfieldInternal:(GPBMessage*)msg
                        field:(GPBFieldDescriptor*)field
                          key:(id)jsonKey
                   jsonObject:(id)jsonObject
                       keyMap:(NSDictionary*)keyMap
{
    GPBDataType mapkeyType = [field mapKeyDataType];
    GPBDataType dataType = [field dataType];
    id pbObject = nil;
    
    if (dataType == GPBDataTypeMessage) {
        pbObject = [[field.msgClass alloc] init];
        [self json2pbInternal:pbObject dict:jsonObject map:keyMap];
    } else if (dataType == GPBDataTypeString) {
        pbObject = jsonObject;
    }
    
#define WFGPB_MAP_CASE(keyType , dType, keyValue, dataValue) \
if (mapkeyType == GPBDataType##keyType && dataType == GPBDataType##dType ) { \
        metamacro_concat(GPB, metamacro_concat(keyType,metamacro_concat(dType,Dictionary)))* dict = GPBGetMessageMapField(msg, field); \
        [dict metamacro_concat(set,dType):dataValue forKey:keyValue]; \
    }\

#define WFGPB_MAP_OBJECT_CASE(keyType , keyValue, dataValue) \
if (mapkeyType == GPBDataType##keyType && (dataType == GPBDataTypeMessage || dataType == GPBDataTypeString) ) { \
        metamacro_concat(GPB, metamacro_concat(keyType,ObjectDictionary))* dict = GPBGetMessageMapField(msg, field); \
        [dict setObject:dataValue forKey:keyValue]; \
    }\

    WFGPB_MAP_CASE(UInt32,UInt32,[jsonKey unsignedIntValue],[jsonObject unsignedIntValue]);
    WFGPB_MAP_CASE(UInt32,Int32,[jsonKey unsignedIntValue],[jsonObject intValue]);
    WFGPB_MAP_CASE(UInt32,UInt64,[jsonKey unsignedIntValue],[jsonObject unsignedLongLongValue]);
    WFGPB_MAP_CASE(UInt32,Int64,[jsonKey unsignedIntValue],[jsonObject longLongValue]);
    WFGPB_MAP_CASE(UInt32,Bool,[jsonKey unsignedIntValue],[jsonObject boolValue]);
    WFGPB_MAP_CASE(UInt32,Float,[jsonKey unsignedIntValue],[jsonObject floatValue]);
    WFGPB_MAP_CASE(UInt32,Double,[jsonKey unsignedIntValue],[jsonObject doubleValue]);
    WFGPB_MAP_CASE(UInt32,Enum,[jsonKey unsignedIntValue],[jsonObject intValue]);
    WFGPB_MAP_OBJECT_CASE(UInt32, [jsonKey unsignedIntValue], pbObject);
    

    WFGPB_MAP_CASE(Int32,UInt32,[jsonKey intValue],[jsonObject unsignedIntValue]);
    WFGPB_MAP_CASE(Int32,Int32,[jsonKey intValue],[jsonObject intValue]);
    WFGPB_MAP_CASE(Int32,UInt64,[jsonKey intValue],[jsonObject unsignedLongLongValue]);
    WFGPB_MAP_CASE(Int32,Int64,[jsonKey intValue],[jsonObject longLongValue]);
    WFGPB_MAP_CASE(Int32,Bool,[jsonKey intValue],[jsonObject boolValue]);
    WFGPB_MAP_CASE(Int32,Float,[jsonKey intValue],[jsonObject floatValue]);
    WFGPB_MAP_CASE(Int32,Double,[jsonKey intValue],[jsonObject doubleValue]);
    WFGPB_MAP_CASE(Int32,Enum,[jsonKey intValue],[jsonObject intValue]);
    WFGPB_MAP_OBJECT_CASE(Int32, [jsonKey intValue], pbObject);
    
    WFGPB_MAP_CASE(UInt64,UInt32,[jsonKey unsignedLongLongValue],[jsonObject unsignedIntValue]);
    WFGPB_MAP_CASE(UInt64,Int32,[jsonKey unsignedLongLongValue],[jsonObject intValue]);
    WFGPB_MAP_CASE(UInt64,UInt64,[jsonKey unsignedLongLongValue],[jsonObject unsignedLongLongValue]);
    WFGPB_MAP_CASE(UInt64,Int64,[jsonKey unsignedLongLongValue],[jsonObject longLongValue]);
    WFGPB_MAP_CASE(UInt64,Bool,[jsonKey unsignedLongLongValue],[jsonObject boolValue]);
    WFGPB_MAP_CASE(UInt64,Float,[jsonKey unsignedLongLongValue],[jsonObject floatValue]);
    WFGPB_MAP_CASE(UInt64,Double,[jsonKey unsignedLongLongValue],[jsonObject doubleValue]);
    WFGPB_MAP_CASE(UInt64,Enum,[jsonKey unsignedLongLongValue],[jsonObject intValue]);
    WFGPB_MAP_OBJECT_CASE(UInt64, [jsonKey unsignedLongLongValue], pbObject);
    
    WFGPB_MAP_CASE(Int64,UInt32,[jsonKey longLongValue],[jsonObject unsignedIntValue]);
    WFGPB_MAP_CASE(Int64,Int32,[jsonKey longLongValue],[jsonObject intValue]);
    WFGPB_MAP_CASE(Int64,UInt64,[jsonKey longLongValue],[jsonObject unsignedLongLongValue]);
    WFGPB_MAP_CASE(Int64,Int64,[jsonKey longLongValue],[jsonObject longLongValue]);
    WFGPB_MAP_CASE(Int64,Bool,[jsonKey longLongValue],[jsonObject boolValue]);
    WFGPB_MAP_CASE(Int64,Float,[jsonKey longLongValue],[jsonObject floatValue]);
    WFGPB_MAP_CASE(Int64,Double,[jsonKey longLongValue],[jsonObject doubleValue]);
    WFGPB_MAP_CASE(Int64,Enum,[jsonKey longLongValue],[jsonObject intValue]);
    WFGPB_MAP_OBJECT_CASE(Int64, [jsonKey longLongValue], pbObject);
    
    WFGPB_MAP_CASE(Bool,UInt32,[jsonKey boolValue],[jsonObject unsignedIntValue]);
    WFGPB_MAP_CASE(Bool,Int32,[jsonKey boolValue],[jsonObject intValue]);
    WFGPB_MAP_CASE(Bool,UInt64,[jsonKey boolValue],[jsonObject unsignedLongLongValue]);
    WFGPB_MAP_CASE(Bool,Int64,[jsonKey boolValue],[jsonObject longLongValue]);
    WFGPB_MAP_CASE(Bool,Bool,[jsonKey boolValue],[jsonObject boolValue]);
    WFGPB_MAP_CASE(Bool,Float,[jsonKey boolValue],[jsonObject floatValue]);
    WFGPB_MAP_CASE(Bool,Double,[jsonKey boolValue],[jsonObject doubleValue]);
    WFGPB_MAP_CASE(Bool,Enum,[jsonKey boolValue],[jsonObject intValue]);
    WFGPB_MAP_OBJECT_CASE(Bool, [jsonKey boolValue], pbObject);
    
    WFGPB_MAP_CASE(String,UInt32,jsonKey,[jsonObject unsignedIntValue]);
    WFGPB_MAP_CASE(String,Int32,jsonKey,[jsonObject intValue]);
    WFGPB_MAP_CASE(String,UInt64,jsonKey,[jsonObject unsignedLongLongValue]);
    WFGPB_MAP_CASE(String,Int64,jsonKey,[jsonObject longLongValue]);
    WFGPB_MAP_CASE(String,Bool,jsonKey,[jsonObject boolValue]);
    WFGPB_MAP_CASE(String,Float,jsonKey,[jsonObject floatValue]);
    WFGPB_MAP_CASE(String,Double,jsonKey,[jsonObject doubleValue]);
    WFGPB_MAP_CASE(String,Enum,jsonKey,[jsonObject intValue]);
}

+ (void)json2pbInternal:(GPBMessage*)msg dict:(NSDictionary *)root map:(NSDictionary*)map
{
    GPBDescriptor* d = [msg descriptor];
    if (!d)
        [NSException exceptionWithName:@"No descriptor or reflection"
                                reason:@"No descriptor or reflection"
                              userInfo:nil];
    
    for (NSString* nameStr in root) {
        
        NSString* name = nameStr;
        
        if (map!=nil &&
            [[map objectForKey:name] isKindOfClass:[NSString class]] &&
            [[map objectForKey:name] length]!=0) {
            name = [map objectForKey:name];
        }
        GPBFieldDescriptor* field = [d fieldWithName:name];
        if (!field) {
            [NSException exceptionWithName:@"No descriptor or reflection"
                                    reason:@"No descriptor or reflection" userInfo:nil];
        }
        
        if ([field fieldType] == GPBFieldTypeRepeated) {
            
            NSArray* array = [root objectForKey:nameStr];
            
            if (![array isKindOfClass:[NSArray class]]) {
                
                NSAssert(NO, @"should be array");
            } else {
                
                [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [self json2fieldInternal:msg field:field jsonObject:obj keyMap:map];
                }];
            }
            
        } else if ([field fieldType] == GPBFieldTypeMap) {
            
            NSDictionary* dict = [root objectForKey:nameStr];
            
            if (![dict isKindOfClass:[NSDictionary class]]) {
                
                NSAssert(NO, @"should be NSDictionary");
                
            } else {
                
                [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    
                    [self json2MapfieldInternal:msg field:field key:key jsonObject:obj keyMap:map];
                }];
            }
            
        } else {
            
            [self json2fieldInternal:msg field:field jsonObject:[root objectForKey:nameStr] keyMap:map];
        }
    }
}

+ (void)json2pbInternal:(GPBMessage*)msg dict:(NSDictionary *)dict
{
    [self json2pbInternal:msg dict:dict map:nil];
}

+ (void)fromJson:(GPBMessage*)msg data:(NSData*)data keyMap:(NSDictionary*)map
{
    NSError* error = nil;
    NSDictionary *JSONObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    if (!error) {
        [self json2pbInternal:msg dict:JSONObject map:map];
    } else {
        NSAssert(NO, @"should be json string");
    }
}

- (id)initWithJsonString:(NSString*)data
{
    self = [self init];
    if (self) {
        [GPBMessage fromJson:self data:[data dataUsingEncoding:NSUTF8StringEncoding] keyMap:nil];
    }
    
    return self;
}

#pragma mark - pb2Json

- (NSDictionary*)toJsonDict
{
    return [GPBMessage pb2JsonDict:self];
}

- (NSString*)toJsonString
{
    NSDictionary* dict = [self toJsonDict];
    NSError* error = nil;
    NSData* data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    if (!error && data.length) {
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    } else {
        return nil;
    }
}

+ (id)field2json:(GPBMessage*)msg field:(GPBFieldDescriptor*)field index:(NSUInteger)index
{
    BOOL repeated = ([field fieldType] == GPBFieldTypeRepeated);

    switch ([field dataType]) {
#define __CASE(type, ctype, arraytype, sfunc)                             \
  case type: {                                                                 \
    ctype value;                                                               \
    if (repeated) {                                                            \
      arraytype *array = GPBGetMessageRepeatedField(msg, field);               \
      value = [array valueAtIndex:index];                                      \
    } else {                                                                   \
      value = sfunc(msg, field);                                               \
    }                                                                          \
    return @(value);                                                           \
    break;                                                                     \
  }

            __CASE(GPBDataTypeDouble, double,GPBDoubleArray,GPBGetMessageDoubleField);
            __CASE(GPBDataTypeFloat, double,GPBFloatArray,GPBGetMessageFloatField);
            __CASE(GPBDataTypeInt64, int64_t,GPBInt64Array,GPBGetMessageInt64Field);
            __CASE(GPBDataTypeSFixed64, int64_t,GPBInt64Array,GPBGetMessageInt64Field);
            __CASE(GPBDataTypeSInt64, int64_t,GPBInt64Array,GPBGetMessageInt64Field);
            __CASE(GPBDataTypeUInt64, uint64_t,GPBUInt64Array,GPBGetMessageUInt64Field);
            __CASE(GPBDataTypeFixed64, uint64_t,GPBUInt64Array,GPBGetMessageUInt64Field);
            __CASE(GPBDataTypeInt32, int32_t,GPBInt32Array,GPBGetMessageInt32Field);
            __CASE(GPBDataTypeSInt32, int32_t,GPBInt32Array,GPBGetMessageInt32Field);
            __CASE(GPBDataTypeSFixed32, int32_t,GPBInt32Array,GPBGetMessageInt32Field);
            __CASE(GPBDataTypeUInt32, uint32_t,GPBUInt32Array,GPBGetMessageUInt32Field);
            __CASE(GPBDataTypeFixed32, uint32_t,GPBUInt32Array,GPBGetMessageUInt32Field);
            __CASE(GPBDataTypeBool, bool,GPBBoolArray,GPBGetMessageBoolField);
#undef __CASE
        case GPBDataTypeString:
        {
            NSString* value = nil;
            if (repeated) {
                NSArray<NSString*>* array = GPBGetMessageRepeatedField(msg,field);
                value = array[index];
            } else {
                value = GPBGetMessageStringField(msg, field);
            }
            return value;
        }
        case GPBDataTypeBytes:
        {
            NSData* data = nil;
            if (repeated) {
                NSArray<NSData*>* array = GPBGetMessageRepeatedField(msg,field);
                data = array[index];
            } else {
                data = GPBGetMessageBytesField(msg,field);
            }
            data = [data base64EncodedDataWithOptions:NSDataBase64Encoding64CharacterLineLength];
            
            if (data.length) {
                return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            } else {
                return nil;
            }
        }
        case GPBDataTypeMessage:
        {
            GPBMessage* mesg = nil;
            if (repeated) {
                NSArray<GPBMessage*>* array = GPBGetMessageRepeatedField(msg, field);
                mesg = array[index];
            } else {
                mesg = GPBGetMessageMessageField(msg, field);
            }
            
            if (mesg) {
                return [self pb2JsonDict:mesg];
            } else {
                return nil;
            }
        }
        case GPBDataTypeEnum:
        {
            int32_t value = 0;
            if (repeated) {
                GPBEnumArray* array = GPBGetMessageRepeatedField(msg, field);
                value = [array valueAtIndex:index];
            } else {
                value = GPBGetMessageEnumField(msg, field);
            }
            return @(value);
        }
        default:
            break;
    }

    return nil;
}

+ (id)mapfield2Json:(GPBMessage*)msg
              field:(GPBFieldDescriptor*)field
{
    GPBDataType mapkeyType = [field mapKeyDataType];
    GPBDataType dataType = [field dataType];
    
#define WFGPB_GETMAP_CASE(keyType , dType, realKeyType, realResultType) \
if (mapkeyType == GPBDataType##keyType && dataType == GPBDataType##dType ) { \
metamacro_concat(GPB, metamacro_concat(keyType,metamacro_concat(dType,Dictionary)))* pbResult = GPBGetMessageMapField(msg, field); \
NSMutableDictionary* result = [NSMutableDictionary dictionaryWithCapacity:pbResult.count]; \
[pbResult metamacro_concat(metamacro_concat(enumerateKeysAnd,dType),sUsingBlock):^(realKeyType key, realResultType value, BOOL * _Nonnull stop) { \
    NSString* keyStr = [NSString stringWithFormat:@"%@", @(key)]; \
    result[keyStr] = @(value); \
}]; \
return result;\
}\

#define WFGPB_GETMAP_CASE_OBJECT(keyType , dType, realKeyType, realResultType) \
if (mapkeyType == GPBDataType##keyType && dataType == GPBDataType##dType ) { \
metamacro_concat(GPB, metamacro_concat(keyType,metamacro_concat(dType,Dictionary)))* pbResult = GPBGetMessageMapField(msg, field); \
NSMutableDictionary* result = [NSMutableDictionary dictionaryWithCapacity:pbResult.count]; \
[pbResult metamacro_concat(metamacro_concat(enumerateKeysAnd,dType),sUsingBlock):^(realKeyType key, realResultType value, BOOL * _Nonnull stop) { \
    NSString* keyStr = [NSString stringWithFormat:@"%@", key]; \
    result[keyStr] = @(value); \
}]; \
return result;\
}\
    
#define WFGPB_GETMAP_OBJECT_CASE(keyType , realKeyType) \
if (mapkeyType == GPBDataType##keyType && (dataType == GPBDataTypeMessage || dataType == GPBDataTypeString) ) { \
metamacro_concat(GPB, metamacro_concat(keyType,ObjectDictionary))* pbResult = GPBGetMessageMapField(msg, field); \
NSMutableDictionary* result = [NSMutableDictionary dictionaryWithCapacity:pbResult.count]; \
[pbResult metamacro_concat(metamacro_concat(enumerateKeysAnd,Object),sUsingBlock):^(realKeyType key, id value, BOOL * _Nonnull stop) { \
    NSString* keyStr = [NSString stringWithFormat:@"%@",@(key)]; \
    if ([value isKindOfClass:[GPBMessage class]]) { \
        id resultValue = [self pb2JsonDict:value];\
        result[keyStr] = resultValue; \
    }\
    if ([value isKindOfClass:[NSString class]]) { \
        result[keyStr] = [value copy]; \
    }\
}]; \
return result;\
}\

    WFGPB_GETMAP_CASE(UInt32, UInt32, uint32_t, uint32_t);
    WFGPB_GETMAP_CASE(UInt32,Int32, uint32_t, int32_t);
    WFGPB_GETMAP_CASE(UInt32,UInt64,uint32_t, uint64_t);
    WFGPB_GETMAP_CASE(UInt32,Int64, uint32_t, int64_t);
    WFGPB_GETMAP_CASE(UInt32,Bool, uint32_t, BOOL);
    WFGPB_GETMAP_CASE(UInt32,Float,uint32_t, float);
    WFGPB_GETMAP_CASE(UInt32,Double,uint32_t, double);
    WFGPB_GETMAP_CASE(UInt32,Enum,uint32_t, int);
    WFGPB_GETMAP_OBJECT_CASE(UInt32, uint32_t);

    WFGPB_GETMAP_CASE(Int32,UInt32,int32_t,uint32_t);
    WFGPB_GETMAP_CASE(Int32,Int32,int32_t,int32_t);
    WFGPB_GETMAP_CASE(Int32,UInt64,int32_t,uint64_t);
    WFGPB_GETMAP_CASE(Int32,Int64,int32_t,int64_t);
    WFGPB_GETMAP_CASE(Int32,Bool,int32_t,BOOL);
    WFGPB_GETMAP_CASE(Int32,Float,int32_t,float);
    WFGPB_GETMAP_CASE(Int32,Double,int32_t,double);
    WFGPB_GETMAP_CASE(Int32,Enum,int32_t,int);
    WFGPB_GETMAP_OBJECT_CASE(Int32, int32_t);

    WFGPB_GETMAP_CASE(UInt64,UInt32,uint64_t,uint32_t);
    WFGPB_GETMAP_CASE(UInt64,Int32,uint64_t,int32_t);
    WFGPB_GETMAP_CASE(UInt64,UInt64,uint64_t,uint64_t);
    WFGPB_GETMAP_CASE(UInt64,Int64,uint64_t,int64_t);
    WFGPB_GETMAP_CASE(UInt64,Bool,uint64_t,BOOL);
    WFGPB_GETMAP_CASE(UInt64,Float,uint64_t,float);
    WFGPB_GETMAP_CASE(UInt64,Double,uint64_t,double);
    WFGPB_GETMAP_CASE(UInt64,Enum,uint64_t,int);
    WFGPB_GETMAP_OBJECT_CASE(UInt64, uint64_t);

    WFGPB_GETMAP_CASE(Int64,UInt32,int64_t,uint32_t);
    WFGPB_GETMAP_CASE(Int64,Int32,int64_t,int32_t);
    WFGPB_GETMAP_CASE(Int64,UInt64,int64_t,uint64_t);
    WFGPB_GETMAP_CASE(Int64,Int64,int64_t,int64_t);
    WFGPB_GETMAP_CASE(Int64,Bool,int64_t,BOOL);
    WFGPB_GETMAP_CASE(Int64,Float,int64_t,float);
    WFGPB_GETMAP_CASE(Int64,Double,int64_t,double);
    WFGPB_GETMAP_CASE(Int64,Enum,int64_t,int);
    WFGPB_GETMAP_OBJECT_CASE(Int64, int64_t);

    WFGPB_GETMAP_CASE(Bool,UInt32,BOOL,uint32_t);
    WFGPB_GETMAP_CASE(Bool,Int32,BOOL,int32_t);
    WFGPB_GETMAP_CASE(Bool,UInt64,BOOL,uint64_t);
    WFGPB_GETMAP_CASE(Bool,Int64,BOOL,int64_t);
    WFGPB_GETMAP_CASE(Bool,Bool,BOOL,BOOL);
    WFGPB_GETMAP_CASE(Bool,Float,BOOL,float);
    WFGPB_GETMAP_CASE(Bool,Double,BOOL,double);
    WFGPB_GETMAP_CASE(Bool,Enum,BOOL,int);
    WFGPB_GETMAP_OBJECT_CASE(Bool, BOOL);

    WFGPB_GETMAP_CASE_OBJECT(String,UInt32,id,uint32_t);
    WFGPB_GETMAP_CASE_OBJECT(String,Int32,id,int32_t);
    WFGPB_GETMAP_CASE_OBJECT(String,UInt64,id,uint64_t);
    WFGPB_GETMAP_CASE_OBJECT(String,Int64,id,int64_t);
    WFGPB_GETMAP_CASE_OBJECT(String,Bool,id,BOOL);
    WFGPB_GETMAP_CASE_OBJECT(String,Float,id,float);
    WFGPB_GETMAP_CASE_OBJECT(String,Double,id,double);
    WFGPB_GETMAP_CASE_OBJECT(String,Enum,id,int);
    
    return nil;
}


+ (NSDictionary*)pb2JsonDict:(GPBMessage*)msg
{
    GPBDescriptor* d = [msg descriptor];
    
    NSMutableDictionary* result = [[NSMutableDictionary alloc] init];
    
    for (GPBFieldDescriptor* field in [d fields]) {
        
        NSString* name = [field name];
        
        if ([field fieldType] == GPBFieldTypeRepeated) {
            NSArray* pbArray = GPBGetMessageRepeatedField(msg, field);
            
            if ([pbArray respondsToSelector:@selector(count)] && pbArray.count > 0) {
                
                NSMutableArray* jsonArray = [NSMutableArray arrayWithCapacity:pbArray.count];
                
                for (NSUInteger i = 0; i< pbArray.count; ++i) {
                    id value = [self field2json:msg field:field index:i];
                    if (value) {
                        [jsonArray addObject:value];
                    }
                }
                result[name] = jsonArray;
            }
            
        } else if([field fieldType] == GPBFieldTypeMap) {
            
            id mapValue = [self mapfield2Json:msg field:field];
            
            if (mapValue) {
                result[name] = mapValue;
            }
            
        } else if (GPBGetHasIvarField(msg, field)) {
            
            id value = [self field2json:msg field:field index:0];
            
            if (value) {
                result[name] = value;
            }
        }
    }

    return result;
    
}

@end
