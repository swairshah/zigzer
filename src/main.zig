// In some other file
const std = @import("std");
const Graph = @import("Graph.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Create a graph with 4 vertices
    var graph = try Graph.init(allocator, 4);
    defer graph.deinit();

    // Add some edges
    try graph.addEdge(0, 1, 1.0); // 0 -> 1
    try graph.addEdge(0, 2, 2.0); // 0 -> 2
    try graph.addEdge(1, 2, 3.0); // 1 -> 2
    try graph.addEdge(2, 3, 4.0); // 2 -> 3

    // Get neighbors of vertex 0
    const neighbors = try graph.getNeighbors(0);
    for (neighbors) |edge| {
        std.debug.print("Edge to {} with weight {}\n", .{ edge.to, edge.weight });
    }

    try printGraph(graph);
}

fn printGraph(graph: Graph) !void {
    for (0..graph.vertex_count) |i| {
        std.debug.print("Vertex {}: ", .{i});
        const neighbors = try graph.getNeighbors(i);
        for (neighbors) |edge| {
            std.debug.print("{} -> {} (weight {})\n", .{ i, edge.to, edge.weight });
        }
    }
}
