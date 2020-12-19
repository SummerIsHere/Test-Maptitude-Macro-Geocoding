
//Macro 'testrun1'
	
// Get scope from tutorial
folder = RunMacro("G30 Tutorial Folder")
info = GetDBInfo(folder + "states.cdf")
scope = info[1]

// Create a map using this scope
roo_map  = CreateMap("Test Map", {
 {"Scope", scope},
 {"Auto Project", "True"},
 {"Position", 100, 150}
 })

//Open csv
tbl = OpenTable("imported", "CSV",{"C:\\open_active\\GIS\\maptitude\\macro_dev\\test_macro\\input_addy.csv",null})
SetView(tbl)

//Write back out a fixed format binary file (apparently reading from one is required to get Geographic Precision)
field_info = GetTableStructure(tbl)
ExportView(tbl + "|", "FFB","C:\\open_active\\GIS\\maptitude\\macro_dev\\test_macro\\imported.ffb",null,null)

//Close out csv view
CloseView(tbl)
view_list = GetViewNames() 
//Re-import binary file

reimp = OpenTable("reimported", "FFB",{"C:\\open_active\\GIS\\maptitude\\macro_dev\\test_macro\\imported.ffb",null})
SetView(reimp)
strct = GetTableStructure(view_name, {{"Include Original", "True"}})
strct = strct + {{"Geocoding Precision", "String", 48, 0, "False", , , , , , , null}}
modt = ModifyTable(reimp, strct)

//Begin geocodingpart
{ fieldNames , fieldSpecs } = GetFields(reimp,"All")
geo = CreateObject("Data.Geocoder").SetRegion()
region_name = geo.GetRegionName()
//ShowMessage("Locating view " + reimp + " in region " + region_name)

id_field = GetFieldFullSpec(reimp,"ID") // You need an input table with an integer ID field to get started
address_field = GetFieldFullSpec(reimp, "Address")
postal_field = GetFieldFullSpec(reimp, "Zipcode")
city_field = GetFieldFullSpec(reimp, "City")
state_field = GetFieldFullSpec(reimp, "State")

// Geocoding options: output geographic file in Maptitude dbd format
opts = {}
opts.best_match = 1 // Important, otherwise [Geocoding Precision] will not be filled
opts.try_methods = { 1 , 1, 1, 1, 1, 1} // Which ADDRESS_WIZARD methods to try, from most accurate to least accurate
new_layer = reimp + " coded"
opts.new_layer_name = new_layer
opts.out_db = "C:\\open_active\\GIS\\maptitude\\macro_dev\\test_macro\\exports\\" + reimp + " export.dbd"

// input_field_specs must be an array of 5 elements in this order for the best
// match geocoder: { address , address2 , city , state , postal_code }

input_field_specs = { address_field , null , city_field , state_field , postal_field }
result = geo.LocateView("ADDRESS_WIZARD",reimp + "|", id_field, input_field_specs , opts)
view_list = GetViewNames() 
field_info2 = GetTableStructure(new_layer)

//close input binary view
CloseView(reimp)
view_list = GetViewNames() 
csv_fl = {"ID","Geocoding Precision"}
coded_export = "C:\\open_active\\GIS\\maptitude\\macro_dev\\test_macro\\exports\\coded.csv"
coded_export_header = "C:\\open_active\\GIS\\maptitude\\macro_dev\\test_macro\\exports\\coded_header.csv"
ExportCSV(new_layer, coded_export, {{"Fields",csv_fl}})

hfile = OpenFile(coded_export_header,"w")
WriteLine(hfile, 'ID,"Geocoding Precision",Longitude,Latitude')
CloseFile(hfile)

//try out cursors



// Create a data cursor for navigation

cursor = CreateDataCursor(new_layer)

//while cursor.Fetch() != null do

// read the state name and population
//addy = cursor.GetValue("Address")
//lat = cursor.GetValue("Latitude")
// Display the information
//str = "The latitude of " + addy + " is " + String(lat)
//ShowMessage(str)
//end