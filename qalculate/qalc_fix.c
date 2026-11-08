#define _GNU_SOURCE
#include <dlfcn.h>
#include <gtk/gtk.h>
#include <string.h>

int gtk_widget_get_allocated_width(GtkWidget *widget) {
    static int (*real_fn)(GtkWidget*) = NULL;
    if (!real_fn) real_fn = dlsym(RTLD_NEXT, "gtk_widget_get_allocated_width");
    int w = real_fn(widget);
    if (widget) {
        const char *name = gtk_widget_get_name(widget);
        const char *bname = GTK_IS_BUILDABLE(widget) ? gtk_buildable_get_name(GTK_BUILDABLE(widget)) : NULL;
        if ((name && strcmp(name, "scrolled_result") == 0) ||
            (bname && strcmp(bname, "scrolled_result") == 0)) {
            return w - 28;
        }
    }
    return w;
}
