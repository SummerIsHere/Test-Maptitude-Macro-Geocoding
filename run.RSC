
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
ExportView(tbl + "|", "FFB","C:\\open_active\\GIS\\maptitude\\macro_dev\\test_macro\\imported.ffb",null,null)


//Re-import binary file

reimp = OpenTable("reimported", "FFB",{"C:\\open_active\\GIS\\maptitude\\macro_dev\\test_macro\\imported.ffb",null})
SetView(reimp)
strct = GetTableStructure(view_name, {{"Include Original", "True"}})
strct = strct + {{"Geocoding Precision", "String", 144, 0, "False", , , , , , , null}}
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
opts.new_layer_name = reimp + " Layer"
opts.out_db = "C:\\open_active\\GIS\\maptitude\\macro_dev\\test_macro\\exports\\" + reimp + " export.dbd"

// input_field_specs must be an array of 5 elements in this order for the best
// match geocoder: { address , address2 , city , state , postal_code }

input_field_specs = { address_field , null , city_field , state_field , postal_field }
result = geo.LocateView("ADDRESS_WIZARD",reimp + "|", id_field, input_field_specs , opts)
view_list = GetViewNames() 

