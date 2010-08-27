/*
 * Really simple widget. Creates a window where it should reparent to, and creates
 * a plug widget inside it (an embedder window).
 * 
 * 
 * Receives as the first argument the windowid where it should reparent to
 * and sends via stdout the windowid where the plug is waiting for.
 *
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <gtk/gtk.h>
#include <gdk/gdkx.h>

int parseint(const char *str) 
{
  int value; 
  if (strlen(str) > 2 && str[0] == '0' && str[1] == 'x') 
    {
      sscanf(str + 2, "%x", &value);
    }
  else
    {
      value = atoi(str);
    }
  return value;
}

int main( int   argc,
          char *argv[] )
{
    /* GtkWidget is the storage type for widgets */
    GtkWidget *window;
    GtkWidget *box;
    GtkWidget *socket;
    GdkWindow* window_container;

    if (argc < 2) {
      g_print("You need to pass the window id\n");
      return 1;
    }
    int windowid=parseint(argv[1]);

    /* Our init, don't forget this! :) */
    gtk_init (&argc, &argv);


    /* Create our window */
    window = gtk_window_new (GTK_WINDOW_POPUP);

    /* Create box */
    /*
    box = gtk_invisible_new ();
    gtk_widget_set_size_request (box, 640, 385);
    */
    //    gtk_drawing_area_size(GTK_DRAWING_AREA(box), 640, 385);

    /* Create socket */
    socket = gtk_socket_new ();
    gtk_container_add (GTK_CONTAINER (window), socket);
    gtk_widget_set_size_request (socket, 640, 385);
    gtk_widget_show (socket);

    /* Showing the window last so everything pops up at once. */
    gtk_widget_realize (window);


    /* Reparent */
    window_container = gdk_window_foreign_new(windowid);
    if (GTK_WIDGET_MAPPED(window))
      gtk_widget_unmap(window);

    g_signal_connect(G_OBJECT(window), "delete_event",
		     G_CALLBACK(gtk_main_quit), NULL);
    g_signal_connect(G_OBJECT(window), "destroy",
		     G_CALLBACK(gtk_main_quit), NULL);

    gdk_window_reparent(window->window, window_container, 0, 0);

    gtk_widget_show (window);

    g_print ("0x%x\n", gtk_socket_get_id(GTK_SOCKET(socket)));


    /* And of course, our main function. */
    gtk_main ();

    /* Control returns here when gtk_main_quit() is called, but not when 
     * exit() is used. */
    
    return 0;
}
