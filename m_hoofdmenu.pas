unit m_hoofdmenu;

{$mode objfpc}{$H+}

interface

uses
  gtk, gdk, glib, SysUtils;

implementation


{ ----------------------------print_hello--------------------------- }
PROCEDURE print_hello( Data : gpointer ; Action : guint ; Widget : pGtkWidget ); cdecl;
{ Obligatory basic callback. }
BEGIN
writeln('Hello, World!');
END; { ----------------------------print_hello--------------------------- }

{ This is the GtkItemFactoryEntry structure used to generate new menus.
Item 1: The menu path. The letter after the underscore indicates an accelerator key once the menu is open.
Item 2: The accelerator key for the entry
Item 3: The callback function.
Item 4: The callback action. This changes the parameters with which the function is called. The default is 0.
Item 5: The item type, used to define what kind of an item it is.
  Here are the possible values:
NIL -> "<Item>"
"" -> "<Item>"
"<Title>" -> create a title item
"<Item>" -> create a simple item
"<CheckItem>" -> create a check item
"<ToggleItem>" -> create a toggle item
"<RadioItem>" -> create a radio item
"<path>" -> path of a radio item to link against
"<Separator>" -> create a separator
"<Branch>" -> create an item to hold sub items (optional)
"<LastBranch>" -> create a right justified branch.
  }

{ -------------------------Global Variables------------------------------ }
VAR
window, menu_bar, main_vbox : pGtkWidget;
TYPE
FactCB = tGtkItemFactoryCallback;
CONST
num_menu_items = 11;
menu_items : ARRAY[1..num_menu_items] OF tGtkItemFactoryEntry = (
(path : '/_File'; accelerator : NIL;
     callback : NIL; callback_action : 0; item_type : '<Branch>'),
(path : '/File/_New'; accelerator : '<ctrl>N';
     callback : FactCB(@print_hello); callback_action : 0; item_type : NIL),
(path : '/File/_Open'; accelerator : '<ctrl>O';
     callback : FactCB(@print_hello); callback_action : 0; item_type : NIL),
(path : '/File/_Save'; accelerator : '<ctrl>S';
     callback : FactCB(@print_hello); callback_action : 0; item_type : NIL),
(path : '/File/Save _As'; accelerator : NIL;
     callback : NIL; callback_action : 0; item_type : NIL),
(path : '/File/sep1'; accelerator : NIL;
     callback : NIL; callback_action : 0; item_type : '<Separator>'),
(path : '/File/Quit'; accelerator : '<ctrl>Q';
     callback : FactCB(@gtk_main_quit); callback_action : 0; item_type : NIL),
(path : '/_Options'; accelerator : NIL;
     callback : NIL; callback_action : 0; item_type : '<Branch>'),
(path : '/Options/Test'; accelerator : NIL;
     callback : NIL; callback_action : 0; item_type : NIL),
(path : '/_Help'; accelerator : NIL;
     callback : NIL; callback_action : 0; item_type : '<LastBranch>'),
(path : '/_Help/About'; accelerator : NIL;
     callback : NIL; callback_action : 0; item_type : NIL)
);
{ --------------------------------make_menu-------------------------------- }
PROCEDURE make_menu;
VAR
it_factory : pGtkItemFactory;
it_accel : pGtkAccelGroup;
BEGIN
it_accel := gtk_accel_group_new();

{ This function initializes the item factory.
   Param 1: The type of menu - can be GTK_TYPE_MENU_BAR, GTK_TYPE_MENU, or GTK_TYPE_OPTION_MENU.
   Param 2: The path of the menu.
   Param 3: A pointer to a gtk_accel_group. The item factory sets up the accelerator table while generating menus. }
it_factory := gtk_item_factory_new(GTK_MENU_BAR_TYPE, '<main>', it_accel);

{ This function generates the menu items. Pass the item factory, the number of items
   in the array, the array itself, and any callback data for the menu items.}
gtk_item_factory_create_items(it_factory, num_menu_items, @menu_items, NIL);

{ Add the new accelerator group to the window. }
gtk_window_add_accel_group(GTK_WINDOW(window), it_accel);
menu_bar := gtk_item_factory_get_widget(it_factory, '<main>');
END; { -------------------------------------------make_menu-------------------------------- }

{ -----------------------------------Main Program------------------------------ }
BEGIN
gtk_init(@argc, @argv); { Initialise GTK }
window := gtk_window_new(GTK_WINDOW_TOPLEVEL); { Create a new window }
gtk_widget_set_usize(GTK_WIDGET(window), 300, 200);
gtk_window_set_title(GTK_WINDOW(window), 'Item Factory');
gtk_signal_connect(GTK_OBJECT(window), 'destroy',
     GTK_SIGNAL_FUNC(@gtk_main_quit), NIL);

main_vbox := gtk_vbox_new(FALSE, 1);
gtk_container_add(GTK_CONTAINER(window), main_vbox);
gtk_widget_show(main_vbox);

make_menu();
gtk_box_pack_start(GTK_BOX(main_vbox), menu_bar, FALSE, TRUE, 0);
gtk_widget_show(menu_bar);

gtk_widget_show(window);
gtk_main();
END. { --------------------------------Main Program--------------------------------- }

end.

