// This code is in autogeocode.rsc.
Macro "autogeocode"

    // Call the toolbox.
    result=RunDbox("find and zoom toolbox")

endMacro

	// Create a dialog box to display the choices
	DBox "get choice" (points_list)  Title: "Choose a Place"
	    // Displays the points_list formatted array of data; requires the
	    // user to choose one and click OK.  Returns an array index for
	    // OK or null if Cancel is clicked.
	
	    Init do
	
	        // disable the OK button to start; enable it when a line
	        // in the scroll list is chosen.
	        DisableItem("OK")
	
	    endItem
	
	    // Add some titles for the scroll list.
	    Text "Distance" 1, 0
	    Text "City" 9, same
	    Text "State" 33, same
	
	    // Display the formatted array; the keyword "multiple" is not
	    // used, so only one choice will be possible.  The points_idx
	    // variable will contain the index (subscript) of the selected
	    // array element.
	    Scroll List 1, 1, 40, 15 List: points_list Variable: points_idx
        do

            // When user makes a choice, enable the OK button.
            EnableItem("OK")
        endItem

	    // Add an OK button. The Default keyword allows the user to press Enter.
	    Button "OK" 21, 17, 7, 1 Default
	        Do

	            // Return the index (subscript) of the chosen element
	            return(points_idx)
	        endItem 

	    // Add a Cancel button. The Cancel keyword allows the user to press Esc.
	    Button "Cancel" 31, same, 7, 1 Cancel
	        Do

            // Return null if user cancels
            return()
        endItem 
EndDBox


// Create a toolbox, which is a type of dialog box (dbox).
// The keyword "ToolBox" makes the dialog box display until closed by the user.
// The keyword NoKeyboard moves the focus to the toolbox immediately when user clicks in it.
Dbox "find and zoom toolbox"  center,center Title: "Find and Zoom" ToolBox NoKeyboard
    // A description of the dialog box:
    // Displays Click on Map tool and Edit Text item to input search distance.
    // Defaults search distance to 5 miles; when user clicks on the map, call 
    // the macro to find nearest places and then display the array.

    // This section is automatically run when the dbox is first opened.
    Init do 

        // Set the layer variable for use below; always put a layer name into
        // a variable, so that if you change the name you only have to change 
        // it in one place in your program.
        layer="Place"

        // Initialize the search_distance to 5 miles, based on the current
        // map units. R2I() changes a real number to an integer.
        current_units = GetMapUnits("Plural")
        search_distance = R2I(5 * GetUnitSize("Miles", current_units))
    endItem

    // This is needed to allow the user to close the toolbox by clicking on 
    // the X in the upper-right corner.
    Close do
        return()
    endItem

    // Create a tool that, when chosen, waits for the user to click on the map.
    // You will use the find icon from one of Maptitude's standard bitmap files
    // (MainButtons.bmp).
    Tool "click_tool" 0,1 Icon: "bmp\\MainButtons|16"  help: "Click on Map"
        do

            // Wait for user to click on map.
            clicked_point = ClickCoord()

            // Run the nearest places macro from lesson 1.
            // A program line can be continued on to the next line at any point
            // except in the middle of a string.
            points_list = RunMacro("get nearest points", 
                layer, clicked_point, search_distance)

            // If the macro found points then display the data; if no points are
            // found, the macro has already displayed a message, so just 
            // drop through to end of item.
            if points_list<>null then do

                // You will copy the data into a formatting array for use in a scroll 
                // list in lesson 3.

                // To demonstrate another way to create an array, you will build 
                // it by concatenation rather than dimensioning it.

                // First set the formatting array to null.
                formatting_array = null

                // Now loop through the list of points and their data
                for i = 1 to points_list.length do
                    // Concatenate the array with an array containing your data.
                    // First, create arrays for the formatting of each field.
                    // Distance will be right justified, 1 decimal, ending in column 5.
                    f_distance = {5, "R*0.0", points_list[i][1]}
                    // City will be left justified, starting in column 7.
                    f_city = {7, "L", points_list[i][2]}
                    // State will be left justified, starting in column 32.
                    f_state = {32, "L", points_list[i][3]}
                    // Second, put them together in an array. 
                    f_array = { f_distance, f_city, f_state }
                    // Third, concatenate the formatting array with that array. 
                    formatting_array = formatting_array + { f_array }
                    end

// BEGINNING OF NEW SECTION TO CALL DBOX
                // Call the dialog box to display the list and return the choice.
                choice = RunDbox("get choice", formatting_array)  

                // If the user didn't press Cancel then create a scope and zoom
                if choice<>null then do

                    // Get the conversion between miles and the current map units
                    mi_cmu = GetUnitSize("Miles", GetMapUnits("Plural"))
                    // Compute .1 and 5 miles in current units
                    tenth = .1 * mi_cmu
                    five = 5 * mi_cmu

                    // Create a tiny scope for the clicked point. A scope is a
                    // center point, and a width and height in the current map
                    // units. The last argument to Scope() must be zero.
                    clicked_pt_scp = Scope(clicked_point, tenth, tenth, 0)

                    // Create a tiny scope for chosen point; the coordinate is
                    // in array element 4.
                    chosen_pt_scp = Scope(points_list[choice][4], tenth, tenth, 0)

                    // Now combine the two scopes
                    new_scope = ScopeUnion(clicked_pt_scp, chosen_pt_scp)

                    // If the two points were less than five miles apart then set
                    // the scope width and height to 5 miles; otherwise expand
                    // the scope by 10% to add a margin.
                    if new_scope.height< five then 
                        new_scope = Scope(new_scope.center, five, five, 0)
                    else new_scope = Scope(new_scope.center, 
                        new_scope.width*1.1, new_scope.height*1.1, 0)

                    // Now set the new scope and redraw the current map.
                    SetMapScope(, new_scope)
                    RedrawMap()
                    end
