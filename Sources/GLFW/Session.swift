import CGLFW3

public enum GLFWSession {    
    public static var hints = Hints()
    
    public struct Version: Hashable, Equatable, Comparable {
        public static func < (lhs: Version, rhs: Version) -> Bool {
            (lhs.major < rhs.major)
                || (lhs.major == rhs.major && lhs.minor < rhs.minor)
                || (lhs.major == rhs.major && lhs.minor == rhs.minor && lhs.revision < rhs.revision)
        }
        
        public let major: Int
        public let minor: Int
        public let revision: Int
        public let string: String
    }
    
    public static var currentTime: Double {
        glfwGetTime()
    }
    
    public static var version: Version {
        var major: Int32 = 0, minor: Int32 = 0, revision: Int32 = 0
        glfwGetVersion(&major, &minor, &revision)
        let string = String(cString: glfwGetVersionString())
        return Version(major: major.int, minor: minor.int, revision: revision.int, string: string)
    }
    
    @available(*, unavailable, renamed: "checkForError()")
    public static func checkError() throws -> Void {}
    
    public static func checkForError() throws -> Void {
        var description: UnsafePointer<CChar>?
        let lastError = glfwGetError(&description)
        if lastError != GLFW_NO_ERROR {
            throw GLFWError(kind: lastError, description: description)
        }
    }
    
    public static var onReceiveError: ((GLFWError) -> Void)? {
        didSet {
            if GLFWSession.onReceiveError != nil {
                glfwSetErrorCallback { error, description in
                    GLFWSession.onReceiveError!(GLFWError(kind: error, description: description))
                }
            } else {
                glfwSetErrorCallback(nil)
            }
        }
    }
    
    public static func initialize() throws {
        if glfwInit() != GLFW_TRUE {
            try checkForError()
            throw GLFWError(kind: .unknown, description: "GLFW init failed, but no error was thrown.")
        }
    }
    
    public static func terminate() {
        glfwTerminate()
    }
    
    public static func getClipboardContents() -> String? {
        glfwGetClipboardString(nil).flatMap(String.init(cString:))
    }
    
    public static func setClipboardContents(_ string: String?) {
        glfwSetClipboardString(nil, string)
    }
    
    public static func pollInputEvents() {
        glfwPollEvents()
    }
    
    public static func waitEvents() {
        glfwWaitEvents()
    }
    
    public static func waitEvents(timeout: Double) {
        glfwWaitEventsTimeout(timeout)
    }
    
    public static func timeout() {
        glfwPostEmptyEvent()
    }
}
