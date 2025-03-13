const std = @import("std");

// Define an interface for shapes that can calculate their area
const Shape = struct {
    ptr: *anyopaque,
    vtable: *const VTable,

    const VTable = struct {
        areaFn: *const fn (ptr: *anyopaque) f32,
    };

    // Convenience method to call the area function
    pub fn area(self: Shape) f32 {
        return self.vtable.areaFn(self.ptr);
    }
};

const Circle = struct {
    radius: f32,

    pub fn toInterface(self: *Circle) Shape {
        return .{
            .ptr = self,
            .vtable = &vtable,
        };
    }

    const vtable = Shape.VTable{
        .areaFn = areaImpl,
    };

    fn areaImpl(ptr: *anyopaque) f32 {
        const self = @as(*Circle, @ptrCast(@alignCast(ptr)));
        return std.math.pi * self.radius * self.radius;
    }
};

const Rectangle = struct {
    width: f32,
    height: f32,

    pub fn toInterface(self: *Rectangle) Shape {
        return .{
            .ptr = self,
            .vtable = &vtable,
        };
    }

    // Static VTable for all Rectangle instances
    const vtable = Shape.VTable{
        .areaFn = areaImpl,
    };

    // Implementation of area calculation for Rectangle
    fn areaImpl(ptr: *anyopaque) f32 {
        const self = @as(*Rectangle, @ptrCast(@alignCast(ptr)));
        return self.width * self.height;
    }
};

pub fn main() !void {
    var circle = Circle{ .radius = 5.0 };
    var rectangle = Rectangle{ .width = 4.0, .height = 6.0 };

    const shape1 = circle.toInterface();
    const shape2 = rectangle.toInterface();

    // Use the interface methods
    std.debug.print("Circle area: {d}\n", .{shape1.area()});
    std.debug.print("Rectangle area: {d}\n", .{shape2.area()});

    const shapes = [_]Shape{ shape1, shape2 };
    for (shapes) |shape| {
        std.debug.print("Shape area: {d}\n", .{shape.area()});
    }
}
