# Copyright 2019, NimGL contributors.

when defined(glfwDLL):
  when defined(windows):
    const glfw_dll* = "glfw3.dll"
  elif defined(macosx):
    const glfw_dll* = "libglfw3.dylib"
  else:
    const glfw_dll* = "libglfw.so.3"
else:
  when not defined(emscripten):
    {.compile: "vkfw/src/vulkan.c".}

  # Thanks to ephja for making this build system
  when defined(emscripten):
    {.passL: "-s USE_GLFW=3".}
  elif defined(windows):
    when defined(vcc):
      {.passL: "opengl32.lib gdi32.lib user32.lib shell32.lib" .}
    else:
      {.passL: "-lopengl32 -lgdi32" .}
    {.passC: "-D_GLFW_WIN32",
      compile: "vkfw/src/win32_init.c",
      compile: "vkfw/src/win32_joystick.c",
      compile: "vkfw/src/win32_monitor.c",
      compile: "vkfw/src/win32_time.c",
      compile: "vkfw/src/win32_thread.c",
      compile: "vkfw/src/win32_window.c",
      compile: "vkfw/src/wgl_context.c",
      compile: "vkfw/src/egl_context.c",
      compile: "vkfw/src/osmesa_context.c".}
  elif defined(macosx):
    {.passC: "-D_GLFW_COCOA -D_GLFW_USE_CHDIR -D_GLFW_USE_MENUBAR -D_GLFW_USE_RETINA",
      passL: "-framework Cocoa -framework OpenGL -framework IOKit -framework CoreVideo",
      compile: "vkfw/src/cocoa_init.m",
      compile: "vkfw/src/cocoa_joystick.m",
      compile: "vkfw/src/cocoa_monitor.m",
      compile: "vkfw/src/cocoa_window.m",
      compile: "vkfw/src/cocoa_time.c",
      compile: "vkfw/src/posix_thread.c",
      compile: "vkfw/src/nsgl_context.m",
      compile: "vkfw/src/egl_context.c",
      compile: "vkfw/src/osmesa_context.c".}
  else:
    {.passL: "-pthread -lGL".}

    when defined(mir):
      {.passC: "-D_GLFW_MIR",
        compile: "vkfw/src/mir_init.c",
        compile: "vkfw/src/mir_monitor.c",
        compile: "vkfw/src/mir_window.c".}
    elif defined(wayland):
      {.passC: "-D_GLFW_WAYLAND",
        compile: "vkfw/src/wl_init.c",
        compile: "vkfw/src/wl_monitor.c",
        compile: "vkfw/src/wl_window.c".}
    else:
      {.passC: "-D_GLFW_X11",
        compile: "vkfw/src/x11_init.c",
        compile: "vkfw/src/x11_monitor.c",
        compile: "vkfw/src/x11_window.c",
        compile: "vkfw/src/glx_context.c".}

    {.compile: "vkfw/src/xkb_unicode.c",
      compile: "vkfw/src/linux_joystick.c",
      compile: "vkfw/src/posix_time.c",
      compile: "vkfw/src/egl_context.c",
      compile: "vkfw/src/osmesa_context.c",
      compile: "vkfw/src/posix_thread.c".}

  when not defined(emscripten):
    {.compile: "vkfw/src/context.c",
      compile: "vkfw/src/init.c",
      compile: "vkfw/src/input.c",
      compile: "vkfw/src/monitor.c",
      compile: "vkfw/src/window.c".}

import vulkan

# Constants and Enums
const
  vkfwVersion* = (major: 0, minor: 1, patch: 0)

