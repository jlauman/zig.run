const std = @import("std");

// a struct with default field values and methods
pub const Plant = struct {
    name: []const u8,
    is_fruit: bool = false,
    is_fungi: bool = false,
    is_legume: bool = false,
    is_vegetable: bool = false,

    pub fn init(name: []const u8) Plant {
        // other fields default to false
        return Plant{
            .name = name,
        };
    }

    pub fn isEdible(self: Plant) bool {
        var is_edible = false;
        if (self.is_fruit) {
            is_edible = true;
        } else if (self.is_fungi) {
            is_edible = true;
        } else if (self.is_legume) {
            is_edible = true;
        } else if (self.is_vegetable) {
            is_edible = true;
        }
        return is_edible;
    }

    pub fn isFruit(self: Plant) bool {
        return self.is_fruit;
    }

    pub fn setIsFruit(self: *Plant) void {
        self.is_fruit = true;
    }

    pub fn isFungi(self: Plant) bool {
        return self.is_fungi;
    }

    pub fn setIsFungi(self: *Plant) void {
        self.is_fungi = true;
    }

    pub fn isLegume(self: Plant) bool {
        return self.is_legume;
    }

    pub fn setIsLegume(self: *Plant) void {
        self.is_legume = true;
    }

    pub fn isVegetable(self: Plant) bool {
        return self.is_vegetable;
    }

    pub fn setIsVegetable(self: *Plant) void {
        self.is_vegetable = true;
    }
};
