@protocol SkyModelAdapter <NSObject>
- (id)modelFromJSONObject:(id)JSONObject error:(NSError *__autoreleasing *)error;
@end