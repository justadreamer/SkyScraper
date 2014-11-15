#import <Foundation/Foundation.h>
#import "AFURLResponseSerialization.h"
#import "SkyModelAdapter.h"

@class SkyXSLTransformation;

@interface SkyHTMLResponseSerializer : AFHTTPResponseSerializer
/**
 *  Transformation object used to convert HTML into JSON dictionary
 */
@property (nonatomic,strong) SkyXSLTransformation *transformation;

/**
 *  A params dictionary passed to XHTransformation
 */
@property (nonatomic,strong) NSDictionary *params;

/**
 *  If set, will be used to convert a JSON dictionary into model object
 */
@property (nonatomic,strong) NSObject<SkyModelAdapter> *modelAdapter;

/**
 *  A factory method for instantiating a serializer object
 *
 *  @param transformation an XHTransformation instance used to conver HTML into JSON dictionary
 *  @param params         optional params dictionary passed to XHTransformation to convert HTML into JSON dictionary
 *  @param modelAdapter   an option model adapter object used to convert JSON dictionary into model object
 *
 *  @return an instance of the serializer
 */
+ (instancetype)serializerWithXHTransformation:(SkyXSLTransformation *)transformation params:(NSDictionary *)params modelAdapter:(NSObject<SkyModelAdapter> *)modelAdapter;
@end
