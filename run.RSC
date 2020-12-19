
//Macro 'testrun1'
	
// Get the scope of a geographic file
folder = RunMacro("G30 Tutorial Folder")
info = GetDBInfo(folder + "states.cdf")
scope = info[1]
// Create a map using this scope
roo_map  = CreateMap("Test Map", {
 {"Scope", scope},
 {"Auto Project", "True"},
 {"Position", 100, 150}
 })

tbl = OpenTable("imported", "CSV",{"C:\\open_active\\GIS\\maptitude\\macro_dev\\test_macro\\input_addy.csv",null})
SetView(tbl)
field_info = GetTableStructure(tbl)

//std_tbl = StandardizeView(GetView(),{"Address"},null,"RID","CSV","C:\\open_active\\GIS\\maptitude_python\\test_macro\\standardized.csv",{{"Read Only","True"}})

//std_field_info = GetTableStructure(std_tbl)

//adapted from 
geo = CreateObject("Data.Geocoder").SetRegion()
region_name = geo.GetRegionName()
ShowMessage("Locating view " + tbl + " in region " + region_name)

id_field = GetFieldFullSpec(tbl,"RID") // You need an input table with an integer ID field to get started
address_field = GetFieldFullSpec(tbl, "Address") // These fields are in the Maptitude tutorial table
postal_field = GetFieldFullSpec(tbl, "Zipcode")
city_field = GetFieldFullSpec(tbl, "City")
state_field = GetFieldFullSpec(tbl, "State")

// Geocoding options: output geographic file in Maptitude dbd format

opts = {}
opts.best_match = 1 // Important, otherwise [Geocoding Precision] will not be filled
opts.try_methods = { 1 , 1, 1, 1, 1, 1} // Which ADDRESS_WIZARD methods to try, from most accurate to least accurate
opts.new_layer_name = tbl + " Layer"
opts.out_db = "C:\\open_active\\GIS\\maptitude\\macro_dev\\test_macro\\" + "Layer.dbd"

// input_field_specs must be an array of 5 elements in this order for the best
// match geocoder: { address , address2 , city , state , postal_code }
input_field_specs = { address_field , null , city_field , state_field , postal_field }
result = geo.LocateView("ADDRESS_WIZARD",tbl + "|", id_field, input_field_specs , opts)
//endMacro
