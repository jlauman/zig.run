// unknown is the default Plant.kind
pub const Kind = enum {
    unknown,
    fruit,
    fungi,
    legume,
    vegetable,
};

// a struct with default field values and methods
pub const Plant = struct {
    name: []const u8,
    kind: Kind = Kind.unknown,

    pub fn init(name: []const u8) Plant {
        return Plant{
            .name = name,
        };
    }

    pub fn isEdible(self: Plant) bool {
        const is_edible = switch (self.kind) {
            .fruit, .fungi, .legume, .vegetable => true,
            .unknown => false,
        };
        return is_edible;
    }

    pub fn setType(self: *Plant, kind: Kind) void {
        self.kind = kind;
    }

    pub fn isFruit(self: Plant) bool {
        return self.kind == .fruit;
    }

    pub fn isFungi(self: Plant) bool {
        return self.kind == .fungi;
    }

    pub fn isLegume(self: Plant) bool {
        return self.kind == .legume;
    }

    pub fn isVegetable(self: Plant) bool {
        return self.kind == .vegetable;
    }
};