type
  KeyStat* {.pure, size: sizeof(int32).} = enum
    Release, Press, Repeat

  Hat* {.pure, size: sizeof(int32).} = enum
    Centered = 0
    Up = 1
    Right = 2
    Down = 4
    Left = 8
  Key* {.pure, size: int32.sizeof.} = enum
    Space = 32
    Apostrophe = 39
    Comma = 44
    Minus = 45
    Period = 46
    Slash = 47
    K0 = 48, K1, K2, K3,
    K4, K5, K6, K7, K8, K9,
    Semicolon = 59
    Equal = 61
    A = 65, B, C, D, E, F, G, H, I, J, K, L,
    M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z,
    LeftBracket = 91
    Backslash = 92
    RightBracket = 93
    GraveAccent = 96
    World1 = 161
    World2 = 162
    Escape = 256
    Enter = 257
    Tab = 258
    Backspace = 259
    Insert = 260
    Delete = 261
    Right = 262
    Left = 263
    Down = 264
    Up = 265
    PageUp = 266
    PageDown = 267
    Home = 268
    End = 269
    CapsLock = 280
    ScrollLock = 281
    NumLock = 282
    PrintScreen = 283
    Pause = 284
    F1 = 290, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11, F12, F13,
    F14, F15, F16, F17, F18, F19, F20, F21, F22, F23, F24, F25,
    Kp0 = 320, Kp1, Kp2, Kp3, Kp4,
    Kp5, Kp6, Kp7, Kp8, Kp9,
    KpDecimal = 330
    KpDivide = 331
    KpMultiply = 332
    KpSubtract = 333
    KpAdd = 334
    KpEnter = 335
    KpEqual = 336
    LeftShift = 340
    LeftControl = 341
    LeftAlt = 342
    LeftSuper = 343
    RightShift = 344
    RightControl = 345
    RightAlt = 346
    RightSuper = 347
    Menu = 348
type ModKey* = enum
  Shift = 0x0001
  Control = 0x0002
  Alt = 0x0004
  Super = 0x0008
  CapsLock = 0x0010
  NumLock = 0x0020
type
  MouseBtn* {.pure, size: int32.sizeof.} = enum
    Button1, Button2, Button3, Button4,
    Button5, Button6, Button7, Button8,
type
  Joystick* {.pure, size: int32.sizeof.} = enum
    K1, K2, K3, K4, K5, K6, K7, K8, K9,
    K10, K11, K12, K13, K14, K15, K16,
  GamepadBtn* {.pure, size: int32.sizeof.} = enum
    A, B, X, Y, LeftBumper, RightBumper, Back, Start, Guide,
    LeftThumb, RightThumb, DpadUp, DpadRight, DpadDown, DpadLeft,
  GamepadAxis* {.pure, size: int32.sizeof.} = enum
    LeftX, LeftY, RightX, RightY,
    LeftTrigger, RightTrigger,

