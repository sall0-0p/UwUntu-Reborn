local ContentProvider = System.getContentProvider();
local Metadata = ContentProvider.get("UwU.FileSystem.Metadata.Metadata");

local FileMetadata = {};
FileMetadata.__index = FileMetadata;

local metadataManager;

local function generateProxy(object, path)
    local proxy = setmetatable({}, {
        __index = function(proxy, key)
            return object[key];
        end,

        __newindex = function (proxy, key, value)
            rawset(object, key, value);

            metadataManager.updateMeta(path, object);
        end
    })

    return proxy;
end

---@param file File
function FileMetadata.new(file, permissions, custom, linkedTo)
    local metadata = setmetatable(Metadata(file.displayName, permissions, custom), FileMetadata);
    metadata.size = fs.getSize(file.path);
    metadata.linkedTo = linkedTo or nil; -- if file is a symlink this property has to be set to respectable path.

    return generateProxy(metadata, file.path);
end

function FileMetadata.fromTable(data, path)
    local metadata = setmetatable(Metadata(data["1"], data["2"], data["0"]), FileMetadata);
    metadata.size = data["5"];
    metadata.linkedTo = data["6"];
    metadata.defaultPermissions = data["3"] or Metadata.DEFAULT_PERMISSIONS;
    metadata.permissions = data["2"] or {};
    metadata.custom = data["0"] or {};

    return generateProxy(metadata, path);
end

function FileMetadata:toTable()
    local function resolveDefaultPermissions() 
        if self.defaultPermissions == Metadata.DEFAULT_PERMISSIONS then
            return nil;
        else 
            return self.defaultPermissions;
        end
    end

    local function resolveEmpty(value) 
        if next(value) == nil then
            return nil;
        else 
            return value;
        end
    end

    return {
        ["1"] = self.displayName;
        ["2"] = resolveEmpty(self.permissions);
        ["3"] = resolveDefaultPermissions();
        ["5"] = self.size;
        ["6"] = self.linkedTo;

        ["0"] = resolveEmpty(self.custom);
    }
end

setmetatable(FileMetadata, {
    __index = Metadata;
    __call = function(cls, ...) 
        return cls.new(...);
    end
})

function FileMetadata.init(mtdManager)
    metadataManager = mtdManager
    FileMetadata["init"] = nil;
end

return FileMetadata;