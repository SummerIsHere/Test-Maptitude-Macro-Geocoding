// This code is in lesson4.rsc.
// Add a "Test Geocoding" menu with a "Find and Zoom" item to the main menu  
Macro "mkmenu"

    // This macro adds the "Test Geocoding Menu" menu before the "window" menu
    // First, make sure the "Test Geocoding Menu" menu is not already there.
    // This error handler prevents an error message if the menu isn't there.
    on NotFound goto next

    // Now remove the menu,...
    RemoveMenuItem("Test Geocoding Menu")

    // Reset the error handling,...
next: on NotFound default

    // And add the menu
    AddMenuItem("Test Geocoding Menu", "Before", "Window")
endMacro

Menu "Test Geocoding Menu System"

    // This is the top-level title to be added to the main menu system
    MenuItem "Test Geocoding Menu" text: "Test Geocoding" key: alt_l
        menu "Test Geocoding Dropdown Menu"
endMenu

Menu "Test Geocoding Dropdown Menu"

    // This is the body of the drop-down menu to be added
    MenuItem "Auto Geocode" text: "Auto Geocode" key: alt_Z
        do

            // Open the toolbox
            RunDbox("find and zoom toolbox")
        endItem
endMenu
