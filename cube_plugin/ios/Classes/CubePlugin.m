#import "CubePlugin.h"
#if __has_include(<cube_plugin/cube_plugin-Swift.h>)
#import <cube_plugin/cube_plugin-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "cube_plugin-Swift.h"
#endif

@implementation CubePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftCubePlugin registerWithRegistrar:registrar];
}
@end
