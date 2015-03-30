#import "SkyHTMLResponseSerializer.h"
#import "SkyXSLTransformation.h"
#import "SkyResponseSerializer+Protected.h"

@implementation SkyHTMLResponseSerializer
- (id) applyTransformationToData:(NSData *)data withError:(NSError *__autoreleasing *)error {
    return [self.transformation JSONObjectFromHTMLData:data withParams:self.params error:error];
}
@end
