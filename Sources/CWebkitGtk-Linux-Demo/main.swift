import CWebkitGtk_Linux

enum Constants {
    enum Signals {
        static let destroy = "destroy"
    }
    enum WebviewSettings {
        static let enableWebGL = "enable-webgl"
    }
    enum WindowSize {
        static let height: gint = 600
        static let width: gint = 800
    }

    static let defaultUrl = "https://start.duckduckgo.com/"
}

func windowWidget() -> UnsafeMutablePointer<GtkWidget> {
    let widget = gtk_window_new(GTK_WINDOW_TOPLEVEL)!

    let window = UnsafeMutablePointer<GtkWindow>(OpaquePointer(widget))
    gtk_window_set_default_size(window, Constants.WindowSize.width, Constants.WindowSize.height)

    let handler: @convention(c) (UnsafeMutableRawPointer, UnsafeMutableRawPointer) -> Void = { sender, data in
        gtk_main_quit()
    }
    g_signal_connect_data(window, Constants.Signals.destroy, unsafeBitCast(handler, to: GCallback.self), nil, nil, G_CONNECT_AFTER)

    return widget
}

func scrolledWindowWidget() -> UnsafeMutablePointer<GtkWidget> {
    return gtk_scrolled_window_new(nil, nil)!
}

func webviewWidget() -> UnsafeMutablePointer<GtkWidget> {
    let widget = webkit_web_view_new()!
    enableWebGL(in: widget)

    return widget
}

func enableWebGL(in widget: UnsafeMutablePointer<GtkWidget>) {
    let webview = UnsafeMutablePointer<WebKitWebView>(OpaquePointer(widget))
    let webviewSettings = webkit_web_view_get_settings(webview)
    let objectSettings = UnsafeMutablePointer<GObject>(OpaquePointer(webviewSettings))

    var value = valueTrue()
    g_object_set_property(objectSettings, Constants.WebviewSettings.enableWebGL, &value)
}

func valueTrue() -> GValue {
    var value = GValue()
    let type = GType(5 << G_TYPE_FUNDAMENTAL_SHIFT) // G_TYPE_BOOLEAN
    g_value_init(&value, type)
    g_value_set_boolean (&value, 1) // TRUE

    return value
}

func addWidget(_ widget: UnsafeMutablePointer<GtkWidget>, to container: UnsafeMutablePointer<GtkWidget>) {
    let internalContainer = UnsafeMutablePointer<GtkContainer>(OpaquePointer(container))

    gtk_container_add(internalContainer, widget)
}

func loadUrl(_ url: String, in widget: UnsafeMutablePointer<GtkWidget>) {
    let webview = UnsafeMutablePointer<WebKitWebView>(OpaquePointer(widget))

    webkit_web_view_load_uri(webview, url)
}

gtk_init(nil, nil)

let window = windowWidget()
let scrolledWindow = scrolledWindowWidget()
let webview = webviewWidget()

addWidget(webview, to: scrolledWindow)
addWidget(scrolledWindow, to: window)

let url = (CommandLine.arguments.count != 2 ? Constants.defaultUrl : CommandLine.arguments[1])
loadUrl(url, in: webview)

gtk_widget_show_all(window)

gtk_main()