const
  GLFWNoError* = 0
  GLFWNotInitialized* = 0x00010001
  GLFWNoCurrentContext* = 0x00010002
  GLFWInvalidEnum* = 0x00010003
  GLFWInvalidValue* = 0x00010004
  GLFWOutOfMemory* = 0x00010005
  GLFWApiUnavailable* = 0x00010006
  GLFWVersionUnavailable* = 0x00010007
  GLFWPlatformError* = 0x00010008
  GLFWFormatUnavailable* = 0x00010009
  GLFWNoWindowContext* = 0x0001000A
  GLFWCursorUnavailable* = 0x0001000B
  GLFWFeatureUnavailable* = 0x0001000C
  GLFWFeatureUnimplemented* = 0x0001000D
  GLFWFocused* = 0x00020001
  GLFWIconified* = 0x00020002
  GLFWResizable* = 0x00020003
  GLFWVisible* = 0x00020004
  GLFWDecorated* = 0x00020005
  GLFWAutoIconify* = 0x00020006
  GLFWFloating* = 0x00020007
  GLFWMaximized* = 0x00020008
  GLFWCenterCursor* = 0x00020009
  GLFWTransparentFramebuffer* = 0x0002000A
  GLFWHovered* = 0x0002000B
  GLFWFocusOnShow* = 0x0002000C
  GLFWMouseButtonPassthrough* = 0x0002000D
  GLFWRedBits* = 0x00021001
  GLFWGreenBits* = 0x00021002
  GLFWBlueBits* = 0x00021003
  GLFWAlphaBits* = 0x00021004
  GLFWDepthBits* = 0x00021005
  GLFWStencilBits* = 0x00021006
  GLFWAccumRedBits* = 0x00021007
  GLFWAccumGreenBits* = 0x00021008
  GLFWAccumBlueBits* = 0x00021009
  GLFWAccumAlphaBits* = 0x0002100A
  GLFWAuxBuffers* = 0x0002100B
  GLFWStereo* = 0x0002100C
  GLFWSamples* = 0x0002100D
  GLFWSrgbCapable* = 0x0002100E
  GLFWRefreshRate* = 0x0002100F
  GLFWDoublebuffer* = 0x00021010
  GLFWClientApi* = 0x00022001
  GLFWContextVersionMajor* = 0x00022002
  GLFWContextVersionMinor* = 0x00022003
  GLFWContextRevision* = 0x00022004
  GLFWContextRobustness* = 0x00022005
  GLFWOpenglForwardCompat* = 0x00022006
  GLFWContextDebug* = 0x00022007
  GLFWOpenglDebugContext* = GLFW_CONTEXT_DEBUG
  GLFWOpenglProfile* = 0x00022008
  GLFWContextReleaseBehavior* = 0x00022009
  GLFWContextNoError* = 0x0002200A
  GLFWContextCreationApi* = 0x0002200B
  GLFWScaleToMonitor* = 0x0002200C
  GLFWCocoaRetinaFramebuffer* = 0x00023001
  GLFWCocoaFrameName* = 0x00023002
  GLFWCocoaGraphicsSwitching* = 0x00023003
  GLFWX11ClassName* = 0x00024001
  GLFWX11InstanceName* = 0x00024002
  GLFWWin32KeyboardMenu* = 0x00025001
  GLFWNoApi* = 0
  GLFWOpenglApi* = 0x00030001
  GLFWOpenglEsApi* = 0x00030002
  GLFWNoRobustness* = 0
  GLFWNoResetNotification* = 0x00031001
  GLFWLoseContextOnReset* = 0x00031002
  GLFWOpenglAnyProfile* = 0
  GLFWOpenglCoreProfile* = 0x00032001
  GLFWOpenglCompatProfile* = 0x00032002
  GLFWCursorSpecial* = 0x00033001 ## Originally GLFW_CURSOR but conflicts with GLFWCursor type
  GLFWStickyKeys* = 0x00033002
  GLFWStickyMouseButtons* = 0x00033003
  GLFWLockKeyMods* = 0x00033004
  GLFWRawMouseMotion* = 0x00033005
  GLFWCursorNormal* = 0x00034001
  GLFWCursorHidden* = 0x00034002
  GLFWCursorDisabled* = 0x00034003
  GLFWAnyReleaseBehavior* = 0
  GLFWReleaseBehaviorFlush* = 0x00035001
  GLFWReleaseBehaviorNone* = 0x00035002
  GLFWNativeContextApi* = 0x00036001
  GLFWEglContextApi* = 0x00036002
  GLFWOsmesaContextApi* = 0x00036003
  GLFWAnglePlatformTypeNone* = 0x00037001
  GLFWAnglePlatformTypeOpengl* = 0x00037002
  GLFWAnglePlatformTypeOpengles* = 0x00037003
  GLFWAnglePlatformTypeD3d9* = 0x00037004
  GLFWAnglePlatformTypeD3d11* = 0x00037005
  GLFWAnglePlatformTypeVulkan* = 0x00037007
  GLFWAnglePlatformTypeMetal* = 0x00037008
  GLFWArrowCursor* = 0x00036001
  GLFWIbeamCursor* = 0x00036002
  GLFWCrosshairCursor* = 0x00036003
  GLFWPointingHandCursor* = 0x00036004
  GLFWResizeEwCursor* = 0x00036005
  GLFWResizeNsCursor* = 0x00036006
  GLFWResizeNwseCursor* = 0x00036007
  GLFWResizeNeswCursor* = 0x00036008
  GLFWResizeAllCursor* = 0x00036009
  GLFWNotAllowedCursor* = 0x0003600A
  GLFWHresizeCursor* = GLFW_RESIZE_EW_CURSOR
  GLFWVresizeCursor* = GLFW_RESIZE_NS_CURSOR
  GLFWHandCursor* = GLFW_POINTING_HAND_CURSOR
  GLFWConnected* = 0x00040001
  GLFWDisconnected* = 0x00040002
  GLFWJoystickHatButtons* = 0x00050001
  GLFWAnglePlatformType* = 0x00050002
  GLFWCocoaChdirResources* = 0x00051001
  GLFWCocoaMenubar* = 0x00051002
  GLFWDontCare* = -1