// END OF NEW SECTION TO CALL DBOX
	            end
	        endItem

    // Display the current integer value of search_distance and 
    // allow user to change it.

    // Place the title at column 6, .5 rows down, and 16 characters wide.
    Text "Search Distance" 6, .5, 16

    // Place the integer edit box below the "Search Distance" title and
    // make it 4 characters wide.
    Edit Integer 8, 2.0, 4 Variable: search_distance

    // Place the text for the current map units right after and on the same 
    // line as the integer edit box.
    Text after, same Variable: current_units

EndDBox


// THIS IS A DUPLICATE OF THE SAME MACRO IN LESSON 1
// A macro to get the nearest points on the search layer
Macro "get nearest points" (search_layer, subject_point, search_distance)

    // Each macro should have a description at the beginning:
    // Finds points within search_distance units of subject_point on 
    // search_layer and returns an array containing a data array for each
    // point, with distance, city and state; the data arrays are in order
    // by distance. This macro is designed to work with the Place layer
    // in Lessons.map.

    // Store the current layer, then make the specified layer the working layer.
    curr_layer = GetLayer()
    SetLayer(search_layer)

    // Find the nearest points in the working layer and return, in array rhs,
    // the record handles (the string form of the record ID) for the closest 
    // records. The last argument, an options array, can be null.
    rhs = LocateNearestRecords(subject_point, search_distance, null)

    // If no points were found then display message and return.
    if rhs = null then do
        ShowMessage('Sorry, no points were within your search distance.')
    // Reset the layer to the stored layer; this is very important when an
    // add-in is working with the standard interface
    SetLayer(curr_layer)

        return()
        end    
 
    // Dimension an array to the length of the record handles (rhs) array.
    Dim data[rhs.length]

    // Look through the record handles array.
    for i = 1 to rhs.length do

        // Use the record handle to set the current record position on the 
        // current view (which in this case is the Place layer).
        SetRecord(, rhs[i])

        // Get the point coordinate for the current record on the current layer,
        // converting the record handle to its numeric equivalent (an ID).
        target_point = GetPoint(rh2id(rhs[i]))

        // Get the distance between the clicked point and the current point.
        distance = GetDistance(subject_point, target_point)

        // Add data to the output array. To add data from a current record for 
        // a layer use a "field specification", which is the layer name in 
        // a variable + "." + field name, e.g. layer.city, not Place.city.
        data[i]={distance, search_layer.city, search_layer.state, target_point}
        end  // end of record handles loop

    // Reset the layer and return the data array to the calling program 
    SetLayer(curr_layer)
    return(data)

EndMacro

























   // A macro to get the nearest points on the search layer
Macro "get nearest points" (search_layer, subject_point, search_distance)

    // Each macro should have a description at the beginning:
    // Finds points within search_distance units of subject_point on 
    // search_layer and returns an array containing a data array for each
    // point, with distance, city and state; the data arrays are in order
    // by distance. This macro is designed to work with the Place layer
    // in Lessons.map.

    // Store the current layer, then make the specified layer the working layer.
    curr_layer = GetLayer()
    SetLayer(search_layer)

    // Find the nearest points in the working layer and return, in array rhs,
    // the record handles (the string form of the record ID) for the closest 
    // records. The last argument, an options array, can be null.
    rhs = LocateNearestRecords(subject_point, search_distance, null)

    // If no points were found then display message and return.
    if rhs = null then do
        ShowMessage('Sorry, no points were within your search distance.')
    // Reset the layer to the stored layer; this is very important when an
    // add-in is working with the standard interface
    SetLayer(curr_layer)

        return()
        end    
 
    // Dimension an array to the length of the record handles (rhs) array.
    Dim data[rhs.length]

    // Look through the record handles array.
    for i = 1 to rhs.length do

        // Use the record handle to set the current record position on the 
        // current view (which in this case is the Place layer).
        SetRecord(, rhs[i])

        // Get the point coordinate for the current record on the current layer,
        // converting the record handle to its numeric equivalent (an ID).
        target_point = GetPoint(rh2id(rhs[i]))

        // Get the distance between the clicked point and the current point.
        distance = GetDistance(subject_point, target_point)

        // Add data to the output array. To add data from a current record for 
        // a layer use a "field specification", which is the layer name in 
        // a variable + "." + field name, e.g. layer.city, not Place.city.
        data[i]={distance, search_layer.city, search_layer.state, target_point}
        end  // end of record handles loop

    // Reset the layer and return the data array to the calling program 
    SetLayer(curr_layer)
    return(data)

EndMacro
