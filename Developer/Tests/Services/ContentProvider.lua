local ContentProvider = System.__contentProvider;
local tests = {};

function tests.importMap()
    local Map = ContentProvider.get("UwU.Utils.Map");
    local map = Map();

    return map.className == "Map"
end

return {
    tests = tests;
    titles = {
        importMap = "Importing Map class using ContentProvider";
    }
}