type
  GLFWMonitor* = ptr object
  GLFWWindow* = ptr object
  GLFWCursor* = ptr object
  GLFWVidMode* = object
    width*: int32
    height*: int32
    redBits*: int32
    greenBits*: int32
    blueBits*: int32
    refreshRate*: int32
  GLFWGammaRamp* = object
    red*: uint16
    green*: uint16
    blue*: uint16
    size*: uint32
  GLFWImage* = object
    width*: int32
    height*: int32
    pixels*: ptr char
  GLFWGamepadState* = object
    buttons*: array[15, bool]
    axes*: array[6, float32]

type
  GLFWGlProc* = pointer
  GLFWVkProc* = pointer
  GLFWErrorFun* = proc(error_code: int32, description: cstring): void {.cdecl.}
  GLFWWindowposFun* = proc(window: GLFWWindow, xpos: int32, ypos: int32): void {.cdecl.}
  GLFWWindowsizeFun* = proc(window: GLFWWindow, width: int32, height: int32): void {.cdecl.}
  GLFWWindowcloseFun* = proc(window: GLFWWindow): void {.cdecl.}
  GLFWWindowrefreshFun* = proc(window: GLFWWindow): void {.cdecl.}
  GLFWWindowfocusFun* = proc(window: GLFWWindow, focused: bool): void {.cdecl.}
  GLFWWindowiconifyFun* = proc(window: GLFWWindow, iconified: bool): void {.cdecl.}
  GLFWWindowmaximizeFun* = proc(window: GLFWWindow, maximized: int32): void {.cdecl.}
  GLFWFramebuffersizeFun* = proc(window: GLFWWindow, width: int32, height: int32): void {.cdecl.}
  GLFWWindowcontentscaleFun* = proc(window: GLFWWindow, xscale: float32, yscale: float32): void {.cdecl.}
  GLFWMousebuttonFun* = proc(window: GLFWWindow, button: int32, action: int32, mods: int32): void {.cdecl.}
  GLFWCursorposFun* = proc(window: GLFWWindow, xpos: float64, ypos: float64): void {.cdecl.}
  GLFWCursorenterFun* = proc(window: GLFWWindow, entered: bool): void {.cdecl.}
  GLFWScrollFun* = proc(window: GLFWWindow, xoffset: float64, yoffset: float64): void {.cdecl.}
  GLFWKeyFun* = proc(window: GLFWWindow, key: int32, scancode: int32, action: int32, mods: int32): void {.cdecl.}
  GLFWCharFun* = proc(window: GLFWWindow, codepoint: uint32): void {.cdecl.}
  GLFWCharmodsFun* = proc(window: GLFWWindow, codepoint: uint32, mods: int32): void {.cdecl.}
  GLFWDropFun* = proc(window: GLFWWindow, path_count: int32, paths: cstringArray): void {.cdecl.}
  GLFWMonitorFun* = proc(monitor: GLFWMonitor, event: int32): void {.cdecl.}
  GLFWJoystickFun* = proc(jid: int32, event: int32): void {.cdecl.}

# Procs
when defined(glfwDLL):
  {.push dynlib: glfw_dll, cdecl.}
else:
  {.push cdecl.}

