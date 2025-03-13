const std = @import("std");
const Graph = @import("Graph.zig");

const BidirectionalEdge = struct {
    from: usize,
    to: usize,
    weight: f32,
};

const UndirectedGraph = struct {
    nodes: std.ArrayList(usize),
    edges: std.ArrayList(BidirectionalEdge),

    pub fn init(allocator: std.mem.Allocator, vertex_count: usize, edges: std.ArrayList(BidirectionalEdge)) !UndirectedGraph {
        var nodes = std.ArrayList(usize).init(allocator);
        for (0..vertex_count) |i| {
            try nodes.append(i);
        }
        return UndirectedGraph{
            .nodes = nodes,
            .edges = edges,
        };
    }

    pub fn deinit(self: *UndirectedGraph) void {
        self.nodes.deinit();
        self.edges.deinit();
    }

    pub fn addEdge(self: *UndirectedGraph, from: usize, to: usize, weight: f32) !void {
        try self.edges.append(BidirectionalEdge{ .from = self.nodes.items[from], .to = self.nodes.items[to], .weight = weight });
        try self.edges.append(BidirectionalEdge{ .from = self.nodes.items[to], .to = self.nodes.items[from], .weight = weight });
    }
};

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
fn printGraph(graph: anytype) !void {
    // for (0..graph.vertex_count) |i| {
    //     std.debug.print("Vertex {}: ", .{i});
    //     const neighbors = try graph.getNeighbors(i);
    //     for (neighbors) |edge| {
    //         std.debug.print("{} -> {} (weight {})\n", .{ i, edge.to, edge.weight });
    //     }
    // }

    switch (@TypeOf(graph)) {
        Graph => {
            for (0..graph.vertex_count) |i| {
                std.debug.print("Vertex {}: ", .{i});
                const neighbors = try graph.getNeighbors(i);
                for (neighbors) |edge| {
                    std.debug.print("{} -> {} (weight {})\n", .{ i, edge.to, edge.weight });
                }
            }
        },
        UndirectedGraph => {
            for (graph.nodes.items, 0..) |node, i| {
                std.debug.print("Vertex {}: ", .{i});
                for (graph.edges.items) |edge| {
                    if (edge.from.id == node.id) {
                        std.debug.print("{} -> {} (weight {})\n", .{ edge.from.id, edge.to.id, edge.weight });
                    }
                }
            }
        },
        else => @compileError("Unsupported graph type"),
    }
}

test "UndirectedGraph" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var graph = try UndirectedGraph.init(allocator, 4, std.ArrayList(BidirectionalEdge).init(allocator));
    defer graph.deinit();

    try graph.addEdge(0, 1, 1.0);
    try graph.addEdge(0, 2, 2.0);
    try graph.addEdge(1, 2, 3.0);
    try graph.addEdge(2, 3, 4.0);

    std.debug.print("Graph: {}\n", .{graph});
}