proc glfwInit*(): bool {.importc: "glfwInit".}
proc glfwTerminate*(): void {.importc: "glfwTerminate".}
proc glfwInitHint*(hint: int32, value: int32): void {.importc: "glfwInitHint".}
proc glfwGetVersion*(major: ptr int32, minor: ptr int32, rev: ptr int32): void {.importc: "glfwGetVersion".}
proc glfwGetVersionString*(): cstring {.importc: "glfwGetVersionString".}
proc glfwGetError*(description: cstringArray): int32 {.importc: "glfwGetError".}
proc glfwSetErrorCallback*(callback: GLFWErrorfun): GLFWErrorfun {.importc: "glfwSetErrorCallback".}
proc glfwGetMonitors*(count: ptr int32): ptr UncheckedArray[GLFWMonitor] {.importc: "glfwGetMonitors".}
proc glfwGetPrimaryMonitor*(): GLFWMonitor {.importc: "glfwGetPrimaryMonitor".}
proc getMonitorPos*(monitor: GLFWMonitor, xpos: ptr int32, ypos: ptr int32): void {.importc: "glfwGetMonitorPos".}
proc getMonitorWorkarea*(monitor: GLFWMonitor, xpos: ptr int32, ypos: ptr int32, width: ptr int32, height: ptr int32): void {.importc: "glfwGetMonitorWorkarea".}
proc getMonitorPhysicalSize*(monitor: GLFWMonitor, widthMM: ptr int32, heightMM: ptr int32): void {.importc: "glfwGetMonitorPhysicalSize".}
proc getMonitorContentScale*(monitor: GLFWMonitor, xscale: ptr float32, yscale: ptr float32): void {.importc: "glfwGetMonitorContentScale".}
proc getMonitorName*(monitor: GLFWMonitor): cstring {.importc: "glfwGetMonitorName".}
proc setMonitorUserPointer*(monitor: GLFWMonitor, pointer: pointer): void {.importc: "glfwSetMonitorUserPointer".}
proc getMonitorUserPointer*(monitor: GLFWMonitor): pointer {.importc: "glfwGetMonitorUserPointer".}
proc glfwSetMonitorCallback*(callback: GLFWMonitorfun): GLFWMonitorfun {.importc: "glfwSetMonitorCallback".}
proc getVideoModes*(monitor: GLFWMonitor, count: ptr int32): ptr GLFWVidmode {.importc: "glfwGetVideoModes".}
proc getVideoMode*(monitor: GLFWMonitor): ptr GLFWVidmode {.importc: "glfwGetVideoMode".}
proc setGamma*(monitor: GLFWMonitor, gamma: float32): void {.importc: "glfwSetGamma".}
proc getGammaRamp*(monitor: GLFWMonitor): ptr GLFWGammaramp {.importc: "glfwGetGammaRamp".}
proc setGammaRamp*(monitor: GLFWMonitor, ramp: ptr GLFWGammaramp): void {.importc: "glfwSetGammaRamp".}
proc glfwDefaultWindowHints*(): void {.importc: "glfwDefaultWindowHints".}
proc glfwWindowHint*(hint: int32, value: int32): void {.importc: "glfwWindowHint".}
proc glfwWindowHintString*(hint: int32, value: cstring): void {.importc: "glfwWindowHintString".}
proc glfwCreateWindowC*(width: int32, height: int32, title: cstring, monitor: GLFWMonitor, share: GLFWWindow): GLFWWindow {.importc: "glfwCreateWindow".}
proc destroyWindow*(window: GLFWWindow): void {.importc: "glfwDestroyWindow".}
proc windowShouldClose*(window: GLFWWindow): bool {.importc: "glfwWindowShouldClose".}
proc setWindowShouldClose*(window: GLFWWindow, value: bool): void {.importc: "glfwSetWindowShouldClose".}
proc setWindowTitle*(window: GLFWWindow, title: cstring): void {.importc: "glfwSetWindowTitle".}
proc setWindowIcon*(window: GLFWWindow, count: int32, images: ptr GLFWImage): void {.importc: "glfwSetWindowIcon".}
proc getWindowPos*(window: GLFWWindow, xpos: ptr int32, ypos: ptr int32): void {.importc: "glfwGetWindowPos".}
proc setWindowPos*(window: GLFWWindow, xpos: int32, ypos: int32): void {.importc: "glfwSetWindowPos".}
proc getWindowSize*(window: GLFWWindow, width: ptr int32, height: ptr int32): void {.importc: "glfwGetWindowSize".}
proc setWindowSizeLimits*(window: GLFWWindow, minwidth: int32, minheight: int32, maxwidth: int32, maxheight: int32): void {.importc: "glfwSetWindowSizeLimits".}
proc setWindowAspectRatio*(window: GLFWWindow, numer: int32, denom: int32): void {.importc: "glfwSetWindowAspectRatio".}
proc setWindowSize*(window: GLFWWindow, width: int32, height: int32): void {.importc: "glfwSetWindowSize".}
proc getFramebufferSize*(window: GLFWWindow, width: ptr int32, height: ptr int32): void {.importc: "glfwGetFramebufferSize".}
proc getWindowFrameSize*(window: GLFWWindow, left: ptr int32, top: ptr int32, right: ptr int32, bottom: ptr int32): void {.importc: "glfwGetWindowFrameSize".}
proc getWindowContentScale*(window: GLFWWindow, xscale: ptr float32, yscale: ptr float32): void {.importc: "glfwGetWindowContentScale".}
proc getWindowOpacity*(window: GLFWWindow): float32 {.importc: "glfwGetWindowOpacity".}
proc setWindowOpacity*(window: GLFWWindow, opacity: float32): void {.importc: "glfwSetWindowOpacity".}
proc iconifyWindow*(window: GLFWWindow): void {.importc: "glfwIconifyWindow".}
proc restoreWindow*(window: GLFWWindow): void {.importc: "glfwRestoreWindow".}
proc maximizeWindow*(window: GLFWWindow): void {.importc: "glfwMaximizeWindow".}
proc showWindow*(window: GLFWWindow): void {.importc: "glfwShowWindow".}
proc hideWindow*(window: GLFWWindow): void {.importc: "glfwHideWindow".}
proc focusWindow*(window: GLFWWindow): void {.importc: "glfwFocusWindow".}
proc requestWindowAttention*(window: GLFWWindow): void {.importc: "glfwRequestWindowAttention".}
proc getWindowMonitor*(window: GLFWWindow): GLFWMonitor {.importc: "glfwGetWindowMonitor".}
proc setWindowMonitor*(window: GLFWWindow, monitor: GLFWMonitor, xpos: int32, ypos: int32, width: int32, height: int32, refreshRate: int32): void {.importc: "glfwSetWindowMonitor".}
proc getWindowAttrib*(window: GLFWWindow, attrib: int32): int32 {.importc: "glfwGetWindowAttrib".}
proc setWindowAttrib*(window: GLFWWindow, attrib: int32, value: int32): void {.importc: "glfwSetWindowAttrib".}
proc setWindowUserPointer*(window: GLFWWindow, pointer: pointer): void {.importc: "glfwSetWindowUserPointer".}
proc getWindowUserPointer*(window: GLFWWindow): pointer {.importc: "glfwGetWindowUserPointer".}
proc setWindowPosCallback*(window: GLFWWindow, callback: GLFWWindowposfun): GLFWWindowposfun {.importc: "glfwSetWindowPosCallback".}
proc setWindowSizeCallback*(window: GLFWWindow, callback: GLFWWindowsizefun): GLFWWindowsizefun {.importc: "glfwSetWindowSizeCallback".}
proc setWindowCloseCallback*(window: GLFWWindow, callback: GLFWWindowclosefun): GLFWWindowclosefun {.importc: "glfwSetWindowCloseCallback".}
proc setWindowRefreshCallback*(window: GLFWWindow, callback: GLFWWindowrefreshfun): GLFWWindowrefreshfun {.importc: "glfwSetWindowRefreshCallback".}
proc setWindowFocusCallback*(window: GLFWWindow, callback: GLFWWindowfocusfun): GLFWWindowfocusfun {.importc: "glfwSetWindowFocusCallback".}
proc setWindowIconifyCallback*(window: GLFWWindow, callback: GLFWWindowiconifyfun): GLFWWindowiconifyfun {.importc: "glfwSetWindowIconifyCallback".}
proc setWindowMaximizeCallback*(window: GLFWWindow, callback: GLFWWindowmaximizefun): GLFWWindowmaximizefun {.importc: "glfwSetWindowMaximizeCallback".}
proc setFramebufferSizeCallback*(window: GLFWWindow, callback: GLFWFramebuffersizefun): GLFWFramebuffersizefun {.importc: "glfwSetFramebufferSizeCallback".}
proc setWindowContentScaleCallback*(window: GLFWWindow, callback: GLFWWindowcontentscalefun): GLFWWindowcontentscalefun {.importc: "glfwSetWindowContentScaleCallback".}
proc glfwPollEvents*(): void {.importc: "glfwPollEvents".}
proc glfwWaitEvents*(): void {.importc: "glfwWaitEvents".}
proc glfwWaitEventsTimeout*(timeout: float64): void {.importc: "glfwWaitEventsTimeout".}
proc glfwPostEmptyEvent*(): void {.importc: "glfwPostEmptyEvent".}
proc getInputMode*(window: GLFWWindow, mode: int32): int32 {.importc: "glfwGetInputMode".}
proc setInputMode*(window: GLFWWindow, mode: int32, value: int32): void {.importc: "glfwSetInputMode".}
proc glfwRawMouseMotionSupported*(): int32 {.importc: "glfwRawMouseMotionSupported".}
proc glfwGetKeyName*(key: Key, scancode: int32): cstring {.importc: "glfwGetKeyName".}
proc glfwGetKeyScancode*(key: Key): int32 {.importc: "glfwGetKeyScancode".}
proc getKey*(window: GLFWWindow, key: Key): KeyStat {.importc: "glfwGetKey".}
proc getMouseButton*(window: GLFWWindow, button: int32): int32 {.importc: "glfwGetMouseButton".}
proc getCursorPos*(window: GLFWWindow, xpos: ptr float64, ypos: ptr float64): void {.importc: "glfwGetCursorPos".}
proc setCursorPos*(window: GLFWWindow, xpos: float64, ypos: float64): void {.importc: "glfwSetCursorPos".}
proc createCursor*(image: ptr GLFWImage, xhot: int32, yhot: int32): GLFWCursor {.importc: "glfwCreateCursor".}
proc glfwCreateStandardCursor*(shape: int32): GLFWCursor {.importc: "glfwCreateStandardCursor".}
proc destroyCursor*(cursor: GLFWCursor): void {.importc: "glfwDestroyCursor".}
proc setCursor*(window: GLFWWindow, cursor: GLFWCursor): void {.importc: "glfwSetCursor".}
proc setKeyCallback*(window: GLFWWindow, callback: GLFWKeyfun): GLFWKeyfun {.importc: "glfwSetKeyCallback".}
proc setCharCallback*(window: GLFWWindow, callback: GLFWCharfun): GLFWCharfun {.importc: "glfwSetCharCallback".}
proc setCharModsCallback*(window: GLFWWindow, callback: GLFWCharmodsfun): GLFWCharmodsfun {.importc: "glfwSetCharModsCallback".}
proc setMouseButtonCallback*(window: GLFWWindow, callback: GLFWMousebuttonfun): GLFWMousebuttonfun {.importc: "glfwSetMouseButtonCallback".}
proc setCursorPosCallback*(window: GLFWWindow, callback: GLFWCursorposfun): GLFWCursorposfun {.importc: "glfwSetCursorPosCallback".}
proc setCursorEnterCallback*(window: GLFWWindow, callback: GLFWCursorenterfun): GLFWCursorenterfun {.importc: "glfwSetCursorEnterCallback".}
proc setScrollCallback*(window: GLFWWindow, callback: GLFWScrollfun): GLFWScrollfun {.importc: "glfwSetScrollCallback".}
proc setDropCallback*(window: GLFWWindow, callback: GLFWDropfun): GLFWDropfun {.importc: "glfwSetDropCallback".}
proc glfwJoystickPresent*(jid: int32): int32 {.importc: "glfwJoystickPresent".}
proc glfwGetJoystickAxes*(jid: int32, count: ptr int32): ptr float32 {.importc: "glfwGetJoystickAxes".}
proc glfwGetJoystickButtons*(jid: int32, count: ptr int32): ptr char {.importc: "glfwGetJoystickButtons".}
proc glfwGetJoystickHats*(jid: int32, count: ptr int32): ptr char {.importc: "glfwGetJoystickHats".}
proc glfwGetJoystickName*(jid: int32): cstring {.importc: "glfwGetJoystickName".}
proc glfwGetJoystickGUID*(jid: int32): cstring {.importc: "glfwGetJoystickGUID".}
proc glfwSetJoystickUserPointer*(jid: int32, pointer: pointer): void {.importc: "glfwSetJoystickUserPointer".}
proc glfwGetJoystickUserPointer*(jid: int32): pointer {.importc: "glfwGetJoystickUserPointer".}
proc glfwJoystickIsGamepad*(jid: int32): int32 {.importc: "glfwJoystickIsGamepad".}
proc glfwSetJoystickCallback*(callback: GLFWJoystickfun): GLFWJoystickfun {.importc: "glfwSetJoystickCallback".}
proc glfwUpdateGamepadMappings*(string: cstring): int32 {.importc: "glfwUpdateGamepadMappings".}
proc glfwGetGamepadName*(jid: int32): cstring {.importc: "glfwGetGamepadName".}
proc glfwGetGamepadState*(jid: int32, state: ptr GLFWGamepadstate): int32 {.importc: "glfwGetGamepadState".}
proc setClipboardString*(window: GLFWWindow, string: cstring): void {.importc: "glfwSetClipboardString".}
proc getClipboardString*(window: GLFWWindow): cstring {.importc: "glfwGetClipboardString".}
proc glfwGetTime*(): float64 {.importc: "glfwGetTime".}
proc glfwSetTime*(time: float64): void {.importc: "glfwSetTime".}
proc glfwGetTimerValue*(): uint64 {.importc: "glfwGetTimerValue".}
proc glfwGetTimerFrequency*(): uint64 {.importc: "glfwGetTimerFrequency".}
proc makeContextCurrent*(window: GLFWWindow): void {.importc: "glfwMakeContextCurrent".}
proc glfwGetCurrentContext*(): GLFWWindow {.importc: "glfwGetCurrentContext".}
proc swapBuffers*(window: GLFWWindow): void {.importc: "glfwSwapBuffers".}
proc glfwSwapInterval*(interval: int32): void {.importc: "glfwSwapInterval".}
proc glfwExtensionSupported*(extension: cstring): int32 {.importc: "glfwExtensionSupported".}
proc glfwGetProcAddress*(procname: cstring): GLFWGlproc {.importc: "glfwGetProcAddress".}
proc glfwVulkanSupported*(): bool {.importc: "glfwVulkanSupported".}
proc glfwGetRequiredInstanceExtensions*(count: ptr uint32): cstringArray {.importc: "glfwGetRequiredInstanceExtensions".}

proc glfwGetInstanceProcAddress*(instance: Instance, procname: cstring): GLFWVkproc {.importc: "glfwGetInstanceProcAddress".}
proc glfwGetPhysicalDevicePresentationSupport*(instance: Instance, device: PhysicalDevice, queuefamily: uint32): int32 {.importc: "glfwGetPhysicalDevicePresentationSupport".}
proc glfwCreateWindowSurface*(instance: Instance, window: GLFWWindow, allocator: ptr AllocationCallbacks, surface: ptr SurfaceKHR): Result {.discardable, importc: "glfwCreateWindowSurface".}

{.pop.}

proc glfwCreateWindow*(width: int32, height: int32, title: cstring = "NimGL", monitor: GLFWMonitor = nil, share: GLFWWindow = nil, icon: bool = true): GLFWWindow =
  result = glfwCreateWindowC(width, height, title, monitor, share)
  if not icon: return result
